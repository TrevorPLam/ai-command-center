# 17-Updates — Specification Normalization & Enhancement Task List

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.  
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.  
> **Purpose**: Consolidate research findings into actionable, ordered updates across all 16 specification files. This task list transforms the diagnosis into explicit spec changes that normalize patterns, close critical gaps, and unify shared infrastructure.

---

## 📐 Reasoning Memo: Why a Dedicated Update Task List is Necessary

The 16-file specification suite, while mature, contains latent inconsistencies and duplicated patterns identified through multi‑lens analysis. Implementing the modules as written would lock in 4× redundant recurrence engines, divergent offline sync implementations, and known bugs (`Set` serialization, `LayoutGroup` omission). A single pass over the specification documents, informed by the research findings, eliminates ~30% of projected duplicated effort and prevents a cascade of P0 regression fixes later.

The updates are organized into **five phases**:

- **Phase 0 — Immediate Critical Fixes**: Bugs that block implementation and must be resolved before any code is written.
- **Phase 1 — Shared Infrastructure Extraction**: Primitives that appear in ≥2 modules but are never consolidated; build once, use everywhere.
- **Phase 2 — Module‑Specific Rescoping**: High‑risk modules (Conference, Documents, Workflow) that need targeted spec revisions.
- **Phase 3 — Foundation Enhancements**: Cross‑cutting improvements (testing, security, accessibility) that affect multiple modules.
- **Phase 4 — Normalization & Final Polish**: Version numbering, deprecation flags, and the final consistency pass.

Each task includes the files to update, the specific sections/tasks within them, and the rationale.

---

## Phase 0 — Immediate Critical Fixes

### Task UPD‑000: Fix `Set` Serialization in Zustand Persisted Slices
**Priority:** 🔴 Critical | **Est. Effort:** 1 hour | **Depends On:** None

**Files to Update:** `04-Projects.md` (PROJ‑001), `10-Lists.md` (LIST‑001)

**What to Change:**
- [x] **UPD‑000A**: In `PROJ‑001A`, change `expandedTaskIds: Set<string>` and `selectedTaskIds: Set<string>` to `string[]`. Add a note: “`Set` is not serializable; store as array and derive `Set` via `useMemo` where needed.”  
- [x] **UPD‑000B**: In `PROJ‑001E` persist config, ensure `expandedTaskIds` and `selectedTaskIds` are excluded from `partialize` since they are ephemeral UI state.  
- [x] **UPD‑000C**: In `LIST‑001A`, apply the same `Set → string[]` conversion for `expandedItemIds` and `selectedItemIds`.  
- [x] **UPD‑000D**: In `LIST‑001A`, update the slice interface to reflect `string[]`.

### Task UPD‑001: Add `LayoutGroup` Audit to Accessibility & Motion Compliance
**Priority:** 🔴 Critical | **Est. Effort:** 1 hour | **Depends On:** None

**Files to Update:** `01-Foundations.md` (FND‑013), `16-Polish-Validation.md` (POL‑005G)

**What to Change:**
- [x] **UPD‑001A**: In `FND‑013`, add a subtask: "Audit all components using `layoutId`; verify each is wrapped in a module‑scoped `LayoutGroup` to prevent namespace collisions."
- [x] **UPD‑001B**: In `POL‑005G` Motion Compliance Checklist, elevate the existing `layoutId` / `LayoutGroup` line to a prominent warning with an explicit audit requirement.
- [x] **UPD‑001C**: Add a note to `04-Projects.md` Kanban and `10-Lists.md` drag‑and‑drop sections referencing the `LayoutGroup` wrapper.

### Task UPD‑002: Replace `focusTriggerRef` in Zustand with Imperative Focus Registry
**Priority:** 🔴 Critical | **Est. Effort:** 0.5 hour | **Depends On:** None

**Files to Update:** `01-Foundations.md` (FND‑005, FND‑011, FND‑012)

**What to Change:**
- [x] **UPD‑002A**: In `FND‑005E`, replace `focusTriggerRef` state with a note: “Use an imperative focus registry (module‑scoped `Map`) outside the Zustand store; never store React refs in Zustand.”  
- [x] **UPD‑002B**: Update `FND‑011F` and `FND‑012J` focus restoration subtasks to reference the imperative registry.

### Task UPD‑003: Enforce `cancelQueries` Before Optimistic Updates in v1 Modules
**Priority:** 🔴 Critical | **Est. Effort:** 1 hour | **Depends On:** None

**Files to Update:** `08-Workflow.md`, `09-Email.md`, `11-Contacts.md`, `12-Documents.md`

