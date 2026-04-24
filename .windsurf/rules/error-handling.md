---
trigger: glob
globs: src/**/*.tsx
---

# Error Handling Rules

All components must handle errors gracefully:

<!-- SECTION: error_boundaries -->

<error_boundaries>

- Wrap route components in error boundaries
- Show user-friendly error messages
- Provide recovery options (retry, go back)
- Log errors to console (and monitoring in production)
- Preserve component state when possible

</error_boundaries>

<!-- ENDSECTION: error_boundaries -->

<!-- SECTION: api_errors -->

<api_errors>

- Handle 404, 500, and network errors
- Show appropriate error messages
- Implement retry logic for transient failures
- Use TanStack Query's error handling
- Distinguish between client and server errors

</api_errors>

<!-- ENDSECTION: api_errors -->

<!-- SECTION: loading_states -->

<loading_states>

- Show skeleton loaders for all data fetches
- Show loading indicators for async actions
- Disable buttons during loading
- Prevent duplicate submissions
- Show progress for long-running operations

</loading_states>

<!-- ENDSECTION: loading_states -->

<!-- SECTION: empty_states -->

<empty_states>

- Show empty states for empty lists
- Provide clear CTAs for empty states
- Use appropriate icons and illustrations
- Explain why data is empty
- Offer actions to populate data

</empty_states>

<!-- ENDSECTION: empty_states -->

<!-- SECTION: user_feedback -->

<user_feedback>

- Show toast notifications for actions
- Provide success/error feedback
- Use consistent notification patterns
- Allow users to dismiss notifications
- Group related notifications

</user_feedback>

<!-- ENDSECTION: user_feedback -->

<!-- SECTION: fallback_uis -->

<fallback_uis>

- Provide fallback for failed component loads
- Show error messages for failed images
- Gracefully degrade for missing features
- Provide offline indicators
- Handle service worker errors

</fallback_uis>

<!-- ENDSECTION: fallback_uis -->
