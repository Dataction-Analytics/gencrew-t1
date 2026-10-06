{{ config(
    materialized='incremental',
    unique_key='hotel_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
-- Business: cleansed and standardised hotels.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on hotel_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'hotels') }}
    {% if is_incremental() %} where ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        hotel_id,
        hotel_code,
        hotel_name,
        star_rating,
        total_rooms,
        city,
        country,
        brand,
        opened_on,
        timezone,
        source_system,
        ingested_at,
        batch_id
from source
