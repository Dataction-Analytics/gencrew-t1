{{ config(
    materialized='incremental',
    unique_key='segment_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
-- Business: cleansed and standardised market_segments.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on segment_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'market_segments') }}
    {% if is_incremental() %} where ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        segment_id,
        segment_code,
        segment_name,
        source_system,
        ingested_at
from source
