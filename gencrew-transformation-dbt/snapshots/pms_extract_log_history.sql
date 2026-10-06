{% snapshot pms_extract_log_history %}
{{
    config(
      target_schema='history',
      unique_key='extract_id',
      strategy='check',
      check_cols='all',
      invalidate_hard_deletes=False
    )
}}

-- SCD2 history for pms_extract_log. dbt maintains dbt_valid_from / dbt_valid_to; the
-- current version is the row where dbt_valid_to is null. Closed versions are
-- kept — a change opens a new row and closes the old one, nothing is deleted.
select * from {{ ref('business_pms_extract_log') }}

{% endsnapshot %}