**What to Change:**
- [x] **UPD‑003A**: In each module’s mutation hooks section, ensure every `onMutate` handler begins with `await queryClient.cancelQueries(...)` before `getQueryData` / `setQueryData`. Add explicit subtask for this.  
- [x] **UPD‑003B**: Add an anti‑pattern warning: “Skipping `cancelQueries` creates race conditions when a background refetch overwrites the optimistic state.”

---

## Phase 1 — Shared Infrastructure Extraction

### Task UPD‑004: Create Shared Recurrence Engine Specification
**Priority:** 🔴 High | **Est. Effort:** 2 hours | **Depends On:** UPD‑000–UPD‑003

**Files to Update:** New file `17-SharedRecurrence.md`, plus `05-Calendar.md`, `07-Budget.md`, `04-Projects.md`, `10-Lists.md`

**What to Change:**
- [x] **UPD‑004A**: Create `17-SharedRecurrence.md` defining `RecurrenceEngine` (wraps `rrule.js`), `RecurrenceEditor` (shared UI), and `recurrenceSchema` (Zod validation for RRULE).
- [x] **UPD‑004B**: In `05-Calendar.md` (CAL‑013), replace inline RRULE handling with a reference to `RecurrenceEngine`.
- [x] **UPD‑004C**: In `07-Budget.md` (BUDG‑010), replace custom recurrence with `RecurrenceEngine`.
- [x] **UPD‑004D**: In `04-Projects.md` (PROJ‑013), replace custom scheduler with `RecurrenceEngine`.
- [x] **UPD‑004E**: In `10-Lists.md` (LIST‑010), replace custom recurrence with `RecurrenceEngine`.

### Task UPD‑005: Extract Shared Drag‑and‑Drop Configuration
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** UPD‑000–UPD‑003

**Files to Update:** `01-Foundations.md` (new section in Cross‑Cutting), `04-Projects.md`, `10-Lists.md`

**What to Change:**
- [x] **UPD‑005A**: In `01-Foundations.md`, add a cross‑cutting rule: “All dnd‑kit usage must use the shared `useDndSensors()` hook (exported from `src/shared/dnd`).”  
- [x] **UPD‑005B**: Create the hook specification: `PointerSensor` with `activationConstraint.distance: 5`, `KeyboardSensor` with `sortableKeyboardCoordinates`.  
- [x] **UPD‑005C**: In `04-Projects.md` (PROJ‑C06) and `10-Lists.md` (LIST‑C10), replace inline sensor configurations with reference to the shared hook.

### Task UPD‑006: Create Unified Optimistic Mutation Wrapper
**Priority:** 🔴 High | **Est. Effort:** 1.5 hours | **Depends On:** UPD‑000–UPD‑003

**Files to Update:** `01-Foundations.md` (new section in FND‑006), all module‑specific mutation sections.

