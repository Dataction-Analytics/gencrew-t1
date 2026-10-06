{{ config(
    materialized='incremental',
    unique_key='rate_plan_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
-- Business: cleansed and standardised rate_plans.
-- Incremental: only rows with ingested_at beyond the last run's high-water mark are
-- read; they MERGE on rate_plan_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'rate_plans') }}
    {% if is_incremental() %} where ingested_at > (select coalesce(max(ingested_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        rate_plan_id,
        hotel_id,
        rate_plan_code,
        rate_plan_name,
        board_type,
        is_refundable,
        source_system,
        ingested_at
from source
