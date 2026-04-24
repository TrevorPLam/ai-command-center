Based on my comprehensive analysis across four rounds of cross-document auditing, I have created a consolidated `TODO.md` that captures every issue discovered, organized into logical parent tasks with detailed subtasks.

```markdown
# TODO.md — AI Command Center Specification Audit & Remediation Task List

> **Generated**: 2026-04-23  
> **Status**: All tasks pending  
> **Purpose**: This document consolidates all issues discovered during a multi-round cross-document audit of the 40+ specification files. Each task is designed to be small enough for an agentic coding system to execute independently, with clear acceptance criteria, dependencies, and strict rules.

---

## 🔴 Phase 1: Critical Cross-Document Corrections (Must Do First)

---

### TASK-001: Fix Phantom Task IDs Across All Specifications

**Status**: ✅ Done  
**Priority**: 🔴 Critical  
**Parent Task ID**: TASK-001

#### Subtasks

- [ ] **TASK-001-01**: Replace `TASK‑006` with `DASH‑006` and `TASK‑007` with `DASH‑007` in `20-Projects.md` (PROJ‑020, PROJ‑024) and `11-Chat.md` (CHAT‑015, CHAT‑018, CHAT‑021).  
  **Target Files**: `20-Projects.md`, `11-Chat.md`

- [ ] **TASK-001-02**: Replace `TASK‑005 (Hooks/Stores)` with `FND‑005 (Zustand)`, `FND‑006 (TanStack Query)` in `11-Chat.md` (CHAT‑015, CHAT‑018).  
  **Target File**: `11-Chat.md`

- [ ] **TASK-001-03**: Replace `TASK‑003 (UI Components)` with `FND‑004 (Testing Infra)`, `FND‑006 (TanStack Query)` in `11-Chat.md` (CHAT‑018).  
  **Target File**: `11-Chat.md`

- [ ] **TASK-001-04**: Add a cross-reference validation script at `scripts/validate-task-refs.js` that parses all `Depends On` fields in markdown files and verifies each referenced task ID exists in the canonical task registry.  
  **Target File**: `scripts/validate-task-refs.js`

- [ ] **TASK-001-05**: Create a canonical task registry at `docs/task-registry.json` listing every task ID across all specification files.  
  **Target File**: `docs/task-registry.json`

#### Priority / Urgency

🔴 Critical. Phantom references create dead links that will derail agentic coding. Without fixing these, automated build scripts that trace dependencies will fail.

#### Research / Investigation

Confirmed via full-text search across all specification files. The IDs `TASK‑006`, `TASK‑007`, `TASK‑005`, and `TASK‑003` appear in the Chat and Projects modules but do not correspond to any existing task in Foundation or Dashboard specifications. These are renumbering artifacts from earlier specification drafts.

#### Related Files

- `20-Projects.md` (PROJ‑020, PROJ‑024)
- `11-Chat.md` (CHAT‑015, CHAT‑018, CHAT‑021)
- `TODO.md` (original 17‑Updates document)
- `00-Plan.md` (for verification)
- `01-Foundations.md` (for canonical task IDs)

#### Definition of Done

- Zero occurrences of `TASK‑006`, `TASK‑007`, `TASK‑005`, or `TASK‑003` remain in any specification file.
- All `Depends On` fields reference only canonical task IDs from the Foundations or the same module.
- Validation script runs successfully in CI and returns zero errors.
- Canonical task registry is complete and committed.

#### Acceptance Criteria

- Running `grep -r "TASK-006\|TASK-007\|TASK-005\|TASK-003" *.md` returns zero results.
- Running `node scripts/validate-task-refs.js` returns `All task references valid.`
- All module specs can be parsed without unresolved dependency errors.

#### Out of Scope

- Renumbering tasks to follow a new numbering scheme (that is Phase 4 normalization, TASK‑017).
- Fixing semantic dependency errors (only lexical fixes here — semantic fixes are in TASK‑002).

#### Dependencies

None.

#### Estimated Effort

1.5 hours

#### Testing Requirements

- Manual: Run `grep` to confirm phantom IDs are gone.
- Automated: Run `scripts/validate-task-refs.js` in CI.

#### Validation Steps

1. Open `20-Projects.md` and search for `TASK‑006` and `TASK‑007`. Confirm zero occurrences.
2. Open `11-Chat.md` and search for `TASK‑006`, `TASK‑007`, `TASK‑005`, `TASK‑003`. Confirm zero occurrences.
3. Run validation script and confirm clean output.
4. Spot-check `PROJ‑020` `Depends On` line reads `DASH‑006, DASH‑007`.

#### Strict Rules

- Do not change any task ID that is not explicitly listed in the subtasks.
- Do not rename any files during this task.
- Preserve all existing formatting around the changed text.

#### Existing Code Patterns

N/A — Specification files only.

#### Advanced Code Patterns

The validation script should:
1. Recursively find all `.md` files in the project root.
2. Extract all `Depends On:` lines and parse the comma-separated task IDs.
3. Extract all `**Parent Task ID**:` and `### TASK-` patterns to build the registry.
4. Report any reference that doesn't match a registered ID.

#### Anti-Patterns

N/A

---

### TASK-002: Align Plan Phase Lists with Module Specifications

**Status**: ✅ Done  
**Priority**: 🔴 Critical  
**Parent Task ID**: TASK-002

#### Subtasks

- [ ] **TASK-002-01**: In `00-Plan.md` Phase 1 Calendar, rename `CAL‑002 Mini‑calendar sidebar` to `CAL‑002 Multi-Calendar Support & Calendar List Sidebar` and add note that mini‑calendar is part of `CAL‑001`.  
  **Target File**: `00-Plan.md`

- [ ] **TASK-002-02**: In `00-Plan.md` Phase 5 Documents, add `DOC‑005 (OCR Pipeline)` to the task list.  
  **Target File**: `00-Plan.md`

- [ ] **TASK-002-03**: In `00-Plan.md` Phase 6 Polish, add `POL‑003 (Analytics, Audit & RUM)` to the task list.  
  **Target File**: `00-Plan.md`

- [ ] **TASK-002-04**: In `00-Plan.md` Phase 4 Budget, add `BUDG‑013 (Financial Planning Dashboard)` to the deferred list with explicit deferral note.  
  **Target File**: `00-Plan.md`

- [ ] **TASK-002-05**: Audit all remaining Phase lists against the latest module specs and add any missing tasks or mark deferred tasks explicitly.  
  **Target File**: `00-Plan.md`

#### Priority / Urgency

🔴 Critical. The Plan is the authoritative roadmap for implementation order. If it lists incorrect task names or omits tasks, the build sequence will be wrong, leading to circular dependencies and blockers during development.

#### Research / Investigation

Compared the canonical module specs against the Plan task lists. The Plan was generated from an earlier version of the specs before several modules were enhanced (Budget, Calendar, Documents). The mismatches are documented in the subtasks.

#### Related Files

- `00-Plan.md`
- `21-Calendar.md` (CAL‑001, CAL‑002)
- `41-Documents.md` (DOC‑000 through DOC‑017)
- `99-Polish-Validation.md` (POL‑001 through POL‑006)
- `50-Budget.md` (BUDG‑013)

#### Definition of Done

- Every task listed in the Plan matches exactly one task ID in the corresponding module specification.
- All phase lists include a complete enumeration with explicit "Deferred" markers for tasks not included in that phase.
- A developer reading the Plan sees an unambiguous mapping to the module specs.

#### Acceptance Criteria

- Phase 1 Calendar list includes `CAL‑002` with correct full title.
- Phase 5 Documents list includes `DOC‑005`.
- Phase 6 Polish list includes `POL‑003`.
- Phase 4 Budget deferred list includes `BUDG‑013`.

#### Out of Scope

- Changing which phase a task belongs to (only adding what was unintentionally omitted).
- Adding brand new tasks to modules (only aligning existing specifications).
- Rewriting the Plan's introductory or explanatory text.

#### Dependencies

- TASK‑001 (phantom IDs must be resolved first to avoid confusion).

#### Estimated Effort

1.5 hours

#### Testing Requirements

- Manual: Side-by-side comparison of Plan lists against module spec task headings.
- Automated: Extend `scripts/validate-task-refs.js` to check that all Plan-referenced tasks exist in the registry.

#### Validation Steps

1. Open `00-Plan.md` and find each Phase section.
2. For each task ID listed, open the corresponding module spec and verify the task heading exists.
3. Confirm all "Deferred" entries are marked as such.

#### Strict Rules

- Only add tasks that already exist in module specs. Do not invent new tasks.
- Do not remove any existing entries without marking as "Deferred" with a note.

#### Existing Code Patterns

N/A — Specification files only.

#### Advanced Code Patterns

N/A

#### Anti-Patterns

N/A

---

### TASK-003: Eliminate Duplicate IndexedDB Definitions

**Status**: 🟡 Pending  
**Priority**: 🔴 Critical  
**Parent Task ID**: TASK-003

#### Subtasks

- [ ] **TASK-003-01**: Remove the standalone `NewsDB` class definition from `40-News.md` (NEWS‑005B) and replace with import from `@/lib/db` (`CommandCenterDB`).  
  **Target File**: `40-News.md`

- [ ] **TASK-003-02**: Remove local Dexie store definitions from `41-Documents.md` (DOC‑014A) and replace with reference to the centralized `CommandCenterDB`.  
  **Target File**: `41-Documents.md`

