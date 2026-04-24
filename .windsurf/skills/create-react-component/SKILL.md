---
name: create-react-component
description: Guides the creation of React components with TypeScript, Tailwind CSS, and shadcn/ui following the project's visual identity and accessibility standards
---

## Component Creation Checklist (2026)

1. **Determine component location** based on functionality:
   - Layout components: `src/components/layout/`
   - Dashboard components: `src/components/dashboard/`
   - Chat components: `src/components/chat/`
   - Agents components: `src/components/agents/`
   - Projects components: `src/components/projects/`
   - Calendar components: `src/components/calendar/`
   - Budget components: `src/components/budget/`
   - News components: `src/components/news/`
   - Settings components: `src/components/settings/`
   - Analytics components: `src/components/analytics/`
   - Reusable UI components: `src/components/ui/`

2. **Use shadcn/ui components as base** when available (Tailwind v3)
   - Note: This project uses Tailwind v3 with standard CSS configuration
   - Components use forwardRef for ref forwarding (React 18 pattern)
   - HSL colors are used in standard format
   - Default style is available; use new-york style if preferred

3. **Apply visual identity**:
   - Glass panels: `backdrop-blur-md bg-white/5 border border-white/10 rounded-xl`
   - Electric blue accent: `#0066ff → #00aaff` for CTAs, focus rings, active states
   - Dark backgrounds: `#000000`, `#0a0a0a`, `#111111`, `#1a1a1a`

4. **Add 150ms ease-out transitions** on interactive elements

5. **Implement accessibility (WCAG 2.2 AA)**:
   - Semantic HTML elements (nav, main, aside, header, footer)
   - ARIA landmarks and labels where needed
   - Keyboard navigation support
   - Focus management (focus trap in modals, focus restoration)
   - 4.5:1 color contrast ratio minimum
   - Proper heading hierarchy (no skipped levels)
   - aria-live regions for dynamic content
   - Screen reader announcements for important changes

6. **Use TypeScript** with proper interfaces for props (TypeScript 5.8+)

7. **Add skeleton loaders** for data fetching states

8. **React 18 patterns**:
   - Use `forwardRef` for components that need ref forwarding
   - Use `<Context.Provider>` for context providers
   - Use standard ref callbacks with cleanup functions
   - Consider Suspense boundaries with React.lazy() for code splitting
   - Use standard form handling with React Hook Form
   - Use FormEvent for form submissions
   - Use TanStack Query for optimistic UI updates
   - Use standard useEffect/useCallback/useMemo hooks

## Related Skills

- **motion-implementation**: Add animations and micro-interactions to components
- **form-components**: For creating form components with validation
- **accessibility**: Ensure WCAG 2.2 AA compliance
- **performance**: Optimize component rendering and Core Web Vitals

## Component Structure Template (React 18)

```tsx
import React from 'react';

interface ComponentNameProps {
  // props here
}

export const ComponentName: React.FC<ComponentNameProps> = ({ }) => {
  return (
    <div className="backdrop-blur-md bg-white/5 border border-white/10 rounded-xl">
      {/* component content */}
    </div>
  );
};

// React 18: Use forwardRef for ref forwarding
export const ComponentWithRef = forwardRef<HTMLDivElement, {}>((props, ref) => {
  return <div ref={ref}>Content</div>;
});
ComponentWithRef.displayName = 'ComponentWithRef';

// React 18: Context.Provider pattern
const ThemeContext = createContext('dark');

export const App: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  return (
    <ThemeContext.Provider value="dark">
      {children}
    </ThemeContext.Provider>
  );
};

// React 18: Ref callback with cleanup
export const ComponentWithCleanup: React.FC = () => {
  const [ref, setRef] = useState<HTMLDivElement | null>(null);

  useEffect(() => {
    if (ref) {
      // ref created
      return () => {
        // ref cleanup when component unmounts
      };
    }
  }, [ref]);

  return <div ref={setRef}>Content</div>;
};
```

## Motion Pattern

```tsx
// Add to interactive elements
className="transition-all duration-150 ease-out"
```

## Reduced Motion Support

```css
@media (prefers-reduced-motion: no-preference) {
  /* animations here */
}
```
