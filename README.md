# Personal AI Command Center - Frontend Specification

A comprehensive specification suite for building a React 18 + TypeScript AI command center frontend with modern tooling and 2026 best practices.

## Project Overview

This is a **frontend-only** specification for a personal AI command center. The application provides a unified interface for AI interactions, project management, calendar, news, budget tracking, workflow automation, email, contacts, documents, video conferencing, research tools, and settings.

**Tech Stack:**
- React 18 + TypeScript (Vite build tool)
- Tailwind CSS v4 (CSS-first `@theme` configuration)
- shadcn/ui component library
- TanStack Query v5 for server state
- Zustand for UI state
- React Router v7 (Data Mode with loaders)
- Motion v12 for animations
- Vitest + Playwright for testing

**Key Design Principles:**
- Dark theme with electric blue accents (`#050507` background, `#0066ff` accent)
- Glass panels with noise overlay for shell surfaces
- Motion hierarchy: Alive (spring), Quiet (fade), Static (instant)
- WCAG 2.2 AA accessibility compliance
- Core Web Vitals targets: LCP < 2.5s, INP < 200ms, CLS < 0.1

## Documentation Structure

### Module Specifications (01-16)

Each module specification is a detailed implementation guide with tasks, subtasks, anti-patterns, and testing requirements.

| File | Module | Description |
|------|--------|-------------|
| `01-Foundations.md` | Project Foundations | Vite setup, design tokens, testing infrastructure, Zustand architecture, TanStack Query, React Router v7 |
| `02-Dashboard.md` | Dashboard | Agent fleet panel, activity feed, attention queue, ambient status banner |
| `03-Chat.md` | Chat Interface | AI chat with streaming SSE, thread management, tool call disclosure, checkpoint banners |
| `04-Projects.md` | Project Management | Multiple views (List, Kanban, Timeline, My Week, Workload), task details, templates |
| `05-Calendar.md` | Calendar | Month/Week/Day/Agenda views, event composer, recurring events with rrule.js |
| `06-News.md` | News Feed | Preference-driven curation, topic selector, source manager, frequency slider |
| `07-Budget.md` | Budget Tracking | Accounts, transactions, goals, investments, reports, anomaly detection |
| `08-Workflow.md` | Workflow Automation | Visual workflow builder with React Flow, node-based automation |
| `09-Email.md` | Email Management | Email client with offline sync (IndexedDB/Dexie) |
| `10-Lists.md` | List Management | Multiple list types with drag-and-drop, offline sync |
| `11-Contacts.md` | Contact Management | Contact database with relationships, offline sync |
| `12-Documents.md` | Document Management | Document editor with Yjs real-time collaboration, offline sync |
| `13-Conference.md` | Video Conferencing | WebRTC video calls with LiveKit, screen sharing, recording |
| `14-Research.md` | Research Tools | RAG with local ONNX embeddings, vector search, knowledge graph |
| `15-Settings.md` | Settings | General, appearance, notifications, analytics, memory, integrations, export/import |
| `16-Polish-Validation.md` | Polish & Validation | Performance optimization, accessibility audit, testing coverage, security checks |

**Specification Format:**
- Reasoning memo explaining architectural decisions
- Cross-cutting foundations (shared requirements)
- Task breakdown with priorities and dependencies
- Subtasks with specific implementation details
- Anti-patterns to avoid
- Definition of done
- Testing requirements (embedded as subtasks)

### Update Task List (TODO.md)

`TODO.md` contains a structured plan for normalizing and enhancing the specifications across 5 phases:

- **Phase 0**: Immediate critical fixes (Set serialization, LayoutGroup audit, focusTriggerRef, cancelQueries)
- **Phase 1**: Shared infrastructure extraction (recurrence engine, drag-and-drop, optimistic mutations, centralized Dexie, SanitizedHTML)
- **Phase 2**: Module-specific rescoping (Documents Yjs, Conference MVP, ONNX UX, Budget z-score)
- **Phase 3**: Foundation enhancements (dependency versions, SSE tests, code-splitting, WCAG 2.5.7)
- **Phase 4**: Normalization and final polish (renumbering, shared primitives, dependency graphs, consistency audit)

Status: Phase 0 tasks UPD-000 and UPD-001 are marked complete.

## Windsurf Configuration

This workspace uses Windsurf's rules, skills, and workflows to guide AI-assisted development.

### Rules (`.windsurf/rules/`)

26 rule files provide persistent behavioral guidelines for the AI assistant:

| Rule | Purpose |
|------|---------|
| `accessibility.md` | WCAG 2.2 AA requirements, ARIA patterns, keyboard navigation |
| `api-pattern.md` | API design patterns and best practices |
| `bento-grid-layout.md` | Bento grid layout system with responsive breakpoints |
| `component-structure.md` | Component organization and structure guidelines |
| `core-web-vitals-inp.md` | INP optimization strategies and thresholds |
| `css-property-animations.md` | CSS @property animated gradient borders |
| `date-handling.md` | Date handling with date-fns |
| `design-tokens.md` | CSS custom properties and theme tokens |
| `drag-and-drop.md` | Drag-and-drop implementation patterns |
| `error-handling.md` | Error handling strategies |
| `focus-restoration.md` | Focus management for modals and drawers |
| `form-handling.md` | Form validation and handling patterns |
| `keyboard-shortcuts.md` | Keyboard shortcut display with `<kbd>` tags |
| `motion-hierarchy.md` | Motion tier assignment (Alive/Quiet/Static) |
| `motion-library.md` | Motion v12 usage patterns and performance |
| `motion-preference.md` | Reduced motion preference handling |
| `performance.md` | Performance optimization guidelines |
| `react-router-v6.md` | React Router v6/v7 patterns |
| `tanstack-query-v5.md` | TanStack Query v5 best practices |
| `tech-stack.md` | Locked tech stack requirements |
| `testing.md` | Testing patterns and strategies |
| `typescript.md` | TypeScript best practices |
| `virtualization.md` | react-window virtualization patterns |
| `visual-identity.md` | Visual design guidelines (colors, typography, glass panels) |
| `vite-config.md` | Vite configuration patterns |