- [ ] **TASK-003-03**: Audit `30-Email.md`, `31-Contacts.md`, `22-Lists.md`, `50-Budget.md` for any standalone Dexie instance declarations or local store definitions. Replace with references to shared `CommandCenterDB`.  
  **Target Files**: `30-Email.md`, `31-Contacts.md`, `22-Lists.md`, `50-Budget.md`

- [ ] **TASK-003-04**: In `01-Foundations.md`, append a "Migration Strategy" section to the `CommandCenterDB` class documentation specifying that new module stores must increment the database version and define a migration function.  
  **Target File**: `01-Foundations.md`

- [ ] **TASK-003-05**: Create a central `src/lib/db.ts` implementation with the full `CommandCenterDB` schema from `01-Foundations.md` (if not already present).  
  **Target File**: `src/lib/db.ts`

#### Priority / Urgency

🔴 Critical. Multiple IndexedDB databases cause data fragmentation, prevent cross-module data access, and create schema inconsistency bugs. The `01-Foundations.md` already defines the canonical `CommandCenterDB`; all modules must use it.

#### Research / Investigation

Confirmed via text search that `40-News.md` defines `class NewsDB extends Dexie` and `41-Documents.md` defines `documents_metadata`, `documents_pending_mutations`, `documents_offline_files`. The global `CommandCenterDB` in `01-Foundations.md` already has prefixed stores for both modules. Using a single DB follows the Dexie best practice of one database per application.

#### Related Files

- `01-Foundations.md` (CommandCenterDB definition)
- `40-News.md` (NEWS‑005B)
- `41-Documents.md` (DOC‑014A)
- `30-Email.md` (EMAIL‑000A for store definitions)
- `31-Contacts.md` (CONT‑010A)
- `22-Lists.md` (LIST‑006A)
- `50-Budget.md` (BUDG‑012A)
- `src/lib/db.ts` (target implementation file)

#### Definition of Done

- Zero standalone `class ...DB extends Dexie` definitions exist outside `01-Foundations.md`.
- All module `useLiveQuery` and mutation hooks read from the shared `CommandCenterDB` instance.
- Migration strategy is documented in `01-Foundations.md`.
- The `CommandCenterDB` version is at least 2 with migration functions for all current stores.

#### Acceptance Criteria

- Searching for `extends Dexie` across all markdown files returns only the definition in `01-Foundations.md`.
- Each module's offline task references `@/lib/db` for import.
- The migration section in `01-Foundations.md` includes an example of adding a new store with version increment.

#### Out of Scope

- Implementing the actual Dexie migration code (that is implementation, not specification).
- Defining additional stores not already present in the specifications.

#### Dependencies

- TASK‑001 (ensure correct task references before rewriting spec text).

#### Estimated Effort

2 hours

#### Testing Requirements

- Manual: Verify each module spec's Dexie section references the shared DB.
- Automated: Add a lint rule that flags `extends Dexie` in any file except `01-Foundations.md`.

#### Validation Steps

1. Open each module spec and locate the offline/dexie section.
2. Verify it imports from `@/lib/db` and does not define a new `Dexie` subclass.
3. Check `01-Foundations.md` for a complete migration strategy section.

#### Strict Rules

- Do not remove the store names from `01-Foundations.md` — only remove duplicate definitions from module specs.
- Do not modify the `CommandCenterDB` schema except to add the migration strategy appendix.

#### Existing Code Patterns

N/A — Specification files only, but the implementation pattern is:
```typescript
import { db } from '@/lib/db';
// Not: const db = new Dexie('NewsDB');
```

#### Advanced Code Patterns

For the migration appendix, provide a concrete example:
```typescript
this.version(2).stores({
  // Re-declare all existing stores
  news_articles: 'id, sourceId, publishedAt',
  // ... existing stores
  // Add new module store
  docs_comments: 'id, documentId, createdAt',
}).upgrade(tx => {
  // Migration logic here
  return tx.table('docs_comments').toCollection().modify(comment => {
    comment.legacyField = undefined;
  });
});
```

#### Anti-Patterns

- ❌ Creating a new `Dexie` subclass for a single module.
- ❌ Using a different database name per module.
- ❌ Forgetting to re-declare all existing stores when adding a new version.
- ❌ Not including an `upgrade` function when adding new stores.

---

## 🟠 Phase 2: Shared Infrastructure Extraction

---

### TASK-004: Create Centralized Recurrence Engine Usage Specification

**Status**: 🟡 Pending  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-004

#### Subtasks

- [ ] **TASK-004-01**: In `21-Calendar.md` (CAL‑013), replace custom recurrence implementation with reference to `RecurrenceEngine` from `@/shared/recurrence`. Remove inline recurrence logic subtasks.  
  **Target File**: `21-Calendar.md`

- [ ] **TASK-004-02**: In `22-Lists.md` (LIST‑010), replace `RecurrencePicker` component and custom recurrence logic with `RecurrenceEditor` and `RecurrenceEngine` from shared module.  
  **Target File**: `22-Lists.md`

- [ ] **TASK-004-03**: In `50-Budget.md` (BUDG‑010), replace custom recurrence calendar implementation with `RecurrenceEngine.getOccurrences()` and `rruleToHuman()` from shared helpers.  
  **Target File**: `50-Budget.md`

- [ ] **TASK-004-04**: In `20-Projects.md` (PROJ‑013), update recurring work dialog to use `RecurrenceEditor` component. Remove inline frequency configuration descriptions.  
  **Target File**: `20-Projects.md`

- [ ] **TASK-004-05**: Verify `23-SharedRecurrence.md` is complete and all four module specs reference it consistently.  
  **Target File**: `23-SharedRecurrence.md`

#### Priority / Urgency

🟠 High. The shared recurrence engine was already specified (`23-SharedRecurrence.md`) to eliminate ~30% duplicated effort. However, the four consuming modules still contain their original custom recurrence implementation details, which will cause confusion and potential duplicate implementation.

#### Research / Investigation

Confirmed that `23-SharedRecurrence.md` defines `RecurrenceEngine`, `RecurrenceEditor`, `RecurrenceEditorProvider`, and helper functions (`ruleToRRULE`, `rruleToHuman`, `buildEditOperations`). The four module specs (Calendar CAL‑013, Lists LIST‑010, Budget BUDG‑010, Projects PROJ‑013) each independently describe recurrence logic that should be delegated to these shared components.

#### Related Files

- `23-SharedRecurrence.md` (source of truth)
- `21-Calendar.md` (CAL‑013)
- `22-Lists.md` (LIST‑010)
- `50-Budget.md` (BUDG‑010)
- `20-Projects.md` (PROJ‑013)

#### Definition of Done

- All four module specs reference `@/shared/recurrence` for recurrence operations.
- No module spec contains independent recurrence engine implementation instructions.
- Module specs still contain any module-specific recurrence UI wiring (e.g., which fields map to which recurrence parameters).

#### Acceptance Criteria

- Searching for "Custom recurrence" or "implement recurrence logic" in the four module files returns only explanations of how the shared module is used, not how to build recurrence from scratch.
- Each module's recurrence task lists `23-SharedRecurrence.md` as a dependency.

#### Out of Scope

- Creating new recurrence features not already in the shared spec.
- Modifying the shared recurrence specification itself.

#### Dependencies

- TASK‑001 (phantom IDs resolved).
- `23-SharedRecurrence.md` must exist and be approved.

#### Estimated Effort

2.5 hours

#### Testing Requirements

- Manual: Verify all four module specs have the updated recurrence references.
- Specification review: Confirm the shared recurrence module covers all needed use cases.

#### Validation Steps

1. Open each module spec and navigate to the recurrence task.
2. Confirm the task text says "Use `RecurrenceEngine` from `@/shared/recurrence`" or similar.
3. Confirm no inline RRULE construction or recurrence calendar logic remains.

#### Strict Rules

- Do not change any module's overall task count or dependency graph except to replace custom recurrence with shared.
- Do not remove any subtasks that are not recurrence-related.

#### Existing Code Patterns

N/A — Specification only.

#### Advanced Code Patterns

N/A

#### Anti-Patterns

- ❌ Retaining custom recurrence implementation descriptions "just in case."
- ❌ Requiring modules to install `rrule.js` separately (it is a dependency of the shared module).

---

### TASK-005: Create Centralized SanitizedHTML Component Specification

**Status**: 🟡 Pending  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-005

#### Subtasks

- [ ] **TASK-005-01**: Define a shared `SanitizedHTML` component in `01-Foundations.md` under a new cross-cutting rule (C‑16). Specify that it uses `DOMPurify.sanitize()` with a strict allowlist and renders via `html-react-parser`.  
  **Target File**: `01-Foundations.md`

- [ ] **TASK-005-02**: In `30-Email.md` (EMAIL‑003C), replace `dangerouslySetInnerHTML` for email body rendering with `SanitizedHTML` component reference.  
  **Target File**: `30-Email.md`

- [ ] **TASK-005-03**: In `40-News.md` (NEWS‑006E), replace DOMPurify manual sanitization for article content with `SanitizedHTML` component reference.  
  **Target File**: `40-News.md`

- [ ] **TASK-005-04**: In `41-Documents.md` (DOC‑003J), update file preview rendering to use `SanitizedHTML`.  
  **Target File**: `41-Documents.md`

