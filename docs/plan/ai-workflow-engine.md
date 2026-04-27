---
title: "AI Workflow Engine"
owner: "AI/ML Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---

This document describes the AI workflow engine including LangGraph integration, memory management, tool integration, and multi-agent orchestration.

---

## LangGraph Integration

- **Pattern**: Supervisor pattern maps to FLOWC01 state machine
- **Transitions**: StateGraph edges for state transitions
- **State Management**: Deterministic state transitions with checkpointing

---

## Memory Management

### LangMem

- **Purpose**: Cross-session summarization with semantic, episodic, and procedural memory
- **Replacement**: Replaces simple FIFO memory
- **Storage**: Episodic memory tier for long-term context retention
- **Memory Types**:
  - Semantic: User preferences and factual knowledge (e.g., "user works in Pacific time, prefers Python examples")
  - Episodic: Past interactions distilled as few-shot examples (e.g., "last time the agent solved X by doing Y")
  - Procedural: Updated system instructions the agent writes to itself (e.g., "always confirm before deleting") - unique to LangMem
- **Performance Issues**: TASK INFORMATION INCORRECT - LangMem has severe performance limitations:
  - p95 search latency: 59.82 seconds on LOCOMO benchmark (not a typo)
  - Accuracy: 58.10% on LOCOMO vs Mem0's 67.13% with 0.200s p95 latency
  - NOT suitable for interactive user-facing agents due to extremely high latency
- **Recommended Use**: Background/batch memory tasks or non-latency-sensitive applications only
- **Alternative**: Mem0 (0.200s p95, 67.13% LOCOMO accuracy) for interactive production agents requiring sub-second memory retrieval
- **Configuration**: Requires embedding index (dims + embed model) for semantic search; store.search() returns nothing without it

**Code Example:**

```python
from langmem import create_manage_memory_tool, create_search_memory_tool
from langgraph.store.memory import InMemoryStore
from langgraph.prebuilt import create_react_agent

# Embedding index REQUIRED for semantic search
store = InMemoryStore(
    index={
        "dims": 1536,
        "embed": "openai:text-embedding-3-small",
    }
)

# Namespace under user ID (NOT thread_id)
manage_memory = create_manage_memory_tool(namespace=("user-123",))
search_memory = create_search_memory_tool(namespace=("user-123",))

agent = create_react_agent(
    model=init_chat_model("anthropic/claude-3-5-sonnet-20241022"),
    tools=[manage_memory, search_memory],
    store=store
)

# Production: replace InMemoryStore with PostgresStore
# from langgraph.store.postgres import PostgresStore
# store = PostgresStore.from_conn_string("postgresql://user:pass@host/dbname")
```

---

## Tool Integration

### Trustcall

- **Function**: Reliable structured data extraction using JSON patch operations
- **Purpose**: Addresses two main LLM limitations:
  1. Populating complex, nested schemas (LLMs struggle with deeply nested structures)
  2. Updating existing schemas without information loss (LLMs often omit data when regenerating)
- **Approach**: Uses JSON patch operations to focus LLM on what has changed, reducing information loss
- **Benefits**: Increases extraction reliability without restricting to subset of JSON schema
- **Use Cases**: Complex schema extraction, memory management updates, simultaneous updates & insertions

**Code Example:**

```python
from trustcall import create_extractor
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-4o")
bound = create_extractor(llm, tools=[UserSchema])

# Update existing object with new information
result = bound.invoke({
    "messages": [{"role": "user", "content": "Update memory with new info"}],
    "existing": {"UserSchema": current_state.model_dump()}
})
```

- **Validation**: All tool calls schema-validated before execution
- **Error Handling**: Graceful fallbacks for invalid tool calls

---

## Multi-Agent Orchestration

### Supervisor Pattern

- **Architecture**: Central orchestrator agent delegates to specialized worker agents
- **Communication**: Workers only communicate through supervisor (no direct worker-to-worker or worker-to-user communication)
- **Implementation**: LangGraph `create_supervisor` with StateGraph nodes
- **Effectiveness**: Slightly underperforms swarm architecture due to "translation" overhead (supervisor acts as middleman between sub-agents and user)
- **Token Cost**: Uses more tokens than swarm for same reason (supervisor paraphrases sub-agent responses)
- **Advantages**: Most generic architecture (fewest assumptions about sub-agents), feasible for all multi-agent scenarios including third-party agents
- **Best For**: Open-ended reasoning, iterative research, complex multi-turn dialogues where path isn't known upfront
- **Trade-offs**: Graphs can become "spaghetti" without strict Supervisor boundaries
- **Improvements**: Removing handoff messages (de-clutters context), forwarding messages tool (reduces paraphrasing errors), tool naming optimization

**Code Example:**

```python
from langgraph.prebuilt import create_supervisor
from langgraph.graph import StateGraph

# Define workers
researcher = create_react_agent(model, tools=[search_tool])
coder = create_react_agent(model, tools=[code_tool])

# Supervisor orchestrates workers
supervisor = create_supervisor(
    [researcher, coder],
    initial_prompt="You are the Boss. Route the task to the right expert."
)

# Build graph
builder = StateGraph(State)
builder.add_node("researcher", researcher)
builder.add_node("coder", coder)
builder.add_node("supervisor", supervisor)
builder.add_edge("researcher", "supervisor")
builder.add_edge("coder", "supervisor")
builder.set_entry_point("supervisor")
graph = builder.compile()
```

### Swarm

- **Capability**: Multi-agent orchestration with direct agent-to-agent handoffs
- **Protocol**: Handoff protocol for agent-to-agent transfers
- **Coordination**: Centralized coordinator for agent scheduling
- **Performance**: Slightly outperforms supervisor architecture due to no translation layer (agents respond directly to user)
- **Limitations**: Each sub-agent must know all other agents (not feasible with third-party agents)

---

## Observability

### OpenTelemetry

- **Attributes**: `gen_ai.*` attributes on all workflow nodes
- **Root Span**: Distributed tracing via DataPrepper
- **Coverage**: 100% of AI workflow executions traced

---

## Cost Management

- **Metering**: All tool calls metered
- **Budget Check**: Synchronous budget check (COST03 rule)
- **Alerts**: Real-time cost threshold alerts
