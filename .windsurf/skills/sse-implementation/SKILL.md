---
name: sse-implementation
description: Guides the implementation of Server-Sent Events (SSE) for real-time streaming in chat interfaces and live data feeds
---

## SSE Implementation Guide

Server-Sent Events (SSE) enable real-time unidirectional communication from server to client. Use this skill when implementing chat streaming, live status updates, or real-time data feeds.

## useSSE Hook Pattern

Create a reusable SSE hook in `src/hooks/useSSE.ts`:

```typescript
interface UseSSEOptions {
  url: string;
  onMessage?: (data: any) => void;
  onError?: (error: Event) => void;
  onOpen?: () => void;
  onClose?: () => void;
  reconnectInterval?: number;
  maxReconnectAttempts?: number;
}

interface UseSSEReturn {
  isConnected: boolean;
  data: any | null;
  error: Event | null;
  reconnectAttempt: number;
  connect: () => void;
  disconnect: () => void;
}

export function useSSE({
  url,
  onMessage,
  onError,
  onOpen,
  onClose,
  reconnectInterval = 3000,
  maxReconnectAttempts = 5,
}: UseSSEOptions): UseSSEReturn {
  const [isConnected, setIsConnected] = useState(false);
  const [data, setData] = useState<any>(null);
  const [error, setError] = useState<Event | null>(null);
  const [reconnectAttempt, setReconnectAttempt] = useState(0);
  const eventSourceRef = useRef<EventSource | null>(null);
  const reconnectTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  const connect = useCallback(() => {
    // Close existing connection
    if (eventSourceRef.current) {
      eventSourceRef.current.close();
    }

    // Clear any pending reconnect
    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current);
    }

    try {
      const eventSource = new EventSource(url);
      eventSourceRef.current = eventSource;

      eventSource.onopen = () => {
        setIsConnected(true);
        setError(null);
        setReconnectAttempt(0);
        onOpen?.();
      };

      eventSource.onmessage = (event) => {
        try {
          const parsedData = JSON.parse(event.data);
          setData(parsedData);
          onMessage?.(parsedData);
        } catch (parseError) {
          console.error('Failed to parse SSE data:', parseError);
          // Handle non-JSON data
          setData(event.data);
          onMessage?.(event.data);
        }
      };

      eventSource.onerror = (event) => {
        setIsConnected(false);
        setError(event as Event);
        onError?.(event as Event);
        
        eventSource.close();

        // Attempt reconnection if under max attempts
        if (reconnectAttempt < maxReconnectAttempts) {
          setReconnectAttempt((prev) => prev + 1);
          reconnectTimeoutRef.current = setTimeout(() => {
            connect();
          }, reconnectInterval);
        }
      };
    } catch (err) {
      setError(err as Event);
      onError?.(err as Event);
    }
  }, [url, onMessage, onError, onOpen, onClose, reconnectInterval, maxReconnectAttempts, reconnectAttempt]);

  const disconnect = useCallback(() => {
    if (eventSourceRef.current) {
      eventSourceRef.current.close();
      eventSourceRef.current = null;
    }
    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current);
      reconnectTimeoutRef.current = null;
    }
    setIsConnected(false);
    onClose?.();
  }, [onClose]);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      disconnect();
    };
  }, [disconnect]);

  return {
    isConnected,
    data,
    error,
    reconnectAttempt,
    connect,
    disconnect,
  };
}
```

## Chat Streaming Implementation

Use SSE for real-time chat message streaming:

