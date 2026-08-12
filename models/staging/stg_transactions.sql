with source as (
    select * from {{ ref('raw_transactions') }}
),

cleaned as (
    select
        cast(transaction_id as string) as transaction_id,
        cast(wallet_id as string) as wallet_id,
        cast(customer_id as string) as customer_id,
        lower(trim(transaction_type)) as transaction_type,
        lower(trim(status)) as status,
        cast(amount_ngn as numeric) as amount_ngn,
        cast(fee_ngn as numeric) as fee_ngn,
        nullif(lower(trim(merchant_category)), '') as merchant_category,
        cast(created_at as timestamp) as created_at,
        cast(nullif(completed_at, '') as timestamp) as completed_at
    from source
)

select * from cleaned
