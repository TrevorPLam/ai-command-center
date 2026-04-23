---
name: drag-drop-components
description: Guides the creation of drag-and-drop components using @dnd-kit for Kanban boards, task lists, and other draggable interfaces with proper accessibility and motion feedback
---

## Overview

This skill guides the implementation of drag-and-drop functionality using @dnd-kit, the modern drag-and-drop library for React.

## Required Dependencies

```bash
npm install @dnd-kit/core @dnd-kit/sortable @dnd-kit/utilities
```

## Core Concepts

### @dnd-kit Setup

- Use `DndContext` as the wrapper for draggable areas
- Use `SortableContext` for sortable lists
- Use `useSortable` hook for draggable items
- Use `useDroppable` for drop zones

### Motion Integration

- **Drag overlay**: Use `DragOverlay` with glowing, scaled card during drag
- **Drop indicator**: Animated blue insertion line using Motion (`scaleY` 0→1)
- Spring animations for smooth drag feedback

### Accessibility

- Provide keyboard alternatives (Ctrl+Shift+Arrow to move selected card)
- Announce moves with toast notifications
- Maintain focus management during drag operations

## Component Patterns

### Draggable Item Pattern

```typescript
import { useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { motion } from 'motion/react';

function DraggableItem({ id, children }) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  };

  return (
    <motion.div
      ref={setNodeRef}
      style={style}
      {...attributes}
      {...listeners}
      whileDrag={{ scale: 1.05, boxShadow: "0 0 20px var(--color-accent)" }}
    >
      {children}
    </motion.div>
  );
}
```

### Drop Zone Pattern

```typescript
import { useDroppable } from '@dnd-kit/core';
import { motion } from 'motion/react';

function DropZone({ id, children }) {
  const { setNodeRef, isOver } = useDroppable({ id });

  return (
    <div ref={setNodeRef}>
      {children}
      {isOver && (
        <motion.div
          initial={{ scaleY: 0 }}
          animate={{ scaleY: 1 }}
          className="h-1 bg-blue-500"
        />
      )}
    </div>
  );
}
```

## Use Cases

### Kanban Board (TASK-012)

- Columns: Not Started, In Progress, On Hold, In Review, Completed
- Drag cards between columns to update status
- Use optimistic updates with TanStack Query mutations

### My Week View (TASK-014)

- Four swim lanes: To Plan, This Week, Later, Cleared
- Drag tasks between lanes
- Keyboard alternative: Ctrl+Shift+Arrow

## Best Practices

- Always use `DragOverlay` for visual feedback during drag
- Implement keyboard alternatives for accessibility
- Use optimistic updates for instant UI feedback
- Announce changes with toast notifications
- Respect `prefers-reduced-motion` for drag animations
- Test with screen readers

## Anti-Patterns

- Using HTML5 drag-drop API (deprecated, less accessible)
- Not providing keyboard alternatives
- Not announcing changes to screen readers
- Dragging without visual feedback
