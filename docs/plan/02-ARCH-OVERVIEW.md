# Architecture overview

This document provides a high-level architectural view of the AI Command Center platform using the C4 model, detailing system context, container level, deployment environments, data flow, security architecture, authentication & authorization, infrastructure & SLAs, third-party integrations, auto-scaling, and multi-region architecture.

---

## Architecture rules

These define how services interact, which libraries to use, and development boundaries.

### Backend / API
- (HARD) All AI calls must go through the LiteLLM proxy.
- (HARD) Prisma client never runs in the browser.
- (HARD) Nylas API access is only from FastAPI.
- (HARD) Vercel Edge Functions cannot connect to a database directly; use Vercel Serverless (300s) with Neon serverless driver, or route through FastAPI.
- (HARD) `/v1/*` endpoints follow OpenAPI 3.1 contract; Schemathesis blocks merge on drift.
- (HARD) PostgreSQL Row‑Level Security (RLS) is enabled on all tables that contain tenant data.
- (MED) Supabase Realtime channels are limited to 100 total connections and 20 per user; memory alert at 40 MB per channel.

### Frontend
- (HARD) Vite SPA only; no Next.js (ADR_001).
- (HARD) Zustand v5 for global state (ADR_003).
- (HARD) react‑big‑calendar pinned to ^1.19.4 for React 19 compatibility.
- (HARD) dnd‑kit is the primary DnD library; no migration to PragmaticDnD (ADR_085).
- (HARD) `react-helmet-async` for document head.
- (HARD) Use `Temporal.ZonedDateTime` for all calendar events (never `PlainDateTime`); rschedule + @rschedule/temporal‑date‑adapter replaces rrule.js on the frontend (ADR_109).
- (HARD) Tremor v3.18.x for charting (ADR_105).
- (HARD) OKLCH‑based design tokens; no hardcoded colours.

### Collaboration & real‑time
- (HARD) Y‑Sweet self‑hosted (Jamsocket shutdown); Docker deployment, 50 MB document limit, GC enabled, undo truncated to last 5 snapshots.
- (HARD) LiveKit Agents v2.0 only; semantic turn detection mandatory.
- (MED) Yjs collaboration is opt‑in per document; disconnect cleanup ensures channel unsubscription.

### Data & offline
- (HARD) Offline‑first pattern: soft deletes via `deleted_at` column (nullable millisecond timestamp); all primary keys are ULIDs.
- (HARD) Every asynchronous operation is idempotent: key = `actor_id` + monotonic counter.
- (HARD) PowerSync is the primary offline sync mechanism (Phase 2); bucket YAML rules per orgId.
- (HARD) Supabase Realtime payload caps: Broadcast max 256 KB – 3 MB, Postgres Changes max 1 MB.

### CI / tooling
- (HARD) Orval ≥8.2.0; generate TypeScript types from OpenAPI; never run on untrusted specs.
- (HARD) LiteLLM ≥1.83.7 with cosign verification.
- (HARD) Grype (not Trivy) for Docker scanning; scanners isolated from CI credential store.
- (HARD) TypeScript `tsc --erasableSyntaxOnly --noEmit` gate in CI; ban TypeScript enums.
- (HARD) MSW handlers are generated from the OpenAPI spec via `openapi-backend` for testing.

---

## 1. System context (C1)

The system interacts with multiple external actors and services:

- **Users**: Access the platform via browser and mobile applications
- **External APIs**: LLM providers (Claude, OpenAI, Gemini), Stripe for billing, Nylas for email
- **Supabase**: Provides database and real-time infrastructure

## 2. Container level (C2)

The platform consists of these high-level containers:

| Container | Technology | Purpose |
| --- | --- | --- |
| Web Application | Vite SPA | React frontend with TypeScript |
| API Backend | FastAPI | Python backend handling business logic |
| Primary Database | Supabase PostgreSQL | Main application data with RLS |
| Time-Series DB | TimescaleDB | AI cost tracking and analytics |
| Cache | Redis (Upstash) | Rate limiting and semantic caching |
| Real-time Communication | LiveKit | Video conferencing and voice AI |

## 3. Deployment environments

### 3.1 Production

