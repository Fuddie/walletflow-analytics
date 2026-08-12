# WalletFlow Dashboard Specification

This folder documents the BI layer for the WalletFlow fintech analytics project.

## Executive KPI cards

1. **Gross Transaction Value (GTV)** — total transaction value across the selected period.
2. **Transaction Success Rate** — successful transactions divided by total transactions.
3. **Active Customers** — distinct customers with at least one transaction in the selected period.
4. **Transactions** — total transaction count.
5. **Successful Transaction Value** — value of successful transactions only.
6. **Fees Generated** — fees associated with successful transactions.

## Recommended visuals

### 1. Monthly GTV trend
Use `mart_daily_wallet_kpis` aggregated by month.

- X-axis: Month
- Y-axis: Gross Transaction Value
- Secondary measure: Transaction Count

### 2. Success rate by transaction type
Use `fct_transactions`.

- Category: transaction_type
- Measure: successful transactions / total transactions

### 3. Transaction mix
Use `fct_transactions`.

- Category: transaction_type
- Measures: transaction count and transaction value

### 4. Monthly active customers
Use `mart_customer_monthly_activity`.

- X-axis: Month
- Y-axis: Distinct active customers

### 5. Customer segment contribution
Join `dim_customers` to transaction facts.

- Category: customer_segment
- Measures: GTV, successful transaction value, active customers

### 6. Failed transaction monitoring
Use `fct_transactions`.

- X-axis: transaction_date
- Measure: failed transaction count
- Breakdown: transaction_type

## Portfolio dataset summary

The deterministic synthetic dataset generator currently produces:

- 250 customers
- 250 wallets
- 5,000 transactions
- Transaction activity covering January to June 2026

A generated run using seed `42` produced approximately:

- **₦145.85m** gross transaction value
- **88.4%** overall transaction success rate
- **250** distinct customers with transaction activity across the period

These figures are synthetic and exist only to demonstrate analytics engineering and BI design.

## Dashboard interview explanation

> "I designed the dashboard around governed marts rather than querying raw transaction tables directly. The KPI definitions are created in the transformation layer, so BI tools only consume approved business logic. This reduces metric duplication and helps different teams report the same numbers consistently."