- [ ] **TASK-005-05**: In `42-Research.md` (RES‑003), update document content rendering to use `SanitizedHTML`.  
  **Target File**: `42-Research.md`

#### Priority / Urgency

🟠 High. Multiple modules independently specify HTML sanitization using `dangerouslySetInnerHTML` or manual DOMPurify calls. This violates DRY and creates a security risk if any module misses sanitization. The shared component should be the single canonical approach.

#### Research / Investigation

Confirmed that Email (EMAIL‑003C) mentions DOMPurify for thread view, News (NEWS‑006E) specifies a detailed DOMPurify config with allowlists, Documents renders preview HTML, and Research renders AI-generated content. Each module independently defines its sanitization strategy. The `@mozilla/readability` output in News already requires sanitization before render.

#### Related Files

- `01-Foundations.md` (new cross-cutting rule)
- `src/components/shared/SanitizedHTML.tsx` (target implementation)
- `30-Email.md` (EMAIL‑003C)
- `40-News.md` (NEWS‑006E)
- `41-Documents.md` (DOC‑003J)
- `42-Research.md` (RES‑003)

#### Definition of Done

- `01-Foundations.md` includes a clear specification for `SanitizedHTML` with default and extensible configuration.
- All four consuming modules reference `SanitizedHTML` instead of implementing their own sanitization.
- The allowlist in the shared spec covers all needed tags across modules (if a module needs additional tags, it extends the default config).

#### Acceptance Criteria

- Searching for `dangerouslySetInnerHTML` across all specs returns only references in the `SanitizedHTML` spec itself.
- Each module's content rendering task mentions `<SanitizedHTML html={content} />`.

#### Out of Scope

- Implementing the actual `SanitizedHTML` component (that is FND‑002 or a foundational task).
- Specifying DOMPurify version (handled by FND‑002 dependency list).

#### Dependencies

- TASK‑001 (phantom IDs resolved).

#### Estimated Effort

1.5 hours

#### Testing Requirements

- Specification review: Confirm the allowlist covers all HTML elements used across modules.
- Security review: Confirm no unsafe tags (script, iframe, object) appear in the allowlist.

#### Validation Steps

1. Review the `SanitizedHTML` specification in `01-Foundations.md` for completeness.
2. Check each consuming module spec for the SanitizedHTML reference.
3. Verify the global allowlist includes all tags used in article content, email bodies, document previews.

#### Strict Rules

- The default configuration must block all scripts, iframes, and event handlers.
- Each module may extend the default allowlist but never reduce it.
- External links in sanitized content must always get `target="_blank" rel="noopener noreferrer"`.

#### Existing Code Patterns

N/A — Specification only.

#### Advanced Code Patterns

The shared component should follow this pattern:
```tsx
import DOMPurify from 'dompurify';
import parse from 'html-react-parser';

interface SanitizedHTMLProps {
  html: string;
  allowlist?: DOMPurify.Config['ALLOWED_TAGS'];
  className?: string;
}

const DEFAULT_ALLOWLIST = {
  ALLOWED_TAGS: ['p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'ul', 'ol', 'li', 'strong', 'em', 'a', 'img', 'blockquote', 'pre', 'code', 'br', 'hr', 'table', 'thead', 'tbody', 'tr', 'th', 'td'],
  ALLOWED_ATTR: ['href', 'src', 'alt', 'title', 'target', 'rel', 'class'],
};
```

#### Anti-Patterns

- ❌ Using `dangerouslySetInnerHTML` directly on any untrusted content.
- ❌ Implementing a module-specific sanitization function instead of using the shared component.
- ❌ Omitting `target="_blank" rel="noopener noreferrer"` on external links.

---

### TASK-006: Enforce Global useOptimisticMutation Wrapper Usage

**Status**: 🟡 Pending  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-006

#### Subtasks

- [ ] **TASK-006-01**: Audit all mutation hook definitions across all module specs for inline `onMutate / onError / onSettled` patterns that duplicate the shared `useOptimisticMutation()` wrapper.  
  **Target Files**: All module specification files

- [ ] **TASK-006-02**: In each identified module, replace inline optimistic patterns with a reference to `useOptimisticMutation()` from `src/lib/useOptimisticMutation.ts` (per FND‑006H in `01-Foundations.md`).  
  **Target Files**: As identified in TASK‑006‑01

- [ ] **TASK-006-03**: Ensure the shared wrapper's canonical pattern (`cancelQueries → snapshot → setQueryData → rollback → onSettled invalidate`) is documented in `01-Foundations.md` as the required pattern for all mutations.  
  **Target File**: `01-Foundations.md`

- [ ] **TASK-006-04**: Add a conformance checklist item to `99-Polish-Validation.md` verifying that zero mutation hooks implement inline optimistic patterns.  
  **Target File**: `99-Polish-Validation.md`

#### Priority / Urgency

🟠 High. The shared wrapper enforces the correct TanStack Query v5 pattern (cancel before mutate, rollback on error, invalidate on settled). Inline implementations often skip `cancelQueries`, creating race conditions where background refetches overwrite optimistic state.

#### Research / Investigation

Confirmed that `01-Foundations.md` FND‑006H defines `useOptimisticMutation()` as the canonical wrapper. However, several module specs (Email EMAIL‑000G, Contacts CONT‑000F, Documents DOC‑001D) still show inline mutation patterns in their specification text. Some (Chat CHAT‑002C) define mutation hooks with full inline patterns. These must be updated to reference the shared wrapper.

#### Related Files

- `01-Foundations.md` (FND‑006H — canonical pattern)
- `30-Email.md` (EMAIL‑000G)
- `31-Contacts.md` (CONT‑000F)
- `41-Documents.md` (DOC‑001D)
- `11-Chat.md` (CHAT‑002C)
- `99-Polish-Validation.md` (POL‑002)

#### Definition of Done

- Zero specification files contain an inline `onMutate: async (...) => { await queryClient.cancelQueries(...); ... }` pattern.
- All mutation spec sections reference `useOptimisticMutation()` as the implementation approach.
- The `99-Polish-Validation.md` checklist includes a mutation pattern conformance item.

#### Acceptance Criteria

- Searching for `cancelQueries` in module specs (outside `01-Foundations.md`) returns zero results — or results only in explanatory text about the wrapper.
- Each module's mutation task says "MUST use the shared `useOptimisticMutation()` wrapper."

#### Out of Scope

- Implementing the `useOptimisticMutation` wrapper (that is FND‑006H implementation).
- Changing the wrapper's canonical pattern.

#### Dependencies

- TASK‑001 (phantom IDs resolved).

#### Estimated Effort

2 hours

#### Testing Requirements

- Specification audit: Manual review of all mutation hook definitions.
- Automated: Extend the validation script to flag inline `onMutate` patterns in spec files.

#### Validation Steps

1. Search all `.md` files for `onMutate: async`.
2. For each occurrence, verify it is either in `01-Foundations.md` or is explanatory text about the wrapper.
3. Spot-check several module mutation tasks to confirm they reference the wrapper.

#### Strict Rules

- No module specification may define a mutation that doesn't use the wrapper.
- The wrapper pattern (cancel → snapshot → set → rollback → invalidate) must not be altered.

#### Existing Code Patterns

Canonical usage:
```typescript
const mutation = useOptimisticMutation({
  mutationFn: updateEntity,
  queryKey: entityKeys.list(),
  optimisticUpdate: (old, input) => old.map(e => e.id === input.id ? { ...e, ...input } : e),
});
```

#### Advanced Code Patterns

N/A — Specification only.

#### Anti-Patterns

- ❌ Inline `onMutate` in a module's mutation hook specification.
- ❌ Calling `setQueryData` before `cancelQueries`.
- ❌ Using `onSuccess` for invalidation instead of `onSettled`.

---

## 🟠 Phase 3: Accessibility Compliance

---

### TASK-007: Add WCAG 2.5.7 Single-Pointer Alternatives to All Drag Interactions

**Status**: 🟡 Pending  
**Priority**: 🔴 Critical  
**Parent Task ID**: TASK-007

#### Subtasks

- [ ] **TASK-007-01**: In `22-Lists.md` (LIST‑004B, Board View), add a "Move to…" button alternative on each card that duplicates the drag-between-columns functionality using the `PROJ‑004F` pattern.  
  **Target File**: `22-Lists.md`

- [ ] **TASK-007-02**: In `22-Lists.md` (LIST‑005A, List Item Reordering), add a "Reorder" button or keyboard shortcut (e.g., `Alt+↑` / `Alt+↓`) for moving items up and down.  
  **Target File**: `22-Lists.md`

- [ ] **TASK-007-03**: In `21-Calendar.md` (CAL‑010, Week/Day Views), add a "Reschedule" dialog or button that opens on `Enter` / click, enabling date/time adjustment without dragging events on the time grid.  
  **Target File**: `21-Calendar.md`

- [ ] **TASK-007-04**: In `50-Budget.md` (BUDG‑006D1, Planned Transaction Rescheduling), add a "Change Date" button/popup accessible via keyboard as an alternative to dragging planned transactions on the financial calendar.  
  **Target File**: `50-Budget.md`

- [ ] **TASK-007-05**: Add a WCAG 2.5.7 compliance checklist item to the module template (in `00-CONTRIBUTING.md` or `99-Polish-Validation.md`).  
  **Target File**: `99-Polish-Validation.md`

