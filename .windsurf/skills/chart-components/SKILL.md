---
name: chart-components
description: Guides the creation of chart components using recharts with proper animations, responsive design, and accessibility for budget analytics, spending trends, and data visualization
---

## Overview

This skill guides the implementation of chart components using recharts, the composable charting library for React.

## Required Dependencies

```bash
npm install recharts
```

## Core Concepts

### Recharts Setup

- Use `ResponsiveContainer` for responsive charts
- Use `LineChart`, `BarChart`, `PieChart` for different chart types
- Use `XAxis`, `YAxis`, `Tooltip`, `Legend` for chart elements
- Use `CartesianGrid` for grid lines

### Motion Integration

- **Line charts**: Animate line drawing left-to-right with `strokeDashoffset`
- **Bar charts**: Grow bars from baseline up
- **Donut charts**: Animate segments on mount
- **Sparklines**: Pure SVG path with `strokeDashoffset` reveal

### Accessibility

- Provide text alternatives for chart data
- Ensure color contrast meets WCAG 2.2 AA
- Support keyboard navigation where applicable
- Include descriptive titles and labels

## Component Patterns

### Line Chart with Animation

```typescript
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';
import { motion } from 'motion/react';

function AnimatedLineChart({ data }) {
  return (
    <ResponsiveContainer width="100%" height={300}>
      <LineChart data={data}>
        <XAxis dataKey="name" />
        <YAxis />
        <Tooltip />
        <Line
          type="monotone"
          dataKey="value"
          stroke="#0066ff"
          strokeWidth={2}
          dot={false}
          animationDuration={1500}
          animationEasing="ease-out"
        />
      </LineChart>
    </ResponsiveContainer>
  );
}
```

### Bar Chart with Animation

```typescript
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';

function AnimatedBarChart({ data }) {
  return (
    <ResponsiveContainer width="100%" height={300}>
      <BarChart data={data}>
        <XAxis dataKey="name" />
        <YAxis />
        <Tooltip />
        <Bar
          dataKey="value"
          fill="#0066ff"
          animationDuration={1000}
          animationEasing="ease-out"
        />
      </BarChart>
    </ResponsiveContainer>
  );
}
```

### Sparkline (SVG)

```typescript
import { motion } from 'motion/react';

function Sparkline({ data, width = 100, height = 30 }) {
  const max = Math.max(...data);
  const min = Math.min(...data);
  const range = max - min || 1;

  const points = data
    .map((value, index) => {
      const x = (index / (data.length - 1)) * width;
      const y = height - ((value - min) / range) * height;
      return `${x},${y}`;
    })
    .join(' ');

  return (
    <svg width={width} height={height} viewBox={`0 0 ${width} ${height}`}>
      <motion.polyline
        points={points}
        fill="none"
        stroke="#0066ff"
        strokeWidth={2}
        initial={{ strokeDasharray: 1000, strokeDashoffset: 1000 }}
        animate={{ strokeDashoffset: 0 }}
        transition={{ duration: 1.5, ease: "easeOut" }}
      />
    </svg>
  );
}
```

## Use Cases

### Budget Dashboard (TASK-024)

- **NetWorthCard**: Sparkline chart (12 months)
- **SpendingTrendChart**: Line/bar chart toggle with time range selector
- **BudgetCategoryCard**: Progress bars with hover popover

### Investments Page (TASK-028)

- **Asset allocation**: Donut chart with animated segments
- **Performance chart**: Line chart showing returns over time

### Cost Analytics (TASK-033)

- **CostBreakdownChart**: By model, by agent
- **BudgetOverview**: Spent vs budget comparison

## Best Practices

- Always use `ResponsiveContainer` for responsive charts
- Use `memo` to prevent unnecessary re-renders
- Provide loading skeletons while data fetches
- Include empty states when no data available
- Use consistent colors matching the theme
- Add tooltips for data exploration
- Respect `prefers-reduced-motion` for animations

## Anti-Patterns

- Hardcoding chart dimensions (use ResponsiveContainer)
- Not handling empty data states
- Using complex animations that distract from data
- Not providing text alternatives
- Using colors that don't meet contrast requirements
