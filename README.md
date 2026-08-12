# WalletFlow Analytics

A personal analytics engineering project that models a fictional digital-wallet business using **dbt, SQL, dimensional modelling, data quality testing, incremental processing, source freshness checks, product engagement KPIs, cohort retention, and CI**.

> **Portfolio note:** WalletFlow is a synthetic fintech project. The company, customers, wallets, and transactions are fictional and were created only to demonstrate analytics engineering skills.

## Why this project exists

Fintech teams often collect large volumes of transactional data, but raw events are not immediately suitable for reporting. Product, operations, finance, and growth teams need consistent definitions for transaction performance, DAU, MAU, stickiness, retention and customer value.

WalletFlow demonstrates how an analytics engineer can turn raw wallet data into trusted, reusable datasets while also thinking about **operational reliability**, not only SQL transformations.

## Business questions

This project is designed to answer questions such as:

- How much transaction value flows through the platform each day?
- What percentage of transactions succeed?
- Which transaction types have the highest failure rates?
- How many customers are active each day and month?
- How frequently does the monthly user base engage?
- What percentage of last month's active customers returned this month?
- How well do first-success cohorts retain over time?
- Which customer segments contribute the most transaction value?

## Tech stack

- **SQL** — transformation logic and business metrics
- **dbt** — model organisation, testing, documentation, lineage and incremental builds
- **Google BigQuery** — target warehouse design, partitioning and clustering
- **Python** — deterministic synthetic data generation
- **GitHub Actions** — pull-request SQL policy checks and optional BigQuery-backed dbt builds
- **BI-ready marts** — designed for Looker, Looker Studio, or Power BI

## Data model

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

## Core models

### `fct_transactions`
One row per transaction. The model is configured as an **incremental BigQuery MERGE** using `transaction_id` as the unique key. It is partitioned by `transaction_date`, clustered on common filter dimensions and uses a configurable recent-history lookback to capture late-arriving transactions.

### `dim_customers`
One row per customer with registration information, customer segment, wallet metadata, and lifetime transaction summaries.

### `mart_daily_wallet_kpis`
Daily executive/product KPIs including transaction count, success rate, GTV, successful value, fees and DAU.

### `mart_monthly_engagement_kpis`
One row per month containing:

- MAU
- average DAU
- peak DAU
- DAU/MAU stickiness
- previous-month active users
- previous-month retained customers
- month-over-month retention rate

### `mart_customer_monthly_activity`
Monthly customer-level activity used for engagement and behavioural analysis.

### `mart_customer_cohort_retention`
Monthly retention by first successful transaction cohort. It reports cohort size, retained customers, month number and cohort retention rate.

## Data quality

The project includes documented tests for:

- unique and non-null primary keys
- accepted transaction statuses and transaction types
- source-level key validation
- customer/wallet referential integrity
- positive transaction values
- successful transactions having a completion timestamp
- mutually exclusive transaction outcome flags
- daily KPI status reconciliation
- composite grains such as customer + activity date and customer + activity month
- retention rates remaining between 0% and 100%
- retained customers never exceeding their denominator population
- average DAU never exceeding MAU
- month-zero cohort retention reconciling to 100%

Every important singular test contains comments explaining **what is tested, why the rule matters, and what a returned row means**.

## Source freshness

`models/staging/sources.yml` declares the raw tables as dbt sources. The transaction source includes a freshness configuration.

Because this synthetic dataset does not contain a true warehouse ingestion timestamp, `created_at` is used only as a **demonstration freshness proxy**. A production pipeline should normally use an ingestion field such as `loaded_at` or `_ingested_at`.

## Late-arriving transactions

The incremental transaction fact uses a project variable:

```yaml
vars:
  incremental_lookback_days: 3
```

On incremental runs, the model re-reads the latest three days relative to the most recent loaded transaction rather than reading only strictly newer timestamps. `transaction_id` is then used as the MERGE key, so re-reading recent records does not create duplicates.

This protects the model from delayed events and recent corrections while avoiding a full-table rebuild.

## Engagement KPI definitions

- **DAU:** distinct customers with at least one transaction attempt on a day.
- **MAU:** distinct customers with at least one transaction attempt in a month.
- **DAU/MAU stickiness:** average DAU divided by MAU.
- **Monthly retention:** customers active in both current and previous month divided by previous-month MAU.
- **Cohort retention:** successful-transaction customers active in a later month divided by the size of their first-success cohort.

## Continuous Integration

`.github/workflows/dbt-ci.yml` adds pull-request quality checks.

The workflow always checks that model/test SQL does **not** use `SELECT *`. When BigQuery repository secrets are configured, it also:

1. installs dbt dependencies,
2. loads the synthetic seed data,
3. runs `dbt build`, and
4. runs `dbt source freshness`.

The BigQuery-backed steps expect these repository secrets:

- `GCP_PROJECT_ID`
- `GCP_SERVICE_ACCOUNT_JSON`

Without those cloud credentials, the no-`SELECT *` SQL policy check still runs and the BigQuery build steps are intentionally skipped.

## Synthetic dashboard benchmark

The deterministic seed-42 sample produces **250 customers, 250 wallets and 5,000 transactions** from January to June 2026. The dashboard specification documents GTV, transaction success, DAU, MAU, stickiness and retention metrics, including month-by-month benchmark values.

See [`dashboard/README.md`](dashboard/README.md).

## How to run

1. Install dbt for BigQuery.
2. Create a BigQuery dataset for the project.
3. Copy `profiles.example.yml` into your local dbt profiles directory and replace the placeholders.
4. Run `dbt deps`.
5. Run `dbt seed`.
6. Run `dbt source freshness`.
7. Run `dbt build`.
8. Run `dbt docs generate` and `dbt docs serve`.

## Interview explanation

> "I built WalletFlow to demonstrate how I would structure analytics engineering for a digital wallet. I started with synthetic customer, wallet and transaction data, declared the raw tables as dbt sources, and standardised them in staging. I built reusable intermediate logic, an incremental transaction fact with late-arriving-data protection, customer and KPI marts, MAU/DAU engagement metrics and cohort retention. I added source, schema and reconciliation tests, then added CI so pull requests can enforce SQL conventions and run dbt quality checks before changes reach the main branch."

## Further improvements

- Add customer snapshots for slowly changing attributes
- Add ingestion timestamps to separate event time from warehouse load time
- Add orchestration and alerting around failed tests/freshness checks
- Connect the marts to a live hosted BI dashboard

## Author

**Fuad Abiola Adebisi**  
Analytics Engineer  
GitHub: [Fuddie](https://github.com/Fuddie)
