# SPEC-CORRECTIONS — Verified Refinements for Foundation Documents

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.  
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.  
> **Versioning Note**: This document captures all corrections, verified version pins, and motion enforcement refinements derived from the final April 2026 research. These tasks must be applied to the project specification files **before any development begins**.

---

## Task SPEC-001: Pin Verified Package Versions in All Dependency Sections

**Priority:** 🔴 High | **Est. Effort:** 45 min | **Depends On:** None

**Status:** ✅ Done

### Related Files
- `01-Foundations.md` (Task FND-002)
- All module spec files that contain `pnpm add` commands

### Subtasks
- [x] **SPEC-001A**: Update the install commands in `01-Foundations.md` FND-002 to exact verified versions:
  ```sh
  pnpm add react@19.2.5 react-dom@19.2.5
  pnpm add @tanstack/react-query@5.99.2
  pnpm add zustand@5.0.12
  pnpm add @tanstack/react-virtual@3.13.24
  pnpm add react-big-calendar@1.19.4
  pnpm add zod@4.3.6
  pnpm add motion@12.38.0
  pnpm add @hookform/resolvers@5.2.2
  pnpm add -D vitest@4.1.0
  pnpm add -D eslint@10.2.1
  ```
- [x] **SPEC-001B**: Add a footnote after the install block: *"These versions are confirmed as of April 23, 2026. Verify against the npm registry during implementation and update if patches have been released."*
- [x] **SPEC-001C**: Scan every other module file (`03-Chat.md`, `04-Projects.md`, `05-Calendar.md`, `06-News.md`, `07-Budget.md`, `08-Settings.md`, `09-Polish-Validation.md`) and replace any `pnpm add` commands with the corresponding pinned versions from the matrix above.
- [x] **SPEC-001D**: Remove any references to `react-window` as a dependency; replace with `@tanstack/react-virtual` where the library is being added.

### Definition of Done
- All dependency install commands across all specification documents reflect the verified, pinned versions.
- A verification note is present.
- No `react-window` install commands remain.

---

## Task SPEC-002: Add OKLCH Design Tokens & Create Typed Token File

**Priority:** 🔴 High | **Est. Effort:** 20 min | **Depends On:** None

**Status:** ✅ Done

### Related Files
- `01-Foundations.md` (Task FND-000)
- (New) `src/lib/tokens.ts`

### Subtasks
- [x] **SPEC-002A**: In `01-Foundations.md` FND-000C, add the OKLCH equivalents alongside the existing hex color definitions:
  ```css
  --background: oklch(9.8% 0.006 264);   /* #050507 */
  --ring: oklch(62% 0.19 264);           /* #0066ff - electric blue */
  ```
  - **Note:** Applied to FND-000C (color tokens section) rather than FND-000G (ThemeProvider)
- [x] **SPEC-002B**: Update subtask **FND-000I** (typed tokens) to explicitly require the creation of `src/lib/tokens.ts` exporting these values as TypeScript constants:
  ```ts
  export const tokens = {
    background: 'oklch(9.8% 0.006 264)',
    accent: 'oklch(62% 0.19 264)',
  } as const;
  ```
- [x] **SPEC-002C**: Throughout the Foundation document, replace any remaining references to the accent color as `#0066ff` with the token name `var(--ring)` (or the appropriate CSS variable), ensuring the spec consistently points to the token, not the raw value.
  - **Note:** No `#0066ff` usage references found in document; already uses token names (`--accent`, `--ring`, `outline-accent`)

### Definition of Done
- OKLCH equivalents are documented in the design token section.
- The creation of `src/lib/tokens.ts` is a defined subtask.
- The accent color is referenced via token, not raw hex.

---

## Task SPEC-003: Unify Virtualization Strategy on TanStack Virtual

**Priority:** 🔴 High | **Est. Effort:** 1.5 hours | **Depends On:** SPEC-001

**Status:** ✅ Done

### Related Files
- `01-Foundations.md` (Cross-cutting C‑03, C‑05)
- `03-Chat.md` (CHAT‑005)
- `04-Projects.md` (PROJ‑003, PROJ‑009)
- `06-News.md` (NEWS‑003)

