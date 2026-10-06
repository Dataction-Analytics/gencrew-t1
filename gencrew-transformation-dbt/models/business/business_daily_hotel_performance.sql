{{ config(
    materialized='incremental',
    unique_key='performance_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
-- Business: cleansed and standardised daily_hotel_performance.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on performance_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'daily_hotel_performance') }}
    where not (NOT (rooms_available > 0))
      and not (NOT (rooms_sold > 0))
      and not (NOT (rooms_available > 0))
      {% if is_incremental() %} and ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        performance_id,
        hotel_id,
        business_date,
        rooms_available,
        rooms_sold,
        rooms_out_of_order,
        arrivals,
        departures,
        source_system,
        ingested_at,
        batch_id,
        other_revenue,
        room_revenue,
        rooms_available - rooms_sold AS rooms_unsold
from source
