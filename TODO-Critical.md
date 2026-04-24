# TODO-Critical.md — Phase 1: Critical Cross-Document Corrections

> **Split from**: TODO.md (lines 24-377)
> **Purpose**: Critical cross-document corrections that must be completed first before any other work.
> **Status**: All tasks completed

---

## 🔴 Phase 1: Critical Cross-Document Corrections (Must Do First)

---

### TASK-001: Fix Phantom Task IDs Across All Specifications

**Status**: ✅ Done  
**Priority**: 🔴 Critical  
**Parent Task ID**: TASK-001

#### Subtasks

- [x] **TASK-001-01**: Replace `TASK‑006` with `DASH‑006` and `TASK‑007` with `DASH‑007` in `20-Projects.md` (PROJ‑020, PROJ‑024) and `11-Chat.md` (CHAT‑015, CHAT‑018, CHAT‑021).  

  [CHECK PATH: `20-Projects.md` and `11-Chat.md` exist at project root] [CONFIRM ID: DASH‑006, DASH‑007, PROJ‑020, PROJ‑024, CHAT‑015, CHAT‑018, CHAT‑021 exist in their respective module specs] [VERIFY: these are the only files containing the phantom IDs; re‑run `grep -r "TASK-006\|TASK-007" *.md` before starting]  
  **Target Files**: `20-Projects.md`, `11-Chat.md`

- [x] **TASK-001-02**: Replace `TASK‑005 (Hooks/Stores)` with `FND‑005 (Zustand)`, `FND‑006 (TanStack Query)` in `11-Chat.md` (CHAT‑015, CHAT‑018).  

  [CONFIRM ID: FND‑005 and FND‑006 in `01-Foundations.md` still represent the intended dependencies] [VERIFY: replacement context in CHAT‑015/CHAT‑018 is still appropriate — no shift of meaning]  
  **Target File**: `11-Chat.md`

- [x] **TASK-001-03**: Replace `TASK‑003 (UI Components)` with `FND‑004 (Testing Infra)`, `FND‑006 (TanStack Query)` in `11-Chat.md` (CHAT‑018).  

  [CONFIRM ID: FND‑004 is indeed Testing Infra; verify that no other FND ID would be more accurate]  
  **Target File**: `11-Chat.md`

- [x] **TASK-001-04**: Add a cross-reference validation script at `scripts/validate-task-refs.js` that parses all `Depends On` fields in markdown files and verifies each referenced task ID exists in the canonical task registry.  

  [CHECK PATH: `scripts/` directory exists; if not, create it] [VERIFY: Markdown parsing logic must handle the exact `**Parent Task ID**:` and `### TASK-` patterns used across all spec files; adapt if any spec uses different heading levels] [IMPLEMENT: use the registry described in TASK‑001‑05]  
  **Target File**: `scripts/validate-task-refs.js`

- [x] **TASK-001-05**: Create a canonical task registry at `docs/task-registry.json` listing every task ID across all specification files.  

  [CHECK PATH: `docs/` directory exists] [VERIFY: the registry must be regenerated after any ID changes; consider making it an output of the validation script]  
  **Target File**: `docs/task-registry.json`

#### Priority / Urgency

🔴 Critical. Phantom references create dead links that will derail agentic coding. Without fixing these, automated build scripts that trace dependencies will fail.

#### Research / Investigation

Confirmed via full-text search across all specification files. The IDs `TASK‑006`, `TASK‑007`, `TASK‑005`, and `TASK‑003` appear in the Chat and Projects modules but do not correspond to any existing task in Foundation or Dashboard specifications. These are renumbering artifacts from earlier specification drafts.  
[VERIFY: this statement remains true at the time of execution; re‑run the full‑text search]

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

- Running `grep -r "TASK-006\|TASK-007\|TASK-005\|TASK-003" *.md` returns zero results. [VERIFY: the grep command works on the target OS; if using PowerShell, adapt accordingly]
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
1. Recursively find all `.md` files in the project root. [VERIFY: root directory and glob pattern `**/*.md` covers all spec files; adjust if specs are in a subfolder]
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

- [x] **TASK-002-01**: In `00-Plan.md` Phase 1 Calendar, rename `CAL‑002 Mini‑calendar sidebar` to `CAL‑002 Multi-Calendar Support & Calendar List Sidebar` and add note that mini‑calendar is part of `CAL‑001`.  

  [CHECK PATH: `00-Plan.md`] [CONFIRM ID: CAL‑001 and CAL‑002 in `21-Calendar.md` match this description — check for any recent renames]  
  **Target File**: `00-Plan.md`

- [x] **TASK-002-02**: In `00-Plan.md` Phase 5 Documents, add `DOC‑005 (OCR Pipeline)` to the task list.  

  [CONFIRM ID: DOC‑005 exists in `41-Documents.md` with that exact title; verify the task has not been removed or renamed]  
  **Target File**: `00-Plan.md`

- [x] **TASK-002-03**: In `00-Plan.md` Phase 6 Polish, add `POL‑003 (Analytics, Audit & RUM)` to the task list.  

  [CONFIRM ID: POL‑003 exists in `99-Polish-Validation.md`]  
  **Target File**: `00-Plan.md`

