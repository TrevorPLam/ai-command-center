
# Database Schema

This document describes all database tables in the system. Every table follows the multi-tenant pattern with organization scoping and Row-Level Security (RLS).

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
- **Foreign key**: org_id
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

### Database DDL - Complete SQL Schema

**Source**: Table definitions from `02-ARCH-DATABASE.md`
**Created**: 2026-04-26
**Status**: Complete SQL DDL for all database tables
**Database**: PostgreSQL 15+ with TimescaleDB extension

#### Overview

This document contains complete CREATE TABLE statements for all database tables in the AI Command Center system. All tables follow multi-tenant patterns with organization scoping and Row-Level Security (RLS).

##### Key Patterns Used

- **Primary Keys**: ULID strings with `gen_random_ulid()` default
- **Foreign Keys**: All tenant-scoped tables include `org_id` foreign key
- **Soft Deletes**: `deleted_at` nullable timestamp for most tables
- **Audit Trail**: `updated_at` auto-update triggers for all tables
- **Security**: RLS enabled on all tenant-scoped tables
- **Performance**: Strategic indexes on foreign keys and query patterns

#### Core Application Tables

##### Messages Table

```sql
CREATE TABLE messages (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    thread_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    content TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_messages_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_messages_thread FOREIGN KEY (thread_id) REFERENCES threads(id) ON DELETE CASCADE,
    CONSTRAINT fk_messages_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Enable RLS
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access messages from their organization
CREATE POLICY messages_org_policy ON messages
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_messages_org_id ON messages(org_id);
CREATE INDEX idx_messages_thread_id ON messages(thread_id);
CREATE INDEX idx_messages_user_id ON messages(user_id);
CREATE INDEX idx_messages_updated_at ON messages(updated_at DESC);
```

##### Threads Table

```sql
CREATE TABLE threads (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    title TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'chat',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_threads_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE
);

-- Enable RLS
ALTER TABLE threads ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access threads from their organization
CREATE POLICY threads_org_policy ON threads
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_threads_org_id ON threads(org_id);
CREATE INDEX idx_threads_category ON threads(category);
CREATE INDEX idx_threads_updated_at ON threads(updated_at DESC);
```

##### Projects Table

```sql
CREATE TABLE projects (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'active',
    priority TEXT NOT NULL DEFAULT 'medium',
    start_date DATE,
    end_date DATE,
    budget DECIMAL(12,2),
    owner TEXT,
    client_email TEXT,
    tags TEXT[],
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_projects_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_projects_status CHECK (status IN ('active', 'completed', 'archived', 'on_hold')),
    CONSTRAINT chk_projects_priority CHECK (priority IN ('low', 'medium', 'high', 'critical'))
);

-- Enable RLS
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access projects from their organization
CREATE POLICY projects_org_policy ON projects
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_projects_org_id ON projects(org_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_priority ON projects(priority);
CREATE INDEX idx_projects_owner ON projects(owner);
CREATE INDEX idx_projects_updated_at ON projects(updated_at DESC);
```

##### Tasks Table

```sql
CREATE TABLE tasks (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    project_id TEXT NOT NULL,
    parent_id TEXT,
    title TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'todo',
    assignee TEXT,
    due_date TIMESTAMP WITH TIME ZONE,
    estimated_time INTEGER, -- in minutes
    priority TEXT NOT NULL DEFAULT 'medium',
    "order" INTEGER NOT NULL DEFAULT 0,
    checklist JSONB,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_tasks_project FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    CONSTRAINT fk_tasks_parent FOREIGN KEY (parent_id) REFERENCES tasks(id) ON DELETE CASCADE,
    CONSTRAINT chk_tasks_status CHECK (status IN ('todo', 'in_progress', 'completed', 'cancelled')),
    CONSTRAINT chk_tasks_priority CHECK (priority IN ('low', 'medium', 'high', 'critical'))
);

-- Enable RLS (inherits from project)
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access tasks from their organization via project
CREATE POLICY tasks_org_policy ON tasks
    FOR ALL TO authenticated_users
    USING (project_id IN (
        SELECT id FROM projects WHERE org_id = auth.jwt()->>'org_id'
    ));

-- Indexes for performance
CREATE INDEX idx_tasks_project_id ON tasks(project_id);
CREATE INDEX idx_tasks_parent_id ON tasks(parent_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_assignee ON tasks(assignee);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_priority ON tasks(priority);
CREATE INDEX idx_tasks_order ON tasks("order");
CREATE INDEX idx_tasks_updated_at ON tasks(updated_at DESC);
```

##### Events Table

