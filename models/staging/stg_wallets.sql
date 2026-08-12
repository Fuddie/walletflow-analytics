with source as (
    select
        wallet_id,
        customer_id,
        created_at,
        wallet_status,
        current_balance_ngn
    from {{ ref('raw_wallets') }}
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

select
    wallet_id,
    customer_id,
    wallet_created_at,
    wallet_status,
    current_balance_ngn
from cleaned
