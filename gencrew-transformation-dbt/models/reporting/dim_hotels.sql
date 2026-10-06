-- Reporting dimension (SCD Type 2): dim_hotels.
-- The latest version of each member is is_current = true with valid_to =
-- 9999-12-31; every earlier version is closed (is_current = false, valid_to =
-- the moment the next version began). History is never deleted.
with h as (

    select * from {{ ref('hotels_history') }}
    {% if is_incremental() %}
    where dbt_valid_from > (select coalesce(max(valid_from), '1900-01-01'::timestamp) from {{ this }} where dim_hotels_nk is not null)
       or dbt_valid_to   > (select coalesce(max(valid_from), '1900-01-01'::timestamp) from {{ this }} where dim_hotels_nk is not null)
    {% endif %}

), versioned as (

    select
        {{ dbt_utils.generate_surrogate_key(['hotel_id', 'dbt_valid_from']) }} as dim_hotels_key,
        hotel_id as dim_hotels_nk,
        hotel_id,
        hotel_code,
        hotel_name,
        brand,
        city,
        country,
        star_rating,
        total_rooms,
        opened_on,
        timezone,
        source_system,
        ingested_at,
        batch_id,
        dbt_valid_from::timestamp as valid_from,
        coalesce(dbt_valid_to, '9999-12-31'::timestamp)::timestamp as valid_to,
        (dbt_valid_to is null) as is_current
    from h
    where hotel_id is not null

)

select * from versioned

{% if not is_incremental() %}
union all

-- The Unknown member: one version, always current, so a fact row with no
-- matching dimension member still reconciles.
select
        '-1' as dim_hotels_key,
        null as dim_hotels_nk,
        null as hotel_id,
        null as hotel_code,
        null as hotel_name,
        null as brand,
        null as city,
        null as country,
        null as star_rating,
        null as total_rooms,
        null as opened_on,
        null as timezone,
        null as source_system,
        null as ingested_at,
        null as batch_id,
        '1900-01-01'::timestamp as valid_from,
        '9999-12-31'::timestamp as valid_to,
        true as is_current
{% endif %}
