# API Endpoints

This document describes all REST API endpoints exposed by the FastAPI backend.

## Core Service Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | /v1/livekit/token | Generate LiveKit token with scoped permissions, TTL 6 hours |
| GET | /v1/collab/token | Y-Sweet collaboration token with organization verification |
| GET | /v1/search | Unified search using pg_trgm, tsvector, and vector indexes |
| POST | /v1/email/send | Send email via Nylas through FastAPI proxy |
| POST | /v1/mcp/execute | Execute MCP tool call with SSRF protection |
| GET | /v1/user/export | GDPR-compliant user data export as SSE stream (JSON) |

## Workflow Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | /v1/workflow/execute | Execute workflow with topological sort and parallel step execution |
| GET | /v1/workflow/status | Get workflow status (pending, running, waiting, completed) |
| POST | /v1/workflow/cancel | Cancel running workflow |
| POST | /v1/workflow/compensate | Admin trigger for workflow compensation (rollback) |

## Agent Management Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | /v1/agent/definitions | Create new agent definition |
| GET | /v1/agent/definitions | List agent definitions |
| PUT | /v1/agent/definitions/{id} | Update agent definition |
| DELETE | /v1/agent/definitions/{id} | Delete agent definition |
| POST | /v1/agent/eval | Run agent evaluation, returns performance scores |
| GET | /v1/agent/cost | Get per-organization agent cost breakdown |
| GET | /v1/agent-card/{agentId} | A2A Agent Card discovery endpoint |
| POST | /v1/collab/ai-peer | Internal endpoint for AI collaboration peer |

## Organization & Data Endpoints

| Method | Path | Description |
|--------|------|-------------|
| DELETE | /v1/organizations | Delete organization with cascade cleanup |
| POST | /v1/import/entity | Import entity data with SSE progress stream |
| GET | /v1/cost-forecast | Get per-organization cost forecast with projections |
| POST | /v1/rerank | Rerank documents for RAG: accepts {query, docs}, returns reranked results |
| GET | /v1/realtime/channels | List active realtime channels |

## Specification & Cross-Cutting Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | /v1/spec/validate | Validate specification YAML frontmatter, sections, and tier |
| POST | /v1/xct/auth/org-switch | Handle org switch: invalidate caches, reconnect realtime, redirect |
| GET | /v1/flowc/workflow/{id}/states | Get workflow state machine and available transitions |
| POST | /v1/apic/codegen | Orval code generation, produces TypeScript files |
| GET | /v1/apic/drift-check | Schemathesis drift check: compare spec vs implementation |
| POST | /v1/evnt/webhook/nylas | Nylas webhook handler with upsert-first, idempotency dedup, async queue |
| POST | /v1/testc/security/run | Security test suite: pgTAP RLS, CSP, DOMPurify, SSRF, LiveKit tokens |
| POST | /v1/testc/ai-eval/run | AI evaluation: accuracy, latency, token usage, tool precision, hallucination |
| POST | /v1/opsr/incident | Create incident with P0-P3 severity, roles, SOC2 logging |
| POST | /v1/fflg/flag/{id}/kill | Kill switch: revert to 0% in under 5 minutes |
| GET | /v1/cost/forecast | Get cost forecast: projected, confidence interval, trend, recommended action |
| POST | /v1/migr/expand-contract | Execute expand-contract zero-downtime migration step |
| GET | /v1/obs/slo/dashboard | SLO dashboard: TTFT, availability, error budget, burn rate |
| GET | /v1/secm/control-matrix | Security Control Matrix: S1-S21 mapped to controls and evidence |
| POST | /v1/secm/mcp/gateway | MCP security gateway: OAuth, schema allowlist, elicitation |
| POST | /v1/pass/enroll | Passkey enrollment with Supabase Auth MFA, QR code, recovery codes |

## Guardrails & Security Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | /v1/grdl/input/check | Guardrails input layer: PII detection, jailbreak detection, toxicity screening |
| POST | /v1/grdl/output/check | Guardrails output layer: hallucination, safety, schema validation |
| POST | /v1/grdl/runtime/enforce | Guardrails runtime: tool authorization and cost threshold enforcement |
| POST | /v1/ssrf/validate | SSRF validation: allowlist check, DNS validation, IMDSv2 |
| POST | /v1/priv/opt-out | Privacy opt-out: allow_training flag, data segregation, differential privacy |

