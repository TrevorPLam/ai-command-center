---
steering: TO PARSE — READ INTRO
file_name: 04-COMP-CHAT-TOOL-CALL.md
document_type: component_specification
module: Chat
tier: core
status: draft
owner: Trevor
description: Tool call disclosure component for displaying and interacting with AI tool invocations and their results.
last_updated: 2026-04-26
version: 1.0
dependencies: [04-COMP-CHAT.md, 01-PLAN-ZUSTAND.md, 02-ARCH-DATABASE.md]
related_adrs: [ADR_003, ADR_085]
related_rules: [XCT_01, XCT_02, g4, S1, S28]
complexity: medium
risk_level: low
---

# ToolCallDisclosure — Component Specification

## 1. Purpose

### 1.1 What This Is
A disclosure component that displays AI tool calls within chat messages, allowing users to expand/collapse tool details, view parameters, and see execution results. It handles different tool types and provides appropriate visual feedback for tool states.

### 1.2 User Story
As a user, I want to see what tools the AI is using and be able to inspect their details so that I can understand how the assistant is working and verify its actions.

### 1.3 Non-Goals
- Does NOT execute tools (that's handled server-side)
- Does NOT manage tool registration (delegated to tool service)
- Does NOT handle tool permissions (handled by guardrails)
- Does NOT implement tool creation (Phase 1 feature)

## 2. UX States

### 2.1 State Catalog
| State ID | State Name | Trigger Condition | Visual Behavior | User Action Available |
|----------|------------|-------------------|-----------------|----------------------|
| S-COLLAPSED | Collapsed | Tool call rendered, not expanded | Tool icon + brief summary | Expand, Copy |
| S-EXPANDED | Expanded | User clicked expand | Full tool details, parameters, results | Collapse, Copy, View Details |
| S-EXECUTING | Executing | Tool call in progress | Loading spinner, "Executing..." | None |
| S-SUCCESS | Success | Tool completed successfully | Green checkmark, results visible | Collapse, Copy |
| S-ERROR | Error | Tool failed | Red X, error message, retry button | Retry, Collapse |
| S-PERMISSION-DENIED | Permission Denied | Tool requires permission | Lock icon, permission request | Grant Permission, Cancel |

### 2.2 State Transition Diagram
S-COLLAPSED → S-EXPANDED (on click) → S-COLLAPSED (on collapse)
S-EXPANDED → S-EXECUTING (on re-run) → S-SUCCESS | S-ERROR
S-ERROR → S-EXECUTING (on retry) → S-SUCCESS | S-ERROR
S-PERMISSION-DENIED → S-EXECUTING (on permission granted) → S-SUCCESS

### 2.3 DO NOT
- DO NOT auto-expand tool calls on render
- DO NOT allow tool execution without proper permissions
- DO NOT show raw tool parameters without sanitization

## 3. Transitions & Animations

### 3.1 Motion Patterns Used
| Pattern | Lexicon Ref | Applied To | Duration/Spring | Notes |
|---------|-------------|------------|-----------------|-------|
| @M | MotionGuard | Expand/collapse | — | Respects prefers-reduced-motion |
| @AS | Spring | Tool execution feedback | tension≥300, damping≥30 | Smooth accordion behavior |
| @OF | OpacityFade | State transitions | ≤150ms | Quick feedback |

### 3.2 DO NOT (HARD constraints from Lexicon)
- DO NOT animate layout properties. Only transform and opacity. (Rule XCT_01)
- DO NOT use spring animations for error states (use fade only). (Rule g4)

## 4. Data Shapes

### 4.1 Zustand Slice
Reference: 01-PLAN-ZUSTAND-TYPES.md ChatSlice
```typescript
interface ChatSlice {
  activeThreadId: string | null;
  threads: Record<string, Thread>;
  messages: Record<string, Message[]>;
  expandedToolCalls: Record<string, boolean>;
}
```

### 4.2 Database Tables Referenced
| Table | Columns Used | RLS Policy |
|-------|-------------|------------|
| messages | id, org_id, thread_id, tool_calls, created_at | org_id = auth.jwt()->>org_id |

### 4.3 API Payloads
#### Tool Call Structure
```json
{
  "id": "string // ULID",
  "name": "string // tool name",
  "parameters": "object // sanitized params",
  "status": "pending|executing|success|error",
  "result": "object // tool output",
  "error": "string // error message if failed"
}
```

### 4.4 Validation Rules
- tool name: must be registered tool
- parameters: sanitized via DOMPurify STRICT profile
- result: sanitized via DOMPurify RICH profile

## 5. Edge Cases & Error Handling

### 5.1 Edge Cases
| ID | Scenario | Expected Behavior | Test Verification |
|----|----------|-------------------|-------------------|
| EC-001 | Very large tool result | Truncate with "Show more" button | Create tool with 10KB result |
| EC-002 | Malicious tool parameters | Sanitized, show safe preview | Send params with XSS attempt |
| EC-003 | Tool timeout | Show "Tool timed out" error | Mock timeout scenario |
| EC-004 | Concurrent tool calls | Show each independently | Multiple tools in one message |

### 5.2 Error Scenarios
| Error Code | Trigger | User Sees | System Does | Recovery |
|------------|---------|-----------|-------------|----------|
| TOOL_TIMEOUT | Tool execution > 30s | "Tool timed out" banner | Cancel execution | Retry with timeout |
| TOOL_PERMISSION_DENIED | User lacks permission | Permission request dialog | Request permission | Grant/deny |
| TOOL_EXECUTION_ERROR | Tool failed | Error message + retry | Log error | Retry tool |

### 5.3 Race Conditions
- Tool completion while expanding: Update expanded state with results.
- Permission request while collapsing: Cancel request, collapse state.

## 6. Acceptance Criteria

### 6.1 Functional
- [ ] All 6 UX states render correctly
- [ ] Expand/collapse animation is smooth
- [ ] Tool parameters are sanitized and displayed
- [ ] Results are formatted appropriately (JSON, text, etc.)
- [ ] Copy button copies tool details to clipboard
- [ ] Permission requests show clear UI

### 6.2 Performance
- [ ] Expand/collapse ≤ 200ms
- [ ] Tool result rendering ≤ 100ms
- [ ] Memory usage ≤ 1MB per 10 tool calls

### 6.3 Accessibility
- [ ] WCAG 2.2 AA: keyboard navigation functional
- [ ] WCAG 2.2 AA: screen reader announces tool states
- [ ] prefers-reduced-motion: animations disabled

### 6.4 Security
- [ ] CSP: no inline scripts
- [ ] RLS: all queries scoped to org_id
- [ ] Input: all content sanitized via DOMPurify

## 7. Accessibility

### 7.1 ARIA Roles & Labels
| Element | Role | aria-label | Notes |
|---------|------|------------|-------|
| Tool call container | article | "Tool call: [tool name]" | |
| Expand button | button | "Expand tool details" | aria-expanded state |
| Copy button | button | "Copy tool details" | |
| Permission dialog | dialog | "Tool permission required" | |

### 7.2 Keyboard Navigation
| Key | Action | Notes |
|-----|--------|-------|
| Enter | Expand/collapse focused tool | |
| Space | Expand/collapse focused tool | |
| Escape | Close permission dialog | |
| Tab | Navigate to next interactive element | |

### 7.3 Screen Reader Announcements
| Event | aria-live Region | Message |
|-------|-----------------|---------|
| Tool executing | polite | "Executing tool: [name]" |
| Tool completed | polite | "Tool [name] completed successfully" |
| Tool failed | assertive | "Tool [name] failed: [error]" |

## 8. Testing Strategy

### 8.1 Unit Tests
- ToolCallDisclosure renders collapsed state
- ToolCallDisclosure expands on click
- ToolCallDisclosure handles different tool types
- ToolCallDisclosure sanitizes parameters

### 8.2 Component Tests
- Expand/collapse animation behavior
- Copy button functionality
- Permission request flow
- Error state handling

### 8.3 Integration Tests
- Tool call in message context
- Multiple tool calls in one message
- Tool execution feedback loop

### 8.4 Security Tests
- XSS prevention in parameters
- XSS prevention in results
- RLS compliance

## 9. Risks & Open Questions

### 9.1 Risks
- XSS via malicious tool parameters/results (mitigated by DOMPurify)
- Performance with many tool calls (mitigated by virtualization)
- Information disclosure via tool details (mitigated by permissions)

### 9.2 Open Questions
- Should tool calls show execution time? → Phase 1.1
- Should users be able to re-run tools? → Phase 1.2
- How should nested tool calls be displayed? → Design review

### 9.3 Assumptions
- All tool calls are part of a message
- Tool results are JSON-serializable
- Permission requests are handled by parent component
