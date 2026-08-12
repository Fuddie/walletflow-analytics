-- Test: assert_cohort_month_zero_is_full_retention
-- Purpose: Validate the acquisition-month baseline of the cohort model.
--
-- Business rule:
-- Every customer in a cohort is, by definition, active in that cohort's first
-- successful-transaction month. Therefore month_number = 0 should have:
--   retained_customers = cohort_size
--   retention_rate = 1.0
--
-- dbt singular-test behaviour:
--   * PASS = zero rows returned.
--   * FAIL = any returned cohort has an incorrect acquisition-month baseline.

select
    cohort_month,
    activity_month,
    month_number,
    cohort_size,
    retained_customers,
    retention_rate
from {{ ref('mart_customer_cohort_retention') }}
where month_number = 0
  and (
      retained_customers != cohort_size
      or retention_rate != 1
  )