### Subtasks
- [x] **SPEC-003A**: Rewrite Cross-cutting requirement **C‑03** in `01-Foundations.md` to read:
  > Use `@tanstack/react-virtual` (`useVirtualizer`) for all virtualized lists. This aligns with the TanStack ecosystem already in use (Query, Table). Existing `react-window` patterns in the Chat and News modules are acceptable implementations but should be considered technical debt to migrate when those modules are revisited."
- [x] **SPEC-003B**: Update **CHAT‑005** (Virtual Scroll) to replace `react-window` references with `@tanstack/react-virtual`. Keep the scroll anchoring contract and the IntersectionObserver sentinel pattern intact. The migration is: `VariableSizeList` → `useVirtualizer` + `measureElement`.
- [x] **SPEC-003C**: Confirm **PROJ‑003** (Project List View) and **PROJ‑009** (Project Task List) already specify TanStack Table + TanStack Virtual. Remove any lingering mentions of `react-window` as the implementation library.
- [x] **SPEC-003D**: Update **NEWS‑003** (Feed Infrastructure) to replace `react-window` with `@tanstack/react-virtual`. Adapt the existing row height measurement pattern to use `measureElement` and `resetAfterIndex`.
- [x] **SPEC-003E**: Add a brief migration note at the top of `03-Chat.md` and `06-News.md` acknowledging that the previous spec referenced `react-window`, but the corrected approach is to use TanStack Virtual.

### Definition of Done
- All virtualization requirements across all specification files point to `@tanstack/react-virtual`.
- Migration notes exist for modules that originally specified `react-window`.

---

## Task SPEC-004: Finalize Calendar Library on `react-big-calendar`

**Priority:** 🔴 High | **Est. Effort:** 30 min | **Depends On:** SPEC-001

### Related Files
- `05-Calendar.md` (all calendar tasks)
- `01-Foundations.md` (C‑12 reference if present)

### Subtasks
- [ ] **SPEC-004A**: In `05-Calendar.md`, add a clear dependency statement after the introduction:
  > "Calendar library: `react-big-calendar ^1.19.4`. This library meets all feature requirements: Month/Week/Day/Agenda/Resource views, drag‑and‑drop via `withDragAndDrop`, date‑fns localization, and time‑zone handling. No alternative library is under consideration for the MVP."
- [ ] **SPEC-004B**: In **CAL‑009** and **CAL‑010**, ensure the import paths and component references use `react-big-calendar` and its addons (`react-big-calendar/lib/addons/dragAndDrop`).
- [ ] **SPEC-004C**: Remove any residual mentions of `@schedule-x/react`. If a comparison was described in earlier drafts, replace it with the finalized decision statement.

### Definition of Done
- `react-big-calendar` is the only calendar library mentioned.
- All integration instructions (DnD, localization, theming) reference `react-big-calendar` APIs.

---

## Task SPEC-005: Correct Drag‑and‑Drop Library Status

**Priority:** 🟠 Medium | **Est. Effort:** 30 min | **Depends On:** None

### Related Files
- `04-Projects.md` (Tasks PROJ‑004, PROJ‑009)
- `01-Foundations.md` (if drag-and-drop guidance is present)

### Subtasks
- [ ] **SPEC-005A**: In `04-Projects.md`, immediately after the `@dnd-kit/core` installation step, insert the following note:
  > "`@dnd-kit/core@6.3.1` was last updated December 2024. Development has moved to the newer `@dnd-kit/react` and `@dnd-kit/dom` packages. For the MVP, `@dnd-kit/core` meets all requirements. Schedule evaluation of `@dnd-kit/react` or `@atlaskit/pragmatic-drag-and-drop` as a POL‑001 performance/debt review item."
- [ ] **SPEC-005B**: Throughout `04-Projects.md`, ensure no statements claim `@dnd-kit` is "end‑of‑life" or "unmaintained." Use the phrasing "maintenance mode" and "forward path available."

### Definition of Done
- `@dnd-kit/core` status is accurately described as low-velocity but stable.
- A future evaluation point is noted.

