-- Reporting dimension (SCD Type 2): dim_loyalty_members.
-- The latest version of each member is is_current = true with valid_to =
-- 9999-12-31; every earlier version is closed (is_current = false, valid_to =
-- the moment the next version began). History is never deleted.
with h as (

    select * from {{ ref('loyalty_members_history') }}
    {% if is_incremental() %}
    where dbt_valid_from > (select coalesce(max(valid_from), '1900-01-01'::timestamp) from {{ this }} where dim_loyalty_members_nk is not null)
       or dbt_valid_to   > (select coalesce(max(valid_from), '1900-01-01'::timestamp) from {{ this }} where dim_loyalty_members_nk is not null)
    {% endif %}

), versioned as (

    select
        {{ dbt_utils.generate_surrogate_key(['loyalty_id', 'dbt_valid_from']) }} as dim_loyalty_members_key,
        loyalty_id as dim_loyalty_members_nk,
        loyalty_id,
        membership_no,
        tier,
        points_balance,
        enrolled_on,
        source_system,
        ingested_at,
        dbt_valid_from::timestamp as valid_from,
        coalesce(dbt_valid_to, '9999-12-31'::timestamp)::timestamp as valid_to,
        (dbt_valid_to is null) as is_current
    from h
    where loyalty_id is not null

)

select * from versioned

{% if not is_incremental() %}
union all

-- The Unknown member: one version, always current, so a fact row with no
-- matching dimension member still reconciles.
select
        '-1' as dim_loyalty_members_key,
        null as dim_loyalty_members_nk,
        null as loyalty_id,
        null as membership_no,
        null as tier,
        null as points_balance,
        null as enrolled_on,
        null as source_system,
        null as ingested_at,
        '1900-01-01'::timestamp as valid_from,
        '9999-12-31'::timestamp as valid_to,
        true as is_current
{% endif %}
