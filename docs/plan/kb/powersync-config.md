---
title: "PowerSync Configuration"
owner: "Backend Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---

## TL;DR

PowerSync bidirectional sync (SQLite client, Postgres server), YAML sync rules per orgId, 50 concurrent connections free tier, LWW conflict resolution, SOC2 Type 2 audited, HIPAA compliant. Phase 2 offline strategy.

## Key Facts

### PowerSync Architecture

**PWRSYNC_ARCH**: SQLite client with Postgres server

- YAML sync rules (legacy)
- Sync Streams (Beta recommended)
- 50 concurrent connections free tier
- SOC2 Type 2 audited, HIPAA compliant (Pro/Team/Enterprise tiers)

### PowerSync Bucket Configuration

**PowerSync_Bucket**: YAML rules per orgId (JWT claim)

- 50 concurrent connections free tier
- Conflict resolution: Last-Writer-Wins (LWW)

### Offline Strategy

**OFFLINE_SYNC**: MVP and Phase 2 approach

- MVP: tombstone + ULID + IC outbox
- Phase 2: PowerSync bidirectional (SQLite/Postgres), SOC2/HIPAA, sync rules YAML
- Note: cr-sqlite unmaintained, Replicache in maintenance mode

## Why It Matters

- PowerSync enables offline-first architecture with bidirectional sync
- YAML sync rules per orgId provide tenant isolation
- SOC2/HIPAA compliance required for regulated industries
- LWW conflict resolution provides predictable merge behavior
- Free tier limited to 50 concurrent connections

## Sources

- PowerSync official documentation
- PowerSync pricing and compliance information
