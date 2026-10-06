{{ config(
    materialized='incremental',
    unique_key='review_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
-- Business: cleansed and standardised reviews.
-- Incremental: only rows with submitted_at beyond the last run's high-water mark are
-- read; they MERGE on review_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'reviews') }}
    {% if is_incremental() %} where submitted_at > (select coalesce(max(submitted_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        rating,
        review_id,
        reservation_id,
        hotel_id,
        guest_id,
        cleanliness,
        service_score,
        value_score,
        title,
        submitted_at,
        source_system,
        ingested_at
from source
