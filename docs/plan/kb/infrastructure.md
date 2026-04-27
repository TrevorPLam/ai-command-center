---
title: "Infrastructure"
owner: "DevOps"
status: "active"
updated: "2026-04-26"
canonical: ""
---

## TL;DR

Terraform for Vercel, Fly.io, Supabase, Upstash with TF Cloud state, Docker for local dev with hot-reload, Doppler/Vault for secrets, Sentry/PostHog/OTel for observability, GitHub Actions with pnpm/turbo, SQLModel migrations with drift detection.

## Key Facts

### Terraform

**Terraform**: as Code

- Targets: Vercel, Fly.io, Supabase, Upstash
- State: Terraform Cloud
- PITR management
- SOC2 evidence pipeline

### Docker

**Docker**: Local development

- supabase start + FastAPI, Redis, MinIO
- Hot-reload enabled
- MCP sandbox
- ClamAV daemon

### Secrets

**Secrets**: Secrets management

- Doppler / Vault
- No .env files in images
- JWT keys, Supabase keys, MCP OAuth secrets in Vault

### Observability Stack

**ObsStack**: Monitoring and observability

- Sentry, PostHog, OTel
- Fly.io → Loki
- Metrics: AI tokens, cache hit, SLO breach rate
- OTel 1.40 GenAI semantic conventions

### CI/CD

**CI**: GitHub Actions

- pnpm, Turbo
- Affected-only builds
- Remote cache
- Supabase migrations
- SQLModel RLS
- AI evaluation gate

### SQLModel Migrations

**SQLModelMig**: Database migrations

- Alembic for schema management
- migrate deploy to production
- Drift check in CI
- RLS versioning
- 6-step zero-downtime rename

## Why It Matters

- Terraform provides infrastructure as code with state management
- Docker enables consistent local development environment
- Centralized secrets management prevents credential leakage
- Observability stack enables debugging and performance monitoring
- CI/CD automation ensures reliable deployments
- SQLModel migrations provide controlled database schema changes

## Sources

- Terraform documentation
- Docker documentation
- Doppler/Vault documentation
- Sentry/PostHog/OTel documentation
- GitHub Actions documentation
- SQLModel documentation
