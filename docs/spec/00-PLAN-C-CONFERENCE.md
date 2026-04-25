---
steering: TO PARSE - READ INTRO
document_type: component_specification
module: Conference
tier: feature
component_count: 7
dependencies:
- lkc (livekit-client)
- lkr (livekit-react)
motion_requirements:
- @L (LiquidGlass)
- @AP (AnimatePresence)
- @M (MotionGuard)
- @AS (Spring animations)
accessibility:
- WCAG 2.2 AA compliance
- Keyboard navigation
- Screen reader support
performance:
- Video optimization
- Grid layout optimization
last_updated: 2026-04-25
version: 1.0
---

# C Components|name|mod|type|pats|rules|deps(non-local)|notes
// Conference
ConferencePage|CF|Page|@L,AP|-|lkc+lkr|LKProvider
RoundtableGrid|CF|Grid|@M,AS|-|-|4-16 participants
ParticipantTile|CF|Tile|@M|-|-|quality indicator
RecordingControls|CF|Controls|@M,AS|-|-|pulsing red
EngagementTools|CF|Tools|-|-|-|LK DataChannels
ScenarioTemplates|CF|Templates|-|-|-|role assign
BreakoutRooms|CF|Rooms|@W|-|-|auto-return
