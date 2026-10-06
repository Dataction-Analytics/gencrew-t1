-- Reporting dimension (SCD Type 2): dim_rate_plans.
-- The latest version of each member is is_current = true with valid_to =
-- 9999-12-31; every earlier version is closed (is_current = false, valid_to =
-- the moment the next version began). History is never deleted.
with h as (

    select * from {{ ref('rate_plans_history') }}
    {% if is_incremental() %}
    where dbt_valid_from > (select coalesce(max(valid_from), '1900-01-01'::timestamp) from {{ this }} where dim_rate_plans_nk is not null)
       or dbt_valid_to   > (select coalesce(max(valid_from), '1900-01-01'::timestamp) from {{ this }} where dim_rate_plans_nk is not null)
    {% endif %}

), versioned as (

    select
        {{ dbt_utils.generate_surrogate_key(['rate_plan_id', 'dbt_valid_from']) }} as dim_rate_plans_key,
        rate_plan_id as dim_rate_plans_nk,
        rate_plan_id,
        rate_plan_code,
        rate_plan_name,
        board_type,
        is_refundable,
        source_system,
        ingested_at,
        dbt_valid_from::timestamp as valid_from,
        coalesce(dbt_valid_to, '9999-12-31'::timestamp)::timestamp as valid_to,
        (dbt_valid_to is null) as is_current
    from h
    where rate_plan_id is not null

)

select * from versioned

{% if not is_incremental() %}
union all

-- The Unknown member: one version, always current, so a fact row with no
-- matching dimension member still reconciles.
select
        '-1' as dim_rate_plans_key,
        null as dim_rate_plans_nk,
        null as rate_plan_id,
        null as rate_plan_code,
        null as rate_plan_name,
        null as board_type,
        null as is_refundable,
        null as source_system,
        null as ingested_at,
        '1900-01-01'::timestamp as valid_from,
        '9999-12-31'::timestamp as valid_to,
        true as is_current
{% endif %}
