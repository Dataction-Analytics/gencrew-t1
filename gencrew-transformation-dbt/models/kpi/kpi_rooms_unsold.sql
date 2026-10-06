-- Kpi: Rooms Unsold
-- Declared on the mapping sheet.
-- numerator   : SUM(rooms_available - rooms_sold)
-- denominator : (none)
-- grain       : hotel_id, DATE_TRUNC('month', business_date)
-- source      : mapping sheet

select
        f.hotel_id as hotel_id,
        DATE_TRUNC('month', f.business_date) as business_date_month,
        SUM(f.rooms_available - f.rooms_sold) as rooms_unsold
from {{ ref('fact_daily_hotel_performance') }} as f
    group by 1, 2
