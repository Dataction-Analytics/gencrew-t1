# KPI catalogue

Every KPI below was DECLARED on the mapping sheet — none is inferred. A KPI is
only emitted as a model when every column its formula names exists on the
reporting fact or a dimension it joins; otherwise it is listed here for a human.

| KPI | Formula | Grain | Status | Model / reason |
|---|---|---|---|---|
| Total Bookings | `COUNT(DISTINCT reservation_id)` | hotel_id, channel_id, segment_id, DATE_TRUNC('month', booked_at) | emitted | kpi_total_bookings |
| Total Revenue | `SUM(charge_amount)` | hotel_id, charge_type, DATE_TRUNC('month', charge_date) | emitted | kpi_total_revenue |
| Occupancy % | `SUM(rooms_sold) ÷ SUM(rooms_available)` | hotel_id, DATE_TRUNC('month', business_date) | emitted | kpi_occupancy_pct |
| ADR (Average Daily Rate) | `SUM(room_revenue) ÷ SUM(rooms_sold)` | hotel_id, DATE_TRUNC('month', business_date) | emitted | kpi_adr__average_daily_rate_ |
| RevPAR (Revenue Per Available Room) | `SUM(room_revenue) ÷ SUM(rooms_available)` | hotel_id, DATE_TRUNC('month', business_date) | emitted | kpi_revpar__revenue_per_available_room_ |
| Cancellation % | `COUNT(DISTINCT CASE WHEN status = 'CANCELLED' THEN reservation_id END) ÷ COUNT(DISTINCT reservation_id)` | hotel_id, DATE_TRUNC('month', booked_at) | emitted | kpi_cancellation_pct |
| Average Stay | `AVG(nights)` | hotel_id, DATE_TRUNC('month', booked_at) | emitted | kpi_average_stay |
| Repeat Guest % | `COUNT(DISTINCT CASE WHEN is_repeat_guest = 1 THEN reservation_id END) ÷ COUNT(DISTINCT reservation_id)` | hotel_id, DATE_TRUNC('month', booked_at) | emitted | kpi_repeat_guest_pct |
| No Show % | `COUNT(DISTINCT CASE WHEN UPPER(REGEXP_REPLACE(status, '[^A-Z0-9]', '')) IN ('NS','NOSHOW') THEN reservation_id END) ÷ COUNT(DISTINCT reservation_id)` | hotel_id, DATE_TRUNC('month', booked_at) | emitted | kpi_no_show_pct |
| Revenue by Channel | `SUM(total_amount)` | channel_id, DATE_TRUNC('month', booked_at) | emitted | kpi_revenue_by_channel |
| Rooms Unsold | `SUM(rooms_available - rooms_sold)` | hotel_id, DATE_TRUNC('month', business_date) | emitted | kpi_rooms_unsold |
| Average Review Score | `AVG(rating)` | hotel_id, DATE_TRUNC('month', submitted_at) | emitted | kpi_average_review_score |