---

## Task SPEC-006: Add Zod v4 Performance Warning

**Priority:** 🔴 High | **Est. Effort:** 20 min | **Depends On:** SPEC-001

### Related Files
- `01-Foundations.md` (Task FND‑002)
- All module files with Zod schema definitions (DASH‑000, CHAT‑002, PROJ‑000, CAL‑008, BUDG‑000, SET‑002)

### Subtasks
- [ ] **SPEC-006A**: In `01-Foundations.md` FND‑002, directly below the Zod installation command, add this warning block:
  > ⚠️ **Zod v4 Performance Note**  
  > Zod v4 schema creation is 8–17× slower than v3. **All schemas must be defined at module scope.** Never define a schema inside a component body, hook, or render function. Use `z.infer<typeof schema>` to derive TypeScript types instead of writing separate interfaces.
- [ ] **SPEC-006B**: Review each module spec and ensure that schema definitions are shown at module level, not inside component examples or hook bodies. If any examples show inline schema definitions, correct them and add a short comment explaining the move.

### Definition of Done
- The Zod v4 performance warning is prominent in the Foundation document.
- All schema definition examples in the spec are at module scope.

---

## Task SPEC-007: Correct iCal Export Implementation Guidance

**Priority:** 🟠 Medium | **Est. Effort:** 15 min | **Depends On:** SPEC-001

### Related Files
- `05-Calendar.md` (Task CAL‑006)

### Subtasks
- [ ] **SPEC-007A**: In `05-Calendar.md` CAL‑006B, replace the instruction *"generate RFC 5545‑compliant .ics strings manually"* with:
  > "Use the `ical-generator` library (`pnpm add ical-generator`) to produce `.ics` content. This library correctly handles CRLF line endings, 75‑byte folding, and text escaping as required by RFC 5545. Manual string generation is error‑prone and must not be used."
- [ ] **SPEC-007B**: Add `ical-generator` to the dependencies list for the Calendar module.

### Definition of Done
- The spec no longer advocates manual ICS string generation.
- A reliable library is specified.

---

## Task SPEC-008: Create Motion Enforcement Toolkit

**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** None

### Related Files
- `01-Foundations.md` (Cross-cutting C‑02, new Motion Tokens section)
- `09-Polish-Validation.md` (Task POL‑005)

### Subtasks
- [ ] **SPEC-008A**: Add a new section **“Motion Tokens”** to `01-Foundations.md` FND‑000, requiring the creation of `src/lib/motion.ts`:
  ```ts
  export const springAlive = { type: 'spring' as const, stiffness: 300, damping: 30 };
  export const fadeQuiet = { duration: 0.15 };
  ```
- [ ] **SPEC-008B**: Add a Cross-cutting rule: *“All `motion` components must use these shared tokens. Inline animation objects (e.g., `transition={{ duration: 0.2 }}`) are prohibited outside of `src/lib/motion.ts`.”*
- [ ] **SPEC-008C**: In `09-Polish-Validation.md` POL‑005, add a **Motion Compliance Checklist** item:
  - Every `motion.div` inside `AnimatePresence` has a `key`.
  - Every `layoutId` is wrapped in a `LayoutGroup`.
  - `useReducedMotion()` is checked at the top of every animated component.
  - No animation exceeds 150ms on a Quiet‑tier element.
  - No easing functions other than spring physics appear on Alive‑tier elements.
- [ ] **SPEC-008D**: Add a note recommending a directory convention (`src/components/motion/` for Alive/Quiet, `src/components/static/` for Static) as a visual signal for reviewers, but clarify that the primary enforcement is the code review checklist, not folder placement.

### Definition of Done
- Shared motion tokens are defined in the Foundation.
- A review checklist for animation quality exists in the Polish document.

---

## Task SPEC-009: Standardize `[TEST]` Subtasks Across All Modules

**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** None

### Related Files
- `06-News.md`
- `07-Budget.md`
- `03-Chat.md`
- `02-Dashboard.md`
- Any other module file with implementation subtasks

