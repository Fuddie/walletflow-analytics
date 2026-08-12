with transactions as (
    select * from {{ ref('stg_transactions') }}
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
    date(created_at) as transaction_date,
    extract(year from created_at) as transaction_year,
    extract(month from created_at) as transaction_month,
    status = 'success' as is_successful,
    status = 'failed' as is_failed,
    status = 'reversed' as is_reversed
from transactions
