# AI Command Center — Chat Module Enhanced Task List

**Researched & Strategically Organized — April 2026**

---

## Research Synthesis

Before presenting the enhanced task list, below is a consolidated summary of the research findings that inform every architectural and implementation decision in the tasks that follow.

### 1. Collaboration Canvas (Split-Pane Editing)

**Industry State:** ChatGPT Canvas uses a side-by-side paradigm where the left pane holds the chat conversation and the right pane is a "living document or codebase." The standout feature is **inline targeted editing** — users highlight specific text/code, and the AI revises *only that section* without regenerating the whole file. OpenAI's newer Interactive Code Blocks add a **diff-style split-screen view** showing exactly what lines are being added or removed before the user clicks "Apply."

**Claude Artifacts** takes a different approach: it renders structured outputs (HTML, SVG, React) in a live preview pane that updates in real-time. Artifacts regenerate the full artifact on each revision rather than tracking line-level edits.

**Key Technical Insight:** Canvas excels for document/code editing depth; Artifacts excels for interactive prototypes. Neither replaces full document collaboration tools like Google Docs. Both features are available only on paid plans (~$20/month).

**Implementation Guidance:**
- Use `@monaco-editor/react` + `vite-plugin-monaco-editor-esm` for Vite compatibility.
- For split-pane layout, use `react-resizable-panels` (by bvaughn, the same developer behind react-window) or `allotment` (built on the same codebase as VS Code's split view).
- For diff display: Monaco's built-in `createDiffEditor` for code; `react-diff-viewer` (supports split/unified view, word diff, line highlighting) for text.
- Apply pattern: generate diff → show preview → user clicks "Apply" → patch applied optimistically.

### 2. Live Artifacts (Sandboxed Rendering)

**Industry State:** Claude Artifacts run in a strictly sandboxed `<iframe>` hosted on a **separate origin** (`claudeusercontent.com`), preventing access to parent cookies, localStorage, or DOM. The sandbox uses `allow-scripts` but **disables `allow-same-origin`** to force a unique, unpredictable origin.

Claude employs a **Content Security Policy (CSP)** that blocks external CDN scripts, blocks `fetch()`/`XMLHttpRequest`, and only allows `data:`, `blob:`, or Anthropic-approved CDN resources for media.

**Security Architecture (from Huawei Cloud research):**
- **Principle of least privilege:** `sandbox="allow-scripts"` only — no `allow-same-origin`, no `allow-top-navigation`, no `allow-forms`
- **Dual defense:** CSP headers as second layer if sandbox is bypassed
- **Environment purification:** Freeze `Object.prototype`, proxy `window.open`, isolate global event listeners
- **Blob URL + iframe.src** is the recommended approach over `srcdoc` — Blob URLs have independent origin (`blob:` protocol), preventing access to parent page DOM or variables.

**For React rendering in-browser:** Use `@babel/standalone` to transpile JSX/TSX → JavaScript, then use `Blob` + `URL.createObjectURL` to create a module that the iframe loads. Import maps + `esm.sh` can provide React, ReactDOM, and other dependencies without a build step.

**Claude's pre-audited component stack:** React DOM (core engine), Tailwind CSS (styling), Radix Primitives (accessible UI), Lucide React (icons), DOMPurify (sanitization before render).

### 3. Version Snapshots & Checkpoints

**Industry State:** Claude Code's `/rewind` (or `/checkpoint`) command captures the file state before AI makes significant edits and allows restoring to any previous point. Checkpoints persist across sessions. They are designed for "fast, session-level recovery" and explicitly complement (not replace) Git for permanent version history.

**Implementation Pattern:**
- Zustand with `zeitstand` middleware: intercepts state changes, writes into a ring-buffer history, exposes `undo(steps?)` / `redo(steps?)`. ~1.6 KB min+gzip.
- Alternative: custom temporal middleware with deep cloning (`JSON.parse(JSON.stringify(state))`) for independent snapshots.
- Checkpoints should auto-create before each AI edit and allow manual creation with descriptions.

### 4. MCP Client Architecture

**Industry State:** MCP is the de facto standard for AI-tool connectivity, with 5,800+ available servers and 97M+ monthly SDK downloads. Adopted by Anthropic, OpenAI, Google, and Microsoft.

**Architecture:** Host → Client(s) → Server(s). Each client maintains a 1:1 stateful connection with a single MCP server. A host can spawn multiple clients.

**Four capability types exposed:** Resources (data the model reads), Tools (functions the model invokes), Prompts (reusable templates), Sampling (server-initiated LLM requests).

**For browser-based MCP clients:**
- `@hashangit/mcp-browser-client` — wraps official `@modelcontextprotocol/sdk` for browser use
- `mcp-lite` by Fiberplane — lightweight, works anywhere `Request`/`Response` are available
- **Important constraint:** The official `@modelcontextprotocol/sdk` requires Node.js ≥v18 — browser usage needs adaptation or wrapper libraries.
- **Production readiness:** MCP still has gaps being addressed (configuration portability, auth standardization, streaming transport). For MVP, mock the protocol layer and build the UI shell.

### 5. Client-Side RAG (Knowledge Base)

**Vector Database Options:**
- `client-vector-search` by shunnNet: plug-and-play, uses `@xenova/transformers` for embeddings (gte-small, ~30MB), stores vectors in IndexedDB, cosine similarity search.
- `@ruvector/rvlite`: full vector DB in WASM (~850KB), supports cosine/euclidean/dot product.
- PGlite + pgvector: WASM Postgres in browser with vector extension, stores in IndexedDB.

**Embedding Model:** `Xenova/all-MiniLM-L6-v2` is the standard choice — pre-trained sentence-transformers model converted to ONNX, runs efficiently in browser via WASM/WebGPU. Testing with 10,000 documents achieved query times of ~88ms.

**IndexedDB Storage:** Chrome allows up to 60% of free disk space (with user permission), Firefox ~2GB. Use `navigator.storage.estimate()` for quota monitoring. Chunk large files at 10MB for writes. Wrap with `localForage` or Dexie for simpler API.

**Security:** DOMPurify all user-provided text before storage and retrieval. Sanitize HTML content before rendering with `DOMPurify.sanitize()` + `html-react-parser` combo.

### 6. Agent-to-Agent (A2A) Flow Orchestrator

**Library:** `@xyflow/react` (React Flow v12+) — handles drag, connect, and all interactions. **Dagre** for automatic DAG layout positioning.

**Key patterns identified in research:**
- Each node type must export `<Handle>` components for edges to connect.
- Use Zustand for outside state accessible to nodes.
- When deleting nodes, ensure Dagre graph instance is also cleaned to prevent edge anomalies.
- Undo/redo with Zustand temporal middleware specifically for React Flow state.

---

## 🧱 Cross-Cutting Foundations (Apply to ALL Chat Tasks)

| ID | Area | Requirement |
|----|------|-------------|
| **CHAT-C01** | Message Cache SSOT | TanStack Query cache is the **only** source of truth for messages. No local `useState` message arrays. |
| **CHAT-C02** | Optimistic Updates | User messages added via `queryClient.setQueryData` in `onMutate`. Rollback on error via snapshot. `onSettled` (not `onSuccess`) triggers invalidation. |
| **CHAT-C03** | Stable React Keys | Optimistic messages use `clientMsgId` generated with `crypto.randomUUID()` **once** at send time. Never replaced with server ID. |
| **CHAT-C04** | Streaming Transport | SSE over `fetch` + `ReadableStream`. Not `EventSource` (no custom headers). Not WebSockets (unidirectional). |
| **CHAT-C05** | Stream Lifecycle | `AbortController` stored in `useRef`. Abort on unmount and on new message send. Suppress `AbortError` reporting. |
| **CHAT-C06** | Scroll Contract | Auto-scroll to bottom **only if** user is within 50px of bottom. Preserve position otherwise. |
| **CHAT-C07** | Cache Config | `staleTime: 0` + `gcTime: Infinity` for messages. |
| **CHAT-C08** | ARIA Live Regions | Message container: `role="log"` + `aria-live="polite"`. CheckpointBanner: `role="status"` + `aria-live="assertive"`. |
| **CHAT-C09** | Motion Guard | All animated components check `useReducedMotion()`. If true: skip character reveal, skip typing dots, skip spring transitions. |
| **CHAT-C10** | Test Infrastructure | All network calls mocked via MSW handlers. TanStack Query wrapped in `createWrapper()` helper. |

### Motion Tier Assignment

| Component | Tier | Technique |
|-----------|------|-----------|
| Thread list items | **Quiet** | `opacity` fade on mount, 150ms max, no stagger |
| MessageBubble (user) | **Static** | Instant render |
| MessageBubble (agent, new) | **Alive** | `opacity: 0→1`, `y: 10→0`, spring `stiffness: 300 damping: 30` |
| Streaming text | **Alive** | Character reveal ~20ms/char; blinking `|` cursor; suppressed when `useReducedMotion()` |
| Typing indicator | **Alive** | Three-dot `keyframes` opacity `[0.3, 1, 0.3]`, staggered delays |
| LED input border | **Alive** | `boxShadow` glow on focus; 100ms brightness flash on keypress |
| ToolCallDisclosure chevron | **Alive** | `rotate: isOpen ? 180 : 0`, spring |
| CheckpointBanner | **Alive** | `y: -20→0` with `AnimatePresence` |
| Slash command menu | **Quiet** | Opacity fade 100ms |
| Canvas pane resize handle | **Quiet** | `opacity` on hover, 150ms |
| Artifact iframe load | **Alive** | `opacity: 0→1`, `scale: 0.98→1`, spring |
| Snapshot list item | **Quiet** | Opacity fade 150ms |
| MCP tool status dot | **Alive** | Pulse keyframes (green=connected, amber=connecting, red=error) |
| Agent node drag overlay | **Alive** | Glowing, scaled card with spring follow |

---

## 📋 Strategic Task Organization

The 21 parent tasks below are organized into **six modules** reflecting the natural dependency chain and conceptual grouping:

| Module | Tasks | Description |
|--------|-------|-------------|
| **A: Chat Core** | CHAT-001 → CHAT-010 | Existing chat infrastructure (layout, state, messages, streaming, slash commands) |
| **B: Collaboration Canvas** | CHAT-011 → CHAT-013 | Split-pane editor, live artifact rendering, version snapshots |
| **C: Multimodal & MCP Foundation** | CHAT-014 → CHAT-017 | Media attachments, MCP settings UI, tool registry, terminal shell |
| **D: Knowledge & Memory** | CHAT-018 → CHAT-019 | Client-side RAG knowledge base, cross-conversation memory |
| **E: Agent Orchestration** | CHAT-020 → CHAT-021 | Agent studio builder, A2A DAG flow editor |

---

**See Also:**
- [11-Chat-Overview.md](11-Chat-Overview.md) - Original Chat Core specification (CHAT-001 through CHAT-010)
- [11-Chat-Modules.md](11-Chat-Modules.md) - Extended module tasks (CHAT-011 through CHAT-022)
