-- Model: stg_transactions
-- Purpose: Standardise raw wallet transaction events into a clean, typed model
-- used by all transaction facts, KPI marts and customer activity models.
-- Grain: One row per transaction_id.
-- Data-quality expectations are documented in schema.yml and singular tests.

with source as (
    -- Read from the declared dbt source so lineage and source-quality rules are
    -- visible in dbt documentation.
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
    from {{ source('walletflow_raw', 'raw_transactions') }}
),

cleaned as (
    select
        -- Normalise business keys for reliable joins.
        cast(transaction_id as string) as transaction_id,
        cast(wallet_id as string) as wallet_id,
        cast(customer_id as string) as customer_id,

        -- Standardise categorical values before accepted-values tests run.
        lower(trim(transaction_type)) as transaction_type,
        lower(trim(status)) as status,

        -- Financial values use NUMERIC to avoid floating-point rounding issues.
        cast(amount_ngn as numeric) as amount_ngn,
        cast(fee_ngn as numeric) as fee_ngn,

        -- Empty merchant categories are converted to NULL because they are not
        -- applicable to every transaction type.
        nullif(lower(trim(merchant_category)), '') as merchant_category,

        -- Cast event timestamps to enforce consistent temporal types.
        cast(created_at as timestamp) as created_at,
        cast(nullif(completed_at, '') as timestamp) as completed_at
    from source
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
    completed_at
from cleaned
