-- Kpi: Total Revenue
-- Declared on the mapping sheet.
-- numerator   : SUM(charge_amount)
-- denominator : (none)
-- grain       : hotel_id, charge_type, DATE_TRUNC('month', charge_date)
-- source      : mapping sheet

select
        f.hotel_id as hotel_id,
        f.charge_type as charge_type,
        DATE_TRUNC('month', f.charge_date) as charge_date_month,
        SUM(f.charge_amount) as total_revenue
from {{ ref('fact_folio_charges') }} as f
    group by 1, 2, 3
