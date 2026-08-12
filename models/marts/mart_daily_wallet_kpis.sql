-- Model: mart_daily_wallet_kpis
-- Purpose: Produce daily business KPIs for executive, product and operations reporting.
-- Grain: One row per transaction_date.
-- Metric governance: Status flags come from fct_transactions so downstream BI tools
-- use one consistent definition of success, failure and reversal.

with transactions as (
    -- Select only fields required for daily KPI calculation.
    select
        transaction_date,
        transaction_id,
        customer_id,
        amount_ngn,
        fee_ngn,
        is_successful,
        is_failed,
        is_reversed
    from {{ ref('fct_transactions') }}
)

select
    transaction_date,

    -- Total number of transaction attempts on the date.
    count(transaction_id) as transaction_count,

    -- Status counts help monitor platform reliability and transaction outcomes.
    countif(is_successful) as successful_transaction_count,
    countif(is_failed) as failed_transaction_count,
    countif(is_reversed) as reversed_transaction_count,

    -- Success rate = successful transactions / all transaction attempts.
    -- SAFE_DIVIDE prevents division-by-zero errors if a date ever has no records.
    safe_divide(countif(is_successful), count(transaction_id)) as transaction_success_rate,

    -- GTV includes all attempted transaction value, regardless of final status.
    sum(amount_ngn) as gross_transaction_value_ngn,

    -- Completed value includes only successful transactions.
    sum(case when is_successful then amount_ngn else 0 end) as successful_transaction_value_ngn,

    -- Fees are recognised only for successful transactions in this portfolio model.
    sum(case when is_successful then fee_ngn else 0 end) as fees_generated_ngn,

    -- Distinct customers with at least one transaction attempt on the date.
    count(distinct customer_id) as active_customers
from transactions
group by transaction_date
order by transaction_date
