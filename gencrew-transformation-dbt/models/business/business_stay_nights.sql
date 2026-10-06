{{ config(
    materialized='incremental',
    unique_key='stay_night_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
-- Business: cleansed and standardised stay_nights.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on stay_night_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'stay_nights') }}
    {% if is_incremental() %} where ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        stay_night_id,
        stay_date,
        reservation_id,
        hotel_id,
        room_id,
        room_type_id,
        is_occupied,
        source_system,
        ingested_at,
        room_revenue
from source
