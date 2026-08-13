# WalletFlow Analytics

WalletFlow is a personal analytics engineering project for a fictional digital-wallet business. It uses synthetic customer, wallet and transaction data to model transaction performance, customer activity and retention with **dbt, BigQuery SQL and Python**.

The repository uses synthetic data only and contains no employer, customer or production data.

## Project scope

The project addresses a common reporting problem: operational transaction data is useful for processing payments, but it needs cleaning, consistent definitions and testing before it is suitable for analytics.

WalletFlow builds a structured reporting layer for questions such as:

- How much transaction value is processed each day?
- What percentage of transactions succeed, fail or reverse?
- How many customers are active each day and month?
- How frequently do monthly active customers use the product?
- What percentage of active customers return in the following month?
- How do customer cohorts retain after their first successful transaction?

## Technology

- **dbt**: transformations, tests, documentation and incremental models
- **Google BigQuery**: warehouse design, partitioning and clustering
- **SQL**: data modelling and metric definitions
- **Python**: deterministic synthetic data generation
- **GitHub Actions**: pull-request SQL checks and dbt CI when BigQuery credentials are available

## Model structure

```text
raw_customers ───────> stg_customers ───────────────> dim_customers
                                │
raw_wallets ─────────> stg_wallets ─────────────────┤
                                │                    │
raw_transactions ────> stg_transactions ─> fct_transactions
                                │                    │
                                └─> int_customer_daily_activity
                                                     │
                                                     ├─> mart_daily_wallet_kpis
                                                     ├─> mart_customer_monthly_activity
                                                     ├─> mart_monthly_engagement_kpis
                                                     └─> mart_customer_cohort_retention
```

## Main models

### `fct_transactions`
Transaction fact table with one row per `transaction_id`. It uses an incremental BigQuery MERGE, is partitioned by `transaction_date`, clustered by commonly filtered fields and reprocesses a configurable recent-history window to capture late-arriving records.

### `dim_customers`
Customer dimension with registration details, wallet attributes and lifetime transaction measures.

### `mart_daily_wallet_kpis`
Daily transaction metrics including transaction count, success rate, gross transaction value, successful transaction value, fees and DAU.

### `mart_monthly_engagement_kpis`
Monthly engagement metrics including:

- MAU
- average DAU
- peak DAU
- DAU/MAU ratio
- previous-month active customers
- returning customers
- month-over-month retention rate

### `mart_customer_monthly_activity`
One row per customer per activity month, with transaction counts, successful activity and transaction value.

### `mart_customer_cohort_retention`
Retention by first-success cohort, including cohort size, retained customers, month number and retention rate.

## Metric definitions

- **DAU:** distinct customers with at least one transaction attempt on a day.
- **MAU:** distinct customers with at least one transaction attempt in a month.
- **DAU/MAU:** average DAU divided by MAU.
- **Monthly retention:** customers active in both the current and previous month divided by previous-month MAU.
- **Cohort retention:** customers with successful activity in a later month divided by the size of their first-success cohort.
- **GTV:** total attempted transaction value.
- **Transaction success rate:** successful transactions divided by total transaction attempts.

## Incremental processing and late-arriving data

The transaction fact uses the project variable below:

```yaml
vars:
  incremental_lookback_days: 3
```

During incremental runs, the model re-reads the most recent three-day window relative to the latest loaded transaction. `transaction_id` is the MERGE key, so existing rows are updated rather than duplicated.

This approach captures delayed transactions and recent corrections without rebuilding the full fact table on every run.

## Data quality

The project includes schema and singular tests for:

- non-null and unique primary keys
- accepted transaction statuses and transaction types
- customer and wallet referential integrity
- positive transaction amounts
- completion timestamps for successful transactions
- mutually exclusive transaction-status flags
- daily transaction-count reconciliation
- composite grains such as customer + date and customer + month
- success and retention rates remaining between 0 and 1
- retained customers not exceeding the relevant population
- average DAU not exceeding MAU
- month-zero cohort retention equalling 100%

SQL models and tests use explicit column selection rather than `SELECT *`.

## Source freshness

`models/staging/sources.yml` defines the raw tables as dbt sources. The transaction source includes a freshness check.

The synthetic dataset does not contain a warehouse ingestion timestamp, so `created_at` is used as a freshness proxy. In a production source, this would normally be replaced with an ingestion field such as `loaded_at` or `_ingested_at`.

## Continuous integration

`.github/workflows/dbt-ci.yml` runs quality checks on pull requests.

The workflow always checks model and test SQL for `SELECT *`. When `GCP_PROJECT_ID` and `GCP_SERVICE_ACCOUNT_JSON` are configured as repository secrets, the workflow also runs:

```bash
dbt seed --full-refresh
dbt build
dbt source freshness
```

## Synthetic dataset

The deterministic seed-42 dataset contains:

- **250 customers**
- **250 wallets**
- **5,000 transactions**
- transaction activity from **January to June 2026**
- approximately **₦145.85m GTV**
- approximately **88.42% transaction success rate**

Monthly engagement figures and dashboard definitions are documented in [`dashboard/README.md`](dashboard/README.md).

## Running the project

1. Install dbt for BigQuery.
2. Create a BigQuery project/dataset for the work.
3. Copy `profiles.example.yml` to the local dbt profiles directory and replace the placeholders.
4. Run `dbt deps`.
5. Run `dbt seed`.
6. Run `dbt source freshness`.
7. Run `dbt build`.
8. Run `dbt docs generate` and `dbt docs serve` if local dbt documentation is required.

## Documentation

- [Architecture](docs/architecture.md)
- [Technical notes](docs/technical_notes.md)
- [Dashboard specification](dashboard/README.md)

## Author

**Fuad Abiola Adebisi**  
Analytics Engineer  
[GitHub](https://github.com/Fuddie)
