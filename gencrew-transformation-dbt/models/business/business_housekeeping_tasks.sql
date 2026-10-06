{{ config(
    materialized='incremental',
    unique_key='task_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
-- Business: cleansed and standardised housekeeping_tasks.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on task_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'housekeeping_tasks') }}
    {% if is_incremental() %} where ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        task_id,
        hotel_id,
        room_id,
        task_date,
        task_type,
        status,
        minutes_taken,
        source_system,
        ingested_at
from source
