---
trigger: glob
globs: src/components/**/*.tsx
---

# Component Structure Rules

Follow this structure for all React components:

<file_organization>
- Layout components: src/components/layout/
- Dashboard components: src/components/dashboard/
- Chat components: src/components/chat/
- Agents components: src/components/agents/
- Projects components: src/components/projects/
- Calendar components: src/components/calendar/
- Budget components: src/components/budget/
- News components: src/components/news/
- Settings components: src/components/settings/
- Analytics components: src/components/analytics/
- Reusable UI components: src/components/ui/
</file_organization>

<component_best_practices>
- Use functional components with hooks
- Use TypeScript interfaces for props
- Export components as default
- Use proper TypeScript typing for all props and state
- Keep components focused and single-purpose
- Extract reusable logic into custom hooks in src/hooks/
</component_best_practices>

<shadcn_ui_usage>
- Use shadcn/ui components as base
- Customize shadcn/ui components with Tailwind classes
- Follow the glass panel pattern: backdrop-blur-md bg-white/5 border border-white/10 rounded-xl
- Use electric blue (#0066ff → #00aaff) for accents and active states
- Ensure all components support the dark theme (locked to dark)
- Note: Project uses Tailwind v3 with standard CSS configuration
- Note: Project uses React 18 with forwardRef pattern
- Note: toast component is available; sonner can be used as alternative
</shadcn_ui_usage>

<state_management>
- Use Zustand for UI-only state (sidebar, command palette, active panel)
- Use TanStack Query for server state
- Keep component state local when possible
- Lift state up only when necessary
</state_management>