```sql
CREATE TABLE events (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    title TEXT NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    timezone TEXT NOT NULL DEFAULT 'UTC',
    all_day_flag BOOLEAN DEFAULT FALSE,
    recurrence_id TEXT,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_events_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_events_recurrence FOREIGN KEY (recurrence_id) REFERENCES recurrence_rules(id) ON DELETE SET NULL,
    CONSTRAINT chk_events_times CHECK (end_time >= start_time)
);

-- Enable RLS
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access events from their organization
CREATE POLICY events_org_policy ON events
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_events_org_id ON events(org_id);
CREATE INDEX idx_events_start_time ON events(start_time);
CREATE INDEX idx_events_end_time ON events(end_time);
CREATE INDEX idx_events_recurrence_id ON events(recurrence_id);
CREATE INDEX idx_events_category ON events(category);
CREATE INDEX idx_events_updated_at ON events(updated_at DESC);
```

#### Communication & Content Tables

##### Emails Table

```sql
CREATE TABLE emails (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    account_id TEXT NOT NULL,
    nylas_id TEXT NOT NULL,
    subject TEXT NOT NULL,
    from_address TEXT NOT NULL,
    to_addresses TEXT[] NOT NULL,
    cc_addresses TEXT[],
    bcc_addresses TEXT[],
    body TEXT,
    attachments JSONB,
    direction TEXT NOT NULL DEFAULT 'inbound',
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_emails_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_emails_account FOREIGN KEY (account_id) REFERENCES connected_accounts(id) ON DELETE CASCADE,
    CONSTRAINT chk_emails_direction CHECK (direction IN ('inbound', 'outbound', 'internal'))
);

-- Enable RLS
ALTER TABLE emails ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access emails from their organization
CREATE POLICY emails_org_policy ON emails
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_emails_org_id ON emails(org_id);
CREATE INDEX idx_emails_account_id ON emails(account_id);
CREATE INDEX idx_emails_nylas_id ON emails(nylas_id);
CREATE INDEX idx_emails_from_address ON emails(from_address);
CREATE INDEX idx_emails_direction ON emails(direction);
CREATE INDEX idx_emails_updated_at ON emails(updated_at DESC);
```

##### Contacts Table

```sql
CREATE TABLE contacts (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    company TEXT,
    privacy_settings JSONB,
    tags TEXT[],
    additional_data JSONB,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_contacts_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT uq_contacts_email UNIQUE(org_id, email) WHERE email IS NOT NULL
);

-- Enable RLS
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access contacts from their organization
CREATE POLICY contacts_org_policy ON contacts
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_contacts_org_id ON contacts(org_id);
CREATE INDEX idx_contacts_email ON contacts(email);
CREATE INDEX idx_contacts_name ON contacts(name);
CREATE INDEX idx_contacts_company ON contacts(company);
CREATE INDEX idx_contacts_tags ON contacts USING GIN(tags);
CREATE INDEX idx_contacts_updated_at ON contacts(updated_at DESC);
```

##### Documents Table

```sql
CREATE TABLE documents (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    size BIGINT NOT NULL,
    storage_path TEXT NOT NULL,
    is_trashed BOOLEAN DEFAULT FALSE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_documents_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_documents_size CHECK (size >= 0)
);

-- Enable RLS
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access documents from their organization
CREATE POLICY documents_org_policy ON documents
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_documents_org_id ON documents(org_id);
CREATE INDEX idx_documents_type ON documents(type);
CREATE INDEX idx_documents_is_trashed ON documents(is_trashed);
CREATE INDEX idx_documents_category ON documents(category);
CREATE INDEX idx_documents_updated_at ON documents(updated_at DESC);
```

##### Media Table

```sql
CREATE TABLE media (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    url TEXT NOT NULL,
    alt_text TEXT,
    blurhash TEXT,
    album_id TEXT,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_media_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_media_album FOREIGN KEY (album_id) REFERENCES albums(id) ON DELETE SET NULL
);

-- Enable RLS
ALTER TABLE media ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access media from their organization
CREATE POLICY media_org_policy ON media
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_media_org_id ON media(org_id);
CREATE INDEX idx_media_type ON media(type);
CREATE INDEX idx_media_album_id ON media(album_id);
CREATE INDEX idx_media_category ON media(category);
CREATE INDEX idx_media_updated_at ON media(updated_at DESC);
```

#### Financial & Planning Tables

##### Transactions Table

```sql
CREATE TABLE transactions (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    date DATE NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'general',
    type TEXT NOT NULL DEFAULT 'expense',
    is_planned BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_transactions_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_transactions_type CHECK (type IN ('income', 'expense', 'transfer'))
);

-- Enable RLS
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access transactions from their organization
CREATE POLICY transactions_org_policy ON transactions
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_transactions_org_id ON transactions(org_id);
CREATE INDEX idx_transactions_date ON transactions(date DESC);
CREATE INDEX idx_transactions_category ON transactions(category);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_is_planned ON transactions(is_planned);
```

##### Goals Table