### Skills (`.windsurf/skills/`)

26 skill directories provide multi-step procedures with supporting files for complex tasks:

| Skill | Purpose |
|-------|---------|
| `analytics-components` | Cost analytics, audit logs, budget overview |
| `budget-components` | Budget dashboard, transactions, goals, investments |
| `calendar-components` | Calendar views, event composer, date handling |
| `chart-components` | Recharts with animations and accessibility |
| `chat-components` | Chat interface, message bubbles, streaming |
| `create-api-client` | TanStack Query v5 API client setup |
| `create-dashboard-component` | Dashboard-specific components |
| `create-hooks` | Custom React hooks with TanStack Query |
| `create-layout-component` | Layout components (sidebar, command palette) |
| `create-mock-data` | Realistic mock data generation |
| `create-react-component` | React components with TypeScript and shadcn/ui |
| `create-zustand-store` | Zustand stores for UI state |
| `date-handling` | Date handling implementation |
| `drag-drop-components` | Drag-and-drop with @dnd-kit |
| `form-components` | Form components with react-hook-form |
| `liquid-glass-implementation` | Liquid glass and matte glass UI effects |
| `motion-implementation` | Motion library animations |
| `news-components` | News feed components with preference curation |
| `projects-components` | Project management components |
| `settings-components` | Settings pages and components |
| `sse-implementation` | Server-Sent Events for real-time streaming |
| `timeline-components` | Timeline and Gantt chart components |
| `virtualization-implementation` | react-window for virtualized lists |

Each skill contains a `SKILL.md` file with YAML frontmatter (name, description) and detailed implementation instructions.

### Workflows (`.windsurf/workflows/`)

- `process-todo-task.md` - Workflow for working through TODO.md tasks with a structured 10-step sequence

### Guide (`.windsurf/WINDSURF_RULES_SKILLS_GUIDE.md`)

Comprehensive guide explaining:
- How rules, skills, and workflows work
- File locations and discovery
- Activation modes and invocation methods
- Best practices for each mechanism
- Enterprise configuration options

## Getting Started

### For Developers

1. **Read the Foundations** (`01-Foundations.md`) to understand the project setup, tech stack, and cross-cutting requirements.

2. **Check TODO.md** for pending specification updates before implementing modules.

3. **Follow Module Specifications** - Each module (02-16) provides detailed task breakdowns. Work through tasks in dependency order.

4. **Use Windsurf Rules** - The AI assistant is configured with project-specific rules that enforce consistency with the specifications.

5. **Invoke Skills** - Use `@skill-name` to invoke specific skills for complex tasks (e.g., `@create-react-component`).

6. **Run Workflows** - Use `/process-todo-task` to work through TODO.md items systematically.

### For AI Assistants

The Windsurf configuration provides:
- **Rules** that enforce the tech stack, visual identity, motion hierarchy, and accessibility standards
- **Skills** that guide component creation following the project's patterns
- **Workflows** that provide structured procedures for common tasks

## Key Cross-Cutting Requirements

### Motion Hierarchy
- **Alive**: Core navigation, state changes, user feedback → Spring physics (`stiffness: 300, damping: 30`)
- **Quiet**: Secondary elements, tooltips, reveals → Opacity fades ≤150ms
- **Static**: Dense data tables, repeated items → No animation

### Accessibility
- WCAG 2.2 AA compliance
- Focus restoration on modal/drawer close
- Keyboard navigation for all interactive elements
- ARIA live regions for dynamic content
- Reduced motion preference respected

### Performance
- Virtualization for lists >50 items (react-window)
- Code splitting with React.lazy()
- TanStack Query for efficient data caching
- Motion animations only on transform/opacity
- Core Web Vitals targets enforced

### State Management
- **Server state**: TanStack Query v5 (single source of truth)
- **UI state**: Zustand with slices pattern
- **Form state**: react-hook-form
- **No mirroring**: Never duplicate TanStack Query cache in Zustand

## Version Information

- **Specification Version**: Enhanced v2/v3 (varies by module)
- **Last Updated**: April 23, 2026
- **Tech Stack Baseline**: React 18, Tailwind v4, Motion v12, React Router v7, TanStack Query v5, Zustand 5

## Notes

- This is a **frontend-only** specification. All API calls target `http://localhost:8000` with mocked data.
- No backend, database, or authentication is specified.
- All data is mocked with realistic placeholder values in `src/lib/mockData/`.
- The specification suite is designed for parallel development - many tasks can be worked on simultaneously by different developers.
