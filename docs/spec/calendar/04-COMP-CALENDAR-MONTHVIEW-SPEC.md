---
steering: TO PARSE — READ INTRO
file_name: 04-COMP-CALENDAR-MONTHVIEW-SPEC.md
document_type: component_specification
module: Calendar
tier: core
status: draft
owner: Trevor
description: Month view calendar component for displaying events in a traditional monthly grid layout with navigation and event management capabilities.
last_updated: 2026-04-26
version: 1.0
dependencies: [04-COMP-CALENDAR.md, 01-PLAN-ZUSTAND.md, 02-ARCH-DATABASE.md]
related_adrs: [ADR_003, ADR_085]
related_rules: [XCT_01, XCT_02, g4, S1, S28]
complexity: medium
risk_level: low
---

# MonthView — Component Specification

## 1. Purpose

### 1.1 What This Is
A traditional month view calendar component that displays events in a grid layout with full month navigation, date selection, and event management capabilities. It handles different event types, time zones, and responsive design.

### 1.2 User Story
As a user, I want to view my calendar in a traditional month layout so that I can see all my events for the month at a glance and navigate between months easily.

### 1.3 Non-Goals
- Does NOT handle event creation (delegated to EventComposer)
- Does NOT implement week/day views (separate components)
- Does NOT handle drag-and-drop event moving (Phase 2 feature)
- Does NOT support calendar sharing (Phase 2 feature)

## 2. UX States

### 2.1 State Catalog
| State ID | State Name | Trigger Condition | Visual Behavior | User Action Available |
|----------|------------|-------------------|-----------------|----------------------|
| S-LOADING | Loading | Calendar data fetching | Skeleton grid with loading shimmer | None |
| S-EMPTY | Empty | No events in selected month | Empty calendar grid with "Add event" CTA | Navigate months, create event |
| S-DATA | Data Present | Events loaded, ≥1 event | Full month grid with events | Select date, view event, navigate |
| S-ERROR | Error | Fetch failed, network error | Error message + retry button | Retry, refresh |
| S-SELECTING | Selecting | Date selected | Highlighted date, event list sidebar | View events, create event |
| S-NAVIGATING | Navigating | Month navigation in progress | Loading overlay on grid | None |

### 2.2 State Transition Diagram
S-LOADING → S-EMPTY | S-DATA | S-ERROR
S-DATA → S-SELECTING (on date click) → S-DATA (on deselect)
S-ERROR → S-LOADING (on retry) → S-DATA (on success)
S-DATA → S-NAVIGATING (on month change) → S-DATA (on load)

### 2.3 DO NOT
- DO NOT auto-navigate to current month without user action
- DO NOT show events from other months in current grid
- DO NOT allow date selection before data loads

## 3. Transitions & Animations

### 3.1 Motion Patterns Used
| Pattern | Lexicon Ref | Applied To | Duration/Spring | Notes |
|---------|-------------|------------|-----------------|-------|
| @M | MotionGuard | Month navigation, date selection | — | Respects prefers-reduced-motion |
| @KS | KeyboardShortcuts | Calendar navigation, date selection | — | Arrow keys, Enter, Space |
| @OF | OpacityFade | Event hover states, error messages | ≤150ms | Quick feedback |
| @AP | AnimatePresence | Sidebar enter/exit | — | Smooth panel transitions |

### 3.2 DO NOT (HARD constraints from Lexicon)
- DO NOT animate grid layout changes (causes layout thrashing). (Rule XCT_01)
- DO NOT use spring animations for month navigation (use slide). (Rule g4)
- DO NOT animate when prefers-reduced-motion is active. Instant transitions. (Rule g6)

## 4. Data Shapes

### 4.1 Zustand Slice
Reference: 01-PLAN-ZUSTAND-TYPES.md CalendarSlice
```typescript
interface CalendarSlice {
  selectedDate: Date | null;
  currentMonth: Date;
  events: Record<string, Event[]>;
  calendars: Record<string, Calendar>;
  viewMode: 'month' | 'week' | 'day';
  isLoading: boolean;
}
```

### 4.2 Database Tables Referenced
| Table | Columns Used | RLS Policy |
|-------|-------------|------------|
| events | id, org_id, calendar_id, title, start_time, end_time, created_at | org_id = auth.jwt()->>org_id |
| calendars | id, org_id, name, color, created_at | org_id = auth.jwt()->>org_id |

### 4.3 API Payloads
#### Get Events for Month
```json
{
  "start_date": "string // ISO date",
  "end_date": "string // ISO date",
  "calendar_ids": ["string // calendar ULIDs"]
}
```
#### Response (200)
```json
{
  "data": {
    "events": [],
    "calendars": []
  },
  "error": null,
  "meta": {}
}
```