```sql
CREATE TABLE goals (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    name TEXT NOT NULL,
    target_value DECIMAL(12,2) NOT NULL,
    current_value DECIMAL(12,2) DEFAULT 0,
    deadline DATE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_goals_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_goals_values CHECK (target_value >= 0 AND current_value >= 0)
);

-- Enable RLS
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access goals from their organization
CREATE POLICY goals_org_policy ON goals
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_goals_org_id ON goals(org_id);
CREATE INDEX idx_goals_deadline ON goals(deadline);
CREATE INDEX idx_goals_category ON goals(category);
CREATE INDEX idx_goals_updated_at ON goals(updated_at DESC);
```

#### Research & Learning Tables

##### Research Notebooks Table

```sql
CREATE TABLE research_notebooks (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    title TEXT NOT NULL,
    content TEXT,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_research_notebooks_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE
);

-- Enable RLS
ALTER TABLE research_notebooks ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access research notebooks from their organization
CREATE POLICY research_notebooks_org_policy ON research_notebooks
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_research_notebooks_org_id ON research_notebooks(org_id);
CREATE INDEX idx_research_notebooks_category ON research_notebooks(category);
CREATE INDEX idx_research_notebooks_updated_at ON research_notebooks(updated_at DESC);
```

##### Flashcards Table

```sql
CREATE TABLE flashcards (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    front_content TEXT NOT NULL,
    back_content TEXT NOT NULL,
    deck_name TEXT NOT NULL,
    fsrs_state JSONB,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_flashcards_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE
);

-- Enable RLS
ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access flashcards from their organization
CREATE POLICY flashcards_org_policy ON flashcards
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_flashcards_org_id ON flashcards(org_id);
CREATE INDEX idx_flashcards_deck_name ON flashcards(deck_name);
CREATE INDEX idx_flashcards_category ON flashcards(category);
CREATE INDEX idx_flashcards_updated_at ON flashcards(updated_at DESC);
```

#### Collaboration & Communication Tables

##### Conference Rooms Table

```sql
CREATE TABLE conference_rooms (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    name TEXT NOT NULL,
    livekit_room_id TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_conference_rooms_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT uq_conference_rooms_livekit UNIQUE(livekit_room_id)
);

-- Enable RLS
ALTER TABLE conference_rooms ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access conference rooms from their organization
CREATE POLICY conference_rooms_org_policy ON conference_rooms
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_conference_rooms_org_id ON conference_rooms(org_id);
CREATE INDEX idx_conference_rooms_livekit_room_id ON conference_rooms(livekit_room_id);
CREATE INDEX idx_conference_rooms_category ON conference_rooms(category);
```

##### Translation Sessions Table

```sql
CREATE TABLE translation_sessions (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    source_language TEXT NOT NULL,
    target_language TEXT NOT NULL,
    speakers JSONB,
    segments JSONB,
    status TEXT NOT NULL DEFAULT 'pending',
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_translation_sessions_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_translation_sessions_status CHECK (status IN ('pending', 'in_progress', 'completed', 'failed'))
);

-- Enable RLS
ALTER TABLE translation_sessions ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access translation sessions from their organization
CREATE POLICY translation_sessions_org_policy ON translation_sessions
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_translation_sessions_org_id ON translation_sessions(org_id);
CREATE INDEX idx_translation_sessions_status ON translation_sessions(status);
CREATE INDEX idx_translation_sessions_source_language ON translation_sessions(source_language);
CREATE INDEX idx_translation_sessions_target_language ON translation_sessions(target_language);
```

##### News Articles Table

```sql
CREATE TABLE news_articles (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    url TEXT NOT NULL,
    title TEXT NOT NULL,
    source TEXT NOT NULL,
    sentiment TEXT,
    summary TEXT,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_news_articles_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT uq_news_articles_url UNIQUE(url)
);

-- Enable RLS
ALTER TABLE news_articles ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access news articles from their organization
CREATE POLICY news_articles_org_policy ON news_articles
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_news_articles_org_id ON news_articles(org_id);
CREATE INDEX idx_news_articles_source ON news_articles(source);
CREATE INDEX idx_news_articles_sentiment ON news_articles(sentiment);
CREATE INDEX idx_news_articles_category ON news_articles(category);
CREATE INDEX idx_news_articles_updated_at ON news_articles(updated_at DESC);
```

#### System & Administration Tables

##### Workflow Executions Table

```sql
CREATE TABLE workflow_executions (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    workflow_id TEXT NOT NULL,
    step_id TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    input_data JSONB,
    output_data JSONB,
    started_at TIMESTAMP WITH TIME ZONE,
    finished_at TIMESTAMP WITH TIME ZONE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_workflow_executions_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_workflow_executions_status CHECK (status IN ('pending', 'running', 'completed', 'failed', 'cancelled'))
);

-- Enable RLS
ALTER TABLE workflow_executions ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access workflow executions from their organization
CREATE POLICY workflow_executions_org_policy ON workflow_executions
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_workflow_executions_org_id ON workflow_executions(org_id);
CREATE INDEX idx_workflow_executions_workflow_id ON workflow_executions(workflow_id);
CREATE INDEX idx_workflow_executions_step_id ON workflow_executions(step_id);
CREATE INDEX idx_workflow_executions_status ON workflow_executions(status);
CREATE INDEX idx_workflow_executions_started_at ON workflow_executions(started_at DESC);
```

