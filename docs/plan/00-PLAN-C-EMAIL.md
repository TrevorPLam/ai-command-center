---
steering: TO PARSE - READ INTRO
document_type: component_specification
module: Email
tier: feature
component_count: 12
dependencies:
- ~s/emailSlice
- rrp (react-resizable-panels)
motion_requirements:
- @M (MotionGuard)
- @AP (AnimatePresence)
- @O (OptimisticMutation)
- @V (VirtualizeList)
accessibility:
- WCAG 2.2 AA compliance
- Keyboard navigation
- Screen reader support
performance:
- Virtualization for email lists
- Resizable panels
last_updated: 2026-04-25
version: 1.0
---

# C Components|name|mod|type|pats|rules|deps(non-local)|notes
// Email
EmailPage|E|Page|@M,AP|-|~s/emailSlice,rrp|resizable panels
UnifiedInbox|E|List|@V|-|-|account color
EmailListItem|E|Item|@O|-|-|bulk select
ThreadView|E|View|@M|dp+g15|-|expand/collapse older
ComposeWindow|E|Window|@M,Q|FT|rta+dp|sched send,undo
AccountSidebar|E|Sidebar|@K|dnd+B3|-|drag-to-folder
SnoozeModal|E|Modal|@R|-|-|snoozed folder
AttachmentViewer|E|Viewer|-|dp|-|size limits
EmailRules|E|Rules|-|-|-|import/export
TemplatesSignatures|E|Templates|@O|-|-|canned
VacationResponder|E|Responder|-|-|-|once-per-sender
AgentEmailComposer|E|Composer|-|-|-|POST /v1/email/send
