---
steering: TO PARSE — READ INTRO
file_name: 04-COMP-DASHBOARD-DECISIONPACKET-SPEC.md
document_type: component_specification
module: Dashboard
tier: core
status: draft
owner: Trevor
description: Decision packet component for displaying and managing structured decision items with voting, comments, and resolution tracking.
last_updated: 2026-04-26
version: 1.0
dependencies: [04-COMP-DASHBOARD.md, 01-PLAN-ZUSTAND.md, 02-ARCH-DATABASE.md]
related_adrs: [ADR_003, ADR_085]
related_rules: [XCT_01, XCT_02, g4, S1, S28]
complexity: high
risk_level: medium
---

# DecisionPacket — Component Specification

## 1. Purpose

### 1.1 What This Is
A dashboard component that displays structured decision packets requiring team input, voting, and resolution. It supports different decision types, voting mechanisms, and outcome tracking with full audit trails.

### 1.2 User Story
As a team member, I want to see all pending decisions and be able to vote or provide input so that our team can make informed decisions efficiently and transparently.

### 1.3 Non-Goals
- Does NOT create decision packets (delegated to DecisionComposer)
- Does NOT implement notification routing (handled by alert service)
- Does NOT support advanced voting algorithms (Phase 2 feature)
- Does NOT handle decision templates (Phase 2 feature)

## 2. UX States

### 2.1 State Catalog
| State ID | State Name | Trigger Condition | Visual Behavior | User Action Available |
|----------|------------|-------------------|-----------------|----------------------|
| S-LOADING | Loading | Decision data fetching | Skeleton list with loading shimmer | None |
| S-EMPTY | Empty | No decisions pending | Empty state with "No decisions pending" | None |
| S-DATA | Data Present | Decisions loaded, ≥1 decision | Decision list with cards | Vote, comment, view details |
| S-ERROR | Error | Fetch failed, network error | Error message + retry button | Retry, refresh |
| S-VOTING | Voting | User actively voting | Voting interface with options | Submit vote, change vote |
| S-RESOLVED | Resolved | Decision has outcome | Resolved state with result | View outcome, archive |
| S-EXPANDED | Expanded | Decision details expanded | Full decision panel with context | Close, vote, comment |

### 2.2 State Transition Diagram
S-LOADING → S-EMPTY | S-DATA | S-ERROR
S-DATA → S-VOTING (on vote click) → S-DATA (on vote submit)
S-DATA → S-EXPANDED (on expand) → S-DATA (on collapse)
S-DATA → S-RESOLVED (on resolution) → S-RESOLVED (final state)
S-ERROR → S-LOADING (on retry) → S-DATA (on success)

### 2.3 DO NOT
- DO NOT allow voting after deadline
- DO NOT show vote counts before user votes (to avoid bias)
- DO NOT allow changing vote after decision resolved

## 3. Transitions & Animations

### 3.1 Motion Patterns Used
| Pattern | Lexicon Ref | Applied To | Duration/Spring | Notes |
|---------|-------------|------------|-----------------|-------|
| @M | MotionGuard | Vote submission, expand/collapse | — | Respects prefers-reduced-motion |
| @OF | OpacityFade | Filter transitions, hover states | ≤150ms | Quick feedback |
| @AP | AnimatePresence | Decision cards, voting panel | — | Smooth transitions |
| @LED | LEDBorder | Urgent decisions | — | Pulsing border for critical items |

### 3.2 DO NOT (HARD constraints from Lexicon)
- DO NOT animate vote count numbers (causes layout thrashing). (Rule XCT_01)
- DO NOT use spring animations for filter changes (use fade). (Rule g4)
- DO NOT animate when prefers-reduced-motion is active. Instant transitions. (Rule g6)

## 4. Data Shapes

### 4.1 Zustand Slice
Reference: 01-PLAN-ZUSTAND-TYPES.md DashboardSlice
```typescript
interface DashboardSlice {
  decisionPackets: DecisionPacketState;
  decisions: Record<string, Decision>;
  userVotes: Record<string, Vote>;
  filters: DecisionFilters;
  isExpanded: Record<string, boolean>;
}

interface DecisionPacketState {
  pendingCount: number;
  resolvedCount: number;
  urgentCount: number;
  lastUpdated: Date;
}
```

### 4.2 Database Tables Referenced
| Table | Columns Used | RLS Policy |
|-------|-------------|------------|
| decisions | id, org_id, title, description, type, deadline, created_at, resolved_at | org_id = auth.jwt()->>org_id |
| votes | id, org_id, decision_id, user_id, choice, created_at | org_id = auth.jwt()->>org_id |
| decision_options | id, org_id, decision_id, title, description, vote_count | org_id = auth.jwt()->>org_id |

### 4.3 API Payloads
#### Get Decisions
```json
{
  "filters": {
    "status": "string // 'pending'|'resolved'",
    "type": "string // optional",
    "urgency": "string // optional"
  },
  "limit": "number // default 50"
}
```
#### Submit Vote
```json
{
  "decision_id": "string // ULID",
  "option_id": "string // ULID",
  "comment": "string // optional"
}
```
#### Response (200)
```json
{
  "data": {
    "decisions": [],
    "pending_count": number,
    "resolved_count": number
  },
  "error": null,
  "meta": {}
}
```

