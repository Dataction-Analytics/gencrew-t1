{{ config(
    materialized='incremental',
    unique_key='room_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
-- Business: cleansed and standardised rooms.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on room_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'rooms') }}
    {% if is_incremental() %} where ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        room_id,
        hotel_id,
        room_type_id,
        room_number,
        floor_no,
        is_active,
        source_system,
        ingested_at
from source
