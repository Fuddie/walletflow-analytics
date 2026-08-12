-- Singular test: assert_transaction_status_flags_are_exclusive
-- What this tests:
--   Every fact transaction must belong to exactly one final status bucket:
--   successful, failed, or reversed.
-- Why it matters:
--   Daily KPI counts rely on these three flags. If more than one flag is TRUE,
--   or none is TRUE, status totals can double-count or omit transactions.
-- Expected result:
--   The sum of the three boolean flags must equal exactly 1 for every transaction.
-- How dbt evaluates it:
--   The test PASSES when this query returns zero rows.

select
    transaction_id,
    status,
    is_successful,
    is_failed,
    is_reversed
from {{ ref('fct_transactions') }}
where cast(is_successful as int64)
    + cast(is_failed as int64)
    + cast(is_reversed as int64) != 1
