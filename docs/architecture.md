# WalletFlow Architecture

WalletFlow follows a simple analytics engineering layering pattern.

## 1. Raw / seed layer
Synthetic source tables represent operational systems:

- `raw_customers`
- `raw_wallets`
- `raw_transactions`

## 2. Staging layer
Staging models standardise field names, data types, casing, and null handling while remaining close to the source structure.

## 3. Intermediate layer
`int_customer_daily_activity` creates reusable customer-day transaction logic. This prevents downstream marts from repeating aggregation rules.

## 4. Marts layer
Business-facing models separate facts, dimensions, and reporting datasets:

- `fct_transactions`
- `dim_customers`
- `mart_daily_wallet_kpis`
- `mart_customer_monthly_activity`

## Why this structure matters

The layered approach makes transformation logic easier to test, review, and reuse. Business users consume stable marts rather than querying raw tables directly.
