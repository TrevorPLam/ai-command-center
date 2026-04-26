# Cross-component dependencies

This document details cross-component dependencies, core dependency patterns, critical shared dependencies, dependency optimization opportunities, circular dependency risks, and recent dependency updates for the AI Command Center platform.

---

## Technology version pins

Exact versions or constraints that must be used in all environments.

- **TypeScript**: 6.0 in production; 7.0 beta (tsgo) evaluated in CI

### TypeScript 7.0 (tsgo) beta assessment (April 2026)

**Status**: TypeScript 7.0 Beta released via ``@typescript`/native-preview`@beta`` package.
Stable release targeted within 2 months from beta announcement (April 2026 → June 2026).

**Beta Stability**:
- tsgo executable has identical behavior to tsc from TypeScript 6.0, just faster
- Editor support via TypeScript Native Preview extension for VS Code is described as
  "rock-solid" and "widely used by many teams for months"
- TypeScript can run side-by-side with TypeScript 6.0 via ``@typescript`/typescript6`
  package with `tsc6` entry point
- Stable programmatic API not available until TypeScript 7.1 or later
- Preview focuses on type checking (--noEmit mode); full emit, watch mode, build mode,
  plugin API still in development (landing in 2026)

**Performance vs tsc 6.0**:
- Benchmarks on microsoft/TypeScript repository (~400k lines, Apple M1 Pro):
  - Total time: 10.8x faster (tsc 0.284s → tsgo 0.026s)
  - Type checking: 30x faster (tsc 0.103s → tsgo 0.003s)
  - Parse: 8.9x faster (tsc 0.071s → tsgo 0.008s)
  - Bind: 6.4x faster (tsc 0.058s → tsgo 0.009s)
  - Peak memory: 2.9x less (tsc 68MB → tsgo 23MB)
- Scaling by project size:
  - < 10k lines: 4x speedup
  - 10k-100k lines: 6x speedup
  - 100k-500k lines: 8.8x speedup
  - 500k+ lines (monorepo): ~10x speedup

**Migration Complexity from tsc 6.0**:
- **Installation**: `npm install -D `@typescript`/native-preview`@beta``
- **Configuration**: No changes required - tsgo accepts same flags as tsc and reads tsconfig.json as-is
- **Adoption Strategy**: Run both tsc and tsgo in CI pipeline during validation period
  (2-4 weeks). When tsgo produces identical results consistently, switch CI gate to tsgo
