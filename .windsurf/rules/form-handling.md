---
trigger: glob
globs: src/components/**/*Form.tsx, src/components/**/*Settings.tsx
---

# Form Handling Rules

All forms must follow consistent patterns for validation and error handling:

<form_library>

- Use React Hook Form for all form state management
- Use Zod for schema validation
- Use shadcn/ui form components as base
- Keep form logic separate from UI components

</form_library>

<validation>

- Define Zod schemas for all forms
- Validate on blur and on submit
- Show inline error messages
- Disable submit button when form is invalid
- Show validation errors in real-time

</validation>

<error_handling>

- Display clear, actionable error messages
- Show field-specific errors inline
- Show form-level errors at the top
- Handle API errors gracefully
- Show loading states during submission

</error_handling>

<form_structure>

- Group related fields with fieldsets
- Use proper labels and aria-describedby for errors
- Implement keyboard navigation
- Support auto-save where appropriate
- Confirm destructive actions with modals

</form_structure>

<typescript_types>

- Use TypeScript interfaces for form data
- Infer types from Zod schemas
- Type form values and errors
- Use proper typing for custom form components

</typescript_types>
