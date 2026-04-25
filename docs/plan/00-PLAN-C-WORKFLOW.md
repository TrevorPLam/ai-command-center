---
steering: TO PARSE - READ INTRO
document_type: component_specification
module: Workflow
tier: core
component_count: 8
dependencies:
- rf (reactflow)
- ~s/workflowSlice
motion_requirements:
- @A (Animations)
- @M (MotionGuard)
- @AS (Spring animations)
accessibility:
- WCAG 2.2 AA compliance
- Keyboard navigation
- Screen reader support
performance:
- Canvas optimization
- Snap-to-grid
last_updated: 2026-04-25
version: 1.0
---

# C Components|name|mod|type|pats|rules|deps(non-local)|notes
// Workflow
WorkflowCanvas|W|Canvas|@A,@M,AS|FT+B3|rf,~s/workflowSlice|snap-to-grid
NodePalette|W|Palette|-|B3|rf|grouped
ExecutionViewer|W|Viewer|@M,AS|-|useMotionValue,~s/workflowSlice|blue pulse
ExecutionLog|W|Log|@V|-|-|filter
ApprovalPanel|W|Panel|@O|-|~s/workflowSlice|escalate
ManualInputDialog|W|Dialog|@M,Q|FT+zod|-|zod validation
TemplateLibrary|W|Library|-|-|-|param substitution
PerformanceMetrics|W|Metrics|-|g26|-|mock
