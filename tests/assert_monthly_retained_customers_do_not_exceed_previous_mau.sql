-- Test: Customers retained from the previous month cannot exceed the previous
-- month's active-user population.
-- Why: A retained customer must have belonged to the denominator population.
-- Any returned row indicates duplicated joins or incorrect retention logic.
-- dbt singular tests pass when this query returns zero rows.

select
    activity_month,
    previous_month_retained_customers,
    previous_month_active_users
from {{ ref('mart_monthly_engagement_kpis') }}
where previous_month_active_users is not null
  and previous_month_retained_customers > previous_month_active_users
