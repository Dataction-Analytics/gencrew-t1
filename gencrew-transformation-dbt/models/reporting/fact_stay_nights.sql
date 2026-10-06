-- Gold fact: fact_stay_nights. Grain: One row per room per night of stay.
-- Incremental on stay_date using MERGE.
-- Never delete-and-reload: the house rule forbids DELETE and TRUNCATE.
with s as (

    select * from {{ ref('business_stay_nights') }}

)

select
        {{ dbt_utils.generate_surrogate_key(['s.stay_night_id']) }} as fact_stay_nights_key,
        coalesce(dim_hotels.dim_hotels_key, '-1') as dim_hotels_key,
        coalesce(dim_rooms.dim_rooms_key, '-1') as dim_rooms_key,
        coalesce(dim_room_types.dim_room_types_key, '-1') as dim_room_types_key,
        s.room_revenue,
        s.stay_date,
        s.is_occupied,
        s.source_system,
        s.ingested_at,
        s.reservation_id,
        s.hotel_id
from s
    left join {{ ref('dim_hotels') }} as dim_hotels
        on s.hotel_id = dim_hotels.dim_hotels_nk
        and s.stay_date >= dim_hotels.valid_from and s.stay_date < dim_hotels.valid_to
    left join {{ ref('dim_rooms') }} as dim_rooms
        on s.room_id = dim_rooms.dim_rooms_nk
        and s.stay_date >= dim_rooms.valid_from and s.stay_date < dim_rooms.valid_to
    left join {{ ref('dim_room_types') }} as dim_room_types
        on s.room_type_id = dim_room_types.dim_room_types_nk
        and s.stay_date >= dim_room_types.valid_from and s.stay_date < dim_room_types.valid_to
    {% if is_incremental() %}
    where s.stay_date > (select coalesce(max(stay_date), '1900-01-01') from {{ this }})
    {% endif %}
