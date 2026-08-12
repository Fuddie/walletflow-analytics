# WalletFlow Analytics

**A fintech analytics engineering portfolio project by Fuad Abiola Adebisi.**

WalletFlow models a fictional digital-wallet platform and demonstrates how raw customer, wallet and transaction data can be transformed into reliable, tested, business-ready analytics datasets.

> All data in this project is synthetic. No real customer or employer data is used.

## Project at a glance

- **250** synthetic customers
- **250** synthetic wallets
- **5,000** synthetic transactions
- **~₦145.85m** generated transaction value
- **~88.4%** overall transaction success rate
- Transaction activity from **January to June 2026**

## What I built

### Transformation layer
Raw source-aligned tables are cleaned into staging models before reusable intermediate logic is applied.

### Analytics marts
The project exposes:

- `fct_transactions` — transaction-level fact model
- `dim_customers` — customer dimension with wallet and activity context
- `mart_daily_wallet_kpis` — daily product and executive KPIs
- `mart_customer_monthly_activity` — customer engagement by month

### Data quality
Tests cover primary-key integrity, accepted values, customer relationships, positive transaction values and successful-transaction completion timestamps.

### BI layer
The dashboard specification focuses on GTV, transaction success rate, transaction mix, active customers, customer segments and failed-transaction monitoring.

## Architecture

```text
Raw data
   │
   ├── customers
   ├── wallets
   └── transactions
          │
          ▼
     Staging models
          │
          ▼
  Intermediate models
          │
          ▼
  Facts + dimensions
          │
          ▼
      KPI marts
          │
          ▼
Looker / Power BI / Looker Studio
```

## Why this matters

The main analytics engineering principle demonstrated here is that business metrics should be defined once in governed transformation models rather than repeatedly inside dashboards. That helps teams use the same definitions for transaction success, transaction value and active customers.

## Interview-ready explanation

> "WalletFlow is a synthetic digital-wallet analytics project I built to demonstrate analytics engineering. I modelled customer, wallet and transaction data through staging, intermediate and mart layers. I then added tests around key data-quality rules and created BI-ready KPI models so reporting tools do not have to redefine business logic."

## Explore the project

- [Architecture](architecture.md)
- [Interview walkthrough](interview_walkthrough.md)
- [Dashboard specification](../dashboard/README.md)
- [GitHub repository](https://github.com/Fuddie/walletflow-analytics)

## Author

**Fuad Abiola Adebisi**  
Analytics Engineer  
[GitHub](https://github.com/Fuddie)
