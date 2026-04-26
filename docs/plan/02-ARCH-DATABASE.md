# Database Schema

This document describes all database tables in the system. Every table follows the multi-tenant pattern with organization scoping and Row-Level Security (RLS).

---

## Data & Offline Rules

- (HARD) Every table that stores user data must have an `org_id` column and an active RLS policy.
- (HARD) Soft deletes via `deleted_at` (nullable timestamp with millisecond precision) are mandatory for offline sync.
- (HARD) Primary keys are ULIDs.
- (HARD) Idempotency keys for all async operations: `actor_id` + monotonic counter, enforced by unique constraint.
- (HARD) Supabase Realtime limits: 100 channels per connection, 20 self‑service channels; payloads capped.
- (HARD) PowerSync bucket rules are defined per org via YAML; sync rules scoped to JWT orgId claim.
- (MED) Offline queue uses an outbox pattern initially; full PowerSync bidirectional sync in Phase 2.

---

## Core Application Tables

### Messages
- **Primary key**: id
- **Foreign keys**: org_id, thread_id, user_id
- **Columns**: content, category, updated_at
- **Security**: RLS ensures users only see messages from their organization

### Threads
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: title, category
- **Purpose**: Groups related messages for chat conversations

### Projects
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: name, description, status, priority, start_date, end_date, budget, owner, client_email, tags, category, updated_at
- **Security**: Organization-scoped with RLS

### Tasks
- **Primary key**: id
- **Foreign keys**: project_id, parent_id (nullable)
- **Columns**: title, status, assignee, due_date, estimated_time, priority, order, checklist, category, updated_at
- **Features**: Supports subtasks through parent_id relationship

### Events
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: title, start_time, end_time, timezone, all_day_flag, recurrence_id (nullable), category, updated_at
- **Integration**: Links to recurrence rules for repeating events

## Communication & Content Tables

### Emails
- **Primary key**: id
- **Foreign keys**: org_id, account_id
- **Columns**: nylas_id, subject, from_address, to_addresses, cc_addresses, bcc_addresses, body, attachments, direction, category
- **Integration**: Synced with Nylas v3 API

### Contacts
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: name, email, phone, company, privacy_settings, tags, additional_data, category, updated_at
- **Privacy**: Includes privacy control fields

### Documents
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: name, type, size, storage_path, is_trashed, category, updated_at
- **Storage**: References Supabase Storage locations

### Media
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: name, type, url, alt_text, blurhash, album_id (nullable), category, updated_at
- **AI Features**: Includes AI-generated alt text and blurhash for performance

## Financial & Planning Tables

### Transactions
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: amount, date, description, category, type, is_planned, category
- **Purpose**: Track financial transactions and budget items

### Goals
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: name, target_value, current_value, deadline, category
- **Purpose**: Track progress toward personal or organizational goals

## Research & Learning Tables

### Research Notebooks
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: title, content, category, updated_at
- **Purpose**: Store research notes and documentation

### Flashcards
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: front_content, back_content, deck_name, fsrs_state, category, updated_at
- **Learning**: Uses FSRS (Free Spaced Repetition Scheduler) algorithm

## Collaboration & Communication Tables

### Conference Rooms
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: name, livekit_room_id, category
- **Integration**: Links to LiveKit for video conferencing

### Translation Sessions
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: source_language, target_language, speakers, segments, status, category
- **Purpose**: Track real-time translation sessions

### News Articles
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: url, title, source, sentiment, summary, category
- **Features**: Includes AI-generated sentiment and summaries

## System & Administration Tables

### Workflow Executions
- **Primary key**: id
- **Foreign keys**: org_id, workflow_id, step_id
- **Columns**: status, input_data, output_data, started_at, finished_at, category
- **Pattern**: Implements state machine pattern for workflow tracking

### Audit Logs
- **Primary key**: id
- **Foreign keys**: org_id, actor_id
- **Columns**: action, entity_type, entity_id, old_value, new_value, category
- **Security**: Anonymizes actor information on deletion for privacy

### Notification Preferences
- **Primary key**: id
- **Foreign keys**: org_id, user_id
- **Columns**: channels, category
- **Purpose**: Store user notification preferences per organization

## Multi-Tenant Foundation Tables

