{% snapshot stay_nights_history %}
{{
    config(
      target_schema='history',
      unique_key='stay_night_id',
      strategy='check',
      check_cols='all',
      invalidate_hard_deletes=False
    )
}}

-- SCD2 history for stay_nights. dbt maintains dbt_valid_from / dbt_valid_to; the
-- current version is the row where dbt_valid_to is null. Closed versions are
-- kept — a change opens a new row and closes the old one, nothing is deleted.
select * from {{ ref('business_stay_nights') }}

{% endsnapshot %}