- [x] **TASK-002-04**: In `00-Plan.md` Phase 4 Budget, add `BUDG‑013 (Financial Planning Dashboard)` to the deferred list with explicit deferral note.  

  [CONFIRM ID: BUDG‑013 exists in `50-Budget.md`]  
  **Target File**: `00-Plan.md`

- [x] **TASK-002-05**: Audit all remaining Phase lists against the latest module specs and add any missing tasks or mark deferred tasks explicitly.  

  [VERIFY: the list of module specs has not changed — include any newly created spec files (e.g., Auth, Notifications) if they have been added]  
  **Target File**: `00-Plan.md`

#### Priority / Urgency

🔴 Critical. The Plan is the authoritative roadmap for implementation order. If it lists incorrect task names or omits tasks, the build sequence will be wrong, leading to circular dependencies and blockers during development.

#### Research / Investigation

Compared the canonical module specs against the Plan task lists. The Plan was generated from an earlier version of the specs before several modules were enhanced (Budget, Calendar, Documents). The mismatches are documented in the subtasks.  
[VERIFY: the comparison remains accurate; if any module spec has been updated since this audit, re‑compare]

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

**Status**: ✅ Done  
**Priority**: 🔴 Critical  
**Parent Task ID**: TASK-003

#### Subtasks

- [x] **TASK-003-01**: Remove the standalone `NewsDB` class definition from `40-News.md` (NEWS‑005B) and replace with import from `@/lib/db` (`CommandCenterDB`).  

  [CHECK PATH: `40-News.md` exists; CONFIRM ID: NEWS‑005B is the correct subtask containing that definition — if the section has been restructured, adjust]  
  **Target File**: `40-News.md`

- [x] **TASK-003-02**: Remove local Dexie store definitions from `41-Documents.md` (DOC‑014A) and replace with reference to the centralized `CommandCenterDB`.  

  [CHECK PATH: `41-Documents.md`; CONFIRM ID: DOC‑014A is the correct location]  
  **Target File**: `41-Documents.md`

- [x] **TASK-003-03**: Audit `30-Email.md`, `31-Contacts.md`, `22-Lists.md`, `50-Budget.md` for any standalone Dexie instance declarations or local store definitions. Replace with references to shared `CommandCenterDB`.  

  [VERIFY: the exact locations of any Dexie mentions, as they may have moved; if modules have been refactored, update the file list]  
  **Target Files**: `30-Email.md`, `31-Contacts.md`, `22-Lists.md`, `50-Budget.md`

- [x] **TASK-003-04**: In `01-Foundations.md`, append a "Migration Strategy" section to the `CommandCenterDB` class documentation specifying that new module stores must increment the database version and define a migration function.  

  [CHECK PATH: `01-Foundations.md`; VERIFY: the `CommandCenterDB` section's heading is still `### CommandCenterDB` and the file is editable as expected] [UPDATE IF: `01-Foundations.md` already contains a migration section — then adjust vs. append]  
  **Target File**: `01-Foundations.md`

- [x] **TASK-003-05**: Create a central `src/lib/db.ts` implementation with the full `CommandCenterDB` schema from `01-Foundations.md` (if not already present).  

  [CHECK PATH: `src/lib/db.ts` may already exist; if so, verify its schema matches the spec exactly before overwriting]  
  **Target File**: `src/lib/db.ts`

#### Priority / Urgency

🔴 Critical. Multiple IndexedDB databases cause data fragmentation, prevent cross-module data access, and create schema inconsistency bugs. The `01-Foundations.md` already defines the canonical `CommandCenterDB`; all modules must use it.

#### Research / Investigation

Confirmed via text search that `40-News.md` defines `class NewsDB extends Dexie` and `41-Documents.md` defines `documents_metadata`, `documents_pending_mutations`, `documents_offline_files`. The global `CommandCenterDB` in `01-Foundations.md` already has prefixed stores for both modules. Using a single DB follows the Dexie best practice of one database per application.  
[VERIFY: the search result still holds; if any of those files have since been updated, re‑run search]

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

- Searching for `extends Dexie` across all markdown files returns only the definition in `01-Foundations.md`. [VERIFY: the search pattern captures all variants, such as `extends Dexie` vs `extends Dexie(…)`]
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
    comment.legacyField = null;
  });
});
```

[VERIFY: the exact store names and indexes match the current spec; cross‑check with `01-Foundations.md`]

#### Anti-Patterns

- ❌ Using a different database name per module.
- ❌ Forgetting to re-declare all existing stores when adding a new version.
- ❌ Not including an `upgrade` function when adding new stores.

---

## See Also

- **Next**: [TODO-Core.md](TODO-Core.md) - Phase 2: Shared Infrastructure Extraction
- **Overview**: [TODO.md](TODO.md) - Main task index with all phases
- **Remaining**: [TODO-Remaining.md](TODO-Remaining.md) - Phases 3-6: Accessibility, Infrastructure, Performance, and Polish
