---
trigger: glob
globs: src/components/calendar/**/*.tsx, src/lib/formatters.ts
---

# Date Handling Rules

This project uses date-fns for date manipulation and formatting. Follow these patterns for consistent date handling across the application.

<!-- SECTION: library_usage -->

<library_usage>

- Use date-fns for all date operations (format, parse, manipulate, compare)
- Use date-fns-tz for timezone handling if needed
- Store dates as ISO 8601 strings in data
- Display dates according to user locale settings
- Respect user timezone preferences

</library_usage>

<!-- ENDSECTION: library_usage -->

<!-- SECTION: date_formatting -->

<date_formatting>

```typescript
import { format, formatDistanceToNow, parseISO } from 'date-fns';

// Format date according to user settings
function formatDate(date: string, formatStr: string = 'MM/dd/yyyy'): string {
  return format(parseISO(date), formatStr);
}

// Relative time (e.g., "2 hours ago")
function formatRelativeTime(date: string): string {
  return formatDistanceToNow(parseISO(date), { addSuffix: true });
}

// Format time
function formatTime(date: string): string {
  return format(parseISO(date), 'h:mm a');
}

// Format date and time
function formatDateTime(date: string): string {
  return format(parseISO(date), 'MM/dd/yyyy h:mm a');
}
```

</date_formatting>

<!-- ENDSECTION: date_formatting -->

<!-- SECTION: date_manulation -->

<date_manulation>

```typescript
import { addDays, addWeeks, addMonths, startOfWeek, endOfWeek, startOfDay, endOfDay } from 'date-fns';

// Add days to a date
function getFutureDate(date: string, days: number): string {
  return addDays(parseISO(date), days).toISOString();
}

// Get week range
function getWeekRange(date: string): { start: string; end: string } {
  const parsed = parseISO(date);
  return {
    start: startOfWeek(parsed).toISOString(),
    end: endOfWeek(parsed).toISOString(),
  };
}

// Get day range
function getDayRange(date: string): { start: string; end: string } {
  const parsed = parseISO(date);
  return {
    start: startOfDay(parsed).toISOString(),
    end: endOfDay(parsed).toISOString(),
  };
}
```

</date_manulation>

<!-- ENDSECTION: date_manulation -->

<!-- SECTION: user_settings -->

<user_settings>

- Store user date format preference in settings
- Store user timezone preference in settings
- Store week start preference (Sunday/Monday) in settings
- Apply these settings consistently across all date displays
- Format dates in components using the user's preferences

</user_settings>

<!-- ENDSECTION: user_settings -->

<!-- SECTION: calendar_components -->

<calendar_components>

- Month view: Show full month grid with navigation
- Week view: Show 7-day time grid with hour labels
- Day view: Show single-day time grid
- Agenda view: Show chronological list of events
- Highlight current day with electric blue border
- Show event chips with color coding by type

</calendar_components>

<!-- ENDSECTION: calendar_components -->

<!-- SECTION: recurring_events -->

<recurring_events>

- Handle repeat rules: none, daily, weekly, monthly, custom
- Calculate next occurrence dates correctly
- Show upcoming recurring items in calendar view
- Allow users to edit repeat rules
- Handle edge cases (month boundaries, leap years)

</recurring_events>

<!-- ENDSECTION: recurring_events -->

<!-- SECTION: timezone_handling -->

<timezone_handling>

- Store all dates in UTC or ISO 8601 format
- Convert to user timezone for display
- Handle daylight saving time transitions
- Show timezone indicators where relevant
- Use date-fns-tz for timezone conversions if needed

</timezone_handling>

<!-- ENDSECTION: timezone_handling -->

<!-- SECTION: accessibility -->

<accessibility>

- Provide alt text for date information
- Use proper ARIA labels for date pickers
- Ensure keyboard navigation for calendar grids
- Announce date changes to screen readers
- Use semantic HTML for date inputs

</accessibility>

<!-- ENDSECTION: accessibility -->

<!-- SECTION: performance -->

<performance>

- Cache formatted dates where appropriate
- Use memoization for expensive date calculations
- Avoid unnecessary date parsing
- Use efficient date comparison methods
- Virtualize long lists of dates

</performance>

<!-- ENDSECTION: performance -->

