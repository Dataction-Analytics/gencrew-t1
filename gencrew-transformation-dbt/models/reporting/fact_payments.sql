-- Gold fact: fact_payments. Grain: One row per payment transaction.
-- Incremental on paid_at using MERGE.
-- Never delete-and-reload: the house rule forbids DELETE and TRUNCATE.
with s as (

    select * from {{ ref('business_payments') }}

)

select
        {{ dbt_utils.generate_surrogate_key(['s.payment_id']) }} as fact_payments_key,
        s.payment_amount,
        s.paid_at,
        s.method,
        s.card_last4,
        s.status,
        s.source_system,
        s.ingested_at,
        s.reservation_id
from s

    {% if is_incremental() %}
    where s.paid_at > (select coalesce(max(paid_at), '1900-01-01') from {{ this }})
    {% endif %}
