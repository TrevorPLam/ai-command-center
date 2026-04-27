---
title: "AI Architecture"
owner: "AI/ML Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---

This document describes the AI architecture including intent dispatcher, local-first gateway, verifier cascade, cost model, and model trust registry.

---

## Intent Dispatcher

The **Intent Dispatcher** is a pure-code middleware that sits between the AI orchestrator and the tool execution layer. Its job is to route every potential action to the **cheapest, fastest, most reliable executor** that can handle it.

- **Layer 1: Deterministic Code.** Database queries, rule engines, schema validators. Called directly by the orchestrator via a tool definition. No LLM involved in execution.
- **Layer 2: Lightweight Models (Qwen 3.5 4B or local).** Simple NLP tasks: extract structured data from an email, classify intent, summarize a short thread.
- **Layer 3: Powerful Models (Sonnet 4.6 / Opus 4.7).** Complex reasoning, multi-step planning, open-ended conversation.

The orchestrator itself (an LLM) uses this dispatcher to execute tools efficiently.

---

## Local-First Gateway Extension

The multi-provider AI gateway is extended with a **local execution tier** as the default route. Every model definition now includes:

- `execution_location`: `local` | `cloud` | `hybrid`
- `privacy_tier`: `sovereign` | `shared` | `third_party`

**Default routing policy (Phase 0):**

1. Gemma 4 E2B/E4B (local) - orchestrator
2. Qwen3.5 4B (local) - tool executor, 97.5% tool-calling accuracy
3. Phi-4-mini-reasoning (local) - verifier (Phase 1)
4. Claude Sonnet 4.6 (cloud) - paid tier only, for tasks exceeding local capability
5. Claude Opus 4.7 (cloud) - premium tier only, for complex multi-step reasoning

---

## Verifier Cascade

Before any agentic action is committed, a lightweight local verifier model (Phi-4-mini-reasoning) performs a structured check:

1. **Reasoning soundness**: Was the orchestrator's plan coherent?
2. **Schema validity**: Does the proposed tool call match the tool's JSON schema?
3. **Permission budget**: Is the action within the user's role and cost limits?

All verifier decisions are logged to `audit_logs`. Verifier model is evaluated monthly; if accuracy drops below 90%, it is retrained or replaced.

---

## Cost Model

| Execution Mode | Cost Model | Marginal Cost | Used By |
| :--- | :--- | :--- | :--- |
| Local CPU (Ollama/llama.cpp) | Fixed: electricity + hardware amortization | ~$0.00001/1K tokens | Free tier default |
| Self-hosted GPU (vLLM) | Fixed: GPU amortization + electricity | ~$0.0001/1K tokens | Team tier with dedicated hardware |
| Cloud API (Claude/Gemini) | Variable: per-token pricing | $3-$75/1M tokens | Paid tiers only |

---

## Model Trust Registry

A structured catalog of all models (local and cloud) with attested capabilities:

- Tool-calling pass rate (from automated test suite)
- Hallucination rate on evaluation datasets
- Latency profiles (TTFT, TPS) on target hardware
- Security audit status (for cloud models)
- Last verification date

All models must be registered before they can participate in agentic workflows. The registry is part of Agent Studio.

---

## Example: Conflict Detection Flow

1. User says "Check for scheduling conflicts."
2. Orchestrator (Sonnet 4.6) decides to call the `detect_conflicts` tool.
3. Dispatcher sees `detect_conflicts` is a pure-code function (overlap algorithm on DB records) → executes it directly, returns result.
4. Orchestrator formats a natural-language response from the result.

**No Opus call. Only one Sonnet call for intent and formatting.**

---

## Configuration

- Tool definitions include a `preferred_executor` field (code, haiku, sonnet, opus).

- Run-time cost and latency budgets can force fallback (e.g., code if under budget, else haiku).
