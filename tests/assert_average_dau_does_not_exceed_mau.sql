-- Test: Average DAU must never exceed MAU.
-- Why: Every daily active customer in a month is part of that month's active
-- customer population. If average DAU is greater than MAU, aggregation logic
-- or joins have duplicated customers.
-- dbt singular tests pass when this query returns zero rows.

select
    activity_month,
    average_daily_active_users,
    monthly_active_users
from {{ ref('mart_monthly_engagement_kpis') }}
where average_daily_active_users > monthly_active_users
