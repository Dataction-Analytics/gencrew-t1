{{ config(
    materialized='incremental',
    unique_key='guest_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
-- Business: cleansed and standardised guests.
-- Incremental: only rows with created_at beyond the last run's high-water mark are
-- read; they MERGE on guest_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'guests') }}
    {% if is_incremental() %} where created_at > (select coalesce(max(created_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        guest_id,
        guest_ref,
        REGEXP_REPLACE(full_name, '[A-Za-z0-9]', 'x', 3, 0) AS full_name,
        REGEXP_REPLACE(COALESCE(email, ''), '[A-Za-z0-9]', 'x', 3, 0) AS email,
        REGEXP_REPLACE(COALESCE(phone, ''), '[A-Za-z0-9]', 'x', 3, 0) AS phone,
        country,
        DATE_TRUNC('year', date_of_birth) AS date_of_birth,
        created_at,
        source_system,
        ingested_at,
        DATEDIFF('year', date_of_birth, CURRENT_DATE()) AS guest_age_years
from source
