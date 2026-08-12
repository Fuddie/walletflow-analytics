-- Singular test: assert_successful_transactions_have_completion_time
-- What this tests:
--   Every transaction marked as successful must have a completed_at timestamp.
-- Why it matters:
--   A successful status without completion evidence is internally inconsistent and
--   could distort settlement, duration, completion-time or operational reporting.
-- How dbt evaluates it:
--   The test PASSES when this query returns zero rows.
--   Every returned row is a successful transaction missing completion evidence.

select
    transaction_id,
    customer_id,
    wallet_id,
    transaction_type,
    status,
    created_at,
    completed_at
from {{ ref('stg_transactions') }}
where status = 'success'
  and completed_at is null
