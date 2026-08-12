with transactions as (
    select
        transaction_date,
        transaction_id,
        customer_id,
        amount_ngn,
        fee_ngn,
        is_successful,
        is_failed,
        is_reversed
    from {{ ref('fct_transactions') }}
)

select
    transaction_date,
    count(transaction_id) as transaction_count,
    countif(is_successful) as successful_transaction_count,
    countif(is_failed) as failed_transaction_count,
    countif(is_reversed) as reversed_transaction_count,
    safe_divide(countif(is_successful), count(transaction_id)) as transaction_success_rate,
    sum(amount_ngn) as gross_transaction_value_ngn,
    sum(case when is_successful then amount_ngn else 0 end) as successful_transaction_value_ngn,
    sum(case when is_successful then fee_ngn else 0 end) as fees_generated_ngn,
    count(distinct customer_id) as active_customers
from transactions
group by transaction_date
order by transaction_date
