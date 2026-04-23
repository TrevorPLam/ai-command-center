---
trigger: always_on
---

# Tech Stack Rules

This project uses a locked tech stack. Do not deviate from these technologies:

<core_technologies>
- React 18 + TypeScript (Vite build tool, NOT Next.js)
- Tailwind CSS + shadcn/ui for all UI components
- TanStack Query v5 for server state management
- Zustand for UI-only state (sidebar, command palette, active panel)
- React Router v6 for all routing
</core_technologies>

<vite_specific_requirements>
- Use Vite for all builds and development server
- Configure vite.config.ts with path aliases (@/ for src)
- Use @/ alias for all src imports (e.g., @/components/ui/Button)
- Configure proxy in vite.config.ts for API calls to http://localhost:8000
- Use Vite environment variables with VITE_ prefix
- Configure tsconfig.json with baseUrl and paths for TypeScript support
- Do NOT use Next.js, Remix, or any SSR framework
- Do NOT configure server-side rendering or API routes
- All builds must be static SPA bundles
</vite_specific_requirements>

<strict_constraints>
- Do NOT use Next.js, Remix, or any SSR framework
- Do NOT create backend files, server code, database schemas, or .env files
- Do NOT add authentication, session management, or login flows
- Do NOT use Replit-specific packages or deployment configs
- Do NOT configure Vercel-specific build settings or deployment configs
- All API calls must target http://localhost:8000
- All data must be mocked with realistic placeholder values in src/lib/mockData/
- Use Vite for all builds, not webpack or other bundlers
- Configure Vite proxy for API calls during development only
</strict_constraints>

<component_requirements>
- Every component must be fully built with realistic mock data rendered
- No page, subpage, or component should be a stub
- Use shadcn/ui components as the base for all UI elements
- All components must use TypeScript with proper typing
</component_requirements>
