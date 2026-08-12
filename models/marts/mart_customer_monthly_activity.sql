-- Model: mart_customer_monthly_activity
-- Purpose: Provide one reusable monthly activity record per customer for
-- retention, engagement and cohort-style analysis.
-- Grain: One row per customer_id per activity_month.

with transactions as (
    -- Only fields needed for monthly customer aggregation are selected.
    select
        transaction_date,
        customer_id,
        transaction_type,
        amount_ngn,
        is_successful
    from {{ ref('fct_transactions') }}
)

select
    -- Month bucket used for trend and retention analysis.
    date_trunc(transaction_date, month) as activity_month,
    customer_id,

    -- Total attempts made by the customer during the month.
    count(*) as transaction_count,

    -- Count only transactions that completed successfully.
    countif(is_successful) as successful_transaction_count,

    -- Sum only successful value so failed/reversed attempts do not inflate activity.
    sum(case when is_successful then amount_ngn else 0 end) as successful_transaction_value_ngn,

    -- Measures breadth of product usage across transaction categories.
    count(distinct transaction_type) as transaction_types_used,

    -- Most recent transaction date in the month, useful for recency analysis.
    max(transaction_date) as latest_activity_date
from transactions
group by activity_month, customer_id
