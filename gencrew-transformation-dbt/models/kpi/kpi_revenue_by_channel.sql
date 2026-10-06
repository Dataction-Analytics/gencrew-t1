-- Kpi: Revenue by Channel
-- Declared on the mapping sheet.
-- numerator   : SUM(total_amount)
-- denominator : (none)
-- grain       : channel_id, DATE_TRUNC('month', booked_at)
-- source      : mapping sheet

select
        f.channel_id as channel_id,
        DATE_TRUNC('month', f.booked_at) as booked_at_month,
        SUM(f.total_amount) as revenue_by_channel
from {{ ref('fact_reservations') }} as f
    where f.status IN ('CONFIRMED', 'CHECKED_OUT')
    group by 1, 2
