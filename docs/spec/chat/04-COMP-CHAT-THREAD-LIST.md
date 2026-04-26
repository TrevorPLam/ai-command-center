---
steering: TO PARSE — READ INTRO
file_name: 04-COMP-CHAT-THREAD-LIST.md
document_type: component_specification
module: Chat
tier: core
status: draft
owner: Trevor
description: Thread list component for displaying and managing chat conversation threads with search, filtering, and navigation capabilities.
last_updated: 2026-04-26
version: 1.0
dependencies: [04-COMP-CHAT.md, 01-PLAN-ZUSTAND.md, 02-ARCH-DATABASE.md]
related_adrs: [ADR_003, ADR_085]
related_rules: [XCT_01, XCT_02, P2, g4, S5]
complexity: medium
risk_level: low
---

# ThreadList — Component Specification

## 1. Purpose

### 1.1 What This Is
A virtualized list component that displays chat conversation threads with search, filtering, and navigation capabilities. It handles thread selection, creation, and management while integrating with the chat state system and providing smooth performance for large thread collections.

### 1.2 User Story
As a user, I want to see and navigate through my conversation threads so that I can quickly find and resume specific conversations.

### 1.3 Non-Goals
- Does NOT handle individual message rendering (that's MessageList's responsibility)
- Does NOT manage thread creation UI (delegated to separate components)
- Does NOT handle real-time thread updates (that's handled via SSE)
- Does NOT implement thread deletion (Phase 1 feature)

## 2. UX States

### 2.1 State Catalog
| State ID | State Name | Trigger Condition | Visual Behavior | User Action Available |
|----------|------------|-------------------|-----------------|----------------------|
| S-LOADING | Loading | Thread data fetching | Skeleton list with shimmer animation | None |
| S-EMPTY | Empty | No threads exist or search returns none | EmptyState component with "New conversation" CTA | Create new thread |
| S-DATA | Data Present | Threads loaded, ≥1 result | Virtualized list with thread items | Select thread, search, filter |
| S-ERROR | Error | Fetch failed, search error | Error message + retry button | Retry, Refresh |
| S-FILTERING | Filtering | Active search or filter applied | Filter indicator + filtered results | Clear filter, modify search |
| S-OFFLINE | Offline | Network lost | Stale data shown + offline indicator | Queue actions for sync |

### 2.2 State Transition Diagram
S-LOADING → S-EMPTY | S-DATA | S-ERROR
S-DATA → S-FILTERING (on search/filter) → S-EMPTY (if filter clears all)
S-ERROR → S-LOADING (on retry) → S-DATA (on success)
S-OFFLINE → S-DATA (on reconnect) → S-LOADING (on refresh)

### 2.3 DO NOT
- DO NOT show blank screen during loading (always show skeleton)
- DO NOT allow thread selection while in error state
- DO NOT auto-refresh threads without user action (respect P2 performance rule)

## 3. Transitions & Animations

### 3.1 Motion Patterns Used
| Pattern | Lexicon Ref | Applied To | Duration/Spring | Notes |
|---------|-------------|------------|-----------------|-------|
| @M | MotionGuard | List entrance/exit | — | Respects prefers-reduced-motion |
| @V | VirtualizeList | Thread list rendering | — | react-window for performance |
| @OF | OpacityFade | Filter transitions | ≤150ms | Quick filter feedback |
| @IS | InfiniteScroll | Scroll loading | — | Load more threads on scroll |

### 3.2 DO NOT (HARD constraints from Lexicon)
- DO NOT animate scroll position (handled by virtualization). (Rule P2)
- DO NOT use inline search debounce (use useTransition). (Rule P2)
- DO NOT render more than 100 threads without virtualization. (Rule P2)

## 4. Data Shapes

### 4.1 Zustand Slice
Reference: 01-PLAN-ZUSTAND-TYPES.md ChatSlice
```typescript
interface ChatSlice {
  activeThreadId: string | null;
  threads: Record<string, Thread>;
  messages: Record<string, Message[]>;
  searchQuery: string;
  filterStatus: 'all' | 'unread' | 'archived';
  streamingMessageId: string | null;
}
```

### 4.2 Database Tables Referenced
| Table | Columns Used | RLS Policy |
|-------|-------------|------------|
| threads | id, org_id, user_id, title, created_at, updated_at, deleted_at | org_id = auth.jwt()->>org_id |
| messages | thread_id, created_at (for latest message preview) | org_id = auth.jwt()->>org_id |

### 4.3 API Payloads
#### Search Threads
```json
{
  "q": "string // search query",
  "status": "string // filter: all|unread|archived",
  "limit": "number // pagination, default 50"
}
```
#### Response (200)
```json
{
  "data": {
    "threads": [],
    "cursor": "string",
    "hasMore": boolean
  },
  "error": null,
  "meta": {}
}
```

### 4.4 Validation Rules
- search query: string, max 200 chars
- status filter: must be one of allowed values
- limit: number, min 1, max 100

## 5. Edge Cases & Error Handling

### 5.1 Edge Cases
| ID | Scenario | Expected Behavior | Test Verification |
|----|----------|-------------------|-------------------|
| EC-001 | 1000+ threads | Virtualization enabled, smooth scrolling | Create 1000 threads, test performance |
| EC-002 | Search query with special characters | Proper encoding, no XSS | Search for `<script>alert()</script>` |
| EC-003 | Rapid filter changes | Debounced via useTransition | Toggle filter rapidly |
| EC-004 | Thread selected while loading | Selection queued, applied when data ready | Click thread during S-LOADING |
| EC-005 | No threads but archived filter active | Show "No archived threads" message | Apply archived filter to empty list |

### 5.2 Error Scenarios
| Error Code (ref: 05-XCT-ERROR-TAXONOMY.md) | Trigger | User Sees | System Does | Recovery |
|---------------------------------------------|---------|-----------|-------------|----------|
| VALIDATION_ERROR | Invalid search query | "Invalid search" toast | 400 response | User must fix query |
| NETWORK_ERROR | Fetch fails | "Connection lost" banner | Retry with exponential backoff | Auto-retry 3x |
| RATE_LIMITED | Too many requests | "Slow down" toast with countdown | 429 response | Wait for window |
| THREAD_NOT_FOUND | Navigate to deleted thread | "Thread not found" + redirect to list | 404 response | Navigate back to list |

### 5.3 Race Conditions
- Thread creation while searching: New thread appears in results after search completes.
- Thread deletion while selected: Selection cleared, list refreshes.
- Concurrent search queries: Latest query wins, previous results discarded.

## 6. Acceptance Criteria

### 6.1 Functional
- [ ] All 6 UX states render correctly
- [ ] Virtualization enabled for >50 threads
- [ ] Search debounced with 300ms delay
- [ ] Thread selection updates activeThreadId in ChatSlice
- [ ] Filter status persists across navigation
- [ ] Hover prefetch for thread content (200ms delay)

### 6.2 Performance
- [ ] Initial render ≤ 800ms (p75)
- [ ] Search response time ≤ 300ms
- [ ] Scroll performance: 60fps with 1000+ threads
- [ ] Memory usage ≤ 5MB for 1000 threads

### 6.3 Accessibility (mandatory for all UI specs)
- [ ] WCAG 2.2 AA: keyboard navigation functional
- [ ] WCAG 2.2 AA: screen reader announces thread count
- [ ] WCAG 2.2 AA: focus order is logical
- [ ] prefers-reduced-motion: animations disabled
- [ ] High contrast mode: colors meet 4.5:1 ratio

### 6.4 Security (cross-reference Domain E)
- [ ] CSP: no inline scripts introduced
- [ ] RLS: all queries scoped to org_id
- [ ] Input: search queries sanitized via DOMPurify

## 7. Accessibility

### 7.1 ARIA Roles & Labels
| Element | Role | aria-label | Notes |
|---------|------|------------|-------|
| Thread list container | listbox | "Conversation threads" | |
| Thread item | option | "[Thread title], last message [preview]" | Dynamic based on thread data |
| Search input | searchbox | "Search conversations" | |
| Filter dropdown | combobox | "Filter threads" | |

### 7.2 Keyboard Navigation
| Key | Action | Notes |
|-----|--------|-------|
| Tab | Move to next thread/interactive element | |
| Enter | Select focused thread | |
| Arrow Down/Up | Navigate thread list | |
| / | Focus search input | |
| Escape | Clear search, clear selection | |

### 7.3 Screen Reader Announcements
| Event | aria-live Region | Message |
|-------|-----------------|---------|
| Threads loaded | polite | "[X] conversations loaded" |
| Search completed | polite | "[X] results found" |
| Thread selected | polite | "Selected: [thread title]" |
| Error occurred | assertive | "Error loading conversations" |

### 7.4 DO NOT
- DO NOT use color alone to indicate thread status (use icons and text).
- DO NOT trap focus within thread list.
- DO NOT auto-play loading animations longer than 2 seconds.

## 8. Testing Strategy

### 8.1 Unit Tests (Vitest)
| Test | What It Verifies | Target Coverage |
|------|-----------------|-----------------|
| ThreadList renders loading state | Skeleton animation | |
| ThreadList renders empty state | EmptyState component | |
| ThreadList filters threads | Filter logic | |
| ThreadList handles search | Debounced search | |
| ThreadList virtualization | react-window integration | |

### 8.2 Component Tests (Vitest + Testing Library)
| Test | What It Verifies |
|------|-----------------|
| Thread selection updates state | activeThreadId in ChatSlice |
| Search debouncing | 300ms delay | |
| Filter persistence | Filter status saved | |
| Keyboard navigation | Arrow keys, Enter, Tab | |

### 8.3 Integration Tests (Playwright for critical flows)
| Flow | Steps |
|------|-------|
| Search thread flow | Type search → wait 300ms → verify results → select thread |
| Filter thread flow | Click filter → select status → verify filtered results |
| Navigate thread flow | Select thread → verify activeThreadId → navigate to thread view |

### 8.4 Security Tests (pgTAP, CSP, Schemathesis)
| Test | Rule Reference |
|------|---------------|
| RLS: tenant isolation | TESTC_04, S5 |
| CSP: no inline scripts | S6 |
| Input validation: XSS prevention | TESTC_04, S1 |

### 8.5 Test Data Requirements
- Thread factory with different statuses (active, archived)
- Messages factory for thread previews
- Search queries with special characters

## 9. Risks & Open Questions

### 9.1 Risks
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Performance with 10,000+ threads | Medium | High | Virtualization with react-window, strict P2 rule |
| Search XSS via malicious queries | Low | High | DOMPurify STRICT profile, CSP enforcement |
| Memory leaks with large lists | Low | Medium | Proper cleanup in useEffect, virtualization |

### 9.2 Open Questions
- Should threads show unread count badges? → Target resolution: Phase 1.1
- Should search include message content or just thread titles? → Target resolution: Design review
- How should thread previews handle long messages? → Target resolution: Design review

### 9.3 Assumptions
- All thread titles are plain text or sanitized HTML
- Thread previews show last message content (truncated if needed)
- Search queries are case-insensitive
- Virtualization threshold is exactly 50 threads
