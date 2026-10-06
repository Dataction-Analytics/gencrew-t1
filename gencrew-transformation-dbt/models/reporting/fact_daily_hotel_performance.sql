-- Gold fact: fact_daily_hotel_performance. Grain: One row per hotel per business day.
-- Incremental on business_date using MERGE.
-- Never delete-and-reload: the house rule forbids DELETE and TRUNCATE.
with s as (

    select * from {{ ref('business_daily_hotel_performance') }}

)

select
        {{ dbt_utils.generate_surrogate_key(['s.performance_id']) }} as fact_daily_hotel_performance_key,
        coalesce(dim_hotels.dim_hotels_key, '-1') as dim_hotels_key,
        s.rooms_available,
        s.rooms_sold,
        s.rooms_out_of_order,
        s.room_revenue,
        s.other_revenue,
        s.business_date,
        s.arrivals,
        s.departures,
        s.source_system,
        s.ingested_at,
        s.batch_id,
        s.rooms_unsold,
        s.hotel_id
from s
    left join {{ ref('dim_hotels') }} as dim_hotels
        on s.hotel_id = dim_hotels.dim_hotels_nk
        and s.business_date >= dim_hotels.valid_from and s.business_date < dim_hotels.valid_to
    {% if is_incremental() %}
    where s.business_date > (select coalesce(max(business_date), '1900-01-01') from {{ this }})
    {% endif %}
