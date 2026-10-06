-- Kpi: Repeat Guest %
-- Declared on the mapping sheet.
-- numerator   : COUNT(DISTINCT CASE WHEN is_repeat_guest = 1 THEN reservation_id END)
-- denominator : COUNT(DISTINCT reservation_id)
-- grain       : hotel_id, DATE_TRUNC('month', booked_at)
-- source      : mapping sheet

select
        f.hotel_id as hotel_id,
        DATE_TRUNC('month', f.booked_at) as booked_at_month,
        round(100.0 * COUNT(DISTINCT CASE WHEN f.is_repeat_guest = 1 THEN f.reservation_id END) / nullif(COUNT(DISTINCT f.reservation_id), 0), 2) as repeat_guest_pct
from {{ ref('fact_reservations') }} as f
    group by 1, 2
