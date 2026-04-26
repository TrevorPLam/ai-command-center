# API endpoints

This document describes all REST API endpoints exposed by the FastAPI backend.

## Core service endpoints

| Method | Path      | Description                                                   |
|--------|-----------|---------------------------------------------------------------|
| POST   | /v1/livekit/token | Generate LiveKit token with scoped permissions, TTL 6h       |
| GET    | /v1/collab/token  | Y-Sweet collaboration token with organization verification   |
| GET    | /v1/search        | Unified search using pg_trgm, tsvector, and vector indexes    |
| POST   | /v1/email/send    | Send email via Nylas through FastAPI proxy                   |
| POST   | /v1/mcp/execute   | Execute MCP tool call with SSRF protection                   |
| GET    | /v1/user/export   | GDPR-compliant user data export as SSE stream (JSON)         |

## Workflow endpoints

| Method | Path                    | Description                                                |
|--------|-------------------------|-----------------------------------------------------------|
| POST   | /v1/workflow/execute    | Execute workflow with topological sort and parallel step    |
| GET    | /v1/workflow/status     | Get workflow status (pending, running, waiting, completed) |
| POST   | /v1/workflow/cancel     | Cancel running workflow                                    |
| POST   | /v1/workflow/compensate  | Admin trigger for workflow compensation (rollback)         |

## Agent management endpoints

| Method | Path                      | Description                                      |
|--------|---------------------------|--------------------------------------------------|
| POST   | /v1/agent/definitions     | Create new agent definition                     |
| GET    | /v1/agent/definitions     | List agent definitions                          |
| PUT    | /v1/agent/definitions/{id} | Update agent definition                         |
| DELETE | /v1/agent/definitions/{id} | Delete agent definition                         |
| POST   | /v1/agent/eval             | Run agent evaluation, returns performance scores |
| GET    | /v1/agent/cost             | Get per-organization agent cost breakdown       |
| GET    | /v1/agent-card/{agentId}   | A2A Agent Card discovery endpoint               |
| POST   | /v1/collab/ai-peer         | Internal endpoint for AI collaboration peer    |

## Organization & data endpoints

| Method | Path | Description |
|--------|------|-------------|
| DELETE | /v1/organizations | Delete organization with cascade cleanup |
| POST | /v1/import/entity | Import entity data with SSE progress stream |
| GET | /v1/cost-forecast | Get per-organization cost forecast with projections |
| POST | /v1/rerank | Rerank documents for RAG: accepts {query, docs}, returns reranked |
| GET | /v1/realtime/channels | List active realtime channels |

## Specification & cross-cutting endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | /v1/spec/validate | Validate specification YAML frontmatter, sections, and tier |
| POST | /v1/xct/auth/org-switch | Handle org switch: invalidate caches, reconnect realtime |
| GET | /v1/flowc/workflow/{id}/states | Get workflow state machine and available transitions |
| POST | /v1/apic/codegen | Orval code generation, produces TypeScript files |
| GET | /v1/apic/drift-check | Schemathesis drift check: compare spec vs implementation |
| POST | /v1/evnt/webhook/nylas | Nylas webhook handler with upsert-first, idempotency dedup |
| POST | /v1/testc/security/run | Security test suite: pgTAP RLS, CSP, DOMPurify, SSRF, tokens |
| POST | /v1/testc/ai-eval/run | AI evaluation: accuracy, latency, token usage, tool precision |
| POST | /v1/opsr/incident | Create incident with P0-P3 severity, roles, SOC2 logging |
| POST | /v1/fflg/flag/{id}/kill | Kill switch: revert to 0% in under 5 minutes |
| GET | /v1/cost/forecast | Get cost forecast: projected, confidence interval, trend, action |
| POST | /v1/migr/expand-contract | Execute expand-contract zero-downtime migration step |
| GET | /v1/obs/slo/dashboard | SLO dashboard: TTFT, availability, error budget, burn rate |
| GET | /v1/secm/control-matrix | Security Control Matrix: S1-S21 mapped to controls and evidence |
| POST | /v1/secm/mcp/gateway | MCP security gateway: OAuth, schema allowlist, elicitation |
| POST | /v1/pass/enroll | Passkey enrollment with Supabase Auth MFA, QR code, recovery |

