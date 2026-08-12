# Interview Walkthrough

## 30-second version

WalletFlow is a synthetic digital-wallet analytics engineering project. I used dbt and BigQuery-style modelling to turn raw customer, wallet and transaction data into tested, business-ready models. The project includes an incremental transaction fact with a late-arriving-data lookback window, governed DAU/MAU and retention KPIs, source freshness checks, reconciliation tests, and GitHub Actions quality checks.

## 2-minute version

The problem I wanted to solve was common in fintech: operational transaction tables are useful for processing payments, but they are not ideal as a reporting layer. Different teams can easily calculate the same metric differently, and delayed transaction records can also make incremental pipelines incomplete if they are handled too narrowly.

I generated synthetic customer, wallet and transaction data, declared the raw tables as dbt sources, and created staging models that explicitly select and standardise required columns. I avoid `SELECT *` so upstream schema changes do not silently flow through the project.

The intermediate layer contains reusable customer activity logic. The marts layer contains a customer dimension, an incremental transaction fact, daily wallet KPIs, monthly customer activity, a monthly engagement KPI mart, and a cohort-retention mart.

The transaction fact uses `transaction_id` as its MERGE key and re-reads a configurable three-day window during incremental runs. This means a transaction that arrives late but has a slightly older event timestamp can still be picked up without rebuilding the entire table or creating duplicates.

For product engagement, I defined DAU as distinct customers with at least one transaction attempt on a day and MAU as distinct customers active in a month. The monthly engagement mart also calculates average DAU, peak DAU, DAU/MAU stickiness and previous-month retention. A separate cohort model defines cohorts from each customer's first successful transaction and tracks successful activity in later months.

Testing includes primary-key checks, relationships, accepted values, positive financial amounts, completion timestamps for successful transactions, transaction-status reconciliation, composite-grain tests and retention logic. For example, average DAU cannot exceed MAU and retained customers cannot exceed the population they are being retained from.

GitHub Actions adds another control layer: pull requests are checked for `SELECT *`, and when BigQuery credentials are configured the workflow can run `dbt seed`, `dbt build` and `dbt source freshness` before changes are accepted.

## Good follow-up answers

**Why dbt?**  
Because it lets transformation logic live in version-controlled SQL models with testing, lineage, modular dependencies and documentation.

**Why separate staging and marts?**  
Staging handles source cleanup once. Marts focus on reusable business logic and reporting metrics. This avoids repeated cleansing and metric definitions.

**Why avoid `SELECT *`?**  
Because I want each model to declare exactly which columns it depends on. That makes schema changes more visible and reduces accidental propagation of unwanted fields.

**Why use a lookback window on the incremental fact?**  
Because a transaction can arrive late. If I only read records newer than the exact latest timestamp already processed, I could miss a delayed record. Re-reading the last few days and merging on `transaction_id` gives the pipeline a small safety window.

**What is DAU/MAU stickiness?**  
It is average daily active users divided by monthly active users. It gives a simple indication of how frequently the monthly user base is active on an average day.

**How do you define monthly retention?**  
I count customers active in both the current and previous month, then divide that number by the previous month's MAU.

**How is cohort retention different?**  
Monthly retention compares one month with the immediately previous month. Cohort retention groups customers by when they first successfully used the product and follows those same customers over several later months.

**What would you still improve for production?**  
I would add a true warehouse ingestion timestamp, snapshots for changing customer attributes, orchestration, alerts for failed freshness/tests, environment-specific datasets and a hosted BI dashboard.

**How would a BI team use this?**  
I would expose the marts as the governed reporting layer. Looker or Power BI would query those models instead of raw transaction events, which keeps KPI definitions consistent.
