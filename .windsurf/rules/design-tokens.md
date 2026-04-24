---
trigger: always_on
---

# Design Tokens Rules

Define CSS custom properties in globals.css for consistent theming:

<!-- SECTION: token_definition -->

<token_definition>

Define these CSS custom properties in src/index.css or globals.css:
- --color-accent: Electric blue (#0066ff)
- --color-surface: Deep charcoal (#111111)
- --motion-duration: 150ms
- --motion-ease: ease-out

</token_definition>

<!-- ENDSECTION: token_definition -->

<!-- SECTION: tailwind_integration -->

<tailwind_integration>

Reference these tokens in tailwind.config.ts:
- Use theme.extend to map CSS variables to Tailwind utilities
- Example: colors: { accent: 'var(--color-accent)' }

</tailwind_integration>

<!-- ENDSECTION: tailwind_integration -->

<!-- SECTION: usage -->

<usage>

- Use CSS variables instead of hardcoded values for themeable properties
- Reference via Tailwind utilities where possible
- Direct CSS variable usage for custom components

</usage>

<!-- ENDSECTION: usage -->
