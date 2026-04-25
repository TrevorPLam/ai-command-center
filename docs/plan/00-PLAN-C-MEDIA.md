---
steering: TO PARSE - READ INTRO
document_type: component_specification
module: Media
tier: feature
component_count: 6
dependencies:
- ~s/mediaSlice
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
- AI alt text
performance:
- Infinite scroll
- Progressive loading
last_updated: 2026-04-25
version: 1.0
---

# C Components|name|mod|type|pats|rules|deps(non-local)|notes
// Media
MediaPage|M|Page|@L,AP|-|~s/mediaSlice|grid/list/timeline
MediaCard|M|Card|@O,Q|-|-|progressive,alt text
MediaGrid|M|Grid|@V|-|-|infinite
GenerationPanel|M|Panel|@Q-ui,@SS,AS|-|-|cancel/retry
MediaDetailDrawer|M|Drawer|@M,Q|-|-|image editor
StorageAnalytics|M|Analytics|-|-|-|quota warnings
