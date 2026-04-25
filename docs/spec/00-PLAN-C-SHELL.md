---
steering: TO PARSE - READ INTRO
document_type: component_specification
module: Shell
tier: core
component_count: 11
dependencies:
- ~l/* (layout components)
- ~providers/*
- orgSlice
- uiSlice
motion_requirements:
- @M (MotionGuard)
- @AP (AnimatePresence)
- @AS (Spring animations)
- @Q (OpacityFade)
accessibility:
- WCAG 2.2 AA compliance
- Focus restoration
- Keyboard navigation
- Screen reader support
performance:
- LCP optimization
- Minimal bundle size
last_updated: 2026-04-25
version: 1.0
---

# C Components|name|mod|type|pats|rules|deps(non-local)|notes
// Shell
AppShell|F|Layout|@M,AP|g8+g20+g21|~l/*,~providers/*|SkipLink,AP
Sidebar|F|Nav|@M,AS|g5+g9+g10+B1|~s/orgSlice|layoutId pill
OrgSwitcher|F|Control|-|-|~s/orgSlice|refreshSession
StatusBar|F|Info|@M|g21|-|fixed bottom
RightPanel|F|Panel|@M,Q|g8+FT|~s/uiSlice|close→focus restore
CommandPalette|F|Overlay|@M,AS|g8+g9+g20+FT|useIntentHandler+cmdk|portal,role=combobox
VoiceShell|F|Input|@M,AS|g9+g10+g20+g24+FT|useWebSpeech|Ctrl+Space
Toaster|F|Feedback|-|-|snn+g29|sonner max3
MetaTitle|F|Meta|-|-|HelmetProvider+rha|per-route
NuqsAdapter|F|Util|-|-|Router|-
LiveKitProvider|F|Provider|-|-|-|wraps conf routes
