---
title: "Knowledge Base Index"
owner: "Knowledge Base"
status: "active"
updated: "2026-04-26"
canonical: ""
---

This directory contains atomic knowledge base files extracted from the monolithic 90-REF-KNOWLEDGE.md. Each file focuses on a specific topic with consistent structure: TL;DR, Key Facts, Why It Matters, Sources.

## Topics

### AI and Models

- [ai-models.md](ai-models.md) - AI architecture, memory systems, evaluation gates, cost tracking, prompt caching, observability, privacy controls, model tiering, LangGraph, LangMem, Trustcall, FastGraphRAG

### MCP Security

- [mcp-cves.md](mcp-cves.md) - MCP security vulnerabilities (CVE-2025-49596, CVE-2025-66416, CVE-2025-6514), MCP Security Crisis, MCPSec IETF draft, patching patterns, supply chain controls

### Nylas Integration

- [nylas-webhooks.md](nylas-webhooks.md) - Nylas webhook reliability, two-tier failure model, 72-hour backfill window, grant expiry handling, webhook best practices

### PowerSync

- [powersync-config.md](powersync-config.md) - PowerSync bidirectional sync, YAML sync rules, 50 concurrent connections, LWW conflict resolution, SOC2/HIPAA compliance

### Tauri

- [tauri-capabilities.md](tauri-capabilities.md) - Tauri v2 capabilities, fine-grained per-window access, XSS containment, CI validation, isolation pattern, passkeys, Supabase passkeys gap

### Backend Infrastructure

- [backend.md](backend.md) - JWT bridge, rate limiting, CORS, health endpoint, SSRF protection, DOMPurify sanitization

### Security and Compliance

- [security.md](security.md) - Encryption, RBAC, audit logging, pentesting, SAST/DAST accuracy, remediation SLA, scan frequency, CI performance, GDPR, SOC 2, RLS, MCP guardrails, OWASP Agentic

### Data Infrastructure

- [data.md](data.md) - Redis, Timescale hypertables, Supabase Storage, pgvector vector search, IndexedDB offline store, realtime channels

### Infrastructure

- [infrastructure.md](infrastructure.md) - Terraform, Docker, secrets management, observability stack, CI/CD, Prisma migrations

### Backend Core

- [backend-core.md](backend-core.md) - FastAPI project structure, service-repository pattern, workflow engine, RAG, Google A2A, MCP integration

### Client

- [client.md](client.md) - Tauri v2, Expo SDK 53/54, Tailwind v4 design system, WCAG 2.2 AA accessibility

### Repository

- [repository.md](repository.md) - pnpm catalogs with Turborepo monorepo, OpenAPI codegen, TanStack Query configuration

### Operations

- [operations.md](operations.md) - Incident communication (Better Stack, PagerDuty), feedback loop for AI evaluation, Stripe billing integration

### Sanitization

- [sanitization.md](sanitization.md) - DOMPurify profiles (STRICT, RICH, EMAIL), CVE mitigation, SVG security, email security

### Dependencies

- [dependencies.md](dependencies.md) - LiteLLM supply chain attack, Orval CVEs, React Big Calendar maintenance, Tremor status, rrule library maintenance

### Technology Updates

- [technology-updates.md](technology-updates.md) - React 20, TypeScript 6.0/7.0, Prisma Next, Vercel Edge Functions, Deno 2.0, OTel GenAI, Temporal, Google A2A v1, Supabase Edge Functions

### Webhooks

- [webhooks.md](webhooks.md) - Svix integration patterns, acknowledge-first pattern, queue selection, Resend inbound webhooks

### Errata

- [_errata.md](_errata.md) - Corrections for "TASK INFORMATION INCORRECT" notes from original knowledge base
