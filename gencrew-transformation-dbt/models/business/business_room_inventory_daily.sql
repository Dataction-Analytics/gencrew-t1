{{ config(
    materialized='incremental',
    unique_key='inventory_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
-- Business: cleansed and standardised room_inventory_daily.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on inventory_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'room_inventory_daily') }}
    {% if is_incremental() %} where ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        inventory_id,
        hotel_id,
        inventory_date,
        rooms_available,
        rooms_out_of_order,
        source_system,
        ingested_at,
        batch_id
from source
