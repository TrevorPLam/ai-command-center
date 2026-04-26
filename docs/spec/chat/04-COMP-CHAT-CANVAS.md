---
steering: TO PARSE — READ INTRO
file_name: 04-COMP-CHAT-CANVAS.md
document_type: component_specification
module: Chat
tier: core
status: draft
owner: Trevor
description: Collaborative canvas component for visual collaboration, drawing, and real-time shared editing within chat threads.
last_updated: 2026-04-26
version: 1.0
dependencies: [04-COMP-CHAT.md, 01-PLAN-ZUSTAND.md, 02-ARCH-DATABASE.md]
related_adrs: [ADR_003, ADR_085]
related_rules: [XCT_01, XCT_02, g4, S1, S28]
complexity: high
risk_level: medium
---

# CollabCanvas — Component Specification

## 1. Purpose

### 1.1 What This Is
A real-time collaborative canvas component that enables visual collaboration within chat threads. It supports drawing, shapes, text, images, and multi-user cursor tracking with WebSocket-based synchronization.

### 1.2 User Story
As a user, I want to collaborate visually with others in a shared canvas so that we can brainstorm, diagram, and create visual content together in real-time.

### 1.3 Non-Goals
- Does NOT handle file uploads (delegated to upload service)
- Does NOT implement advanced image editing (Phase 2 feature)
- Does NOT support video/audio embedding (Phase 2 feature)
- Does NOT handle canvas export (Phase 1.1 feature)

## 2. UX States

### 2.1 State Catalog
| State ID | State Name | Trigger Condition | Visual Behavior | User Action Available |
|----------|------------|-------------------|-----------------|----------------------|
| S-LOADING | Loading | Canvas data fetching | Loading spinner, canvas placeholder | None |
| S-EMPTY | Empty | New canvas, no content | Blank canvas with toolbar | Draw, add shapes, add text |
| S-DRAWING | Drawing | User actively drawing | Canvas with drawing tools active | Draw, change tool, undo/redo |
| S-SHARED | Shared | Multiple users active | Other user cursors visible | Collaborate, see changes |
| S-ERROR | Error | Sync failed, network error | Error overlay, retry button | Retry, refresh |
| S-READONLY | Read-only | User lacks edit permission | Canvas visible, tools disabled | View only |

### 2.2 State Transition Diagram
S-LOADING → S-EMPTY | S-DRAWING | S-ERROR
S-EMPTY → S-DRAWING (on first action)
S-DRAWING → S-SHARED (on other user join)
S-SHARED → S-DRAWING (on other user leave)
S-ERROR → S-LOADING (on retry)
S-DRAWING → S-READONLY (on permission change)

### 2.3 DO NOT
- DO NOT allow drawing without proper permissions
- DO NOT auto-save without user action (manual save only)
- DO NOT show other users' cursors when offline

## 3. Transitions & Animations

### 3.1 Motion Patterns Used
| Pattern | Lexicon Ref | Applied To | Duration/Spring | Notes |
|---------|-------------|------------|-----------------|-------|
| @M | MotionGuard | Tool selection, cursor movement | — | Respects prefers-reduced-motion |
| @KS | KeyboardShortcuts | Tool shortcuts, canvas navigation | — | V for select, D for draw, etc. |
| @OF | OpacityFade | Tool panel, error states | ≤150ms | Quick feedback |
| @AP | AnimatePresence | Tool panel enter/exit | — | Smooth panel transitions |

### 3.2 DO NOT (HARD constraints from Lexicon)
- DO NOT animate canvas content (causes performance issues). (Rule XCT_01)
- DO NOT use spring animations for cursor movement (use instant). (Rule g4)
- DO NOT animate when prefers-reduced-motion is active. Instant transitions. (Rule g6)

## 4. Data Shapes

### 4.1 Zustand Slice
Reference: 01-PLAN-ZUSTAND-TYPES.md ChatSlice
```typescript
interface ChatSlice {
  activeThreadId: string | null;
  threads: Record<string, Thread>;
  messages: Record<string, Message[]>;
  canvases: Record<string, Canvas>;
  activeTool: 'select' | 'draw' | 'text' | 'shape' | 'image';
  canvasPermissions: Record<string, 'read' | 'write' | 'admin'>;
}
```

### 4.2 Database Tables Referenced
| Table | Columns Used | RLS Policy |
|-------|-------------|------------|
| canvases | id, org_id, thread_id, content, created_at, updated_at | org_id = auth.jwt()->>org_id |
| canvas_elements | id, canvas_id, type, data, created_at, user_id | org_id = auth.jwt()->>org_id |

### 4.3 API Payloads
#### Canvas Element
```json
{
  "id": "string // ULID",
  "type": "string // 'path'|'rect'|'circle'|'text'|'image'",
  "data": "object // element-specific data",
  "user_id": "string // creator ULID",
  "created_at": "string // ISO timestamp"
}
```
#### WebSocket Message
```json
{
  "type": "string // 'element_add'|'element_update'|'cursor_move'",
  "canvas_id": "string",
  "payload": "object // message-specific data"
}
```

