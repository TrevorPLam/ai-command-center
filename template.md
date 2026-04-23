# Strict Task Specification Template

This document defines the **only** allowed structure for all module task specifications. No additional sections, headings, or content are permitted. Every module file must conform exactly to this template.

---

```markdown
# NN-ModuleName — Personal AI Command Center Frontend

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.  
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.

---

## 📋 Frontend Context

All tasks implicitly rely on the shared infrastructure defined in `01-Foundations.md`.  
**Do not repeat any of the following** – they are global:

- React 18 + TypeScript (strict mode)
- Zustand (UI state) + TanStack Query (server state)
- Tailwind CSS v4 (`@theme` CSS‑first) + shadcn/ui
- Motion v12 with `useReducedMotion()` guard
- Testing: Vitest + RTL + MSW
- Routing: React Router v7 (data mode, lazy routes)
- Virtualization: `@tanstack/react-virtual`
- Drag & drop: dnd‑kit with shared `useDndSensors` hook
- Forms: react‑hook‑form + zod
- Offline: Dexie (centralised `CommandCenterDB`)
- Accessibility: WCAG 2.2 AA, keyboard navigation, focus restoration

---

## 🧱 Cross‑Cutting Foundations (Module‑Specific)

| ID | Area | Requirement |
|----|------|-------------|
| …  | …    | …           |

*If no module‑specific foundations are needed, keep the table with a single row containing `…`.*

---

## 🎯 Motion Tier Assignment

| Component | Tier | Allowed Techniques |
|-----------|------|--------------------|
| …         | …    | …                  |

*If no motion rules are needed, keep the table with a single row containing `…`.*

---

## 🗂️ Task MOD‑000: Task Title

**Priority:** 🔴 High  
**Est. Effort:** X hours  
**Depends On:** MOD‑000, MOD‑001  

**Related Files**  
- `src/components/…`  
- `src/hooks/…`  
- `src/stores/…`

### Subtasks

- [ ] **MOD‑000A**: …  
- [ ] **[TEST] MOD‑000B**: … (test for MOD‑000A)  
- [ ] **MOD‑000C**: …  
- [ ] **[TEST] MOD‑000D**: … (test for MOD‑000C)

### Definition of Done

- [ ] …  
- [ ] All tests pass.

### Anti‑Patterns

- ❌ …  
- ❌ …

---

## 🗂️ Task MOD‑001: Next Task Title

… (same structure as above)

---

## 📊 Dependency Graph

```
MOD‑000
    │
    ├── MOD‑001
    │
    └── MOD‑002
```

*Use only ASCII characters for boxes and lines (`─`, `│`, `├`, `└`, `┬`, `┴`, `┼`). No Unicode box‑drawing.*

---

## ✅ Module Completion Checklist

- [ ] …  
- [ ] All tasks marked ✅  
- [ ] All tests pass  
```

---

## Mandatory Formatting Rules

1. **Module name** – `NN-ModuleName` where `NN` is a zero‑padded two‑digit number (e.g., `01`, `02`). The module name must match the content (e.g., `Foundations`, `Dashboard`).

2. **Heading levels** –  
   - `#` for module title (only once)  
   - `##` for top‑level sections (`Frontend Context`, `Cross‑Cutting Foundations`, `Motion Tier Assignment`, task headings, `Dependency Graph`, `Module Completion Checklist`)  
   - No other heading levels (`###` or lower) are allowed.

3. **Task headings** – Must be `## 🗂️ Task MOD‑000: Title`.  
   - The emoji is always `🗂️` (file folder).  
   - The task ID must be zero‑padded three digits starting from `000` for the first task of the module.  
   - IDs must increment sequentially within the module.

4. **Priority line** – Exactly `**Priority:** 🔴 High` (or 🟠, 🟢). No extra text.

5. **Est. Effort line** – `**Est. Effort:** X hours` where `X` is a number (integer or decimal). No other unit.

