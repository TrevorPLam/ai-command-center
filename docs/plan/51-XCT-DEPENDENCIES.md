---
title: "Cross-component Dependencies"
owner: "Architecture"
status: "active"
updated: "2026-04-26"
canonical: ""
---

This document details cross-component dependencies, core dependency patterns, critical shared dependencies, dependency optimization opportunities, circular dependency risks, and recent dependency updates for the AI Command Center platform.

---

## Technology version pins

Exact versions or constraints are defined in [versions.yaml](./versions.yaml) (source of truth).

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

## SQLModel + Alembic (Python ORM)

### Current Status (April 26, 2026)

**SQLModel**: Production-ready Python ORM built on Pydantic v2 and SQLAlchemy 2.0
- Type-safe models with Pydantic validation
- Full SQLAlchemy 2.0 async support
- Native pgvector extension support
- Production-ready with active maintenance

**Alembic**: Industry-standard database migration tool for SQLAlchemy
- Linear migration history
- Automatic migration generation
- Support for complex schema changes
- Data migration capabilities

### Core Features

**Type Safety & Validation**:
- Pydantic v2 integration for runtime validation
- IDE autocomplete with full type hints
- Automatic schema validation
- Seamless FastAPI integration (Pydantic models shared)

**Query API**:
- SQLAlchemy 2.0 async session support
- Type-safe query building
- Raw SQL execution with type safety
- Aggregation and grouping support

**Schema System**:
- Python class-based models (no separate schema DSL)
- Automatic table/column name mapping
- Relationship definitions with cascade behavior
- Index and constraint definitions

**Migration System (Alembic)**:
- Linear migration history (simple and predictable)
- Automatic migration generation from model changes
- Support for data migrations
- Rollback capabilities
- Branching support for parallel development

### Feature Comparison

| Feature | SQLModel + Alembic | Notes |
|---------|-------------------|-------|
| Query API | SQLAlchemy 2.0 async sessions | Mature, battle-tested |
| Schema Language | Python classes (Pydantic) | Same language as application |
| Type Safety | Pydantic v2 validation | Runtime + compile-time safety |
| GROUP BY | Full SQLAlchemy support | Native SQL aggregation |
| Streaming | Async yield for large result sets | Lower memory usage |
| Extensions | pgvector, custom types | SQLAlchemy extension ecosystem |
| Agent Support | Type-safe models, structured errors | Python-native tooling |
| Migrations | Alembic (linear history) | Industry standard, reliable |
| Data Migrations | Alembic operations | Type-safe data transformations |
| SQL Query Builder | SQLAlchemy Core | Drop to SQL when needed |
| FastAPI Integration | Native Pydantic models | Zero-copy validation |

### Phase 3 Suitability Analysis

**Requirements Mapping**:

| Project Phase 3 Requirement | SQLModel + Alembic Capability | Fit |
|------------------------------|-------------------------------|-----|
| Offline Sync (PowerSync) | SQLAlchemy event listeners for CDC | High |
| Collaboration (Yjs) | Async sessions for real-time data | High |
| Feature Flags | Alembic migrations for schema changes | High |
| Advanced AI (GraphRAG) | pgvector extension support | Excellent |
| Agent Workflows | Type-safe models, structured errors | Excellent |
| Performance | SQLAlchemy 2.0 async, connection pooling | High |
| Type Safety | Pydantic v2 validation | Excellent |
| Multi-tenant | Session scoping, row-level security | High |
| Observability | SQLAlchemy event hooks for telemetry | High |

**Suitability Verdict**: Highly Suitable for Phase 3

**Rationale**:
1. **Production-Ready**: SQLModel and Alembic are mature, production-tested tools
2. **Python Ecosystem**: Native integration with FastAPI, Pydantic, and Python tooling
3. **Type Safety**: Pydantic v2 provides comprehensive validation and type safety
4. **Migration Reliability**: Alembic is the industry standard for SQLAlchemy migrations
5. **Performance**: SQLAlchemy 2.0 async sessions provide excellent performance
6. **Agent-Friendly**: Python-native tooling aligns with AI agent workflows

**No Evaluation Needed**: SQLModel + Alembic is the chosen stack (ADR_002), production-ready, and requires no evaluation phase.

**Dependencies**:
- Add `MCPSec` middleware to MCP security dependencies.
- TASK INFORMATION INCORRECT: `es2026-shim` does not exist. Pattern matching (match/using) is Stage 1 proposal, NOT part of ES2026. No polyfill available.
- Change OpenAI provider deps from Assistants/ChatCompletions to Responses API + Conversations.

## Frontend Dependencies

### Core Framework

**React Ecosystem**:
- `react` ^19.0.0 - Core UI library
- `react-dom` ^19.0.0 - React DOM renderer
- `react-router-dom` ^6.28.0 - Client-side routing
- `@tanstack/react-query` ^5.59.0 - Server state management
- `zustand` ^5.0.0 - UI-only state management (ADR_003)
- `react-helmet-async` ^2.0.0 - Document head management (ADR_016)