| Service | Provider | Configuration | Scaling Strategy |
| --- | --- | --- | --- |
| FastAPI Backend | Fly.io | Machines v2, Python 3.12, 2 shared-cpu-1x HA | 1-10 VMs, zero-downtime rolling |
| Web Application | Vercel | Vite SPA, Edge Functions, CDN, Edge Middleware | Global CDN |
| Primary Database | Supabase | Postgres 15, RLS, pgBouncer pooling | Managed HA |
| Real-time | Supabase | WebSockets, 100 channels/connection, 200 free/500 Pro | Auto-scale |
| Time-Series | TimescaleDB | Continuous aggregates, real-time materialization | Managed |
| Cache | Upstash Redis | Rate limiting, semantic cache, session storage | Managed cluster |
| Conferencing | LiveKit | STT/LLM/TTS pipeline, WebRTC, turn detection | Managed SFU |
| Secrets | HashiCorp Vault | JWT 90d, Stripe 180d, MCP OAuth 90d, LLM keys 30d | Auto-unseal |
| Environment Variables | Doppler | Per-env (dev/staging/prod), GitHub Actions | Geo-redundant |

### 3.2 Staging

| Service | Provider | Configuration | Scaling Strategy |
| --- | --- | --- | --- |
| FastAPI | Fly.io | Single shared-cpu-1x VM, manual deployment | No auto-scaling |
| Web App | Vercel | Preview deployments, branch-based builds | - |
| Database | Supabase | Separate project with RLS test data | - |

### 3.3 Development

| Service | Provider | Configuration | Scaling Strategy |
| --- | --- | --- | --- |
| FastAPI | Docker Compose | Local development with mock LLM services | - |
| Web App | Vite Dev Server | Hot module replacement, local development | - |
| Database | Local Supabase | Docker Compose, local instance | - |

## 4. Data flow architecture

The following table describes how data flows between system components:

| Source | Destination | Protocol | Security Controls | Purpose |
| --- | --- | --- | --- | --- |
| Browser | FastAPI | HTTPS | JWT+org_id | `/v1/*` API endpoints |
| FastAPI | Supabase | TCP | Internal network, RLS enforced | Database queries (Prisma) |
| FastAPI | LiteLLM | HTTPS | API key rot, cosign | LLM routing (Claude, GPT, Gemini) |
| FastAPI | MCP Server | HTTP | MCPSec L2, OAuth tool auth | SSRF allowlist, nonce replay protection |
| FastAPI | Stripe | HTTPS | API key 180d rotation | Billing (@stripe/ai-sdk) |
| FastAPI | Nylas | HTTPS | OAuth2, grant.expired webhook | Email sync (upsert-first, 10s ack) |
| FastAPI | LiveKit | WebSocket | Token TTL 6h, RBAC scoped | Voice pipeline (STT/LLM/TTS) |
| Supabase | Browser | WebSocket | JWT auth, org-scoped channels | Realtime CDC updates |
| FastAPI | TimescaleDB | TCP | Internal network | AI cost logging hypertable |
| FastAPI | Upstash | Redis | TLS encrypted | Rate limiting, semantic cache |
| FastAPI | Sentry | HTTPS | DSN via env var | Error tracking, session replays |
| FastAPI | PostHog | HTTPS | API key authentication | Product analytics, allow_training flag |
| FastAPI | OTel Collector | HTTPS | OTLP protocol | GenAI traces, PII redaction |

## 5. Security architecture

The platform implements defense in depth with 12 security layers covering network isolation, application security, API protection, authentication, data access, supply chain security, MCP security, AI guardrails, secret management, compliance, privacy, and audit logging.

For detailed specifications of each security layer, including mechanisms, test methods, and ownership, see [02-ARCH-SECURITY-DETAILS.md](02-ARCH-SECURITY-DETAILS.md).

## 6. Authentication & authorization

### 6.1 Login

- **Provider**: Supabase Auth with email/password
- **Token Hook**: `custom_access_token_hook` embeds `org_id` and `role` in JWT
- **Security**: JWT tokens are httpOnly, not stored in localStorage

### 6.2 Multi-factor authentication (MFA)

#### 6.2.1 TOTP

- **Implementation**: Spectrum TOTP
- **Backup**: Recovery codes provided on enrollment

#### 6.2.2 WebAuthn passkeys

- **Implementation**: SimpleWebAuthn (ADR107)
- **Storage**: `webauthn_challenges` table
- **Flow**: RPC-based authentication flow
- **Features**:
  - Cross-device QR code support
  - Recovery codes for account recovery

