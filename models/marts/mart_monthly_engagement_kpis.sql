-- Model: mart_monthly_engagement_kpis
-- Purpose: Provide one governed monthly engagement table for product and
-- executive dashboards.
-- Grain: One row per activity_month.
--
-- KPI definitions:
--   * MAU = distinct customers with at least one transaction attempt in month.
--   * Average DAU = average of the daily distinct active-customer counts in month.
--   * Peak DAU = highest daily active-customer count observed in month.
--   * DAU/MAU stickiness = average DAU divided by MAU.
--   * Previous-month retained customers = customers active in both this month
--     and the immediately preceding calendar month.
--   * Monthly retention rate = previous-month retained customers divided by the
--     previous month's active-customer population.
--
-- Why transaction attempts rather than only successful transactions for DAU/MAU?
-- Opening/using the wallet enough to attempt a transaction is treated as product
-- activity. Cohort retention remains success-based in mart_customer_cohort_retention.

with customer_daily_activity as (
    -- One customer/date record is enough for DAU calculations; multiple
    -- transactions by the same customer on the same day should count once.
    select distinct
        transaction_date,
        customer_id
    from {{ ref('fct_transactions') }}
),

customer_monthly_activity as (
    -- Collapse activity into one customer/month record for MAU and retention.
    select distinct
        date_trunc(transaction_date, month) as activity_month,
        customer_id
    from {{ ref('fct_transactions') }}
),

daily_active_users as (
    select
        transaction_date,
        date_trunc(transaction_date, month) as activity_month,
        count(distinct customer_id) as daily_active_users
    from customer_daily_activity
    group by transaction_date, activity_month
),

monthly_activity as (
    select
        activity_month,
        count(distinct customer_id) as monthly_active_users
    from customer_monthly_activity
    group by activity_month
),

monthly_dau_summary as (
    select
        activity_month,
        avg(daily_active_users) as average_daily_active_users,
        max(daily_active_users) as peak_daily_active_users
    from daily_active_users
    group by activity_month
),

previous_month_retention as (
    -- Join each customer's current-month activity to the same customer's
    -- activity exactly one calendar month earlier.
    select
        current_month.activity_month,
        count(distinct current_month.customer_id) as previous_month_retained_customers
    from customer_monthly_activity as current_month
    inner join customer_monthly_activity as previous_month
        on current_month.customer_id = previous_month.customer_id
        and previous_month.activity_month = date_sub(current_month.activity_month, interval 1 month)
    group by current_month.activity_month
),

previous_month_population as (
    -- The denominator for month-over-month retention is the prior month's MAU.
    select
        current_month.activity_month,
        previous_month.monthly_active_users as previous_month_active_users
    from monthly_activity as current_month
    left join monthly_activity as previous_month
        on previous_month.activity_month = date_sub(current_month.activity_month, interval 1 month)
)

select
    m.activity_month,
    m.monthly_active_users,
    d.average_daily_active_users,
    d.peak_daily_active_users,

    -- Stickiness approximates how frequently the monthly user base engages on
    -- an average day. Higher values mean more frequent usage.
    safe_divide(d.average_daily_active_users, m.monthly_active_users) as dau_mau_stickiness,

    -- The first month has no prior month in the dataset, so these values can be NULL.
    p.previous_month_active_users,
    coalesce(r.previous_month_retained_customers, 0) as previous_month_retained_customers,
    safe_divide(
        coalesce(r.previous_month_retained_customers, 0),
        p.previous_month_active_users
    ) as monthly_retention_rate
from monthly_activity as m
inner join monthly_dau_summary as d
    on m.activity_month = d.activity_month
left join previous_month_retention as r
    on m.activity_month = r.activity_month
left join previous_month_population as p
    on m.activity_month = p.activity_month
order by m.activity_month
