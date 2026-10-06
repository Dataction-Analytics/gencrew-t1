{{ config(
    materialized='incremental',
    unique_key='audit_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
-- Business: cleansed and standardised batch_load_audit.
-- Incremental: only rows with load_started_at beyond the last run's high-water mark are
-- read; they MERGE on audit_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'batch_load_audit') }}
    {% if is_incremental() %} where load_started_at > (select coalesce(max(load_started_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        audit_id,
        batch_id,
        target_table,
        load_started_at,
        load_finished_at,
        rows_loaded,
        rows_rejected,
        status,
        source_system
from source
