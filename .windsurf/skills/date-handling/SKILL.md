---
name: date-handling
description: Guides the implementation of date handling using date-fns for calendar views, timeline components, and date pickers with proper formatting and timezone awareness
---

## Overview

This skill guides the implementation of date handling using date-fns, the modern date utility library for JavaScript.

## Required Dependencies

```bash
npm install date-fns
```

## Core Concepts

### date-fns Setup

- Use date-fns for all date operations
- Import only the functions you need (tree-shakeable)
- Use UTC functions when timezone consistency is required
- Format dates consistently across the app

### Date Formatting

- Use `format` for display dates
- Use `formatRelative` for relative time (e.g., "2 hours ago")
- Use `formatDistance` for distance between dates
- Use locale-aware formatting when needed

### Date Calculations

- Use `addDays`, `addWeeks`, `addMonths` for date arithmetic
- Use `differenceInDays`, `differenceInWeeks` for date differences
- Use `startOfDay`, `endOfDay`, `startOfWeek`, `endOfWeek` for date ranges
- Use `isSameDay`, `isBefore`, `isAfter` for comparisons

## Utility Functions

### Formatters

```typescript
import { format, formatRelative, formatDistanceToNow } from 'date-fns';

export const formatDate = (date: Date): string => {
  return format(date, 'MMM dd, yyyy');
};

export const formatTime = (date: Date): string => {
  return format(date, 'h:mm a');
};

export const formatDateTime = (date: Date): string => {
  return format(date, 'MMM dd, yyyy h:mm a');
};

export const formatRelativeTime = (date: Date): string => {
  return formatRelative(date, new Date());
};

export const formatTimeAgo = (date: Date): string => {
  return formatDistanceToNow(date, { addSuffix: true });
};
```

### Date Range Calculations

```typescript
import {
  startOfDay,
  endOfDay,
  startOfWeek,
  endOfWeek,
  startOfMonth,
  endOfMonth,
  addDays,
  addWeeks,
  addMonths,
  differenceInDays,
} from 'date-fns';

export const getWeekRange = (date: Date): { start: Date; end: Date } => {
  return {
    start: startOfWeek(date, { weekStartsOn: 0 }),
    end: endOfWeek(date, { weekStartsOn: 0 }),
  };
};

export const getMonthRange = (date: Date): { start: Date; end: Date } => {
  return {
    start: startOfMonth(date),
    end: endOfMonth(date),
  };
};

export const getDaysInRange = (start: Date, end: Date): Date[] => {
  const days: Date[] = [];
  let current = startOfDay(start);
  const last = endOfDay(end);

  while (current <= last) {
    days.push(new Date(current));
    current = addDays(current, 1);
  }

  return days;
};
```

## Component Patterns

### Calendar Grid

```typescript
import { getDaysInMonth, startOfMonth, endOfMonth, eachDayOfInterval, format } from 'date-fns';

function CalendarGrid({ month }: { month: Date }) {
  const daysInMonth = getDaysInMonth(month);
  const monthStart = startOfMonth(month);
  const monthEnd = endOfMonth(month);
  const days = eachDayOfInterval({ start: monthStart, end: monthEnd });

  return (
    <div className="grid grid-cols-7 gap-2">
      {days.map(day => (
        <div key={day.toISOString()} className="calendar-day">
          {format(day, 'd')}
        </div>
      ))}
    </div>
  );
}
```

### Date Picker Integration

```typescript
import { useState } from 'react';
import { format } from 'date-fns';

function DatePicker({ value, onChange }: { value: Date; onChange: (date: Date) => void }) {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div>
      <button onClick={() => setIsOpen(true)}>
        {format(value, 'MMM dd, yyyy')}
      </button>
      {isOpen && (
        <CalendarPopover
          selected={value}
          onSelect={(date) => {
            onChange(date);
            setIsOpen(false);
          }}
        />
      )}
    </div>
  );
}
```

## Use Cases

### Calendar Views (TASK-020)

- Month view: Grid with days, events shown as colored chips
- Week view: 7-column time grid with events as blocks
- Day view: Single day time grid with all-day events
- Agenda view: Chronological list grouped by date

### Timeline Views (TASK-013, TASK-018)

- Calculate bar positions based on date ranges
- Handle zoom controls (Week/Month/Quarter)
- Format dates in tooltips

### Transaction Lists (TASK-025)

- Date range picker for filtering
- Format transaction dates consistently
- Calculate relative time for recent transactions

## Best Practices

- Always use date-fns for date operations
- Format dates consistently across the app
- Use UTC functions when timezone consistency matters
- Handle timezone conversions explicitly
- Provide relative time for recent dates
- Use semantic date formats (e.g., "Today", "Yesterday")
- Test with different locales if internationalization is needed

## Anti-Patterns

- Using native Date methods (inconsistent across browsers)
- Hardcoding date formats
- Not handling timezone differences
- Using moment.js (deprecated, larger bundle)
- Not validating date inputs
- Mixing date libraries
