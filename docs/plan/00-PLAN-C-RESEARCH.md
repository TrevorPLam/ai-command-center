---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-C-RESEARCH.md
document_type: component_specification
module: Research
tier: feature
status: stable
owner: Product Engineering
component_count: 6
dependencies:
- ~s/researchSlice
- markmap
- yjs
motion_requirements:
- @L (LiquidGlass)
- @AP (AnimatePresence)
- @M (MotionGuard)
- @AS (Spring animations)
- @AG (StaggerChildren)
accessibility:
- WCAG 2.2 AA compliance
- Keyboard navigation
- Screen reader support
- Mind map alt text
performance:
- Multi-format support
- FSRS optimization
last_updated: 2026-04-25
version: 1.0
dependencies: [00-PLAN-1-INTRO.md, 00-PLAN-C-SHELL.md]
related_adrs: [ADR_008]
related_rules: [g10]
complexity: medium
risk_level: medium
---

# C Components|name|mod|type|pats|rules|deps(non-local)|notes
// Research
ResearchPage|R|Page|@L,AP|-|~s/researchSlice|multi-format
MindMapEditor|R|Editor|@M,AS|-|markmap,yjs|collab,WCAG alt
FlashcardDeck|R|Deck|@M,AG|-|-|FSRS
LearningGuide|R|Guide|@SS|-|-|streaming
AudioOverview|R|Overview|@M,AS|-|-|waveform
ReportGenerator|R|Generator|@O|-|-|PDF/MD
