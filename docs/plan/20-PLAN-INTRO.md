---
title: "Pattern Tags & Domain Shortcuts"
owner: "Frontend Engineering"
status: "active"
updated: "2026-04-26"
canonical: "pattern-tags.yaml"
---

**Pattern tags**: Capitalized abbreviations for recurring frontend behaviors. **Domain shortcuts**: Terms for architectural patterns.

---

## Pattern Tags

For the complete pattern tag registry with descriptions, see [pattern-tags.yaml](./pattern-tags.yaml).

### Animation Tags

MotionGuard, AnimatePresence, Spring, StaggerChildren, OpacityFade, Static, PopLayout, LazyMotion

### Data Tags

VirtualizeList, InfiniteScroll, OptimisticMutation, InlineEdit, DebounceAutoSave, HoverPrefetch, SSEStream, ChatCache

### Specialized Tags

GenUI, SandboxIframe, Recurring, TimezoneAware, TieredMemory, WorkflowExecution, A2AFlow, KeyboardShortcuts, Upload, MCPSecurity, TriageColor, PLAY

### LiveKit Tags

Streaming, InterruptHandling, TokenGeneration, InterruptDetection, StateManagement, HorizontalScaling

### Spec/Architecture Tags

SpecTemplate, ComponentTiering, CrossCuttingSpec, FlowContract, APIContract, EventContract, TestContract, OpsRunbook, FeatureFlag, CostControl, MigrationStrategy, Observability, SecurityMatrix, MCPSecurity, Passkeys, TauriDesktop, MobileNotif, AIGuardrails, SSRFPrevention, PrivacyAI, StripeBilling, ComplianceCode, YjsLifecycle, NylasV3, OTelGenAI, OfflineFirst

---

## Domain Patterns

| Pattern | Description |
|---|---|
| **ORG scoping** | Every row has `org_id`; RLS enforces org isolation |
| **Server-wins rollback** | On conflict, server state replaces client + rollback event |
| **Last-write-wins (LWW)** | Conflict resolution via `uat` timestamp |
| **Idempotency key (IC)** | Async operations use `actor_id + monotonic_counter` |
| **Expand-contract (EBC)** | DB schema changes: add columns/tables, then remove old |
| **Zero-downtime (ZDT)** | Deployments/migrations with no service interruption |
| **Error budget (EB)** | Allowed failure window before SLO breach |
| **Burn rate (BR)** | Error budget consumption rate; triggers alerts |