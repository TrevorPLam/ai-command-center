---
title: "Data Infrastructure"
owner: "Data Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---

## TL;DR

Upstash Redis for rate limiting and semantic cache, Timescale hypertables for time-series data, Supabase Storage with S3 versioning, pgvector HNSW for vector search, IndexedDB offline store with tombstone pattern, Supabase Broadcast vs PgChanges for realtime channels.

## Key Facts

### Redis

**Redis**: Upstash Redis

- Rate limiting
- Semantic cache for AI
- Hot settings storage
- Prefix caching
- Flag cohorts
- In-memory cache storage

### TimeSeries

**TimeSeries**: Timescale hypertables

- Tables: transactions, ai_cost_log, slo_metrics
- Continuous aggregates
- Cost forecasting

### Object Storage

**ObjectStorage**: Supabase Storage + S3 versioning

- Weekly sync
- Point-in-time recovery manual sync
- Yjs snapshot storage

### Vector Search

**VectorSearch**: pgvector HNSW

- Parameters: m=16, ef_c=200, ef_s=40
- pg_trgm for text search
- Hybrid RRF (k=60) + cross-encoder rerank
- RLS at database level

### Offline Store

**OfflineStore**: IndexedDB outbox pattern

- Tombstone pattern (deleted_at nullable int ms)
- ULID for unique identifiers
- Incremental Clock = actor_id + monotonic
- Last-Writer-Wins via update_at timestamp

### Realtime Channels

**RealtimeChannels**: Channel comparison

- Supabase Broadcast (ephemeral, 256KB-3MB)
- Supabase PgChanges (durable WAL, 1MB)
- Channel pattern: org:{orgId}:{table}
- Memory alert at 40MB
- Platform: 100 channels, 20 self-hosted

## Why It Matters

- Redis provides low-latency caching and rate limiting
- Timescale enables efficient time-series queries and aggregation
- Vector search enables semantic search and RAG
- Offline store ensures app functionality without network
- Realtime channels enable collaborative features

## Sources

- Upstash Redis documentation
- TimescaleDB documentation
- pgvector documentation
- Supabase realtime documentation
