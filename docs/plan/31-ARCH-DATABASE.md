# Database Schema Documentation

This document describes database design rules, patterns, and configuration. For the complete SQL DDL schema with all CREATE TABLE statements, RLS policies, indexes, and triggers, see [02-arch-database-schema.sql](02-arch-database-schema.sql).

---

## Data and offline rules

For the complete rule definitions, see [00-RULES.yaml](00-RULES.yaml).

- #BE-17: Every table that stores user data must have an org_id column and an active RLS policy
- #BE-08: Offline-first pattern: soft deletes via deleted_at column (nullable millisecond timestamp); all primary keys are ULIDs
- #BE-09: Every asynchronous operation is idempotent: key = actor_id + monotonic counter
- #BE-18: All tables must have a created_at timestamp column

---

## TimescaleDB Configuration

### Continuous Aggregates Performance

Performance Benchmarks:

- Cloudflare achieved up to 1000x query performance improvement with precomputed aggregates using continuous aggregates
- Cloudflare handles ~100,000 aggregated rows per second ingestion rate with TimescaleDB for Zero Trust Analytics
- Materialization hypertable compression provides 10-20x storage savings on aggregated data
- Proper refresh window tuning reduces refresh duration from minutes to milliseconds

Query Patterns:

```sql
-- 1-hour buckets: sweet spot for most dashboard use cases
CREATE MATERIALIZED VIEW metrics_hourly WITH (timescaledb.continuous) AS
SELECT
  time_bucket('1 hour', event_timestamp_utc) AS bucket_utc,
  device_id,
  AVG(metric_a) AS avg_metric_a,
  MAX(metric_b) AS max_metric_b,
  COUNT(*) AS event_count
FROM raw_device_metrics
GROUP BY bucket_utc, device_id;

-- Properly tuned refresh policy
SELECT add_continuous_aggregate_policy(
  'metrics_hourly',
  start_offset => INTERVAL '3 hours',
  end_offset => INTERVAL '1 hour',
  schedule_interval => INTERVAL '1 hour'
);
```

Key Performance Factors:

- Bucket width: 1-hour buckets optimal for dashboard queries (avoids 60x unnecessary work with 1-minute buckets)
- Refresh window: start_offset covers late-arriving data latency + one bucket width as safety margin
- end_offset: Set to at least one bucket width to avoid materializing partial buckets
- Compression: Enable on materialization hypertable with segmentby on most common filter dimension
- Indexes: Add composite indexes on (filter_column, bucket_utc DESC) for dashboard queries

### Continuous Aggregates

Real-Time Materialization Overhead at Scale:

- Real-time aggregation transparently combines pre-computed aggregate with raw data from hypertable
- Example overhead: 10 servers × 60 seconds × 90 minutes = 54,000 raw rows combined with 1,660 materialized rows
- Recent data (within end_offset gap) is more likely to be memory resident for better performance
- Materialized-only mode eliminates live aggregation overhead for predictable performance
- Trade-off: Real-time mode provides up-to-date data with slower recent window; materialized-only provides consistent performance with stale recent window

Optimization Strategies:

1. Bucket Width Selection: Match bucket width to query resolution (1-hour for hourly dashboards)
2. Refresh Window Tuning: Process only recent data instead of full dataset
3. Compression: Enable on materialization hypertable (10-20x storage savings)
4. Targeted Indexes: Composite indexes on filter dimensions + bucket column
5. Hierarchical CAGGs: Multi-resolution access (hourly → daily → monthly)
6. Real-Time Mode Selection: Use real-time for operational dashboards, materialized-only for batch reports

---

## Complete DDL

For the complete SQL DDL schema with all CREATE TABLE statements, RLS policies, indexes, and triggers, see [02-arch-database-schema.sql](02-arch-database-schema.sql).

The schema file contains:
- All 56 database tables with complete CREATE TABLE statements
- Row-Level Security (RLS) policies for multi-tenant isolation
- Performance indexes on foreign keys and query patterns
- Database triggers for automatic timestamp updates
- TimescaleDB hypertable configuration for time-series data
- Validation checklists for security, performance, and data integrity