##### Audit Logs Table

```sql
CREATE TABLE audit_logs (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    actor_id TEXT,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    old_value JSONB,
    new_value JSONB,
    category TEXT NOT NULL DEFAULT 'general',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_audit_logs_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE
);

-- Enable RLS
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access audit logs from their organization
CREATE POLICY audit_logs_org_policy ON audit_logs
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_audit_logs_org_id ON audit_logs(org_id);
CREATE INDEX idx_audit_logs_actor_id ON audit_logs(actor_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_entity_type ON audit_logs(entity_type);
CREATE INDEX idx_audit_logs_entity_id ON audit_logs(entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);
```

##### Notification Preferences Table

```sql
CREATE TABLE notification_preferences (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    channels JSONB NOT NULL DEFAULT '{}',
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_notification_preferences_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_notification_preferences_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT uq_notification_preferences_user UNIQUE(org_id, user_id)
);

-- Enable RLS
ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access notification preferences from their organization
CREATE POLICY notification_preferences_org_policy ON notification_preferences
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_notification_preferences_org_id ON notification_preferences(org_id);
CREATE INDEX idx_notification_preferences_user_id ON notification_preferences(user_id);
```

#### Multi-Tenant Foundation Tables

##### Organization Members Table

```sql
CREATE TABLE organization_members (
    org_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    role_id TEXT,
    joined_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (org_id, user_id),
    CONSTRAINT fk_org_members_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_org_members_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_org_members_role FOREIGN KEY (role_id) REFERENCES user_roles(id) ON DELETE SET NULL
);

-- Enable RLS
ALTER TABLE organization_members ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only see their own organization memberships
CREATE POLICY organization_members_policy ON organization_members
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id' AND user_id = auth.jwt()->>'user_id');

-- Indexes for performance
CREATE INDEX idx_organization_members_org_id ON organization_members(org_id);
CREATE INDEX idx_organization_members_user_id ON organization_members(user_id);
CREATE INDEX idx_organization_members_role_id ON organization_members(role_id);
```

##### Connected Accounts Table

```sql
CREATE TABLE connected_accounts (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    provider TEXT NOT NULL,
    grant_id TEXT, -- encrypted
    access_token TEXT,
    expires_at TIMESTAMP WITH TIME ZONE,
    grant_status TEXT NOT NULL DEFAULT 'active',
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_connected_accounts_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_connected_accounts_status CHECK (grant_status IN ('active', 'expired', 'revoked'))
);

-- Enable RLS
ALTER TABLE connected_accounts ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access connected accounts from their organization
CREATE POLICY connected_accounts_org_policy ON connected_accounts
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_connected_accounts_org_id ON connected_accounts(org_id);
CREATE INDEX idx_connected_accounts_provider ON connected_accounts(provider);
CREATE INDEX idx_connected_accounts_grant_status ON connected_accounts(grant_status);
CREATE INDEX idx_connected_accounts_expires_at ON connected_accounts(expires_at);
```

##### Organizations Table

```sql
CREATE TABLE organizations (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    slug TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    plan TEXT NOT NULL DEFAULT 'free',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    allow_training_flag BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_organizations_plan CHECK (plan IN ('free', 'pro', 'enterprise'))
);

-- No RLS on organizations table (system-level access)
CREATE INDEX idx_organizations_slug ON organizations(slug);
CREATE INDEX idx_organizations_plan ON organizations(plan);
CREATE INDEX idx_organizations_created_at ON organizations(created_at DESC);
```

##### Feature Flags Table

```sql
CREATE TABLE feature_flags (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    flag_name TEXT NOT NULL,
    percentage DECIMAL(5,2) DEFAULT 0.0,
    enabled BOOLEAN DEFAULT FALSE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_feature_flags_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT uq_feature_flags_org_name UNIQUE(org_id, flag_name),
    CONSTRAINT chk_feature_flags_percentage CHECK (percentage >= 0.0 AND percentage <= 100.0)
);

-- Enable RLS
ALTER TABLE feature_flags ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access feature flags from their organization
CREATE POLICY feature_flags_org_policy ON feature_flags
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_feature_flags_org_id ON feature_flags(org_id);
CREATE INDEX idx_feature_flags_flag_name ON feature_flags(flag_name);
CREATE INDEX idx_feature_flags_enabled ON feature_flags(enabled);
```

##### Notifications Table

```sql
CREATE TABLE notifications (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    template TEXT NOT NULL,
    deeplink TEXT,
    read_status BOOLEAN DEFAULT FALSE,
    unsubscribed BOOLEAN DEFAULT FALSE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_notifications_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Enable RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access notifications from their organization
CREATE POLICY notifications_org_policy ON notifications
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_notifications_org_id ON notifications(org_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_read_status ON notifications(read_status);
CREATE INDEX idx_notifications_unsubscribed ON notifications(unsubscribed);
CREATE INDEX idx_notifications_updated_at ON notifications(updated_at DESC);
```

