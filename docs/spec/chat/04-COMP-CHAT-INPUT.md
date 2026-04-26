---
steering: TO PARSE — READ INTRO
file_name: 04-COMP-CHAT-INPUT.md
document_type: component_specification
module: Chat
tier: core
status: draft
owner: Trevor
description: Chat input component for composing and sending messages with support for slash commands, file uploads, and real-time audio recording.
last_updated: 2026-04-26
version: 1.0
dependencies: [04-COMP-CHAT.md, 01-PLAN-ZUSTAND.md, 02-ARCH-DATABASE.md]
related_adrs: [ADR_003, ADR_085]
related_rules: [XCT_01, XCT_02, g4, S1, S28]
complexity: medium
risk_level: low
---

# ChatInput — Component Specification

## 1. Purpose

### 1.1 What This Is
A comprehensive chat input component that handles message composition, sending, and interactive features. It supports text input, slash commands, file uploads, real-time audio recording, and integrates with the chat state management system.

### 1.2 User Story
As a user, I want to compose and send messages with rich features like slash commands and file uploads so that I can communicate effectively with the AI assistant.

### 1.3 Non-Goals
- Does NOT handle message rendering (that's MessageList's responsibility)
- Does NOT manage thread state directly (uses ChatSlice)
- Does NOT implement file processing/upload (delegated to upload service)
- Does NOT handle audio transcription (delegated to audio service)

## 2. UX States

### 2.1 State Catalog
| State ID | State Name | Trigger Condition | Visual Behavior | User Action Available |
|----------|------------|-------------------|-----------------|----------------------|
| S-IDLE | Idle | Component mounted, no active input | Normal input field with placeholder | Type, attach files, start audio |
| S-TYPING | Typing | User actively typing | Input focused, send button enabled | Send message, cancel typing |
| S-SENDING | Sending | Message being sent | Send button disabled, loading spinner | None |
| S-ATTACHING | Attaching | File upload in progress | Upload progress indicator | Cancel upload |
| S-ERROR | Error | Send failed, validation error | Error message, retry button | Retry, edit message |
| S-DISABLED | Disabled | Rate limited, network offline | Input disabled, error message | None |
| S-RECORDING | Recording | Audio recording active | Red recording indicator, timer | Stop recording |
| S-SLASH-MENU | Slash Menu | Slash command menu open | Overlay with command options | Select command, dismiss |

### 2.2 State Transition Diagram
S-IDLE → S-TYPING (on focus) → S-SENDING (on send) → S-IDLE (on success)
S-TYPING → S-SLASH-MENU (on typing /) → S-TYPING (on dismiss)
S-SENDING → S-ERROR (on failure) → S-TYPING (on retry)
S-ERROR → S-IDLE (on manual clear) → S-TYPING (on focus)
S-ATTACHING → S-TYPING (on complete) | S-ERROR (on failure)
S-RECORDING → S-TYPING (on stop) → S-RECORDING (on start)
S-DISABLED → S-IDLE (on reconnection)