**What to Change:**
- [x] **UPD‑006A**: In `01-Foundations.md`, add a cross‑cutting rule: “All TanStack Query mutations must use the shared `useOptimisticMutation()` wrapper that enforces `cancelQueries → snapshot → setQueryData → rollback → onSettled invalidate.”  
- [x] **UPD‑006B**: In each module’s hooks file, replace explicit mutation patterns with `useOptimisticMutation({ queryKey, mutationFn, updateFn })`.
### Task UPD‑007: Centralize IndexedDB (Dexie) Schema
**Priority:** 🔴 High | **Est. Effort:** 2 hours | **Depends On:** UPD‑000–UPD‑003

**Files to Update:** `06-News.md`, `07-Budget.md`, `09-Email.md`, `10-Lists.md`, `11-Contacts.md`, `12-Documents.md`, new foundation rule.

**What to Change:**
- [x] **UPD‑007A**: Create a single `CommandCenterDB` schema in a new foundation rule, with module‑prefixed stores.
- [x] **UPD‑007B**: In each module's Dexie setup, replace independent `new Dexie(...)` with reference to the centralized database.
- [x] **UPD‑007C**: Add a global quota manager specification that calls `navigator.storage.estimate()` and warns at 80% usage.

### Task UPD‑008: Build Shared SanitizedHTML Component
**Priority:** 🟠 Medium | **Est. Effort:** 0.5 hour | **Depends On:** UPD‑000

**Files to Update:** `01-Foundations.md` (new cross‑cutting rule), `09-Email.md`, `06-News.md`, `12-Documents.md`, `14-Research.md`

**What to Change:**
- [x] **UPD‑008A**: Create a `SanitizedHTML` component spec using DOMPurify + `html-react-parser`.  
- [x] **UPD‑008B**: Replace all `dangerouslySetInnerHTML` usage in the above modules with `SanitizedHTML`.

---

## Phase 2 — Module‑Specific Rescoping

### Task UPD‑009: Replace Documents Operational Transforms with Yjs
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** UPD‑007 (Centralized Dexie)

**Files to Update:** `12-Documents.md` (DOC‑008, DOC‑010)

**What to Change:**
- [x] **UPD‑009A**: Replace the `OperationalTransform` class with Yjs `Y.Text`, using `y-indexeddb` for persistence.  
- [x] **UPD‑009B**: Update the collaboration cursor overlay to use Yjs awareness.  
- [x] **UPD‑009C**: Reduce estimated effort for real‑time collaboration from 3 hours to 1.5 hours.

### Task UPD‑010: Re‑scope Conference Module MVP
**Priority:** 🔴 High | **Est. Effort:** 1.5 hours | **Depends On:** None

**Files to Update:** `13-Conference.md` (CONF‑002, CONF‑007)

**What to Change:**
- [ ] **UPD‑010A**: Replace custom WebRTC roundtable layout with `@livekit/components-react` `GridLayout` for MVP; defer circular layout.  
- [ ] **UPD‑010B**: Split Conference into two tasks: `CONF‑WebRTC` (video) and `CONF‑OT` (collaborative editing, deferred to v2).  
- [ ] **UPD‑010C**: Add a note about `MediaRecorder` format limitations (WebM in Chrome).

### Task UPD‑011: Add First‑Use ONNX Loading UX to RAG Modules
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** UPD‑007

**Files to Update:** `03-Chat.md` (CHAT‑018), `14-Research.md` (RES‑003)

**What to Change:**
- [ ] **UPD‑011A**: In `CHAT‑018C`, add a subtask: “Implement `useEmbeddingSetup()` hook with download progress, compilation indicator, and storage permission request.”  
- [ ] **UPD‑011B**: In `RES‑003D`, reference the same setup hook.  
- [ ] **UPD‑011C**: Add 30‑second timeout guard for embedding generation.

### Task UPD‑012: Replace Budget AI Anomaly Detection with Client‑Side Z‑Score
**Priority:** 🟠 Medium | **Est. Effort:** 0.5 hour | **Depends On:** None

**Files to Update:** `07-Budget.md` (BUDG‑014)

**What to Change:**
- [ ] **UPD‑012A**: Replace mock AI service with `Iterflow`‑based z‑score analysis for anomaly detection.  
- [ ] **UPD‑012B**: Add configuration UI for z‑score threshold.

---

## Phase 3 — Foundation Enhancements

### Task UPD‑013: Update Dependencies to Pinned Versions
**Priority:** 🔴 High | **Est. Effort:** 0.5 hour | **Depends On:** None

**Files to Update:** `01-Foundations.md` (FND‑002)

**What to Change:**
- [ ] **UPD‑013A**: Pin `zustand@5.0.11` (latest released), verify `motion@12.38.0` exists or adjust.  
- [ ] **UPD‑013B**: Add `rrule.js@2.7.2`, `yjs`, `y-indexeddb`, `chrono-node`, `Iterflow` to FND‑002.  

### Task UPD‑014: Add Streaming (SSE) Test Patterns
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** UPD‑000

**Files to Update:** `01-Foundations.md` (FND‑004), `03-Chat.md` (CHAT‑007)

**What to Change:**
- [ ] **UPD‑014A**: In `FND‑004`, add a testing pattern for `ReadableStream` + `AbortController` using Vitest mocks.  
- [ ] **UPD‑014B**: In `CHAT‑007` tests, add concrete test cases for partial chunk reassembly and abort error suppression.

### Task UPD‑015: Add Code‑Splitting Strategy for Heavy Libraries
**Priority:** 🔴 High | **Est. Effort:** 1.5 hours | **Depends On:** UPD‑010, UPD‑011

**Files to Update:** `16-Polish-Validation.md` (POL‑001), `03-Chat.md` (CHAT‑011), `08-Workflow.md` (FLOW‑001)

**What to Change:**
- [ ] **UPD‑015A**: In `POL‑001B`, add explicit `manualChunks` entries for Monaco, React Flow, `react-big-calendar`, `@babel/standalone`, and `tesseract.js`.  
- [ ] **UPD‑015B**: In `CHAT‑011` and `FLOW‑001`, add a note that Monaco and React Flow must be loaded lazily with a stub.  
- [ ] **UPD‑015C**: In `POL‑001`, add a subtask to verify that the combined uncompressed size of all heavy libraries is < 4MB with all modules loaded.

### Task UPD‑016: Ensure WCAG 2.5.7 Single‑Pointer Alternatives for All Drag Actions
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** UPD‑005

**Files to Update:** `05-Calendar.md` (CAL‑010), `04-Projects.md` (PROJ‑004F), `10-Lists.md` (LIST‑004B)

**What to Change:**
- [ ] **UPD‑016A**: In each drag‑based view, add a mandatory “Move to…” button alternative (already correctly specified in Projects).  
- [ ] **UPD‑016B**: In `05-Calendar.md`, add explicit keyboard alternative for event creation (click‑to‑create).  

---

## Phase 4 — Normalization & Final Polish

### Task UPD‑017: Renumber and Version All Specification Files
**Priority:** 🟠 Medium | **Est. Effort:** 1 hour | **Depends On:** All previous UPD tasks

**Files to Update:** All 16 files + new files created

**What to Change:**
- [ ] **UPD‑017A**: Re‑index all files to a consistent `01‑` through `22‑` numbering, with internal headings matching file numbers.  
- [ ] **UPD‑017B**: Update all cross‑references within the specs.  
- [ ] **UPD‑017C**: Add version headers and reasoning memos for each module updated.

### Task UPD‑018: Create Shared Primitives Specification Document
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** UPD‑004 through UPD‑008

**Files to Update:** New file `18-SharedPrimitives.md`

**What to Change:**
- [ ] **UPD‑018A**: Consolidate all shared component specifications into a single document: `DragOverlay`, `BulkActionBar`, `EmptyState`, `Skeleton`, `ConfirmDialog`, `ZodForm`, `PriorityBadge`, `TagPicker`, `DateRangePicker`, `ActivityTimeline`, `ShareDialog`, `MotionWrapper`, `FileUploadZone`, `InlineEditField`.  
- [ ] **UPD‑018B**: Define the file tree for `src/shared/`.

### Task UPD‑019: Update Cross‑Module Dependency Graph
**Priority:** 🟢 Low | **Est. Effort:** 0.5 hour | **Depends On:** UPD‑017, UPD‑018

**Files to Update:** All dependency graph sections

**What to Change:**
- [ ] **UPD‑019A**: Insert the shared primitives as a dependency for appropriate modules.  
- [ ] **UPD‑019B**: Mark deprecated tasks (e.g., Conference OT, custom recurrence) with migration notes.

### Task UPD‑020: Final Consistency Audit
**Priority:** 🔴 High | **Est. Effort:** 2 hours | **Depends On:** UPD‑000 through UPD‑019

**Files to Update:** All files

**What to Change:**
- [ ] **UPD‑020A**: Run a cross‑reference check for every anti‑pattern warning (e.g., `react‑window` deprecated → TanStack Virtual).  
- [ ] **UPD‑020B**: Verify all `Set` usage in persisted state has been fixed.  
- [ ] **UPD‑020C**: Ensure all modules have consistent `onSettled` invalidation pattern.  
- [ ] **UPD‑020D**: Confirm all v1 modules have a migrated version header.

---

## 📊 Dependency Graph for Update Tasks

```
UPD‑000 (Set fix)
UPD‑001 (LayoutGroup audit)
UPD‑002 (focusTriggerRef removal)
UPD‑003 (cancelQueries fix)
     │
     ├── UPD‑004 (Recurrence engine)
     ├── UPD‑005 (dnd‑kit shared)
     ├── UPD‑006 (Optimistic mutation wrapper)
     ├── UPD‑007 (Centralized Dexie)
     └── UPD‑008 (SanitizedHTML)
              │
              ├── UPD‑009 (Documents Yjs) depends on UPD‑007
              ├── UPD‑010 (Conference rescope)
              ├── UPD‑011 (ONNX setup UX) depends on UPD‑007
              ├── UPD‑012 (Budget z‑score)
              └── UPD‑013 (Dependency versions)
                       │
                       ├── UPD‑014 (SSE tests)
                       ├── UPD‑015 (Bundle strategy) depends on UPD‑010, UPD‑011
                       └── UPD‑016 (WCAG 2.5.7) depends on UPD‑005
                                │
                                ├── UPD‑017 (Renumbering)
                                ├── UPD‑018 (Shared Primitives doc) depends on UPD‑004‑008
                                ├── UPD‑019 (Dependency graphs update)
                                └── UPD‑020 (Final consistency audit) ← depends on all
