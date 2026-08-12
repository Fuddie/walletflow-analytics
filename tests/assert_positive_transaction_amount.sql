-- Singular test: assert_positive_transaction_amount
-- What this tests:
--   Transaction amounts must be greater than zero.
-- Why it matters:
--   Zero or negative amounts would make wallet-volume and value KPIs unreliable
--   unless they were explicitly modelled as a different event type.
-- How dbt evaluates it:
--   A singular test PASSES when this query returns zero rows.
--   Any row returned below is therefore a failing transaction that needs review.

select
    transaction_id,
    customer_id,
    wallet_id,
    transaction_type,
    status,
    amount_ngn,
    created_at
from {{ ref('stg_transactions') }}
where amount_ngn <= 0
