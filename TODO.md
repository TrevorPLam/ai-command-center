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
- [ ] **UPD‑007A**: Create a single `CommandCenterDB` schema in a new foundation rule, with module‑prefixed stores.  
- [ ] **UPD‑007B**: In each module’s Dexie setup, replace independent `new Dexie(...)` with reference to the centralized database.  
- [ ] **UPD‑007C**: Add a global quota manager specification that calls `navigator.storage.estimate()` and warns at 80% usage.

### Task UPD‑008: Build Shared SanitizedHTML Component
**Priority:** 🟠 Medium | **Est. Effort:** 0.5 hour | **Depends On:** UPD‑000

**Files to Update:** `01-Foundations.md` (new cross‑cutting rule), `09-Email.md`, `06-News.md`, `12-Documents.md`, `14-Research.md`

**What to Change:**
- [ ] **UPD‑008A**: Create a `SanitizedHTML` component spec using DOMPurify + `html-react-parser`.  
- [ ] **UPD‑008B**: Replace all `dangerouslySetInnerHTML` usage in the above modules with `SanitizedHTML`.

---

## Phase 2 — Module‑Specific Rescoping

### Task UPD‑009: Replace Documents Operational Transforms with Yjs
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** UPD‑007 (Centralized Dexie)

**Files to Update:** `12-Documents.md` (DOC‑008, DOC‑010)

**What to Change:**
- [ ] **UPD‑009A**: Replace the `OperationalTransform` class with Yjs `Y.Text`, using `y-indexeddb` for persistence.  
- [ ] **UPD‑009B**: Update the collaboration cursor overlay to use Yjs awareness.  
- [ ] **UPD‑009C**: Reduce estimated effort for real‑time collaboration from 3 hours to 1.5 hours.

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
- [ ] Centralized `CommandCenterDB` schema created
- [ ] `SanitizedHTML` component specified

**Phase 2:**
- [ ] Documents OT replaced with Yjs
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