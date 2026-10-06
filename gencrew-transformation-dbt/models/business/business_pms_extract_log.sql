{{ config(
    materialized='incremental',
    unique_key='extract_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
-- Business: cleansed and standardised pms_extract_log.
-- Incremental: only rows with extracted_at beyond the last run's high-water mark are
-- read; they MERGE on extract_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'pms_extract_log') }}
    {% if is_incremental() %} where extracted_at > (select coalesce(max(extracted_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        extract_id,
        hotel_id,
        extract_type,
        extracted_at,
        rows_extracted,
        status,
        source_system
from source
