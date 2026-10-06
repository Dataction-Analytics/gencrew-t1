{{ config(
    materialized='incremental',
    unique_key='channel_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
-- Business: cleansed and standardised channels.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on channel_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'channels') }}
    {% if is_incremental() %} where ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        channel_name,
        channel_id,
        channel_code,
        channel_group,
        commission_pct,
        source_system,
        ingested_at
from source
