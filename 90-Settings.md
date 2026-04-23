# 90‑Settings — Personal AI Command Center Frontend (Enhanced v3)
> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.  
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.  
> **Versioning Note**: This document supersedes `08-Settings (Enhanced v2)`.

---

## 📋 Frontend Context (Module‑Wide Assumptions)

> All tasks in this module implicitly rely on the shared infrastructure defined in `00‑Foundations.md`.
> **Do not repeat these in every task** – they are global.

- **Framework**: React 18 + TypeScript (strict mode)
- **State**: Zustand (UI) + TanStack Query (server state)
- **Styling**: Tailwind CSS v4 (CSS‑first `@theme`), shadcn/ui components
- **Animation**: Motion v12 (`framer-motion`) with `useReducedMotion()` guard
- **Testing**: Vitest + RTL + MSW (unit / component / integration)
- **Routing**: React Router v7 (data mode, lazy routes)
- **Virtualization**: `@tanstack/react-virtual`
- **Drag & Drop**: dnd‑kit with shared `useDndSensors` hook
- **Forms**: react‑hook‑form + zod
- **Offline**: Dexie (centralised `CommandCenterDB`)
- **Accessibility**: WCAG 2.2 AA, keyboard navigation, focus restoration

## 📐 Reasoning Memo: Structural & Quality Decisions
- Keep **8 parent tasks** to avoid fragmentation and maintain a clear mental model, but tighten scopes so each is focused, testable, and maps cleanly to UI + state boundaries. [minimum-code](https://www.minimum-code.com/blog/ui-ux-best-practises-web-app-design-2026)
- Push “perfect developer practices” into **cross-cutting requirements** and **per-task subtasks**, instead of creating separate parent tasks for testing, validation, or accessibility. [dev](https://dev.to/marufrahmanlive/react-hook-form-with-zod-complete-guide-for-2026-1em1)
- Integrate **testing, performance, accessibility, and security checks** as explicit subtasks within each parent task, not as separate tasks, to ensure they are never “optional”. [uxpilot](https://uxpilot.ai/blogs/ux-best-practices)
- Add missing concerns discovered via research:
  - **Settings audit breadcrumbs**: basic logging of key changes in the frontend store (for debugging and user trust). [uxpilot](https://uxpilot.ai/blogs/ux-best-practices)
  - **Performance & UX safeguards**: form-level RHF + Zod best practices, avoiding unnecessary re-renders, and designing for consistent feedback. [oneuptime](https://oneuptime.com/blog/post/2026-01-15-type-safe-forms-react-hook-form-zod/view)
  - **Security UX** for API keys and Danger Zone: stricter confirmation flows, time‑limited reveals, clear affordances around destructive actions. [minimum-code](https://www.minimum-code.com/blog/ui-ux-best-practises-web-app-design-2026)
### New Structure: 8 Parent Tasks (Refined, Same Count)
| Original Enhanced v2 | Enhanced v3 | Change |
|----------------------|------------|--------|
| SET‑000: Settings State & Persistence | **SET‑000: Settings State, Persistence & Audit** | Add basic change logging and more explicit migration strategy. |
| SET‑001: Settings Page Layout | **SET‑001: Settings Shell, Layout & Navigation** | Explicitly own accessibility, keyboard behavior, and performance constraints. |
| SET‑002: General, Appearance, Notifications, Analytics | **SET‑002: Core Settings Forms (General, Appearance, Notifications, Analytics)** | Tighten RHF + Zod patterns, add optimistic UX and error boundaries. |
| SET‑003: API Keys Management | **SET‑003: API Keys & Security UX** | Clarify security patterns (reveal timeout, copy flows, warnings). |
| SET‑004: Memory & Integrations | **SET‑004: Memory, Integrations & Sync States** | Make sync states, failure states, and optimistic updates explicit. |
| SET‑005: Export & Import | **SET‑005: Export, Import & Data Portability UX** | Clarify long‑running operation UX and failure/retry semantics. |
| SET‑006: Danger Zone & Privacy Compliance | **SET‑006: Danger Zone, Privacy, and Account Lifecycle** | Tighten flows, add “undo” windows where appropriate. |
| SET‑007: Team & Workspace Settings | **SET‑007: Team & Workspace Settings (Optional)** | Mostly unchanged; beef up role semantics and invitations. |
## 🔬 2026 Research Anchors — Settings Module
| Finding | Source | Action Required |
|---------|--------|-----------------|
| Use Zod schemas as single source of truth for validation and types; derive TS types from schemas. | dev.to RHF+Zod guide 2026 [dev](https://dev.to/marufrahmanlive/react-hook-form-with-zod-complete-guide-for-2026-1em1) | All settings data models come from Zod schemas, not separate TS interfaces. |
| Centralize form configuration with a single `useForm` instance when multiple tabs write to one logical settings object to avoid conflicting validation and state drift. | Wasp & RHF multi-step patterns [wasp](https://wasp.sh/blog/2025/01/22/advanced-react-hook-form-zod-shadcn) | Prefer a single settings form context, or at least shared schemas and consistent error handling. |
| Show validation errors as close to the input as possible, with clear messages and accessible error text. | RHF + Zod articles [dev](https://dev.to/marufrahmanlive/react-hook-form-with-zod-complete-guide-for-2026-1em1) | Use shadcn `<FormMessage>` under each field; never hide errors in toast only. |
| Use Zustand `partialize` carefully; only persist stable, user-controlled preferences; prepare migrations for shape changes. | Zustand docs + discussion [zustand.docs.pmnd](https://zustand.docs.pmnd.rs/reference/integrations/persisting-store-data) | Keep `persist` slice minimal, add `migrate` to remove deprecated keys safely. |
| Accessibility and consistency are core UX best practices in 2026; every interactive element must be keyboard accessible and have an accessible name. | UX best-practices 2026 [minimum-code](https://www.minimum-code.com/blog/ui-ux-best-practises-web-app-design-2026) | Sidebar and forms must support keyboard nav, ARIA attributes, and proper labels. |
| Personalization (themes, language, notification preferences) is expected; users must be able to quickly adjust settings, see immediate feedback, and understand the impact. | UI/UX 2026 personalization guidance [minimum-code](https://www.minimum-code.com/blog/ui-ux-best-practises-web-app-design-2026) | Ensure settings immediately reflect changes in the UI (especially theme and motion). |

---

## 🧱 Cross‑Cutting Foundations for Settings
| ID | Area | Requirement |
|----|------|-------------|
| **SET‑C01** | State Management | Single `settingsSlice` with nested objects per section; `persist` middleware with strict `partialize` and `migrate`. |
| **SET‑C02** | Form Handling | All settings forms use `react-hook-form` + `zod` + `@hookform/resolvers`; schemas are the single source of truth. |
| **SET‑C03** | Accessibility | Every form field has an accessible name; errors exposed via `aria-describedby` and `<FormMessage>`; dialogs include `<DialogTitle>`. |
| **SET‑C04** | Feedback | All saves show subtle toast + inline confirmation (disabled Save → “Saved” state); errors show near fields plus toast if global. |
| **SET‑C05** | Persistence | Settings persist to `localStorage` via Zustand `persist`; exports/imports remain mock-only in this prototype. |
| **SET‑C06** | Privacy & Compliance | Data export and account deletion simulate GDPR/CCPA timelines and inform the user clearly. |
| **SET‑C07** | Theme Application | Theme changes apply immediately via `ThemeProvider`; appearance settings read from Zustand and rehydrate on load. |
| **SET‑C08** | Motion Preference | Motion toggle persists and overrides global motion preferences; honors OS reduced-motion when enabled. |
| **SET‑C09** | Keyboard & Focus | Sidebar and all actions are keyboard navigable; focus is trapped correctly in modals; visible focus rings for keyboard users. |
| **SET‑C10** | Destructive Actions | All destructive actions use `variant="destructive"`, require confirmation, and avoid accidental triggers. |
| **SET‑C11** | Testing | Each parent task includes tests for state updates, accessibility basics, and critical flows; settings domain has 90%+ coverage. |
| **SET‑C12** | Observability | Basic logging hooks capture key settings changes (e.g., theme, notification preferences) to help debug behavior in development. |
## 🎯 Motion Tier Assignment for Settings
| Component | Tier | Technique |
|-----------|------|--------------------|
| Settings sidebar active indicator | **Quiet** | Background color fade (≤150ms). |
| Section content transition | **Quiet** | Opacity fade (≤150ms) with `AnimatePresence`. |
| Toast notifications | **Quiet** | Slide-in from bottom (≤150ms). |
| Accordion (Memory/Integrations) | **Quiet** | Smooth height transition via layout prop. |
| Export progress bar | **Quiet** | Width transition (≤150ms). |
| Danger zone dialogs | **Static** | Instant open/close (no animation). |
| All form inputs | **Static** | No animation (instant updates). |

## 🗂️ Task SET‑000: Settings State, Persistence & Audit (Zustand Slice)
**Priority:** 🔴 High
**Est. Effort:** 1 hour
**Depends On:** FND‑005 (Zustand Slices)
### Related Files
- `src/schemas/settingsSchema.ts`  
- `src/stores/slices/settingsSlice.ts`  
- `src/utils/settingsAudit.ts`
### Subtasks
**Schemas & Types:**
- [ ] **SET‑000A**: Create/extend `src/schemas/settingsSchema.ts` with Zod schemas for each section; derive TS types via `z.infer` instead of hand-written interfaces. [dev](https://dev.to/marufrahmanlive/react-hook-form-with-zod-complete-guide-for-2026-1em1)
- [ ] **SET‑000B**: Add schemas for `memorySettingsSchema`, `integrationSchema`, `apiKeySchema`, and `teamSettingsSchema` to centralize validation.

**Slice Definition & Persistence:**
- [ ] **SET‑000C**: Implement `settingsSlice` interface with nested objects and CRUD/update methods for each section (general, appearance, notifications, analytics, memory, integrations, apiKeys, team).  
- [ ] **SET‑000D**: Apply `persist` middleware with `partialize`:
  - Persist only `appearance`, `notifications`, `general.theme`, `general.language`, and other safe preferences.
  - Do not persist sensitive fields (email, API keys, analytics tracking) or volatile data.
  - Use `version: 1` with a `migrate` function that cleans up deprecated keys and maps old shapes safely. [github](https://github.com/pmndrs/zustand/discussions/1273)
- [ ] **SET‑000E**: Create atomic selector hooks for each section to minimize re-renders (`useGeneralSettings`, `useAppearanceSettings`, etc.).  

**Audit & Observability:**
- [ ] **SET‑000F**: Implement a small `settingsAudit` utility that logs key changes (e.g., theme, motion, notification frequency) in development mode only, to help debug settings-related issues.  

**Testing:**
- [ ] **SET‑000G**: Write unit tests for:
  - All update methods and expected state transitions.
  - Persistence behavior and `partialize` exclusions.
  - Migration logic when version changes.
### Definition of Done
- `settingsSlice` exposes strongly-typed, nested settings objects and atomic selectors.  
- `persist` only stores safe preference fields; migrations are in place.  
- Core settings changes are logged in dev builds for debugging.  
- Tests pass and cover updates, persistence, and migration paths.
### Anti‑Patterns
- ❌ Multiple stores for settings instead of a single slice.  
- ❌ Persisting the entire slice without `partialize`.  
- ❌ Duplicating validation logic in TypeScript and Zod instead of deriving from schemas. [dev](https://dev.to/marufrahmanlive/react-hook-form-with-zod-complete-guide-for-2026-1em1)
## 🔧 Task SET‑001: Settings Shell, Layout & Navigation
**Priority:** 🔴 High
**Est. Effort:** 1 hour
**Depends On:** SET‑000, FND‑007 (Router)
### Related Files
- `src/pages/SettingsPage.tsx`  
- `src/components/settings/SettingsSidebar.tsx`  
- `src/router/routes.ts`
### Subtasks
- [ ] **SET‑001A**: Create `SettingsPage` with a responsive two-column layout: internal left sidebar (~200px) + flexible content area, with sensible behavior on small screens (sidebar collapsible or stacked).  
- [ ] **SET‑001B**: Implement `SettingsSidebar` with items: General, Appearance, Notifications, Analytics, Memory, Integrations, API Keys, Export/Import, Danger Zone, Team (optional).  
- [ ] **SET‑001C**: Style active item with an accessible indicator (color + left border) and ensure sufficient contrast. [minimum-code](https://www.minimum-code.com/blog/ui-ux-best-practises-web-app-design-2026)
- [ ] **SET‑001D**: Add keyboard navigation: arrow keys move between items, Enter/Space activates selection, focus ring is visible for keyboard users.  
- [ ] **SET‑001E**: Configure `/settings` route in `routes.ts`, ensuring `settingsSlice` is hydrated prior to rendering the page.  
- [ ] **SET‑001F**: Use `useActiveSection()` hook to determine which section component to render; wrap content area in `<AnimatePresence>` for fade transitions.  

**Testing:**
- [ ] **SET‑001G**: Tests for:
  - Route rendering.
  - Sidebar navigation (mouse + keyboard).
  - Section switching and ARIA relationships between sidebar and content.
### Definition of Done
- `/settings` renders a responsive two-column layout with accessible navigation.  
- Section changes are smooth but subtle.  
- Keyboard and screen reader navigation is reliable.
## ⚙️ Task SET‑002: Core Settings Forms (General, Appearance, Notifications, Analytics)
**Priority:** 🔴 High
**Est. Effort:** 4 hours
**Depends On:** SET‑001
### Related Files
- `src/components/settings/GeneralSettings.tsx`  
- `src/components/settings/AppearanceSettings.tsx`  
- `src/components/settings/NotificationSettings.tsx`  
- `src/components/settings/AnalyticsSettings.tsx`
### Subtasks
**Setup & Shared Form Infrastructure:**
- [ ] **SET‑002A**: Install and configure `react-hook-form`, `zod`, and `@hookform/resolvers` if not already installed. [dev](https://dev.to/marufrahmanlive/react-hook-form-with-zod-complete-guide-for-2026-1em1)
- [ ] **SET‑002B**: Implement a shared `SettingsFormProvider` that wires RHF with Zod schemas per section, to keep form configuration consistent.  

**General Settings:**
- [ ] **SET‑002C**: Build `GeneralSettings` form:
  - Fields: display name (editable), email (read-only field), timezone select, language select, theme (if using general theme field).
  - Use `zodResolver(generalSettingsSchema)`; show inline field errors with `<FormMessage>`.  
  - Save button updates `general` slice and triggers toast + inline “Saved” indicator.  

**Appearance Settings:**
- [ ] **SET‑002D**: Build `AppearanceSettings` form:
  - Theme preset: System / Dark / Light; wired to `ThemeProvider` for immediate application.  
  - Accent color presets; change visible immediately in UI tokens.  
  - Font size slider with live preview of text size.  
  - Motion toggle that writes to both settings and a global motion context, respecting OS preference when enabled.  

**Notification Settings:**
- [ ] **SET‑002E**: Build `NotificationSettings` form:
  - Toggles for email, push, in-app.  
  - Frequency select (Real-time, Hourly, Daily, Never).  
  - Quiet hours: enable toggle + start/end time; validate ranges (end after start) via Zod refinement. [contentful](https://www.contentful.com/blog/react-hook-form-validation-zod/)

**Analytics Settings:**
- [ ] **SET‑002F**: Build `AnalyticsSettings` form:
  - Tracking toggle (with brief explanatory helper text).  
  - Data retention dropdown (30d, 90d, 180d, 1y).  
  - “Download my data” entry point that hooks into SET‑005 export flow.  

**Shared Behavior:**
- [ ] **SET‑002G**: Implement debounced auto-save (e.g., 1–2s after last change) OR explicit Save button per section; avoid double submitted states.  
- [ ] **SET‑002H**: Show subtle toast on successful save and on error; never rely solely on toast for validation errors. [uxpilot](https://uxpilot.ai/blogs/ux-best-practices)
- [ ] **SET‑002I**: Ensure all fields use `<FormLabel>` and associate descriptions and errors via `aria-describedby`.  

**Testing:**
- [ ] **SET‑002J**: Tests for:
  - Validation behavior and error messages.
  - Correct updates to `settingsSlice`.
  - Theme and motion being applied consistently.
### Definition of Done
- All four core settings sections render with type-safe forms and robust validation.  
- Updates persist to the store and `localStorage` as intended; theme/motion changes are immediate.  
- Users receive clear feedback for success and failure.
## 🔑 Task SET‑003: API Keys & Security UX
**Priority:** 🟠 Medium
**Est. Effort:** 1.5 hours
**Depends On:** SET‑001, SET‑000
### Related Files
- `src/components/settings/ApiKeysSettings.tsx`  
- `src/schemas/apiKeySchema.ts`
### Subtasks
- [ ] **SET‑003A**: Implement `apiKeySchema` with provider, key, label, and createdAt fields.  
- [ ] **SET‑003B**: Build `ApiKeysSettings` listing common providers (OpenAI, Anthropic, Google AI, Groq, etc.) with masked keys, status badges, and actions: Reveal (time-limited), Copy, Regenerate, Delete.  
- [ ] **SET‑003C**: Add “Add API Key” modal:
  - Provider dropdown, key input (masked), optional label.
  - Validation through RHF + Zod (non-empty, length constraints, basic pattern without storing real rules).  
- [ ] **SET‑003D**: Implement security-positive UX:
  - Keys are masked by default; reveal auto-hides after a short timeout.
  - “Copy” shows a small non-intrusive confirmation message.
  - Regenerate/Delete require confirmation dialogs.  

**Testing:**
- [ ] **SET‑003E**: Tests for:
  - Create/Update/Delete flows.
  - Masking and reveal timeout behavior.
  - Slice updates and error handling.
### Definition of Done
- Users can add, inspect, and manage API keys with secure defaults.  
- Masking, reveal, and destructive operations feel safe and predictable.

## 🗂️ Task SET‑004: Memory, Integrations & Sync States
**Priority:** 🟠 Medium
**Est. Effort:** 2.5 hours
**Depends On:** SET‑001, SET‑000
### Related Files
- `src/components/settings/MemorySettings.tsx`  
- `src/components/settings/IntegrationsSettings.tsx`
### Subtasks
**Memory Settings:**
- [ ] **SET‑004A**: Implement `MemorySettings`:
  - Toggle memory on/off, retention period slider (7/30/90 days), auto-summarize toggle.  
  - “Clear memory” uses `AlertDialog`, requires confirmation, shows progress toast, then clears mock memory from store.  

**Integrations Settings:**
- [ ] **SET‑004B**: Build `IntegrationsSettings`:
  - List integrations (GitHub, Notion, Google Calendar, Slack, etc.) with status badge and last sync time.  
  - “Connect” drives a mock OAuth modal; “Disconnect” uses confirmation dialog.  
  - Show sync states: idle, syncing, failed, with a retry control.  

**Testing:**
- [ ] **SET‑004C**: Tests for:
  - Toggle behavior and memory clearing.
  - Integration connect/disconnect flows and optimistic UI, including failure and retry states.
### Definition of Done
- Memory controls are clear, safe, and responsive.  
- Integrations show realistic connection states and can be connected/disconnected smoothly.
## 📤 Task SET‑005: Export, Import & Data Portability UX
**Priority:** 🟢 Low
**Est. Effort:** 1.5 hours
**Depends On:** SET‑001, SET‑000
### Related Files
- `src/components/settings/ExportImportPage.tsx`
### Subtasks
- [ ] **SET‑005A**: Implement Export section:
  - “Export all data” button, format dropdown (JSON/CSV).  
  - Simulated progress via shadcn `Progress`, then show Download button for mock file.  
  - Display short explanation of what is included and expected timelines (ties to GDPR/CCPA text).  

- [ ] **SET‑005B**: Implement Import section:
  - File dropzone with format detection, small preview (mock data).  
  - Validate file type and basic shape via Zod; show inline errors for invalid files.  
  - “Import” action runs simulated progress and either success or error.  

**Testing:**
- [ ] **SET‑005C**: Tests for:
  - Export flow: progress, completion, download button.
  - Import flow: validation, preview, success/error paths.
### Definition of Done
- Users can start an export, see progress, and “download” a mock archive.  
- Users can attempt an import, see validation behavior, and get clear feedback.
## ⚠️ Task SET‑006: Danger Zone, Privacy & Account Lifecycle
**Priority:** 🔴 High
**Est. Effort:** 2 hours
**Depends On:** SET‑001, SET‑000
### Related Files
- `src/components/settings/DangerZone.tsx`
### Subtasks
- [ ] **SET‑006A**: Implement `DangerZone` section:
  - Red-bordered card containing destructive actions: Delete all data, Reset to factory settings, Delete account.  
  - “Delete all data” uses `AlertDialog` with typed confirmation (e.g., “DELETE”); progress toast after confirmation.  
  - “Reset to factory settings” confirms then resets settings slice to defaults plus shows summary of what changed.  
- [ ] **SET‑006B**: “Delete account” flow:
  - Stepwise modal explaining impact, GDPR/CCPA timelines, and what will happen when. [minimum-code](https://www.minimum-code.com/blog/ui-ux-best-practises-web-app-design-2026)
  - Reason dropdown (optional), confirmation email field (mock), final confirmation with destructive button.  
  - Show mock “request received” message and timeline reminder.  
- [ ] **SET‑006C**: Add “Request My Data” button that navigates to or triggers the same flow as SET‑005 Export.  

**Testing:**
- [ ] **SET‑006D**: Tests for:
  - All destructive flows, including guardrails (can’t proceed without confirmation).
  - State reset behavior and visible UI updates.
### Definition of Done
- All destructive actions are clearly marked, confirmed, and safe from accidental activation.  
- Users understand what will happen and when, especially for account deletion.
## 👥 Task SET‑007: Team & Workspace Settings (Optional)
**Priority:** 🟢 Low
**Est. Effort:** 1.5 hours
**Depends On:** SET‑001, SET‑000
### Related Files
- `src/components/settings/TeamSettings.tsx`
### Subtasks
- [ ] **SET‑007A**: Build `TeamSettings`:
  - Workspace name (editable).  
  - Team member list: name, email, role (Admin/Member), status (Active/Pending), join date (optional).  
  - “Invite member” modal with email + role; uses RHF + Zod for basic validation.  
- [ ] **SET‑007B**: Role dropdown with optimistic changes and visual confirmation; “Remove” action guarded via confirmation dialog.  

**Testing:**
- [ ] **SET‑007C**: Tests for:
  - Invite flow, role changes, removal.
  - Store updates and UI feedback.
### Definition of Done
- Workspace settings feel coherent and simple to manage.  
- Invitations and role changes are reliable and clearly communicated.
## 📊 Dependency Graph
```
SET‑000 (State, Persistence & Audit)
     │
SET‑001 (Settings Shell, Layout & Navigation)
     │
     ├── SET‑002 (Core Settings Forms)
     │
     ├── SET‑003 (API Keys & Security UX)
     │
     ├── SET‑004 (Memory & Integrations)
     │
     ├── SET‑005 (Export, Import & Data Portability)
     │
     ├── SET‑006 (Danger Zone & Privacy)
     │
     └── SET‑007 (Team & Workspace — optional)
```
## 🏁 Settings Module Completion Checklist
**State, Persistence & Audit:**
- [ ] `settingsSlice` with nested objects, `partialize`, and `migrate` in place.  
- [ ] `localStorage` persistence works; only safe fields stored.  
- [ ] Atomic selectors prevent unnecessary re-renders.  
- [ ] Basic change logging wired for dev builds.

**Core Settings (SET‑002):**
- [ ] General: display name, email (read-only), timezone, language, theme (if applicable).  
- [ ] Appearance: theme preset, accent color, font size, motion toggle with live feedback.  
- [ ] Notifications: toggles, frequency, quiet hours with validated ranges.  
- [ ] Analytics: tracking toggle, retention period, “Download my data” entry point.

**Other Sections:**
- [ ] API Keys: add, reveal (time-limited), copy, regenerate, delete with confirmations.  
- [ ] Memory: retention slider, auto-summarize, “Clear memory” with confirmation.  
- [ ] Integrations: GitHub, Notion, Google Calendar, Slack, etc., with connect/disconnect and sync states.  
- [ ] Export/Import: progress indicators, mock download, import validation.  
- [ ] Danger Zone: data deletion, reset, account deletion with compliance workflow and clear copy.  
- [ ] Team Workspace (optional): workspace name, members, roles, invites.

**Accessibility, UX & Feedback:**
- [ ] All forms use `<FormLabel>`, accessible descriptions, and inline `<FormMessage>` for errors.  
- [ ] All destructive actions require confirmation via `AlertDialog` with clear labeling.  
- [ ] All settings actions provide subtle toasts and/or inline success indicators.  
- [ ] Keyboard navigation in sidebar and modals works; focus management is correct.  
- [ ] Theme and motion changes apply immediately and persist.

**Testing & Quality:**
- [ ] Each SET task has tests covering core flows and edge cases.  
- [ ] `pnpm test` passes for the entire settings domain with high coverage.  
- [ ] Linting and type-checking pass with no settings-related errors.  

Would you like to go one level deeper and generate concrete file stubs (e.g., the exact `SettingsFormProvider` and `settingsAudit` utilities) so your devs can start from copy‑pasteable scaffolding rather than just task text?  