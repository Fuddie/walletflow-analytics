# Technical Notes

## SQL conventions

- Required columns are selected explicitly in models and tests.
- Business logic is defined in dbt models rather than repeated in dashboards.
- Financial values use `NUMERIC` where appropriate.
- Controlled categories are standardised before accepted-value tests run.

## Incremental transaction model

`fct_transactions` is built incrementally with `transaction_id` as the MERGE key.

The model reprocesses a recent-history window on each incremental run:

```yaml
vars:
  incremental_lookback_days: 3
```

This allows delayed transactions and recent corrections to be captured. Reprocessed rows do not create duplicates because matching `transaction_id` values are merged.

## Partitioning and clustering

The transaction fact is partitioned by `transaction_date` and clustered by:

- `customer_id`
- `transaction_type`
- `status`

These fields match common reporting and filtering patterns.

## Activity metrics

### DAU
Distinct customers with at least one transaction attempt on a calendar day.

### MAU
Distinct customers with at least one transaction attempt in a calendar month.

### DAU/MAU
Average DAU divided by MAU for the month.

### Monthly retention
Customers active in both the current and previous month divided by the previous month's MAU.

### Cohort retention
Customers are assigned to the month of their first successful transaction. Retention measures the proportion of each cohort that records successful activity in later months.

## Testing approach

Tests cover both structural and business rules:

- primary-key uniqueness and nullability
- relationships between customers, wallets and transactions
- accepted status and transaction-type values
- positive transaction amounts
- completion timestamps for successful transactions
- one status flag per transaction
- daily status totals reconciling to transaction count
- one row per declared composite grain
- retention rates remaining between 0 and 1
- retained populations not exceeding their denominators
- month-zero cohort retention equalling 100%
- average DAU not exceeding MAU

A singular dbt test passes when it returns zero rows.

## Source freshness

The transaction source uses `created_at` as a freshness proxy because the synthetic dataset has no ingestion timestamp. A production implementation would use a warehouse load timestamp such as `loaded_at` or `_ingested_at`.

## Continuous integration

The GitHub Actions workflow checks pull-request SQL for `SELECT *` in model and test files.

When BigQuery credentials are configured, the same workflow can run:

```bash
dbt seed --full-refresh
dbt build
dbt source freshness
```
