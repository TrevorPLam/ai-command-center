# TODO.md — AI Command Center Specification Audit & Remediation Task Index

> **Generated**: 2026-04-23  
> **Status**: Split into phase-specific files  
> **Purpose**: Main index for all specification audit and remediation tasks.  
> **Structure**: Tasks are organized by phase into separate files for better maintainability.

---

## 📋 Task File Index

### 🔴 Phase 1: Critical Cross-Document Corrections (Must Do First)
**File**: [TODO-Critical.md](TODO-Critical.md)  
**Status**: ✅ All tasks completed  
**Tasks**: TASK-001, TASK-002, TASK-003  
**Focus**: Phantom ID fixes, Plan alignment, centralized IndexedDB

### 🟠 Phase 2: Shared Infrastructure Extraction  
**File**: [TODO-Core.md](TODO-Core.md)  
**Status**: ✅ All tasks completed  
**Tasks**: TASK-004, TASK-005, TASK-006  
**Focus**: Shared recurrence engine, SanitizedHTML component, optimistic mutations

### 🟠 Phase 3: Accessibility Compliance
**File**: [TODO-Remaining.md](TODO-Remaining.md#-phase-3-accessibility-compliance)  
**Status**: 🟡 Most tasks pending  
**Tasks**: TASK-007, TASK-008  
**Focus**: WCAG 2.5.7 alternatives, screen reader announcements

### 🟡 Phase 4: Missing Infrastructure
**File**: [TODO-Remaining.md](TODO-Remaining.md#-phase-4-missing-infrastructure)  
**Status**: 🟡 All tasks pending  
**Tasks**: TASK-009, TASK-010, TASK-011, TASK-012  
**Focus**: Authentication, notifications, route map, seed data

### 🟡 Phase 5: Performance and Production Readiness
**File**: [TODO-Remaining.md](TODO-Remaining.md#-phase-5-performance-and-production-readiness)  
**Status**: 🟡 All tasks pending  
**Tasks**: TASK-013, TASK-014  
**Focus**: Code splitting, SSE testing utilities

### 🟢 Phase 6: Quality and Polish
**File**: [TODO-Remaining.md](TODO-Remaining.md#-phase-6-quality-and-polish)  
**Status**: 🟡 All tasks pending  
**Tasks**: TASK-015, TASK-016, TASK-017  
**Focus**: Shared UI components, E2E scenarios, cache invalidation

---

## 🎯 Quick Status Overview

| Phase | File | Completed | Total | Status |
|-------|------|-----------|-------|--------|
| 🔴 Phase 1 | TODO-Critical.md | 3/3 | 100% | ✅ Done |
| 🟠 Phase 2 | TODO-Core.md | 3/3 | 100% | ✅ Done |
| 🟠 Phase 3 | TODO-Remaining.md | 0/2 | 0% | 🟡 Pending |
| 🟡 Phase 4 | TODO-Remaining.md | 0/4 | 0% | 🟡 Pending |
| 🟡 Phase 5 | TODO-Remaining.md | 0/2 | 0% | 🟡 Pending |
| 🟢 Phase 6 | TODO-Remaining.md | 0/3 | 0% | 🟡 Pending |
| **Overall** | **All Files** | **6/17** | **35%** | **🟡 In Progress** |

---

## 📊 Task Dependency Graph

```text
Phase 1 (Critical) → Phase 2 (Core) → Phase 3-6 (Remaining)
     ↓                    ↓              ↓
  TASK-001            TASK-004        TASK-007-017
  TASK-002            TASK-005
  TASK-003            TASK-006
```

**Key Dependencies**:
- All phases depend on TASK-001 (phantom IDs)
- Phase 3 depends on Phase 1 completion
- Phase 4-6 can proceed independently after Phases 1-2

---

## 🔎 Placeholder Key

| Placeholder | Meaning |
|-------------|---------|
| `[VERIFY: <statement>]` | Claim must be confirmed against live code/specs before execution. |
| `[CHECK PATH: <path>]` | File or directory existence must be verified; update path if necessary. |
| `[CONFIRM ID: <id>]` | Task/component ID must exist in the canonical registry. |
| `[IMPLEMENT: <description>]` | Implementation details may need adjustment after the check; adapt accordingly. |
| `[UPDATE IF: <condition>]` | Action might be conditional; verify condition before proceeding. |

Each placeholder is **blocking** — do not proceed past it until resolved.

---

## 📁 File Structure

```text
TODO.md                 # This index file
├── TODO-Critical.md     # Phase 1: Critical corrections (completed)
├── TODO-Core.md         # Phase 2: Shared infrastructure (completed)
└── TODO-Remaining.md   # Phases 3-6: Remaining work (pending)
```

---

## 🔄 Migration Notes

- **Original file**: `TODO.md.bak` (backup of full task list)
- **Split completed**: 2026-04-23
- **Reason**: Better maintainability and focused work per phase
- **Cross-references**: All files link back to this index

---

## 📝 Working with Split Files

1. **Start here**: Review the status overview above
2. **Pick a phase**: Navigate to the appropriate file
3. **Check dependencies**: Ensure prerequisite phases are complete
4. **Resolve placeholders**: Address all `[VERIFY]` tags before execution
5. **Update status**: Mark tasks complete as you work

---

## 🏁 Completion Criteria

All phases are complete when:
- [x] Phase 1-2: Already completed ✅
- [ ] Phase 3: WCAG compliance implemented
- [ ] Phase 4: Missing infrastructure specified
- [ ] Phase 5: Performance optimizations documented
- [ ] Phase 6: Quality and polish specified

**Final Goal**: 100% task completion across all phases
