with transactions as (
    select * from {{ ref('stg_transactions') }}
),

daily as (
    select
        date(created_at) as activity_date,
        customer_id,
        count(*) as transaction_count,
        countif(status = 'success') as successful_transaction_count,
        sum(case when status = 'success' then amount_ngn else 0 end) as successful_transaction_value_ngn,
        sum(case when status = 'success' then fee_ngn else 0 end) as fees_generated_ngn,
        countif(status = 'failed') as failed_transaction_count
    from transactions
    group by 1, 2
)

select * from daily
