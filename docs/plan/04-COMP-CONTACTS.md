---
steering: TO PARSE - READ INTRO
file_name: 04-COMP-CONTACTS.md
document_type: component_specification
module: Contacts
tier: feature
status: stable
owner: Product Engineering
component_count: 11
dependencies:
- ~s/contactsSlice
motion_requirements:
- @M (MotionGuard)
- @AP (AnimatePresence)
- @E (InlineEdit)
- @O (OptimisticMutation)
accessibility:
- WCAG 2.2 AA compliance
- Keyboard navigation
- Screen reader support
performance:
- Contact search optimization
- Privacy field handling
last_updated: 2026-04-25
version: 1.0
dependencies: [01-PLAN-LEXICON.md, 04-COMP-SHELL.md]
related_adrs: []
related_rules: [g10, g27]
complexity: medium
risk_level: medium
---

# C Components|name|mod|type|pats|rules|deps(non-local)|notes
// Contacts
ContactsPage|K|Page|@M,AP|-|~s/contactsSlice|quick add
ContactDetail|K|Detail|@E,@O|-|-|privacy badges
ContactField|K|Field|@E|-|-|field-level privacy
QuickAddModal|K|Modal|@M,Q|-|-|auto-enrich
ContactAutocomplete|K|Autocomplete|@K|-|-|recent first
EnrichmentPanel|K|Panel|@Q-ui|-|-|bulk
RelationshipGraph|K|Graph|@M,AS|-|-|zoom,pan,WCAG alt
RelationshipGraphTableView|K|Table|-|-|-|WCAG B11
CommunicationTimeline|K|Timeline|@V|-|-|quick actions
TagManager|K|Manager|-|-|-|auto-tag
ImportExportDialog|K|Dialog|@IMPORT|-|-|duplicate handling
WorkflowAutomation|K|Workflow|@W|-|-|pre-built templates
