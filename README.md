# WalletFlow Analytics

A personal analytics engineering project that models a fictional digital-wallet business using **dbt, SQL, dimensional modelling, data quality testing, incremental processing, source freshness checks, and business-ready marts**.

> **Portfolio note:** WalletFlow is a synthetic fintech project. The company, customers, wallets, and transactions are fictional and were created only to demonstrate analytics engineering skills.

## Why this project exists

Fintech teams often collect large volumes of transactional data, but raw events are not immediately suitable for reporting. Product, operations, finance, and growth teams need consistent definitions for metrics such as transaction volume, success rate, active customers, repeat usage, and customer retention.

WalletFlow demonstrates how an analytics engineer can turn raw wallet data into trusted, reusable datasets while also thinking about **operational reliability**, not only SQL transformations.

## Business questions

This project is designed to answer questions such as:

- How much transaction value flows through the platform each day?
- What percentage of transactions succeed?
- Which transaction types have the highest failure rates?
- How many customers are active each day and month?
- Which customers are repeat users?
- How does monthly customer activity change over time?
- How well do customer cohorts retain after their first successful transaction?
- Which customer segments contribute the most transaction value?

## Tech stack

- **SQL** — transformation logic and business metrics
- **dbt** — model organisation, testing, documentation, lineage and incremental builds
- **Google BigQuery** — target warehouse design, partitioning and clustering
- **Python** — deterministic synthetic data generation
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
                                                     └─> mart_customer_cohort_retention
```

## Repository structure

```text
walletflow-analytics/
├── analyses/                  # Ad-hoc business questions
├── dashboard/                 # Dashboard metric specification
├── docs/                      # Architecture, data quality and operating notes
├── models/
│   ├── staging/               # Source definitions + cleaned source-aligned models
│   ├── intermediate/          # Reusable transformation logic
│   └── marts/                 # Business-facing facts, dimensions, KPIs and retention
├── scripts/                   # Synthetic data generator
├── seeds/                     # Synthetic source data
├── tests/                     # Singular reconciliation/business-rule tests
├── dbt_project.yml
├── packages.yml
└── profiles.example.yml
```

## Core models

### `fct_transactions`
One row per transaction. The model is configured as an **incremental BigQuery model** using `transaction_id` as the merge key. It is partitioned by `transaction_date` and clustered by commonly filtered dimensions.

### `dim_customers`
One row per customer with registration information, customer segment, wallet metadata, and lifetime transaction summaries.

### `mart_daily_wallet_kpis`
A daily KPI table for executive or product reporting, including:

- transaction count
- successful transaction count
- transaction success rate
- gross transaction value (GTV)
- successful transaction value
- fees generated
- active customers

### `mart_customer_monthly_activity`
Monthly customer-level activity used for engagement and behavioural analysis.

### `mart_customer_cohort_retention`
Monthly retention by first successful transaction cohort. It reports cohort size, retained customers, month number and retention rate.

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
- retained customers never exceeding original cohort size
- month-zero cohort retention reconciling to 100%

Every important singular test contains comments explaining **what is tested, why the rule matters, and what a returned row means**.

## Source freshness

`models/staging/sources.yml` declares the raw tables as dbt sources. The transaction source includes a freshness configuration.

Because this is a synthetic portfolio dataset and does not contain a real ingestion timestamp, `created_at` is used only as a **demonstration freshness proxy**. In a production pipeline, freshness should normally use an ingestion timestamp such as `loaded_at` or `_ingested_at`.

Run the freshness check with:

```bash
dbt source freshness
```

## Incremental processing

`fct_transactions` demonstrates an incremental MERGE pattern:

- `transaction_id` is the unique merge key
- later runs process only transactions newer than the latest loaded `created_at`
- the model is partitioned by transaction date
- clustering supports common customer, type and status filters
- unexpected schema changes are configured to fail instead of silently propagating

For a real source that permits late-arriving or updated historical events, the incremental filter would typically use an ingestion/update timestamp or a configurable lookback window rather than only `created_at`.

## How to run

1. Install dbt for BigQuery.
2. Create a BigQuery dataset for the project.
3. Copy `profiles.example.yml` into your local dbt profiles directory and replace the placeholders.
4. Install packages:

```bash
dbt deps
```

5. Load the synthetic seed data:

```bash
dbt seed
```

6. Check source freshness:

```bash
dbt source freshness
```

7. Build and test the project:

```bash
dbt build
```

8. Generate documentation:

```bash
dbt docs generate
dbt docs serve
```

## Interview explanation

A simple way to explain the project:

> "I built WalletFlow to demonstrate how I would structure analytics engineering for a digital wallet. I started with synthetic customer, wallet and transaction data, declared the raw tables as dbt sources, and standardised them in staging. I built reusable intermediate logic, an incremental transaction fact, customer and KPI marts, and a cohort-retention model. I also added source, schema and reconciliation tests so I can detect grain, integrity and business-rule problems before they reach a dashboard. The objective is to create a trusted analytics layer rather than have every analyst redefine the same metrics."

## Further improvements

- Add customer snapshots for slowly changing attributes
- Add a configurable late-arriving-data lookback window to the incremental fact
- Add CI with `dbt build` on pull requests
- Add orchestration and alerting around failed tests/freshness checks
- Connect the marts to a live BI dashboard

## Author

**Fuad Abiola Adebisi**  
Analytics Engineer  
GitHub: [Fuddie](https://github.com/Fuddie)
