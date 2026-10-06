{{ config(
    materialized='incremental',
    unique_key='charge_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
-- Business: cleansed and standardised folio_charges.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on charge_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'folio_charges') }}
    {% if is_incremental() %} where ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        charge_type,
        charge_id,
        reservation_id,
        hotel_id,
        charge_date,
        description,
        currency,
        source_system,
        ingested_at,
        charge_amount
from source
