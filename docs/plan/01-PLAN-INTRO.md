# Intro

## How to read this document

This document is the single source of truth for project patterns, domain shortcuts, and indexes to detailed documentation. Pattern tags and domain shortcuts are defined once here and used throughout other documents for brevity.

**Pattern tags** (like `@OptimisticMutation`) are short labels for recurring front-end behaviors. They are defined in the Glossary and used in component descriptions.

**Domain shortcuts** (like `ORG scoping`) are terms that condense frequently referenced architectural patterns.

---

## Pattern tag glossary

Tags are capitalised, self-documenting abbreviations. They appear in component tables to indicate which patterns and behaviours a component uses.

- **@MotionGuard**: Animates only `transform` and `opacity`; respects `prefers-reduced-motion` (instant transition).
- **@AnimatePresence**: Page-level enter/exit transition (React AnimatePresence wrapper).
- **@Spring**: Spring animation with tension ≥300 and damping ≥30.
- **@StaggerChildren**: Staggered animation for child elements (max 3 children).
- **@OpacityFade**: Opacity fade ≤150ms.
- **@Static**: No animation (static element).
- **@PopLayout**: Pop-in layout animation for new elements.
- **@OptimisticMutation**: Immediate UI update, revert on failure; pending state (opacity 0.5, italic, pulse); 5-second undo for deletes.
- **@VirtualizeList**: Virtualized list to handle large data sets.
- **@ChatCache**: AI responses cached indefinitely (staleTime:Infinity).
- **@InlineEdit**: Inline editing triggered by click, with debounced auto-save.
- **@InfiniteScroll**: Infinite scroll / load-more pattern.
- **@DebounceAutoSave**: 300ms debounce, auto-save on edits.
- **@SSEStream**: Server-Sent Events for real‑time data streaming.
- **@TieredMemory**: Memory management with retention tiers (working, episodic, semantic).
- **@PromptCaching**: Uses prompt caching for LLM calls to reduce latency/cost.
- **@TriageColor**: Color-coded triage indicators.
- **@TimezoneAware**: All times displayed in user's timezone; uses ZonedDateTime.
- **@KeyboardShortcuts**: Keyboard shortcuts for accessibility and power users.
- **@HoverPrefetch**: Hover triggers data prefetch (200ms debounce).
- **@Upload**: File upload logic.
- **@FileHandling**: File manipulation (read, write, copy).
- **@SandboxIframe**: Runs content inside a sandboxed iframe (e.g., Monaco editor).
- **@A2AFlow**: Agent-to-agent communication flow.
- **@WorkflowExecution**: Workflow execution display and state machine.
- **@Recurring**: Recurring event logic (rschedule + Temporal adapter).
- **@RealtimeLimits**: Realtime channel and memory limits.
- **@UploadSecurity**: File upload security scanning (ClamAV).
- **@RecurrenceEngine**: Recurrence rule engine.

**Spec/Architecture tags** (for documentation, not runtime):

- **@SpecTemplate**: Document follows SPEC-TEMPLATE.md.
- **@ComponentTiering**: Tier 1 (standalone spec), Tier 2 (grouped module), Tier 3 (design system only).
- **@CrossCuttingSpec**: Specification for a cross‑cutting service.
- **@FlowContract**: Contract for a user‑facing flow.
- **@APIContract**: OpenAPI 3.1 contract.
- **@EventContract**: Event and webhook contract.
- **@TestContract**: Testing contract and coverage targets.
- **@OpsRunbook**: Operational runbook.
- **@FeatureFlag**: Feature flag usage and rollout.
- **@CostControl**: Cost tracking and budgeting.
- **@MigrationStrategy**: Database migration strategy (expand‑contract, etc.).
- **@Observability**: Observability instrumentation.
- **@SecurityMatrix**: Security control mapping.
- **@MCPSecurity**: MCP security enforcement.
- **@Passkeys**: Passkey/WebAuthn integration.
- **@TauriDesktop**: Tauri desktop application capabilities.
- **@MobileNotif**: Mobile push notifications.
- **@AIGuardrails**: AI guardrails (input/output/runtime).
- **@SSRFPrevention**: Server‑side request forgery protection.
- **@PrivacyAI**: AI privacy controls (training opt‑out, differential privacy).
- **@StripeBilling**: Stripe billing integration.
- **@ComplianceCode**: Compliance automation (SOC2, EU AI Act).
- **@YjsLifecycle**: Yjs collaboration lifecycle (garbage collection, undo, snapshots).
- **@NylasV3**: Nylas v3 webhook processing.
- **@OTelGenAI**: OpenTelemetry GenAI instrumentation.
- **@OfflineFirst**: Offline‑first data patterns (tombstones, idempotency keys).

When you see a tag like `@MotionGuard, @OptimisticMutation` in a component entry, refer back here for the exact expectation.

---

## Domain pattern definitions

These terms describe recurring architectural strategies. They are used in rules and specs to avoid repetition.

- **ORG scoping**: Every database row belongs to exactly one organization (`org_id` column). Row‑Level Security (RLS) enforces that users only see their own org's data.
- **Server‑wins rollback**: On conflict between client and server state, the server state replaces the client state and a rollback event is triggered.
- **Last‑write‑wins (LWW)**: Conflict resolution uses a `uat` (updated‑at) timestamp column; the newest timestamp wins.
- **Idempotency key (IC)**: Every asynchronous operation carries a key composed of `actor_id + monotonic_counter`; enforced unique in the database to prevent duplicate processing.
- **Expand‑contract (EBC)**: Database schema changes are applied in two steps: first add new columns/tables (expand), then remove old ones later (contract), ensuring zero‑downtime.
- **Zero‑downtime (ZDT)**: Deployments and migrations cause no service interruption.
- **Error budget (EB)**: Allowed failure window for an SLO before its availability target is breached.
- **Burn rate (BR)**: How fast the error budget is consumed; triggers alerts.