## Integration Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | /v1/stkb/meter | Stripe token billing meter recording |
| POST | /v1/yjs/lifecycle/manage | Yjs lifecycle management: garbage collection, undo, snapshot |
| POST | /v1/nyls/webhook/config | Nylas webhook configuration: upsert-first, async processing, sync policy |
| POST | /v1/rcll/recurrence/expand | Recurrence expansion: RFC5545 compliant with DST handling and edit modes |

---

## OpenAPI 3.1 Schema

```yaml
openapi: 3.1.0
info:
  title: AI Command Center API
  description: Multi-tenant AI command center with real-time collaboration, workflow orchestration, and agent management
  version: 1.0.0
  contact:
    name: API Support
    email: api@example.com
  license:
    name: MIT
    url: https://opensource.org/licenses/MIT

servers:
  - url: https://api.example.com/v1
    description: Production server
  - url: http://localhost:8000/v1
    description: Development server

security:
  - BearerAuth: []
  - OrgHeader: []

components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
    OrgHeader:
      type: apiKey
      in: header
      name: X-Organization-ID

  schemas:
    # Common Schemas
    Error:
      type: object
      properties:
        code:
          type: string
          description: Error code from taxonomy
          example: "VALIDATION_ERROR"
        message:
          type: string
          description: Human-readable error message
          example: "Request validation failed"
        details:
          type: object
          description: Additional error details
          additionalProperties: true
      required: [code, message]
    
    ValidationError:
      allOf:
        - $ref: '#/components/schemas/Error'
        - type: object
          properties:
            details:
              type: array
              items:
                type: object
                properties:
                  field:
                    type: string
                  message:
                    type: string
              required: [field, message]
    
    PaginationMeta:
      type: object
      properties:
        cursor:
          type: string
          nullable: true
          description: Cursor for next page
        limit:
          type: integer
          minimum: 1
          maximum: 100
          description: Items per page
        total:
          type: integer
          minimum: 0
          description: Total items available
      required: [cursor, limit, total]
    
    PaginatedResponse:
      type: object
      properties:
        data:
          type: array
          items:
            type: object
            description: Varies by endpoint
        error:
          $ref: '#/components/schemas/Error'
          nullable: true
        meta:
          $ref: '#/components/schemas/PaginationMeta'
      required: [data, error, meta]

    # Core Service Schemas
    LiveKitTokenRequest:
      type: object
      properties:
        room_name:
          type: string
          minLength: 1
          maxLength: 100
          description: Room identifier
        permissions:
          type: array
          items:
            type: string
            enum: [join, publish, admin]
          description: Room permissions
        ttl_minutes:
          type: integer
          minimum: 1
          maximum: 1440
          default: 360
          description: Token TTL in minutes
      required: [room_name, permissions]
    
    LiveKitTokenResponse:
      type: object
      properties:
        token:
          type: string
          description: JWT token for LiveKit room
        url:
          type: string
          format: uri
          description: LiveKit server URL
        expires_at:
          type: string
          format: date-time
          description: Token expiration timestamp
      required: [token, url, expires_at]
    
    CollabTokenResponse:
      type: object
      properties:
        token:
          type: string
          description: Y-Sweet collaboration token
        document_id:
          type: string
          description: Document identifier
        expires_at:
          type: string
          format: date-time
          description: Token expiration
      required: [token, document_id, expires_at]
    
    SearchRequest:
      type: object
      properties:
        query:
          type: string
          minLength: 1
          maxLength: 1000
          description: Search query
        types:
          type: array
          items:
            type: string
            enum: [messages, tasks, events, documents, contacts]
          description: Entity types to search
        limit:
          type: integer
          minimum: 1
          maximum: 100
          default: 20
          description: Maximum results
        cursor:
          type: string
          nullable: true
          description: Pagination cursor
      required: [query]
    
    SearchResult:
      type: object
      properties:
        id:
          type: string
          description: Entity ID
        type:
          type: string
          enum: [message, task, event, document, contact]
          description: Entity type
        title:
          type: string
          description: Result title
        snippet:
          type: string
          description: Highlighted snippet
        score:
          type: number
          minimum: 0
          maximum: 1
          description: Relevance score
        metadata:
          type: object
          additionalProperties: true
          description: Type-specific metadata
      required: [id, type, title, snippet, score]
    
    EmailSendRequest:
      type: object
      properties:
        to:
          type: array
          items:
            type: string
            format: email
          minItems: 1
          maxItems: 50
          description: Recipient emails
        cc:
          type: array
          items:
            type: string
            format: email
          maxItems: 50
          description: CC recipients
        bcc:
          type: array
          items:
            type: string
            format: email
          maxItems: 50
          description: BCC recipients
        subject:
          type: string
          minLength: 1
          maxLength: 200
          description: Email subject
        body:
          type: string
          minLength: 1
          maxLength: 50000
          description: Email body (HTML allowed)
        attachments:
          type: array
          items:
            type: object
            properties:
              filename:
                type: string
              content:
                type: string
                format: byte
                description: Base64 encoded content
              content_type:
                type: string
                description: MIME type
            required: [filename, content, content_type]
          maxItems: 10
          description: File attachments
      required: [to, subject, body]
    
    McpExecuteRequest:
      type: object
      properties:
        tool_name:
          type: string
          minLength: 1
          maxLength: 100
          description: MCP tool name
        parameters:
          type: object
          additionalProperties: true
          description: Tool parameters (varies by tool)
        timeout_seconds:
          type: integer
          minimum: 1
          maximum: 300
          default: 30
          description: Execution timeout
      required: [tool_name, parameters]
    
    McpExecuteResponse:
      type: object
      properties:
        result:
          type: object
          additionalProperties: true
          description: Tool execution result
        execution_time_ms:
          type: integer
          minimum: 0
          description: Execution time in milliseconds
        success:
          type: boolean
          description: Whether execution succeeded
      required: [result, execution_time_ms, success]

    # Workflow Schemas
    WorkflowExecuteRequest:
      type: object
      properties:
        workflow_id:
          type: string
          description: Workflow definition ID
        input_data:
          type: object
          additionalProperties: true
          description: Initial input data for workflow
        options:
          type: object
          properties:
            parallel_execution:
              type: boolean
              default: true
              description: Enable parallel step execution
            timeout_minutes:
              type: integer
              minimum: 1
              maximum: 60
              default: 30
              description: Workflow timeout
      required: [workflow_id]
    
    WorkflowStatusResponse:
      type: object
      properties:
        workflow_id:
          type: string
          description: Workflow execution ID
        status:
          type: string
          enum: [pending, running, waiting, completed, failed, cancelled]
          description: Current status
        started_at:
          type: string
          format: date-time
          description: Start timestamp
        updated_at:
          type: string
          format: date-time
          description: Last update timestamp
        completed_at:
          type: string
          format: date-time
          nullable: true
          description: Completion timestamp
        steps:
          type: array
          items:
            type: object
            properties:
              step_id:
                type: string
              name:
                type: string
              status:
                type: string
                enum: [pending, running, completed, failed, skipped]
              started_at:
                type: string
                format: date-time
              completed_at:
                type: string
                format: date-time
                nullable: true
              output:
                type: object
                additionalProperties: true
                nullable: true
              error:
                $ref: '#/components/schemas/Error'
                nullable: true
            required: [step_id, name, status]
        result:
          type: object
          additionalProperties: true
          nullable: true
          description: Final workflow result
      required: [workflow_id, status, started_at, updated_at, steps]

    # Agent Management Schemas
    AgentDefinition:
      type: object
      properties:
        id:
          type: string
          description: Agent definition ID
        name:
          type: string
          minLength: 1
          maxLength: 100
          description: Agent name
        description:
          type: string
          maxLength: 1000
          description: Agent description
        model:
          type: string
          description: AI model identifier
        system_prompt:
          type: string
          maxLength: 10000
          description: System prompt template
        tools:
          type: array
          items:
            type: string
          description: Available tools
        settings:
          type: object
          additionalProperties: true
          description: Agent-specific settings
        created_at:
          type: string
          format: date-time
        updated_at:
          type: string
          format: date-time
      required: [id, name, description, model, system_prompt, tools]
    
    AgentDefinitionCreate:
      type: object
      properties:
        name:
          type: string
          minLength: 1
          maxLength: 100
        description:
          type: string
          maxLength: 1000
        model:
          type: string
        system_prompt:
          type: string
          maxLength: 10000
        tools:
          type: array
          items:
            type: string
        settings:
          type: object
          additionalProperties: true
      required: [name, description, model, system_prompt, tools]
    
    AgentEvaluationResponse:
      type: object
      properties:
        agent_id:
          type: string
        evaluation_id:
          type: string
        metrics:
          type: object
          properties:
            accuracy:
              type: number
              minimum: 0
              maximum: 1
            latency_ms:
              type: number
              minimum: 0
            token_usage:
              type: integer
              minimum: 0
            tool_precision:
              type: number
              minimum: 0
              maximum: 1
            hallucination_rate:
              type: number
              minimum: 0
              maximum: 1
          required: [accuracy, latency_ms, token_usage, tool_precision, hallucination_rate]
        passed:
          type: boolean
        evaluated_at:
          type: string
          format: date-time
      required: [agent_id, evaluation_id, metrics, passed, evaluated_at]
    
    # Guardrails Schemas
    GuardrailsCheckRequest:
      type: object
      properties:
        content:
          type: string
          minLength: 1
          maxLength: 100000
          description: Content to check
        check_type:
          type: string
          enum: [input, output, runtime]
          description: Type of guardrail check
        context:
          type: object
          additionalProperties: true
          description: Additional context for the check
      required: [content, check_type]
    
    GuardrailsCheckResponse:
      type: object
      properties:
        passed:
          type: boolean
          description: Whether all checks passed
        results:
          type: array
          items:
            type: object
            properties:
              check_type:
                type: string
              passed:
                type: boolean
              confidence:
                type: number
                minimum: 0
                maximum: 1
              details:
                type: object
                additionalProperties: true
              recommendations:
                type: array
                items:
                  type: string
            required: [check_type, passed, confidence]
        blocked_content:
          type: boolean
          description: Whether content should be blocked
        modified_content:
          type: string
          nullable: true
          description: Suggested modified content
      required: [passed, results, blocked_content]

paths:
  # Core Service Endpoints
  /livekit/token:
    post:
      tags: [Core Services]
      summary: Generate LiveKit token
      description: Generate LiveKit token with scoped permissions, TTL 6 hours
      security:
        - BearerAuth: []
        - OrgHeader: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/LiveKitTokenRequest'
      responses:
        '200':
          description: Token generated successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/LiveKitTokenResponse'
        '400':
          description: Validation error
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ValidationError'
        '401':
          description: Unauthorized
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '429':
          description: Rate limited
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'

  /collab/token:
    get:
      tags: [Core Services]
      summary: Get collaboration token
      description: Y-Sweet collaboration token with organization verification
      security:
        - BearerAuth: []
        - OrgHeader: []
      parameters:
        - name: document_id
          in: query
          required: true
          schema:
            type: string
        - name: permissions
          in: query
          schema:
            type: array
            items:
              type: string
              enum: [read, write, admin]
      responses:
        '200':
          description: Token retrieved successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/CollabTokenResponse'
        '401':
          description: Unauthorized
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '404':
          description: Document not found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'

  /search:
    get:
      tags: [Core Services]
      summary: Unified search
      description: Unified search using pg_trgm, tsvector, and vector indexes
      security:
        - BearerAuth: []
        - OrgHeader: []
      parameters:
        - name: query
          in: query
          required: true
          schema:
            type: string
            minLength: 1
        - name: types
          in: query
          schema:
            type: array
            items:
              type: string
              enum: [messages, tasks, events, documents, contacts]
        - name: limit
          in: query
          schema:
            type: integer
            minimum: 1
            maximum: 100
            default: 20
        - name: cursor
          in: query
          schema:
            type: string
            nullable: true
      responses:
        '200':
          description: Search results
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/PaginatedResponse'
                  - type: object
                    properties:
                      data:
                        type: array
                        items:
                          $ref: '#/components/schemas/SearchResult'
        '400':
          description: Invalid query
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'

  /email/send:
    post:
      tags: [Core Services]
      summary: Send email
      description: Send email via Nylas through FastAPI proxy
      security:
        - BearerAuth: []
        - OrgHeader: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/EmailSendRequest'
      responses:
        '200':
          description: Email sent successfully
          content:
            application/json:
              schema:
                type: object
                properties:
                  message_id:
                    type: string
                  status:
                    type: string
                    enum: [sent, queued]
                  sent_at:
                    type: string
                    format: date-time
                required: [message_id, status, sent_at]
        '400':
          description: Invalid email data
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ValidationError'
        '429':
          description: Rate limited
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'

  /mcp/execute:
    post:
      tags: [Core Services]
      summary: Execute MCP tool
      description: Execute MCP tool call with SSRF protection
      security:
        - BearerAuth: []
        - OrgHeader: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/McpExecuteRequest'
      responses:
        '200':
          description: Tool executed successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/McpExecuteResponse'
        '400':
          description: Invalid tool request
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '403':
          description: Tool not authorized
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '500':
          description: Tool execution failed
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'

  /user/export:
    get:
      tags: [Core Services]
      summary: Export user data
      description: GDPR-compliant user data export as SSE stream (JSON)
      security:
        - BearerAuth: []
        - OrgHeader: []
      parameters:
        - name: format
          in: query
          schema:
            type: string
            enum: [json, csv]
            default: json
        - name: include_deleted
          in: query
          schema:
            type: boolean
            default: false
      responses:
        '200':
          description: Data export stream
          content:
            text/event-stream:
              schema:
                type: string
                description: Server-sent events with JSON data
        '401':
          description: Unauthorized
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'

  # Workflow Endpoints
  /workflow/execute:
    post:
      tags: [Workflows]
      summary: Execute workflow
      description: Execute workflow with topological sort and parallel step execution
      security:
        - BearerAuth: []
        - OrgHeader: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/WorkflowExecuteRequest'
      responses:
        '200':
          description: Workflow execution started
          content:
            application/json:
              schema:
                type: object
                properties:
                  execution_id:
                    type: string
                  status:
                    type: string
                    enum: [pending, running]
                  started_at:
                    type: string
                    format: date-time
                required: [execution_id, status, started_at]
        '400':
          description: Invalid workflow request
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'

  /workflow/status:
    get:
      tags: [Workflows]
      summary: Get workflow status
      description: Get workflow status (pending, running, waiting, completed)
      security:
        - BearerAuth: []
        - OrgHeader: []
      parameters:
        - name: execution_id
          in: query
          required: true
          schema:
            type: string
      responses:
        '200':
          description: Workflow status
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/WorkflowStatusResponse'
        '404':
          description: Workflow not found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'

  /workflow/cancel:
    post:
      tags: [Workflows]
      summary: Cancel workflow
      description: Cancel running workflow
      security:
        - BearerAuth: []
        - OrgHeader: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                execution_id:
                  type: string
                reason:
                  type: string
                  maxLength: 500
              required: [execution_id]
      responses:
        '200':
          description: Workflow cancelled
          content:
            application/json:
              schema:
                type: object
                properties:
                  execution_id:
                    type: string
                  status:
                    type: string
                    enum: [cancelled]
                  cancelled_at:
                    type: string
                    format: date-time
                required: [execution_id, status, cancelled_at]
        '404':
          description: Workflow not found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'

  /workflow/compensate:
    post:
      tags: [Workflows]
      summary: Compensate workflow
      description: Admin trigger for workflow compensation (rollback)
      security:
        - BearerAuth: []
        - OrgHeader: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                execution_id:
                  type: string
                force:
                  type: boolean
                  default: false
                  description: Force compensation even if not failed
              required: [execution_id]
      responses:
        '200':
          description: Compensation started
          content:
            application/json:
              schema:
                type: object
                properties:
                  execution_id:
                    type: string
                  status:
                    type: string
                    enum: [compensating]
                  started_at:
                    type: string
                    format: date-time
                required: [execution_id, status, started_at]
        '404':
          description: Workflow not found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
```

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