### Subtasks
- [ ] **SPEC-009A**: For every implementation subtask in `06-News.md` and `07-Budget.md`, add a corresponding `[TEST]` subtask immediately after. Follow the pattern used in `04-Projects.md` (e.g., `[TEST] PROJ‑004B…`).
- [ ] **SPEC-009B**: Review `03-Chat.md` and `02-Dashboard.md` for gaps. Where a subtask describes UI behavior or state change, ensure a test subtask is defined.
- [ ] **SPEC-009C**: Verify that the testing infrastructure described in `01-Foundations.md` FND‑004 aligns with the testing philosophy detailed in `09-Polish-Validation.md` POL‑C07 (tiered pyramid, phased execution).

### Definition of Done
- All module specification files contain paired `[TEST]` subtasks for every implementation subtask.
- The testing strategy is consistently documented.

---

## Task SPEC-010: Clarify Tiered Testing Execution

**Priority:** 🟠 Medium | **Est. Effort:** 30 min | **Depends On:** SPEC-009

### Related Files
- `01-Foundations.md` (Task FND‑004)
- `09-Polish-Validation.md` (POL‑002)

### Subtasks
- [ ] **SPEC-010A**: In `01-Foundations.md` FND‑004, add an explicit note: *“Testing is executed in phases: unit tests for pure logic and stores immediately; component and integration tests after the feature’s components are built; E2E and visual regression tests are reserved for the pre‑launch Polish phase (POL‑002). Do not gate feature completion on E2E tests.”*
- [ ] **SPEC-010B**: Ensure `09-Polish-Validation.md` POL‑002 describes the E2E, Lighthouse, and pa11y gates as pre‑launch activities, not per‑feature requirements.

### Definition of Done
- Testing guidance clearly separates phase‑appropriate gates.
- Developers know what is required when.

---

## Task SPEC-011: Final Language Softening Pass

**Priority:** 🟢 Low | **Est. Effort:** 45 min | **Depends On:** All above

### Related Files
- All specification documents

### Subtasks
- [ ] **SPEC-011A**: Scan all spec files for absolute language (“obsolete,” “never,” “only,” “best,” “must be replaced”) and replace with measured, evidence‑based phrasing:
  - “We prefer” instead of “must use”
  - “This library meets our current requirements” instead of “is the superior choice”
  - “Evaluate during Polish phase” instead of “migrate immediately”
- [ ] **SPEC-011B**: Add a short section at the end of each module spec titled **“Research Baseline”** that states: *“Technology choices in this document are based on research conducted April 2026. They should be re‑evaluated during the Polish phase (09‑Polish‑Validation.md) before final launch.”*

### Definition of Done
- No unfounded absolute claims remain.
- A re‑evaluation escape hatch is present in every module.

---

## 📊 Dependency Graph

```
SPEC-001 (Pin Versions)
 ├── SPEC-003 (Virtualization)
 ├── SPEC-004 (Calendar)
 ├── SPEC-006 (Zod Warning)
 └── SPEC-007 (iCal)
SPEC-002 (OKLCH Tokens)
SPEC-005 (dnd-kit Status)
SPEC-008 (Motion Toolkit)
SPEC-009 (Standardize Tests)
 └── SPEC-010 (Tiered Testing)

---

## Correction Completion Checklist

- [x] All `pnpm add` commands reflect the exact, verified versions.
- [x] OKLCH token equivalents are defined; typed token file is spec'd.
- [x] Virtualization strategy is unified on `@tanstack/react-virtual`.
- [ ] Calendar module is locked to `react-big-calendar ^1.19.4`.
- [ ] `@dnd-kit/core` status is accurately described.
- [ ] Zod v4 performance warning is prominent.
- [ ] iCal export uses `ical-generator`, not manual strings.
- [ ] Motion tokens exist (`src/lib/motion.ts`) and a review checklist is in place.
- [ ] Every implementation subtask is paired with a `[TEST]` subtask.
- [ ] Testing execution is described as phased, not monolithic.
- [ ] No speculative or overconfident language remains.

Once all tasks are marked Done, the specification suite is ready for the implementation phase.