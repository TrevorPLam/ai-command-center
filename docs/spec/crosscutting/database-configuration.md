---
id: arch.database-configuration
title: Database Configuration
type: architecture
compressed: 'pgvector HNSW: m=16,ef_construction=64
Audit triggers: on sensitive tables (organizations,user_roles,connected_accounts)
Migration pattern: add nullable→backfill→NOT NULL
Frontend access: @supabase/supabase-js only
Backend access: SQLAlchemy+SET LOCAL request.jwt.claims for RLS
RLS policies: use auth.jwt()->>'user_role' and org_id custom claims'
Audit triggers: on sensitive tables (organizations,user_roles,connected_accounts)
Migration pattern: add nullable→backfill→NOT NULL
Frontend access: '@supabase/supabase-js only'
Backend access: SQLAlchemy+SET LOCAL request.jwt.claims for RLS
RLS policies: 'use auth.jwt()->>'user_role' and org_id custom claims''
last_updated: '2026-04-24T23:37:09.427478+00:00'
---

# Database Configuration

pgvector HNSW: m=16,ef_construction=64
Audit triggers: on sensitive tables (organizations,user_roles,connected_accounts)
Migration pattern: add nullable→backfill→NOT NULL
Frontend access: @supabase/supabase-js only
Backend access: SQLAlchemy+SET LOCAL request.jwt.claims for RLS
RLS policies: use auth.jwt()->>'user_role' and org_id custom claims
