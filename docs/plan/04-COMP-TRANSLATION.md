---
steering: TO PARSE - READ INTRO
file_name: 04-COMP-TRANSLATION.md
document_type: component_specification
module: Translation
tier: feature
status: stable
owner: Product Engineering
component_count: 6
dependencies:
- ~s/translationSlice
motion_requirements:
- @L (LiquidGlass)
- @AP (AnimatePresence)
- @M (MotionGuard)
- @O (OptimisticMutation)
- @Q (OpacityFade)
- @S (Static)
accessibility:
- WCAG 2.2 AA compliance
- Keyboard navigation
- Screen reader support
performance:
- Split screen optimization
- Language detection
last_updated: 2026-04-25
version: 1.0
dependencies: [01-PLAN-LEXICON.md, 04-COMP-SHELL.md]
related_adrs: []
related_rules: [g10, g27]
complexity: medium
risk_level: medium
---

# C Components|name|mod|type|pats|rules|deps(non-local)|notes
// Translation
TranslationPage|T|Page|@L,AP|-|~s/translationSlice|mobile Sheet
SpeakerManager|T|Manager|@M,@O,Q|-|-|staggered
SplitScreenView|T|View|@S|-|-|language badges
TranslationSegment|T|Segment|@M,AG|-|-|streaming
SessionControls|T|Controls|@O,AS|-|-|optimistic status
StreamingHook|T|Hook|@SS,AS|-|~h/useStreaming|retry 3×
