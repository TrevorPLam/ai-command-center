---
name: form-components
description: Guides the creation of form components using react-hook-form with proper validation, error handling, and accessibility for all form inputs across the application
---

## Overview

This skill guides the implementation of form components using react-hook-form, the performant form library for React.

## Required Dependencies

```bash
npm install react-hook-form zod @hookform/resolvers
```

## Core Concepts

### react-hook-form Setup

- Use `useForm` hook for form state management
- Use `zod` for schema validation
- Use `@hookform/resolvers` to integrate zod with react-hook-form
- Use `Controller` for controlled components (shadcn/ui components)

### Validation

- Define schemas using zod
- Provide clear error messages
- Validate on submit and on blur
- Show inline error messages

### Accessibility

- Use proper labels for all inputs
- Associate labels with inputs using `htmlFor`
- Provide ARIA descriptions for errors
- Ensure keyboard navigation works
- Use semantic form elements

## Component Patterns

### Form with Validation

```typescript
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';

const schema = z.object({
  name: z.string().min(1, 'Name is required'),
  email: z.string().email('Invalid email address'),
});

type FormData = z.infer<typeof schema>;

function MyForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const onSubmit = async (data: FormData) => {
    // Submit logic
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div>
        <label htmlFor="name">Name</label>
        <Input id="name" {...register('name')} />
        {errors.name && <span className="error">{errors.name.message}</span>}
      </div>
      <div>
        <label htmlFor="email">Email</label>
        <Input id="email" {...register('email')} />
        {errors.email && <span className="error">{errors.email.message}</span>}
      </div>
      <Button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Submitting...' : 'Submit'}
      </Button>
    </form>
  );
}
```

### Controlled Component with Controller

```typescript
import { useForm, Controller } from 'react-hook-form';
import { Select } from '@/components/ui/Select';

function FormWithSelect() {
  const { control } = useForm();

  return (
    <form>
      <Controller
        name="category"
        control={control}
        render={({ field }) => (
          <Select
            value={field.value}
            onValueChange={field.onChange}
            options={['Technology', 'Business', 'Design']}
          />
        )}
      />
    </form>
  );
}
```

### Debounced Save

```typescript
import { useEffect } from 'react';
import { useForm } from 'react-hook-form';

function AutoSaveForm() {
  const { watch } = useForm();
  const formData = watch();

  useEffect(() => {
    const timeoutId = setTimeout(() => {
      // Save to server
    }, 2000);

    return () => clearTimeout(timeoutId);
  }, [formData]);

  // Form JSX
}
```

## Use Cases

### Event Composer (TASK-021)

- Modal with fields: Title, Date, Start/End time, All-day toggle, Description, Location, Repeat, Link to project, Color picker, Reminder
- Form validation using zod
- Optimistic update on submit

### Task Detail Drawer (TASK-017)

- Fields: title, status selector, priority, due date/start date pickers, description, checklist, subtasks, comments, tags, attachments
- Inline editing with auto-save

### Settings Forms (TASK-030, TASK-031)

- General settings: display name, language, timezone, date format
- Appearance settings: theme, accent color, font size, motion toggle
- Notification settings: various toggles and thresholds

## Best Practices

- Always use zod for validation schemas
- Provide clear, actionable error messages
- Use `Controller` for shadcn/ui components
- Implement optimistic updates for better UX
- Use debounced save for auto-save scenarios
- Show loading states during submission
- Respect `prefers-reduced-motion` for toggle switches
- Ensure all inputs have proper labels

## Anti-Patterns

- Using uncontrolled components without proper refs
- Not validating on the client before submission
- Showing generic error messages
- Not handling loading states
- Using inline styles for form layout
- Not providing labels for inputs