#### Role-Based Access Control Tables

##### User Roles Table

```sql
CREATE TABLE user_roles (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    name TEXT NOT NULL,
    permissions JSONB NOT NULL DEFAULT '{}',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_user_roles_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT uq_user_roles_org_name UNIQUE(org_id, name),
    CONSTRAINT chk_user_roles_name CHECK (name IN ('admin', 'manager', 'member', 'viewer', 'external'))
);

-- Enable RLS
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access user roles from their organization
CREATE POLICY user_roles_org_policy ON user_roles
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_user_roles_org_id ON user_roles(org_id);
CREATE INDEX idx_user_roles_name ON user_roles(name);
```

##### Role Permissions Table

```sql
CREATE TABLE role_permissions (
    role_id TEXT NOT NULL,
    resource TEXT NOT NULL,
    action TEXT NOT NULL,

    PRIMARY KEY (role_id, resource, action),
    CONSTRAINT fk_role_permissions_role FOREIGN KEY (role_id) REFERENCES user_roles(id) ON DELETE CASCADE
);

-- Enable RLS
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access role permissions from their organization
CREATE POLICY role_permissions_org_policy ON role_permissions
    FOR ALL TO authenticated_users
    USING (role_id IN (
        SELECT id FROM user_roles WHERE org_id = auth.jwt()->>'org_id'
    ));

-- Indexes for performance
CREATE INDEX idx_role_permissions_role_id ON role_permissions(role_id);
CREATE INDEX idx_role_permissions_resource ON role_permissions(resource);
CREATE INDEX idx_role_permissions_action ON role_permissions(action);
```

#### AI & Agent Tables

##### Agent Definitions Table

```sql
CREATE TABLE agent_definitions (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    tools JSONB NOT NULL DEFAULT '[]',
    configuration JSONB NOT NULL DEFAULT '{}',
    version INTEGER NOT NULL DEFAULT 1,
    is_public BOOLEAN DEFAULT FALSE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_agent_definitions_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT uq_agent_definitions_org_name_version UNIQUE(org_id, name, version)
);

-- Enable RLS
ALTER TABLE agent_definitions ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access agent definitions from their organization
CREATE POLICY agent_definitions_org_policy ON agent_definitions
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_agent_definitions_org_id ON agent_definitions(org_id);
CREATE INDEX idx_agent_definitions_name ON agent_definitions(name);
CREATE INDEX idx_agent_definitions_version ON agent_definitions(version);
CREATE INDEX idx_agent_definitions_is_public ON agent_definitions(is_public);
CREATE INDEX idx_agent_definitions_updated_at ON agent_definitions(updated_at DESC);
```

##### Recurrence Rules Table

```sql
CREATE TABLE recurrence_rules (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    rrule TEXT NOT NULL,
    start_timezone TEXT NOT NULL DEFAULT 'UTC',
    exception_dates TEXT[],
    overrides JSONB DEFAULT '{}',
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_recurrence_rules_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_recurrence_rules_entity_type CHECK (entity_type IN ('event', 'task', 'reminder'))
);

-- Enable RLS
ALTER TABLE recurrence_rules ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access recurrence rules from their organization
CREATE POLICY recurrence_rules_org_policy ON recurrence_rules
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_recurrence_rules_org_id ON recurrence_rules(org_id);
CREATE INDEX idx_recurrence_rules_entity_id ON recurrence_rules(entity_id);
CREATE INDEX idx_recurrence_rules_entity_type ON recurrence_rules(entity_type);
CREATE INDEX idx_recurrence_rules_updated_at ON recurrence_rules(updated_at DESC);
```

##### AI Cost Log Table

```sql
CREATE TABLE ai_cost_log (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    request_id TEXT NOT NULL,
    model TEXT NOT NULL,
    tokens_in INTEGER NOT NULL DEFAULT 0,
    tokens_out INTEGER NOT NULL DEFAULT 0,
    cost DECIMAL(10,6) NOT NULL DEFAULT 0.000000,
    caller TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'general',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_ai_cost_log_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_ai_cost_log_tokens CHECK (tokens_in >= 0 AND tokens_out >= 0),
    CONSTRAINT chk_ai_cost_log_cost CHECK (cost >= 0)
);

-- Enable RLS
ALTER TABLE ai_cost_log ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access AI cost logs from their organization
CREATE POLICY ai_cost_log_org_policy ON ai_cost_log
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Create TimescaleDB hypertable for time-series performance
SELECT create_hypertable('ai_cost_log', 'created_at', chunk_time_interval => INTERVAL '1 day');

-- Indexes for performance
CREATE INDEX idx_ai_cost_log_org_id ON ai_cost_log(org_id);
CREATE INDEX idx_ai_cost_log_request_id ON ai_cost_log(request_id);
CREATE INDEX idx_ai_cost_log_model ON ai_cost_log(model);
CREATE INDEX idx_ai_cost_log_caller ON ai_cost_log(caller);
CREATE INDEX idx_ai_cost_log_created_at ON ai_cost_log(created_at DESC);
```

