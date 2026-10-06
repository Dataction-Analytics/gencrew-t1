# Incremental loading and history

Mode: **incremental + SCD Type 2**.

The first `dbt build` is a full load. Every later run:

1. `business` / `business` models read only source rows whose watermark
   column is beyond the last run's high-water mark (`max(col)` in the target),
   and MERGE them by natural key. Tables with no timestamp are re-read in full
   and still MERGE — never truncated.
2. `dbt snapshot` writes one history row per changed version of every
   `business` table (`snapshots/*_history.sql`) — a change opens a new
   version and closes the previous one (`dbt_valid_to`). Nothing is deleted.
3. `reporting` dimensions are **Type 2**: one row per version, `is_current`
   marks the active one, earlier versions are closed with `valid_to`. Facts
   MERGE incrementally and join the dimension version that was valid at the
   event's timestamp (point-in-time), or the current version when the fact has
   no timestamp.

| Table | Watermark column | Watermark kind | Natural key | History |
|---|---|---|---|---|
| `batch_load_audit` | load_started_at | **event time** — edits to past rows are not picked up; add an updated_at column to the source to capture them | `audit_id` | yes |
| `cancellations` | cancelled_at | **event time** — edits to past rows are not picked up; add an updated_at column to the source to capture them | `cancellation_id` | yes |
| `channels` | ingested_at | **event time** — edits to past rows are not picked up; add an updated_at column to the source to capture them | `channel_id` | yes |
| `daily_hotel_performance` | ingested_at | **event time** — edits to past rows are not picked up; add an updated_at column to the source to capture them | `performance_id` | yes |
| `folio_charges` | ingested_at | **event time** — edits to past rows are not picked up; add an updated_at column to the source to capture them | `charge_id` | yes |
| `guests` | created_at | **event time** — edits to past rows are not picked up; add an updated_at column to the source to capture them | `guest_id` | yes |
| `hotels` | ingested_at | **event time** — edits to past rows are not picked up; add an updated_at column to the source to capture them | `hotel_id` | yes |
| `housekeeping_tasks` | ingested_at | **event time** — edits to past rows are not picked up; add an updated_at column to the source to capture them | `task_id` | yes |
| `loyalty_members` | ingested_at | **event time** — edits to past rows are not picked up; add an updated_at column to the source to capture them | `loyalty_id` | yes |
| `market_segments` | ingested_at | **event time** — edits to past rows are not picked up; add an updated_at column to the source to capture them | `segment_id` | yes |
| `ota_feed_raw` | received_at | **event time** — edits to past rows are not picked up; add an updated_at column to the source to capture them | `feed_row_id` | yes |
| `payments` | paid_at | **event time** — edits to past rows are not picked up; add an updated_at column to the source to capture them | `payment_id` | yes |
| `pms_extract_log` | extracted_at | **event time** — edits to past rows are not picked up; add an updated_at column to the source to capture them | `extract_id` | yes |
| `rate_plans` | ingested_at | **event time** — edits to past rows are not picked up; add an updated_at column to the source to capture them | `rate_plan_id` | yes |
| `reservation_rooms` | ingested_at | **event time** — edits to past rows are not picked up; add an updated_at column to the source to capture them | `reservation_room_id` | yes |
| `reservations` | booked_at | **event time** — edits to past rows are not picked up; add an updated_at column to the source to capture them | `reservation_id` | yes |
| `reviews` | submitted_at | **event time** — edits to past rows are not picked up; add an updated_at column to the source to capture them | `review_id` | yes |
| `room_inventory_daily` | ingested_at | **event time** — edits to past rows are not picked up; add an updated_at column to the source to capture them | `inventory_id` | yes |
| `room_types` | ingested_at | **event time** — edits to past rows are not picked up; add an updated_at column to the source to capture them | `room_type_id` | yes |
| `rooms` | ingested_at | **event time** — edits to past rows are not picked up; add an updated_at column to the source to capture them | `room_id` | yes |
| `stay_nights` | ingested_at | **event time** — edits to past rows are not picked up; add an updated_at column to the source to capture them | `stay_night_id` | yes |

A table with no timestamp is re-read in full each run and still MERGEs by key
(correct, just not cheap). History snapshots on such tables use dbt's `check`
strategy (all columns compared), so changes are still versioned.

Run order: `dbt run --select business` → `dbt run --select business` →
`dbt snapshot` → `dbt run --select reporting kpi` → `dbt test`.
`dbt build` does the same in dependency order.
