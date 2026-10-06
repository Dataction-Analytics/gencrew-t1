{{ config(
    materialized='incremental',
    unique_key='cancellation_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
-- Business: cleansed and standardised cancellations.
-- Incremental: only rows with cancelled_at beyond the last run's high-water mark are
-- read; they MERGE on cancellation_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'cancellations') }}
    {% if is_incremental() %} where cancelled_at > (select coalesce(max(cancelled_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        cancellation_id,
        reservation_id,
        cancelled_at,
        reason_code,
        cancelled_by,
        source_system,
        ingested_at,
        penalty_amount
from source
