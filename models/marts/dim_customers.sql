with customers as (
    select * from {{ ref('stg_customers') }}
),

wallets as (
    select * from {{ ref('stg_wallets') }}
),

transaction_summary as (
    select
        customer_id,
        count(*) as lifetime_transaction_count,
        countif(status = 'success') as lifetime_successful_transaction_count,
        sum(case when status = 'success' then amount_ngn else 0 end) as lifetime_successful_value_ngn,
        min(created_at) as first_transaction_at,
        max(created_at) as latest_transaction_at
    from {{ ref('stg_transactions') }}
    group by 1
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
    coalesce(t.lifetime_transaction_count, 0) as lifetime_transaction_count,
    coalesce(t.lifetime_successful_transaction_count, 0) as lifetime_successful_transaction_count,
    coalesce(t.lifetime_successful_value_ngn, 0) as lifetime_successful_value_ngn,
    t.first_transaction_at,
    t.latest_transaction_at
from customers c
left join wallets w using (customer_id)
left join transaction_summary t using (customer_id)