### 6.3 Organization switching

- **Mechanism**: `supabase.auth.refreshSession()`
- **Cleanup**: Query client cache cleared
- **Reconnection**: Realtime reconnection triggered
- **Rule**: AUTHHOOK01 compliance

### 6.4 Nylas authentication

- **Protocol**: OAuth2 grant flow
- **Expiration**: `grant.expired` webhook triggers re-authentication
- **Window**: Must complete re-auth within 72 hours
- **Monitoring**: Daily cron job checks for expiring grants

## 7. Infrastructure & SLAs

| Component | Provider | SLA | Backup Strategy | Disaster Recovery | Monitoring |
| --- | --- | --- | --- | --- | --- |
| FastAPI | Fly.io | 99.9% | Daily pg_dump, hourly WAL | Region failover | Sentry + Loki |
| Web App | Vercel | 99.9% | Git versioning | Global CDN | Vercel Analytics |
| Supabase DB | Supabase | 99.9% | PITR, 7-day retention | Cross-region replica | Supabase Dashboard |
| TimescaleDB | Supabase | 99.9% | Continuous aggregates backup | Read replica | Supabase Dashboard |
| Redis | Upstash | 99.9% | Persistence enabled, AOF | Multi-AZ | Upstash Dashboard |
| LiveKit | LiveKit | 99.9% | Recording retention | Region failover | LiveKit Dashboard |
| Vault | HashiCorp | 99.9% | Auto-unseal, RAID storage | Disaster recovery | Vault UI |
| Doppler | Doppler | 99.9% | Secret versioning | Geo-redundant | Doppler Dashboard |

## 8. Third-party integrations

| Service | Protocol | Authentication | Rate Limit | Retry Policy | Timeout | Circuit Breaker |
| --- | --- | --- | --- | --- | --- | --- |
| LiteLLM | HTTP | API key | 100 req/min | Exponential backoff 3x | 30s | Opens after 5 failures |
| Nylas | HTTP | OAuth2 | 100 req/min | Linear backoff 1s | 10s | Opens after 3 failures |
| Stripe | HTTP | API key | 100 req/min | Exponential backoff 2x | 30s | Opens after 5 failures |
| LiveKit | WebSocket | Token TTL 6h | - | - | - | - |
| Supabase Realtime | WebSocket | JWT | 100 channels per connection | Reconnect: 1s, 2s, 4s, 8s, max 30s | - | - |
| Upstash Redis | TCP | TLS | 10,000 ops/sec | - | 5s | Opens after 10 failures |
| OTel Collector | HTTPS | OTLP | - | Exponential backoff 2x | 10s | Opens after 3 failures |
| Sentry | HTTPS | DSN | - | - | 5s | Opens after 5 failures |
| PostHog | HTTPS | API key authentication | 1000 events/min | Linear backoff 500ms | 10s | Opens after 3 failures |

## 9. Auto-scaling configuration

| Service | Metric | Threshold | Scale Up Action | Scale Down Action | Max | Min |
| --- | --- | --- | --- | --- | --- | --- |
| FastAPI | CPU | 70% | Add 1 VM | Remove 1 VM | 10 | 1 |
| FastAPI | Memory | 80% | Add 1 VM | Remove 1 VM | 10 | 1 |
| Supabase DB | Connections | 80% | Add read replica | - | - | - |
| Supabase Realtime | Channels | 100/connection | Add capacity | - | - | - |
| Upstash Redis | Memory | 70% | Scale cluster | - | - | - |
| LiveKit | Participants | 1000 | Add SFU | Remove SFU | - | - |

## 10. Multi-region architecture

### 10.1 FastAPI active-passive deployment pattern

**Architecture overview:**

- Active: prod traffic
- Passive: pre-deployed infra, data replication
- Failover: active→passive during disaster
- Data: live in passive for tight RTO/RPO

**Implementation pattern:**

```text
[Active Region]          [Passive Region]
     FastAPI VMs  ←→  Replication  ←→  FastAPI VMs (standby)
         ↓                              ↓
   Load Balancer                    Load Balancer (standby)
         ↓                              ↓
   User Traffic                     (ready to accept traffic)
```

**Failover flow:**

