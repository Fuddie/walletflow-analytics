-- Model: fct_transactions
-- Purpose: Provide the central transaction fact table used by KPI and customer
-- activity marts.
-- Grain: One row per transaction_id.
--
-- Incremental strategy:
--   * The first run performs a full build.
--   * Later runs re-read a configurable recent-history window rather than only
--     reading records newer than the exact latest timestamp already loaded.
--   * This lookback protects the fact table from late-arriving transactions or
--     corrections whose event timestamp is slightly older than the latest load.
--   * unique_key = transaction_id allows dbt to MERGE re-read records safely,
--     updating existing rows instead of creating duplicates.
--   * partition_by transaction_date improves BigQuery pruning for date filters.
--   * cluster_by supports common customer/type/status access patterns.
--   * on_schema_change = 'fail' prevents an unexpected upstream schema change
--     from silently changing the production fact table.
--
-- The lookback length is configured in dbt_project.yml as
-- var('incremental_lookback_days'). The default project value is 3 days.
--
-- Portfolio note: the current source data is synthetic and static, but this
-- configuration demonstrates a common production pattern for delayed events.

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
    -- Explicit dependency on only the fields required by this fact table.
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
        -- Late-arriving-data protection:
        -- Instead of starting exactly after max(created_at), subtract the
        -- configurable lookback window and reprocess those recent records.
        -- MERGE + transaction_id then de-duplicates/replaces matching facts.
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

    -- Calendar fields make common BI filters and aggregations simpler.
    date(created_at) as transaction_date,
    extract(year from created_at) as transaction_year,
    extract(month from created_at) as transaction_month,

    -- Boolean flags centralise status logic so downstream models do not repeatedly
    -- redefine what counts as successful, failed or reversed.
    status = 'success' as is_successful,
    status = 'failed' as is_failed,
    status = 'reversed' as is_reversed
from transactions