**TypeScript & Build**:
- `typescript` ^6.0.0 - Type checking (tsc)
- `@typescript/native-preview` @beta - TypeScript 7.0 beta (tsgo, experimental)
- `vite` ^7.3.1 - Build tool and dev server
- `@vitejs/plugin-react` ^4.3.0 - Vite React plugin

### Motion & Animation

**Motion Library**:
- `motion` ^11.0.0 - Animation library (formerly framer-motion)
- Note: Import from `motion/react`, not `framer-motion`

**Motion Patterns**:
- Spring physics for primary interactions (stiffness: 300, damping: 30)
- Stagger children for list reveals (0.05-0.08s delay)
- AnimatePresence for exit animations
- LazyMotion for code splitting animation bundles
- Respect prefers-reduced-motion media query

### UI Components

**Tailwind CSS**:
- `tailwindcss` ^4.2.2 - Utility-first CSS
- `@tailwindcss/vite` ^4.0.0 - Tailwind Vite plugin
- Note: Use @theme/@source for configuration (Tailwind CSS 4 syntax)

**shadcn/ui Components**:
- `@radix-ui/react-dialog` - Dialog/Modal components
- `@radix-ui/react-dropdown-menu` - Dropdown menus
- `@radix-ui/react-select` - Select components
- `@radix-ui/react-tabs` - Tab components
- `@radix-ui/react-toast` - Toast notifications
- `@radix-ui/react-tooltip` - Tooltips
- `@radix-ui/react-popover` - Popovers
- `@radix-ui/react-slot` - Slot composition
- `class-variance-authority` - Component variants
- `clsx` - Conditional className
- `tailwind-merge` - Tailwind class merging

**Charting**:
- `@tremor/react` ^3.18.x - Dashboard charts (ADR_087, ADR_105)
- Note: Tremor v4 beta not ready for migration

**Calendar**:
- `react-big-calendar` ^1.19.4 - Calendar component (pinned for React 19 compatibility, ADR_014)
- `date-fns` - Date utilities

### Drag & Drop

**dnd-kit** (Primary DnD library, ADR_018, ADR_085):
- `@dnd-kit/core` - Core drag and drop
- `@dnd-kit/sortable` - Sortable lists
- `@dnd-kit/utilities` - Utility functions
- Note: No migration to PragmaticDnD

### Virtualization

**react-window**:
- `react-window` - Virtualized lists for performance
- Note: Use for lists >50 items (ActivityFeed, transaction lists, news feed)

### Forms & Validation

**React Hook Form**:
- `react-hook-form` - Form state management
- `@hookform/resolvers` - Validation resolvers
- `zod` - Schema validation
- Note: Use "use no memo" directive for RHF components (ADR_094)

### Date & Time

**Temporal Polyfill** (ADR_095, ADR_109):
- `@js-temporal/polyfill` - Temporal API polyfill
- `rschedule` - Recurrence engine
- `@rschedule/temporal-date-adapter` - Temporal adapter for rschedule
- Note: Mandatory until Safari supports Temporal natively
- Note: Use Temporal.ZonedDateTime for all calendar events (never PlainDateTime)

### Real-time & Collaboration

**Yjs**:
- `yjs` - CRDT for real-time collaboration
- `y-sweet` - Yjs backend service
- `y-websocket` - Yjs WebSocket provider
- Note: Yjs lifecycle: GC on, undo truncation last 5, snapshot version history (ADR_076)

**LiveKit**:
- `livekit-client` - Real-time audio/video
- `livekit-react` - React components for LiveKit
- `livekit-agents` - Voice AI pipeline (backend)
- Note: LiveKit Agents v2.0 only, semantic turn detection mandatory (ADR_115)

### AI & GenUI

**AI SDKs**:
- `ai` - Vercel AI SDK
- `@ai-sdk/react` - React components for AI SDK
- `@stripe/ai-sdk` - Stripe AI integration
- `@stripe/agent-toolkit` - Stripe agent tools

### Code Editor

**Monaco Editor**:
- `@monaco-editor/react` - Monaco React wrapper
- Note: Isolated in sandboxed iframe with separate CSP (ADR_022)
- Note: Lazy-loaded with React.lazy + Suspense

### Security & Sanitization

**DOMPurify**:
- `dompurify` ^3.4.0 - HTML sanitization (SEC-10)
- Note: Three DOMPurify profiles for different security levels

**React Textarea Autosize**:
- `react-textarea-autosize` - Auto-resizing textarea

### Resizable Panels

**react-resizable-panels**:
- `react-resizable-panels` - Resizable panel layouts

### Storage & Persistence

**Zustand Persistence**:
- `zustand` - Built-in persist middleware
- Note: Use version, migrate, and partialize functions (FE-32)
- Note: Conditional rendering, not Suspense (FE-15)

