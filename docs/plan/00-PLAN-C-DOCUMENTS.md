---
steering: TO PARSE - READ INTRO
document_type: component_specification
module: Documents
tier: feature
component_count: 9
dependencies:
- ~s/documentsSlice
motion_requirements:
- @L (LiquidGlass)
- @AP (AnimatePresence)
- @O (OptimisticMutation)
- @Q (OpacityFade)
- @V (VirtualizeList)
accessibility:
- WCAG 2.2 AA compliance
- Keyboard navigation
- Screen reader support
performance:
- Document grid optimization
- Drag and drop upload
last_updated: 2026-04-25
version: 1.0
---

# C Components|name|mod|type|pats|rules|deps(non-local)|notes
// Documents
DocumentsPage|DC|Page|@L,AP|-|~s/documentsSlice|grid/list/gallery
DocumentCard|DC|Card|@O,Q|-|-|progressive
DocumentGrid|DC|Grid|@V|-|-|dnd upload
UploadManager|DC|Manager|@U|-|-|size validation
FilePreview|DC|Preview|@M,AS|-|-|kbd nav
ShareDialog|DC|Dialog|@M,Q|-|-|-
AIPanel|DC|Panel|@SS|-|-|streaming
VersionHistory|DC|History|-|-|-|-
RealTimeCoEdit|DC|CoEdit|@C|-|yjs,ysc|opt-in
