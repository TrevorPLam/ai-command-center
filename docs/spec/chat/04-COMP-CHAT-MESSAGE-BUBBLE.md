---
steering: TO PARSE — READ INTRO
file_name: 04-COMP-CHAT-MESSAGE-BUBBLE.md
document_type: component_specification
module: Chat
tier: core
status: draft
owner: Trevor
description: Message bubble component for rendering chat messages with support for different message types, tool calls, and interactive elements.
last_updated: 2026-04-26
version: 1.0
dependencies: [04-COMP-CHAT.md, 01-PLAN-ZUSTAND.md, 02-ARCH-DATABASE.md]
related_adrs: [ADR_003, ADR_085]
related_rules: [XCT_01, XCT_02, g4, S1, S28]
complexity: medium
risk_level: low
---

# MessageBubble — Component Specification

## 1. Purpose

### 1.1 What This Is
A flexible message bubble component that renders different types of chat messages (user, assistant, system, tool calls) with proper styling, animations, and interactive elements. It handles message states, timestamps, editing capabilities, and integrates with the chat state management system.

### 1.2 User Story
As a user, I want to see chat messages rendered clearly with appropriate styling and interactions so that I can distinguish between different message types and take actions like editing or copying content.

### 1.3 Non-Goals
- Does NOT handle message sending logic (that's ChatInput's responsibility)
- Does NOT manage thread state directly (uses ChatSlice)
- Does NOT handle real-time streaming (that's MessageList's responsibility)
- Does NOT implement file upload UI (delegated to separate components)

## 2. UX States

### 2.1 State Catalog
| State ID | State Name | Trigger Condition | Visual Behavior | User Action Available |
|----------|------------|-------------------|-----------------|----------------------|
| S-LOADING | Loading | Message data fetching | Skeleton bubble with shimmer animation | None |
| S-USER | User Message | Message from current user | Right-aligned bubble, blue background | Edit, Copy, Delete |
| S-ASSISTANT | Assistant Message | Message from AI assistant | Left-aligned bubble, dark background | Copy, Regenerate |
| S-SYSTEM | System Message | System notification or status | Centered, gray background, small text | None |
| S-TOOL-CALL | Tool Call | AI invoked a tool | Special bubble with tool icon and expandable details | Expand/Collapse, Copy |
| S-TOOL-RESULT | Tool Result | Tool execution completed | Nested bubble under tool call with result data | Copy, View Details |
| S-ERROR | Error | Message sending/processing failed | Red-tinted bubble, error icon | Retry, Edit |
| S-EDITING | Editing | User clicked edit on own message | Input field replaces message content | Save, Cancel |
| S-STREAMING | Streaming | AI response in progress | Typing indicator with partial content | Stop generation |

### 2.2 State Transition Diagram
S-LOADING → S-USER | S-ASSISTANT | S-SYSTEM | S-TOOL-CALL | S-ERROR
S-USER → S-EDITING (on edit click) → S-USER (on save) | S-ERROR (on save failure)
S-TOOL-CALL → S-TOOL-RESULT (on completion) | S-ERROR (on failure)
S-STREAMING → S-ASSISTANT (on completion) | S-ERROR (on failure)

### 2.3 DO NOT
- DO NOT show user messages on the left side (always right-aligned)
- DO NOT allow editing of assistant or system messages
- DO NOT show tool results without their corresponding tool call
- DO NOT animate streaming text word-by-word (use typewriter effect only)

## 3. Transitions & Animations

### 3.1 Motion Patterns Used
| Pattern | Lexicon Ref | Applied To | Duration/Spring | Notes |
|---------|-------------|------------|-----------------|-------|
| @M | MotionGuard | All bubble entrance/exit | — | Respects prefers-reduced-motion |
| @AS | Spring | Tool call expand/collapse | tension≥300, damping≥30 | Smooth accordion behavior |
| @O | OptimisticMutation | Message edit/delete | pending: opacity 0.7 + scale 0.98 | Undo 5s for delete |
| @Q | OpacityFade | State transitions | ≤150ms | Quick feedback |

### 3.2 DO NOT (HARD constraints from Lexicon)
- DO NOT animate layout properties. Only transform and opacity. (Rule XCT_01)
- DO NOT use spring animations for streaming text (causes layout thrashing)
- DO NOT animate when prefers-reduced-motion is active. Instant transition. (Rule g6)

