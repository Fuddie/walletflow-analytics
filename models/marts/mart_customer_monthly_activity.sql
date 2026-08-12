with transactions as (
    select
        transaction_date,
        customer_id,
        transaction_type,
        amount_ngn,
        is_successful
    from {{ ref('fct_transactions') }}
)

select
    date_trunc(transaction_date, month) as activity_month,
    customer_id,
    count(*) as transaction_count,
    countif(is_successful) as successful_transaction_count,
    sum(case when is_successful then amount_ngn else 0 end) as successful_transaction_value_ngn,
    count(distinct transaction_type) as transaction_types_used,
    max(transaction_date) as latest_activity_date
from transactions
group by activity_month, customer_id