#### Priority / Urgency

🔴 Critical. WCAG 2.5.7 (Dragging Movements) is a Level AA requirement. Without alternatives, users who cannot use a mouse or pointer cannot rearrange items, move calendar events, or manage Kanban boards. Some modules already have the pattern (`PROJ‑004F`); others must catch up.

#### Research / Investigation

The W3C Understanding Document for SC 2.5.7 states: "All functionality that uses a dragging movement for operation can be achieved by a single pointer without dragging." The `PROJ‑004F` implementation ("Move to…" submenu in the `⋯` menu) is a valid and proven pattern. The Calendar `react-big-calendar` library provides `onSelectEvent` and `onSelectSlot` callbacks that can be used to open a reschedule dialog. The Lists Board View uses dnd‑kit; the `PROJ‑004F` pattern can be reused directly.

#### Related Files

- `22-Lists.md` (LIST‑004B, LIST‑005A)
- `21-Calendar.md` (CAL‑010)
- `50-Budget.md` (BUDG‑006D1)
- `20-Projects.md` (PROJ‑004F — reference pattern)
- `99-Polish-Validation.md` (compliance checklist)

#### Definition of Done

- Every drag‑based interaction in every module has a documented button‑ or keyboard‑based alternative.
- The alternative uses the same mutation hooks as the drag operation.
- The module template (`00-CONTRIBUTING.md` or `99-Polish-Validation.md`) includes a WCAG 2.5.7 conformance item.

#### Acceptance Criteria

- Lists Board View cards have a "Move to…" option in their action menu.
- Calendar events have a "Reschedule" option on click or keyboard activation.
- Budget planned transactions have a "Change Date" action.
- All alternatives call the same optimistic mutations as the drag handlers.

#### Out of Scope

- Adding alternatives for drag operations that are not yet specified.
- Implementing the actual UI components (only spec updates).

#### Dependencies

- TASK‑001 (correct task references needed).
- `PROJ‑004F` must be finalized as the reference pattern.

#### Estimated Effort

2 hours

#### Testing Requirements

- Specification review: Verify each drag interaction has a corresponding alternative subtask.
- Accessibility audit: After implementation, run axe‑core to confirm no drag‑only interactions remain.

#### Validation Steps

1. Open each module spec and search for "drag", "dnd", "DragOverlay".
2. For each drag interaction found, verify there is a corresponding button/click alternative subtask.
3. Verify the alternative uses the same mutation as the drag handler.

#### Strict Rules

- The alternative must trigger the same mutation with the same parameters as the drag operation.
- The alternative must not be hidden behind a gesture — it must be reachable via keyboard.
- The alternative must be documented in the same task as the drag implementation.

#### Existing Code Patterns

Reference pattern from `PROJ‑004F`:
```
"Move to…" button on each `KanbanCard` (in `⋯` menu): "Move to → [column name]" submenu.
Rendered as `<button>` elements. Calls same mutation as drag.
```

#### Advanced Code Patterns

For Calendar, the alternative could be:
```tsx
// On event click/keypress, open a dialog:
const handleEventClick = (event) => {
  openRescheduleDialog({
    eventId: event.id,
    currentStart: event.start,
    currentEnd: event.end,
    onConfirm: (newStart, newEnd) => updateEventMutation.mutate({ id: event.id, start: newStart, end: newEnd }),
  });
};
```

#### Anti-Patterns

- ❌ Providing only a drag interaction with no button alternative.
- ❌ Using a different, less capable mutation for the alternative than the drag action.
- ❌ Making the alternative available only on hover (must be keyboard reachable).

---

### TASK-008: Add Screen Reader Announcements for Drag-and-Drop Reordering

**Status**: 🟡 Pending  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-008

#### Subtasks

- [ ] **TASK-008-01**: Update the shared `useDndSensors` hook specification in `01-Foundations.md` (C‑14 or new C‑17) to require an `onDragEnd` callback that updates a live region announcing the new position of the moved item.  
  **Target File**: `01-Foundations.md`

- [ ] **TASK-008-02**: Define a shared `<LiveRegion>` component specification that renders a visually hidden `aria-live="polite"` container for drag announcements.  
  **Target File**: `01-Foundations.md`

- [ ] **TASK-008-03**: Update `20-Projects.md` (PROJ‑004C, Kanban drag), `22-Lists.md` (LIST‑005A, List drag), and `50-Budget.md` (BUDG‑006, Calendar drag) to wire the live region announcement into their drag handlers.  
  **Target Files**: `20-Projects.md`, `22-Lists.md`, `50-Budget.md`

#### Priority / Urgency

🟠 High. Screen reader users need to know where an item was moved after a drag‑and‑drop reorder. Without announcements, they cannot confirm the action succeeded or know the new position. This is covered by WCAG 4.1.3 (Status Messages).

#### Research / Investigation

`@dnd-kit`'s `onDragEnd` callback provides `active` (the dragged item) and `over` (the drop target). The `KeyboardSensor` already handles keyboard‑driven reordering, but no accessible feedback is built in. A common pattern is to update an `aria-live` region with text like "Moved 'Project Alpha' to column In Progress, position 3." This should be a shared utility used by all dnd‑kit consumers.

#### Related Files

- `01-Foundations.md` (C‑14 or new C‑17)
- `src/shared/dnd/useDndSensors.ts` (target implementation)
- `src/components/shared/LiveRegion.tsx` (target implementation)
- `20-Projects.md` (PROJ‑004C)
- `22-Lists.md` (LIST‑005A)
- `50-Budget.md` (BUDG‑006)

#### Definition of Done

- `useDndSensors` specification requires an announcement callback parameter.
- A shared `<LiveRegion>` component is specified.
- All drag operations in all modules produce an accessible announcement upon completion.

#### Acceptance Criteria

- After a Kanban card is moved via keyboard, the screen reader announces "Moved 'Card Name' to 'Column Name'."
- After a list item is reordered, the screen reader announces "Moved 'Item Name' to position 4."

#### Out of Scope

- Internationalization of announcement strings (use hardcoded English for MVP).
- Announcements during the drag operation (only on completion).

#### Dependencies

- TASK‑007 (WCAG 2.5.7 alternatives must exist first).

#### Estimated Effort

1.5 hours

#### Testing Requirements

- Accessibility testing: Verify live region updates with screen reader simulation in tests.
- Integration test: Confirm the live region is updated after a keyboard‑driven drag operation.

#### Validation Steps

1. Review the updated `useDndSensors` spec for the announcement callback parameter.
2. Verify each drag‑consuming module references the `LiveRegion` component.
3. Check that the announcement text includes the item name and new position.

#### Strict Rules

- The live region must be visually hidden but accessible to screen readers.
- Announcements must not fire on initial render, only on drag completion.
- The announcement text must be concise (one sentence).

#### Existing Code Patterns

The `useDndSensors` hook already exists in the spec. Extend it:
```typescript
export function useDndSensors(options?: {
  onAnnouncement?: (message: string) => void;
}) {
  // ... existing sensor config
  // On dragEnd, call options.onAnnouncement?.(message)
}
```

#### Advanced Code Patterns

Pattern for `<LiveRegion>`:
```tsx
export function LiveRegion() {
  const [message, setMessage] = useState('');
  // Subscribe to announcements from dndSensors
  return (
    <div className="sr-only" aria-live="polite" aria-atomic="true">
      {message}
    </div>
  );
}
```

#### Anti-Patterns

- ❌ Firing announcements during the drag instead of on completion.
- ❌ Announcing technical IDs instead of human-readable names.
- ❌ Creating a separate live region per component instead of sharing one.

---

## 🟡 Phase 4: Missing Infrastructure

---

### TASK-009: Create Authentication Module Specification

**Status**: 🟡 Pending  
**Priority**: 🔴 Critical  
**Parent Task ID**: TASK-009

#### Subtasks

- [ ] **TASK-009-01**: Create `05-Auth.md` with the following tasks:
  - AUTH‑000: Define `User` type, `AuthSlice` (token, userId, isAuthenticated).
  - AUTH‑001: Implement `AuthProvider` that hydrates auth state from `secureVault` on boot, provides `login(email, pw)` and `logout()`.
  - AUTH‑002: Create global `apiClient` (`src/lib/apiClient.ts`) that adds `Authorization: Bearer <token>` header, handles 401/403, and triggers global logout.
  - AUTH‑003: Protect all routes with a `<RequireAuth>` wrapper; redirect unauthenticated users to `/login`.
  - AUTH‑004: Build login page with RHF + Zod validation, mock authentication.
  **Target File**: `05-Auth.md`

- [ ] **TASK-009-02**: Update `00-Plan.md` Phase 0 to include `AUTH‑000` through `AUTH‑004` as prerequisite tasks.  
  **Target File**: `00-Plan.md`

- [ ] **TASK-009-03**: Update all module specifications that reference `useUser()` or `currentUserId` to reference the auth slice.  
  **Target Files**: All module specs with user-dependent features

#### Priority / Urgency

🔴 Critical. Without authentication, there is no user session, no protected API calls, no personalized data. Every module that references a user implicitly assumes an authentication system exists. This must be specified before any module can be implemented.

#### Research / Investigation

