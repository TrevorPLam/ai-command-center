---
name: settings-components
description: Guides the creation of settings components including SettingsPage with internal sidebar navigation, GeneralSettings, AppearanceSettings, NotificationSettings, AnalyticsSettings, MemorySettings, IntegrationsSettings, ExportImportPage, and DangerZone
---

## Settings Components

### SettingsPage.tsx
Settings page with internal sidebar navigation (separate from global left sidebar).

**Layout:**
- Left sidebar (200px): internal settings navigation
- Right content area: active settings section

**Settings internal nav (left column):**
- General
- Appearance
- Notifications
- Analytics ← subpage
- Memory ← subpage
- Integrations ← subpage
- Export / Import
- Danger Zone

### GeneralSettings.tsx
Form controls:
- Display name input (text)
- Language selector (dropdown)
- Timezone selector (dropdown with search)
- Date format selector (MM/DD/YYYY, DD/MM/YYYY, etc.)
- Week starts on (Sunday / Monday)
- Default landing page dropdown
- Save button (blue)

### AppearanceSettings.tsx
Form controls:
- Theme: Dark (default, locked) / System
- Accent color picker (electric blue default, 6 options with color swatches)
- Font size: Small / Medium / Large (radio buttons)
- Sidebar: Expanded / Collapsed default (toggle)
- Motion: Full / Reduced (respects prefers-reduced-motion)
- Density: Compact / Comfortable / Spacious (radio buttons)
- Preview section showing current settings
- Save button (blue)

### NotificationSettings.tsx
Form controls:
- Agent decision alerts: toggle + sound toggle
- Budget alerts: over-budget category toggle, threshold input (percentage)
- News digest: frequency selector (Real-time / Hourly / Daily), delivery time picker
- Calendar reminders: default reminder time selector (15min / 1hr / 1 day)
- In-app notification panel toggle
- Push notifications toggle (mocked)
- Save button (blue)

### AnalyticsSettings.tsx (`/settings/analytics`)
Form controls:
- Cost tracking: toggle enable/disable
- Budget cap: monthly token budget input + warning threshold % (slider)
- Model breakdown: toggle show/hide per-model cost breakdown
- Data retention: dropdown (7 days / 30 days / 90 days / Forever)
- Export analytics data: Download JSON button (mocked, shows toast)
- Save button (blue)

### MemorySettings.tsx (`/settings/memory`)
Form controls:
- Memory system: toggle enable/disable
- Working memory window: slider (4k / 8k / 16k / 32k tokens)
- Episodic memory retention: dropdown (7 / 30 / 90 / 365 days)
- Semantic memory: toggle + re-index button
- Knowledge base stats: total entries count, total size, last indexed
- Clear all memory button (opens confirmation modal)
- Export memory: Download JSON button (mocked, shows toast)
- Save button (blue)

### IntegrationsSettings.tsx (`/settings/integrations`)
Grid of integration cards (MCPServerCard) organized by category:

**AI Providers:**
- OpenAI, Anthropic, Google Gemini, Ollama (local), Groq
- Each card: logo placeholder, name, status badge (Connected / Not Connected), model list if connected, Configure button (opens modal with API key input, masked)

**MCP Servers:**
- GitHub, Linear, Notion, Slack, Jira, Filesystem, Browser
- Each MCPServerCard: icon, name, description, status toggle (enabled/disabled), last connected timestamp, Configure button (opens modal with server URL + auth fields)

**Calendar:**
- Google Calendar, Apple Calendar, Outlook
- Connection status + Connect button

**News Sources:**
- RSS feeds, custom source URLs
- List with add/remove

"Test Connection" button on each card shows a toast (Connected successfully / Failed — mocked).

### MCPServerCard.tsx
- Icon/logo placeholder
- Name
- Description (one line)
- Status badge (Connected / Not Connected)
- Status toggle (enabled/disabled)
- Last connected timestamp
- Configure button
- Test Connection button
- Hover: subtle lift

### ExportImportPage.tsx (`/settings/export`)
Two sections:

**Export:**
- Export all data: Download .aicc archive (JSON bundle) — mocked download
- Export by section: Projects / Budget / News Preferences / Settings (individual download buttons)
- Last export timestamp

**Import:**
- Drag-and-drop zone or file picker
- Shows preview of what will be imported
- Confirm import button
- Warning about overwriting data

### DangerZone.tsx
Red-bordered card with destructive actions:
- Reset all settings (confirmation modal)
- Clear all budget data (confirmation modal)
- Clear all projects (confirmation modal)
- Clear all chat history (confirmation modal)
- Clear everything (nuclear option, double-confirmation modal)

All confirmation modals require typing "CONFIRM" to enable the destructive button.

## Data Requirements

All settings components must use realistic mock data from `src/lib/mockData/settings.ts` with:
- Current settings values
- Integration connection states
- Memory system stats
- Analytics data

## State Management

- Use TanStack Query for fetching settings and integration states
- Use Zustand for UI-only state (active section, drawer open/close, modal states)
- Persist settings to localStorage or mock API

## Accessibility Requirements (WCAG 2.2 AA)

- SettingsPage: proper ARIA landmarks (main, nav), semantic HTML, keyboard navigation for sidebar
- All forms: proper labels, error announcements, aria-invalid for invalid fields
- DangerZone: proper warnings, aria-live for confirmations, role="alert"
- MCPServerCard: proper button roles, focus states, aria-label for actions
- All interactive elements: 4.5:1 color contrast ratio minimum
- Focus management: visible focus indicators, logical tab order
- Dynamic content: aria-live regions for settings updates
- Screen readers: announce setting changes, connection status
- Keyboard navigation: all interactive elements reachable via keyboard, escape to close modals
- Form validation: inline error messages with aria-describedby

## Visual Identity

- Glass panels: backdrop-blur-md bg-white/5 border border-white/10 rounded-xl
- Electric blue accent: #0066ff → #00aaff for CTAs and active states
- DangerZone: red border (#ef4444), red text for destructive actions
- Status colors: Connected (green), Not Connected (gray)
- 150ms ease-out transitions on all interactive elements
- Skeleton loaders on all data fetch states

**Tailwind v4 & shadcn/ui Notes (2026):**
- shadcn/ui v2+ uses Tailwind v4 with @theme directive
- Components have data-slot attributes for styling
- forwardRef removed from components (React 19 pattern)
- HSL colors converted to OKLCH in v4
- Default style deprecated, new projects use new-york style

## Form Handling (2026)

- Use React Hook Form v7 for all settings forms
- Zod v3+ schema validation with zodResolver
- Show validation errors inline with aria-describedby
- Disable save button when form is invalid (use formState.isValid)
- Show success toast on save
- Auto-save or manual save based on section
- Use useFormStatus for form submission state (React 19)
- Use SubmitEvent instead of FormEvent where applicable
- Type-safe form data with TypeScript interfaces from Zod schemas
