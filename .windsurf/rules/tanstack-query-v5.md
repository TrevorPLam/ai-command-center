---
trigger: glob
globs: src/hooks/*.ts, src/api/*.ts
---

# TanStack Query v5 Rules

This project uses TanStack Query v5 for server state management. Follow these v5-specific patterns.

<v5_api_changes>
- isLoading is now derived: isPending && isFetching
- isInitialLoading is deprecated, use isLoading
- Use isPending for initial loading state
- Use isFetching for any refetch in progress
- QueryClient defaults have changed
</v5_api_changes>

<query_setup>

```typescript
// src/api/client.ts
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      gcTime: 10 * 60 * 1000, // 10 minutes (was cacheTime in v4)
      refetchOnWindowFocus: false,
      refetchOnReconnect: true,
      retry: 3,
      retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000),
    },
  },
});
```

</query_setup>

<hook_patterns>

```typescript
// v5 pattern: use isPending for initial loading
export function useProjects() {
  const { data, isPending, error, isFetching } = useQuery({
    queryKey: ['projects'],
    queryFn: () => fetch('/api/v1/projects').then(res => res.json()),
  });

  // isPending = true on first load, false after
  // isFetching = true during any refetch
  // isLoading (derived) = isPending && isFetching

  return {
    projects: data,
    isLoading: isPending, // Use isPending for initial load
    isRefetching: isFetching && !isPending, // Refetching but not initial load
    error,
  };
}
```

</hook_patterns>

<mutation_patterns>

```typescript
export function useCreateProject() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (project: Partial<Project>) => 
      fetch('/api/v1/projects', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(project),
      }).then(res => res.json()),
    onSuccess: (data) => {
      // Invalidate queries
      queryClient.invalidateQueries({ queryKey: ['projects'] });
      
      // Or update cache directly for optimistic updates
      queryClient.setQueryData(['projects'], (old: Project[]) => [...old, data]);
    },
    onError: (error) => {
      console.error('Mutation failed:', error);
    },
  });
}
```

</mutation_patterns>

<query_keys>
- Use arrays for query keys: ['resource', 'id', 'params']
- Include all parameters that affect the data
- Use consistent key patterns across the app
- Serialize complex parameters in query keys
- Use queryKeyFactory for reusable key patterns
</query_keys>

<cache_management>
- Use staleTime to control data freshness
- Use gcTime (was cacheTime) for garbage collection
- Invalidate queries after mutations
- Use setQueryData for optimistic updates
- Use cancelQueries to cancel in-flight requests
</cache_management>

<error_handling>
- Handle error states in components
- Show user-friendly error messages
- Implement retry logic with exponential backoff
- Distinguish between network and server errors
- Use error boundaries for catastrophic failures
</error_handling>

<loading_states>
- Use isPending for initial loading state
- Use isFetching for refetching state
- Show skeleton loaders for isPending
- Show subtle indicators for isFetching
- Use Suspense boundaries for loading states
</loading_states>

<pagination>
- Use infiniteQuery for infinite scroll
- Implement cursor-based pagination
- Use initialPageParam (required in v5) instead of default parameter
- Use hasNextPage and fetchNextPage
- Manage isFetchingNextPage state
- Handle error recovery in pagination
- getNextPageParam is now required for infinite queries
- getNextPageParam can return null to indicate no more pages (in addition to undefined)
</pagination>

<optimistic_updates>
- Use setQueryData for immediate UI updates
- Rollback on mutation failure
- Use cache updater functions
- Keep updates simple and predictable
- Test rollback scenarios
</optimistic_updates>

<devtools>
- Install @tanstack/react-query-devtools
- Add DevTools component in development
- Use for debugging query states
- Monitor cache performance
- Inspect mutation history
</devtools>

<typescript_types>
- Define interfaces for all data types
- Use generics for query hooks
- Type mutation variables and responses
- Use infer types from Zod schemas
- Enable strict mode in TypeScript
</typescript_types>
