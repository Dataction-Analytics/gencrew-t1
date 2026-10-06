-- Kpi: Average Stay
-- Declared on the mapping sheet.
-- numerator   : AVG(nights)
-- denominator : (none)
-- grain       : hotel_id, DATE_TRUNC('month', booked_at)
-- source      : mapping sheet

select
        f.hotel_id as hotel_id,
        DATE_TRUNC('month', f.booked_at) as booked_at_month,
        AVG(f.nights) as average_stay
from {{ ref('fact_reservations') }} as f
    where f.status != 'CANCELLED'
    group by 1, 2
