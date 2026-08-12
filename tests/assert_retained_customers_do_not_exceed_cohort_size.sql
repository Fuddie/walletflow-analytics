-- Test: assert_retained_customers_do_not_exceed_cohort_size
-- Purpose: Validate a core retention rule: the number of retained customers in
-- any activity month cannot be greater than the original cohort population.
--
-- dbt singular-test behaviour:
--   * PASS = this query returns zero rows.
--   * FAIL = every returned row is a cohort/month combination where the retained
--     population is logically impossible.
--
-- Why this matters:
-- A violation usually indicates duplicate counting, an incorrect join, or a
-- cohort denominator that was calculated at the wrong grain.

select
    cohort_month,
    activity_month,
    month_number,
    cohort_size,
    retained_customers,
    retention_rate
from {{ ref('mart_customer_cohort_retention') }}
where retained_customers > cohort_size