### 4.4 Validation Rules
- decision_id: must be valid ULID and user has access
- option_id: must belong to decision
- deadline: must be in future for voting decisions
- comment: sanitized via DOMPurify RICH profile

## 5. Edge Cases & Error Handling

### 5.1 Edge Cases
| ID | Scenario | Expected Behavior | Test Verification |
|----|----------|-------------------|-------------------|
| EC-001 | Vote after deadline | Show "Voting closed" message | Try to vote after deadline |
| EC-002 | Change vote before deadline | Update existing vote | Vote, then change vote |
| EC-003 | Decision with no options | Show error, cannot vote | Create decision without options |
| EC-004 | Rapid vote submissions | Debounce, show last vote | Submit multiple votes quickly |
| EC-005 | Network drop during vote | Queue vote, sync on reconnect | Disconnect while voting |

### 5.2 Error Scenarios
| Error Code | Trigger | User Sees | System Does | Recovery |
|------------|---------|-----------|-------------|----------|
| VALIDATION_ERROR | Invalid vote data | "Invalid vote" toast | 400 response | User must fix vote |
| PERMISSION_DENIED | User lacks voting rights | "Cannot vote" message | 403 response | Request permission |
| DEADLINE_PASSED | Vote after deadline | "Voting closed" message | 400 response | View results only |
| NETWORK_ERROR | Vote fails | "Connection lost" banner | Retry with exponential backoff | Auto-retry 3x |

### 5.3 Race Conditions
- Vote submission while resolving: Accept vote if before resolution timestamp.
- Real-time vote count updates: Update counts without page refresh.
- Decision resolution while voting: Cancel voting, show resolved state.

## 6. Acceptance Criteria

### 6.1 Functional
- [ ] All 7 UX states render correctly
- [ ] Voting interface works for different decision types
- [ ] Vote counts update in real-time
- [ ] Decision deadlines are enforced
- [ ] Resolved decisions show outcomes clearly
- [ ] Responsive design works on mobile

### 6.2 Performance
- [ ] Initial render ≤ 600ms (p75)
- [ ] Vote submission ≤ 200ms
- [ ] Real-time updates ≤ 300ms
- [ ] Memory usage ≤ 3MB per 100 decisions

### 6.3 Accessibility
- [ ] WCAG 2.2 AA: keyboard navigation functional
- [ ] WCAG 2.2 AA: screen reader announces vote status
- [ ] prefers-reduced-motion: animations disabled

### 6.4 Security
- [ ] CSP: no inline scripts
- [ ] RLS: all queries scoped to org_id
- [ ] Input: all decision content sanitized

## 7. Accessibility

### 7.1 ARIA Roles & Labels
| Element | Role | aria-label | Notes |
|---------|------|------------|-------|
| Decision list | main | "Pending decisions" | |
| Decision card | article | "Decision: [title], [status]" | aria-live="polite" |
| Vote button | button | "Vote for [option]" | |
| Vote count | status | "[X] votes for [option]" | aria-atomic="true" |
| Deadline | time | "Voting closes [date]" | datetime attribute |

### 7.2 Keyboard Navigation
| Key | Action | Notes |
|-----|--------|-------|
| Tab | Navigate through decisions and controls | |
| Enter | Select vote option | |
| Space | Select vote option | |
| Arrow keys | Navigate vote options | |
| Escape | Close expanded decision | |
| Ctrl+Enter | Submit vote (when in voting mode) | |

### 7.3 Screen Reader Announcements
| Event | aria-live Region | Message |
|-------|-----------------|---------|
| New decision | assertive | "New decision: [title]" |
| Vote submitted | polite | "Vote submitted for [option]" |
| Decision resolved | assertive | "Decision resolved: [outcome]" |
| Deadline approaching | assertive | "Voting closes in [time]" |

## 8. Testing Strategy

### 8.1 Unit Tests
- DecisionPacket renders empty state
- DecisionPacket renders with decisions
- DecisionPacket handles voting
- DecisionPacket enforces deadlines

### 8.2 Component Tests
- Vote submission flow
- Real-time vote count updates
- Decision resolution flow
- Responsive layout behavior

### 8.3 Integration Tests
- Complete decision lifecycle
- Multiple user voting scenarios
- Deadline enforcement
- Real-time collaboration

### 8.4 Security Tests
- Vote data sanitization
- Permission enforcement
- RLS compliance

## 9. Risks & Open Questions

### 9.1 Risks
- Vote manipulation (mitigated by audit logging)
- Performance with many voters (mitigated by optimization)
- Data corruption during sync (mitigated by conflict resolution)

### 9.2 Open Questions
- Should votes be anonymous? → Phase 1.1
- Should decisions support abstentions? → Phase 1.1
- How should tie-breaking work? → Design review

### 9.3 Assumptions
- Real-time updates use WebSocket connections
- Vote deadlines are enforced server-side
- Users can only vote once per decision
- Decision outcomes are immutable once resolved
