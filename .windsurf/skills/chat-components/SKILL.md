---
name: chat-components
description: Guides the creation of chat interface components including ChatInterface, MessageBubble, ToolCallDisclosure, CheckpointBanner, and ChatInput with proper thread management and real-time streaming
---

## Chat Components

### ChatInterface.tsx
Full-height flex layout with thread list sidebar and active thread area.

**Thread list sidebar (240px):**
- Search box at top
- List of past threads with: title (auto-generated from first message), relative timestamp, last message preview, active agent badge
- "New Chat" button creates a new thread
- Filter by agent or date

**Active thread area:**
- Messages rendered by MessageBubble
- User messages: right-aligned, charcoal background
- Agent messages: left-aligned, glass card
- ToolCallDisclosure: collapsible section showing tool name, input args (JSON), and output. Collapsed by default, expand with chevron
- CheckpointBanner: amber banner that appears when agent pauses for human approval; shows context and Approve/Reject buttons inline
- ChatInput: sticky bottom bar with textarea (auto-resize), send button (electric blue), model selector dropdown, attach file button, and slash-command trigger

### MessageBubble.tsx
- Displays individual messages
- User messages: right-aligned, bg-[#111111] border border-white/8
- Agent messages: left-aligned, glass panel (backdrop-blur-md bg-white/5 border border-white/10)
- Shows: sender name, timestamp, message content
- Includes ToolCallDisclosure for agent tool calls
- Includes CheckpointBanner when agent needs approval

### ToolCallDisclosure.tsx
- Collapsible section showing tool call details
- Shows: tool name, input arguments (formatted JSON), output (formatted JSON)
- Collapsed by default with chevron indicator
- Electric blue accent when expanded
- Syntax highlighting for JSON
- Copy button for input/output

### CheckpointBanner.tsx
- Amber/yellow warning banner
- Appears when agent pauses for human approval
- Shows: context description, what action requires approval
- Inline Approve (green) and Reject (red) buttons
- Dismissible after decision
- ARIA role="alert" for screen readers

### ChatInput.tsx
- Sticky bottom bar
- Textarea with auto-resize (min-height: 40px, max-height: 200px)
- Send button (electric blue, right-aligned)
- Model selector dropdown (shows available AI models)
- Attach file button
- Slash-command trigger (shows available commands)
- Submit on Enter (Shift+Enter for new line)
- Character count indicator

## Data Requirements

All chat components must use realistic mock data from `src/lib/mockData/` with:
- Thread history with multiple conversations
- Messages with user and agent roles
- Tool calls with realistic inputs/outputs
- Checkpoint scenarios requiring approval

## State Management

- Use TanStack Query for fetching thread list and message history
- Use SSE (Server-Sent Events) for real-time message streaming via useSSE hook
- Use Zustand for UI-only state (active thread, sidebar open/close)

## Accessibility Requirements (WCAG 2.2 AA)

- ChatInterface: proper ARIA landmarks (main, aside, navigation), semantic HTML
- MessageBubble: proper role and aria-label for each message, announcement of new messages
- ToolCallDisclosure: aria-expanded state, keyboard navigation, proper button roles
- CheckpointBanner: role="alert", aria-live="polite", aria-atomic="true"
- ChatInput: proper labels, keyboard navigation, focus management, aria-label for textarea
- All interactive elements: 4.5:1 color contrast ratio minimum
- Focus management: visible focus indicators, focus restoration after thread switch
- Dynamic content: aria-live regions for streaming messages
- Screen readers: announce tool calls, checkpoint requests, message completion
- Keyboard navigation: proper tab order, escape to close drawers

## Visual Identity

- Glass panels: backdrop-blur-md bg-white/5 border border-white/10 rounded-xl
- Electric blue accent: #0066ff → #00aaff for CTAs and active states
- 150ms ease-out transitions on all interactive elements
- Charcoal backgrounds: #111111, #1a1a1a for user messages
- Skeleton loaders on all data fetch states

**Tailwind v3 & shadcn/ui Notes (2026):**
- shadcn/ui uses Tailwind v3 with standard CSS configuration
- Components use forwardRef for ref forwarding (React 18 pattern)
- HSL colors are used in standard format
- Default style is available; use new-york style if preferred