## 4. Data Shapes

### 4.1 Zustand Slice
Reference: 01-PLAN-ZUSTAND-TYPES.md ChatSlice
```typescript
interface ChatSlice {
  activeThreadId: string | null;
  threads: Record<string, Thread>;
  messages: Record<string, Message[]>;
  streamingMessageId: string | null;
  editingMessageId: string | null;
}

interface Message {
  id: string;                    // ULID
  org_id: string;
  thread_id: string;
  user_id: string;
  type: 'user' | 'assistant' | 'system' | 'tool_call' | 'tool_result';
  content: string;
  tool_calls?: ToolCall[];
  created_at: string;             // ISO 8601
  updated_at: string;
  deleted_at: string | null;
}
```

### 4.2 Database Tables Referenced
| Table | Columns Used | RLS Policy |
|-------|-------------|------------|
| messages | id, org_id, thread_id, user_id, type, content, tool_calls, created_at, updated_at, deleted_at | org_id = auth.jwt()->>org_id |

### 4.3 API Payloads
#### Update Message
```json
{
  "id": "string // ULID",
  "content": "string // updated content",
  "version": "number // optimistic version"
}
```
#### Delete Message
```json
{
  "id": "string // ULID"
}
```
#### Response (200)
```json
{
  "data": {"message": {}},
  "error": null,
  "meta": {"optimistic": true}
}
```

### 4.4 Validation Rules
- content: string, min 1 char, max 50,000 chars
- id: must be valid ULID format
- type: must be one of allowed message types
- tool_calls: array, required if type is 'tool_call', optional otherwise

## 5. Edge Cases & Error Handling

### 5.1 Edge Cases
| ID | Scenario | Expected Behavior | Test Verification |
|----|----------|-------------------|-------------------|
| EC-001 | Message content exceeds 50,000 chars | Show error toast, truncate display with "..." | Send 50,001 char message |
| EC-002 | Tool call result is very large JSON | Collapse by default, show "Expand" button | Create tool result with 10KB JSON |
| EC-003 | User tries to edit assistant message | Edit button disabled, tooltip shows "Can't edit assistant messages" | Hover over assistant message edit button |
| EC-004 | Rapid message deletion while offline | Show optimistic delete, queue for sync | Delete message, go offline, come back online |
| EC-005 | Message contains malicious script tags | Content sanitized via DOMPurify STRICT profile | Send message with `<script>alert()</script>` |

### 5.2 Error Scenarios
| Error Code (ref: 05-XCT-ERROR-TAXONOMY.md) | Trigger | User Sees | System Does | Recovery |
|---------------------------------------------|---------|-----------|-------------|----------|
| VALIDATION_ERROR | Content too long/invalid | "Message format error" toast | 400 response | User must fix content |
| AUTH_FAILED | User not authorized | "Can't edit this message" toast | 401 response | Re-auth required |
| NETWORK_ERROR | Save/delete fails | "Connection lost" banner | Retry with exponential backoff | Auto-retry 3x |
| RATE_LIMITED | Too many edits/deletes | "Slow down" toast with countdown | 429 response | Wait for window |

### 5.3 Race Conditions
- Concurrent edits: If user edits message while agent is modifying it → LWW via updated_at timestamp wins.
- Delete during edit: If message deleted while being edited → Cancel edit, show "Message deleted" toast.

## 6. Acceptance Criteria

### 6.1 Functional
- [ ] All 8 UX states render correctly with appropriate styling
- [ ] User messages align right, assistant/system left
- [ ] Tool calls expand/collapse smoothly with spring animation
- [ ] Edit mode replaces bubble content with input field
- [ ] Delete shows optimistic removal with 5-second undo
- [ ] Copy button copies content to clipboard
- [ ] Timestamps display in user's timezone (@TimezoneAware)

### 6.2 Performance
- [ ] Bubble render time ≤ 16ms (60fps)
- [ ] Tool call expansion animation ≤ 200ms
- [ ] Memory usage ≤ 2MB per 100 messages

