# WalletFlow Architecture

WalletFlow uses a layered dbt structure so source cleaning, reusable logic and reporting calculations remain separate.

## Raw sources

Synthetic source tables represent the operational data boundary:

- `raw_customers`
- `raw_wallets`
- `raw_transactions`

The source definitions live in `models/staging/sources.yml` and include source-level tests. Transaction freshness is demonstrated using `created_at` because the synthetic data does not include a separate ingestion timestamp.

## Staging

Staging models standardise data types, text casing, categorical values and null handling while staying close to the source structure.

Each model selects required columns explicitly. This keeps dependencies clear and prevents new upstream fields from flowing into downstream models without review.

## Intermediate

`int_customer_daily_activity` creates reusable customer-day transaction measures. The model has one row per `customer_id` and `activity_date`.

## Core models

### `fct_transactions`

One row per transaction. The model is incremental and uses:

- `transaction_id` as the MERGE key
- partitioning by `transaction_date`
- clustering by `customer_id`, `transaction_type` and `status`
- a configurable three-day lookback for recently delayed records

### `dim_customers`

One row per customer with registration information, wallet attributes and lifetime transaction measures.

## Reporting marts

- `mart_daily_wallet_kpis` — daily transaction performance and DAU
- `mart_customer_monthly_activity` — customer-level monthly activity
- `mart_monthly_engagement_kpis` — MAU, average DAU, peak DAU, DAU/MAU and month-over-month retention
- `mart_customer_cohort_retention` — retention by first-success cohort

## Data flow

```text
Raw sources
    │
    ▼
Staging models
    │
    ▼
Intermediate logic
    │
    ├──────────────► Customer dimension
    │
    ▼
Incremental transaction fact
    │
    ├──────────────► Daily KPI mart
    ├──────────────► Monthly engagement mart
    └──────────────► Cohort retention mart
```

The final marts are intended to be queried by reporting tools such as Looker, Looker Studio or Power BI.