## Guardrails & security endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | /v1/grdl/input/check | Guardrails input layer: PII detection, jailbreak detection |
| POST | /v1/grdl/output/check | Guardrails output layer: hallucination, safety, schema validation |
| POST | /v1/grdl/runtime/enforce | Guardrails runtime: tool authorization and cost threshold |
| POST | /v1/ssrf/validate | SSRF validation: allowlist check, DNS validation, IMDSv2 |
| POST | /v1/priv/opt-out | Privacy opt-out: allow_training flag, data segregation, privacy |

## Integration endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | /v1/stkb/meter | Stripe token billing meter recording |
| POST | /v1/yjs/lifecycle/manage | Yjs lifecycle management: garbage collection, undo, snapshot |
| POST | /v1/nyls/webhook/config | Nylas webhook configuration: upsert-first, async processing |
| POST | /v1/rcll/recurrence/expand | Recurrence expansion: RFC5545 compliant with DST handling |

---

## OpenAPI 3.1 Schema

The complete OpenAPI 3.1 schema is maintained in a separate file for better maintainability and token efficiency.

- **Schema file**: [34-arch-endpoints-schema.yaml](34-arch-endpoints-schema.yaml)
- **Purpose**: Single source of truth for API contract
- **Usage**: Orval generates TypeScript types, Schemathesis validates implementation

The schema includes:
- Common schemas (Error, ValidationError, PaginationMeta, PaginatedResponse)
- Core service schemas (LiveKit, Collab, Search, Email, MCP)
- Workflow schemas (Execute, Status, Cancel, Compensate)
- Agent management schemas (Definition, Evaluation)
- Guardrails schemas (Input/Output/Runtime checks)
- All endpoint paths with request/response specifications

---

## API Versioning Strategy

### Version Format

All API endpoints are versioned using URL path versioning:

- **Current Version**: `/v1/`
- **Format**: `/v{major}/`

### API Lifecycle

APIs progress through the following lifecycle stages:

| Stage | Description | Stability |
|-------|-------------|-----------|
| **Draft** | Early development, subject to breaking changes without notice | Unstable |
| **Beta** | Feature-complete, testing in production, may have minor changes | Testing |
| **Stable** | Production-ready, backward-compatible changes only | Stable |
| **Deprecated** | No longer recommended, 12-month deprecation period | Maintenance |
| **Sunset** | Removed from service, returns 410 Gone | End-of-life |

### Deprecation Policy

When an API or endpoint is deprecated:

1. **Deprecation Header**: Responses include a `Deprecation` header with the deprecation date
2. **Sunset Header**: Responses include a `Sunset` header with the planned removal date (12 months from deprecation)
3. **Documentation**: Migration guide published in the developer documentation
4. **Communication**: Email notification sent to registered developers
5. **Transition Period**: 12-month window for migration

### OpenAPI Schema Versioning

- **Source of Truth**: OpenAPI 3.1 specification
- **Discriminator**: Version field in the schema identifies API version
- **Code Generation**: Orval generates TypeScript types from the OpenAPI spec
- **Validation**: Schemathesis validates implementation against the specification

### Breaking Changes

Breaking changes result in a major version bump:

- Removing endpoints
- Removing fields from responses
- Changing field types
- Adding required request fields
- Changing authentication requirements

### Non-Breaking Changes

Non-breaking changes do not require version bump:

- Adding new endpoints
- Adding optional fields to requests
- Adding fields to responses
- Expanding enum values
- Relaxing validation rules

### Migration Guides

Every major version change requires a migration guide covering:

- Endpoint mapping (old → new)
- Field mapping and transformations
- Authentication changes
- Code examples for common operations
- Timeline and sunset dates

### Current Version Status

| Version | Status | Sunset Date | Migration Guide |
|---------|--------|-------------|-----------------|
| v1 | Stable | N/A | N/A |
