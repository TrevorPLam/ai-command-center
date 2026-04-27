---
title: "Data Services"
owner: "Data Platform"
status: "active"
updated: "2026-04-26"
canonical: ""
---

Realtime, offline sync, recurrence, search, and data processing services.

---

## Services

### Realtime Service

#### CrossCuttingRealtime
- **Module**: XCT (Cross-Cutting)
- **Type**: Service
- **Patterns**: `@SSEStream`, `@RealtimeLimits`
- **Rules**: g37, g43 (Global rules 37, 43)
- **Dependencies**: Supabase Realtime, Server-Sent Events
- **Purpose**: Manages real-time data streaming and channel monitoring
- **Features**:
  - Channel authentication and authorization
  - Memory usage monitoring
  - 25 second heartbeat intervals (default)
  - Channel limits enforcement

### Search Service

#### CrossCuttingSearch
- **Module**: XCT (Cross-Cutting)
- **Type**: Service
- **Patterns**: None
- **Rules**: g33 (Global rule 33)
- **Dependencies**: nuqs, useInfiniteQuery
- **Purpose**: Provides unified search functionality across the application
- **Features**:
  - 300ms debounce on search input
  - 200ms hover prefetch for related data
  - URL state synchronization
  - Infinite scroll support

### Offline Service

#### CrossCuttingOffline
- **Module**: XCT (Cross-Cutting)
- **Type**: Service
- **Patterns**: `@OfflineFirst`
- **Rules**: B5 (Backend rule 5)
- **Dependencies**: IndexedDB, ULID
- **Purpose**: Manages offline-first data synchronization
- **Features**:
  - Outbox pattern for queuing operations
  - Idempotency key generation
  - Conflict resolution strategies
  - Tombstone pattern for soft deletes

### API Contract Generation

#### APIContractGen
- **Module**: APIC (API Contract)
- **Type**: Utility
- **Patterns**: None
- **Rules**: OAPI_01 (OpenAPI rule 1)
- **Dependencies**: FastAPI, Orval, Schemathesis
- **Purpose**: Generates TypeScript types and utilities from OpenAPI specifications
- **Features**:
  - OpenAPI 3.1 to TypeScript type generation
  - React Query hooks generation
  - MSW (Mock Service Worker) handlers
  - CI drift detection and blocking

### Resend Email Integration

#### ResendEmailIntegration
- **Module**: EMAIL (Email Service)
- **Type**: Service
- **Patterns**: None
- **Dependencies**: Resend API, Webhook Ingester
- **Purpose**: Manages transactional email delivery with webhook reliability
- **Features**:
  - Automatic retries with exponential backoff (immediately, 5s, 5min, 30min, 2hr, 5hr, 10hr, 10hr)
  - Idempotency via svix-id header to prevent duplicate processing
  - Manual replays available via dashboard for failed deliveries
  - Event granularity: distinct events per recipient (improved Jan 22, 2026)
  - Status monitoring via public status page (resend-status.com) with incident history

### Nylas Webhook Handler

#### NylasWebhookHandler
- **Module**: NYLS (Nylas v3)
- **Type**: Service
- **Patterns**: `@NylasV3`
- **Rules**: S3 (Security rule 3)
- **Dependencies**: Nylas v3, queue system
- **Purpose**: Processes incoming Nylas webhooks
- **Features**:
  - Upsert-first strategy (create or update)
  - 10-second acknowledgment timeout
  - Async queue processing
  - Sync policy enforcement

### Offline Sync Engine

#### OfflineSyncEngine
- **Module**: CRDB (Offline-First)
- **Type**: Service
- **Patterns**: `@OfflineFirst`
- **Rules**: B5 (Backend rule 5)
- **Dependencies**: cr-sqlite vs outbox pattern
- **Purpose**: Synchronizes data between client and server
- **Features**:
  - Tombstone pattern for deleted items
  - ULID primary keys
  - Conflict resolution mechanisms
  - Bidirectional sync support

### Realtime Channel Monitor

#### RealtimeChannelMonitor
- **Module**: RLMT (Realtime Limits)
- **Type**: Service
- **Patterns**: `@RealtimeLimits`
- **Rules**: g37, g43 (Global rules 37, 43)
- **Dependencies**: Supabase Realtime
- **Purpose**: Monitors and enforces realtime channel limits
- **Features**:
  - 100 channel ceiling per connection
  - 200 concurrent peak connections (Free), 500 (Pro), $10/1,000 additional
  - Payload size monitoring
  - Memory usage alerts

### Recurrence Engine Service

#### RecurrenceEngineService
- **Module**: RCLL (Recurrence Engine)
- **Type**: Service
- **Patterns**: `@Recurring`
- **Rules**: B-015 (Backend rule 15)
- **Dependencies**: `@martinhipp/rrule`, Temporal adapter
- **Purpose**: Handles recurring event and task scheduling
- **Features**:
  - DST-aware wall-clock time handling
  - Three edit modes (single, following, all)
  - Exception storage and management
  - RFC5545 compliance

### Yjs Lifecycle Manager

#### YjsLifecycleManager
- **Module**: YJS (Yjs Lifecycle)
- **Type**: Service
- **Patterns**: `@YjsLifecycle`
- **Rules**: YSW_01, YSW_02 (Y-Sweet rules 1, 2)
- **Dependencies**: Yjs, Y-Sweet
- **Purpose**: Manages collaborative document lifecycle
- **Features**:
  - Garbage collection enabled
  - Undo stack truncation (last 5 snapshots)
  - Document versioning through snapshots
  - 50MB document size limit
  - Compaction triggering
