---
trigger: glob
globs: src/components/projects/**/*.tsx, src/components/calendar/**/*.tsx
---

# Drag and Drop Rules

This project uses @dnd-kit for drag and drop functionality. Follow these patterns for consistent, accessible drag and drop interactions.

<!-- SECTION: library_usage -->

<library_usage>

- Use @dnd-kit/core for core drag and drop functionality
- Use @dnd-kit/sortable for sortable lists
- Use @dnd-kit/utilities for collision detection and animations
- All drag operations must be keyboard accessible
- Provide visual feedback during drag operations

</library_usage>

<!-- ENDSECTION: library_usage -->

<!-- SECTION: basic_drag_and_drop -->

<basic_drag_and_drop>

```typescript
import { DndContext, closestCenter } from '@dnd-kit/core';
import { useDraggable } from '@dnd-kit/core';
import { useDroppable } from '@dnd-kit/core';

function DraggableItem({ id, children }: { id: string; children: React.ReactNode }) {
  const { attributes, listeners, setNodeRef, transform } = useDraggable({ id });
  
  const style = {
    transform: transform ? `translate3d(${transform.x}px, ${transform.y}px, 0)` : undefined,
  };

  return (
    <div ref={setNodeRef} style={style} {...attributes} {...listeners}>
      {children}
    </div>
  );
}

function DroppableZone({ id, children }: { id: string; children: React.ReactNode }) {
  const { setNodeRef } = useDroppable({ id });

  return <div ref={setNodeRef}>{children}</div>;
}
```

</basic_drag_and_drop>

<!-- ENDSECTION: basic_drag_and_drop -->

<!-- SECTION: sortable_lists -->

<sortable_lists>

```typescript
import { SortableContext, useSortable, verticalListSortingStrategy } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';

function SortableItem({ id, children }: { id: string; children: React.ReactNode }) {
  const { attributes, listeners, setNodeRef, transform, transition } = useSortable({ id });
  
  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  };

  return (
    <div ref={setNodeRef} style={style} {...attributes} {...listeners}>
      {children}
    </div>
  );
}
```

</sortable_lists>

<!-- ENDSECTION: sortable_lists -->

<!-- SECTION: accessibility -->

<accessibility>

- All draggable items must have aria-grabbed attribute
- All droppable zones must have aria-dropeffect attribute
- Provide keyboard shortcuts for drag operations (Space to grab, arrows to move, Enter to drop)
- Announce drag state changes to screen readers
- Ensure focus management during drag operations
- Use proper button roles for drag handles

</accessibility>

<!-- ENDSECTION: accessibility -->

<!-- SECTION: visual_feedback -->

<visual_feedback>

- Show electric blue highlight on valid drop targets
- Show ghost image during drag operation
- Animate drop with 150ms ease-out transition
- Show placeholder in original position during drag
- Use backdrop-blur-md bg-white/5 for drag overlays
- Respect prefers-reduced-motion media query

</visual_feedback>

<!-- ENDSECTION: visual_feedback -->

<!-- SECTION: kanban_patterns -->

<kanban_patterns>

- Use columns as droppable zones
- Cards as draggable items
- Update data on drop (optimistic update)
- Use collision detection for column boundaries
- Show visual feedback when hovering over columns
- Support reordering within columns

</kanban_patterns>

<!-- ENDSECTION: kanban_patterns -->

<!-- SECTION: my_week_patterns -->

<my_week_patterns>

- Use swim lanes as droppable zones
- Tasks as draggable items
- Support drag between lanes
- Update task status on drop
- Show lane-specific visual feedback
- Preserve task metadata during drag

</my_week_patterns>

<!-- ENDSECTION: my_week_patterns -->

<!-- SECTION: performance -->

<performance>

- Use collision detection algorithms for performance
- Debounce drag operations where appropriate
- Virtualize long lists before adding drag and drop
- Use transform and opacity for animations (avoid layout properties)
- Clean up event listeners on unmount
- Use React.memo for draggable items

</performance>

<!-- ENDSECTION: performance -->

<!-- SECTION: error_handling -->

<error_handling>

- Handle drag errors gracefully
- Provide fallback for failed drag operations
- Show user feedback for invalid drops
- Rollback optimistic updates on error
- Log drag operations in development

</error_handling>

<!-- ENDSECTION: error_handling -->

