---
title: "Component Overview"
owner: "Architecture"
status: "active"
updated: "2026-04-26"
canonical: "component-registry.yaml"
---

This document provides a high-level summary of the component inventory. For the complete authoritative registry, see [component-registry.yaml](./component-registry.yaml).

## Module Summary

| Module | Component Count | Key Patterns |
| :--- | :--- | :--- |
| Dashboard | 8 | MotionGuard, AnimatePresence, StaggerChildren |
| Chat | 17 | VirtualizeList, OptimisticMutation, SSEStream |
| Projects | 19 | VirtualizeList, OptimisticMutation, InlineEdit |
| Calendar | 12 | TimezoneAware, Recurring, OptimisticMutation |
| Budget | 7 | VirtualizeList, LCP |
| Email | 13 | VirtualizeList, DOMPurify |
| Contacts | 12 | InlineEdit, VirtualizeList |
| Documents | 9 | VirtualizeList, Upload |
| Media | 6 | VirtualizeList, SSEStream |
| News | 6 | VirtualizeList, HoverPrefetch |
| Platform | 10 | LazyMotion, AnimatePresence |
| Conference | 7 | LazyMotion, AnimatePresence |
| LiveKit | 7 | Streaming, StateManagement |
| Research | 6 | LazyMotion, SSEStream |
| Settings | 11 | InlineEdit, OptimisticMutation |
| Foundation (Shell) | 11 | MotionGuard, AnimatePresence |
| Translation | 6 | LazyMotion, SSEStream |
| Workflow | 8 | A2AFlow, VirtualizeList |

**Total Components:** 157

## Pattern Tag Glossary

For the complete pattern tag registry with descriptions, see [pattern-tags.yaml](./pattern-tags.yaml).

### Animation Patterns

MotionGuard, AnimatePresence, StaggerChildren, OpacityFade, Spring, LazyMotion, PopLayout

### Data Patterns

VirtualizeList, InfiniteScroll, OptimisticMutation, InlineEdit, DebounceAutoSave, HoverPrefetch, SSEStream, ChatCache

### Specialized Patterns

GenUI, SandboxIframe, Recurring, TimezoneAware, TieredMemory, WorkflowExecution, A2AFlow, KeyboardShortcuts, Upload, MCPSecurity, Static, TriageColor, PLAY

### LiveKit-Specific Patterns

Streaming, InterruptHandling, TokenGeneration, InterruptDetection, StateManagement, HorizontalScaling

## Rule Reference

### Global Rules (g)

- **g4**: Liquid glass effect
- **g5**: Noise-overlay glass effect
- **g8**: Focus restoration via Zustand store
- **g9**: Keyboard shortcuts displayed in kbd tags
- **g10**: WCAG 2.2 AA compliance
- **g15**: SanitizedHTML component with DOMPurify profiles
- **g20**: VoiceShell + CommandPalette integrated with Zustand
- **g21**: useRef + useCallback for intervals
- **g24**: Web Speech API fallback
- **g26**: LCP ≤ 800ms
- **g27**: URL state sync via nuqs
- **g29**: Sonner toast configuration

### Backend Rules (B)

- **B1**: Zustand persist with version, migrate, and partialize
- **B3**: Drag-and-drop keyboard alternatives (WCAG 2.5.7)
- **B9**: Memory tier configuration
- **B10**: MCP server configuration
- **B11**: userEvent.setup() per test

### Performance Rules (P)

- **P2**: Filter updates useTransition

### Feature Rules (FT)

- **FT**: FocusTrap for modals/drawers

### Other Rules

- **dp**: DOMPurify ≥3.4.0 sanitization
- **dnd**: Drag-and-drop via centralized dnd-kit façade
- **LCP**: Largest Contentful Paint optimization
- **rta**: react-textarea-autosize

## Key Highlights

**Most Common Patterns:**

1. @MotionGuard (40+ components) - Ensures accessible, performant animations
2. @AnimatePresence (30+ components) - Consistent page transitions
3. @VirtualizeList (20+ components) - Performance optimization for large lists
4. @OptimisticMutation (20+ components) - Immediate UI feedback
5. @InlineEdit (15+ components) - Efficient editing UX

**High-Dependency Modules:**

- Chat: Integrates with Y-Sweet, MCP, AI streaming
- LiveKit: Complex STT/LLM/TTS pipeline
- Projects: Heavy use of drag-and-drop, virtualization

**Accessibility Patterns:**

- All animated components use @MotionGuard (respects prefers-reduced-motion)
- Keyboard shortcuts (@KeyboardShortcuts) in key navigation components
- WCAG 2.2 AA compliance (g10) across modules
- Focus restoration (g8) for modals/drawers

---

*This document is auto-generated from [component-registry.yaml](./component-registry.yaml). Do not edit directly.*
