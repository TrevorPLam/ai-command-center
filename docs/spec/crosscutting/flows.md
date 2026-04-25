---
id: crosscutting.flows
title: System Flows
type: architecture
last_updated: '2026-04-25T01:34:38.866847+00:00'
---

## Login Flow
1. User submits credentials on LoginPage via `signInWithPassword`.
2. Supabase Auth returns session; `authSlice` updates `currentUser`.
3. Custom access token hook embeds `org_id` and `user_role` into JWT.
4. `onAuthStateChange` triggers query invalidation and Realtime reconnection.
5. Redirect to Dashboard.

## Chat Message Flow
1. User types message in ChatInput, sends (Cmd+Enter).
2. Message added to MessageList with permanent `clientMsgId`, displayed optimistically.
3. `useSSE` opens a stream to FastAPI `/v1/chat` with the message and thread context.
4. FastAPI proxies the request to LiteLLM; streaming tokens are appended to MessageBubble in real time.
5. On stream end, message fully rendered and cached indefinitely (`staleTime=0`, `gcTime=∞`).

## Email Send Flow
1. User composes email in ComposeWindow, clicks Send.
2. Frontend calls `POST /v1/email/send` through `~services/api.ts`.
3. FastAPI authenticates via JWT and forwards the request to Nylas API.
4. Nylas sends the email; webhook notifications are received by an Edge Function and upserted into the `emails` table.
5. Realtime subscription pushes the sent email to the UnifiedInbox.
