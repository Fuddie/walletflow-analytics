-- Model: fct_transactions
-- Purpose: central transaction fact table used by reporting and customer-activity marts.
-- Grain: one row per transaction_id.
--
-- Incremental processing:
--   * The first run builds the full table.
--   * Later runs re-read a configurable recent-history window.
--   * This captures late-arriving transactions and recent corrections.
--   * transaction_id is the MERGE key, so matching rows are updated rather than duplicated.
--   * The table is partitioned by transaction_date for date-based pruning.
--   * It is clustered by customer_id, transaction_type and status for common filters.
--   * Unexpected schema changes fail the build instead of being accepted silently.
--
-- The lookback length is configured in dbt_project.yml as
-- var('incremental_lookback_days'). The project default is 3 days.

{{
    config(
        materialized='incremental',
        unique_key='transaction_id',
        incremental_strategy='merge',
        partition_by={
            'field': 'transaction_date',
            'data_type': 'date'
        },
        cluster_by=['customer_id', 'transaction_type', 'status'],
        on_schema_change='fail'
    )
}}

with transactions as (
    -- Only fields required by the fact table are selected.
    select
        transaction_id,
        wallet_id,
        customer_id,
        transaction_type,
        status,
        amount_ngn,
        fee_ngn,
        merchant_category,
        created_at,
        completed_at
    from {{ ref('stg_transactions') }}

    {% if is_incremental() %}
        -- Reprocess recent history instead of starting exactly after the latest
        -- loaded timestamp. MERGE handles matching transaction_id values safely.
        where created_at >= timestamp_sub(
            (
                select coalesce(max(created_at), timestamp('1900-01-01'))
                from {{ this }}
            ),
            interval {{ var('incremental_lookback_days', 3) }} day
        )
    {% endif %}
)

select
    transaction_id,
    wallet_id,
    customer_id,
    transaction_type,
    status,
    amount_ngn,
    fee_ngn,
    merchant_category,
    created_at,
    completed_at,

    -- Date fields support reporting and partitioning.
    date(created_at) as transaction_date,
    extract(year from created_at) as transaction_year,
    extract(month from created_at) as transaction_month,

    -- Status flags keep outcome logic consistent across downstream models.
    status = 'success' as is_successful,
    status = 'failed' as is_failed,
    status = 'reversed' as is_reversed
from transactions
