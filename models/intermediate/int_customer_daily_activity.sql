-- Model: int_customer_daily_activity
-- Purpose: Aggregate transaction events to a reusable daily customer grain.
-- Grain: One row per customer_id per activity_date.
-- Why intermediate: This logic is reusable by retention, engagement and KPI marts,
-- so it should not be duplicated in multiple downstream models.

with transactions as (
    -- Pull only the fields required for daily customer aggregation.
    select
        customer_id,
        status,
        amount_ngn,
        fee_ngn,
        created_at
    from {{ ref('stg_transactions') }}
),

daily as (
    select
        -- Convert timestamp to calendar date for daily activity reporting.
        date(created_at) as activity_date,
        customer_id,

        -- Total attempts, regardless of final status.
        count(*) as transaction_count,

        -- Successful transaction count is used for engagement and conversion metrics.
        countif(status = 'success') as successful_transaction_count,

        -- Only successful value contributes to completed wallet activity.
        sum(case when status = 'success' then amount_ngn else 0 end) as successful_transaction_value_ngn,

        -- Fees are recognised here only on successful transactions.
        sum(case when status = 'success' then fee_ngn else 0 end) as fees_generated_ngn,

        -- Failed attempts are retained so downstream models can monitor reliability.
        countif(status = 'failed') as failed_transaction_count
    from transactions
    group by activity_date, customer_id
)

select
    activity_date,
    customer_id,
    transaction_count,
    successful_transaction_count,
    successful_transaction_value_ngn,
    fees_generated_ngn,
    failed_transaction_count
from daily