```

---

## 🏁 Update Completion Checklist

**Phase 0:**
- [ ] All `Set<string>` in persisted state converted to `string[]`
- [ ] `focusTriggerRef` replaced with imperative registry
- [ ] `cancelQueries` enforced in all v1 module mutations

**Phase 1:**
- [ ] `17-SharedRecurrence.md` created and 4 modules updated
- [x] Shared `useDndSensors()` hook specified
- [x] Unified `useOptimisticMutation()` hook specified
- [x] Centralized `CommandCenterDB` schema created
- [x] `SanitizedHTML` component specified

**Phase 2:**
- [x] Documents OT replaced with Yjs
- [ ] Conference rescoped to LiveKit rectangular grid
- [ ] ONNX first‑use UX added to Chat and Research
- [ ] Budget anomaly detection switched to client‑side z‑score

**Phase 3:**
- [ ] Dependencies updated with pinned versions and new libraries
- [ ] SSE test patterns documented
- [ ] Heavy library code‑splitting strategy added
- [ ] WCAG 2.5.7 alternatives mandated for all drag operations

**Phase 4:**
- [ ] All files renumbered and cross‑referenced
- [ ] `18-SharedPrimitives.md` created
- [ ] All dependency graphs updated
- [ ] Final cross‑reference audit completed

**Success Metric:** Post‑update, the total estimated effort for duplicate implementations will decrease by ≥25%, and all P0 persistence bugs will be eliminated before any component code is written.

---

## Phase 5 — New Feature Extensions (from User Desire Synthesis)

> **Purpose**: Add 17 new feature ideas derived from user desire synthesis. These are pure frontend UI/UX additions that extend existing modules or create new standalone spec files. All reuse existing mock data infrastructure, glass-aesthetic, motion hierarchy, and cross-cutting foundations.

### Task UPD‑021: Create Agent Observatory Dashboard
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** UPD‑017

**Files to Update:** `02-Dashboard.md` (new task DASH‑008 or extend DASH‑004)

**What to Change:**
- [ ] **UPD‑021A**: Create new task **DASH‑008** (Agent Observatory Dashboard) as a full-page "mission control" view.
- [ ] **UPD‑021B**: Specify live status display for all agents (online/offline, active tasks, token costs).
- [ ] **UPD‑021C**: Add audit trail component showing recent agent actions with timestamps.
- [ ] **UPD‑021D**: Integrate with existing AgentFleetPanel data model.
- [ ] **UPD‑021E**: Apply Alive-tier motion for status indicators and Quiet-tier for audit entries.

### Task UPD‑022: Add AI Decision Justification Panel
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** UPD‑017

**Files to Update:** `08-Workflow.md` (new task FLOW‑005.1, extend FLOW‑005)

**What to Change:**
- [ ] **UPD‑022A**: Create subtask **FLOW‑005.1** (AI Decision Justification Panel) extending Execution Monitoring.
- [ ] **UPD‑022B**: Specify reasoning chain display with step-by-step breakdown.
- [ ] **UPD‑022C**: Add confidence score visualization (progress bar with color coding).
- [ ] **UPD‑022D**: Implement "what-if" adjustment controls for proposed actions.
- [ ] **UPD‑022E**: Use Quiet-tier motion for panel reveal.

### Task UPD‑023: Create Permission Scope Manager
**Priority:** 🟠 Medium | **Est. Effort:** 2.5 hours | **Depends On:** UPD‑017

**Files to Update:** `15-Settings.md` (new task SET‑008 or extend SET‑003)

**What to Change:**
- [ ] **UPD‑023A**: Create new task **SET‑008** (Permission Scope Manager) as visual policy builder.
- [ ] **UPD‑023B**: Specify per-agent permission UI (apps, actions, confirmation prompts).
- [ ] **UPD‑023C**: Add connection to Agent Studio for policy application.
- [ ] **UPD‑023D**: Implement permission scope visualization with tree/grouped view.
- [ ] **UPD‑023E**: Use Alive-tier motion for scope changes.

### Task UPD‑024: Implement Proactive Insight Feed ("Pulse")
**Priority:** 🔴 High | **Est. Effort:** 2 hours | **Depends On:** UPD‑017

**Files to Update:** `01-Foundations.md` (new task FND‑015)

**What to Change:**
- [ ] **UPD‑024A**: Create new foundation task **FND‑015** (Proactive Insight Feed) as global always-visible panel.
- [ ] **UPD‑024B**: Specify root layout integration (persistent side panel or bottom bar).
- [ ] **UPD‑024C**: Define insight types: unreplied emails, deadline collisions, well-being nudges.
- [ ] **UPD‑024D**: Add AI-detected pattern surfacing logic (mock data).
- [ ] **UPD‑024E**: Apply Alive-tier motion for new insights (spring physics, stagger).

### Task UPD‑025: Extend AmbientStatusBanner with Intentionality Nudge
**Priority:** 🟠 Medium | **Est. Effort:** 1 hour | **Depends On:** UPD‑017

**Files to Update:** `02-Dashboard.md` (extend DASH‑003)

**What to Change:**
- [ ] **UPD‑025A**: Extend **DASH‑003** (AmbientStatusBanner) with intentionality tracking.
- [ ] **UPD‑025B**: Add color change logic when user drifts from declared intention.
- [ ] **UPD‑025C**: Implement non-judgmental nudge messaging.
- [ ] **UPD‑025D**: Add do-not-disturb mode respect.
- [ ] **UPD‑025E**: Use CSS @property animated gradient border for nudge state.

### Task UPD‑026: Create Context‑Aware Briefing
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** UPD‑017

**Files to Update:** `05-Calendar.md` (new task CAL‑015)

**What to Change:**
- [ ] **UPD‑026A**: Create new task **CAL‑015** (Pre‑Meeting Briefing) as prep card before events.
- [ ] **UPD‑026B**: Specify briefing content: attendees, recent emails, related documents, previous action items.
- [ ] **UPD‑026C**: Add trigger logic (5-10 minutes before event).
- [ ] **UPD‑026D**: Integrate with existing Calendar, Email, Documents data models.
- [ ] **UPD‑026E**: Use Quiet-tier motion for card reveal.

### Task UPD‑027: Create Personal Timeline Explorer (New Spec File)
**Priority:** 🔴 High | **Est. Effort:** 4 hours | **Depends On:** UPD‑017

**Files to Update:** New file `19-PersonalTimeline.md`

**What to Change:**
- [ ] **UPD‑027A**: Create `19-PersonalTimeline.md` spec file following existing pattern.
- [ ] **UPD‑027B**: Define domain model: TimelineEvent, TimelineFilter, ZoomLevel.
- [ ] **UPD‑027C**: Specify scrollable, zoomable timeline UI (react-window for virtualization).
- [ ] **UPD‑027D**: Add timeline data aggregation from all modules (Calendar, Projects, Chat, etc.).
- [ ] **UPD‑027E**: Implement zoom controls (day/week/month/year views).
- [ ] **UPD‑027F**: Add search and filter capabilities.
- [ ] **UPD‑027G**: Use Alive-tier motion for timeline navigation.

### Task UPD‑028: Add Relationship Graph / Personal CRM
**Priority:** 🟠 Medium | **Est. Effort:** 3 hours | **Depends On:** UPD‑017

**Files to Update:** `11-Contacts.md` (new task CONT‑028)

**What to Change:**
- [ ] **UPD‑028A**: Create new task **CONT‑028** (Relationship Graph Dashboard).
- [ ] **UPD‑028B**: Specify force-directed graph visualization (react-force-graph or D3).
- [ ] **UPD‑028C**: Add AI-suggested reconnection moments based on interaction history.
- [ ] **UPD‑028D**: Implement draft message suggestions for reconnection.
- [ ] **UPD‑028E**: Build on existing Contacts relationship data model.
- [ ] **UPD‑028F**: Use Quiet-tier motion for graph node hover.

### Task UPD‑029: Create Life Admin Concierge (New Spec File)
**Priority:** 🟠 Medium | **Est. Effort:** 3 hours | **Depends On:** UPD‑017

**Files to Update:** New file `20-LifeAdmin.md`

**What to Change:**
- [ ] **UPD‑029A**: Create `20-LifeAdmin.md` spec file following existing pattern.
- [ ] **UPD‑029B**: Define domain model: LifeAdminTask, DecisionCard, BookingIntegration.
- [ ] **UPD‑029C**: Specify low-friction input interface (quick capture, voice input).
- [ ] **UPD‑029D**: Add decision card component for complex choices (insurance plans, etc.).
- [ ] **UPD‑029E**: Implement booking integration stubs (doctor appointments, services).
- [ ] **UPD‑029F**: Use Alive-tier motion for task completion.

### Task UPD‑030: Create AI Journal & Reflection Partner (New Spec File)
**Priority:** 🟠 Medium | **Est. Effort:** 3 hours | **Depends On:** UPD‑017

**Files to Update:** New file `21-AIJournal.md`

**What to Change:**
- [ ] **UPD‑030A**: Create `21-AIJournal.md` spec file following existing pattern.
- [ ] **UPD‑030B**: Define domain model: JournalEntry, ReflectionPrompt, PatternInsight.
- [ ] **UPD‑030C**: Specify private journaling space with rich text editor.
- [ ] **UPD‑030D**: Add AI-powered reflection and pattern detection (mock data).
- [ ] **UPD‑030E**: Implement Socratic question generation.
- [ ] **UPD‑030F**: Design distinct visual style from Chat (calmer, more contemplative).
- [ ] **UPD‑030G**: Use Quiet-tier motion throughout.

### Task UPD‑031: Add Gamified Quest System
**Priority:** 🟢 Low | **Est. Effort:** 2.5 hours | **Depends On:** UPD‑017

**Files to Update:** `04-Projects.md` (new task PROJ‑026), `10-Lists.md` (new task LIST‑025)

**What to Change:**
- [ ] **UPD‑031A**: Create **PROJ‑026** (Quest Log) in Projects module.
- [ ] **UPD‑031B**: Create **LIST‑025** (Quest Log) in Lists module.
- [ ] **UPD‑031C**: Specify XP, levels, and achievements system.
- [ ] **UPD‑031D**: Add overlay that turns tasks/habits into quests.
- [ ] **UPD‑031E**: Implement Alive-tier celebration animations for level-ups.
- [ ] **UPD‑031F**: Add progress visualization (XP bar, achievement badges).

### Task UPD‑032: Implement Context Bridge
**Priority:** 🟠 Medium | **Est. Effort:** 1.5 hours | **Depends On:** UPD‑017

**Files to Update:** `01-Foundations.md` (new task FND‑016)

**What to Change:**
- [ ] **UPD‑032A**: Create new foundation task **FND‑016** (Context Save/Restore).
- [ ] **UPD‑032B**: Specify tiny floating button component for "brain save-point" capture.
- [ ] **UPD‑032C**: Define context snapshot structure (current chat, document, project state).
- [ ] **UPD‑032D**: Add restoration and sharing functionality.
- [ ] **UPD‑032E**: Use Alive-tier motion for button interactions.

### Task UPD‑033: Add Cognitive Load Meter
**Priority:** 🟠 Medium | **Est. Effort:** 1.5 hours | **Depends On:** UPD‑017

**Files to Update:** `01-Foundations.md` (new task FND‑017)

**What to Change:**
- [ ] **UPD‑033A**: Create new foundation task **FND‑017** (Cognitive Load Indicator).
- [ ] **UPD‑033B**: Specify ambient header bar component for load display.
- [ ] **UPD‑033C**: Define load estimation logic (context switches, meetings, task count).
- [ ] **UPD‑033D**: Add intervention suggestions (take break, focus mode, etc.).
- [ ] **UPD‑033E**: Use color-coded indicators (green/yellow/red) with CSS @property animation.

### Task UPD‑034: Add Multi‑Audience Translator
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** UPD‑017

**Files to Update:** `03-Chat.md` (new task CHAT‑023), `09-Email.md` (new task EMAIL‑014)

**What to Change:**
- [ ] **UPD‑034A**: Create **CHAT‑023** (Multi‑Audience Translator) in Chat module.
- [ ] **UPD‑034B**: Create **EMAIL‑014** (Multi‑Audience Translator) in Email module.
- [ ] **UPD‑034C**: Specify one-click rewrite into personas (Executive summary, Engineer, Client‑friendly).
- [ ] **UPD‑034D**: Add persona chips in composer interfaces.
- [ ] **UPD‑034E**: Use Quiet-tier motion for rewrite preview.

### Task UPD‑035: Create Meeting Intelligence Hub
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** UPD‑017

**Files to Update:** `05-Calendar.md` (new task CAL‑016)

**What to Change:**
- [ ] **UPD‑035A**: Create new task **CAL‑016** (Meeting Intelligence Hub).
- [ ] **UPD‑035B**: Specify unified meeting view with pre‑briefing, live, and post‑meeting phases.
- [ ] **UPD‑035C**: Add live transcription with key point extraction (mock data).
- [ ] **UPD‑035D**: Implement post‑meeting action item extraction.
- [ ] **UPD‑035E**: Add searchable meeting archive.
- [ ] **UPD‑035F**: Use Alive-tier motion for live transcription updates.

### Task UPD‑036: Add AI Art Director & Creative Studio
**Priority:** 🟢 Low | **Est. Effort:** 3 hours | **Depends On:** UPD‑017

**Files to Update:** `18-Media.md` (new task MEDIA‑023)

**What to Change:**
- [ ] **UPD‑036A**: Create new task **MEDIA‑023** (Creative Studio).
- [ ] **UPD‑036B**: Specify canvas-based creative workflow component.
- [ ] **UPD‑036C**: Add mood board creation and management.
- [ ] **UPD‑036D**: Implement style guide tools.
- [ ] **UPD‑036E**: Add AI-as-critique feature (mock data for feedback).
- [ ] **UPD‑036F**: Extend existing Media module with collaborative creation.

### Task UPD‑037: Extend Voice Shell with Persona Studio
**Priority:** 🟢 Low | **Est. Effort:** 2 hours | **Depends On:** UPD‑017

**Files to Update:** `01-Foundations.md` (extend FND‑014)

**What to Change:**
- [ ] **UPD‑037A**: Extend **FND‑014** (Voice Shell) with Persona Studio.
- [ ] **UPD‑037B**: Specify persona designer UI (formality, verbosity, humour sliders).
- [ ] **UPD‑037C**: Add context-based switching logic.
- [ ] **UPD‑037D**: Implement playback preview for voice personas.
- [ ] **UPD‑037E**: Use Quiet-tier motion for persona adjustments.

---

## 📊 Updated Dependency Graph for All Tasks

```
UPD‑000 (Set fix)
UPD‑001 (LayoutGroup audit)
UPD‑002 (focusTriggerRef removal)
UPD‑003 (cancelQueries fix)
     │
     ├── UPD‑004 (Recurrence engine)
     ├── UPD‑005 (dnd‑kit shared)
     ├── UPD‑006 (Optimistic mutation wrapper)
     ├── UPD‑007 (Centralized Dexie)
     └── UPD‑008 (SanitizedHTML)
              │
              ├── UPD‑009 (Documents Yjs) depends on UPD‑007
              ├── UPD‑010 (Conference rescope)
              ├── UPD‑011 (ONNX setup UX) depends on UPD‑007
              ├── UPD‑012 (Budget z‑score)
              └── UPD‑013 (Dependency versions)
                       │
                       ├── UPD‑014 (SSE tests)
                       ├── UPD‑015 (Bundle strategy) depends on UPD‑010, UPD‑011
                       └── UPD‑016 (WCAG 2.5.7) depends on UPD‑005
                                │
                                ├── UPD‑017 (Renumbering)
                                ├── UPD‑018 (Shared Primitives doc) depends on UPD‑004‑008
                                ├── UPD‑019 (Dependency graphs update)
                                └── UPD‑020 (Final consistency audit) ← depends on all
                                         │
                                         └── UPD‑021 through UPD‑037 (New Feature Extensions) ← depends on UPD‑017
