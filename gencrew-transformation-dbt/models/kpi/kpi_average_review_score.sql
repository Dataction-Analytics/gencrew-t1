-- Kpi: Average Review Score
-- Declared on the mapping sheet.
-- numerator   : AVG(rating)
-- denominator : (none)
-- grain       : hotel_id, DATE_TRUNC('month', submitted_at)
-- source      : mapping sheet

select
        f.hotel_id as hotel_id,
        DATE_TRUNC('month', f.submitted_at) as submitted_at_month,
        AVG(f.rating) as average_review_score
from {{ ref('fact_reviews') }} as f
    group by 1, 2
