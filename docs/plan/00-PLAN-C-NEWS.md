---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-C-NEWS.md
document_type: component_specification
module: News
tier: feature
status: stable
owner: Product Engineering
component_count: 6
dependencies:
- ~s/newsSlice
motion_requirements:
- @L (LiquidGlass)
- @AP (AnimatePresence)
- @O (OptimisticMutation)
- @V (VirtualizeList)
- @I (InfiniteScroll)
- @H (HoverPrefetch)
accessibility:
- WCAG 2.2 AA compliance
- Keyboard navigation
- Screen reader support
performance:
- Virtualization for news feeds
- Infinite scroll
last_updated: 2026-04-25
version: 1.0
dependencies: [00-PLAN-1-INTRO.md, 00-PLAN-C-SHELL.md]
related_adrs: []
related_rules: [g10, g27]
complexity: medium
risk_level: medium
---

# C Components|name|mod|type|pats|rules|deps(non-local)|notes
// News
NewsPage|N|Page|@L,AP|-|~s/newsSlice|pause/dedup
NewsFeed|N|Feed|@V,@I|-|-|filter tabs
NewsCard|N|Card|@O,@H|-|-|expand/collapse,WebShare
SentimentDot|N|Dot|@M,Q|-|-|WCAG 1.4.1
ArticleReaderPanel|N|Panel|@M,AS|-|-|progress bar
AudioPlayer|N|Player|@M,AS|-|-|voice selector