The existing specs mention `secureVault` (`30-Email.md`), `userId` in Zustand slices (various), and `currentUser` in Calendar attendee specs (CAL‑004F). However, no specification defines how a user logs in, how tokens are stored, or how API calls are authenticated. For MVP, mock authentication with a fake JWT stored in `secureVault` is sufficient. The React Router v7 data mode supports `loader` functions that can redirect unauthenticated users.

#### Related Files

- `05-Auth.md` (new)
- `00-Plan.md` (update Phase 0)
- `01-Foundations.md` (add cross-cutting rule for API client)
- `30-Email.md` (secureVault reference)
- `21-Calendar.md` (CAL‑004F)
- `src/stores/slices/authSlice.ts` (target implementation)
- `src/lib/apiClient.ts` (target implementation)

#### Definition of Done

- `05-Auth.md` contains complete task specifications for the authentication module.
- The Plan includes auth tasks in Phase 0.
- All module specs that reference user data include a "Depends On: AUTH‑001" or similar.

#### Acceptance Criteria

- `05-Auth.md` follows the same template as other module specs (Frontend Context, Cross‑Cutting Foundations, Motion Tier, Tasks with subtasks and tests).
- The API client specification handles 401, 403, and network errors uniformly.
- Login page specification includes validation, error states, and loading state.

#### Out of Scope

- Real OAuth integration (mock only for MVP).
- Multi‑factor authentication.
- Password reset flow (can be added later).

#### Dependencies

None (this is a new foundational specification).

#### Estimated Effort

2 hours (specification only)

#### Testing Requirements

- Specification review: Verify completeness and consistency with other modules.
- Implementation tests will cover login flow, token refresh, and route protection.

#### Validation Steps

1. Review `05-Auth.md` against the module specification template.
2. Verify the Plan includes auth tasks.
3. Check several module specs for updated `Depends On` fields.

#### Strict Rules

- Auth tokens must never be stored in localStorage. Use `secureVault` (IndexedDB with SubtleCrypto).
- The API client must be the only module that reads the token.
- All routes except `/login` must be protected.

#### Existing Code Patterns

N/A — New specification.

#### Advanced Code Patterns

The API client should follow this pattern:
```typescript
class ApiClient {
  private getToken: () => Promise<string | null>;

  async fetch<T>(url: string, options?: RequestInit): Promise<T> {
    const token = await this.getToken();
    const headers = new Headers(options?.headers);
    if (token) headers.set('Authorization', `Bearer ${token}`);

    const response = await fetch(url, { ...options, headers });
    if (response.status === 401) {
      useAuthStore.getState().logout();
      throw new ApiError('Unauthorized', 401);
    }
    if (!response.ok) {
      throw new ApiError(await response.text(), response.status);
    }
    return response.json();
  }
}

export const apiClient = new ApiClient();
```

#### Anti-Patterns

- ❌ Storing auth tokens in `localStorage`.
- ❌ Each module defining its own `fetch` wrapper.
- ❌ Not handling 401 globally (each component handling it separately).

---

### TASK-010: Create Global Notification Center Specification

**Status**: 🟡 Pending  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-010

#### Subtasks

- [ ] **TASK-010-01**: Create `08-Notifications.md` with tasks for:
  - NOTIF‑000: Define `Notification` type (id, type, title, body, link, priority, readAt, createdAt).
  - NOTIF‑001: Create `notificationSlice` with array of notifications, `unreadCount` selector, add/remove/markRead actions.
  - NOTIF‑002: Build `<NotificationBell>` component for the StatusBar showing unread count and dropdown list.
  - NOTIF‑003: Implement a pub/sub event bus (`createNotification(message)`) that any module can call to push a notification.
  - NOTIF‑004: Wire key event sources: agent decisions, budget alerts, email delivery, project assignments.
  **Target File**: `08-Notifications.md`

- [ ] **TASK-010-02**: Update `01-Foundations.md` StatusBar task (FND‑010) to reference the NotificationBell component.  
  **Target File**: `01-Foundations.md`

- [ ] **TASK-010-03**: Update `50-Budget.md` (BUDG‑014, spending insights), `20-Projects.md` (PROJ‑020, triage integration), `30-Email.md` (EMAIL‑009, follow‑up reminders) to publish notifications through the shared event bus.  
  **Target Files**: `50-Budget.md`, `20-Projects.md`, `30-Email.md`

#### Priority / Urgency

🟠 High. Multiple modules generate user‑facing notifications, but each currently describes standalone toast implementations. A centralized notification center provides a unified UI (bell icon with unread count), prevents notification fatigue, and allows users to manage notification preferences in one place.

#### Research / Investigation

The StatusBar already has a slot for indicators (`FND‑010`). The `settingsSlice` already manages notification preferences. What's missing is a shared notification queue and UI component. The event bus pattern is lightweight: a React Context or a simple Zustand slice that any module can import and call `addNotification(...)`. The `<NotificationBell>` renders in the StatusBar and shows a dropdown of recent notifications.

#### Related Files

- `08-Notifications.md` (new)
- `01-Foundations.md` (FND‑010 — StatusBar)
- `50-Budget.md` (BUDG‑014)
- `20-Projects.md` (PROJ‑020)
- `30-Email.md` (EMAIL‑009)
- `src/stores/slices/notificationSlice.ts` (target implementation)

#### Definition of Done

- `08-Notifications.md` contains complete task specifications.
- The StatusBar specification includes the NotificationBell.
- Key event sources are specified to publish through the shared bus.

#### Acceptance Criteria

- Notification bell renders in the StatusBar.
- Clicking the bell opens a dropdown with recent notifications, sorted by recency.
- Unread count badge updates in real time.
- Any module can call `addNotification(...)` to push a notification.

#### Out of Scope

- Push notifications to the OS (browser Notification API is separate, handled in Calendar CAL‑005).
- Email delivery of notifications.
- Notification grouping or summarization.

#### Dependencies

- TASK‑009 (auth must exist for user‑specific notifications).
- `FND‑010` (StatusBar shell must exist).

#### Estimated Effort

2 hours (specification only)

#### Testing Requirements

- Specification review: Verify event sources are correctly mapped.
- Integration tests: After implementation, verify that completing a task or receiving an email pushes a notification.

#### Validation Steps

1. Review `08-Notifications.md` for completeness.
2. Verify the Plan includes notification tasks.
3. Check the StatusBar spec references the NotificationBell.

#### Strict Rules

- Notifications must be stored in Zustand only (no IndexedDB for MVP).
- Notification state must not be persisted across sessions.
- Max 50 notifications in the list; oldest are evicted.

#### Existing Code Patterns

N/A — New specification.

#### Advanced Code Patterns

The event bus pattern:
```typescript
// In notificationSlice:
addNotification: (notification) => set(state => ({
  notifications: [notification, ...state.notifications].slice(0, 50),
}))

// Usage from any module:
import { useNotificationStore } from '@/stores/slices/notificationSlice';
const addNotification = useNotificationStore(s => s.addNotification);
addNotification({
  id: crypto.randomUUID(),
  type: 'budget_alert',
  title: 'Overspend Alert',
  body: 'Dining category is 120% of budget.',
  link: '/budget?category=dining',
  priority: 'high',
});
```

#### Anti-Patterns

- ❌ Each module implementing its own notification toast independently.
- ❌ Storing notifications in module-specific state instead of the shared slice.
- ❌ Not providing a link/action for the notification.

---

### TASK-011: Create Global Route Map Specification

**Status**: 🟡 Pending  
**Priority**: 🔴 Critical  
**Parent Task ID**: TASK-011

#### Subtasks

- [ ] **TASK-011-01**: Create `00-Routes.md` listing every route path, its lazy import source, loader function summary, guard requirements, and special annotations (e.g., "requires Auth", "desktop only").  
  **Target File**: `00-Routes.md`

- [ ] **TASK-011-02**: Populate `00-Routes.md` from the route specifications in each module spec and the Plan.  
  **Target File**: `00-Routes.md`

- [ ] **TASK-011-03**: Update `01-Foundations.md` FND‑007 to reference `00-Routes.md` as the canonical route source.  
  **Target File**: `01-Foundations.md`

#### Priority / Urgency

🔴 Critical. The React Router v7 configuration is the backbone of navigation. Without a single source of truth for all routes, the router configuration will be assembled from scattered specifications, leading to missing routes, incorrect guards, and broken navigation. Agentic coding tools need a machine‑parseable route list.

#### Research / Investigation

Each module spec defines its own routes (e.g., `11-Chat.md` CHAT‑001C, `20-Projects.md` PROJ‑002A, `21-Calendar.md` CAL‑001G). The `00-Plan.md` gives a high‑level sequence but not the complete route table. A unified `00-Routes.md` should be a structured reference, not a narrative document — ideally with a table format and optional machine‑readable JSON alongside.

#### Related Files

- `00-Routes.md` (new)
- `01-Foundations.md` (FND‑007)
- All module specs with `### Subtasks` containing route configuration
- `00-Plan.md` (for sequence context)

#### Definition of Done

- `00-Routes.md` contains a complete table of all routes.
- Each route entry includes: path, method (GET/POST), lazy import path, loader description, auth requirement, module association.
- FND‑007 references this document as authoritative.

#### Acceptance Criteria

- Every route defined in any module spec appears in `00-Routes.md`.
- The table can be parsed to generate a React Router configuration automatically.

#### Out of Scope

- Defining route transition animations (those are per‑module).
- Specifying data loaders in full implementation detail (summary only).

#### Dependencies

- TASK‑002 (Plan must be aligned first).

