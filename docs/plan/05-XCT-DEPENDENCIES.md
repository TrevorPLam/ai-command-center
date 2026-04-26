---
file_name: 05-XCT-DEPENDENCIES.md
steering: TO PARSE - READ INTRO
document_type: dependencies_analysis
tier: infrastructure
description: Cross-component dependency analysis and optimization opportunities
last_updated: 2026-04-25
version: 1.0
---

# Cross-Component Dependencies

## Core Dependency Patterns

### Shell (F) Dependencies
- **AppShell**: Foundation for all pages, providers layout structure
- **Sidebar**: Navigation hub, consumed by all page components
- **CommandPalette**: Global search/commands, used across modules
- **RightPanel**: Container for detail views (AgentDetailDrawer, TaskDetailDrawer, etc.)
- **StatusBar**: Global status display

### Cross-Module Dependencies

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
1. **Motion/Animation**: 80%+ components use @M pattern
2. **Optimistic UI**: 60%+ components use @O pattern  
3. **Real-time Updates**: 40%+ components use @SS pattern
4. **Virtualization**: 30%+ components use @V pattern

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
- Create `SHARED-PATTERNS.md` for common @M, @O, @SS combinations
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
- Add `@tremor/react` in Dashboard and Budget module dependencies.
- Replace `ElectricSQL`/`Replicache`/`cr-sqlite` with `PowerSync` in offline sync section.
- Add `ai`, `@ai-sdk/react` in Chat and GenUI deps.
- Add `@stripe/ai-sdk`, `@stripe/agent-toolkit` in Stripe integration.
- Add `temporal-polyfill` as conditional dep in Calendar/Recurrence stack.
- Add `tsgo` (TypeScript 7.0 beta) to CI tooling dependencies, flagged experimental.
- Add `@prisma/next` horizon dep for Phase 3 evaluation.
- Add `MCPSec` middleware to MCP security dependencies.
- Add `es2026-shim` for match/using polyfills in build chain.
- Change OpenAI provider deps from Assistants/ChatCompletions to Responses API + Conversations.
