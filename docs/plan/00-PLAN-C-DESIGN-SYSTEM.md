---
steering: TO PARSE - READ INTRO
document_type: design_system
tier: infrastructure
description: Tailwind v4 OKLCH tokens, motion, LiquidGlass, colour rules
last_updated: 2026-04-25
version: 1.0
---

#DS
Tokens|OKLCH-based; three-layer: brand/semantic/component. No hardcoded colours (HARD DSNOKEYUI).
Motion|Spring(tension≥300,damping≥30); stagger≤3; transform/opacity only; prefers-reduced-motion instant.
Glass|LiquidGlass effect: backdrop-blur,noise overlay; use CSS variables for tint.
DarkMode|System preference + manual toggle; persist in localStorage.
Components|SanitizedHTML with STRICT|RICH|EMAIL profiles; EmptyState pattern.