#### Estimated Effort

2 hours

#### Testing Requirements

- Specification audit: Cross‑reference all module route definitions against the table.
- Automated: Build a script that extracts route definitions from `00-Routes.md` and compares them against all module specs.

#### Validation Steps

1. Search all module specs for route path definitions (e.g., `path: 'chat'`).
2. Verify each appears in `00-Routes.md`.
3. Check that all routes requiring auth are marked as such.

#### Strict Rules

- The route table must be the first section of the document for easy parsing.
- Use consistent column names: Path, Module, Lazy Import, Auth Required, Loader Summary.
- Sort by path alphabetically.

#### Existing Code Patterns

Table format example:
```markdown
| Path | Module | Lazy Import | Auth | Loader Summary |
|------|--------|-------------|------|----------------|
| `/` | Dashboard | `@/pages/Dashboard` | Yes | Prefetch agents |
| `/chat` | Chat | `@/pages/ChatPage` | Yes | Prefetch threads |
| `/calendar` | Calendar | `@/pages/CalendarPage` | Yes | Prefetch current month |
```

#### Advanced Code Patterns

N/A — Specification only.

#### Anti-Patterns

- ❌ Defining the same route in two different module specs without acknowledging it.
- ❌ Missing auth requirement on routes that need it.
- ❌ Using different path conventions across modules.

---

### TASK-012: Create Global Seed Data Specification for Integration Tests

**Status**: 🟡 Pending  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-012

#### Subtasks

- [ ] **TASK-012-01**: Add a task `FND‑004J` to `01-Foundations.md` for creating `src/mocks/seed.ts` with `seedAllData()` that generates a consistent set of interrelated mock data (users, accounts, categories, contacts, projects, etc.).  
  **Target File**: `01-Foundations.md`

- [ ] **TASK-012-02**: Update all module factory specifications to accept an optional `context` parameter containing shared IDs (e.g., `userId`, `projectId`) instead of generating random UUIDs.  
  **Target Files**: All module specs with factory tasks (NEWS‑000, BUDG‑001, CAL‑000, etc.)

- [ ] **TASK-012-03**: Require all integration tests to call `seedAllData()` before rendering.  
  **Target File**: `01-Foundations.md` (FND‑004)

#### Priority / Urgency

🟠 High. Without shared seed data, cross‑module integration tests will fail because IDs won't match (e.g., a transaction references a category that doesn't exist in the mock). This is essential for reliable multi‑module testing.

#### Research / Investigation

The current factory pattern generates fully random UUIDs every time. For single‑module tests, this is fine. But when testing that "completing a project task creates a budget transaction," the task's `projectId` must match an existing project, and the resulting transaction must reference a valid `categoryId`. A `seedAllData()` function can return a context object with all shared IDs, and factories can use these for their foreign keys.

#### Related Files

- `01-Foundations.md` (FND‑004J)
- `src/mocks/seed.ts` (new)
- All module factory specifications
- All module mock handler specifications

#### Definition of Done

- `FND‑004J` is added to `01-Foundations.md` with a complete specification.
- Every factory specification notes that it can accept a `context` parameter.
- The seed function is documented to produce deterministic output when given a fixed `faker.seed()`.

#### Acceptance Criteria

- Calling `seedAllData()` returns a context with `user.id`, `account.id`, `category.id`, `project.id`, `contact.id`, etc.
- A factory called with `createMockTransaction({ accountId: context.accountId })` produces a valid transaction linked to the seeded account.
- Running the seed function with the same seed produces identical data.

#### Out of Scope

- Implementing the actual seed function (that is an implementation task).
- Ensuring referential integrity in production data (only mock data).

#### Dependencies

- TASK‑003 (centralized Dexie must be specified first).

#### Estimated Effort

2 hours

#### Testing Requirements

- Unit test: Verify `seedAllData()` returns consistent, referentially intact data.
- Integration test: Use seeded data in a multi‑module test and verify no ID mismatches.

#### Validation Steps

1. Review the `FND‑004J` specification for completeness.
2. Check that factory specs mention the `context` parameter.
3. Verify the seed function is deterministic with a fixed seed.

#### Strict Rules

- The seed function MUST use `faker.seed()` for determinism.
- All foreign key references in seeded data must point to IDs present in the same seed context.
- The seed function must export a `resetAllData()` companion that clears all mock state.

#### Existing Code Patterns

Example seed function pattern:
```typescript
export function seedAllData() {
  faker.seed(12345);

  const user = createMockUser();
  const accounts = createMockAccounts(3, { ownerId: user.id });
  const categories = createMockCategories(10);
  const contacts = createMockContacts(5, { userId: user.id });
  const projects = createMockProjects(3, { ownerId: user.id, memberIds: [user.id] });

  return { user, accounts, categories, contacts, projects };
}
```

#### Advanced Code Patterns

Factories accepting context:
```typescript
export function createMockTransaction(overrides: Partial<Transaction> = {}, context?: SeedContext): Transaction {
  return {
    id: faker.string.uuid(),
    accountId: overrides.accountId || (context ? faker.helpers.arrayElement(context.accounts).id : faker.string.uuid()),
    categoryId: overrides.categoryId || (context ? faker.helpers.arrayElement(context.categories).id : faker.string.uuid()),
    // ...
  };
}
```

#### Anti-Patterns

- ❌ Generating all IDs randomly in integration tests.
- ❌ Hardcoding expected IDs in test assertions without using the seed context.
- ❌ Not resetting state between tests.

---

## 🟡 Phase 5: Performance and Production Readiness

---

### TASK-013: Specify Heavy Library Code-Splitting Strategy

**Status**: 🟡 Pending  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-013

#### Subtasks

- [ ] **TASK-013-01**: In `99-Polish-Validation.md` (POL‑001), add explicit `manualChunks` targets for: `@monaco-editor/react` (CHAT‑011), `@xyflow/react` (FLOW‑001), `react-big-calendar` (CAL and BUDG), `@babel/standalone` (CHAT‑012), `tesseract.js` (DOC‑005), `recharts` (BUDG).  
  **Target File**: `99-Polish-Validation.md`

- [ ] **TASK-013-02**: In `11-Chat.md` (CHAT‑011) and `12-Workflow.md` (FLOW‑001), add notes that these libraries must be lazy‑loaded with `<Suspense>` and a skeleton fallback.  
  **Target Files**: `11-Chat.md`, `12-Workflow.md`

- [ ] **TASK-013-03**: In `01-Foundations.md` (FND‑002), add the `vite-plugin-monaco-editor-esm` and similar Vite‑specific plugins to the dependency installation subtasks.  
  **Target File**: `01-Foundations.md`

#### Priority / Urgency

🟠 High. The bundle budget in `POL‑C02` (vendor chunk <500KB, total initial JS <2MB) cannot be met without explicit code‑splitting. Monaco Editor alone is >5MB uncompressed. Without `manualChunks` and lazy loading, the initial bundle will far exceed the budget.

#### Research / Investigation

Vite's `rollupOptions.output.manualChunks` can group libraries into named chunks. Libraries like Monaco and React Flow should be loaded only when their respective features are activated (Chat Canvas, Workflow Editor). Using React's `lazy()` and `<Suspense>` with a skeleton ensures the main bundle stays small. The `vite-plugin-monaco-editor-esm` handles Monaco's Web Worker bundling correctly in Vite's ESM environment.

#### Related Files

- `99-Polish-Validation.md` (POL‑001)
- `11-Chat.md` (CHAT‑011 — Collaboration Canvas)
- `12-Workflow.md` (FLOW‑001 — Workflow Canvas)
- `01-Foundations.md` (FND‑002 — Dependencies)

#### Definition of Done

- `POL‑001` lists all heavy libraries with their chunk names and the feature that triggers their lazy load.
- Each affected feature task includes a note about lazy loading with fallback skeleton.
- Vite‑specific plugins are documented in FND‑002.

#### Acceptance Criteria

- `manualChunks` configuration groups Monaco, React Flow, and other heavy libs into separate chunks.
- The initial bundle size is verifiable below 2MB after code‑splitting.
- Switching to the Canvas or Workflow view shows a skeleton while the chunk loads.

#### Out of Scope

- Implementing the actual `manualChunks` Rollup configuration.
- Measuring actual bundle sizes (that happens after implementation).

#### Dependencies

None.

#### Estimated Effort

1.5 hours

#### Testing Requirements

- Build analysis: After implementation, run `rollup-plugin-visualizer` to verify chunk sizes.
- Manual: Verify that navigating to Canvas view shows a skeleton before the editor renders.

#### Validation Steps

1. Review `POL‑001` for the complete list of heavy libraries.
2. Check that each library is associated with a specific feature/view.
3. Verify the lazy‑loading notes in the relevant module tasks.

#### Strict Rules

- No library larger than 1MB may be in the initial bundle.
- All heavy libraries must have a skeleton fallback specified.
- The `manualChunks` configuration must be documented, not just implied.

#### Existing Code Patterns

Vite config pattern:
```typescript
build: {
  rollupOptions: {
    output: {
      manualChunks: {
        'monaco-editor': ['@monaco-editor/react'],
        'react-flow': ['@xyflow/react'],
        'charts': ['recharts'],
      },
    },
  },
}
```

