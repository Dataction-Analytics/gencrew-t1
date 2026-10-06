{{ config(
    materialized='incremental',
    unique_key='feed_row_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
-- Business: cleansed and standardised ota_feed_raw.
-- Incremental: only rows with received_at beyond the last run's high-water mark are
-- read; they MERGE on feed_row_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'ota_feed_raw') }}
    {% if is_incremental() %} where received_at > (select coalesce(max(received_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        feed_row_id,
        ota_name,
        external_booking_ref,
        hotel_code,
        guest_name,
        REGEXP_REPLACE(COALESCE(guest_email, ''), '[A-Za-z0-9]', 'x', 3, 0) AS guest_email,
        arrival,
        departure,
        room_type_text,
        gross_amount,
        currency,
        booking_status,
        received_at,
        source_system,
        batch_id
from source
