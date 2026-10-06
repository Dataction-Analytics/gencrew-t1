-- Kpi: Occupancy %
-- Declared on the mapping sheet.
-- numerator   : SUM(rooms_sold)
-- denominator : SUM(rooms_available)
-- grain       : hotel_id, DATE_TRUNC('month', business_date)
-- source      : mapping sheet

select
        f.hotel_id as hotel_id,
        DATE_TRUNC('month', f.business_date) as business_date_month,
        round(100.0 * SUM(f.rooms_sold) / nullif(SUM(f.rooms_available), 0), 2) as occupancy_pct
from {{ ref('fact_daily_hotel_performance') }} as f
    where f.rooms_available > 0
    group by 1, 2