### 4.4 Validation Rules
- element type: must be one of allowed types
- element data: sanitized based on type
- canvas permissions: checked against user role

## 5. Edge Cases & Error Handling

### 5.1 Edge Cases
| ID | Scenario | Expected Behavior | Test Verification |
|----|----------|-------------------|-------------------|
| EC-001 | 1000+ canvas elements | Virtualization, performance optimization | Add 1000 elements |
| EC-002 | Concurrent editing conflicts | Last-writer-wins with conflict UI | Two users edit same element |
| EC-003 | Network interruption | Queue changes, sync on reconnect | Disconnect during drawing |
| EC-004 | Canvas size limits | Clamp to max dimensions, show warning | Create oversized canvas |
| EC-005 | Invalid element data | Reject element, show error | Send malformed element |

### 5.2 Error Scenarios
| Error Code | Trigger | User Sees | System Does | Recovery |
|------------|---------|-----------|-------------|----------|
| CANVAS_NOT_FOUND | Invalid canvas ID | "Canvas not found" error | 404 response | Navigate back |
| PERMISSION_DENIED | User lacks write access | Read-only mode | Disable tools | Request permission |
| SYNC_ERROR | WebSocket connection lost | "Connection lost" banner | Reconnect attempt | Auto-retry 3x |
| ELEMENT_TOO_LARGE | Element exceeds size limit | "Element too large" toast | Reject element | Resize element |

### 5.3 Race Conditions
- Element creation while syncing: Queue creation, apply after sync.
- Tool change while drawing: Finish current stroke, then change tool.
- Permission change while editing: Revoke edit access, save current state.

## 6. Acceptance Criteria

### 6.1 Functional
- [ ] All 6 UX states render correctly
- [ ] Drawing tools work smoothly (pen, shapes, text)
- [ ] Real-time collaboration shows other users' cursors
- [ ] Undo/redo functionality works
- [ ] Canvas persists across page refreshes
- [ ] Permission system controls edit access

### 6.2 Performance
- [ ] Canvas rendering ≥ 30fps with 100 elements
- [ ] Cursor position updates ≤ 50ms
- [ ] Element creation ≤ 100ms
- [ ] Memory usage ≤ 10MB per canvas

### 6.3 Accessibility
- [ ] WCAG 2.2 AA: keyboard navigation functional
- [ ] WCAG 2.2 AA: screen reader announces tool changes
- [ ] prefers-reduced-motion: animations disabled

### 6.4 Security
- [ ] CSP: no inline scripts
- [ ] RLS: all queries scoped to org_id
- [ ] Input: all element data sanitized

## 7. Accessibility

### 7.1 ARIA Roles & Labels
| Element | Role | aria-label | Notes |
|---------|------|------------|-------|
| Canvas | application | "Collaborative canvas" | |
| Tool panel | toolbar | "Drawing tools" | |
| Tool button | button | "[Tool name] tool" | aria-pressed state |
| Color picker | combobox | "Color selection" | |

### 7.2 Keyboard Navigation
| Key | Action | Notes |
|-----|--------|-------|
| Tab | Navigate tools/elements | |
| Enter | Select tool/element | |
| Arrow keys | Move selected element | |
| Delete | Remove selected element | |
| Ctrl+Z | Undo | |
| Ctrl+Y | Redo | |
| Escape | Deselect, exit mode | |

### 7.3 Screen Reader Announcements
| Event | aria-live Region | Message |
|-------|-----------------|---------|
| Tool changed | polite | "Selected: [tool name]" |
| Element added | polite | "Added [element type]" |
| User joined | polite | "[Username] joined canvas" |
| Error occurred | assertive | "Error: [message]" |

## 8. Testing Strategy

### 8.1 Unit Tests
- CollabCanvas renders empty state
- CollabCanvas handles tool selection
- CollabCanvas processes element creation
- CollabCanvas manages undo/redo stack

### 8.2 Component Tests
- Drawing interactions work
- Tool panel navigation
- Permission restrictions
- Error state handling

### 8.3 Integration Tests
- Real-time collaboration flow
- WebSocket message handling
- Canvas persistence
- Multi-user conflict resolution

### 8.4 Security Tests
- Element data sanitization
- Permission enforcement
- RLS compliance

## 9. Risks & Open Questions

### 9.1 Risks
- Performance with many elements (mitigated by virtualization)
- Data corruption during sync (mitigated by conflict resolution)
- XSS via malicious element data (mitigated by sanitization)
- High memory usage (mitigated by element limits)

### 9.2 Open Questions
- Should canvas support layers? → Phase 1.2
- Should users be able to comment on elements? → Phase 1.1
- How should version history be handled? → Phase 2
- Should canvas support templates? → Phase 1.2

### 9.3 Assumptions
- WebSocket connection is reliable
- All users have compatible browsers
- Canvas size is limited to reasonable dimensions
- Element data is JSON-serializable