### 6.3 Accessibility (mandatory for all UI specs)
- [ ] WCAG 2.2 AA: keyboard navigation functional
- [ ] WCAG 2.2 AA: screen reader announces message type and content
- [ ] WCAG 2.2 AA: focus order is logical (edit → save → cancel)
- [ ] prefers-reduced-motion: all animations disabled
- [ ] High contrast mode: colors meet 4.5:1 ratio

### 6.4 Security (cross-reference Domain E)
- [ ] CSP: no inline scripts introduced
- [ ] RLS: all queries scoped to org_id
- [ ] Input: all message content passes through SanitizedHTML with STRICT profile

## 7. Accessibility

### 7.1 ARIA Roles & Labels
| Element | Role | aria-label | Notes |
|---------|------|------------|-------|
| Message bubble | article | "Message from [sender] at [time]" | Dynamic based on message type |
| Edit button | button | "Edit message" | Only for user messages |
| Delete button | button | "Delete message" | Only for user messages |
| Copy button | button | "Copy message content" | Available on all messages |
| Tool call expander | button | "Expand tool call details" | aria-expanded state |

### 7.2 Keyboard Navigation
| Key | Action | Notes |
|-----|--------|-------|
| Tab | Move to next interactive element | |
| Enter | Activate focused button | |
| Escape | Exit edit mode, cancel changes | Must restore original content |
| Ctrl+C | Copy message content | When message focused |

### 7.3 Screen Reader Announcements
| Event | aria-live Region | Message |
|-------|-----------------|---------|
| Message sent | polite | "Message sent" |
| Message edited | polite | "Message edited" |
| Message deleted | assertive | "Message deleted" |
| Tool call completed | polite | "Tool call [tool_name] completed" |

### 7.4 DO NOT
- DO NOT use color alone to convey message type (use icons and text labels).
- DO NOT trap focus within message bubble.
- DO NOT auto-play animations longer than 3 seconds.

## 8. Testing Strategy

### 8.1 Unit Tests (Vitest)
| Test | What It Verifies | Target Coverage |
|------|-----------------|-----------------|
| MessageBubble renders user message | Correct alignment and styling | |
| MessageBubble renders assistant message | Correct alignment and styling | |
| MessageBubble handles tool calls | Expand/collapse behavior | |
| MessageBubble edit mode | Input field replaces content | |
| MessageBubble delete optimistic | Optimistic removal and undo | |

### 8.2 Component Tests (Vitest + Testing Library)
| Test | What It Verifies |
|------|-----------------|
| Edit button only shows for user messages | Permission logic |
| Copy button copies to clipboard | Clipboard API integration |
| Tool call expansion animation | Spring animation behavior |
| Reduced motion preference | Animations disabled |

### 8.3 Integration Tests (Playwright for critical flows)
| Flow | Steps |
|------|-------|
| Edit message flow | Click edit → modify content → save → verify update |
| Delete message flow | Click delete → confirm → optimistic removal → undo |
| Tool call interaction | Expand tool call → view details → collapse |

### 8.4 Security Tests (pgTAP, CSP, Schemathesis)
| Test | Rule Reference |
|------|---------------|
| RLS: tenant isolation | TESTC_04, S5 |
| CSP: no inline scripts | S6 |
| Input validation: XSS prevention | TESTC_04, S1 |

### 8.5 Test Data Requirements
- Message factory with different types (user, assistant, system, tool_call)
- Thread with multiple messages for testing ordering
- Tool call with large result for testing collapse behavior

## 9. Risks & Open Questions

### 9.1 Risks
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Performance with 1000+ messages | Medium | Medium | Virtualize parent MessageList, not individual bubbles |
| XSS via malicious content | Low | High | DOMPurify STRICT profile, CSP enforcement |
| Accessibility color contrast | Low | Medium | Use OKLCH design tokens, test with high contrast mode |

### 9.2 Open Questions
- Should tool call results be syntax highlighted? → Target resolution: Phase 1.1
- Should message bubbles support reactions/emoji responses? → Target resolution: Phase 2
- How should very long messages be truncated? → Target resolution: Design review

### 9.3 Assumptions
- All timestamps are in ISO 8601 format and converted to user's timezone
- Tool calls always have corresponding results (may be empty)
- Message content is plain text or sanitized HTML
- ULIDs are used for all message IDs
