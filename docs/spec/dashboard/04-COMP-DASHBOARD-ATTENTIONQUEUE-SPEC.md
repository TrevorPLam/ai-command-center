---
steering: TO PARSE — READ INTRO
file_name: 04-COMP-DASHBOARD-ATTENTIONQUEUE-SPEC.md
document_type: component_specification
module: Dashboard
tier: core
status: draft
owner: Trevor
description: Attention queue component for displaying and managing system alerts, notifications, and action items requiring user attention.
last_updated: 2026-04-26
version: 1.0
dependencies: [04-COMP-DASHBOARD.md, 01-PLAN-ZUSTAND.md, 02-ARCH-DATABASE.md]
related_adrs: [ADR_003, ADR_085]
related_rules: [XCT_01, XCT_02, g4, S1, S28]
complexity: medium
risk_level: low
---

# AttentionQueue — Component Specification

## 1. Purpose

### 1.1 What This Is
A dashboard component that displays system alerts, notifications, and action items requiring user attention. It supports different alert types, priority levels, and batch actions for managing multiple items.

### 1.2 User Story
As a user, I want to see all important system alerts and notifications in one place so that I can quickly review and take action on items that require my attention.

### 1.3 Non-Goals
- Does NOT generate alerts (that's handled by alert service)
- Does NOT implement email notifications (separate system)
- Does NOT handle alert routing rules (Phase 2 feature)
- Does NOT support custom alert workflows (Phase 2 feature)

## 2. UX States

### 2.1 State Catalog
| State ID | State Name | Trigger Condition | Visual Behavior | User Action Available |
|----------|------------|-------------------|-----------------|----------------------|
| S-LOADING | Loading | Queue data fetching | Skeleton list with loading shimmer | None |
| S-EMPTY | Empty | No alerts in queue | Empty state with "All caught up" message | None |
| S-DATA | Data Present | Alerts loaded, ≥1 alert | Alert list with items | Dismiss, acknowledge, view details |
| S-ERROR | Error | Fetch failed, network error | Error message + retry button | Retry, refresh |
| S-FILTERING | Filtering | Active filter applied | Filter indicator, filtered alerts | Clear filter, modify filter |
| S-BATCH-ACTION | Batch Action | Multiple items selected | Batch action toolbar | Dismiss all, acknowledge all |
| S-EXPANDED | Expanded | Alert details expanded | Full alert details panel | Close, take action |

### 2.2 State Transition Diagram
S-LOADING → S-EMPTY | S-DATA | S-ERROR
S-DATA → S-FILTERING (on filter) → S-DATA (on clear)
S-DATA → S-BATCH-ACTION (on select multiple) → S-DATA (on clear selection)
S-DATA → S-EXPANDED (on expand item) → S-DATA (on collapse)
S-ERROR → S-LOADING (on retry) → S-DATA (on success)

### 2.3 DO NOT
- DO NOT auto-dismiss alerts without user action
- DO NOT show expired alerts (filter out automatically)
- DO NOT allow batch actions on different alert types

## 3. Transitions & Animations

### 3.1 Motion Patterns Used
| Pattern | Lexicon Ref | Applied To | Duration/Spring | Notes |
|---------|-------------|------------|-----------------|-------|
| @M | MotionGuard | Alert enter/exit, expand/collapse | — | Respects prefers-reduced-motion |
| @OF | OpacityFade | Filter transitions, hover states | ≤150ms | Quick feedback |
| @AP | AnimatePresence | Alert list items, batch toolbar | — | Smooth transitions |
| @LED | LEDBorder | High-priority alerts | — | Pulsing border for critical items |

### 3.2 DO NOT (HARD constraints from Lexicon)
- DO NOT animate alert count numbers (causes layout thrashing). (Rule XCT_01)
- DO NOT use spring animations for filter changes (use fade). (Rule g4)
- DO NOT animate when prefers-reduced-motion is active. Instant transitions. (Rule g6)

## 4. Data Shapes

### 4.1 Zustand Slice
Reference: 01-PLAN-ZUSTAND-TYPES.md DashboardSlice
```typescript
interface DashboardSlice {
  attentionQueue: AttentionQueueState;
  alerts: Record<string, Alert>;
  selectedAlertIds: string[];
  filters: AlertFilters;
  isExpanded: Record<string, boolean>;
}

interface AttentionQueueState {
  unreadCount: number;
  totalCount: number;
  lastUpdated: Date;
}
```

### 4.2 Database Tables Referenced
| Table | Columns Used | RLS Policy |
|-------|-------------|------------|
| alerts | id, org_id, user_id, type, priority, message, created_at, acknowledged_at | org_id = auth.jwt()->>org_id |

### 4.3 API Payloads
#### Get Alerts
```json
{
  "filters": {
    "type": "string // optional",
    "priority": "string // optional",
    "status": "string // optional"
  },
  "limit": "number // default 50"
}
```
#### Acknowledge Alert
```json
{
  "alert_id": "string // ULID",
  "acknowledged": boolean
}
```
#### Response (200)
```json
{
  "data": {
    "alerts": [],
    "unread_count": number,
    "total_count": number
  },
  "error": null,
  "meta": {}
}
```

### 4.4 Validation Rules
- alert_id: must be valid ULID and belongs to user
- priority: must be one of 'low', 'medium', 'high', 'critical'
- type: must be registered alert type

## 5. Edge Cases & Error Handling

### 5.1 Edge Cases
| ID | Scenario | Expected Behavior | Test Verification |
|----|----------|-------------------|-------------------|
| EC-001 | 1000+ alerts in queue | Pagination, virtualization | Create 1000 alerts |
| EC-002 | Rapid alert arrivals | Real-time updates, no flicker | Send alerts rapidly |
| EC-003 | Expired alerts | Auto-filter out | Create expired alert |
| EC-004 | Batch action on mixed types | Show error, require same type | Select mixed alerts |
| EC-005 | Network drop during action | Queue action, sync on reconnect | Disconnect during dismiss |

### 5.2 Error Scenarios
| Error Code | Trigger | User Sees | System Does | Recovery |
|------------|---------|-----------|-------------|----------|
| VALIDATION_ERROR | Invalid alert ID | "Invalid alert" toast | 400 response | User must retry |
| PERMISSION_DENIED | User lacks access | "Access denied" toast | 403 response | Request permission |
| NETWORK_ERROR | Action fails | "Connection lost" banner | Retry with exponential backoff | Auto-retry 3x |
| ALERT_NOT_FOUND | Alert already dismissed | "Alert not found" error | 404 response | Refresh queue |

### 5.3 Race Conditions
- Alert dismissal while filtering: Update filter after dismissal completes.
- Batch action while new alerts arrive: Apply batch to current selection only.
- Real-time update while expanded: Update expanded alert if it matches.

## 6. Acceptance Criteria

### 6.1 Functional
- [ ] All 7 UX states render correctly
- [ ] Alert types display with appropriate styling
- [ ] Priority levels show correct visual hierarchy
- [ ] Batch actions work for multiple selections
- [ ] Real-time updates appear without page refresh
- [ ] Responsive design works on mobile

### 6.2 Performance
- [ ] Initial render ≤ 500ms (p75)
- [ ] Alert dismissal ≤ 100ms
- [ ] Real-time update ≤ 200ms
- [ ] Memory usage ≤ 2MB per 100 alerts

### 6.3 Accessibility
- [ ] WCAG 2.2 AA: keyboard navigation functional
- [ ] WCAG 2.2 AA: screen reader announces alert types
- [ ] prefers-reduced-motion: animations disabled

### 6.4 Security
- [ ] CSP: no inline scripts
- [ ] RLS: all queries scoped to org_id and user_id
- [ ] Input: all alert content sanitized

## 7. Accessibility

### 7.1 ARIA Roles & Labels
| Element | Role | aria-label | Notes |
|---------|------|------------|-------|
| Alert list | log | "System alerts and notifications" | aria-live="polite" |
| Alert item | article | "[type] alert: [message]" | aria-atomic="true" |
| Dismiss button | button | "Dismiss alert" | |
| Acknowledge button | button | "Acknowledge alert" | |
| Filter dropdown | combobox | "Filter alerts" | |

### 7.2 Keyboard Navigation
| Key | Action | Notes |
|-----|--------|-------|
| Tab | Navigate through alerts and controls | |
| Space | Select/deselect alert for batch | |
| Enter | Acknowledge focused alert | |
| Delete | Dismiss focused alert | |
| Escape | Close expanded alert, clear selection | |
| Ctrl+A | Select all visible alerts | |

### 7.3 Screen Reader Announcements
| Event | aria-live Region | Message |
|-------|-----------------|---------|
| New alert | assertive | "New [type] alert: [message]" |
| Alert dismissed | polite | "Alert dismissed" |
| Batch action completed | assertive | "[X] alerts [action]" |
| Error occurred | assertive | "Error: [message]" |

## 8. Testing Strategy

### 8.1 Unit Tests
- AttentionQueue renders empty state
- AttentionQueue renders with alerts
- AttentionQueue handles filtering
- AttentionQueue handles batch actions

### 8.2 Component Tests
- Alert dismissal flow
- Alert acknowledgment flow
- Real-time update handling
- Responsive layout behavior

### 8.3 Integration Tests
- Complete alert management flow
- Filter and search combinations
- Batch action workflows
- Real-time collaboration

### 8.4 Security Tests
- Alert data sanitization
- User permission enforcement
- RLS compliance

## 9. Risks & Open Questions

### 9.1 Risks
- Alert spam (mitigated by rate limiting)
- Performance with many alerts (mitigated by virtualization)
- Data corruption during sync (mitigated by conflict resolution)

### 9.2 Open Questions
- Should alerts auto-expire after time? → Phase 1.1
- Should alerts support custom actions? → Phase 2
- How should alert escalation work? → Design review

### 9.3 Assumptions
- Real-time updates use WebSocket connections
- Alert priorities follow standard severity levels
- User can only access their own alerts
- Alert content is plain text or sanitized HTML
