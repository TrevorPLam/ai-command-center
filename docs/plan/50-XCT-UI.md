---
title: "UI Services"
owner: "Frontend Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---

Motion, optimistic mutations, design system, and sanitization.

---

## Services

### Motion Service

#### CrossCuttingMotion
- **Module**: XCT (Cross-Cutting)
- **Type**: Service
- **Patterns**: `@MotionGuard`
- **Rules**: P1, P2 (Performance rules)
- **Dependencies**: ~/hooks/useShouldAnimate
- **Purpose**: Ensures all animations use only transform and opacity properties
- **Features**: Respects prefers-reduced-motion, disables animations when reduced motion is requested

### Optimistic Mutation Service

#### CrossCuttingOptimistic
- **Module**: XCT (Cross-Cutting)
- **Type**: Service
- **Patterns**: `@OptimisticMutation`
- **Rules**: g19 (Global rule 19)
- **Dependencies**: useOptimistic, ~/hooks/useUndo
- **Purpose**: Manages optimistic UI updates with rollback capability
- **Features**:
  - Pending state with opacity 0.5, italic styling, and pulse animation
  - Automatic rollback on failure
  - 5-second undo window for delete operations

---

## Design System

### Design Tokens

- **Color System**: OKLCH-based three-layer architecture
  - Brand tokens: Primary palette
  - Semantic tokens: Functional colors (success, warning, error)
  - Component tokens: Component-specific colors
- **Constraint**: No hardcoded hex/RGB colors allowed (HARD rule DSNOKEYUI)
- **Reference**: All colors use CSS custom properties

### Motion System

- **Spring Physics**: Tension ≥300, damping ≥30
- **Stagger**: Maximum 3 children in any stagger animation
- **Properties**: Transform and opacity only (no layout animations)
- **Accessibility**: Respects prefers-reduced-motion (instant transitions when enabled)

### Glass Effects

- **Liquid Glass**: backdrop-blur with noise overlay
- **Implementation**: CSS variables for tint control
- **Usage**: Shell surfaces, modals, command palette

### Dark Mode

- **Source**: System preference detection
- **Override**: Manual toggle available
- **Persistence**: Stored in localStorage

### Component Patterns

- **SanitizedHTML**: Three profiles available
  - STRICT: No SVG, minimal tags
  - RICH: Div, span, lists allowed
  - EMAIL: Links and images with rel=noopener
- **EmptyState**: Required pattern for all empty data states

---

## Sanitisation

### Content Sanitization

#### DOMPurify

- **Version**: ≥3.4.0 required
- **Component**: `SanitizedHTML` with profile prop
  - **STRICT**: No SVG, no style, minimal allowed tags
  - **RICH**: Div, span, strong, em, ul/li allowed, no SVG
  - **EMAIL**: Links (a), images (img), paragraphs (p), line breaks (br); forces rel=noopener on all links

### File Scanning

#### ClamAV

- **Version**: v1.4.x sidecar deployment
- **Updates**: freshclam hourly for virus definitions
- **Health Check**: Available on /health endpoint
- **Caching**: No scan caching (fresh scan every time)

### Input Validation

#### Zod Schema Validation

- **URL Parameters**: All validated with Zod schemas
- **Output**: All output sanitized before rendering
- **Coverage**: 100% of user inputs

### MCP Security

#### SSRF Protection

- **Middleware**: Blocks all private IP ranges
- **Allowlist**: Strict allowlist validation for outbound requests
- **Redirects**: No redirects allowed (blocks open redirects)

### Testing

- **XSS Payload Matrix**: 10 test cases in TESTC04
- **CSP Violations**: Automated CSP violation checks in CI
