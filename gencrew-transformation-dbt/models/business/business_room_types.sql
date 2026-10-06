{{ config(
    materialized='incremental',
    unique_key='room_type_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
-- Business: cleansed and standardised room_types.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on room_type_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'room_types') }}
    {% if is_incremental() %} where ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        room_type_code,
        room_type_id,
        hotel_id,
        room_type_name,
        max_occupancy,
        source_system,
        ingested_at,
        base_rate
from source
