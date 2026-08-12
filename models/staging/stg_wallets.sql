with source as (
    select * from {{ ref('raw_wallets') }}
),

cleaned as (
    select
        cast(wallet_id as string) as wallet_id,
        cast(customer_id as string) as customer_id,
        cast(created_at as timestamp) as wallet_created_at,
        upper(trim(wallet_status)) as wallet_status,
        cast(current_balance_ngn as numeric) as current_balance_ngn
    from source
)

select * from cleaned