##### Prompt Versions Table

```sql
CREATE TABLE prompt_versions (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    prompt_id TEXT NOT NULL,
    template TEXT NOT NULL,
    variables JSONB DEFAULT '{}',
    version INTEGER NOT NULL DEFAULT 1,
    is_production BOOLEAN DEFAULT FALSE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_prompt_versions_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT uq_prompt_versions_org_prompt_version UNIQUE(org_id, prompt_id, version)
);

-- Enable RLS
ALTER TABLE prompt_versions ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access prompt versions from their organization
CREATE POLICY prompt_versions_org_policy ON prompt_versions
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_prompt_versions_org_id ON prompt_versions(org_id);
CREATE INDEX idx_prompt_versions_prompt_id ON prompt_versions(prompt_id);
CREATE INDEX idx_prompt_versions_version ON prompt_versions(version);
CREATE INDEX idx_prompt_versions_is_production ON prompt_versions(is_production);
CREATE INDEX idx_prompt_versions_updated_at ON prompt_versions(updated_at DESC);
```

##### Evaluation Datasets Table

```sql
CREATE TABLE evaluation_datasets (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    name TEXT NOT NULL,
    test_cases JSONB NOT NULL DEFAULT '[]',
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_evaluation_datasets_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE
);

-- Enable RLS
ALTER TABLE evaluation_datasets ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access evaluation datasets from their organization
CREATE POLICY evaluation_datasets_org_policy ON evaluation_datasets
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_evaluation_datasets_org_id ON evaluation_datasets(org_id);
CREATE INDEX idx_evaluation_datasets_name ON evaluation_datasets(name);
CREATE INDEX idx_evaluation_datasets_updated_at ON evaluation_datasets(updated_at DESC);
```

##### Evaluation Runs Table

```sql
CREATE TABLE evaluation_runs (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    dataset_id TEXT NOT NULL,
    prompt_version_id TEXT NOT NULL,
    metrics JSONB NOT NULL DEFAULT '{}',
    passed BOOLEAN NOT NULL DEFAULT FALSE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_evaluation_runs_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_evaluation_runs_dataset FOREIGN KEY (dataset_id) REFERENCES evaluation_datasets(id) ON DELETE CASCADE,
    CONSTRAINT fk_evaluation_runs_prompt_version FOREIGN KEY (prompt_version_id) REFERENCES prompt_versions(id) ON DELETE CASCADE
);

-- Enable RLS
ALTER TABLE evaluation_runs ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access evaluation runs from their organization
CREATE POLICY evaluation_runs_org_policy ON evaluation_runs
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_evaluation_runs_org_id ON evaluation_runs(org_id);
CREATE INDEX idx_evaluation_runs_dataset_id ON evaluation_runs(dataset_id);
CREATE INDEX idx_evaluation_runs_prompt_version_id ON evaluation_runs(prompt_version_id);
CREATE INDEX idx_evaluation_runs_passed ON evaluation_runs(passed);
CREATE INDEX idx_evaluation_runs_updated_at ON evaluation_runs(updated_at DESC);
```

#### GraphRAG & Analytics Tables

##### Graph Entities Table

```sql
CREATE TABLE graph_entities (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    description TEXT,
    embedding vector(1536), -- for vector similarity search
    source_count INTEGER DEFAULT 0,
    trust_score DECIMAL(3,2) DEFAULT 0.0,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_graph_entities_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_graph_entities_trust_score CHECK (trust_score >= 0.0 AND trust_score <= 1.0)
);

-- Enable RLS
ALTER TABLE graph_entities ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access graph entities from their organization
CREATE POLICY graph_entities_org_policy ON graph_entities
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_graph_entities_org_id ON graph_entities(org_id);
CREATE INDEX idx_graph_entities_name ON graph_entities(name);
CREATE INDEX idx_graph_entities_type ON graph_entities(type);
CREATE INDEX idx_graph_entities_trust_score ON graph_entities(trust_score DESC);
CREATE INDEX idx_graph_entities_embedding ON graph_entities USING ivfflat (embedding vector_cosine_ops);
```

##### Graph Relationships Table