### 2.3 DO NOT
- DO NOT allow sending when input is empty (unless it's a slash command)
- DO NOT show send button while message is being sent
- DO NOT allow file uploads larger than 10MB
- DO NOT auto-play audio recordings without user consent

## 3. Transitions & Animations

### 3.1 Motion Patterns Used
| Pattern | Lexicon Ref | Applied To | Duration/Spring | Notes |
|---------|-------------|------------|-----------------|-------|
| @M | MotionGuard | Input focus/blur, send button | — | Respects prefers-reduced-motion |
| @KS | KeyboardShortcuts | Slash menu navigation, send on Enter | — | Cmd+Enter to send, Escape to cancel |
| @OF | OpacityFade | Error/success states | ≤150ms | Quick feedback |
| @AP | AnimatePresence | Slash menu overlay | — | Smooth enter/exit |

### 3.2 DO NOT (HARD constraints from Lexicon)
- DO NOT animate input field height (causes layout thrashing). (Rule XCT_01)
- DO NOT use spring animations for sending (use fade only). (Rule g4)
- DO NOT animate when prefers-reduced-motion is active. Instant transition. (Rule g6)

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
  isRecording: boolean;
  recordingStartTime: number | null;
}
```

### 4.2 Database Tables Referenced
| Table | Columns Used | RLS Policy |
|-------|-------------|------------|
| messages | id, org_id, thread_id, user_id, content, created_at, updated_at, deleted_at | org_id = auth.jwt()->>org_id |
| media | id, org_id, thread_id, filename, content_type, size, created_at | org_id = auth.jwt()->>org_id |

### 4.3 API Payloads
#### Send Message
```json
{
  "thread_id": "string // ULID",
  "content": "string // message content",
  "attachments": ["string // media ULIDs"],
  "slash_command": "string // optional command"
}
```
#### Upload File
```json
{
  "file": "File // FormData",
  "thread_id": "string // ULID"
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
- thread_id: must be valid ULID
- attachments: array, max 5 files, each ≤10MB
- slash_command: string, max 100 chars, must match registered commands

## 5. Edge Cases & Error Handling

### 5.1 Edge Cases
| ID | Scenario | Expected Behavior | Test Verification |
|----|----------|-------------------|-------------------|
| EC-001 | Message > 50,000 chars | Show error toast, truncate with "..." | Send 50,001 char message |
| EC-002 | File upload > 10MB | Reject upload, show size error | Upload 11MB file |
| EC-003 | Rapid slash command typing | Debounced menu, no flicker | Type / rapidly |
| EC-004 | Audio recording while sending | Stop recording, show "Cannot record while sending" | Start recording during send |
| EC-005 | Network offline while typing | Queue message, show offline indicator | Go offline, type message, come online |
| EC-006 | Invalid slash command | Show "Unknown command" toast | Type /invalid_command |

### 5.2 Error Scenarios
| Error Code (ref: 05-XCT-ERROR-TAXONOMY.md) | Trigger | User Sees | System Does | Recovery |
|---------------------------------------------|---------|-----------|-------------|----------|
| VALIDATION_ERROR | Content too long/invalid | "Message format error" toast | 400 response | User must fix content |
| RATE_LIMITED | Too many messages | "Slow down" toast with countdown | 429 response | Wait for window |
| UPLOAD_FAILED | File upload error | "Upload failed" toast | Retry button | Retry upload |
| NETWORK_ERROR | Send fails | "Connection lost" banner | Retry with exponential backoff | Auto-retry 3x |
| AUDIO_PERMISSION_DENIED | Microphone access denied | "Microphone access denied" toast | Request permission | Request mic permission |

### 5.3 Race Conditions
- Message send while recording: Stop recording, send message, restart recording option.
- File upload completion while typing: Show upload success, clear typing state.
- Slash command execution while sending: Queue command, execute after send completes.

## 6. Acceptance Criteria

### 6.1 Functional
- [ ] All 8 UX states render correctly
- [ ] Text input handles multi-line with Shift+Enter
- [ ] Cmd+Enter sends message, Enter newlines
- [ ] Slash commands trigger menu overlay
- [ ] File upload shows progress and handles errors
- [ ] Audio recording shows timer and controls
- [ ] Input grows to max 4 lines, then scrolls

### 6.2 Performance
- [ ] Input responsiveness ≤ 16ms (60fps)
- [ ] File upload progress updates ≤ 100ms
- [ ] Slash menu appears ≤ 50ms after typing /
- [ ] Audio recording latency ≤ 200ms

### 6.3 Accessibility (mandatory for all UI specs)
- [ ] WCAG 2.2 AA: keyboard navigation functional
- [ ] WCAG 2.2 AA: screen reader announces all state changes
- [ ] WCAG 2.2 AA: focus order is logical
- [ ] prefers-reduced-motion: all animations disabled
- [ ] High contrast mode: colors meet 4.5:1 ratio

### 6.4 Security (cross-reference Domain E)
- [ ] CSP: no inline scripts introduced
- [ ] RLS: all queries scoped to org_id
- [ ] Input: all message content passes through SanitizedHTML with RICH profile

## 7. Accessibility

### 7.1 ARIA Roles & Labels
| Element | Role | aria-label | Notes |
|---------|------|------------|-------|
| Input field | textbox | "Message input" | Multiline, auto-grow |
| Send button | button | "Send message" | Disabled when sending |
| Attach button | button | "Attach file" | Opens file picker |
| Record button | button | "Start recording" | Toggle recording state |
| Slash menu | dialog | "Available commands" | aria-live="polite" |

### 7.2 Keyboard Navigation
| Key | Action | Notes |
|-----|--------|-------|
| Tab | Move to next interactive element | |
| Enter | Send message (if not in slash menu) | |
| Shift+Enter | New line in input | |
| Escape | Cancel slash menu, stop recording | |
| / | Open slash command menu | |
| Arrow Up/Down | Navigate slash menu | |
| Space | Trigger slash menu autocomplete | |

### 7.3 Screen Reader Announcements
| Event | aria-live Region | Message |
|-------|-----------------|---------|
| Message sent | polite | "Message sent" |
| File uploaded | polite | "File uploaded successfully" |
| Recording started | assertive | "Recording started" |
| Error occurred | assertive | "Error: [message]" |

### 7.4 DO NOT
- DO NOT use placeholder text that sounds like system messages.
- DO NOT auto-focus input on component mount (respect user flow).
- DO NOT play recording sounds without user consent.

## 8. Testing Strategy

### 8.1 Unit Tests (Vitest)
| Test | What It Verifies | Target Coverage |
|------|-----------------|-----------------|
| ChatInput renders idle state | Input field, send button enabled | |
| ChatInput handles typing | Input grows, send button enabled | |
| ChatInput sends message | API call, optimistic update | |
| ChatInput handles slash commands | Menu appears, command execution | |
| ChatInput handles file upload | Progress indicator, error handling | |
| ChatInput handles audio recording | Recording controls, timer display | |

### 8.2 Component Tests (Vitest + Testing Library)
| Test | What It Verifies |
|------|-----------------|
| Keyboard shortcuts work | Cmd+Enter sends, / opens menu | |
| Input auto-grow behavior | Height increases with content | |
| File upload validation | Size limits, type checking | |
| Recording permission flow | Permission request, denial handling | |

### 8.3 Integration Tests (Playwright for critical flows)
| Flow | Steps |
|------|-------|
| Send message flow | Type message → press Cmd+Enter → verify sent | |
| Upload file flow | Click attach → select file → upload → verify attached | |
| Slash command flow | Type / → select command → execute → verify result | |
| Audio recording flow | Click record → speak → stop → verify recording saved |

### 8.4 Security Tests (pgTAP, CSP, Schemathesis)
| Test | Rule Reference |
|------|---------------|
| RLS: tenant isolation | TESTC_04, S5 |
| CSP: no inline scripts | S6 |
| Input validation: XSS prevention | TESTC_04, S1 |
| File upload security | ClamAV integration | S27 |

### 8.5 Test Data Requirements
- Message factory with different content types
- File factory for upload testing
- Slash command factory for command testing
- Audio recording mock for permission testing

## 9. Risks & Open Questions

### 9.1 Risks
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Performance with large file uploads | Medium | High | Chunked uploads, progress indicators |
| Audio recording permissions | Low | Medium | Clear permission UI, fallback to text |
| XSS via message content | Low | High | DOMPurify RICH profile, CSP enforcement |
| Memory leaks with audio streams | Low | Medium | Proper cleanup in useEffect |

### 9.2 Open Questions
- Should input support markdown formatting? → Target resolution: Phase 1.1
- Should file uploads support drag-and-drop? → Target resolution: Phase 1.2
- How should slash commands be discovered? → Target resolution: Design review
- Should audio recording support transcription? → Target resolution: Phase 2

### 9.3 Assumptions
- All message content is plain text or sanitized HTML
- File uploads are processed asynchronously
- Audio recording uses Web Audio API with permission checks
- Slash commands are registered server-side
- Input field supports up to 4 lines of text
