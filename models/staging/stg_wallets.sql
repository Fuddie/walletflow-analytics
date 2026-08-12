-- Model: stg_wallets
-- Purpose: Clean and standardise raw wallet records for downstream customer
-- dimensions and wallet reporting.
-- Grain: One row per wallet_id.
-- Key checks are defined in schema.yml: wallet_id uniqueness/not-null,
-- customer relationship integrity, and accepted wallet_status values.

with source as (
    -- Select only fields required by downstream analytics models.
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
        -- Standardise identifiers for reliable joins across models.
        cast(wallet_id as string) as wallet_id,
        cast(customer_id as string) as customer_id,

        -- Rename created_at to make the wallet event explicit downstream.
        cast(created_at as timestamp) as wallet_created_at,

        -- Wallet status is a controlled category; normalise to uppercase.
        upper(trim(wallet_status)) as wallet_status,

        -- Balance is stored as NUMERIC for precise financial aggregation.
        cast(current_balance_ngn as numeric) as current_balance_ngn
    from source
)

-- Explicit final projection documents the staging contract.
select
    wallet_id,
    customer_id,
    wallet_created_at,
    wallet_status,
    current_balance_ngn
from cleaned
