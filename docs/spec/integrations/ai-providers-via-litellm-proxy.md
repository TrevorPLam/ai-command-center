---
id: integration.ai-providers-via-litellm-proxy
title: AI Providers (via LiteLLM Proxy)
type: integration
status: draft
version: 1.0.0
compressed: 'Purpose: unified AI model access; Proxy: LiteLLM sidecar on litellm:4000; Routing: all AI calls→LiteLLM only(GC9); Model Assignments: chat:gpt-4o→claude-3-7 fallback,embed:text-embedding-3-small→local fallback,img:dall-e-3,tts:openai/tts-1,stt:whisper-1,vision:gpt-4o; Circuit Breaker:5 consecutive failures/60s→fallback chain,alert Sentry; Cost Tracking: all requests logged to ai_cost_log(tokens,model,user,org); Rate Limit: exceeding hard cap returns RATE_LIMITED(S20)'
Purpose: 'unified AI model access; Proxy: LiteLLM sidecar on litellm:4000; Routing: all AI calls→LiteLLM only(GC9); Model Assignments: chat:gpt-4o→claude-3-7 fallback,embed:text-embedding-3-small→local fallback,img:dall-e-3,tts:openai/tts-1,stt:whisper-1,vision:gpt-4o; Circuit Breaker:5 consecutive failures/60s→fallback chain,alert Sentry; Cost Tracking: all requests logged to ai_cost_log(tokens,model,user,org); Rate Limit: exceeding hard cap returns RATE_LIMITED(S20)'
last_updated: '2026-04-24T23:37:09.431666+00:00'
---

# AI Providers (via LiteLLM Proxy)

Purpose: unified AI model access; Proxy: LiteLLM sidecar on litellm:4000; Routing: all AI calls→LiteLLM only(GC9); Model Assignments: chat:gpt-4o→claude-3-7 fallback,embed:text-embedding-3-small→local fallback,img:dall-e-3,tts:openai/tts-1,stt:whisper-1,vision:gpt-4o; Circuit Breaker:5 consecutive failures/60s→fallback chain,alert Sentry; Cost Tracking: all requests logged to ai_cost_log(tokens,model,user,org); Rate Limit: exceeding hard cap returns RATE_LIMITED(S20)
