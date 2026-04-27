# Supabase Realtime Memory Profile

## Overview

Research on Supabase Realtime memory characteristics to establish channel usage
guidelines that keep memory under 40MB per client/instance.

## Architecture Summary

Supabase Realtime is built on Elixir/Phoenix using lightweight processes (not OS
processes). Channels use Phoenix.PubSub with PG2 adapter for pub/sub messaging.
Each WebSocket connection can subscribe to multiple channels.

## Memory Characteristics

### Per-Connection Memory

- **Base overhead**: Each WebSocket connection maintains Erlang process state
- **Channel memory**: Each channel subscription adds process overhead
- **Presence state**: In-memory CRDT stores shared state per channel
- **Message buffers**: Temporary storage for in-flight messages

### Known Memory Issues

1. **Channel leaks**: Creating channels without cleanup causes memory bloat
   - Common in React apps when useEffect runs multiple times
   - Missing cleanup functions cause orphaned channels
   - StrictMode doubles effect runs in development

2. **Replication state bloat**: Historical issue where change records stored as final structs
   - Fixed in PR #131 by broadcasting binary instead of JSON
   - Minimal data now stored in Replication state

3. **Garbage collection**: Long-lived processes delay GC until 65k sweeps
   - Can force GC sooner with `:erlang.garbage_collect()`
   - Consider `ERL_FULLSWEEP_AFTER` tuning for production

## Channel Limits

### Plan Limits

- **Channels per connection**: Up to 100 for most plans
- **Concurrent peak connections**: 200 (Free), 500 (Pro), custom (Enterprise)
- **Channel join rate**: Limited per project to prevent resource exhaustion

### Payload Size Benchmarks

Supabase tests with payload sizes up to 50KB. Larger payloads increase memory pressure and latency.

## Recommended Guidelines

### Channel Usage Per User

| Metric                    | Recommended Limit | Rationale                             |
|---------------------------|-------------------|---------------------------------------|
| Channels per connection   | ≤10               | Conservative for 40MB budget          |
| Presence channels per user| ≤5                | Presence state adds memory overhead   |
| Broadcast channels per user| ≤5                | Message buffers scale with throughput|
| Total channels per user   | ≤10               | Balances functionality with memory    |

### Payload Size Limits

| Message Type       | Recommended Size | Rationale                               |
|--------------------|------------------|-----------------------------------------|
| Presence updates   | ≤1KB             | Frequent sync events                    |
| Broadcast messages | ≤10KB            | Typical chat/notification size          |
| Postgres changes   | ≤50KB            | Matches Supabase benchmark max          |
| Binary attachments | Use separate storage| Avoid large payloads in Realtime         |

### Memory Budget Allocation

For 40MB total budget:

- **Connection overhead**: ~5MB (WebSocket, Erlang process)

- **Channel processes**: ~2MB per channel (10 channels = ~20MB)

- **Presence state**: ~5MB (CRDT storage)

- **Message buffers**: ~5MB (in-flight messages)

- **Margin**: ~5MB (GC overhead, spikes)

## Implementation Best Practices

### Channel Lifecycle Management

```typescript
// ✅ CORRECT - Singleton client with cleanup
const supabase = createClient(SUPABASE_URL, SUPABASE_KEY)

function ChatRoom() {
  useEffect(() => {
    const channel = supabase
      .channel('chat')
      .on('broadcast', { event: 'message' }, (payload) => {
        console.log(payload)
      })
      .subscribe()

    // ALWAYS cleanup
    return () => {
      channel.unsubscribe()
    }
  }, [])
}
```

### Monitoring

Use Supabase Realtime Reports to track:

- Connected Clients count

- Rate of Channel Joins

- Message Payload Size

- Response Errors

### Garbage Collection

For self-hosted deployments, consider:

```erlang
% Force GC on long-lived processes
:erlang.garbage_collect(ProcessPid)
```

## Context References

- Rules BE-07, BE-11
- 80-OPS-PERFORMANCE.md
- [Supabase Realtime Limits](https://supabase.com/docs/guides/realtime/limits)
- [Supabase Realtime Architecture](https://supabase.com/docs/guides/realtime/architecture)
