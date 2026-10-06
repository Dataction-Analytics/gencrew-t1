-- Kpi: ADR (Average Daily Rate)
-- Declared on the mapping sheet.
-- numerator   : SUM(room_revenue)
-- denominator : SUM(rooms_sold)
-- grain       : hotel_id, DATE_TRUNC('month', business_date)
-- source      : mapping sheet

select
        f.hotel_id as hotel_id,
        DATE_TRUNC('month', f.business_date) as business_date_month,
        SUM(f.room_revenue) / nullif(SUM(f.rooms_sold), 0) as adr__average_daily_rate_
from {{ ref('fact_daily_hotel_performance') }} as f
    where f.rooms_sold > 0
    group by 1, 2
