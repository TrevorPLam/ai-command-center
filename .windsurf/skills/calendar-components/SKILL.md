---
name: calendar-components
description: Guides the creation of calendar components including CalendarPage with multiple views (Month, Week, Day, Agenda), EventDetailDrawer, and EventComposer with proper date handling and event management
---

## Calendar Components

### CalendarPage.tsx
Main calendar page with view switcher.

**Top bar:**
- View switcher: Month | Week | Day | Agenda
- Navigation arrows (prev/next)
- "Today" button
- "New Event" button (blue)

### MonthView.tsx
Standard calendar grid (7 columns x 5-6 rows):
- Days with events show colored chips (blue = event, amber = deadline, green = reminder)
- Clicking a day selects it and shows its events in a side pane
- Clicking an event chip opens EventDetailDrawer
- Current day highlighted with electric blue border
- Month label at top
- Navigation: prev/next month arrows

### WeekView.tsx
7-column time grid:
- 24hr or 12hr toggle
- Events render as colored blocks spanning their duration
- Hour labels on left (vertical axis)
- Days of week on top (horizontal axis)
- Current time indicator (red horizontal line)
- All-day events at top
- Scrollable time axis
- Click time slot: opens EventComposer with pre-filled time

### DayView.tsx
Single-day time grid:
- Same as week view but full width
- All-day events at top
- Hour-by-hour time slots
- Current time indicator (red horizontal line)
- Click time slot: opens EventComposer

### AgendaView.tsx
Chronological list of upcoming events:
- Grouped by date
- Each item: time range, title, location/link if present, event type badge
- Expand/collapse per date
- "Show past events" toggle
- Click event: opens EventDetailDrawer

### EventDetailDrawer.tsx
Right-side sheet (320px):
- Event title (large, editable)
- Date + time pickers
- All-day toggle
- Description textarea
- Location input
- Repeat rule selector (None / Daily / Weekly / Monthly / Custom)
- Link to project (dropdown of projects)
- Color picker
- Reminder selector (15min / 1hr / 1 day before)
- Edit + Delete buttons
- Show linked project info if present

### EventComposer.tsx
Modal for creating new events:
- Title input (required)
- Date picker
- Start time picker
- End time picker
- All-day toggle
- Description textarea
- Location input
- Repeat selector (None / Daily / Weekly / Monthly / Custom)
- Link to project dropdown
- Color picker (presets: blue, green, amber, red, purple)
- Reminder selector (15min / 1hr / 1 day before)
- Cancel + Create buttons
- Form validation with error messages

## Data Requirements

All calendar components must use realistic mock data from `src/lib/mockData/calendar.ts` with:
- Events across multiple days
- Various event types (meetings, deadlines, reminders)
- Recurring events
- Events linked to projects
- All-day events
- Events with locations and descriptions

## State Management

- Use TanStack Query for fetching calendar events
- Use Zustand for UI-only state (current view, selected date, drawer open/close)
- Use date-fns or luxon for date manipulation and formatting

## Accessibility Requirements (WCAG 2.2 AA)

- CalendarPage: proper ARIA landmarks (main, nav), semantic HTML, keyboard navigation for view switcher
- MonthView: grid role, proper cell labels, aria-selected for selected day, keyboard navigation
- WeekView/DayView: timegrid role, proper time labels, aria-label for time slots
- EventDetailDrawer: focus trap when open, role="dialog", aria-modal="true"
- EventComposer: proper form labels, error announcements, aria-invalid for invalid fields
- All interactive elements: 4.5:1 color contrast ratio minimum
- Focus management: visible focus indicators, focus restoration after modal close
- Dynamic content: aria-live regions for event updates
- Screen readers: announce date changes, event creation/deletion
- Keyboard navigation: arrow keys for calendar navigation, escape to close modals

## Visual Identity

- Glass panels: backdrop-blur-md bg-white/5 border border-white/10 rounded-xl
- Electric blue accent: #0066ff → #00aaff for CTAs and active states
- Event colors: blue (event), amber (deadline), green (reminder), purple (personal)
- 150ms ease-out transitions on all interactive elements
- Skeleton loaders on all data fetch states
- Current day: electric blue border and subtle blue background

**Tailwind v3 & shadcn/ui Notes (2026):**
- shadcn/ui uses Tailwind v3 with standard CSS configuration
- Components use forwardRef for ref forwarding (React 18 pattern)
- HSL colors are used in standard format
- Default style is available; use new-york style if preferred

## Date Handling

- Use date-fns or luxon for all date operations
- Format dates according to user settings (MM/DD/YYYY vs DD/MM/YYYY)
- Respect timezone settings
- Handle recurring events correctly
- Show relative timestamps (e.g., "in 2 hours", "tomorrow")
