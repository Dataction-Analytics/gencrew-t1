{% snapshot market_segments_history %}
{{
    config(
      target_schema='history',
      unique_key='segment_id',
      strategy='check',
      check_cols='all',
      invalidate_hard_deletes=False
    )
}}

-- SCD2 history for market_segments. dbt maintains dbt_valid_from / dbt_valid_to; the
-- current version is the row where dbt_valid_to is null. Closed versions are
-- kept — a change opens a new row and closes the old one, nothing is deleted.
select * from {{ ref('business_market_segments') }}

{% endsnapshot %}