```sql
CREATE TABLE graph_relationships (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    source_id TEXT NOT NULL,
    target_id TEXT NOT NULL,
    relationship_type TEXT NOT NULL,
    weight DECIMAL(3,2) DEFAULT 1.0,
    community TEXT,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_graph_relationships_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_graph_relationships_source FOREIGN KEY (source_id) REFERENCES graph_entities(id) ON DELETE CASCADE,
    CONSTRAINT fk_graph_relationships_target FOREIGN KEY (target_id) REFERENCES graph_entities(id) ON DELETE CASCADE,
    CONSTRAINT chk_graph_relationships_weight CHECK (weight >= 0.0)
);

-- Enable RLS
ALTER TABLE graph_relationships ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access graph relationships from their organization
CREATE POLICY graph_relationships_org_policy ON graph_relationships
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_graph_relationships_org_id ON graph_relationships(org_id);
CREATE INDEX idx_graph_relationships_source_id ON graph_relationships(source_id);
CREATE INDEX idx_graph_relationships_target_id ON graph_relationships(target_id);
CREATE INDEX idx_graph_relationships_relationship_type ON graph_relationships(relationship_type);
CREATE INDEX idx_graph_relationships_weight ON graph_relationships(weight DESC);
CREATE INDEX idx_graph_relationships_community ON graph_relationships(community);
```

##### RAG Index Statistics Table

```sql
CREATE TABLE rag_index_statistics (
    org_id TEXT PRIMARY KEY,
    chunk_count BIGINT DEFAULT 0,
    index_type TEXT NOT NULL DEFAULT 'vector',
    contextual_retrieval_activated BOOLEAN DEFAULT FALSE,
    graphrag_active BOOLEAN DEFAULT FALSE,
    last_indexed TIMESTAMP WITH TIME ZONE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_rag_index_statistics_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE
);

-- Enable RLS
ALTER TABLE rag_index_statistics ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access RAG index statistics from their organization
CREATE POLICY rag_index_statistics_org_policy ON rag_index_statistics
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

-- Indexes for performance
CREATE INDEX idx_rag_index_statistics_org_id ON rag_index_statistics(org_id);
CREATE INDEX idx_rag_index_statistics_index_type ON rag_index_statistics(index_type);
CREATE INDEX idx_rag_index_statistics_last_indexed ON rag_index_statistics(last_indexed DESC);
```

##### WebAuthn Challenges Table

```sql
CREATE TABLE webauthn_challenges (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    user_id TEXT NOT NULL,
    challenge TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'passkey',
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_webauthn_challenges_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT chk_webauthn_challenges_expires CHECK (expires_at > created_at)
);

-- No RLS needed - challenges are user-specific
CREATE INDEX idx_webauthn_challenges_user_id ON webauthn_challenges(user_id);
CREATE INDEX idx_webauthn_challenges_expires_at ON webauthn_challenges(expires_at);
CREATE INDEX idx_webauthn_challenges_challenge ON webauthn_challenges(challenge);
```

##### Secret Rotation Log Table

```sql
CREATE TABLE secret_rotation_log (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    secret_name TEXT NOT NULL,
    rotated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    method TEXT NOT NULL,
    success BOOLEAN NOT NULL,
    evidence TEXT,

    CONSTRAINT chk_secret_rotation_log_method CHECK (method IN ('manual', 'automated', 'emergency'))
);

-- System table - no RLS needed
CREATE INDEX idx_secret_rotation_log_secret_name ON secret_rotation_log(secret_name);
CREATE INDEX idx_secret_rotation_log_rotated_at ON secret_rotation_log(rotated_at DESC);
CREATE INDEX idx_secret_rotation_log_success ON secret_rotation_log(success);
```

##### PostHog Event Taxonomy Table

```sql
CREATE TABLE posthog_event_taxonomy (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    event_name TEXT NOT NULL UNIQUE,
    required_properties JSONB NOT NULL DEFAULT '{}',
    owner TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- System table - no RLS needed
CREATE INDEX idx_posthog_event_taxonomy_event_name ON posthog_event_taxonomy(event_name);
CREATE INDEX idx_posthog_event_taxonomy_owner ON posthog_event_taxonomy(owner);
CREATE INDEX idx_posthog_event_taxonomy_category ON posthog_event_taxonomy(category);
```

##### Feature Flag Evidence Table

```sql
CREATE TABLE feature_flag_evidence (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    flag_id TEXT NOT NULL,
    owner TEXT NOT NULL,
    default_behavior TEXT,
    review_date DATE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_feature_flag_evidence_flag FOREIGN KEY (flag_id) REFERENCES feature_flags(id) ON DELETE CASCADE
);

-- Enable RLS (inherits from flag)
ALTER TABLE feature_flag_evidence ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can only access feature flag evidence from their organization
CREATE POLICY feature_flag_evidence_org_policy ON feature_flag_evidence
    FOR ALL TO authenticated_users
    USING (flag_id IN (
        SELECT id FROM feature_flags WHERE org_id = auth.jwt()->>'org_id'
    ));

-- Indexes for performance
CREATE INDEX idx_feature_flag_evidence_flag_id ON feature_flag_evidence(flag_id);
CREATE INDEX idx_feature_flag_evidence_owner ON feature_flag_evidence(owner);
CREATE INDEX idx_feature_flag_evidence_review_date ON feature_flag_evidence(review_date DESC);
```

#### Database Triggers and Functions

##### Updated At Trigger Function