### Organization Members
- **Composite key**: org_id, user_id
- **Foreign key**: role_id
- **Columns**: joined_date
- **Security**: RLS join table for organization membership

### Connected Accounts
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: provider, grant_id (encrypted), access_token, expires_at, category
- **Security**: Encrypts sensitive grant IDs

### Organizations
- **Primary key**: id
- **Columns**: slug, name, plan, created_at, allow_training_flag
- **Purpose**: Multi-tenant root table with organization settings

### Feature Flags
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: flag_name, percentage, enabled, category
- **Lifecycle**: Controls feature rollout and availability

### Notifications
- **Primary key**: id
- **Foreign keys**: org_id, user_id
- **Columns**: template, deeplink, read_status, category
- **Features**: Uses templates with deep linking for in-app notifications

## Role-Based Access Control

### User Roles
- **Primary key**: id
- **Foreign keys**: org_id
- **Columns**: name, permissions
- **Hierarchy**: Supports admin, manager, member, viewer, external roles

### Role Permissions
- **Primary key**: role_id
- **Columns**: resource, action
- **Pattern**: RBAC matrix defining what each role can do

## AI & Agent Tables

### Agent Definitions
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: name, description, tools, configuration, version, is_public, category, updated_at
- **Features**: Versioned, organization-scoped agent configurations

### Recurrence Rules
- **Primary key**: id
- **Foreign keys**: org_id, entity_id
- **Columns**: entity_type, rrule, start_timezone, exception_dates, overrides, category
- **Purpose**: Shared recurrence engine for calendar events and other repeating items

### AI Cost Log
- **Primary key**: id
- **Foreign keys**: org_id, request_id
- **Columns**: model, tokens_in, tokens_out, cost, caller, category
- **Performance**: TimescaleDB hypertable for time-series efficiency

### Prompt Versions
- **Primary key**: id
- **Foreign keys**: org_id, prompt_id
- **Columns**: template, variables, version, is_production, category
- **Quality Gates**: Evaluation gate controls production deployment

### Evaluation Datasets
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: name, test_cases, category
- **Purpose**: Store test datasets for AI model evaluation

### Evaluation Runs
- **Primary key**: id
- **Foreign keys**: org_id, dataset_id, prompt_version_id
- **Columns**: metrics, passed, category
- **CI Integration**: Blocks merges if evaluation fails

## Collaboration Tables

### Collab Documents
- **Primary key**: id
- **Foreign keys**: org_id, entity_id
- **Columns**: ysweet_document_id, entity_type, permissions, creator_id, category
- **Integration**: Y-Sweet integration for real-time collaboration

## Monitoring & Cross-Cutting Service Tables

### Specification Metadata
- **Primary key**: id
- **Columns**: component_name, tier (1/2/3), status, frontmatter, sections_required, authors, dependencies, category, updated_at
- **Purpose**: Registry for all component specifications

### Realtime Channel Monitoring
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: channel_name, subscriber_count, memory_mb, created_at, last_activity
- **Purpose**: Monitor Supabase Realtime channel usage and memory

### Offline Operations Queue
- **Primary key**: id
- **Foreign keys**: org_id, actor_id, entity_id
- **Columns**: operation, entity_type, idempotency_key, tombstone, deleted_at (nullable), created_at
- **Purpose**: Queue for offline-first operations

### Workflow State Audit
- **Primary key**: id
- **Foreign keys**: workflow_id, step_id
- **Columns**: state, transition_reason, guard_evaluated, timestamp
- **Purpose**: Audit trail for workflow state machine transitions

### Webhook Deduplication
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: provider, provider_event_id, processed_status, deduplication_key, created_at
- **Purpose**: Prevent duplicate webhook processing

### Test Coverage Targets
- **Primary key**: id
- **Columns**: module, unit_target (0.80), component_target (0.85), integration_target (0.70), e2e_flows_target (10-15), a11y_critical_target (0)
- **Purpose**: Define testing coverage requirements per module

### Incident Management
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: severity (P0-P3), title, description, status, roles, slo_impact, created_at, resolved_at
- **Compliance**: SOC2 compliant incident lifecycle

