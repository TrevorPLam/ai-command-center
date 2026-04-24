---
trigger: glob
globs: src/**/*.tsx, src/**/*.ts
---

# Testing Rules

All code should be testable and follow testing best practices:

<!-- SECTION: testing_approach -->

<testing_approach>

- Use React Testing Library for component testing
- Use Vitest for unit testing
- Use Playwright for end-to-end testing
- Write tests for critical user flows and components
- Test behavior, not implementation details

</testing_approach>

<!-- ENDSECTION: testing_approach -->

<!-- SECTION: component_testing -->

<component_testing>

- Test user interactions and state changes
- Test accessibility (keyboard navigation, screen readers)
- Test error states and loading states
- Mock external dependencies (API calls, stores)
- Use describe/it/test blocks with clear descriptions

</component_testing>

<!-- ENDSECTION: component_testing -->

<!-- SECTION: hook_testing -->

<hook_testing>

- Test custom hooks with @testing-library/react
- Test hook return values and state changes
- Test error handling in hooks
- Mock dependencies (API calls, stores)
- Test hook cleanup with unmount
- Use renderHook from @testing-library/react for hook testing

</hook_testing>

<!-- ENDSECTION: hook_testing -->

<!-- SECTION: testing_coverage -->

<testing_coverage>

- Aim for 80%+ code coverage on critical paths
- Test all user-facing components
- Test all custom hooks
- Test error boundaries and error handling
- Test loading and empty states

</testing_coverage>

<!-- ENDSECTION: testing_coverage -->

<!-- SECTION: test_naming -->

<test_naming>

- Use descriptive test names that explain what is being tested
- Follow pattern: "should [do something] when [condition]"
- Group related tests with describe blocks
- Use beforeEach/afterEach for setup/teardown

</test_naming>

<!-- ENDSECTION: test_naming -->
