---
name: timeline-components
description: Guides the creation of timeline and Gantt chart components for project management with zoom controls, hover tooltips, and proper date handling
---

## Overview

This skill guides the implementation of timeline and Gantt chart components for visualizing project schedules and task timelines.

## Required Dependencies

```bash
npm install date-fns
```

## Core Concepts

### Timeline Structure

- Horizontal timeline with project names on left
- Bars spanning from start date to due date
- Color-coded by status
- Zoom controls: Week/Month/Quarter
- Hover tooltips showing project details

### Date Handling

- Use `date-fns` for all date calculations
- Format dates consistently (e.g., "MMM dd, yyyy")
- Handle timezone conversions if needed
- Calculate bar positions and widths based on date ranges

### Motion Integration

- **Bar animation**: Bars animate `scaleX` from 0 to 1 on render
- **Transform origin**: `transformOrigin: "left"` for left-to-right growth
- **Tooltip animation**: Uses `AnimatePresence` for enter/exit

## Component Patterns

### Timeline Bar

```typescript
import { motion } from 'motion/react';
import { format } from 'date-fns';

interface TimelineBarProps {
  project: {
    name: string;
    startDate: Date;
    dueDate: Date;
    status: string;
  };
  timelineStart: Date;
  timelineEnd: Date;
  totalWidth: number;
}

function TimelineBar({ project, timelineStart, timelineEnd, totalWidth }: TimelineBarProps) {
  const totalDays = differenceInDays(timelineEnd, timelineStart);
  const startOffset = differenceInDays(project.startDate, timelineStart);
  const duration = differenceInDays(project.dueDate, project.startDate);

  const left = (startOffset / totalDays) * totalWidth;
  const width = (duration / totalDays) * totalWidth;

  const statusColors = {
    'In Progress': '#0066ff',
    'Completed': '#10b981',
    'On Hold': '#f59e0b',
    'Not Started': '#6b7280',
  };

  return (
    <motion.div
      initial={{ scaleX: 0 }}
      animate={{ scaleX: 1 }}
      transformOrigin="left"
      transition={{ duration: 0.5, ease: "easeOut" }}
      style={{
        position: 'absolute',
        left: `${left}px`,
        width: `${width}px`,
        height: '32px',
        backgroundColor: statusColors[project.status] || '#6b7280',
        borderRadius: '4px',
      }}
    >
      <Tooltip content={`${project.name}: ${format(project.startDate, 'MMM dd')} - ${format(project.dueDate, 'MMM dd')}`}>
        <div className="h-full w-full" />
      </Tooltip>
    </motion.div>
  );
}
```

### Timeline Container

```typescript
import { useState } from 'react';
import { addDays, addWeeks, addMonths } from 'date-fns';

function TimelineView({ projects }) {
  const [zoom, setZoom] = useState<'week' | 'month' | 'quarter'>('month');

  const timelineStart = getTimelineStart(projects, zoom);
  const timelineEnd = getTimelineEnd(projects, zoom);

  return (
    <div className="timeline-container">
      <div className="zoom-controls">
        <button onClick={() => setZoom('week')}>Week</button>
        <button onClick={() => setZoom('month')}>Month</button>
        <button onClick={() => setZoom('quarter')}>Quarter</button>
      </div>
      <div className="timeline-grid">
        {projects.map(project => (
          <TimelineBar
            key={project.id}
            project={project}
            timelineStart={timelineStart}
            timelineEnd={timelineEnd}
            totalWidth={800}
          />
        ))}
      </div>
    </div>
  );
}
```

## Use Cases

### Projects Timeline View (TASK-013)

- Gantt-style horizontal timeline
- Project names on left, bars spanning start to due date
- Color-coded by status
- Zoom controls: Week/Month/Quarter
- Hover tooltip with project details

### Project Timeline Tab (TASK-018)

- Gantt view scoped to single project's tasks
- Same zoom controls
- Task-level granularity

## Best Practices

- Use `date-fns` for all date operations
- Calculate positions dynamically based on date ranges
- Provide clear visual distinction between statuses
- Include tooltips for detailed information
- Respect `prefers-reduced-motion` for bar animations
- Handle edge cases (zero duration, overlapping dates)
- Use CSS Grid or Flexbox for layout

## Anti-Patterns

- Hardcoding bar positions (calculate from dates)
- Not handling timezone differences
- Using complex drag-to-resize (not required for MVP)
- Not providing zoom controls
- Using colors that don't meet contrast requirements