```

---

## 🏁 Updated Completion Checklist

**Phase 0:**
- [ ] All `Set<string>` in persisted state converted to `string[]`
- [ ] `focusTriggerRef` replaced with imperative registry
- [ ] `cancelQueries` enforced in all v1 module mutations

**Phase 1:**
- [ ] `17-SharedRecurrence.md` created and 4 modules updated
- [x] Shared `useDndSensors()` hook specified
- [x] Unified `useOptimisticMutation()` hook specified
- [x] Centralized `CommandCenterDB` schema created
- [x] `SanitizedHTML` component specified

**Phase 2:**
- [x] Documents OT replaced with Yjs
- [ ] Conference rescoped to LiveKit rectangular grid
- [ ] ONNX first‑use UX added to Chat and Research
- [ ] Budget anomaly detection switched to client‑side z‑score

**Phase 3:**
- [ ] Dependencies updated with pinned versions and new libraries
- [ ] SSE test patterns documented
- [ ] Heavy library code‑splitting strategy added
- [ ] WCAG 2.5.7 alternatives mandated for all drag operations

**Phase 4:**
- [ ] All files renumbered and cross‑referenced
- [ ] `18-SharedPrimitives.md` created
- [ ] All dependency graphs updated
- [ ] Final cross‑reference audit completed

**Phase 5 — New Feature Extensions:**
- [ ] Agent Observatory Dashboard (DASH‑008) specified
- [ ] AI Decision Justification Panel (FLOW‑005.1) specified
- [ ] Permission Scope Manager (SET‑008) specified
- [ ] Proactive Insight Feed "Pulse" (FND‑015) specified
- [ ] Intentionality Nudge System (extend DASH‑003) specified
- [ ] Context‑Aware Briefing (CAL‑015) specified
- [ ] Personal Timeline Explorer (`19-PersonalTimeline.md`) created
- [ ] Relationship Graph / Personal CRM (CONT‑028) specified
- [ ] Life Admin Concierge (`20-LifeAdmin.md`) created
- [ ] AI Journal & Reflection Partner (`21-AIJournal.md`) created
- [ ] Gamified Quest System (PROJ‑026 / LIST‑025) specified
- [ ] Context Bridge (FND‑016) specified
- [ ] Cognitive Load Meter (FND‑017) specified
- [ ] Multi‑Audience Translator (CHAT‑023 / EMAIL‑014) specified
- [ ] Meeting Intelligence Hub (CAL‑016) specified
- [ ] AI Art Director & Creative Studio (MEDIA‑023) specified
- [ ] Voice Persona Studio (extend FND‑014) specified

**Success Metric:** Post‑update, the total estimated effort for duplicate implementations will decrease by ≥25%, all P0 persistence bugs will be eliminated before any component code is written, and 17 new user-desired features will be fully specified with implementation guidance.