```sql
-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply the trigger to all tables that need it
CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_threads_updated_at BEFORE UPDATE ON threads
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_emails_updated_at BEFORE UPDATE ON emails
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contacts_updated_at BEFORE UPDATE ON contacts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_documents_updated_at BEFORE UPDATE ON documents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_media_updated_at BEFORE UPDATE ON media
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON transactions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_goals_updated_at BEFORE UPDATE ON goals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_research_notebooks_updated_at BEFORE UPDATE ON research_notebooks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_flashcards_updated_at BEFORE UPDATE ON flashcards
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conference_rooms_updated_at BEFORE UPDATE ON conference_rooms
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_translation_sessions_updated_at BEFORE UPDATE ON translation_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_news_articles_updated_at BEFORE UPDATE ON news_articles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workflow_executions_updated_at BEFORE UPDATE ON workflow_executions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notification_preferences_updated_at BEFORE UPDATE ON notification_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_connected_accounts_updated_at BEFORE UPDATE ON connected_accounts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_organizations_updated_at BEFORE UPDATE ON organizations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_feature_flags_updated_at BEFORE UPDATE ON feature_flags
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_roles_updated_at BEFORE UPDATE ON user_roles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_agent_definitions_updated_at BEFORE UPDATE ON agent_definitions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_recurrence_rules_updated_at BEFORE UPDATE ON recurrence_rules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_prompt_versions_updated_at BEFORE UPDATE ON prompt_versions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_evaluation_datasets_updated_at BEFORE UPDATE ON evaluation_datasets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_evaluation_runs_updated_at BEFORE UPDATE ON evaluation_runs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_graph_entities_updated_at BEFORE UPDATE ON graph_entities
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_graph_relationships_updated_at BEFORE UPDATE ON graph_relationships
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rag_index_statistics_updated_at BEFORE UPDATE ON rag_index_statistics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posthog_event_taxonomy_updated_at BEFORE UPDATE ON posthog_event_taxonomy
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_feature_flag_evidence_updated_at BEFORE UPDATE ON feature_flag_evidence
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

#### Validation Checklist

##### Schema Validation

- [ ] All 40+ tables from `02-ARCH-DATABASE.md` have CREATE TABLE statements
- [ ] Every table with `org_id` has RLS enabled with proper policy
- [ ] All Phase 0 tables are included (defer Phase 1+ tables if marked)
- [ ] SQL validates against PostgreSQL 15+ syntax
- [ ] All primary keys use ULID with `gen_random_ulid()` default
- [ ] All tenant-scoped tables have `org_id` foreign key constraints
- [ ] All tables have `updated_at` column with auto-update trigger
- [ ] All tables have appropriate indexes for performance
- [ ] TimescaleDB hypertable configured for `ai_cost_log`
- [ ] All check constraints are properly defined
- [ ] All foreign key relationships have proper ON DELETE clauses
- [ ] All RLS policies use `auth.jwt()->>'org_id'` pattern
- [ ] All JSONB columns have appropriate defaults
- [ ] All array columns use proper PostgreSQL array syntax
- [ ] All vector columns use proper pgvector syntax
- [ ] All timestamp columns use `WITH TIME ZONE`
- [ ] All unique constraints are properly defined
- [ ] All enum-like check constraints are comprehensive

##### Security Validation

- [ ] Row-Level Security enabled on all tenant-scoped tables
- [ ] RLS policies properly reference JWT organization ID
- [ ] No table allows unrestricted access
- [ ] Sensitive columns (grant_id) marked as encrypted
- [ ] Audit trail properly implemented with audit_logs table
- [ ] No hardcoded secrets in DDL

##### Performance Validation

- [ ] Foreign key indexes created on all foreign key columns
- [ ] org_id indexes created on all tenant tables
- [ ] Query pattern indexes created (status, category, date ranges)
- [ ] TimescaleDB hypertable for time-series data
- [ ] Vector indexes for similarity search
- [ ] GIN indexes for JSONB array columns
- [ ] Composite unique constraints where needed

##### Data Integrity Validation

- [ ] All tables have proper primary key constraints
- [ ] Foreign key relationships maintain referential integrity
- [ ] Check constraints validate data ranges and enums
- [ ] NOT NULL constraints on required fields
- [ ] Default values provided for all columns
- [ ] Soft delete pattern implemented with `deleted_at` columns

#### Migration Notes

##### Version Requirements

- **PostgreSQL**: 15.0 or higher
- **Extensions**:
  - `pgvector` for vector similarity search
  - `pgcrypto` for ULID generation
  - `timescaledb` for time-series optimization

##### Deployment Order

1. Create extensions first
2. Create system tables (organizations, users)
3. Create tenant tables with foreign keys
4. Enable RLS policies
5. Create indexes
6. Create triggers
7. Validate with test data

##### Rollback Strategy

- All DDL is transactional - can be rolled back if needed
- RLS policies can be disabled temporarily for debugging
- Indexes can be dropped and recreated without data loss

---

*Last updated: 2026-04-26*
*Status: Complete - Ready for database initialization*
