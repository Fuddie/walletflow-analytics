# Interview Walkthrough

## 30-second version

WalletFlow is a synthetic digital-wallet analytics project. I used a layered analytics engineering approach: raw seed data, staging models, reusable intermediate logic, and business-facing marts. I added data quality tests and designed the marts so BI tools can consume consistent metrics without reimplementing business logic.

## 2-minute version

The problem I wanted to solve was common in fintech: operational transaction tables are good for processing payments but not ideal for analytics. Different teams can easily calculate the same metric differently.

I created synthetic customer, wallet, and transaction data, then used dbt-style modelling to create a clean analytics layer. The staging layer standardises data types and values. The intermediate layer creates reusable customer-level daily activity. The marts layer contains a transaction fact table, customer dimension, daily KPI mart, and monthly customer activity mart.

I also included tests for primary keys, relationships, accepted values, positive amounts, and completion timestamps for successful transactions. That gives the reporting layer both consistency and basic data quality protection.

The main business metrics are transaction count, transaction success rate, gross transaction value, successful transaction value, fees, and active customers.

## Good follow-up answers

**Why dbt?**  
Because it lets transformation logic live in version-controlled SQL models with testing, lineage, modular dependencies, and documentation.

**Why separate staging and marts?**  
Staging handles source cleanup once. Marts then focus on business logic. This avoids repeating cleansing rules and makes downstream reporting easier to maintain.

**What would you change for production scale?**  
I would make the transaction fact incremental, partition large BigQuery tables by transaction date, cluster on frequently filtered fields, add orchestration and CI, and monitor freshness and test failures.

**How would a BI team use this?**  
I would expose the marts as the governed reporting layer. Looker or Power BI would query those tables instead of raw transaction events, which keeps KPI definitions consistent.
