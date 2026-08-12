# WalletFlow Dashboard Specification

This folder documents the reporting layer for WalletFlow. Metrics are defined in dbt models so reporting tools use the same calculations.

## KPI cards

1. **Gross Transaction Value (GTV)** — total attempted transaction value in the selected period.
2. **Transaction Success Rate** — successful transactions divided by total transaction attempts.
3. **Transactions** — total transaction attempts.
4. **Successful Transaction Value** — value of successful transactions only.
5. **Fees Generated** — fees associated with successful transactions.
6. **DAU** — distinct customers with at least one transaction attempt on a day.
7. **MAU** — distinct customers with at least one transaction attempt in a month.
8. **Average DAU** — average daily active-customer count across observed dates in a month.
9. **DAU/MAU** — average DAU divided by MAU.
10. **Monthly Retention Rate** — customers active in both the current and previous month divided by previous-month MAU.
11. **Cohort Retention Rate** — successful-transaction customers retained in later months divided by the size of their first-success cohort.
12. **Failed Transaction Rate** — failed transactions divided by total transaction attempts.
13. **Reversal Rate** — reversed transactions divided by total transaction attempts.
14. **Average Transaction Value** — GTV divided by transaction count.

## Reporting models

### `mart_daily_wallet_kpis`
Used for:

- DAU
- transaction count
- success, failure and reversal monitoring
- GTV
- successful transaction value
- fees generated

### `mart_monthly_engagement_kpis`
Used for:

- MAU
- average DAU
- peak DAU
- DAU/MAU
- returning customers
- monthly retention rate

### `mart_customer_cohort_retention`
Used for:

- cohort size
- retained customers by month number
- cohort retention rate
- retention heatmaps

## Recommended visuals

### Monthly GTV and transaction trend
Use `mart_daily_wallet_kpis` aggregated by month.

- X-axis: month
- Primary measure: GTV
- Secondary measure: transaction count

### DAU and MAU trend
Use `mart_monthly_engagement_kpis` for MAU and average DAU. Use `mart_daily_wallet_kpis` for individual daily active-customer points if needed.

### DAU/MAU trend
Use `mart_monthly_engagement_kpis`.

- X-axis: month
- Measure: DAU/MAU
- Format: percentage

### Month-over-month retention
Use `mart_monthly_engagement_kpis`.

- X-axis: month
- Measure: monthly retention rate
- Supporting measures: previous-month MAU and retained customers

### Cohort retention heatmap
Use `mart_customer_cohort_retention`.

- Rows: cohort month
- Columns: month number
- Value: retention rate

### Success rate by transaction type
Use `fct_transactions`.

- Category: transaction type
- Measure: successful transactions / total transactions

### Transaction mix
Use `fct_transactions`.

- Category: transaction type
- Measures: transaction count and transaction value

### Customer segment contribution
Join `dim_customers` to `fct_transactions`.

- Category: customer segment
- Measures: GTV, successful value and active customers

### Failed transaction monitoring
Use `fct_transactions`.

- X-axis: transaction date
- Measure: failed transaction count or rate
- Breakdown: transaction type

## Synthetic dataset benchmark

The deterministic generator uses seed `42` and produces:

- **250 customers**
- **250 wallets**
- **5,000 transactions**
- Activity from **January to June 2026**
- **₦145.85m** GTV
- **88.42%** overall transaction success rate
- **₦128.11m** successful transaction value
- **₦409.8k** successful-transaction fees

Monthly engagement from the generated sample:

| Month | MAU | Avg. DAU | Peak DAU | DAU/MAU | Previous-month retention |
|---|---:|---:|---:|---:|---:|
| Jan 2026 | 242 | 25.68 | 33 | 10.61% | N/A |
| Feb 2026 | 240 | 26.82 | 37 | 11.18% | 95.87% |
| Mar 2026 | 239 | 26.42 | 33 | 11.05% | 96.25% |
| Apr 2026 | 244 | 25.57 | 35 | 10.48% | 97.91% |
| May 2026 | 243 | 27.32 | 37 | 11.24% | 97.13% |
| Jun 2026 | 238 | 25.80 | 38 | 10.84% | 95.06% |

All figures above come from synthetic data generated for this project.
