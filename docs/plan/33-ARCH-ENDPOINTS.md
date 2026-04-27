---
title: "API Overview"
owner: "Backend Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---

This document provides a high-level overview of the REST API exposed by the FastAPI backend. For detailed endpoint specifications, see the [OpenAPI schema](34-arch-endpoints-schema.yaml).

## API Domain Groups

The API is organized into the following domain groups:

- **Core services**: LiveKit token generation, Y-Sweet collaboration, unified search, email delivery, MCP tool execution, and GDPR-compliant user data export
- **Workflow**: Workflow execution, status tracking, cancellation, and compensation (rollback) operations
- **Agent management**: Agent definition CRUD operations, evaluation, cost tracking, A2A discovery, and AI collaboration
- **Organization & data**: Organization lifecycle, entity import, cost forecasting, RAG reranking, and realtime channel management
- **Specification & cross-cutting**: Specification validation, authentication flows, workflow state machines, code generation, drift detection, webhook handlers, security testing, AI evaluation, incident management, feature flags, cost forecasting, database migrations, SLO monitoring, security controls, MCP gateway, and passkey enrollment
- **Guardrails & security**: Input/output validation, runtime enforcement, SSRF protection, and privacy opt-out
- **Integration**: Stripe billing, Yjs lifecycle, Nylas webhooks, and recurrence expansion

## OpenAPI Schema

The [OpenAPI 3.1 schema](34-arch-endpoints-schema.yaml) is the single source of truth for all API specifications. It includes:

- Common schemas (Error, ValidationError, PaginationMeta, PaginatedResponse)
- All endpoint paths with request/response specifications
- Domain-specific schemas for each API group

The schema is used by:
- **Orval**: Generates TypeScript types and API clients
- **Schemathesis**: Validates implementation against specification in CI

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
| v1      | Stable | N/A         | N/A             |
