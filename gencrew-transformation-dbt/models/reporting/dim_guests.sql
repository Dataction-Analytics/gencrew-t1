-- Reporting dimension (SCD Type 2): dim_guests.
-- The latest version of each member is is_current = true with valid_to =
-- 9999-12-31; every earlier version is closed (is_current = false, valid_to =
-- the moment the next version began). History is never deleted.
with h as (

    select * from {{ ref('guests_history') }}
    {% if is_incremental() %}
    where dbt_valid_from > (select coalesce(max(valid_from), '1900-01-01'::timestamp) from {{ this }} where dim_guests_nk is not null)
       or dbt_valid_to   > (select coalesce(max(valid_from), '1900-01-01'::timestamp) from {{ this }} where dim_guests_nk is not null)
    {% endif %}

), versioned as (

    select
        {{ dbt_utils.generate_surrogate_key(['guest_id', 'dbt_valid_from']) }} as dim_guests_key,
        guest_id as dim_guests_nk,
        guest_id,
        guest_ref,
        full_name,
        email,
        phone,
        country,
        date_of_birth,
        created_at,
        source_system,
        ingested_at,
        guest_age_years,
        dbt_valid_from::timestamp as valid_from,
        coalesce(dbt_valid_to, '9999-12-31'::timestamp)::timestamp as valid_to,
        (dbt_valid_to is null) as is_current
    from h
    where guest_id is not null

)

select * from versioned

{% if not is_incremental() %}
union all

-- The Unknown member: one version, always current, so a fact row with no
-- matching dimension member still reconciles.
select
        '-1' as dim_guests_key,
        null as dim_guests_nk,
        null as guest_id,
        null as guest_ref,
        null as full_name,
        null as email,
        null as phone,
        null as country,
        null as date_of_birth,
        null as created_at,
        null as source_system,
        null as ingested_at,
        null as guest_age_years,
        '1900-01-01'::timestamp as valid_from,
        '9999-12-31'::timestamp as valid_to,
        true as is_current
{% endif %}
