---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-C-DESIGN-SYSTEM.md
document_type: design_system
tier: infrastructure
status: stable
owner: Product Engineering
description: Tailwind v4 OKLCH tokens, motion, LiquidGlass, colour rules
last_updated: 2026-04-25
version: 1.0
dependencies: [00-PLAN-1-INTRO.md]
related_adrs: []
related_rules: [DSNOKEYUI, g2, g5, g6, g13]
complexity: low
risk_level: low
---

#DS
Tokens|OKLCH-based; three-layer: brand/semantic/component. No hardcoded colours (HARD DSNOKEYUI).
Motion|Spring(tension≥300,damping≥30); stagger≤3; transform/opacity only; prefers-reduced-motion instant.
Glass|LiquidGlass effect: backdrop-blur,noise overlay; use CSS variables for tint.
DarkMode|System preference + manual toggle; persist in localStorage.
Components|SanitizedHTML with STRICT|RICH|EMAIL profiles; EmptyState pattern.