1. Health check detects active region failure
2. DNS/traffic routing switches to passive region (seconds to minutes)
3. Passive region infrastructure accepts traffic immediately
4. Data replication ensures minimal data loss (RPO near 0)

**Key considerations:**

- Infra: fully/partially deployed in passive before failover
- Data replication: active to avoid backup restoration
- Network failover: 2-5s
- App failover: 1-3min
- Total RTO: ≤5min with proper config

### 10.2 Database replication

#### 10.2.1 Supabase cross-region replication

**Implementation:**

- Streaming replication: WAL changes stream directly from primary to replica
- File-based log shipping: WAL files buffered and sent as fallback
- Hybrid approach: Streaming for low lag, file-based for resilience
- Replication is asynchronous (transactions not blocked on primary)

**Latency characteristics:**

- Replication lag varies based on geographic distance and network conditions
- CAP theorem trade-off: consistency vs availability during network partitions
- Typical cross-region lag: 100-500ms depending on regions
- Monitoring available via Supabase Dashboard

**Failover considerations:**

- Automatic failover currently Enterprise-only (planned for all paid plans)
- Read replicas are read-only only (select operations)
- Promotion to primary requires manual intervention or Enterprise auto-failover
- Geo-based load balancing in development (round-robin currently used)

**Recovery time objective (RTO):**

- PITR restoration time is variable and depends on:
  - Time since last full backup (weekly)
  - WAL activity volume since last backup
  - Database size (less critical than WAL activity)
- 1-hour RTO achievable for cross-region replica promotion with proper preparation
- Faster recovery possible with active-passive setup and pre-warmed infrastructure

## 11. High availability & disaster recovery

For detailed disaster recovery procedures, runbooks, and incident response, see [08-OPS-MANUAL.md](08-OPS-MANUAL.md).

## 12. SOC2 automation

For detailed SOC2 automation implementation, evidence collection pipelines, and control mapping, see [02-ARCH-SECURITY-DETAILS.md](02-ARCH-SECURITY-DETAILS.md).

## 13. Container scanning

For detailed container scanning implementation, Grype vs Trivy comparison, and CI integration patterns, see [02-ARCH-SECURITY-DETAILS.md](02-ARCH-SECURITY-DETAILS.md).

## 14. Service deployment details

For detailed deployment configurations for Y-Sweet and LiveKit, see [02-ARCH-DEPLOYMENT.md](02-ARCH-DEPLOYMENT.md).

---

## 15. Technology stack by domain

This section provides the detailed technology choices for each domain, referenced from the strategic blueprint [00-STRAT-BLUEPRINT.md](00-STRAT-BLUEPRINT.md).

### Domain A: platform foundation & developer experience

#### Modern tech stack & monorepo

- React 19.2.5 with React Compiler (separate beta package)
- Vite 8 with Rolldown (10-30x build speed improvement)
- Tailwind CSS v4 with `@theme` tokens
- TypeScript 7.0 `tsgo` (10x typecheck improvement)
- Zustand v5 for state management
- Turborepo 2.x tasks-based pipelines with topological ordering

#### CI/CD, testing & quality gates

- Playwright AI test agents (Planner → Generator → Healer pipeline)
- Schemathesis API validation, pgtap RLS testing, automated security gates
- `.cursorrules` / `.windsurfrules` for strict architectural patterns

#### Infrastructure & deployment

- Fly.io Machines v2, Python 3.12, auto-scaling 1-10 VMs, zero-downtime rolling deployments
- Doppler for environment variables, Vault for long-lived secrets
- TimescaleDB v2.13+ for time-series, PgBouncer connection pooling
- Vercel Edge Functions with Neon serverless driver, CDN optimization

#### Observability & operations

- Sentry error tracking with session replays, PostHog event analytics
- OpenTelemetry v1.40.0 with `gen_ai` namespace for agentic system observability
- DataPrepper for PII redaction, Loki aggregation with structured labels
- Core Web Vitals monitoring (INP ≤200ms), bundle analysis, lazy loading, virtualization

### Domain B: data, sync & knowledge

#### Offline-first sync

- PowerSync + TanStack DB 0.6: Bidirectional SQLite↔Postgres sync with query-driven data loading
- Automatic conflict resolution and queue management for offline changes

#### Real-time & time-series

- CDC with millisecond updates
- TimescaleDB continuous aggregates with `materialized_only=false` for real-time enforcement

