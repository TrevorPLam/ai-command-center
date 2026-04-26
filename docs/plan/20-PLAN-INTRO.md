# Pattern Tags & Domain Shortcuts

**Pattern tags**: Capitalized abbreviations for recurring frontend behaviors. **Domain shortcuts**: Terms for architectural patterns.

---

## Pattern Tags

| Tag | Description |
|---|---|
| **@MotionGuard** | Animate transform/opacity only; respects reduced-motion |
| **@AnimatePresence** | Page-level enter/exit transitions |
| **@Spring** | Spring animation (tension≥300, damping≥30) |
| **@StaggerChildren** | Staggered child animations (max 3) |
| **@OpacityFade** | Opacity fade ≤150ms |
| **@Static** | No animation |
| **@PopLayout** | Pop-in layout animation |
| **@OptimisticMutation** | Immediate UI update, revert on failure, 5s undo |
| **@VirtualizeList** | Virtualized lists for large datasets |
| **@ChatCache** | AI responses cached indefinitely |
| **@InlineEdit** | Click-triggered inline editing, debounced auto-save |
| **@InfiniteScroll** | Infinite scroll pattern |
| **@DebounceAutoSave** | 300ms debounce auto-save |
| **@SSEStream** | Server-Sent Events streaming |
| **@TieredMemory** | Memory tiers: working/episodic/semantic |
| **@PromptCaching** | LLM prompt caching for latency/cost reduction |
| **@TriageColor** | Color-coded triage indicators |
| **@TimezoneAware** | User timezone with ZonedDateTime |
| **@KeyboardShortcuts** | Accessibility/power user shortcuts |
| **@HoverPrefetch** | Hover triggers data prefetch (200ms) |
| **@Upload** | File upload logic |
| **@FileHandling** | File manipulation |
| **@SandboxIframe** | Sandboxed content (Monaco) |
| **@A2AFlow** | Agent-to-agent communication |
| **@WorkflowExecution** | Workflow display + state machine |
| **@Recurring** | Recurring events (rschedule + Temporal) |
| **@RealtimeLimits** | Realtime channel + memory limits |
| **@UploadSecurity** | ClamAV file scanning |
| **@RecurrenceEngine** | Recurrence rule engine |

### Spec/Architecture Tags

| Tag | Description |
|---|---|
| **@SpecTemplate** | SPEC-TEMPLATE.md format |
| **@ComponentTiering** | Tier 1 (standalone), Tier 2 (grouped), Tier 3 (design system) |
| **@CrossCuttingSpec** | Cross-cutting service spec |
| **@FlowContract** | User-facing flow contract |
| **@APIContract** | OpenAPI 3.1 contract |
| **@EventContract** | Event + webhook contract |
| **@TestContract** | Testing contract + coverage |
| **@OpsRunbook** | Operational runbook |
| **@FeatureFlag** | Feature flags + rollout |
| **@CostControl** | Cost tracking + budgeting |
| **@MigrationStrategy** | DB migration (expand-contract) |
| **@Observability** | Observability instrumentation |
| **@SecurityMatrix** | Security control mapping |
| **@MCPSecurity** | MCP security enforcement |
| **@Passkeys** | WebAuthn integration |
| **@TauriDesktop** | Tauri desktop capabilities |
| **@MobileNotif** | Mobile push notifications |
| **@AIGuardrails** | AI input/output/runtime guards |
| **@SSRFPrevention** | SSRF protection |
| **@PrivacyAI** | AI privacy controls |
| **@StripeBilling** | Stripe billing |
| **@ComplianceCode** | Compliance automation |
| **@YjsLifecycle** | Yjs collaboration lifecycle |
| **@NylasV3** | Nylas v3 webhooks |
| **@OTelGenAI** | OpenTelemetry GenAI |
| **@OfflineFirst** | Offline-first patterns |

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