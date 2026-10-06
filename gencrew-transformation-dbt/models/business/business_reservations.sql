{{ config(
    materialized='incremental',
    unique_key='reservation_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'
) }}
-- Business: cleansed and standardised reservations.
-- Incremental: only rows with booked_at beyond the last run's high-water mark are
-- read; they MERGE on reservation_id. Nothing is deleted or truncated.
with source as (

    select * from {{ source('raw', 'reservations') }}
    where not (NOT (status != 'CANCELLED'))
      and not (NOT (status IN ('CONFIRMED', 'CHECKED_OUT')))
      {% if is_incremental() %} and booked_at > (select coalesce(max(booked_at), '1900-01-01'::timestamp) from {{ this }}) {% endif %}

)

select
        reservation_id,
        confirmation_no,
        hotel_id,
        guest_id,
        booked_at,
        check_in_date,
        check_out_date,
        nights,
        status,
        total_amount,
        channel_id,
        segment_id,
        rate_plan_id,
        adults,
        children,
        rooms_booked,
        currency,
        is_repeat_guest,
        source_system,
        ingested_at,
        batch_id,
        CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END AS is_cancelled,
        CASE WHEN status IN ('CHECKED_IN', 'CHECKED_OUT') THEN 1 ELSE 0 END AS is_realised,
        rooms_booked * nights AS room_nights_booked
from source
