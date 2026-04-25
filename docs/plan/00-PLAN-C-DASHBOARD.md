---
steering: TO PARSE - READ INTRO
document_type: component_specification
module: Dashboard
tier: core
component_count: 8
dependencies:
- useAgentStatus
- LayoutGroup
motion_requirements:
- @M (MotionGuard)
- @AP (AnimatePresence)
- @AG (StaggerChildren)
- @O (OptimisticMutation)
accessibility:
- WCAG 2.2 AA compliance
- Screen reader support
- Keyboard navigation
performance:
- LCP optimization
- Grid layout optimization
last_updated: 2026-04-25
version: 1.0
---

# C Components|name|mod|type|pats|rules|deps(non-local)|notes
// Dashboard
AmbientStatusBanner|D|Banner|@M,AP|g4|useAgentStatus|dismiss→localStorage
AgentFleetPanel|D|Grid|@M,AG|-|LayoutGroup|layoutId morph
AgentCard|D|Card|@O,AG|g2|-|role=button
ActivityFeed|D|Feed|@V|-|-|role=log,aria-live=polite
ActivityEntry|D|Entry|@M,AG|-|-
AttentionQueue|D|Queue|@P,@O,@V,AS|-|-|inject RightPanel
DecisionPacket|D|Packet|@O,Q|-|useMotionValue|skipInitialAnim
AgentDetailDrawer|D|Drawer|@M,AS|g8+FT+B1|~s/uiSlice|layoutScroll
