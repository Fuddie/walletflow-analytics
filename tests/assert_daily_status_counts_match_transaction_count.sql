-- Singular test: assert_daily_status_counts_match_transaction_count
-- What this tests:
--   For every reporting date, successful + failed + reversed transactions must
--   reconcile exactly to the total transaction count.
-- Why it matters:
--   This protects the headline daily KPI mart from silent classification gaps
--   or double counting in status logic.
-- How dbt evaluates it:
--   The test PASSES when this query returns zero rows.
--   Any returned date indicates a KPI reconciliation problem.

select
    transaction_date,
    transaction_count,
    successful_transaction_count,
    failed_transaction_count,
    reversed_transaction_count
from {{ ref('mart_daily_wallet_kpis') }}
where successful_transaction_count
    + failed_transaction_count
    + reversed_transaction_count != transaction_count
