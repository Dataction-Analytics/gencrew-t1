-- Kpi: No Show %
-- Declared on the mapping sheet.
-- numerator   : COUNT(DISTINCT CASE WHEN UPPER(REGEXP_REPLACE(status, '[^A-Z0-9]', '')) IN ('NS','NOSHOW') THEN reservation_id END)
-- denominator : COUNT(DISTINCT reservation_id)
-- grain       : hotel_id, DATE_TRUNC('month', booked_at)
-- source      : mapping sheet

select
        f.hotel_id as hotel_id,
        DATE_TRUNC('month', f.booked_at) as booked_at_month,
        round(100.0 * COUNT(DISTINCT CASE WHEN UPPER(REGEXP_REPLACE(f.status, '[^A-Z0-9]', '')) IN ('NS','NOSHOW') THEN f.reservation_id END) / nullif(COUNT(DISTINCT f.reservation_id), 0), 2) as no_show_pct
from {{ ref('fact_reservations') }} as f
    group by 1, 2