### Feature Flag Registry
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: flag_name, description, owner, default_behavior, targeting_rules, current_stage, cohort_hash, review_date
- **Purpose**: Registry for all feature flags with compliance tracking

### Cost Budgets
- **Primary key**: id
- **Foreign keys**: org_id, scope_id
- **Columns**: level (org/team/user/model), monthly_limit, current_usage, alert_15_percent, alert_5_percent, alert_0_percent, hard_cap, updated_at
- **Purpose**: Multi-level budget enforcement

### SLO Definitions
- **Primary key**: id
- **Foreign keys**: org_id, service_id
- **Columns**: metric, target, window, current_value, error_budget_remaining
- **Purpose**: Service Level Objective definitions and tracking

### Security Control Mappings
- **Primary key**: id
- **Columns**: rule_id (S1-S21), control_description, mechanism, test_method, owner, evidence, last_verified
- **Purpose**: Security Control Matrix mapping

## Security & Compliance Tables

### MCP Tool Authorizations
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: tool_name, auth_method (oauth), scope, allowlist_schema, elicitation_required, approved_by, approved_at
- **Security**: MCP security layer authorization

### Passkeys
- **Primary key**: id
- **Foreign keys**: org_id, user_id
- **Columns**: credential_id, authenticator_type, created_at, last_used, recovery_codes
- **Purpose**: WebAuthn passkey storage

### Guardrails Audit Logs
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: layer (input/output/runtime), decision (allow/block/warn), reason, timestamp
- **Requirement**: 100% logging of all guardrail decisions

### SSRF Allowlists
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: allowed_domain, allowed_ip_range, validation_method, created_at, updated_at
- **Security**: Server-Side Request Forgery prevention

### Privacy Training Opt-outs
- **Primary key**: id
- **Foreign keys**: org_id, user_id
- **Columns**: allow_training, opted_out, reason, segregation_applied
- **Privacy**: AI training data privacy controls

### Stripe Usage Records
- **Primary key**: id
- **Foreign keys**: org_id, stripe_meter_id
- **Columns**: token_count, cost_usd, recorded_at, stripe_status
- **Purpose**: Track Stripe token meter usage

### Yjs Document Lifecycle
- **Primary key**: id
- **Foreign keys**: org_id, user_id
- **Columns**: document_namespace, gc_enabled, undo_stack_limit (≤5), snapshot_version, size_mb, compaction_triggered, category, updated_at
- **Purpose**: Monitor Yjs collaboration document lifecycle

### Nylas Webhook Configuration
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: trigger_type, upsert_first, async_queue, timeout (10 seconds), sync_policy
- **Integration**: Nylas v3 webhook processing configuration

### OpenTelemetry Span Definitions
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: span_name, required_attributes (gen_ai.*), redaction_rules
- **Purpose**: Define OTel span specifications for GenAI

### Offline Tombstone Configuration
- **Primary key**: id
- **Foreign keys**: org_id, entity_type
- **Columns**: deleted_at_column, retention_days, compaction_schedule
- **Purpose**: Configure soft delete behavior

### Realtime Limits Configuration
- **Primary key**: id
- **Foreign keys**: org_id
- **Columns**: platform_limit (100), self_service_limit (20), current_usage, alert_threshold (15), alert_triggered
- **Purpose**: Enforce realtime channel limits

### Upload Security Configuration
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: scanner (clamd), version_pinned (1.4.x+), cve_monitoring, chunked_scanning, pre_scan_validation
- **Security**: ClamAV upload scanning configuration

### Recurrence Rule Configuration
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: entity_type, rrule, rdate, exdate, timezone_id, edit_mode, exception_storage
- **Performance**: Exception storage keyed by start_utc for O(1) lookup

## TimescaleDB Configuration

### Continuous Aggregates Performance

**Performance Benchmarks:**

- Cloudflare achieved up to 1000x query performance improvement with precomputed aggregates using continuous aggregates
- Cloudflare handles ~100,000 aggregated rows per second ingestion rate with TimescaleDB for Zero Trust Analytics
- Materialization hypertable compression provides 10-20x storage savings on aggregated data
- Proper refresh window tuning reduces refresh duration from minutes to milliseconds

**Query Patterns:**

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

**Key Performance Factors:**