React lazy loading pattern:
```tsx
const CanvasEditor = lazy(() => import('@/components/chat/CanvasEditor'));
// Wrap in:
<Suspense fallback={<EditorSkeleton />}>
  <CanvasEditor />
</Suspense>
```

#### Advanced Code Patterns

N/A — Configuration only.

#### Anti-Patterns

- ❌ Importing heavy libraries at the top level of a page component.
- ❌ Not providing a skeleton fallback, causing a blank screen during load.
- ❌ Using `React.lazy` without `<Suspense>` (it will throw).

---

### TASK-014: Specify SSE and ReadableStream Testing Utilities

**Status**: 🟡 Pending  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-014

#### Subtasks

- [ ] **TASK-014-01**: Add a section to `01-Foundations.md` FND‑004 for mocking `ReadableStream` and `AbortController` in Vitest. Specify a `createSSEStream(tokens, options?)` utility that returns a `Response` with a readable stream and SSE‑formatted chunks.  
  **Target File**: `01-Foundations.md`

- [ ] **TASK-014-02**: Update `11-Chat.md` (CHAT‑007D) to use the shared SSE mock utility instead of inline stream construction.  
  **Target File**: `11-Chat.md`

- [ ] **TASK-014-03**: Update `33-Translation.md` (TRANS‑006D) to use the shared SSE mock utility.  
  **Target File**: `33-Translation.md`

- [ ] **TASK-014-04**: Add test case patterns for partial chunk reassembly, `AbortError` suppression, and reconnect logic to the FND‑004 SSE section.  
  **Target File**: `01-Foundations.md`

#### Priority / Urgency

🟠 High. Streaming is used in Chat and Translation for real‑time updates. Testing stream consumption is notoriously tricky because of `ReadableStream` and `AbortController` interactions. Without shared test utilities, each module will implement its own (possibly buggy) test helpers, leading to false positives.

#### Research / Investigation

MSW can return `ReadableStream` responses. A common pattern is to create a `createSSEStream` function that takes an array of tokens and returns a `Response` with `Content-Type: text/event-stream`. The consumer reads with `response.body.getReader()`. Tests need to verify that partial chunks are buffered correctly, that `[DONE]` terminates the stream, and that `AbortError` is suppressed without calling `onError`.

#### Related Files

- `01-Foundations.md` (FND‑004)
- `src/test/sseMock.ts` (target implementation)
- `11-Chat.md` (CHAT‑007D)
- `33-Translation.md` (TRANS‑006D)

#### Definition of Done

- `FND‑004` contains a dedicated "SSE Testing" subsection with the `createSSEStream` utility specification.
- Both Chat and Translation stream handler specifications reference this utility.
- The subsection includes explicit test case patterns for the three key streaming edge cases.

#### Acceptance Criteria

- `createSSEStream(['Hello', ' world', '[DONE]'])` returns a Response whose reader yields the tokens.
- Partial chunk reassembly test passes: two `enqueue` calls whose concat forms a message are correctly reassembled.
- AbortError suppression test passes: aborting the reader does not trigger `onError`.

#### Out of Scope

- Implementing the actual utility (that is an implementation task).
- WebSocket testing utilities.

#### Dependencies

None.

#### Estimated Effort

1.5 hours

#### Testing Requirements

- Unit tests for the `createSSEStream` utility itself (verify it produces valid SSE).
- Integration tests: Use the utility in Chat and Translation stream tests.

#### Validation Steps

1. Review the SSE Testing section in `01-Foundations.md` for completeness.
2. Verify Chat and Translation MSW handler specs reference the utility.
3. Check that the three edge case patterns are documented.

#### Strict Rules

- The utility must return a standard `Response` object (MSW compatible).
- The `ReadableStream` must support cancellation via `AbortController.signal`.
- `[DONE]` must be sent as a separate chunk.

#### Existing Code Patterns

Specification for the utility:
```typescript
// src/test/sseMock.ts
export function createSSEStream(tokens: string[], options?: {
  delayMs?: number;
  shouldError?: boolean;
}): Response {
  const stream = new ReadableStream({
    async start(controller) {
      for (const token of tokens) {
        if (options?.shouldError) {
          controller.error(new Error('Simulated stream error'));
          return;
        }
        controller.enqueue(new TextEncoder().encode(`data: ${token}\n\n`));
        if (options?.delayMs) await new Promise(r => setTimeout(r, options.delayMs));
      }
      controller.close();
    },
  });

  return new Response(stream, {
    headers: { 'Content-Type': 'text/event-stream' },
  });
}
```

#### Advanced Code Patterns

Test patterns to add to FND‑004:
- **Partial chunk reassembly**: Enqueue two chunks `'{"tok'` and `'en":"hello"}'` then verify the consumer reconstructs the full JSON.
- **AbortError suppression**: Call `abortController.abort()` mid‑stream and verify `onError` is NOT called.
- **Reconnect**: Verify `Last-Event-ID` header is sent on subsequent requests.

#### Anti-Patterns

- ❌ Using `EventSource` in tests (cannot be mocked easily; use `fetch` + `ReadableStream`).
- ❌ Not testing partial chunk reassembly (network packets fragment arbitrarily).
- ❌ Treating `AbortError` as a real error in tests.

---

## 🟢 Phase 6: Quality and Polish

---

### TASK-015: Create Shared UI Components Library Specification

**Status**: 🟡 Pending  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-015

#### Subtasks

- [ ] **TASK-015-01**: Create a task in `01-Foundations.md` (FND‑002‑L or new FND‑003B) specifying the following shared components:
  - `<EmptyState icon="..." title="..." description="..." action={{ label, onClick }} />`
  - `<ErrorScreen title="..." message="..." onRetry={() => void} />`
  - `<ConfirmDialog title="..." description="..." confirmLabel="..." onConfirm={() => void} variant="destructive" />`
  - `<LoadingSkeleton variant="card" | "table" | "text" count={5} />`
  **Target File**: `01-Foundations.md`

- [ ] **TASK-015-02**: Update all module specs that describe custom empty states or error screens to reference these shared components instead.  
  **Target Files**: `40-News.md`, `21-Calendar.md`, `50-Budget.md`, `20-Projects.md`, `22-Lists.md`

- [ ] **TASK-015-03**: Ensure the components follow the established `oklch()` color tokens and motion tier assignments.  
  **Target File**: `01-Foundations.md`

#### Priority / Urgency

🟠 High. At least six different modules independently specify skeleton loaders, empty states, and error screens with nearly identical requirements. Extracting these into shared components reduces implementation effort by ~20% and ensures consistent UX across the entire application.

#### Research / Investigation

The News module (`NEWS‑003G`, `NEWS‑003H`) specifies `FeedSkeleton` and `FeedEmptyState` components. The Budget module (`BUDG‑003C`, `BUDG‑003D`) specifies skeleton and empty state components. The Projects module (`PROJ‑025A`, `PROJ‑025B`) specifies skeleton loaders and empty states. All follow similar patterns but are defined independently. Centralizing them into a shared library eliminates duplication and ensures a single source of truth for UX patterns.

#### Related Files

- `01-Foundations.md` (new task or sub-section)
- `src/components/shared/EmptyState.tsx` (target)
- `src/components/shared/ErrorScreen.tsx` (target)
- `src/components/shared/ConfirmDialog.tsx` (target)
- `src/components/shared/LoadingSkeleton.tsx` (target)
- `40-News.md`, `21-Calendar.md`, `50-Budget.md`, `20-Projects.md`, `22-Lists.md`

#### Definition of Done

- Shared component specs are in `01-Foundations.md`.
- At least the four listed component types are specified.
- All module specs reference these shared components for their loading/empty/error states.
- Each component specification includes props, variants, and motion tier assignment.

#### Acceptance Criteria

- Searching for "skeleton" or "empty state" in module specs returns references to the shared components.
- The shared component props cover all use cases described in the module specs.

#### Out of Scope

- Implementing the components (that is an implementation task).
- Building a full design system (only these four component types).

#### Dependencies

- TASK‑005 (`SanitizedHTML` component should be part of this library or alongside it).

#### Estimated Effort

2 hours

#### Testing Requirements

- Specification review: Verify all module empty/error/loading states map to a shared component variant.
- Implementation tests: Verify each component renders correctly with sample props.

#### Validation Steps

1. Review the shared component specifications for completeness.
2. Search module specs for custom empty state descriptions and verify they now reference the shared components.
3. Verify the props cover all described use cases.

#### Strict Rules

- The shared components must accept `className` for Tailwind overrides in consuming modules.
- All components must have accessible names and roles (e.g., `<EmptyState>` has `role="status"`).
- Skeletons must respect `prefers-reduced-motion`.

#### Existing Code Patterns

N/A — Specification only.

#### Advanced Code Patterns

Example specification for EmptyState:
```tsx
interface EmptyStateProps {
  icon: LucideIcon;
  title: string;
  description?: string;
  action?: { label: string; onClick: () => void };
  className?: string;
}
```

#### Anti-Patterns

- ❌ Each module building its own skeleton component with different animation patterns.
- ❌ Using different terminology for the same concept (e.g., "no data" vs "empty" vs "nothing here").
- ❌ Not providing an action CTA in empty states.

---

### TASK-016: Create End-to-End Scenarios Specification

**Status**: 🟡 Pending  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-016

#### Subtasks

