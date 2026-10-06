# Business rules applied in the `business` layers

Each rule below came from the mapping sheet or was approved on the requirement,
and is applied by the `models/business/` models. A rule that could not be expressed as SQL is
marked so, and must be handled by a human before sign-off.

| Table | Column | Rule | Layer | Expressed as SQL | Source |
|---|---|---|---|---|---|
| guests | email | Handle 8.1% null values in guests.email field. May require default value, exclusion from certain analyses, or retention as null | cleansed | yes | ['ontology-upload:fc63b28958a292918871'] |
| guests | phone | Handle 9.9% null values in guests.phone field. May require default value, exclusion from certain analyses, or retention as null | cleansed | yes | ['ontology-upload:fc63b28958a292918871'] |
| ota_feed_raw | guest_email | Handle 12% null values in ota_feed_raw.guest_email field | cleansed | yes | ['ontology-upload:fc63b28958a292918871'] |
| reservations |  | Boolean flag indicating reservation was cancelled. Derived from standardized status = 'CANCELLED' | business | yes | ['ontology-upload:fc63b28958a292918871'] |
| reservations |  | Boolean flag indicating reservation resulted in actual stay. Derived from status IN ('CHECKED_IN', 'CHECKED_OUT') | business | yes | ['ontology-upload:fc63b28958a292918871'] |
| reservations |  | Total room-nights in reservation calculated as rooms_booked * nights. Used for capacity and revenue analysis | business | yes | ['ontology-upload:fc63b28958a292918871'] |
| daily_hotel_performance |  | Count of available rooms not sold, calculated as rooms_available - rooms_sold from daily performance | business | yes | ['ontology-upload:fc63b28958a292918871'] |
| guests |  | Calculate guest age from date_of_birth. Used for demographic analysis and segmentation | business | yes | ['ontology-upload:fc63b28958a292918871'] |
| reservations |  | Filter rule for Total Bookings KPI to exclude cancelled reservations. Keeps only non-cancelled bookings | kpi | yes | ['ontology-upload:fc63b28958a292918871'] |
| reservations |  | Filter rule for Revenue by Channel KPI to include only confirmed and checked-out bookings per requirement | kpi | yes | ['ontology-upload:fc63b28958a292918871'] |
| daily_hotel_performance |  | Validation rule ensuring rooms_available > 0 before calculating Occupancy % to prevent division by zero | kpi | yes | ['ontology-upload:fc63b28958a292918871'] |
| daily_hotel_performance |  | Validation rule ensuring rooms_sold > 0 before calculating ADR to prevent division by zero | kpi | yes | ['ontology-upload:fc63b28958a292918871'] |
| daily_hotel_performance |  | Validation rule ensuring rooms_available > 0 before calculating RevPAR to prevent division by zero | kpi | yes | ['ontology-upload:fc63b28958a292918871'] |
