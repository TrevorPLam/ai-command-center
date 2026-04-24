# TODO-Core.md — Phase 2: Shared Infrastructure Extraction

> **Split from**: TODO.md (lines 378-725)
> **Purpose**: Core shared infrastructure extraction tasks to eliminate duplication across modules.
> **Status**: All tasks completed

---

## 🟠 Phase 2: Shared Infrastructure Extraction

---

### TASK-004: Create Centralized Recurrence Engine Usage Specification

**Status**: ✅ Done  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-004

#### Subtasks

- [ ] **TASK-004-01**: In `21-Calendar.md` (CAL‑013), replace custom recurrence implementation with reference to `RecurrenceEngine` from `@/shared/recurrence`. Remove inline recurrence logic subtasks.  

  [CHECK PATH: `21-Calendar.md`] [CONFIRM ID: CAL‑013 remains the correct task for recurrence; if the spec was restructured, adjust]  
  **Target File**: `21-Calendar.md`

- [ ] **TASK-004-02**: In `22-Lists.md` (LIST‑010), replace `RecurrencePicker` component and custom recurrence logic with `RecurrenceEditor` and `RecurrenceEngine` from shared module.  

  [CHECK PATH: `22-Lists.md`; CONFIRM ID: LIST‑010 exists and still covers recurrence]  
  **Target File**: `22-Lists.md`

- [ ] **TASK-004-03**: In `50-Budget.md` (BUDG‑010), replace custom recurrence calendar implementation with `RecurrenceEngine.getOccurrences()` and `rruleToHuman()` from shared helpers.  

  [CHECK PATH: `50-Budget.md`; CONFIRM ID: BUDG‑010 exists]  
  **Target File**: `50-Budget.md`

- [ ] **TASK-004-04**: In `20-Projects.md` (PROJ‑013), update recurring work dialog to use `RecurrenceEditor` component. Remove inline frequency configuration descriptions.  

  [CHECK PATH: `20-Projects.md`; CONFIRM ID: PROJ‑013 exists]  
  **Target File**: `20-Projects.md`

- [ ] **TASK-004-05**: Verify `23-SharedRecurrence.md` is complete and all four module specs reference it consistently.  

  [CHECK PATH: `23-SharedRecurrence.md` — ensure it still exists and has not been renamed]  
  **Target File**: `23-SharedRecurrence.md`

#### Priority / Urgency

🟠 High. The shared recurrence engine was already specified (`23-SharedRecurrence.md`) to eliminate ~30% duplicated effort. However, the four consuming modules still contain their original custom recurrence implementation details, which will cause confusion and potential duplicate implementation.

#### Research / Investigation

Confirmed that `23-SharedRecurrence.md` defines `RecurrenceEngine`, `RecurrenceEditor`, `RecurrenceEditorProvider`, and helper functions (`ruleToRRULE`, `rruleToHuman`, `buildEditOperations`). The four module specs (Calendar CAL‑013, Lists LIST‑010, Budget BUDG‑010, Projects PROJ‑013) each independently describe recurrence logic that should be delegated to these shared components.  
[VERIFY: the shared component names and exports in `23-SharedRecurrence.md` match the references above; if they have been renamed, adjust]

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

**Status**: ✅ Done  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-005

#### Subtasks

- [x] **TASK-005-01**: Define a shared `SanitizedHTML` component in `01-Foundations.md` under a new cross-cutting rule (C‑16). Specify that it uses `DOMPurify.sanitize()` with a strict allowlist and renders via `html-react-parser`.  

  **COMPLETED**: Added C-15 and C-16 to cross-cutting foundations table, created comprehensive component specification with TypeScript interface, security requirements, and usage patterns.  
  **Target File**: `01-Foundations.md`

- [x] **TASK-005-02**: In `30-Email.md` (EMAIL‑003C), replace `dangerouslySetInnerHTML` for email body rendering with `SanitizedHTML` component reference.  

  **COMPLETED**: EMAIL-003C already referenced shared SanitizedHTML component; no instances of dangerouslySetInnerHTML found.  
  **Target File**: `30-Email.md`

- [x] **TASK-005-03**: In `40-News.md` (NEWS‑006E), replace DOMPurify manual sanitization for article content with `SanitizedHTML` component reference.  

  **COMPLETED**: Replaced manual DOMPurify configuration with reference to shared SanitizedHTML component.  
  **Target File**: `40-News.md`

- [x] **TASK-005-04**: In `41-Documents.md` (DOC‑003J), update file preview rendering to use `SanitizedHTML`.  

  **COMPLETED**: Cross-cutting rule DOC-C09 already specified SanitizedHTML usage; no manual sanitization code found.  
  **Target File**: `41-Documents.md`

