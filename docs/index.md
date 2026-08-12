# WalletFlow Analytics

WalletFlow is a personal analytics engineering project for a fictional digital-wallet platform. It uses synthetic data to demonstrate a complete reporting workflow from raw sources through tested marts and product KPIs.

All customer, wallet and transaction records in this project are generated. No employer or production data is included.

## Dataset

- **250** customers
- **250** wallets
- **5,000** transactions
- **~₦145.85m** gross transaction value
- **~88.4%** transaction success rate
- Activity from **January to June 2026**

## Models

### Staging
Source data is standardised with explicit column selection, consistent data types, controlled categorical values and null handling.

### Core models

- `fct_transactions` — incremental transaction fact table
- `dim_customers` — customer dimension with wallet and activity measures
- `int_customer_daily_activity` — reusable customer-day transaction logic

### Reporting marts

- `mart_daily_wallet_kpis` — daily transaction and customer metrics
- `mart_customer_monthly_activity` — customer activity by month
- `mart_monthly_engagement_kpis` — DAU, MAU, DAU/MAU and monthly retention
- `mart_customer_cohort_retention` — retention by first-success cohort

## Data quality

Tests cover primary keys, relationships, accepted values, transaction amounts, completion timestamps, status reconciliation, composite grains and retention logic.

## Incremental processing

`fct_transactions` uses `transaction_id` as the MERGE key and reprocesses a configurable three-day window on incremental runs. This allows recently delayed or corrected records to be picked up without rebuilding the full fact table.

## Reporting

The reporting layer includes transaction performance, GTV, DAU, MAU, DAU/MAU, month-over-month retention and cohort retention. Metric definitions are kept in dbt models rather than repeated inside individual dashboards.

## Project links

- [Architecture](architecture.md)
- [Technical notes](technical_notes.md)
- [Dashboard specification](../dashboard/README.md)
- [Repository](https://github.com/Fuddie/walletflow-analytics)

## Author

**Fuad Abiola Adebisi**  
Analytics Engineer
