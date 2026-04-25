---
steering: TO PARSE - READ INTRO
document_type: component_specification
module: Chat
tier: core
component_count: 22
dependencies:
- ~p/ChatPage
- ~s/workflowSlice
motion_requirements:
- @L (LiquidGlass)
- @AP (AnimatePresence)
- @AS (Spring animations)
- @GENUI (GenUI)
accessibility:
- WCAG 2.2 AA compliance
- Screen reader support
- Keyboard navigation
performance:
- Lazy loading
- Prefetching
last_updated: 2026-04-25
version: 1.0
---

# C Components|name|mod|type|pats|rules|deps(non-local)|notes
// Chat
ChatPage|C|Page|@L,AP|-|~p/ChatPage|lazy prefetch
ThinkingTracePanel|C|Panel|AS|-|-|collapsible,dual-pane
GenUIRenderer|C|Renderer|@GENUI|-|-|agent-driven UI
ThreadList|C|List|P2,@L|-|-|useTransition
ThreadListItem|C|Item|-|-|-|hover prefetch 200ms
MessageList|C|List|@V,@S|-|-|role=log,aria-live
MessageBubble|C|Bubble|S/AG,@M|-|-|clientMsgId
TypingIndicator|C|Indicator|@M,AS|-|-|skip reduced motion
ChatInput|C|Input|@M,Q|g4|rta|Cmd+Enter
SlashMenu|C|Menu|@M,@K,Q|FT|~data/slashCommands|built-in+MCP
ToolCallDisclosure|C|Disclosure|@M,AS|-|-|rev-measure VP
CheckpointBanner|C|Banner|@O,AS|-|-|aria-live=assertive
CollabCanvas|C|Canvas|@X,@O,S|-|mco,yjs,yml,ymp,~s/canvasStore|YS token,layoutId
ArtifactSandbox|C|Sandbox|@X,AS|g4+dp|-|BlobURL CSP,revoke
KnowledgeBase|C|Panel|@V|-|FastAPI /v1/embed|inject ctx
MemoryManager|C|Manager|@MEM|B9|~s/memoryStore|episodic+semantic,FIFO
MCPSettings|C|Settings|-|B10|~s/mcpStore|-
AgentStudio|C|Studio|@O|B10|~s/agentStore|browse/clone
A2AFlowEditor|C|Editor|@A,AS|-|dag+rf|kbd access,B11
PromptLibrary|C|Library|@L,@O|-|~s/promptStore|version history
A2ATranscriptViewer|C|Viewer|@A2AMSG|-|-|inter-agent msgs
AgentPlayground|C|Playground|@PLAY,AS|-|-|live trace,sandboxed
