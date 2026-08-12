-- Model: dim_customers
-- Purpose: Build a customer dimension enriched with wallet attributes and
-- lifetime transaction behaviour for customer-level analysis.
-- Grain: One row per customer_id.
-- Join strategy: LEFT JOINs preserve customers even when wallet or transaction
-- activity is missing.

with customers as (
    -- Customer attributes required in the final dimension.
    select
        customer_id,
        first_name,
        last_name,
        email,
        state,
        customer_segment,
        signup_date,
        is_verified
    from {{ ref('stg_customers') }}
),

wallets as (
    -- Wallet attributes enrich the customer profile.
    select
        wallet_id,
        customer_id,
        wallet_status,
        current_balance_ngn
    from {{ ref('stg_wallets') }}
),

transaction_summary as (
    -- Aggregate transaction behaviour once at customer grain so the final join
    -- does not duplicate customer records.
    select
        customer_id,
        count(*) as lifetime_transaction_count,
        countif(status = 'success') as lifetime_successful_transaction_count,
        sum(case when status = 'success' then amount_ngn else 0 end) as lifetime_successful_value_ngn,
        min(created_at) as first_transaction_at,
        max(created_at) as latest_transaction_at
    from {{ ref('stg_transactions') }}
    group by customer_id
)

select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.state,
    c.customer_segment,
    c.signup_date,
    c.is_verified,
    w.wallet_id,
    w.wallet_status,
    w.current_balance_ngn,

    -- Customers without transactions receive zero activity counts instead of NULL.
    coalesce(t.lifetime_transaction_count, 0) as lifetime_transaction_count,
    coalesce(t.lifetime_successful_transaction_count, 0) as lifetime_successful_transaction_count,
    coalesce(t.lifetime_successful_value_ngn, 0) as lifetime_successful_value_ngn,

    -- Timestamps remain NULL for customers with no transaction history.
    t.first_transaction_at,
    t.latest_transaction_at
from customers as c
left join wallets as w
    on c.customer_id = w.customer_id
left join transaction_summary as t
    on c.customer_id = t.customer_id