- **Breaking Changes**: TypeScript 6.0 deprecations become hard removals in 7.0
  (target, moduleResolution, baseUrl, esModuleInterop, outFile, module values,
  alwaysStrict, downlevelIteration, legacy module keyword, asserts keyword,
  /// <reference no-default-lib>)
- **Behavioral Changes**: Type ordering in .d.ts output, inference changes from
  this-less optimization, silent moduleResolution default shift,
  "use strict" always emitted, esModuleInterop emit changes
- **Escape Hatch**: `ignoreDeprecations` mechanism available to temporarily silence
  deprecation warnings during migration

- **React**: 19.2.5; React 20 evaluated Q2 2026
- **Vite**: 8.0.0
- **Zustand**: 5.0.12
- **TanStack Query**: 5.100.1
- **Motion (Framer)**: 12.38.0 (import from `motion/react`)
- **Tailwind CSS**: 4.2.2
- **Prisma**: 7.8.0 (pgbouncer=true)
- **dnd‑kit**: 6.3.1 (community standard; no migration)
- **Node**: 24.15.0 LTS Krypton
- **Python**: 3.12
- **FastAPI**: 0.136.1
- **react‑big‑calendar**: ^1.19.4 (React 19 compatible)
- **Yjs**: 13.6.21
- **DOMPurify**: ≥3.4.0
- **nuqs**: ^2.5
- **react‑helmet‑async**: latest
- **LiveKit Agents**: ≥2.0.0 ONLY
- **LiveKit Server SDK**: ≥1.0.0
- **markmap**: latest
- **react‑resizable**: ^3.1.3
- **`@ai`‑sdk/react**: ^2.0 (Vercel AI SDK v6)
- **`@tremor`/react**: ^3.18
- **`@stripe`/ai‑sdk**: latest
- **`@stripe`/agent‑toolkit**: latest
- **`@powersync`/web**: latest
- **litellm**: >=1.83.7 (cosign + Grype verified)
- **orval**: >=8.2.0
- **`@anthropic`/mcp‑inspector**: >=0.14.1 (dev only)
- **tsgo**: 7.0 beta
- **temporal‑polyfill**: ^0.3.2 (~20KB)
- **pgvectorscale**: 0.4.0 (DiskANN)
- **`@xyflow`/react**: 12.10.2
- **OTel**: v1.40.0 + experimental GenAI
- **prisma‑next**: GA June‑July 2026 (Postgres); Phase 3 evaluation
- **rschedule**: latest
- **`@rschedule`/temporal‑date‑adapter**: latest
- **SimpleWebAuthn**: latest
- **deepeval**: latest

---

## Component dependency matrix

#### Dashboard → Shell
- AgentDetailDrawer → RightPanel + uiSlice
- AmbientStatusBanner → useAgentStatus hook

#### Chat → Shell + XCT
- CollabCanvas → YjsLifecycleManager + CrossCuttingRealtime
- ArtifactSandbox → UploadSecurityScanner + CSP
- MCPSettings → mcpStore + mcpSlice

#### Projects → Shell + Workflow
- ProjectKanbanView → dnd kit + workflowSlice
- TaskDetailDrawer → RightPanel + projectSlice
- RecurringWorkDialog → RecurrenceEngineService

#### Calendar → Shell + Shared
- EventComposer → optimistic UI patterns
- RecurringEditModal → RecurrenceEngineService
- All views → rbc (React Big Calendar)

#### Email → External Services
- All components → NylasWebhookHandler
- ComposeWindow → FastAPI email proxy

#### Settings → All Modules
- MCPSettings → Cross-cutting security
- CostDashboard → AI cost tracking
- IntegrationsSettings → External service configs

### Critical Shared Dependencies

#### State Management (Zustand Slices)
- **uiSlice**: CommandPalette, RightPanel, global UI state
- **orgSlice**: Sidebar, OrgSwitcher, multi-tenant context
- **projectSlice**: All Project components, task management
- **calendarSlice**: All Calendar components, event state
- **mcpSlice**: Chat MCP, Settings MCP, tool management

#### Cross-Cutting Services (XCT)
- **CrossCuttingMotion**: All animated components
- **CrossCuttingOptimistic**: All data mutations (Chat, Projects, Calendar)
- **CrossCuttingRealtime**: Chat, CollabCanvas, ActivityFeed
- **CrossCuttingSearch**: CommandPalette, GlobalSearchDialog
- **CrossCuttingAuthOrg**: Org switching, session management

#### External Service Integrations
- **NylasWebhookHandler**: Email module
- **StripeTokenMeter**: AI cost tracking across Chat, Agent components
- **OTelGenAIInstrumenter**: All AI interactions
- **UploadSecurityScanner**: Documents, Media, Chat artifacts

### Dependency Optimization Opportunities

#### High-Frequency Cross-Cutting Patterns
1. **Motion/Animation**: 80%+ components use `@M` pattern
2. **Optimistic UI**: 60%+ components use `@O` pattern
3. **Real-time Updates**: 40%+ components use `@SS` pattern
4. **Virtualization**: 30%+ components use `@V` pattern

#### Token Optimization Strategies
1. **Extract Common Patterns**: Create shared component specs for frequently used combinations
2. **Dependency Injection**: Reduce hardcoded deps by using shared interfaces
3. **Layered Architecture**: Separate UI deps from service deps
4. **Lazy Loading**: Defer heavy dependencies (Monaco, Yjs, etc.)

#### Circular Dependency Risks
- Shell ↔ All modules (managed through provider pattern)
- Chat ↔ MCP ↔ Settings (triangular dependency)
- Projects ↔ Workflow ↔ Calendar (circular date/task references)

### Recommended Refactoring

#### Phase 1: Extract Shared Patterns
- Create `SHARED-PATTERNS.md` for common `@M`, `@O`, `@SS` combinations
- Define standard interfaces for frequent dependency patterns

#### Phase 2: Service Layer Abstraction
- Create service interfaces to reduce direct component-to-service coupling
- Implement dependency injection for heavy services

#### Phase 3: Component Composition
- Identify opportunities for component composition over inheritance
- Create higher-order components for common cross-cutting concerns

## Module Interaction Matrix

| Module | Shell | Dashboard | Chat | Projects | Calendar | Settings | XCT |
|--------|-------|-----------|------|----------|----------|----------|-----|
| **Shell** | Self | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Dashboard** | ✓ | Self | ✓ | ✓ | ✗ | ✓ | ✓ |
| **Chat** | ✓ | ✓ | Self | ✓ | ✗ | ✓ | ✓ |
| **Projects** | ✓ | ✓ | ✓ | Self | ✓ | ✓ | ✓ |
| **Calendar** | ✓ | ✗ | ✗ | ✓ | Self | ✓ | ✓ |
| **Settings** | ✓ | ✓ | ✓ | ✓ | ✓ | Self | ✓ |
| **XCT** | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | Self |

**Legend**: ✓ = Direct dependency, ✗ = No direct dependency

This analysis reveals heavy interdependence, suggesting opportunities for:
1. Shared abstraction layers
2. Service-oriented architecture
3. Event-driven communication patterns
4. Dependency injection containers

## Dependency Updates (April 2026)

- Replace `dndkit` with `dnd-kit (pinned, no migration)`; remove all PragmaticDnD references.
- Add ``@tremor`/react` in Dashboard and Budget module dependencies.
- Replace `ElectricSQL`/`Replicache`/`cr-sqlite` with `PowerSync` in offline sync section.
- Add `ai`, ``@ai`-sdk/react` in Chat and GenUI deps.
- Add ``@stripe`/ai-sdk`, ``@stripe`/agent-toolkit` in Stripe integration.
- Add ``@js`-temporal/polyfill` as conditional dep in Calendar/Recurrence stack (NOT `temporal-polyfill` or `es2026-shim` - these packages don't exist or are incorrect).
- Add `tsgo` (TypeScript 7.0 beta) to CI tooling dependencies, flagged experimental.

## TypeScript Compilers

### tsgo (TypeScript 7.0 Beta) vs tsc 6.0

**Status**: TypeScript 7.0 Beta released via ``@typescript`/native-preview`@beta`` package. Stable release targeted within 2 months from beta announcement (April 2026 → June 2026).

**Beta Stability Assessment**:
- tsgo executable has identical behavior to tsc from TypeScript 6.0, just faster
- Editor support via TypeScript Native Preview extension for VS Code is described as "rock-solid" and "widely used by many teams for months"
- TypeScript can run side-by-side with TypeScript 6.0 via ``@typescript`/typescript6` package with `tsc6` entry point
- Stable programmatic API not available until TypeScript 7.1 or later
- Preview focuses on type checking (--noEmit mode); full emit, watch mode, build mode, plugin API still in development (landing in 2026)

**Performance Comparison (Benchmarks on microsoft/TypeScript repository ~400k lines, Apple M1 Pro)**:

| Metric | tsc 6.0 | tsgo 7.0 Beta | Improvement |
|--------|---------|---------------|-------------|
| Total time | 0.284s | 0.026s | 10.8x faster |
| Type checking | 0.103s | 0.003s | 30x faster |
| Parse | 0.071s | 0.008s | 8.9x faster |
| Bind | 0.058s | 0.009s | 6.4x faster |
| Emit | 0.052s | Not available | N/A |
| Peak memory | 68MB | 23MB | 2.9x less |

**Scaling by Project Size**:

| Project scale | tsc | tsgo | Speedup |
|--------------|-----|------|---------|
| < 10k lines | 0.8s | 0.2s | 4x |
| 10k-100k lines | 4.2s | 0.7s | 6x |
| 100k-500k lines | 18.5s | 2.1s | 8.8x |
| 500k+ lines (monorepo) | 65s+ | 6.5s+ | ~10x |

**Migration Complexity from tsc 6.0**:

**Installation**:
```bash
npm install -D `@typescript`/native-preview`@beta`
```

**Configuration**: No changes required - tsgo accepts same flags as tsc and reads tsconfig.json as-is

**Adoption Strategy**: Run both tsc and tsgo in CI pipeline during validation period (2-4 weeks). When tsgo produces identical results consistently, switch CI gate to tsgo

```yaml
# Example CI workflow
jobs:
  typecheck-tsc:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout`@v4`
      - run: npm ci
      - run: npx tsc --noEmit
  typecheck-tsgo:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout`@v4`
      - run: npm ci
      - run: npx tsgo --noEmit
```

**Breaking Changes (TypeScript 6.0 deprecations become hard removals in 7.0)**:
- target: es3 and es5 (deprecated)
- moduleResolution: node10, classic (deprecated)
- module: amd, umd, system, none (deprecated)
- baseUrl (deprecated)
- esModuleInterop: false (deprecated)
- allowSyntheticDefaultImports: false (deprecated)
- alwaysStrict: false (deprecated)
- outFile (deprecated)
- downlevelIteration (deprecated)
- Legacy module keyword for namespaces (deprecated)
- asserts keyword on imports (deprecated)
- /// <reference no-default-lib="true"/> (deprecated)

**Behavioral Changes**:
- Type ordering in .d.ts output - Union member ordering may differ between 6.0 and 7.0
- Inference changes from this-less optimization - Method-syntax functions that don't use this now participate in inference earlier
- Silent moduleResolution default shift - Projects without explicit moduleResolution now get bundler instead of node10/classic
- "use strict" always emitted - Non-ESM output files now unconditionally include "use strict"
- esModuleInterop emit changes - Default import emit now uses __importDefault/__importStar helpers

**Escape Hatch**: `ignoreDeprecations` mechanism available to temporarily silence deprecation warnings during migration

## Prisma Next (`@prisma`/next)

### Current Status (April 26, 2026)

**Prisma Next Roadmap**:
- **Phase 1 -- Enable external contributions (April 2026)**: In progress. Establishing stable APIs for extension authors. Public call for contributors in April 2026.
- **Phase 2 -- Early access (May 2026)**: Not started. Get Prisma Next into users' hands for real-world validation. Postgres + one additional SQL database (SQLite candidate) expected to be stable.
- **Phase 3 -- General availability (June-July 2026)**: Not started. Bring Prisma Next Postgres support to GA as production-ready product. Prisma Next will become Prisma 8 at GA.

**Prisma 7 Status**: Prisma 7 remains the recommended version for production applications and will continue to receive updates and long-term support for 12 months after Prisma Next GA. Teams can continue upgrading to Prisma 7 with confidence.

### Feature Set Comparison: Prisma Next vs Prisma Current

#### What's Already Built in Prisma Next

**Core Query API Improvements**:
- New query API with custom collection methods for models
- Streaming query results for large datasets (async iterables, lower memory usage)
- Low-level, type-safe SQL query builder for complex or custom SQL
- Aggregation & grouping support (addresses long-standing GROUP BY gap)
- Model collections for domain-specific query methods

**Schema & Type System**:
- TypeScript Prisma schemas as alternative to schema.prisma
- Extension system for installing new behaviors and data types
- First extension: pgvector for vector similarity search

**Agent-Centric Development**:
- Compile-time guardrails (type errors before runtime)
- Machine-readable errors with stable codes and suggested fixes
- Structured output for AI agents (query plans, schema details, diagnostics)
- Schema change preview before database impact

**Middleware & Validation**:
- Middleware for query inspection, blocking, and rewriting
- Built-in query linting (block risky patterns like deletes without where)
- Query budgeting (prevent expensive or unbounded queries)
- Validation at every layer (editor, schema alignment, middleware)

**Migration System**:
- Graph-based migrations (like Git branches for database schema)
- Handles branching histories for parallel development
- Squashing old migrations to keep history manageable
- Baselines for adopting existing databases
- Data migrations coming (type-safe data transformations alongside schema changes)

### Feature Comparison Table

| Feature | Prisma 7 (Current) | Prisma Next | Notes |
|---------|-------------------|-------------|-------|
| Query API | GraphQL-inspired nested objects | Fluent method chaining + SQL builder | Prisma Next reduces nesting complexity |
| Schema Language | schema.prisma only | schema.prisma OR TypeScript | TypeScript schemas enable full IDE integration |
| GROUP BY | Not supported | Fully supported with combine() | Addresses GitHub issue #8744 |
| Streaming | Not supported | Async iterables for large result sets | Lower memory usage for background jobs |
| Extensions | Limited (built-in only) | Extensible plugin system | pgvector, ParadeDB, custom extensions |
| MongoDB | Removed in Prisma 7 | Coming via Prisma Next | Architecture designed for non-SQL targets |
| Agent Support | Basic | Structured output, guardrails, error codes | Designed for AI-assisted workflows |
| Migrations | Linear file list | Graph-based (Git-like) | Handles parallel development better |
| Data Migrations | Manual only | Type-safe data migrations coming | Long-standing gap being addressed |
| TypeScript Schema | No | Yes | Schema in same language as application |
| SQL Query Builder | Raw SQL only | Type-safe SQL builder | Drop to SQL when ORM doesn't fit |

### Migration Complexity for Phase 3

**Timeline Alignment**:
- Prisma Next GA: June-July 2026
- Project Phase 3: Aug-Sep 2026 (Advanced: Offline, Collab, Feature Flags)
- Evaluation window: 1-2 months between Prisma Next GA and project Phase 3
- ADR_102: Prisma Next evaluation postponed to Phase 3 (Postgres GA mid-2026)

**Migration Path Design** (from Prisma roadmap):
- **Parallel Operation**: Prisma Next and Prisma 7 can run side-by-side with gradual traffic shift
- **Compatibility Layer**: Existing Prisma 7 queries don't need immediate rewrite
- **Long-term Support**: Prisma 7 receives 12-month LTS after Prisma Next GA
- **Incremental Adoption**: Teams can adopt at their own pace

**Migration Complexity Assessment**: Low to Moderate

**Low Complexity Factors**:
- Compatibility layer prevents immediate query rewrite
- Parallel operation allows gradual migration
- 12-month Prisma 7 LTS provides comfortable transition window
- Postgres support (primary target) aligns with project database choice
- Graph-based migrations handle parallel development better

**Moderate Complexity Factors**:
- New query API requires learning curve (fluent chaining vs nested objects)
- TypeScript schema option introduces new paradigm
- Extension system may require custom implementations
- Data migrations feature still in development
- MongoDB support not yet available (if needed)

**Estimated Migration Effort**:
- Evaluation period: 2-4 weeks (parallel operation testing)
- Schema migration: 1-2 weeks (optional TypeScript schema conversion)
- Query migration: 4-8 weeks (gradual adoption using compatibility layer)
- Extension integration: 2-4 weeks (if custom extensions needed)
- Total timeline: 8-18 weeks for full migration (can be spread across Phase 3)

**Migration Risks**:
- Extension ecosystem maturity (early stage in Phase 1)
- Data migrations feature not yet GA
- Potential API changes during EA phase (May 2026)
- Learning curve for team unfamiliar with new patterns

### Phase 3 Suitability Analysis

**Requirements Mapping**:

| Project Phase 3 Requirement | Prisma Next Capability | Fit |
|------------------------------|------------------------|-----|
| Offline Sync (PowerSync) | Extension system supports custom sync logic | High |
| Collaboration (Yjs) | Streaming queries for real-time data | High |
| Feature Flags | Type-safe schema changes with preview | High |
| Advanced AI (GraphRAG) | pgvector extension for vector similarity | Excellent |
| Agent Workflows | Structured output, guardrails, error codes | Excellent |
| Performance | Streaming, aggregation, query budgeting | High |
| Type Safety | TypeScript schemas, compile-time guardrails | Excellent |
| Multi-tenant | Extension system for tenant isolation | High |
| Observability | Middleware for telemetry (Sentry, Datadog) | High |

**Suitability Verdict**: Highly Suitable for Phase 3

**Rationale**:
1. **Timing Alignment**: Prisma Next GA (June-July 2026) precedes project Phase 3 (Aug-Sep 2026), providing 1-2 month evaluation window
2. **Feature Alignment**: New features (streaming, aggregation, pgvector, agent support) directly address Phase 3 requirements
3. **Migration Safety**: Parallel operation and compatibility layer reduce risk
4. **Future-Proofing**: Extension system provides flexibility for evolving requirements
5. **Agent-Centric Design**: Built for AI-assisted workflows, aligning with project's AI-first approach

**Recommendation**: Proceed with Phase 3 evaluation as planned in ADR_102. Schedule evaluation for July 2026 (immediately after Prisma Next GA) to inform Phase 3 adoption decisions in Aug-Sep 2026.

**Evaluation Checklist for Phase 3**:
- [ ] Prisma Next GA release review (June-July 2026)
- [ ] Parallel operation testing with existing Prisma 7 setup
- [ ] TypeScript schema evaluation for team adoption
- [ ] Extension system testing (pgvector, custom extensions)
- [ ] Migration complexity validation with real project schema
- [ ] Performance benchmarking (streaming, aggregation)
- [ ] Agent workflow integration testing
- [ ] Data migrations feature assessment
- [ ] Cost/benefit analysis vs staying on Prisma 7
- [ ] Go/no-go decision for Phase 3 adoption

**Dependencies**:
- Add ``@prisma`/next` horizon dep for Phase 3 evaluation (already noted in 05-XCT-DEPENDENCIES.md line 211)
- Add `MCPSec` middleware to MCP security dependencies.
- TASK INFORMATION INCORRECT: `es2026-shim` does not exist. Pattern matching (match/using) is Stage 1 proposal, NOT part of ES2026. No polyfill available.
- Change OpenAI provider deps from Assistants/ChatCompletions to Responses API + Conversations.

## OpenAI Migration

### Responses API Feature Parity

**Status**: Assistants API deprecated, shutdown August 26, 2026. Responses API has achieved full feature parity.

**Migration Mapping**:
- **Assistants → Prompts**: Versioned behavioral profiles that hold configuration (model, tools, instructions). Easier to version and update than assistants.
- **Threads → Conversations**: Threads stored messages server-side. Conversations store generalized items (messages, tool calls, tool outputs, and other data).
- **Runs → Responses**: Responses send input items or use a conversation object and receive output items. Tool call loops are explicitly managed (not automatic).
- **Run steps → Items**: Generalized objects that can be messages, tool calls, outputs, and more.

### Migration Complexity and Timeline

**Complexity**: Moderate. Requires code changes but no automated tool for thread-to-conversation migration.

**Timeline**:
- **Deadline**: August 26, 2026 (Assistants API shutdown)
- **Strategy**: Incremental migration recommended
  - Migrate new user chats to conversations and responses
  - Backfill old threads as necessary (no automated migration tool)
  - Simple message inputs are wire-compatible between Chat Completions and Responses

**Code Changes Required**:
- Update endpoints: `POST /v1/chat/completions` → `POST /v1/responses`
- Change parameter: `messages` → `input`
- Migrate assistant objects to prompt objects (via dashboard "Create prompt" button)
- Convert thread messages to conversation items (manual backfill script required)

### Tool-Calling Compatibility

**Status**: Fully supported with minor structural differences.

**Function Calling Differences**:
1. **Tagging**: Responses uses internally-tagged polymorphism vs externally-tagged in Chat Completions
2. **Strict Mode**: Responses functions are strict by default vs non-strict in Chat Completions
3. **Item Correlation**: Tool calls and outputs are distinct Items correlated using `call_id`

**Tool Ecosystem Support**:
- Function calling (custom code)
- Web search (built-in)
- Remote MCP servers (Model Context Protocol)
- File search (built-in)
- Code interpreter (built-in)
- Computer use (built-in)
- Image generation (built-in)
- Tool search (dynamic tool loading)
- Skills (versioned skill bundles)
- Shell (hosted containers)

**Migration Example**:
```json
// Chat Completions (externally-tagged, non-strict)
{
  "type": "function",
  "function": {
    "name": "get_weather",
    "parameters": { "type": "object", "properties": {...} }
  }
}

// Responses (internally-tagged, strict by default)
{
  "type": "function",
  "name": "get_weather",
  "strict": true,
  "parameters": { "type": "object", "properties": {...} }
}
```

## PowerSync Configuration

### YAML Sync Rules (Legacy) vs Sync Streams (Beta Recommended)

**Status:** Sync Rules are now legacy. Sync Streams (Beta) are recommended for all new projects.

#### YAML Sync Rules Capabilities

```yaml
bucket_definitions:
  user_lists:
    # Parameter Query (authentication)
    parameters: SELECT request.user_id() as user_id
    # Data Query (filtered by parameter)
    data:
      - SELECT * FROM lists WHERE owner_id = bucket.user_id
```

**Capabilities:**
- Bucket definitions with custom names
- Parameter Queries (authentication, client, table-based)
- Data Queries with SQL-like syntax
- Authentication parameters from JWT (user_id, org_id)
- Client parameters passed at connection
- Values from tables/collections
- SELECT with column selection and WHERE filtering
- Subqueries with IN (SELECT ...)
- INNER JOIN (selected columns from single table)
- Common Table Expressions (CTEs) via with: block
- Multiple queries per stream via queries:
- Table-valued functions (json_each() for array expansion)
- BETWEEN and CASE expressions

**Limitations:**
- Limited set of operators and functions (not all SQL supported)
- No GROUP BY, ORDER BY, LIMIT, UNION in basic queries
- NOT IN not supported with subqueries or parameter arrays
- Complex OR conditions limited (both sides must reference same parameter)
- Two IN expressions on parameters in same AND not supported

#### Sync Streams (Recommended)

**Advantages over Sync Rules:**
- On-demand syncing with subscription parameters
- Temporary caching-like behavior with configurable TTL
- Simpler developer experience with React hooks
- Automatic bucket/parameter creation (implicit)

**Feature Matrix:**

| Feature | Sync Rules (Legacy) | Sync Streams (Beta) |
|---------|-------------------|-------------------|
| On-demand syncing | No | Yes |
| TTL caching | No | Yes |
| React hooks | No | Yes |
| Bucket definition | Explicit (manual) | Implicit (automatic) |
| Parameter types | Auth, Client, Table | Auth, Connection, Subscription |
| Subquery support | IN (SELECT ...) | IN (SELECT ...) with limited nesting |
| Status | Legacy (supported) | Recommended (Beta) |

## Temporal API

### Browser Support (April 2026)

**Status**: Temporal reached TC39 Stage 4 in March 2026, securing its place in ES2026.

**Browser Support Table**:

| Browser | Version Support | Status | Notes |
|---------|----------------|--------|-------|
| Chrome | 144+ | Supported | Shipped January 2026 |
| Firefox | 139+ | Supported | Shipped May 2025 (first browser) |
| Edge | 144+ | Supported | Follows Chrome |
| Safari | 26.3-26.5 | NOT Supported | Technical Preview disabled by default |
| Safari | 18.4+ | Conflicting reports | Some sources claim support, but Can I Use shows NOT supported |
| iOS Safari | 3.2-26.5 | NOT Supported | No support yet |
| Node.js | 24 | Flag Required | Requires `--harmony-temporal` flag (V8 implementation in progress as of April 2026) |

**Global Usage**: 69.28% as of March 2026 (Can I Use)

### Polyfill Strategy

**Official Polyfill**: ``@js`-temporal/polyfill` (version 0.5.1, last published April 2025)

**Installation**:
```bash
npm install `@js`-temporal/polyfill
```

**Usage**:
```typescript
// For production today (polyfill approach)
import { Temporal } from '`@js`-temporal/polyfill';

// Or CommonJS:
const { Temporal } = require('`@js`-temporal/polyfill');
```

**Important Notes**:
- `es2026-shim` does NOT exist - this is incorrect package name
- `temporal-polyfill` is an alternative but `@js`-temporal/polyfill is the official polyfill
- Pattern matching (match/using) is Stage 1 proposal, NOT part of ES2026 - no polyfill available
- Node.js native support without flag expected in Node.js 24 LTS updates later in 2026

## Fly.io Private Network Configuration

### Private Networking Overview

Fly.io provides IPv6 private networking (6PN) for secure communication between apps within an organization.

### .internal DNS Resolution

**DNS Structure:**

- **Base domain:** `.internal`
- **App addressing:** `<appname>.internal` returns AAAA records for all running Machines
- **Regional addressing:** `<region>.<appname>.internal` for Machines in specific region
- **Machine addressing:** `<machine_id>.vm.<appname>.internal` for specific Machine
- **Process group:** `<process_group>.process.<appname>.internal` for specific process groups

**DNS Server:**

- **Address:** `fdaa::3` (Fly.io custom DNS server)
- **Configuration:** Automatically configured in `/etc/resolv.conf` on Machines
- **Capabilities:** Resolves both public DNS and 6PN addresses

### Network Binding Requirements

**fly-local-6pn Alias:**

- Machines alias their 6PN address to `fly-local-6pn` in `/etc/hosts`
- Services must bind to `fly-local-6pn:<port>` to be accessible via 6PN
- Example: Bind to `fly-local-6pn:8080` for service on port 8080
- `fly-local-6pn` is to 6PN as `localhost` is to `127.0.0.1`

### Custom Private Networks

**Use Cases:**

- Tenant isolation for multi-tenant SaaS platforms
- Customer-specific app isolation
- Untrusted code isolation
- Security boundary enforcement

**Network Naming:**

- **Pattern:** Use formula like `customerID-network` or `appName-someID-network`
- **Constraints:** Letters, numbers, dashes; must start with letter
- **Uniqueness:** Network names unique within organization
- **Persistence:** Network ID permanently associated with name (never reused)

**Creation Methods:**

```bash
# Via flyctl
fly apps create <app-name> --network <network-name>

# Via Machines API
curl -i -X POST \
  -H "Authorization: Bearer ${FLY_API_TOKEN}" \
  -H "Content-Type: application/json" \
  "${FLY_API_HOSTNAME}/v1/apps" \
  -d '{
    "app_name": "my-app-name",
    "org_slug": "personal",
    "network": "my-custom-network-name"
  }'
```

**Important Constraints:**

- Apps cannot be moved between networks after creation
- Apps cannot exist in multiple networks simultaneously
- Destroying all apps on a custom 6PN does not destroy the network
- Apps on different custom 6PNs cannot communicate without explicit configuration

### Security Configuration

**Network Isolation:**

- **Default 6PN:** All apps in organization can communicate
- **Custom 6PN:** Apps isolated to specific network only
- **Cross-network communication:** Requires explicit configuration
- **Organization isolation:** Each org's network isolated from others

**Security Features:**

- **WireGuard VPN:** Secure VPN access to 6PN from local machines
- **TLS termination:** Built-in TLS for all public services
- **Firewall rules:** Managed via Fly.io platform
- **Access control:** Organization roles and permissions

**Security Best Practices:**

- Use custom private networks for tenant isolation in multi-tenant apps
- Implement proper organization role management
- Use WireGuard VPN for secure local development access
- Monitor network traffic between apps
- Apply principle of least privilege for inter-app communication

### TXT Query Records

**Available TXT Queries:**

- `vms.<appname>.internal` - Machine information
- `all.vms.<appname>.internal` - All Machines including stopped
- `regions.<appname>.internal` - Regions where app is deployed
- `all.regions.<appname>.internal` - All regions including stopped
- `_apps.internal` - List of all apps in organization
- `_peer.internal` - Peer information
- `_instances.internal` - Instance information
- `all._instances.internal` - All instances including stopped

### Important Notes

- **6PN address changes:** 6PN addresses are not static and can change on reboot
- **Use domains for addressing:** Use `<machine_id>.vm.<appname>.internal` for stable addressing
- **FLY_PRIVATE_IP:** Environment variable contains current Machine's 6PN address
- **Running Machines only:** AAAA queries only return running Machines (stopped Machines excluded)
- **Flycast alternative:** Use Flycast for Fly Proxy features on private network