#### Vector & graph intelligence

- pgvectorscale 0.4.0 with StreamingDiskANN index: 28x lower p95 latency, 16x higher throughput vs. Pinecone on 50M embeddings
- HNSW `ef_construction=64` baseline, 500K vector threshold
- GraphRAG & Multimodal: Knowledge graph entity mapping, late chunking for unified semantic processing
- Semantic Layer: Ontology and knowledge graph integration for shared vocabulary across agents

### Domain C: AI core & agent architecture

#### Multi-provider AI gateway

- Dynamic routing between Claude Opus 4.7 (SWE-bench Verified 87.6%, GPQA Diamond 94.2%, Finance Agent 64.4%), Claude Sonnet 4.6 (default), Gemini 3.1 Pro (multimodal fallback), GPT-5.5 (restricted from production agentic use due to 86% hallucination rate)
- Routing based on task complexity, cost, and hallucination risk assessment
- Reasoning token budgeting with effort control APIs (none/low/medium/high/xhigh)
- Model distillation pipelines for 5-30x cost reduction on specialized tasks

#### Model cost optimization & tiering

- Token budgeting with Opus 4.7 tokenizer (1.0–1.35× increase depending on content type)
- Model tiering: Opus 4.7 for complex tasks, Sonnet 4.6 as default, Gemini 3.1 Pro for multimodal fallback, GPT-5.5 restricted

#### Edge AI & WebGPU

- Transformers.js and Wasm for local model execution (Phi-4, Gemma-2B) in privacy-sensitive contexts
- Prefix caching for 80% TTFT reduction

#### Agent protocols & identity

- MCP Standardization: Secure Model Context Protocol with SSRF controls, tool allowlisting, schema validation, audit logging
- APS (Agent Passport System) Gateway: IETF draft with Agent Passports (Ed25519), 7-dimension constraint lattice, 3-signature chain, cascade revocation, Bayesian reputation, institutional governance
- AgentROA: Complementary IETF draft adapting RPKI Route Origin Authorization for agent identity verification
- A2A v1.0 Integration: Google's Agent-to-Agent protocol with signed Agent Cards, cryptographic identity attestation, multi-tenant endpoints
- Agent Studio: Definition versioning, trust catalog, RBAC controls, playground environment, evaluation gates

#### Multi-agent orchestration

- LangChain 0.3.x LCEL with LangGraph state machines, hierarchical manager-worker patterns
- Joint reasoning for hallucination reduction

#### AI reliability engineering

- Output Validation & Guardrails: Structured output enforcement with JSON Schema and constrained decoding, hallucination detection using LLM-as-a-judge patterns
- Human-in-the-Loop Architecture: Confidence-score-based approval workflows with configurable thresholds, interrupt handling for long-running tasks
- Production Resilience & Circuit Breakers: Circuit breaker patterns for failing agents, automatic provider failover with health checks, agent versioning with blue-green/canary deployments
- Safe Deployment Patterns: Feature flagging at model and prompt levels, A/B testing frameworks, prompt versioning with instant rollback
- Semantic Layer & Cross-Agent Trust: Ontology-driven shared vocabulary, trust layer with continuous attestation

#### Local model infrastructure

- Serving Stack: Ollama (primary) / llama.cpp (backend). Docker Compose for reproducible environments
- Model Registry: Inventory of supported local models, their capabilities, quantization formats, and hardware requirements
- Quantization Policy: Default GGUF Q4_K_M; migration path to ternary (FairyFuse) when backend matures
- Hardware Abstraction: CPU‑only tier (AVX2, 16GB+), GPU‑accelerated tier (optional), Apple Silicon tier (M2+)
- Fine‑Tuning Pipeline: Phase 2+ via Unsloth (GPU) or LoFT CLI (CPU‑only for small models)
- Distributed Inference: Phase 3+ via Prima.cpp or Mesh LLM for 30‑70B models on commodity clusters

### Domain D: frontend, UX & multimodal interfaces

#### Frontend core

- Real-time JSON to React component rendering, interactive charts and forms
- Optimistic updates with TanStack Query v5
- React Compiler integration: `babel-plugin-react-compiler` beta, `use no memo` carveouts, `useFormState` over `useWatch` for RHF compatibility

#### Real-time collaboration

