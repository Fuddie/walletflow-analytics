# WalletFlow Dashboard Specification

This folder documents the BI layer for the WalletFlow fintech analytics project.

The dashboard is intentionally designed on top of governed marts rather than raw transaction tables. That keeps metric definitions consistent across BI tools and makes the logic easier to test.

## Executive KPI cards

1. **Gross Transaction Value (GTV)** — total attempted transaction value across the selected period.
2. **Transaction Success Rate** — successful transactions divided by total transaction attempts.
3. **Transactions** — total transaction attempts.
4. **Successful Transaction Value** — value of successful transactions only.
5. **Fees Generated** — fees associated with successful transactions.
6. **DAU (Daily Active Users)** — distinct customers with at least one transaction attempt on a day.
7. **MAU (Monthly Active Users)** — distinct customers with at least one transaction attempt in a month.
8. **Average DAU** — average daily active-user count across observed dates in a month.
9. **DAU/MAU Stickiness** — average DAU divided by MAU. This approximates how frequently the monthly user base engages on an average day.
10. **Monthly Retention Rate** — customers active in both the current and previous month divided by the previous month's MAU.
11. **Cohort Retention Rate** — successful-transaction customers retained in later months divided by the size of their first-success cohort.
12. **Failed Transaction Rate** — failed transactions divided by total transaction attempts.
13. **Reversal Rate** — reversed transactions divided by total transaction attempts.
14. **Average Transaction Value** — GTV divided by transaction count.

## Metric ownership in the model layer

### `mart_daily_wallet_kpis`
Use for:

- DAU
- transaction count
- success/failure/reversal monitoring
- GTV
- successful transaction value
- fees generated

### `mart_monthly_engagement_kpis`
Use for:

- MAU
- average DAU
- peak DAU
- DAU/MAU stickiness
- previous-month retained customers
- monthly retention rate

### `mart_customer_cohort_retention`
Use for:

- cohort size
- retained customers by month number
- cohort retention rate
- retention curves / heatmaps

## Recommended visuals

### 1. Executive KPI strip
Show the selected period's GTV, transaction count, success rate, MAU, average DAU, DAU/MAU stickiness and retention rate.

### 2. Monthly GTV and transaction trend
Use `mart_daily_wallet_kpis` aggregated by month.

- X-axis: month
- Primary measure: GTV
- Secondary measure: transaction count

### 3. DAU and MAU trend
Use `mart_monthly_engagement_kpis` for MAU and average DAU, with `mart_daily_wallet_kpis` for individual daily points if needed.

- X-axis: month
- Measures: MAU, average DAU, peak DAU

### 4. DAU/MAU stickiness trend
Use `mart_monthly_engagement_kpis`.

- X-axis: month
- Measure: DAU/MAU stickiness
- Format: percentage

### 5. Month-over-month retention trend
Use `mart_monthly_engagement_kpis`.

- X-axis: month
- Measure: monthly retention rate
- Supporting measures: previous-month MAU and retained customers

### 6. Cohort retention heatmap
Use `mart_customer_cohort_retention`.

- Rows: cohort_month
- Columns: month_number
- Value: retention_rate

### 7. Success rate by transaction type
Use `fct_transactions`.

- Category: transaction_type
- Measure: successful transactions / total transactions

### 8. Transaction mix
Use `fct_transactions`.

- Category: transaction_type
- Measures: transaction count and transaction value

### 9. Customer segment contribution
Join `dim_customers` to `fct_transactions`.

- Category: customer_segment
- Measures: GTV, successful value, active customers

### 10. Failed transaction monitoring
Use `fct_transactions`.

- X-axis: transaction_date
- Measure: failed transaction count or rate
- Breakdown: transaction_type

## Synthetic dataset benchmark

The deterministic generator uses seed `42` and currently produces:

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

These figures are synthetic and exist only to demonstrate analytics engineering and BI design.

## Dashboard interview explanation

> "I designed the dashboard around governed marts rather than querying raw transaction tables directly. Daily transaction KPIs, MAU, DAU, stickiness and retention are defined in the transformation layer, then tested before BI consumes them. That means analysts and product teams use the same definitions instead of rebuilding metrics independently in every dashboard."
