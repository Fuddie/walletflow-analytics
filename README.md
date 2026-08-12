# WalletFlow Analytics

A personal analytics engineering project that models a fictional digital-wallet business using **dbt-style transformations, SQL, dimensional modelling, data quality tests, and business-ready marts**.

> **Portfolio note:** WalletFlow is a synthetic fintech project. The company, customers, wallets, and transactions are fictional and were created only to demonstrate analytics engineering skills.

## Why this project exists

Fintech teams often collect large volumes of transactional data, but raw events are not immediately suitable for reporting. Product, operations, finance, and growth teams need consistent definitions for metrics such as transaction volume, success rate, active customers, repeat usage, and customer retention.

WalletFlow demonstrates how an analytics engineer can turn raw wallet data into trusted, reusable datasets.

## Business questions

This project is designed to answer questions such as:

- How much transaction value flows through the platform each day?
- What percentage of transactions succeed?
- Which transaction types have the highest failure rates?
- How many customers are active each day and month?
- Which customers are repeat users?
- How does monthly customer activity change over time?
- Which customer segments contribute the most transaction value?

## Tech stack

- **SQL** — transformation logic and business metrics
- **dbt** — model organisation, testing, documentation, and lineage
- **Google BigQuery** — target warehouse design
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
                                                     └─> mart_customer_monthly_activity
```

## Repository structure

```text
walletflow-analytics/
├── analyses/                  # Ad-hoc business questions
├── dashboard/                 # Dashboard metric specification
├── docs/                      # Architecture and data dictionary
├── models/
│   ├── staging/               # Cleaned source-aligned models
│   ├── intermediate/          # Reusable transformation logic
│   └── marts/                 # Business-facing facts, dimensions, KPIs
├── scripts/                   # Synthetic data generator
├── seeds/                     # Synthetic source data
├── tests/                     # Singular data quality tests
├── dbt_project.yml
├── packages.yml
└── profiles.example.yml
```

## Core models

### `fct_transactions`
One row per transaction. Contains cleaned transaction attributes, customer and wallet identifiers, transaction status, amount, fees, and derived flags.

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
Monthly customer-level activity used for customer engagement and retention analysis.

## Data quality

The project includes tests for:

- unique and non-null primary keys
- accepted transaction statuses
- accepted transaction types
- positive transaction values
- valid customer references
- successful transactions having a completion timestamp

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

6. Build and test the project:

```bash
dbt build
```

7. Generate documentation:

```bash
dbt docs generate
dbt docs serve
```

## Interview explanation

A simple way to explain the project:

> "I built WalletFlow to demonstrate how I would structure analytics engineering for a digital wallet. I started with synthetic customer, wallet, and transaction data. I cleaned the raw tables in staging models, created reusable intermediate logic, and then built fact, dimension, and KPI marts. I also added dbt tests so the reporting layer is not only useful but trustworthy. The final marts can feed tools such as Looker or Power BI without every analyst redefining the same metrics."

## Next improvements

- Add incremental models for high-volume transaction data
- Add snapshots for customer profile changes
- Add cohort retention and funnel marts
- Add orchestration and CI checks
- Connect the marts to a live BI dashboard

## Author

**Fuad Abiola Adebisi**  
Analytics Engineer  
GitHub: [Fuddie](https://github.com/Fuddie)
