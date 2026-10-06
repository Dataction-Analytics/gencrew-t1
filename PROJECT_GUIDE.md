# Project guide — t1

Everything about this delivery in one place. Generated from the measured source
model, the mapping sheet, and the delivery's own certificates.

## 1. What this is

A layered data transformation built **inside the warehouse**. Nothing is moved
between systems and no infrastructure is provisioned: every layer is SQL run by
the warehouse engine. The pipeline is physically unable to DELETE, TRUNCATE or
DROP — every statement passes the platform guard before execution.

## 2. The layers and where they live

| Layer | Home (database.schema) |
|---|---|
| `raw` | `HOTEL.BRONZE_HOTEL` |
| `business` | `HOTEL.SILVER_HOTEL` |
| `reporting` | `HOTEL.GOLD_HOTEL` |
| `kpi` | `HOTEL.GOLD_HOTEL` |

- **Cleansed** — 21 models: dedupe, null handling, formats, value maps.
- **Business** — 0 models: renames, derived columns and the sheet's business rules.
- **History** — SCD Type 2 snapshots: a change closes the old version and opens a new one; nothing is removed.
- **Reporting** — star schema: 8 dimensions + 6 facts, surrogate keys, Unknown members, point-in-time joins.
- **KPI** — 12 models, one per declared KPI at its own grain.

## 3. How to run it

**`gencrew-t1-dbt/`** — the dbt project, the stack chosen for
this delivery.

```bash
cd gencrew-t1-dbt
cp .env.example .env        # fill in the warehouse credentials
dbt deps && dbt build       # models + tests, in dependency order
dbt snapshot                # SCD Type 2 history
```

## 4. How loads behave

The first run is a full build. Every later run is **incremental**: models read
only source rows past the last high-water mark (21 of 21 tables
have a measured watermark column; the rest are re-read in full and still MERGE
by natural key — correct, just not cheap). Dimensions keep full history
(SCD Type 2): `is_current` marks the active version, closed versions keep their
`valid_from`/`valid_to`. Facts join the dimension version that was valid at the
event's own timestamp.

Details per table: `gencrew-t1-dbt/INCREMENTAL.md`.

## 5. The KPIs

- **kpi_total_bookings** — emitted as a model
- **kpi_total_revenue** — emitted as a model
- **kpi_occupancy_pct** — emitted as a model
- **kpi_adr__average_daily_rate_** — emitted as a model
- **kpi_revpar__revenue_per_available_room_** — emitted as a model
- **kpi_cancellation_pct** — emitted as a model
- **kpi_average_stay** — emitted as a model
- **kpi_repeat_guest_pct** — emitted as a model
- **kpi_no_show_pct** — emitted as a model
- **kpi_revenue_by_channel** — emitted as a model
- **kpi_rooms_unsold** — emitted as a model
- **kpi_average_review_score** — emitted as a model

Formulas and grains: `gencrew-t1-dbt/KPI_CATALOG.md`.

## 6. Business rules

13 of 13 mapping-sheet rules were
applied automatically; the remainder are listed with reasons in
`gencrew-t1-dbt/BUSINESS_RULES.md` for a human to resolve.

## 7. Tests

A delivery-derived pytest suite runs during Development: every model reference
must resolve, no destructive statement may appear, the SCD2 shape and the KPI
models are checked, and the SQL folder must mirror the dbt project. Results are
in CERTIFICATES.json; a red suite holds the delivery in Development.

## 8. Security & audit

See `gencrew-service/`SECURITY_AND_OBSERVABILITY.md — written from what this
delivery actually does, and CERTIFICATES.json — the per-step audit trail with
measured counts for every gate.

## 9. Troubleshooting

- **A model fails on types** — check BUSINESS_RULES.md for the cast rules; the
  source column's measured type travels into the cast.
- **A KPI reads zero rows** — confirm the watermark table has advanced;
  incremental models only see rows past the high-water mark.
- **Credentials** — the dbt profile reads env vars only (`.env.example` lists
  them); no secret is ever written into the project.