- [ ] **TASK-016-01**: Create `98-EndToEndScenarios.md` describing 5‑10 critical multi‑module user workflows:
  1. Dashboard → Chat → Canvas → Create Project
  2. Calendar → Create Event → Link to Project → Budget Forecast
  3. Email → Convert to Task → Project Task List → Complete
  4. Research → OCR Document → AI Q&A → Export Report
  5. Triage → Plan for Week → My Week View → Mark Complete
  **Target File**: `98-EndToEndScenarios.md`

- [ ] **TASK-016-02**: Each scenario must list the module task IDs involved, the expected sequence of user actions, and the expected system responses.  
  **Target File**: `98-EndToEndScenarios.md`

- [ ] **TASK-016-03**: Add a note that these scenarios should be implemented as Playwright E2E tests in Phase 6.  
  **Target File**: `98-EndToEndScenarios.md`

- [ ] **TASK-016-04**: Update `99-Polish-Validation.md` POL‑002D to reference these scenarios as the minimum E2E test coverage.  
  **Target File**: `99-Polish-Validation.md`

#### Priority / Urgency

🟠 High. E2E tests validate that modules work together correctly. Without predefined scenarios, E2E testing will be ad‑hoc and miss critical integration bugs. The scenarios also serve as a validation checklist for the build sequence.

#### Research / Investigation

The `99-Polish-Validation.md` POL‑002D already mentions four E2E test cases but they are minimal. Expanding to 5‑10 scenarios covering the most important user journeys ensures that cross‑module dependencies are validated. Each scenario should be a self‑contained narrative that references specific task IDs and UI components.

#### Related Files

- `98-EndToEndScenarios.md` (new)
- `99-Polish-Validation.md` (POL‑002D)
- All module specs (for task ID references)

#### Definition of Done

- `98-EndToEndScenarios.md` exists with 5‑10 scenarios.
- Each scenario includes task IDs, user actions, and system responses.
- The `POL‑002D` checklist references this document.

#### Acceptance Criteria

- Scenarios cover Dashboard, Chat, Calendar, Email, Projects, Budget, Documents, Triage, and Research.
- Each scenario name is a descriptive title.
- Task ID references are correct and verifiable.

#### Out of Scope

- Writing the actual Playwright test code.
- Defining Playwright configuration for these tests.

#### Dependencies

- TASK‑001 (all task IDs must be correct).
- TASK‑002 (Plan must be aligned for sequence logic).

#### Estimated Effort

2 hours

#### Testing Requirements

- Specification review: Verify each scenario is logically coherent and references valid task IDs.
- Implementation: After modules are built, implement these as Playwright tests.

#### Validation Steps

1. Read each scenario and verify the sequence of actions is logical.
2. Check that all referenced task IDs exist in the task registry.
3. Verify scenarios cover at least 5 different modules.

#### Strict Rules

- Each scenario must involve at least two different modules.
- Module task IDs must be the canonical IDs from the task registry.
- System responses must be described concretely, not vaguely.

#### Existing Code Patterns

N/A — Specification only.

#### Advanced Code Patterns

N/A

#### Anti-Patterns

- ❌ Scenarios that test only one module in isolation.
- ❌ Vague system responses like "the UI updates."
- ❌ Referencing task IDs that don't exist.

---

### TASK-017: Add Cross-Module Cache Invalidation Map

**Status**: 🟡 Pending  
**Priority**: 🟡 Medium  
**Parent Task ID**: TASK-017

#### Subtasks

- [ ] **TASK-017-01**: Add a "Cross‑Module Invalidation Map" section to `01-Foundations.md` (under FND‑006) that lists which module's mutation should trigger invalidation of which other module's query keys.  
  **Target File**: `01-Foundations.md`

- [ ] **TASK-017-02**: Define the initial invalidation mappings:
  - `useCreateTransaction` → invalidate `budgetKeys.dashboard()`, `budgetKeys.categories()`.
  - `useUpdateTask` (complete) → invalidate `projectKeys.detail(projectId)`, `budgetKeys.reports()` (if task has budget tracking).
  - `useCreateProject` → invalidate `budgetKeys.goals()` (if linked to budget goal).
  - `useStarEmail` → no cross‑module invalidation needed.
  **Target File**: `01-Foundations.md`

- [ ] **TASK-017-03**: Update each affected mutation specification to include the cross‑module keys in its `onSettled` invalidation.  
  **Target Files**: `50-Budget.md`, `20-Projects.md`, `30-Email.md`

#### Priority / Urgency

🟡 Medium. Without deliberate cross‑module invalidation, data will become stale when actions in one module affect another (e.g., completing a budget‑tracked task updates the project but the budget dashboard still shows old data). This causes UX confusion and potential data integrity issues.

#### Research / Investigation

TanStack Query supports invalidating multiple query keys in `onSettled`. The current specs only invalidate keys within the same module. The invalidation map formalizes which cross‑module dependencies exist, preventing stale caches. This is particularly important for the tight integration between Projects and Budget, Email and Calendar, and Chat and Research.

#### Related Files

- `01-Foundations.md` (FND‑006)
- `50-Budget.md` (BUDG‑001F, BUDG‑006)
- `20-Projects.md` (PROJ‑000H)
- `30-Email.md` (EMAIL‑000G)

#### Definition of Done

- The invalidation map exists in `01-Foundations.md`.
- At least 5 cross‑module invalidation rules are documented.
- Affected mutation specs include the cross‑module keys.

#### Acceptance Criteria

- A developer reading the invalidation map can determine which caches will be refreshed after any mutation.
- Each rule includes the source mutation, target module, target query key(s), and rationale.

#### Out of Scope

- Implementing a generic cross‑module invalidation middleware (that is a future enhancement).
- Mapping every possible mutation (only high‑impact ones for MVP).

#### Dependencies

- TASK‑001 (task IDs must be correct).

#### Estimated Effort

1.5 hours

#### Testing Requirements

- Manual verification: After building, test that completing a budget‑tracked task refreshes the budget dashboard.
- Automated: Add integration tests that verify stale data is not shown after cross‑module mutations.

#### Validation Steps

1. Review the invalidation map for completeness.
2. Verify each listed source mutation has a corresponding `onSettled` calling `invalidateQueries` for the target keys.
3. Test manually after implementation.

#### Strict Rules

- Cross‑module invalidation must use the established key factories (e.g., `projectKeys.detail(id)`).
- Invalidations must be in `onSettled`, not `onSuccess`.
- Never invalidate `all` keys indiscriminately — be specific.

#### Existing Code Patterns

The existing modules already follow:
```typescript
onSettled: () => {
  queryClient.invalidateQueries({ queryKey: entityKeys.all });
}
```
Extend to:
```typescript
onSettled: () => {
  queryClient.invalidateQueries({ queryKey: entityKeys.all });
  // Cross-module invalidation:
  queryClient.invalidateQueries({ queryKey: budgetKeys.reports() });
}
```

#### Advanced Code Patterns

N/A

#### Anti-Patterns

- ❌ Invalidating `['budget']` (the entire module) instead of specific keys.
- ❌ Using `onSuccess` for cross‑module invalidation.
- ❌ Not documenting the cross‑module dependency, leading to forgotten invalidations.

---

## 📊 Task Dependency Graph

```
TASK-001 (Phantom IDs)
├── TASK-002 (Plan Alignment)
├── TASK-003 (Centralized Dexie)
├── TASK-004 (Shared Recurrence)
├── TASK-005 (SanitizedHTML)
├── TASK-006 (useOptimisticMutation)
├── TASK-007 (WCAG 2.5.7)
│   └── TASK-008 (Screen Reader Announcements)
├── TASK-009 (Auth Spec)
│   └── TASK-010 (Notification Center)
├── TASK-011 (Route Map)
├── TASK-012 (Seed Data)
├── TASK-013 (Code Splitting)
├── TASK-014 (SSE Testing)
├── TASK-015 (Shared UI Components)
├── TASK-016 (E2E Scenarios)
└── TASK-017 (Cache Invalidation Map)
```

---

## 🏁 Completion Checklist

- [ ] **TASK-001**: Zero phantom task IDs remain.
- [ ] **TASK-002**: Plan phase lists match module specs exactly.
- [ ] **TASK-003**: Only one Dexie instance defined across all specs.
- [ ] **TASK-004**: Four modules reference shared RecurrenceEngine.
- [ ] **TASK-005**: Four modules reference shared SanitizedHTML.
- [ ] **TASK-006**: All mutations use the shared wrapper.
- [ ] **TASK-007**: All drag operations have WCAG 2.5.7 alternatives.
- [ ] **TASK-008**: All drag operations produce screen reader announcements.
- [ ] **TASK-009**: Auth module specification complete.
- [ ] **TASK-010**: Notification center specification complete.
- [ ] **TASK-011**: Global route map complete.
- [ ] **TASK-012**: Seed data specification complete.
- [ ] **TASK-013**: Code‑splitting strategy documented.
- [ ] **TASK-014**: SSE testing utilities specified.
- [ ] **TASK-015**: Shared UI component library specified.
- [ ] **TASK-016**: End‑to‑end scenarios documented.
- [ ] **TASK-017**: Cross‑module invalidation map documented.
```

This `TODO.md` consolidates all 17 actionable remediation tasks discovered across the four audit rounds, organized by priority and with full traceability from each finding back to the relevant specification file. Each task is self‑contained with explicit acceptance criteria, dependencies, and strict rules so that an agentic coding system or a developer unfamiliar with the codebase can execute them independently.