```typescript
// src/hooks/useChatStream.ts
import { useSSE } from './useSSE';

export function useChatStream(threadId: string) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [isStreaming, setIsStreaming] = useState(false);

  const { isConnected, data, error, connect, disconnect } = useSSE({
    url: `/api/v1/chat/${threadId}/stream`,
    onMessage: (data) => {
      if (data.type === 'message_chunk') {
        // Append streaming chunk
        setMessages((prev) => {
          const lastMessage = prev[prev.length - 1];
          if (lastMessage && lastMessage.id === data.messageId) {
            // Update existing message
            return [
              ...prev.slice(0, -1),
              { ...lastMessage, content: lastMessage.content + data.content },
            ];
          } else {
            // New message
            return [...prev, { id: data.messageId, content: data.content, role: data.role }];
          }
        });
      } else if (data.type === 'message_complete') {
        setIsStreaming(false);
      } else if (data.type === 'tool_call') {
        // Handle tool call disclosure
        setMessages((prev) => [
          ...prev,
          {
            id: data.toolId,
            type: 'tool_call',
            tool: data.tool,
            args: data.args,
            result: data.result,
          },
        ]);
      }
    },
    onError: (error) => {
      console.error('Chat stream error:', error);
      setIsStreaming(false);
    },
    onOpen: () => {
      setIsStreaming(true);
    },
  });

  const startStreaming = useCallback(() => {
    connect();
  }, [connect]);

  const stopStreaming = useCallback(() => {
    disconnect();
    setIsStreaming(false);
  }, [disconnect]);

  return {
    messages,
    isStreaming,
    isConnected,
    error,
    startStreaming,
    stopStreaming,
  };
}
```

## Agent Status Streaming

Use SSE for real-time agent status updates:

```typescript
// src/hooks/useAgentStatusStream.ts
import { useSSE } from './useSSE';

export function useAgentStatusStream() {
  const [agentStatuses, setAgentStatuses] = useState<Map<string, AgentStatus>>(new Map());

  const { isConnected, connect, disconnect } = useSSE({
    url: '/api/v1/agents/stream',
    onMessage: (data) => {
      if (data.type === 'agent_status_update') {
        setAgentStatuses((prev) => {
          const updated = new Map(prev);
          updated.set(data.agentId, {
            id: data.agentId,
            status: data.status,
            currentTask: data.currentTask,
            tokenSpend: data.tokenSpend,
            uptime: data.uptime,
          });
          return updated;
        });
      } else if (data.type === 'agent_thinking') {
        setAgentStatuses((prev) => {
          const updated = new Map(prev);
          const existing = updated.get(data.agentId);
          updated.set(data.agentId, {
            ...existing,
            status: 'thinking',
          });
          return updated;
        });
      }
    },
  });

  useEffect(() => {
    connect();
    return () => disconnect();
  }, [connect, disconnect]);

  return {
    agentStatuses,
    isConnected,
  };
}
```

## SSE Best Practices (2026)

**Connection Management**

- Always clean up EventSource connections on unmount
- Implement exponential backoff for reconnection
- Set maximum reconnection attempts to prevent infinite loops
- Provide manual connect/disconnect controls for user control
- Handle page visibility changes (pause when tab hidden)
- Use Last-Event-ID for message recovery after reconnection

**Error Handling**

- Handle connection errors gracefully
- Show user-friendly error messages
- Implement retry logic with backoff
- Log errors for debugging
- Distinguish between network errors and parse errors

**Data Parsing**

- Always wrap JSON.parse in try-catch
- Handle both JSON and plain text data
- Validate data structure before use
- Use TypeScript interfaces for type safety
- Support custom event types with addEventListener

**Performance**

- Debounce rapid message updates if needed
- Use requestAnimationFrame for UI updates
- Batch multiple messages when possible
- Consider using React.memo for message components
- Monitor memory usage for long-running connections
- Implement backpressure handling for high-frequency updates

**Accessibility**

- Announce new messages to screen readers
- Provide pause/resume controls for streaming
- Show clear loading and error states
- Use ARIA live regions for dynamic content
- Respect prefers-reduced-motion for animations

**Security**

- Validate all incoming data
- Sanitize HTML content before rendering
- Use HTTPS for SSE connections
- Implement authentication (query params, cookies, or fetch-based with headers)
- Configure CORS properly on server side
- Rate limit connections to prevent abuse

**Production Considerations**