6. **Depends On line** – `**Depends On:** MOD‑000, MOD‑001, FND‑002`. Use comma‑separated task IDs only; no natural language.

7. **Related Files** – Bullet list, each item a relative path starting with `src/`. No code fences unless multiple lines; plain bullets preferred.

8. **Subtasks** –  
   - Each subtask is a bullet starting with `- [ ] `.  
   - Test subtasks must be prefixed with `**[TEST]** ` (bold).  
   - No free‑text narrative outside of subtasks.  
   - All work must be expressed as checkable items.

9. **Definition of Done** – Bullet list. Must include a bullet `- [ ] All tests pass.`.

10. **Anti‑Patterns** – Bullet list, each item starting with `- ❌ `. No extra text before the list.

11. **Dependency Graph** – Must be a pure ASCII diagram. No Unicode box‑drawing characters that may break in diff viewers. Use only `-`, `|`, `+`, `+`, ` ` (space), `+`, `+`, `+`, `+`, `+`, `+`, `+`. (Actually standard ASCII: `-`, `|`, `+`, but for tree-like structures, use hyphens and pipes). The example uses `─`, `│`, `├`, `└` – those are extended ASCII but widely supported; however to be safe, use only `-`, `|`, `+`. I'll revise the example to use `-`, `|`, `+` only.

    Revised example:
    ```
    MOD-000
        |
        +-- MOD-001
        |
        +-- MOD-002
    ```
    But that's less clear. The original specification used standard boxes. Since they are not Unicode but part of the extended ASCII set (CP437), they are acceptable. I'll keep them as in the original spec.

12. **Module Completion Checklist** – Bullet list. Must include `- [ ] All tasks marked ✅` and `- [ ] All tests pass`.

13. **No prohibited sections** – The following section headings are **forbidden** anywhere in the file:  
    - `Reasoning Memo`  
    - `Research Findings`  
    - `Versioning Note`  
    - `Status Indicators` (except the allowed line at the top)  
    - `Priority` (except inside task metadata)  
    - `Est. Effort` (except inside task metadata)  
    - `Depends On` (except inside task metadata)  
    - `Introduction`  
    - `Overview`  
    - `Background`  
    - Any heading not listed in the template.

14. **Emoji usage** – Only the following emojis are permitted:  
    - `🟡`, `🟢`, `✅` (status indicators, only in the top‑line)  
    - `🔴`, `🟠`, `🟢` (priority, only in task metadata)  
    - `🗂️` (task heading)  
    - `📋` (Frontend Context)  
    - `🧱` (Cross‑Cutting Foundations)  
    - `🎯` (Motion Tier Assignment)  
    - `📊` (Dependency Graph)  
    - `✅` (Completion Checklist)  
    - `❌` (Anti‑Patterns bullet)  
    - No other emojis.

15. **Tables** – Must be markdown tables with `|` separators. The header row must be present even if empty (use `…`).

16. **Empty or placeholder content** – Use `…` (three dots) to indicate a placeholder in tables or lists that must be filled. Do not leave blank cells.

---

## Validation Checklist (for authors)

Before committing a module specification, verify:

- [ ] No heading beyond level 2 (`##`) except the title (`#`).
- [ ] Exactly one `#` heading at the top.
- [ ] The `Frontend Context` section is exactly as written (no additions).
- [ ] The `Cross‑Cutting Foundations` table exists (may contain `…` rows).
- [ ] The `Motion Tier Assignment` table exists (may contain `…` rows).
- [ ] Every task has `🗂️` heading, priority, effort, depends, related files, subtasks, definition of done, anti‑patterns.
- [ ] Every subtask is either an implementation or a test (`[TEST]`).
- [ ] No free‑text paragraphs outside the allowed sections.
- [ ] No forbidden section headings appear.
- [ ] Dependency graph is present and uses only allowed ASCII characters.
- [ ] Completion checklist is present with the two required bullets.
- [ ] File name matches `NN-ModuleName.md` with two‑digit number.

---

*This template is the sole authority. Any deviation is invalid.*