- Bucket width: 1-hour buckets optimal for dashboard queries (avoids 60x unnecessary work with 1-minute buckets)
- Refresh window: start_offset covers late-arriving data latency + one bucket width as safety margin
- end_offset: Set to at least one bucket width to avoid materializing partial buckets
- Compression: Enable on materialization hypertable with segmentby on most common filter dimension
- Indexes: Add composite indexes on (filter_column, bucket_utc DESC) for dashboard queries

### Continuous Aggregates

**Real-Time Materialization Overhead at Scale:**

- Real-time aggregation transparently combines pre-computed aggregate with raw data from hypertable
- Example overhead: 10 servers × 60 seconds × 90 minutes = 54,000 raw rows combined with 1,660 materialized rows
- Recent data (within end_offset gap) is more likely to be memory resident for better performance
- Materialized-only mode eliminates live aggregation overhead for predictable performance
- Trade-off: Real-time mode provides up-to-date data with slower recent window; materialized-only provides consistent performance with stale recent window

**Optimization Strategies:**

1. **Bucket Width Selection**: Match bucket width to query resolution (1-hour for hourly dashboards)
2. **Refresh Window Tuning**: Process only recent data instead of full dataset
3. **Compression**: Enable on materialization hypertable (10-20x storage savings)
4. **Targeted Indexes**: Composite indexes on filter dimensions + bucket column
5. **Hierarchical CAGGs**: Multi-resolution access (hourly → daily → monthly)
6. **Real-Time Mode Selection**: Use real-time for operational dashboards, materialized-only for batch reports

## GraphRAG & Analytics Tables (Added April 2026)

### Graph Entities
- **Primary key**: id
- **Foreign key**: org_id
- **Columns**: name, type, description, embedding, source_count, trust_score, category
- **Purpose**: GraphRAG node storage for knowledge graphs

### Graph Relationships
- **Primary key**: id
- **Foreign keys**: org_id, source_id, target_id
- **Columns**: relationship_type, weight, community, category
- **Purpose**: GraphRAG edge storage for knowledge graphs

### RAG Index Statistics
- **Primary key**: org_id
- **Columns**: chunk_count, index_type, contextual_retrieval_activated, graphrag_active, last_indexed, category
- **Purpose**: Monitor RAG index performance and configuration

### WebAuthn Challenges
- **Primary key**: id
- **Foreign key**: user_id
- **Columns**: challenge, type, expires_at, created_at
- **Security**: TTL 15 minutes for passkey authentication challenges

### Secret Rotation Log
- **Primary key**: id
- **Columns**: secret_name, rotated_at, method, success, evidence
- **Compliance**: SOC2 audit trail for secret rotation

### PostHog Event Taxonomy
- **Primary key**: id
- **Columns**: event_name, required_properties, owner, category
- **Purpose**: Analytics governance for event tracking

### Feature Flag Evidence
- **Primary key**: id
- **Foreign key**: flag_id
- **Columns**: owner, default_behavior, review_date, category
- **Compliance**: Feature flag compliance documentation

## Schema Modifications

### Connected Accounts Enhancement
- **New column**: grant_status (expired|revoked|active)
- **Purpose**: Track the status of connected account grants

### Notifications Enhancement
- **New column**: unsubscribed (boolean)
- **Alternative**: notificationPreferences JSONB field
- **Purpose**: Support unsubscribe functionality per notification

### Guardrails Audit Logs Enhancement
- **New column**: reason (cacheBlock|redisBlock|quotaExceeded)
- **Purpose**: Provide detailed reasons for guardrail decisions

### Upload Security Configuration Update
- **Version update**: version_pin from 1.0.4 to 1.4.x
- **Purpose**: Upgrade to newer ClamAV version with better security

---

## Complete DDL

For the complete SQL DDL schema with all CREATE TABLE statements, RLS policies, indexes, and triggers, see [02-arch-database-schema.sql](02-arch-database-schema.sql).

The schema file contains:
- All 40+ database tables with complete CREATE TABLE statements
- Row-Level Security (RLS) policies for multi-tenant isolation
- Performance indexes on foreign keys and query patterns
- Database triggers for automatic timestamp updates
- TimescaleDB hypertable configuration for time-series data
- Validation checklists for security, performance, and data integrity