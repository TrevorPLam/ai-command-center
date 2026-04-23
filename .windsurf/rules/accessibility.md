---
trigger: always_on
---

# Accessibility Rules (WCAG 2.2 AA)

All components must meet WCAG 2.2 AA accessibility standards:

<aria_requirements>
- ActivityFeed: role="log" with aria-live="polite"
- CommandPalette: role="combobox" with aria-expanded and aria-activedescendant
- AttentionQueue: Each decision packet needs role="article" and descriptive aria-label
- All modals: Focus trapped, role="dialog", aria-modal="true", aria-labelledby pointing to modal title
- All interactive elements: Accessible names via aria-label or visible label
</aria_requirements>

<color_contrast>
- All text must meet 4.5:1 contrast ratio on dark backgrounds
- Verify contrast for all text sizes and colors
- Test with both normal and large text (18pt+ or 14pt+ bold)
</color_contrast>

<keyboard_navigation>
- Tab order must follow visual order
- All actions must be reachable without mouse
- Ensure focus indicators are visible (electric blue)
- Skip to main content link if needed
</keyboard_navigation>

<motion_reduced>
- Wrap all CSS animations in @media (prefers-reduced-motion: no-preference)
- Respect user's motion preferences
- Provide alternatives for essential animations
</motion_reduced>

<semantic_html>
- Use proper HTML5 semantic elements
- Ensure proper heading hierarchy (h1-h6)
- Use landmark regions (main, nav, aside, etc.)
- Provide alt text for all images
</semantic_html>
