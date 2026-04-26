---
steering: TO PARSE - READ INTRO
file_name: 04-COMP-SETTINGS.md
document_type: component_specification
module: Settings
tier: feature
status: stable
owner: Product Engineering
component_count: 12
dependencies:
- ~s/settingsSlice
- rhf (react-hook-form)
- hr (hookform-resolvers)
- zod
motion_requirements:
- @M (MotionGuard)
- @AP (AnimatePresence)
- @E (InlineEdit)
accessibility:
- WCAG 2.2 AA compliance
- Keyboard navigation
- Screen reader support
performance:
- Form optimization
- Live preview
last_updated: 2026-04-25
version: 1.0
dependencies: [01-PLAN-LEXICON.md, 04-COMP-SHELL.md]
related_adrs: []
related_rules: [g10, g27]
complexity: medium
risk_level: medium
---

# C Components|name|mod|type|pats|rules|deps(non-local)|notes
// Settings
SettingsPage|S|Page|@M,AP|-|~s/settingsSlice|kbd nav
GeneralSettings|S|Form|@E|-|rhf+hr+zod|-
AppearanceSettings|S|Form|@M|-|-|live preview
NotificationSettings|S|Form|-|-|-|Zod refinement
ApiKeysSettings|S|Form|-|-|-|security
MemorySettings|S|Form|@MEM|-|-|-
IntegrationsSettings|S|Form|@O|-|-|-
ExportImportPage|S|Page|@U|-|-|GDPR notice
DangerZone|S|Zone|-|-|-|typed confirmation
StorageQuotaIndicator|S|Indicator|-|-|-|useStorageQuota
CostDashboard|S|Dashboard|-|-|-|budget,alerts
MCPSettings|S|Settings|@MCP_APPROVAL|-|-|discover,test,approve
