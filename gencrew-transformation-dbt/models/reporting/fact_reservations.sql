-- Gold fact: fact_reservations. Grain: One row per reservation transaction.
-- Incremental on booked_at using MERGE.
-- Never delete-and-reload: the house rule forbids DELETE and TRUNCATE.
with s as (

    select * from {{ ref('business_reservations') }}

)

select
        {{ dbt_utils.generate_surrogate_key(['s.reservation_id']) }} as fact_reservations_key,
        coalesce(dim_hotels.dim_hotels_key, '-1') as dim_hotels_key,
        coalesce(dim_guests.dim_guests_key, '-1') as dim_guests_key,
        coalesce(dim_channels.dim_channels_key, '-1') as dim_channels_key,
        coalesce(dim_rate_plans.dim_rate_plans_key, '-1') as dim_rate_plans_key,
        s.total_amount,
        s.nights,
        s.adults,
        s.children,
        s.rooms_booked,
        s.booked_at,
        s.check_in_date,
        s.check_out_date,
        s.confirmation_no,
        s.status,
        s.currency,
        s.is_repeat_guest,
        s.source_system,
        s.ingested_at,
        s.batch_id,
        s.is_cancelled,
        s.is_realised,
        s.room_nights_booked,
        s.reservation_id,
        s.hotel_id,
        s.channel_id,
        s.segment_id
from s
    left join {{ ref('dim_hotels') }} as dim_hotels
        on s.hotel_id = dim_hotels.dim_hotels_nk
        and s.booked_at >= dim_hotels.valid_from and s.booked_at < dim_hotels.valid_to
    left join {{ ref('dim_guests') }} as dim_guests
        on s.guest_id = dim_guests.dim_guests_nk
        and s.booked_at >= dim_guests.valid_from and s.booked_at < dim_guests.valid_to
    left join {{ ref('dim_channels') }} as dim_channels
        on s.channel_id = dim_channels.dim_channels_nk
        and s.booked_at >= dim_channels.valid_from and s.booked_at < dim_channels.valid_to
    left join {{ ref('dim_rate_plans') }} as dim_rate_plans
        on s.rate_plan_id = dim_rate_plans.dim_rate_plans_nk
        and s.booked_at >= dim_rate_plans.valid_from and s.booked_at < dim_rate_plans.valid_to
    {% if is_incremental() %}
    where s.booked_at > (select coalesce(max(booked_at), '1900-01-01') from {{ this }})
    {% endif %}
