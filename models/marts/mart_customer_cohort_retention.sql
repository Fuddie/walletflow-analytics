-- Model: mart_customer_cohort_retention
-- Purpose: Measure monthly customer retention by grouping customers into the
-- month of their first observed successful transaction and tracking whether
-- they return in later months.
-- Grain: One row per cohort_month + activity_month.
--
-- Business definition used here:
--   * Cohort month = month of a customer's first successful transaction.
--   * Retained customer = a cohort customer with at least one successful
--     transaction in the activity month.
--   * Month number = whole-month distance from cohort month to activity month.
--   * Retention rate = retained customers / original cohort size.
--
-- Why successful transactions only?
-- A failed attempt does not demonstrate completed product usage. Using success
-- creates a cleaner engagement signal for this portfolio example.

with successful_transactions as (
    -- Only columns needed for cohort calculations are selected.
    select
        customer_id,
        transaction_date
    from {{ ref('fct_transactions') }}
    where is_successful = true
),

first_success as (
    -- Find the first month in which each customer successfully transacted.
    select
        customer_id,
        date_trunc(min(transaction_date), month) as cohort_month
    from successful_transactions
    group by customer_id
),

monthly_activity as (
    -- Collapse multiple successful transactions in the same month into one
    -- customer-month activity record so a customer is counted once per month.
    select distinct
        customer_id,
        date_trunc(transaction_date, month) as activity_month
    from successful_transactions
),

cohort_activity as (
    select
        f.cohort_month,
        a.activity_month,
        a.customer_id,

        -- BigQuery DATE_DIFF returns the month distance between activity and
        -- cohort month: 0 = acquisition month, 1 = next month, etc.
        date_diff(a.activity_month, f.cohort_month, month) as month_number
    from monthly_activity as a
    inner join first_success as f
        on a.customer_id = f.customer_id
    where a.activity_month >= f.cohort_month
),

cohort_sizes as (
    -- Cohort size is fixed from the first-success population and becomes the
    -- denominator for every later retention month.
    select
        cohort_month,
        count(distinct customer_id) as cohort_size
    from first_success
    group by cohort_month
),

retained as (
    -- Count distinct returning customers for each cohort/activity month.
    select
        cohort_month,
        activity_month,
        month_number,
        count(distinct customer_id) as retained_customers
    from cohort_activity
    group by cohort_month, activity_month, month_number
)

select
    r.cohort_month,
    r.activity_month,
    r.month_number,
    s.cohort_size,
    r.retained_customers,

    -- SAFE_DIVIDE protects against division by zero if an unexpected empty
    -- cohort were ever introduced upstream.
    safe_divide(r.retained_customers, s.cohort_size) as retention_rate
from retained as r
inner join cohort_sizes as s
    on r.cohort_month = s.cohort_month
order by r.cohort_month, r.month_number