- Yjs 13.6.21 with LiveKit, canvas-first design patterns
- Thought-trace visibility for agent operations
- Infinite canvas design, real-time co-editing, version control integration, conflict resolution algorithms

#### Multimodal & voice

- Multi-speaker TTS with voice profiles, vision-native workflows with screenshot-to-action, multimodal RAG processing
- LiveKit Agents v1.0.0: Production-ready real-time voice and video AI agents using WebRTC. Handles STT→LLM→TTS pipeline streaming, turn detection, interruption handling, multi-agent handoffs

#### Mobile & accessibility

- Expo SDK 55 with New Architecture, React Native 0.83, `expo-notifications` config plugins, NativeWind v4
- Motion v12 with OKLCH animation, reduced motion support, WCAG 2.2 AA compliance, keyboard navigation

### Domain E: security, compliance & governance

#### API & supply-chain security

- APS Gateway (as defined in Domain C.4)
- Supply chain: LiteLLM ≥1.83.7 with cosign verification, Orval ≥8.2.0 (CVE-2026-25141 mitigation), DOMPurify ≥3.4.0 (CVE-2026-41238 XSS protection)
- Full CSP with nonce strategy, `worker-src` for service workers, `strict-dynamic` scripts, Report-Only in pre-production
- MCP Identity Crisis mitigation: OAuth On-Behalf-Of flows and identity propagation
- MCP Default Configuration Risk mitigation: Tool allowlisting, SSRF controls, and schema validation
- MCP Critical CVEs: CVE-2025-6514 (mcp-remote command injection, CVSS 9.6), CVE-2026-23744 (MCPJam Inspector RCE), CVE-2025-49596 (MCP Inspector RCE)
- CIS MCP Companion Guide: CIS Controls v8.1 Companion Guide for MCP (released April 21, 2026)

#### Identity & audit

- Unique agent IDs with audit trails, service account separation, action attribution
- Immutable WORM logs for all agent decisions, blockchain-style hash chaining, legal defensibility, forensic analysis
- EU AI Act Alignment: Current statutory deadline August 2, 2026 for majority of rules. Proposed Digital Omnibus extension would delay high-risk obligations to December 2, 2027 / August 2, 2028. Articles 9-15 mandate extensive documentation and traceability
- GDPR compliance with consent management, data minimization, right to deletion, privacy by design

#### AI ethics & fairness

- Automated demographic bias detection, fairness metrics dashboard, bias mitigation strategies, regulatory reporting
- Red teaming for prompt injections, jailbreaks, and training-data leakage (aligned with CSA RiskRubric.ai framework)
- OWASP ASI01-ASI10 Complete CVE Mapping (as of April 2026) - see [03-TECH-VALIDATION.md](03-TECH-VALIDATION.md) for detailed CVE references

### Domain F: business strategy & monetization

#### Billing infrastructure

- Stripe Three-Package Architecture: `@stripe/ai-sdk` (metering middleware), `@stripe/token-meter` (bypass), `@stripe/agent-toolkit` (agent actions via function calling)
- AI cost markup configuration, tiered model access, license gates, feature flags

#### Revenue optimization

- Unit economics tracking, churn prediction, expansion revenue identification
- Real-time token cost monitoring, budget enforcement alerts, per-user action economics

#### Product & vertical strategy

- Deep workflow AI for specific industries (Clinical Trial Compliance, Financial Auditing, Legal Research), domain-specific fine-tuning
- Data Flywheel: Human-in-the-loop feedback collection, LoRA adapter training, continuous model improvement

#### Market models & build-vs-buy

- Agentic Enterprise Licensing: All-you-can-eat agentic AI agreements (AELA model), consumption vs. flat fee tensions
- Forward-Deployed Engineering: In-house engineers as necessity for business/industry knowledge
- Decision Velocity Architecture: Decision automation as core metric (speed × accuracy × effectiveness), collapsing decision trees for 5-10x improvements

#### Workflow integration & ecosystem

- Cross-team workflow unification (40-60 SaaS tool integration), event-driven architecture with two-way API syncs
- Composable Architecture (MACH Alliance): Microservices, API-first, Cloud-native, Headless principles. MACH AI Exchange launched April 2025
- Data-as-a-Service: Monetizable clean, structured, versioned data
- Third-party integrations, API marketplace, developer community building
