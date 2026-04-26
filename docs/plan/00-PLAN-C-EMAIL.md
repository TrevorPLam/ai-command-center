---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-C-EMAIL.md
document_type: component_specification
module: Email
tier: feature
status: stable
owner: Product Engineering
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
dependencies: [00-PLAN-1-INTRO.md, 00-PLAN-C-SHELL.md]
related_adrs: [ADR_011]
related_rules: [g10, g27]
complexity: medium
risk_level: medium
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
