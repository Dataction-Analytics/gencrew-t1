{{ config(
    materialized='incremental',
    unique_key='payment_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
-- Business: cleansed and standardised payments.
-- Incremental: only rows with paid_at beyond the last run's high-water mark are
-- read; they MERGE on payment_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'payments') }}
    {% if is_incremental() %} where paid_at > (select coalesce(max(paid_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        card_last4,
        payment_id,
        reservation_id,
        paid_at,
        method,
        status,
        source_system,
        ingested_at,
        payment_amount
from source
