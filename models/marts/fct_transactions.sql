-- Model: fct_transactions
-- Purpose: Provide the central transaction fact table used by KPI and customer
-- activity marts.
-- Grain: One row per transaction_id.
-- Design note: The model keeps raw business attributes from staging and adds
-- reporting-friendly date parts and boolean status flags.

with transactions as (
    -- Explicit dependency on only the fields required by this fact table.
    select
        transaction_id,
        wallet_id,
        customer_id,
        transaction_type,
        status,
        amount_ngn,
        fee_ngn,
        merchant_category,
        created_at,
        completed_at
    from {{ ref('stg_transactions') }}
)

select
    transaction_id,
    wallet_id,
    customer_id,
    transaction_type,
    status,
    amount_ngn,
    fee_ngn,
    merchant_category,
    created_at,
    completed_at,

    -- Calendar fields make common BI filters and aggregations simpler.
    date(created_at) as transaction_date,
    extract(year from created_at) as transaction_year,
    extract(month from created_at) as transaction_month,

    -- Boolean flags centralise status logic so downstream models do not repeatedly
    -- redefine what counts as successful, failed or reversed.
    status = 'success' as is_successful,
    status = 'failed' as is_failed,
    status = 'reversed' as is_reversed
from transactions