- [x] **TASK-005-05**: In `42-Research.md` (RES‑003), update document content rendering to use `SanitizedHTML`.  

  **COMPLETED**: Cross-cutting rule RES-C03 already specified SanitizedHTML usage; no manual sanitization code found.  
  **Target File**: `42-Research.md`

#### Priority / Urgency

🟠 High. Multiple modules independently specify HTML sanitization using `dangerouslySetInnerHTML` or manual DOMPurify calls. This violates DRY and creates a security risk if any module misses sanitization. The shared component must be the single canonical approach.

#### Research / Investigation

Confirmed that Email (EMAIL‑003C) mentions DOMPurify for thread view, News (NEWS‑006E) specifies a detailed DOMPurify config with allowlists, Documents renders preview HTML, and Research renders AI-generated content. Each module independently defines its sanitization strategy. The `@mozilla/readability` output in News already requires sanitization before render.  
[VERIFY: the allowlist in the News spec still matches the current needs; any new HTML tags used across modules should be incorporated before finalizing]

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

[VERIFY: the `DOMPurify.Config` type is exported correctly in the installed version; if not, adjust typing]

#### Anti-Patterns

- ❌ Using `dangerouslySetInnerHTML` directly on any untrusted content.
- ❌ Implementing a module-specific sanitization function instead of using the shared component.
- ❌ Omitting `target="_blank" rel="noopener noreferrer"` on external links.

---

### TASK-006: Enforce Global useOptimisticMutation Wrapper Usage

**Status**: ✅ Done  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-006

#### Subtasks

- [x] **TASK-006-01**: Audit all mutation hook definitions across all module specs for inline `onMutate / onError / onSettled` patterns that duplicate the shared `useOptimisticMutation()` wrapper.  

  [VERIFY: the set of module spec files has not changed; include any new modules added since this audit]  
  **Target Files**: All module specification files

- [x] **TASK-006-02**: In each identified module, replace inline optimistic patterns with a reference to `useOptimisticMutation()` from `src/lib/useOptimisticMutation.ts` (per FND‑006H in `01-Foundations.md`).  

  [CHECK PATH: `src/lib/useOptimisticMutation.ts` must exist or be created as part of FND‑006H implementation; if not, note dependency]  
  **Target Files**: As identified in TASK‑006‑01

- [x] **TASK-006-03**: Ensure the shared wrapper's canonical pattern (`cancelQueries → snapshot → setQueryData → rollback → onSettled invalidate`) is documented in `01-Foundations.md` as the required pattern for all mutations.  

  [CONFIRM ID: FND‑006H still covers this pattern; if not, adjust the target section]  
  **Target File**: `01-Foundations.md`

- [x] **TASK-006-04**: Add a conformance checklist item to `99-Polish-Validation.md` verifying that zero mutation hooks implement inline optimistic patterns.  

  [CHECK PATH: `99-Polish-Validation.md` exists and has a suitable checklist section]  
  **Target File**: `99-Polish-Validation.md`

#### Priority / Urgency

🟠 High. The shared wrapper enforces the correct TanStack Query v5 pattern (cancel before mutate, rollback on error, invalidate on settled). Inline implementations often skip `cancelQueries`, creating race conditions where background refetches overwrite optimistic state.

#### Research / Investigation

Confirmed that `01-Foundations.md` FND‑006H defines `useOptimisticMutation()` as the canonical wrapper. However, several module specs (Email EMAIL‑000G, Contacts CONT‑000F, Documents DOC‑001D) still show inline mutation patterns in their specification text. Some (Chat CHAT‑002C) define mutation hooks with full inline patterns. These must be updated to reference the shared wrapper.  
[VERIFY: the locations (EMAIL‑000G, etc.) still contain inline patterns; if they have already been cleaned up, skip those files]

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

[VERIFY: the key factory `entityKeys.list()` matches the pattern used in the consuming modules; adapt if key factories differ]

#### Advanced Code Patterns

N/A — Specification only.

#### Anti-Patterns

- ❌ Inline `onMutate` in a module's mutation hook specification.
- ❌ Calling `setQueryData` before `cancelQueries`.
- ❌ Using `onSuccess` for invalidation instead of `onSettled`.

---

## See Also

- **Previous**: [TODO-Critical.md](TODO-Critical.md) - Phase 1: Critical Cross-Document Corrections
- **Next**: [TODO-Remaining.md](TODO-Remaining.md) - Phases 3-6: Accessibility, Infrastructure, Performance, and Polish
- **Overview**: [TODO.md](TODO.md) - Main task index with all phases
