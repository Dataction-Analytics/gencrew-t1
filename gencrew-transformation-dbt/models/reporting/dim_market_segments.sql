-- Reporting dimension (SCD Type 2): dim_market_segments.
-- The latest version of each member is is_current = true with valid_to =
-- 9999-12-31; every earlier version is closed (is_current = false, valid_to =
-- the moment the next version began). History is never deleted.
with h as (

    select * from {{ ref('market_segments_history') }}
    {% if is_incremental() %}
    where dbt_valid_from > (select coalesce(max(valid_from), '1900-01-01'::timestamp) from {{ this }} where dim_market_segments_nk is not null)
       or dbt_valid_to   > (select coalesce(max(valid_from), '1900-01-01'::timestamp) from {{ this }} where dim_market_segments_nk is not null)
    {% endif %}

), versioned as (

    select
        {{ dbt_utils.generate_surrogate_key(['segment_id', 'dbt_valid_from']) }} as dim_market_segments_key,
        segment_id as dim_market_segments_nk,
        segment_id,
        segment_code,
        segment_name,
        source_system,
        ingested_at,
        dbt_valid_from::timestamp as valid_from,
        coalesce(dbt_valid_to, '9999-12-31'::timestamp)::timestamp as valid_to,
        (dbt_valid_to is null) as is_current
    from h
    where segment_id is not null

)

select * from versioned

{% if not is_incremental() %}
union all

-- The Unknown member: one version, always current, so a fact row with no
-- matching dimension member still reconciles.
select
        '-1' as dim_market_segments_key,
        null as dim_market_segments_nk,
        null as segment_id,
        null as segment_code,
        null as segment_name,
        null as source_system,
        null as ingested_at,
        '1900-01-01'::timestamp as valid_from,
        '9999-12-31'::timestamp as valid_to,
        true as is_current
{% endif %}