### 4.4 Validation Rules
- start_date/end_date: valid ISO dates, end_date ≥ start_date
- calendar_ids: array of valid ULIDs
- event times: must be within selected month

## 5. Edge Cases & Error Handling

### 5.1 Edge Cases
| ID | Scenario | Expected Behavior | Test Verification |
|----|----------|-------------------|-------------------|
| EC-001 | 100+ events in one day | Event count badge, "X more events" | Create 100 events same day |
| EC-002 | Events spanning multiple days | Event bar spans multiple cells | Create 3-day event |
| EC-003 | Different time zones | Display in user's local time | Create event in different timezone |
| EC-004 | Month with 6 weeks grid | Full 6x7 grid displayed | Navigate to February 2026 |
| EC-005 | Leap year handling | February 29th appears correctly | View February 2024 |

### 5.2 Error Scenarios
| Error Code | Trigger | User Sees | System Does | Recovery |
|------------|---------|-----------|-------------|----------|
| VALIDATION_ERROR | Invalid date range | "Invalid date range" toast | 400 response | User must fix dates |
| NETWORK_ERROR | Fetch fails | "Connection lost" banner | Retry with exponential backoff | Auto-retry 3x |
| CALENDAR_NOT_FOUND | Invalid calendar ID | "Calendar not found" error | 404 response | Navigate back |
| PERMISSION_DENIED | User lacks access | "Access denied" toast | 403 response | Request permission |

### 5.3 Race Conditions
- Month navigation while loading: Cancel previous request, load new month.
- Event creation while navigating: Queue creation, apply after navigation.
- Date selection while events loading: Queue selection, apply after load.

## 6. Acceptance Criteria

### 6.1 Functional
- [ ] All 6 UX states render correctly
- [ ] Month navigation works smoothly
- [ ] Date selection highlights and persists
- [ ] Events display correctly in grid cells
- [ ] Multi-day events span multiple cells
- [ ] Responsive design works on mobile

### 6.2 Performance
- [ ] Initial render ≤ 800ms (p75)
- [ ] Month navigation ≤ 300ms
- [ ] Event rendering ≤ 100ms for 100 events
- [ ] Memory usage ≤ 5MB per month

### 6.3 Accessibility
- [ ] WCAG 2.2 AA: keyboard navigation functional
- [ ] WCAG 2.2 AA: screen reader announces date and events
- [ ] prefers-reduced-motion: animations disabled

### 6.4 Security
- [ ] CSP: no inline scripts
- [ ] RLS: all queries scoped to org_id
- [ ] Input: all event data sanitized

## 7. Accessibility

### 7.1 ARIA Roles & Labels
| Element | Role | aria-label | Notes |
|---------|------|------------|-------|
| Calendar grid | grid | "Month calendar for [month year]" | |
| Date cell | gridcell | "[day], [weekday], [X] events" | aria-selected state |
| Event link | link | "[event title], [time]" | |
| Navigation buttons | button | "Previous month", "Next month" | |

### 7.2 Keyboard Navigation
| Key | Action | Notes |
|-----|--------|-------|
| Tab | Navigate through grid cells | |
| Arrow keys | Move between dates | |
| Enter | Select focused date | |
| Space | Select focused date | |
| Page Up/Down | Navigate months | |
| Home | Go to first day of month | |
| End | Go to last day of month | |

### 7.3 Screen Reader Announcements
| Event | aria-live Region | Message |
|-------|-----------------|---------|
| Month changed | polite | "Showing [month year]" |
| Date selected | polite | "Selected [day], [X] events" |
| Event created | assertive | "Event created: [title]" |
| Error occurred | assertive | "Error: [message]" |

## 8. Testing Strategy

### 8.1 Unit Tests
- MonthView renders empty state
- MonthView renders with events
- MonthView handles month navigation
- MonthView handles date selection

### 8.2 Component Tests
- Calendar grid navigation
- Event display in cells
- Multi-day event rendering
- Responsive layout behavior

### 8.3 Integration Tests
- Month navigation flow
- Event viewing flow
- Date selection with sidebar
- Time zone handling

### 8.4 Security Tests
- Event data sanitization
- Calendar permission enforcement
- RLS compliance

## 9. Risks & Open Questions

### 9.1 Risks
- Performance with many events (mitigated by virtualization)
- Time zone display issues (mitigated by proper date handling)
- Memory leaks with large datasets (mitigated by cleanup)

### 9.2 Open Questions
- Should month show week numbers? → Phase 1.1
- Should events be color-coded by calendar? → Phase 1.1
- How should all-day events be displayed? → Design review

### 9.3 Assumptions
- All dates are handled in user's local timezone
- Events are sorted by start time
- Calendar grid is always 6 weeks × 7 days
- Event colors come from calendar settings