- Monitor connection health and metrics
- Set connection limits per user
- Implement graceful degradation when SSE unavailable
- Consider fallback to polling for unsupported browsers
- Add observability for connection lifecycle events

## Component Integration Example

```typescript
// src/components/chat/ChatInterface.tsx
import { useChatStream } from '@/hooks/useChatStream';

export function ChatInterface({ threadId }: { threadId: string }) {
  const { messages, isStreaming, isConnected, error, startStreaming, stopStreaming } = useChatStream(threadId);

  useEffect(() => {
    startStreaming();
    return () => stopStreaming();
  }, [threadId, startStreaming, stopStreaming]);

  return (
    <div className="flex flex-col h-full">
      <div className="flex-1 overflow-y-auto">
        {messages.map((message) => (
          <MessageBubble key={message.id} message={message} />
        ))}
        
        {isStreaming && (
          <div className="animate-pulse text-gray-400">Agent is thinking...</div>
        )}
        
        {error && (
          <div className="text-red-400">Connection error: {error.message}</div>
        )}
      </div>
      
      <div className="border-t border-white/10 p-4">
        <StatusIndicator 
          connected={isConnected} 
          streaming={isStreaming} 
        />
        <ChatInput threadId={threadId} />
      </div>
    </div>
  );
}
```

## Testing SSE Hooks

```typescript
// src/hooks/__tests__/useSSE.test.ts
import { renderHook, act, waitFor } from '@testing-library/react';
import { useSSE } from '../useSSE';

// Mock EventSource
class MockEventSource {
  url: string;
  onopen: (() => void) | null = null;
  onmessage: ((event: MessageEvent) => void) | null = null;
  onerror: ((event: Event) => void) | null = null;
  readyState: number = 0;

  constructor(url: string) {
    this.url = url;
  }

  close() {
    this.readyState = 2; // CLOSED
  }

  // Helper to simulate message
  simulateMessage(data: any) {
    this.onmessage?.(new MessageEvent('message', { data: JSON.stringify(data) }));
  }

  // Helper to simulate error
  simulateError() {
    this.onerror?.(new Event('error'));
  }
}

global.EventSource = MockEventSource as any;

describe('useSSE', () => {
  it('connects to SSE endpoint', () => {
    const { result } = renderHook(() => useSSE({ url: '/api/stream' }));
    
    expect(result.current.isConnected).toBe(true);
  });

  it('receives and parses messages', async () => {
    const onMessage = vi.fn();
    const { result } = renderHook(() => useSSE({ 
      url: '/api/stream',
      onMessage,
    }));

    const eventSource = (result.current as any).eventSourceRef.current;
    
    act(() => {
      eventSource.simulateMessage({ type: 'test', data: 'hello' });
    });

    await waitFor(() => {
      expect(onMessage).toHaveBeenCalledWith({ type: 'test', data: 'hello' });
    });
  });

  it('handles connection errors', async () => {
    const onError = vi.fn();
    const { result } = renderHook(() => useSSE({ 
      url: '/api/stream',
      onError,
    }));

    const eventSource = (result.current as any).eventSourceRef.current;
    
    act(() => {
      eventSource.simulateError();
    });

    await waitFor(() => {
      expect(result.current.error).toBeTruthy();
      expect(onError).toHaveBeenCalled();
    });
  });

  it('cleans up on unmount', () => {
    const { result, unmount } = renderHook(() => useSSE({ url: '/api/stream' }));
    
    const eventSource = (result.current as any).eventSourceRef.current;
    
    unmount();
    
    expect(eventSource.readyState).toBe(2); // CLOSED
  });
});
```

## Common Pitfalls

1. **Memory leaks**: Not cleaning up EventSource on unmount
2. **Infinite reconnection**: Not setting max reconnection attempts
3. **Race conditions**: Multiple simultaneous connections
4. **Parse errors**: Not handling malformed JSON
5. **UI thrashing**: Updating state too rapidly during streaming
6. **Missing error handling**: Not showing user-friendly error messages
7. **No user control**: No way to pause/resume streaming
