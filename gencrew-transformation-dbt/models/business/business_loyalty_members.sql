{{ config(
    materialized='incremental',
    unique_key='loyalty_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
-- Business: cleansed and standardised loyalty_members.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on loyalty_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'loyalty_members') }}
    {% if is_incremental() %} where ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        tier,
        loyalty_id,
        guest_id,
        membership_no,
        points_balance,
        enrolled_on,
        source_system,
        ingested_at
from source
