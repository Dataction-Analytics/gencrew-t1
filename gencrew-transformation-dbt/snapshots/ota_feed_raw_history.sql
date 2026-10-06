{% snapshot ota_feed_raw_history %}
{{
    config(
      target_schema='history',
      unique_key='feed_row_id',
      strategy='check',
      check_cols='all',
      invalidate_hard_deletes=False
    )
}}

-- SCD2 history for ota_feed_raw. dbt maintains dbt_valid_from / dbt_valid_to; the
-- current version is the row where dbt_valid_to is null. Closed versions are
-- kept — a change opens a new row and closes the old one, nothing is deleted.
select * from {{ ref('business_ota_feed_raw') }}

{% endsnapshot %}
