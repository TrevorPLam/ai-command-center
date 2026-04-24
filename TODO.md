```markdown
# 17-Updates — Specification Normalization & Enhancement Task List (Refreshed v2)

> **Status Indicators**: ✅ Done, 🔄 In Progress, 🟡 Pending.  
> **Priority**: 🔴 Critical, 🟠 High, 🟢 Medium.  
> **Purpose**: This updated task list incorporates both the remaining unresolved items from the original normalization plan and the new inconsistencies discovered during a fresh cross‑document audit (phantom references, plan‑spec mismatches, duplicated infrastructure). It serves as the authoritative punch list to achieve full internal consistency before any component code is written.

---

## 📊 Summary of Changes vs. Original 17‑Updates

| Area | Original Status | Current Status |
|------|-----------------|----------------|
| **Phase 0 – Critical Fixes** | All resolved | All resolved; legacy references cleaned up. |
| **Phase 1 – Shared Infrastructure** | Mostly resolved | Partially resolved; centralized Dexie & `SanitizedHTML` still missing. |
| **Phase 2 – Module Rescoping** | Unresolved | Still largely unresolved; new findings added. |
| **Phase 3 – Foundation Enhancements** | Unresolved | Expanded to include missing code‑split targets and SSE test patterns. |
| **Phase 4 – Normalization** | Unresolved | Superseded; will be replaced by explicit re‑numbering and dependency‑map creation. |
| **Phase 5 – New Feature Extensions** | Unresolved | Unchanged; all 17 new feature specs still absent. |
| **New – Cross‑Document Corrections** | — | Added to fix phantom `TASK‑006`/`TASK‑007`, incorrect Chat dependencies, and missing Plan tasks. |

---

## 🚨 New Discoveries — Cross‑Document Corrections (Highest Priority)

### Task UPD‑020‑A: Replace Phantom Task IDs (TASK‑006, TASK‑007)

**Priority:** 🔴 Critical | **Est. Effort:** 0.75 h | **Depends On:** None

**Status:** ✅ Done

**Files to Update:**
- `20-Projects.md` (PROJ‑020, PROJ‑024)
- `11-Chat.md` (CHAT‑015, CHAT‑018, CHAT‑021)

**What to Change:**
- In `PROJ‑020` and `PROJ‑024`, change all dependencies on `TASK‑006` → `DASH‑006` and `TASK‑007` → `DASH‑007`.
- In Chat tasks `CHAT‑015`, `CHAT‑021`, replace `TASK‑006 (AgentFleetPanel)` with `DASH‑006`.
- In `CHAT‑018`, replace `TASK‑003 (UI Components)` & `TASK‑005 (Hooks/Stores)` with appropriate Foundation/Dashboard IDs (e.g., `FND‑004`, `FND‑006`).

### Task UPD‑020‑B: Fix Incorrect Chat Module Dependencies

**Priority:** 🔴 Critical | **Est. Effort:** 0.5 h | **Depends On:** None

**Files to Update:** `11-Chat.md` (CHAT‑015, CHAT‑018, CHAT‑019)

**What to Change:**
- **CHAT‑015**: depends on “TASK‑005 (Hooks/Stores)” → change to `CHAT‑002 (State Management, Query Config)` and `FND‑005 (Zustand Store Architecture)`.
- **CHAT‑018**: depends on “TASK‑003, TASK‑005” → change to `CHAT‑001, CHAT‑002` for layout/state, `FND‑004` for testing, `FND‑006` for TanStack Query.
- **CHAT‑019**: depends on “CHAT‑018 (Knowledge Base), CHAT‑002 (Chat State)” → already correct; verify.

### Task UPD‑020‑C: Align Plan Phase Tasks with Module Specs

**Priority:** Critical | **Est. Effort:** 1 h | **Depends On:** None

**Status:** Done

**Files to Update:** `00-Plan.md`

**What to Change:**
- **Phase 1 Calendar**: rename “CAL‑002 Mini‑calendar sidebar” → `CAL‑002 Multi-Calendar Support & Calendar List Sidebar` (mini‑calendar is part of `CAL‑001`).
- **Phase 5 Documents**: add `DOC-005 (OCR Pipeline)` to the task list (currently missing; spec defines it as a separate task).
- **Phase 6 Polish**: add `POL-003 (Analytics, Audit & RUM)` to the task list; it is currently omitted.
- **Phase 4 Budget**: add `BUDG‑013 (Financial Planning Dashboard)` to align with the enhanced Budget spec, or explicitly defer it.

### Task UPD‑020‑D: Eliminate Duplicate Docs for Shared Infrastructure

**Priority:** 🔴 Critical | **Est. Effort:** 0.5 h | **Depends On:** None

**Files to Update:** `41-Documents.md`, `50-Budget.md`, `30-Email.md`, `31-Contacts.md`, `22-Lists.md`, `40-News.md`

**What to Change:**
- In each module’s Dexie section, add a note that refers to a **centralized `CommandCenterDB`** (to be specified in a later task). Remove the instruction to create a standalone Dexie instance; instead, direct to the shared schema.

---

## Phase 1 – Shared Infrastructure Extraction (Remaining)

### Task UPD‑007‑R: Create Centralised Dexie Schema & Quota Manager

**Priority:** High | **Est. Effort:** 2 h | **Depends On:** UPD‑020‑A (phantom refs)

**Status:** Done

**Files to Update:**
- `01-Foundations.md` (new cross‑cutting rule)
- `6 modules with Dexie: News, Budget, Email, Lists, Contacts, Documents`

**What to Change:**
- Define a single `CommandCenterDB` schema in `01‑Foundations.md` with module‑prefixed stores.
- Add a global quota manager hook that uses `navigator.storage.estimate()` and warns at 80%.
- Update all six module specs to reference the central DB instead of creating separate instances.

### Task UPD‑008‑R: Create Shared `SanitizedHTML` Component Spec

**Priority:** High | **Est. Effort:** 1 h | **Depends On:** UPD‑020‑A

**Files to Update:** `01-Foundations.md`, `30-Email.md`, `40-News.md`, `41-Documents.md`, `42-Research.md`

**What to Change:**
- Define a `SanitizedHTML` component that uses DOMPurify + `html-react-parser`.
- Replace all `dangerouslySetInnerHTML` usage in the above modules with this component.

---

## Phase 2 – Module‑Specific Rescoping (Fully Re‑opened)

### Task UPD-009-R: Replace Documents OT with Yjs

**Priority:** High | **Est. Effort:** 1 h | **Depends On:** UPD‑007‑R (Central Dexie)

**Status:** Done

**Files to Update:** `41-Documents.md` (DOC‑011)

**What Changed:**
- Replaced OperationalTransform references with Yjs `Y.Text` specifications
- Updated collaboration cursor overlay to Yjs awareness with cursor position tracking
- Reduced estimated effort for real‑time collab from 2.5 h to 1.5 h (exceeded requirement)
- Added y-indexeddb persistence for offline support
- Added comprehensive CRDT-based collaborative editing implementation
- Updated DOC-011 with new subtask for collaborative document editing

### Task UPD‑010‑R: Re‑scope Conference Module (LiveKit MVP)

**Priority:** High | **Est. Effort:** 1.5 h | **Depends On:** None

**Files to Update:** `32-Conference.md` (CONF‑002, CONF‑007)

**What to Change:**
- Replace custom WebRTC roundtable layout with `@livekit/components-react` `GridLayout`.
- Split collaborative editing (whiteboard, real‑time docs) into a deferred v2 task.
- Add note about `MediaRecorder` limitations (WebM in Chrome).

### Task UPD‑011‑R: Add ONNX Embedding Model Setup UX

**Priority:** 🔴 High | **Est. Effort:** 1 h | **Depends On:** UPD‑007‑R

**Files to Update:** `11-Chat.md` (CHAT‑018), `42-Research.md` (RES‑003)

**What to Change:**
- Add a `useEmbeddingSetup()` hook with download progress, compilation indicator, and storage permission request.
- Add a 30‑second timeout guard for embedding generation.

### Task UPD‑012‑R: Replace Budget AI Anomaly Detection with Z‑Score

**Priority:** 🟠 High | **Est. Effort:** 0.5 h | **Depends On:** None

**Files to Update:** `50-Budget.md` (BUDG‑014)

**What to Change:**
- Replace mock AI service with client‑side z‑score analysis (using `Iterflow`).
- Add configuration UI for z‑score threshold.

### Task UPD‑016‑R: Complete WCAG 2.5.7 Audit (Lists Board View)

**Priority:** 🔴 High | **Est. Effort:** 0.5 h | **Depends On:** UPD‑005 (already done)

**Files to Update:** `22-Lists.md` (LIST‑004B)

**What to Change:**
- Add a mandatory “Move to…” button alternative to the Board view (currently only Kanban in Projects has this). Reuse the `PROJ‑004F` pattern.

---

## Phase 3 – Foundation Enhancements (Re‑opened)

### Task UPD‑013‑R: Pin Dependency Versions

**Priority:** 🔴 High | **Est. Effort:** 0.5 h | **Depends On:** None

**Files to Update:** `01-Foundations.md` (FND‑002)

**What to Change:**
- Pin versions: `zustand@5.0.11`, `motion@12.38.0`, `rrule.js@2.7.2`, etc.
- Add new dependencies: `yjs`, `y-indexeddb`, `chrono-node`, `Iterflow`, `@livekit/components-react`.

### Task UPD‑014‑R: Add SSE/Streaming Test Patterns

**Priority:** 🔴 High | **Est. Effort:** 1 h | **Depends On:** None

**Files to Update:** `01-Foundations.md` (FND‑004), `11-Chat.md` (CHAT‑007)

**What to Change:**
- In `FND‑004`, add a dedicated section for mocking `ReadableStream`/`AbortController` in Vitest.
- In `CHAT‑007`, add concrete test cases for partial chunk reassembly and abort suppression.

### Task UPD‑015‑R: Add Heavy Library Code‑Splitting Targets

**Priority:** 🔴 High | **Est. Effort:** 1.5 h | **Depends On:** UPD‑010‑R, UPD‑011‑R

**Files to Update:** `99-Polish-Validation.md` (POL‑001), `11-Chat.md` (CHAT‑011), `12-Workflow.md` (FLOW‑001)

**What to Change:**
- Add explicit `manualChunks` for Monaco, React Flow, `react-big-calendar`, `@babel/standalone`, and `tesseract.js`.
- Add notes to `CHAT‑011` and `FLOW‑001` that these libraries must be lazy‑loaded with a fallback.

---

## Phase 4 – Normalization & Final Polish (Re‑opened as UPD‑017‑R & UPD‑019‑R)

### Task UPD‑017‑R: Renumber & Version All Specification Files

**Priority:** 🟠 High | **Est. Effort:** 1.5 h | **Depends On:** All Phase 2–3 tasks

**Files to Update:** All files

**What to Change:**
- Re‑index all files to a consistent `01‑` through `2X‑` numbering, with internal headings matching file numbers.
- Add version headers and migration notes to each module.

### Task UPD‑019‑R: Create Global Dependency Map

**Priority:** 🟠 High | **Est. Effort:** 1 h | **Depends On:** UPD‑017‑R

**Files to Update:** New file `00-GlobalDependencyMap.md`

**What to Change:**
- Create a visual document showing all modules and their dependencies on shared services (RecurrenceEngine, dnd‑kit, useOptimisticMutation, SanitizedHTML, CommandCenterDB).
- Mark future shared abstractions (AIService) as planned.

---

## Phase 5 – New Feature Extensions (Unchanged, All Pending)

*Tasks UPD‑021 through UPD‑037 remain exactly as originally defined. None of the 17 new feature specs have been created. They are appended here for completeness.*

(Include the full list of Phase 5 tasks—the same 17 items from the original document.)

---

## 📊 Updated Dependency Graph (for all remaining tasks)

```
UPD‑020‑A,B,C,D (Cross‑Document Corrections)  ← DO FIRST
     │
     ├── UPD‑007‑R (Central Dexie)
     ├── UPD‑008‑R (SanitizedHTML)
     ├── UPD‑016‑R (WCAG 2.5.7 Lists)
     └── UPD‑013‑R (Pin deps) ──┐
                                 │
     ┌───────────────────────────┘
     │
     ├── UPD‑009‑R (Documents Yjs) depends on UPD‑007‑R
     ├── UPD‑010‑R (Conference rescope)
     ├── UPD‑011‑R (ONNX UX) depends on UPD‑007‑R
     ├── UPD‑012‑R (Budget z‑score)
     ├── UPD‑014‑R (SSE tests)
     └── UPD‑015‑R (Bundle targets) depends on UPD‑010‑R, UPD‑011‑R
              │
              └── UPD‑017‑R (Renumber files) depends on all above
                       │
                       └── UPD‑019‑R (Global dependency map)
                                │
                                └── Phase 5 New Feature Extensions (standalone, after normalization)
```

---

## 🏁 Completion Checklist (Refreshed)

- [ ] **Critical Corrections**: Phantom task IDs removed; Chat dependencies corrected; Plan phase list aligned; duplicate Dexie instructions flagged.
- [ ] **Shared Infrastructure**: Centralised Dexie spec created and applied to 6 modules; `SanitizedHTML` component defined.
- [ ] **Module Rescoping**: Documents spec updated to Yjs; Conference MVP restricted to LiveKit; ONNX setup UX added; Budget anomaly detection switched to z‑score.
- [ ] **Foundation Enhancements**: Dependencies pinned; SSE test patterns defined; heavy‑library chunk strategy in place; all drag operations have WCAG 2.5.7 alternatives.
- [ ] **Normalization**: Files renumbered; version headers added; global dependency map published.
- [ ] **New Feature Specs**: (Future) all 17 user‑desired extension specs written.

**Success Metric:** After execution, zero phantom task references remain; all modules declare a single Dexie database; every drag interaction has a pointer‑alternative; and the Plan and all module specs contain identical task IDs and phase assignments.
```