-- Model: stg_customers
-- Purpose: Standardise the raw synthetic customer source into a clean, typed,
-- source-aligned staging model for downstream dimensions and marts.
-- Grain: One row per customer_id.
-- Important design choice: Columns are selected explicitly so upstream schema
-- changes do not silently propagate into downstream models.

with source as (
    -- Read from the declared dbt source rather than referencing the seed model
    -- directly. This makes source lineage visible in dbt docs and allows source
    -- tests/freshness configuration to live in one place.
    select
        customer_id,
        first_name,
        last_name,
        email,
        state,
        customer_segment,
        signup_date,
        is_verified
    from {{ source('walletflow_raw', 'raw_customers') }}
),

cleaned as (
    select
        -- Cast business keys to STRING so joins use a consistent data type.
        cast(customer_id as string) as customer_id,

        -- Normalise names and email casing/whitespace for consistent reporting.
        lower(trim(first_name)) as first_name,
        lower(trim(last_name)) as last_name,
        lower(trim(email)) as email,

        -- State and segment are controlled categorical values, stored in uppercase.
        upper(trim(state)) as state,
        upper(trim(customer_segment)) as customer_segment,

        -- Enforce analytics-friendly date and boolean types.
        cast(signup_date as date) as signup_date,
        cast(is_verified as bool) as is_verified
    from source
)

-- Final projection is explicit to make the model contract clear.
select
    customer_id,
    first_name,
    last_name,
    email,
    state,
    customer_segment,
    signup_date,
    is_verified
from cleaned
