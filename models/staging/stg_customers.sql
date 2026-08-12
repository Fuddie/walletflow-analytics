with source as (
    select * from {{ ref('raw_customers') }}
),

cleaned as (
    select
        cast(customer_id as string) as customer_id,
        lower(trim(first_name)) as first_name,
        lower(trim(last_name)) as last_name,
        lower(trim(email)) as email,
        upper(trim(state)) as state,
        upper(trim(customer_segment)) as customer_segment,
        cast(signup_date as date) as signup_date,
        cast(is_verified as bool) as is_verified
    from source
)

select * from cleaned