### Performance

**React Compiler**:
- `@babel/plugin-react-compiler` - React Compiler (ADR_034)
- Note: Enabled globally, carveouts for RHF and Zustand persist (ADR_094)

### Accessibility

**react-aria**:
- `@react-aria/*` - Accessible components (optional, shadcn/ui provides most)

### Testing

**Testing Tools**:
- `@testing-library/react` - React testing utilities
- `@testing-library/jest-dom` - Jest matchers
- `@testing-library/user-event` - User event simulation
- `vitest` - Unit test runner
- `playwright` - E2E testing

### Development Tools

**ESLint**:
- `eslint` - Linting
- `eslint-plugin-react-hooks` - React hooks rules (replaces React Compiler ESLint plugin)
- `@typescript-eslint/eslint-plugin` - TypeScript ESLint
- `@typescript-eslint/parser` - TypeScript parser

**Prettier**:
- `prettier` - Code formatting
- `prettier-plugin-tailwindcss` - Tailwind class sorting

**Package Manager**:
- `pnpm` ^10.29.1 - Package manager (pinned version)

### Module-specific Dependencies

**Dashboard**:
- `@tremor/react` - Charts and metrics

**Budget**:
- `@tremor/react` - Financial charts

**Calendar**:
- `react-big-calendar` - Calendar views
- `@js-temporal/polyfill` - Temporal polyfill
- `rschedule` - Recurrence engine
- `@rschedule/temporal-date-adapter` - Temporal adapter

**Chat**:
- `ai` - AI SDK
- `@ai-sdk/react` - React AI components
- `yjs` - Real-time collaboration
- `y-sweet` - Yjs backend

**Projects**:
- `@dnd-kit/core` - Drag and drop
- `@dnd-kit/sortable` - Sortable lists
- `@dnd-kit/utilities` - DnD utilities

**Email**:
- `react-resizable-panels` - Resizable email view
- `react-textarea-autosize` - Auto-resizing compose input

**Conference**:
- `livekit-client` - Real-time audio/video
- `livekit-react` - React LiveKit components

**Documents**:
- `yjs` - Real-time collaboration
- `y-sweet` - Yjs backend

### Installation Commands

```bash
# Core dependencies
pnpm add react react-dom react-router-dom @tanstack/react-query zustand react-helmet-async

# Build tools
pnpm add -D typescript vite @vitejs/plugin-react @typescript/native-preview@beta

# Motion
pnpm add motion

# UI components
pnpm add tailwindcss @tailwindcss/vite
pnpm add @radix-ui/react-dialog @radix-ui/react-dropdown-menu @radix-ui/react-select @radix-ui/react-tabs @radix-ui/react-toast @radix-ui/react-tooltip @radix-ui/react-popover @radix-ui/react-slot
pnpm add class-variance-authority clsx tailwind-merge

# Charting
pnpm add @tremor/react

# Calendar
pnpm add react-big-calendar date-fns

# Drag & drop
pnpm add @dnd-kit/core @dnd-kit/sortable @dnd-kit/utilities

# Virtualization
pnpm add react-window

# Forms
pnpm add react-hook-form @hookform/resolvers zod

# Date & time
pnpm add @js-temporal/polyfill rschedule @rschedule/temporal-date-adapter

# Real-time
pnpm add yjs y-sweet y-websocket
pnpm add livekit-client livekit-react

# AI
pnpm add ai @ai-sdk/react @stripe/ai-sdk @stripe/agent-toolkit

# Code editor
pnpm add @monaco-editor/react

# Security
pnpm add dompurify react-textarea-autosize

# Resizable panels
pnpm add react-resizable-panels

# Testing
pnpm add -D @testing-library/react @testing-library/jest-dom @testing-library/user-event vitest playwright

# Linting
pnpm add -D eslint eslint-plugin-react-hooks @typescript-eslint/eslint-plugin @typescript-eslint/parser

# Formatting
pnpm add -D prettier prettier-plugin-tailwindcss
```

### Dependency Notes

- **React Compiler**: Enabled globally via Babel plugin, with carveouts for React Hook Form (use "use no memo" directive) and Zustand persist (no Suspense)
- **dnd-kit**: Primary DnD library, no migration to PragmaticDnD (ADR_018, ADR_085)
- **Tremor**: v3.18.x pinned, v4 beta not ready for migration
- **Temporal**: Polyfill mandatory until Safari supports Temporal natively (ADR_095)
- **rschedule**: Replaces rrule.js on frontend with Temporal date adapter (ADR_109)
- **LiveKit**: v2.0 only, semantic turn detection mandatory (ADR_115)
- **Monaco**: Isolated in sandboxed iframe with separate CSP (ADR_022)
- **DOMPurify**: >=3.4.0 mandatory for XSS prevention (SEC-10)
- **pnpm**: Pinned to 10.29.1 for consistency

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