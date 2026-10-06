-- Kpi: Total Bookings
-- Declared on the mapping sheet.
-- numerator   : COUNT(DISTINCT reservation_id)
-- denominator : (none)
-- grain       : hotel_id, channel_id, segment_id, DATE_TRUNC('month', booked_at)
-- source      : mapping sheet

select
        f.hotel_id as hotel_id,
        f.channel_id as channel_id,
        f.segment_id as segment_id,
        DATE_TRUNC('month', f.booked_at) as booked_at_month,
        COUNT(DISTINCT f.reservation_id) as total_bookings
from {{ ref('fact_reservations') }} as f
    where f.status != 'CANCELLED'
    group by 1, 2, 3, 4
