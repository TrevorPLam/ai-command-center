#!/bin/bash
# Generate component overview from YAML registry
# This script regenerates 40-COMP-OVERVIEW.md from component-registry.yaml

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_PLAN_DIR="$SCRIPT_DIR/../docs/plan"
YAML_FILE="$DOCS_PLAN_DIR/component-registry.yaml"
OUTPUT_FILE="$DOCS_PLAN_DIR/40-COMP-OVERVIEW.md"

# Check if yq is installed
if ! command -v yq &> /dev/null; then
    echo "Error: yq is required but not installed."
    echo "Install from: https://github.com/mikefarah/yq"
    exit 1
fi

# Check if YAML file exists
if [ ! -f "$YAML_FILE" ]; then
    echo "Error: $YAML_FILE not found"
    exit 1
fi

# Extract component counts by module
echo "Generating component overview..."

# Count components per module
MODULE_COUNTS=$(yq eval '.components | group_by(.module) | map({module: .[0].module, count: length}) | sort_by(.module)' "$YAML_FILE")

# Generate module summary table
cat > "$OUTPUT_FILE" << 'EOF'
# Component Overview

This document provides a high-level summary of the component inventory. For the complete authoritative registry, see [component-registry.yaml](./component-registry.yaml).

## Module Summary

| Module | Component Count | Key Patterns |
| :--- | :--- | :--- |
EOF

# Add module rows
yq eval '.components | group_by(.module) | map({module: .[0].module, count: length, patterns: (map(.tags | join(", ")) | unique | join(", "))}) | sort_by(.module) | .[] | "| \(.module) | \(.count) | \(.patterns) |"' "$YAML_FILE" >> "$OUTPUT_FILE"

# Calculate total
TOTAL=$(yq eval '.components | length' "$YAML_FILE")
echo "" >> "$OUTPUT_FILE"
echo "**Total Components:** $TOTAL" >> "$OUTPUT_FILE"

# Add pattern tag glossary
cat >> "$OUTPUT_FILE" << 'EOF'

## Pattern Tag Glossary

### Animation Patterns

- **@MotionGuard**: Animates only transform and opacity, respects prefers-reduced-motion
- **@AnimatePresence**: Page-level enter/exit transitions
- **@StaggerChildren**: Staggered animation for child elements (max 3 children)
- **@OpacityFade**: Opacity fade ≤150ms
- **@Spring**: Spring physics animation for primary interactions
- **@LazyMotion**: Lazy loading of motion features for code splitting
- **@PopLayout**: Pop-in layout animation for new elements

### Data Patterns

- **@VirtualizeList**: Virtualized rendering for large lists
- **@InfiniteScroll**: Infinite scroll / load-more pattern
- **@OptimisticMutation**: Immediate UI update with revert on failure; pending state styling
- **@InlineEdit**: Inline editing triggered by click, with debounced auto-save
- **@DebounceAutoSave**: 300ms debounce, auto-save on edits
- **@HoverPrefetch**: Hover triggers data prefetch (200ms debounce)
- **@SSEStream**: Server-Sent Events for real-time data streaming
- **@ChatCache**: AI responses cached indefinitely (staleTime:Infinity)

### Specialized Patterns

- **@GenUI**: Agent-driven UI component rendering
- **@SandboxIframe**: Sandboxed iframe for external content
- **@Recurring**: Recurring event logic (rschedule + Temporal adapter)
- **@TimezoneAware**: All times displayed in user's timezone
- **@TieredMemory**: Memory management with retention tiers (working, episodic, semantic)
- **@WorkflowExecution**: Workflow execution display and state machine
- **@A2AFlow**: Agent-to-agent communication flow
- **@KeyboardShortcuts**: Keyboard shortcuts for accessibility and power users
- **@Upload**: File upload logic
- **@MCPSecurity**: MCP security enforcement
- **@Static**: No animation (static element)
- **@TriageColor**: Color-coded triage indicators
- **@PLAY**: Playground/sandbox environment

### LiveKit-Specific Patterns

- **@Streaming**: Streaming interfaces for real-time data
- **@InterruptHandling**: Interrupt detection and handling for voice pipelines
- **@TokenGeneration**: LLM token generation streaming
- **@InterruptDetection**: Voice activity detection for barge-in
- **@StateManagement**: Session state accumulation and handoff
- **@HorizontalScaling**: Worker pool scaling based on load

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
EOF

echo "Generated $OUTPUT_FILE successfully"
