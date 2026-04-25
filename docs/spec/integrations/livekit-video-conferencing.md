---
id: integration.livekit-video-conferencing
title: LiveKit (Video Conferencing)
type: integration
status: draft
version: 1.0.0
compressed: 'Purpose: real-time video/audio; Token Generation: FastAPI /v1/livekit/token; Token TTL:6h; Room mgmt: conferenceRooms table; Provider: LiveKitProvider wraps conference routes; Features: screen share,recording,breakout rooms,live captions; Data Channels: Engagement tools via LiveKit DataChannels; Agent Pipeline: STT→LLM→TTS (livekit-agents v1),agent generates real-time meeting summaries,posts to Supabase; supports live captions for WCAG1.2.4; Engagement tools(polls,Q&A,chat) transmitted via DataChannels,not SSE'
Purpose: 'real-time video/audio; Token Generation: FastAPI /v1/livekit/token; Token TTL:6h; Room mgmt: conferenceRooms table; Provider: LiveKitProvider wraps conference routes; Features: screen share,recording,breakout rooms,live captions; Data Channels: Engagement tools via LiveKit DataChannels; Agent Pipeline: STT→LLM→TTS (livekit-agents v1),agent generates real-time meeting summaries,posts to Supabase; supports live captions for WCAG1.2.4; Engagement tools(polls,Q&A,chat) transmitted via DataChannels,not SSE'
last_updated: '2026-04-24T23:37:09.430516+00:00'
---

# LiveKit (Video Conferencing)

Purpose: real-time video/audio; Token Generation: FastAPI /v1/livekit/token; Token TTL:6h; Room mgmt: conferenceRooms table; Provider: LiveKitProvider wraps conference routes; Features: screen share,recording,breakout rooms,live captions; Data Channels: Engagement tools via LiveKit DataChannels; Agent Pipeline: STT→LLM→TTS (livekit-agents v1),agent generates real-time meeting summaries,posts to Supabase; supports live captions for WCAG1.2.4; Engagement tools(polls,Q&A,chat) transmitted via DataChannels,not SSE
