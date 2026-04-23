# 23‑SharedRecurrence — Personal AI Command Center Frontend

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.
> **Priority**: 🔴 High (Phase 1 — Shared Infrastructure Extraction)

---

## 📋 Frontend Context (Module‑Wide Assumptions)

> All tasks in this module implicitly rely on the shared infrastructure defined in `00‑Foundations.md`.
> **Do not repeat these in every task** – they are global.

- **Framework**: React 18 + TypeScript (strict mode)
- **State**: Zustand (UI) + TanStack Query (server state)
- **Styling**: Tailwind CSS v4 (CSS‑first `@theme`), shadcn/ui components
- **Animation**: Motion v12 (`framer-motion`) with `useReducedMotion()` guard
- **Testing**: Vitest + RTL + MSW (unit / component / integration)
- **Routing**: React Router v7 (data mode, lazy routes)
- **Virtualization**: `@tanstack/react-virtual`
- **Drag & Drop**: dnd‑kit with shared `useDndSensors` hook
- **Forms**: react‑hook‑form + zod
- **Offline**: Dexie (centralised `CommandCenterDB`)
- **Accessibility**: WCAG 2.2 AA, keyboard navigation, focus restoration

## 📐 Reasoning Memo

Four modules (Calendar, Budget, Projects, Lists) currently implement custom recurrence engines, resulting in ~30% duplicated effort and inconsistent behavior. This specification consolidates all recurrence logic into a single shared engine built on `rrule.js` v2.7 (RFC 5545 compliant), with a shared React component for recurrence editing and Zod validation for RRULE strings.

The shared engine provides:
- **RecurrenceEngine**: Wrapper around rrule.js with UTC date handling and helper functions
- **RecurrenceEditor**: shadcn/ui-based component for building/editing recurrence rules
- **recurrenceSchema**: Zod validation for RRULE strings and recurrence rule objects
- **Helper functions**: Human-readable descriptions, edit operations, occurrence generation

All modules will reference this shared specification instead of implementing custom recurrence logic.

---

## 🔬 Research Findings

| Finding | Source | Action Required |
|---------|--------|-----------------|
| **rrule.js v2.7 is the RFC 5545 standard** for recurrence rules in JavaScript. It handles all standard frequencies (daily, weekly, monthly, yearly) with complex options (BYDAY, BYMONTHDAY, COUNT, UNTIL). | rrule.js GitHub | Use rrule.js as the core engine; wrap with helper functions for common operations. |
| **UTC date handling is critical** — rrule.js requires `new Date(Date.UTC(...))` to avoid timezone offset bugs. Returned dates are in UTC format to be interpreted as local timezone. | rrule.js docs | Enforce UTC date creation in RecurrenceEngine; document timezone handling patterns. |
| **react-rrule-builder-ts exists but uses MUI + Yup** — not compatible with project's shadcn/ui + Zod stack. Also in beta status (not 1.0). | react-rrule-builder-ts GitHub | Build custom RecurrenceEditor using shadcn/ui components and Zod validation. |
| **Per-instance state needed** — Multiple recurrence editors on the same page must work independently. React Context + Zustand pattern is the standard solution. | React patterns | Use React Context with Zustand store for RecurrenceEditor state management. |
| **Three edit modes are standard** — "this event only", "this and following", "all events" — requires EXDATE handling and series manipulation. | RFC 5545, Google Calendar UX | Provide helper functions for all three edit modes with proper exception handling. |

---

## 🧱 Cross-Cutting Foundations

| ID | Area | Requirement |
|----|------|-------------|
| **REC-C01** | Core Library | Use `rrule.js@2.7.2` for all RRULE processing. No custom recurrence engines. |
| **REC-C02** | Date Handling | All dates passed to rrule.js must be UTC: `new Date(Date.UTC(year, month, day, hour, minute))`. Use provided `datetime()` helper. |
| **REC-C03** | Timezone Support | Store RRULE strings with TZID parameter when timezone-aware recurrence is needed. Use Intl API for timezone conversion. |
| **REC-C04** | Validation | Use Zod schema for RRULE string validation and recurrence rule object validation. |
| **REC-C05** | UI Components | RecurrenceEditor uses shadcn/ui components (Select, DatePicker, Switch, Button). No MUI dependencies. |
| **REC-C06** | State Management | RecurrenceEditor uses React Context + Zustand store for per-instance state. |
| **REC-C07** | Exception Handling | Support EXDATE for single-occurrence exceptions and `recurringEventId` + `originalStart` for occurrence tracking. |
| **REC-C08** | Edit Modes | Support three edit modes: "this only", "this and following", "all events" with proper series manipulation. |

---


## 🗂️ Task REC-000: RecurrenceEngine Implementation

**Priority:** 🔴 High
**Est. Effort:** 2 hours
**Depends On:** FND-001 (TypeScript Base), FND-002 (Dependencies)

### Related Files
`src/shared/recurrence/RecurrenceEngine.ts` · `src/shared/recurrence/types.ts` · `src/shared/recurrence/helpers.ts`

### Subtasks

- [ ] **REC-000A**: Install `rrule.js@2.7.2`:
  ```bash
  pnpm add rrule@2.7.2
  ```

- [ ] **REC-000B**: Define core types in `src/shared/recurrence/types.ts`:
  ```ts
  export interface RecurrenceRule {
    frequency: 'daily' | 'weekly' | 'monthly' | 'yearly'
    interval: number // e.g., every 2 weeks
    byDay?: number[] // 0=Sun, 1=Mon, ... 6=Sat (for weekly)
    byMonthDay?: number[] // day of month (1-31) for monthly
    byMonth?: number[] // month number (0-11) for yearly
    count?: number // total occurrences
    until?: Date // end date
    tzid?: string // IANA timezone string
  }

  export interface RecurrenceEditMode {
    mode: 'this' | 'thisAndFollowing' | 'all'
  }

  export interface RecurrenceOccurrence {
    date: Date
    isException: boolean
  }
  ```

- [ ] **REC-000C**: Create `RecurrenceEngine` class in `src/shared/recurrence/RecurrenceEngine.ts`:
  ```ts
  import { RRule, rrulestr } from 'rrule'

  export class RecurrenceEngine {
    private rule: RRule

    constructor(rruleString: string) {
      this.rule = rrulestr(rruleString)
    }

    // Get all occurrences between start and end dates
    getOccurrences(start: Date, end: Date): Date[] {
      return this.rule.between(start, end)
    }

    // Get next N occurrences from a reference date
    getNextOccurrences(from: Date, count: number): Date[] {
      return this.rule.after(from, true, count)
    }

    // Convert to RRULE string
    toString(): string {
      return this.rule.toString()
    }

    // Validate RRULE string
    static isValid(rruleString: string): boolean {
      try {
        rrulestr(rruleString)
        return true
      } catch {
        return false
      }
    }
  }
  ```

- [ ] **REC-000D**: Create helper functions in `src/shared/recurrence/helpers.ts`:
  ```ts
  import { RRule } from 'rrule'
  import { RecurrenceRule, RecurrenceEditMode } from './types'

  // UTC date helper (from rrule.js)
  export function datetime(year: number, month: number, day: number, hour = 0, minute = 0): Date {
    return new Date(Date.UTC(year, month, day, hour, minute))
  }

  // Convert RecurrenceRule object to RRULE string
  export function ruleToRRULE(rule: RecurrenceRule): string {
    const options: any = {
      freq: RRule[rule.frequency.toUpperCase()],
      interval: rule.interval,
    }

    if (rule.byDay) options.byday = rule.byDay
    if (rule.byMonthDay) options.bymonthday = rule.byMonthDay
    if (rule.byMonth) options.bymonth = rule.byMonth
    if (rule.count) options.count = rule.count
    if (rule.until) options.until = rule.until
    if (rule.tzid) options.tzid = rule.tzid

    return new RRule(options).toString()
  }

  // Convert RRULE string to human-readable description
  export function rruleToHuman(rruleString: string): string {
    const rule = rrulestr(rruleString)
    const options = rule.origOptions
    
    const freq = options.freq?.toLowerCase() || 'daily'
    const interval = options.interval || 1
    
    let text = `Every ${interval > 1 ? interval + ' ' : ''}${freq}`
    
    if (options.byday) {
      const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
      text += ` on ${options.byday.map((d: number) => days[d]).join(', ')}`
    }
    
    if (options.until) {
      text += ` until ${options.until.toDateString()}`
    } else if (options.count) {
      text += ` for ${options.count} times`
    }
    
    return text
  }

  // Build edit operations for three-mode recurrence editing
  export function buildEditOperations(
    masterEvent: any,
    occurrenceDate: Date,
    mode: RecurrenceEditMode['mode']
  ): { masterPatch: any; newEvent?: any } {
    switch (mode) {
      case 'this':
        // Create standalone exception, add EXDATE to master
        return {
          masterPatch: {
            exdates: [...(masterEvent.exdates || []), occurrenceDate],
          },
          newEvent: {
            ...masterEvent,
            id: crypto.randomUUID(),
            recurringEventId: masterEvent.id,
            originalStart: occurrenceDate,
          },
        }
      case 'thisAndFollowing':
        // Split series: master ends before this occurrence, new series starts here
        return {
          masterPatch: {
            until: new Date(occurrenceDate.getTime() - 86400000), // day before
          },
          newEvent: {
            ...masterEvent,
            id: crypto.randomUUID(),
            recurringEventId: masterEvent.id,
            originalStart: occurrenceDate,
          },
        }
      case 'all':
        // Update all instances (no exception handling)
        return {
          masterPatch: masterEvent,
        }
    }
  }

  // Restore exception to series (remove EXDATE)
  export function restoreExceptionToSeries(masterEvent: any, occurrenceDate: Date): Partial<any> {
    return {
      exdates: masterEvent.exdates?.filter((d: Date) => d.getTime() !== occurrenceDate.getTime()),
    }
  }
  ```

- [ ] **REC-000E**: Create Zod schema in `src/schemas/recurrenceSchema.ts`:
  ```ts
  import { z } from 'zod'
  import { RecurrenceRule } from '@/shared/recurrence/types'

  export const recurrenceRuleSchema = z.object({
    frequency: z.enum(['daily', 'weekly', 'monthly', 'yearly']),
    interval: z.number().int().min(1).max(99),
    byDay: z.array(z.number().min(0).max(6)).optional(),
    byMonthDay: z.array(z.number().min(1).max(31)).optional(),
    byMonth: z.array(z.number().min(0).max(11)).optional(),
    count: z.number().int().min(1).max(999).optional(),
    until: z.date().optional(),
    tzid: z.string().optional(),
  })

  export const rruleStringSchema = z.string().refine(
    (val) => RecurrenceEngine.isValid(val),
    { message: 'Invalid RRULE string' }
  )
  ```

### Tests
- [ ] `RecurrenceEngine.getOccurrences()` returns correct dates for daily/weekly/monthly/yearly rules
- [ ] `RecurrenceEngine.getNextOccurrences()` returns next N occurrences from reference date
- [ ] `ruleToRRULE()` generates valid RRULE strings for all frequency types
- [ ] `rruleToHuman()` produces human-readable descriptions
- [ ] `buildEditOperations()` returns correct patches for all three edit modes
- [ ] Zod schema validates RecurrenceRule objects
- [ ] Zod schema validates RRULE strings (rejects invalid strings)

### Definition of Done
- RecurrenceEngine wraps rrule.js with all necessary helper functions
- UTC date handling enforced via `datetime()` helper
- Three edit modes supported with proper exception handling
- Zod validation for both rule objects and RRULE strings
- All helper functions tested

### Anti-Patterns
- ❌ Using `new Date()` without UTC — causes timezone offset bugs
- ❌ Implementing custom recurrence logic instead of using rrule.js
- ❌ Not handling EXDATE for single-occurrence exceptions
- ❌ Storing timezone offsets in dates — use TZID parameter instead

---


## 🗂️ Task REC-001: RecurrenceEditor Component

**Priority:** 🔴 High
**Est. Effort:** 2.5 hours
**Depends On:** REC-000

### Related Files
`src/shared/recurrence/RecurrenceEditor.tsx` · `src/shared/recurrence/RecurrenceEditorStore.ts` · `src/shared/recurrence/RecurrenceEditorContext.tsx`

### Subtasks

- [ ] **REC-001A**: Create Zustand store in `src/shared/recurrence/RecurrenceEditorStore.ts`:
  ```ts
  import { create } from 'zustand'
  import { RecurrenceRule } from './types'

  interface RecurrenceEditorState {
    rule: RecurrenceRule
    setFrequency: (freq: RecurrenceRule['frequency']) => void
    setInterval: (interval: number) => void
    setByDay: (days: number[]) => void
    setByMonthDay: (days: number[]) => void
    setByMonth: (months: number[]) => void
    setCount: (count?: number) => void
    setUntil: (date?: Date) => void
    setTzid: (tzid?: string) => void
    reset: () => void
  }

  const initialState: RecurrenceRule = {
    frequency: 'weekly',
    interval: 1,
  }

  export const useRecurrenceEditorStore = create<RecurrenceEditorState>((set) => ({
    rule: initialState,
    setFrequency: (freq) => set((state) => ({ rule: { ...state.rule, frequency: freq } })),
    setInterval: (interval) => set((state) => ({ rule: { ...state.rule, interval } })),
    setByDay: (byDay) => set((state) => ({ rule: { ...state.rule, byDay } })),
    setByMonthDay: (byMonthDay) => set((state) => ({ rule: { ...state.rule, byMonthDay } })),
    setByMonth: (byMonth) => set((state) => ({ rule: { ...state.rule, byMonth } })),
    setCount: (count) => set((state) => ({ rule: { ...state.rule, count } })),
    setUntil: (until) => set((state) => ({ rule: { ...state.rule, until } })),
    setTzid: (tzid) => set((state) => ({ rule: { ...state.rule, tzid } })),
    reset: () => set({ rule: initialState }),
  }))
  ```

- [ ] **REC-001B**: Create React Context in `src/shared/recurrence/RecurrenceEditorContext.tsx`:
  ```ts
  import { createContext, useContext, ReactNode } from 'react'
  import { useRecurrenceEditorStore } from './RecurrenceEditorStore'

  const RecurrenceEditorContext = createContext<ReturnType<typeof useRecurrenceEditorStore> | null>(null)

  export function RecurrenceEditorProvider({ children }: { children: ReactNode }) {
    const store = useRecurrenceEditorStore()
    return (
      <RecurrenceEditorContext.Provider value={store}>
        {children}
      </RecurrenceEditorContext.Provider>
    )
  }

  export function useRecurrenceEditor() {
    const context = useContext(RecurrenceEditorContext)
    if (!context) throw new Error('useRecurrenceEditor must be used within RecurrenceEditorProvider')
    return context
  }
  ```

- [ ] **REC-001C**: Build `RecurrenceEditor` component using shadcn/ui:
  ```tsx
  import { RecurrenceEditorProvider, useRecurrenceEditor } from './RecurrenceEditorContext'
  import { ruleToRRULE, rruleToHuman } from './helpers'
  import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
  import { Button } from '@/components/ui/button'
  import { Switch } from '@/components/ui/switch'
  import { DatePicker } from '@/components/ui/date-picker'

  function RecurrenceEditorContent({ onChange }: { onChange: (rrule: string) => void }) {
    const { rule, setFrequency, setInterval, setByDay, setByMonthDay, setCount, setUntil } = useRecurrenceEditor()

    // Generate RRULE on any change
    React.useEffect(() => {
      onChange(ruleToRRULE(rule))
    }, [rule, onChange])

    return (
      <div className="space-y-4">
        {/* Frequency selector */}
        <Select value={rule.frequency} onValueChange={setFrequency}>
          <SelectTrigger>
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="daily">Daily</SelectItem>
            <SelectItem value="weekly">Weekly</SelectItem>
            <SelectItem value="monthly">Monthly</SelectItem>
            <SelectItem value="yearly">Yearly</SelectItem>
          </SelectContent>
        </Select>

        {/* Interval input */}
        <div className="flex items-center gap-2">
          <span>Every</span>
          <input
            type="number"
            min="1"
            max="99"
            value={rule.interval}
            onChange={(e) => setInterval(parseInt(e.target.value))}
            className="w-16"
          />
          <span>{rule.frequency}</span>
        </div>

        {/* Day selector for weekly */}
        {rule.frequency === 'weekly' && (
          <div className="flex gap-2">
            {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day, i) => (
              <Button
                key={day}
                variant={rule.byDay?.includes(i) ? 'default' : 'outline'}
                size="sm"
                onClick={() => {
                  const days = rule.byDay || []
                  setByDay(days.includes(i) ? days.filter(d => d !== i) : [...days, i])
                }}
              >
                {day}
              </Button>
            ))}
          </div>
        )}

        {/* End condition */}
        <div className="space-y-2">
          <Switch
            checked={!!rule.count}
            onCheckedChange={(checked) => setCount(checked ? 10 : undefined)}
          />
          <span>End after</span>
          {rule.count && (
            <input
              type="number"
              min="1"
              max="999"
              value={rule.count}
              onChange={(e) => setCount(parseInt(e.target.value))}
              className="w-16"
            />
          )}
          <span>occurrences</span>
        </div>

        {/* Human-readable preview */}
        <div className="text-sm text-muted-foreground">
          {rruleToHuman(ruleToRRULE(rule))}
        </div>
      </div>
    )
  }

  export function RecurrenceEditor({ value, onChange }: { value?: string; onChange: (rrule: string) => void }) {
    return (
      <RecurrenceEditorProvider>
        <RecurrenceEditorContent onChange={onChange} />
      </RecurrenceEditorProvider>
    )
  }
  ```

- [ ] **REC-001D**: Add accessibility features:
  - ARIA labels on all interactive elements
  - Keyboard navigation for day selector (Tab, Arrow keys)
  - Focus management when switching frequency modes
  - Screen reader announcements for preview text

- [ ] **REC-001E**: Add responsive layout:
  - Day selector wraps on small screens
  - Interval input scales appropriately
  - Use `@media` queries for mobile optimization

### Tests
- [ ] RecurrenceEditor renders with default weekly rule
- [ ] Frequency selector updates rule correctly
- [ ] Day selector toggles days for weekly recurrence
- [ ] Interval input validates min/max values
- [ ] End condition switch toggles count input
- [ ] `onChange` callback fires on any state change
- [ ] Human-readable preview updates correctly
- [ ] Multiple RecurrenceEditor instances work independently (per-instance store)
- [ ] Accessibility: keyboard navigation works, ARIA labels present

### Definition of Done
- RecurrenceEditor component using shadcn/ui
- Per-instance Zustand store via React Context
- Supports all frequencies (daily, weekly, monthly, yearly)
- Day selector for weekly recurrence
- End condition options (count, until date)
- Human-readable preview
- Accessibility compliant
- Responsive layout

### Anti-Patterns
- ❌ Using global state — must use per-instance store via Context
- ❌ Using MUI components — must use shadcn/ui
- ❌ Missing accessibility features — keyboard navigation and ARIA labels required
- ❌ Not validating interval range — must enforce 1-99

---

## 📋 Module Integration Tasks

### Task REC-002: Calendar Module Integration

**Priority:** 🔴 High
**Est. Effort:** 0.5 hours
**Depends On:** REC-000, REC-001

**Files to Update:** `05-Calendar.md` (CAL-013)

**What to Change:**
- Replace inline `src/utils/recurrence.ts` implementation with reference to RecurrenceEngine
- Update CAL-013C to: "Use `RecurrenceEngine` from `@/shared/recurrence` for all RRULE operations"
- Update CAL-013 to import helper functions from shared module
- Remove duplicate recurrence implementation instructions

---

### Task REC-003: Budget Module Integration

**Priority:** 🔴 High
**Est. Effort:** 0.5 hours
**Depends On:** REC-000, REC-001

**Files to Update:** `07-Budget.md` (BUDG-010)

**What to Change:**
- Replace custom recurrence in BUDG-010C with: "Use `RecurrenceEngine` from `@/shared/recurrence` for RecurringCalendar"
- Update BUDG-010B to use `rruleToHuman()` from shared helpers for recurrence summary
- Update BUDG-010C1 to use `buildEditOperations()` from shared helpers for "Edit Series" modal
- Remove custom recurrence engine implementation instructions

---

### Task REC-004: Projects Module Integration

**Priority:** 🔴 High
**Est. Effort:** 0.5 hours
**Depends On:** REC-000, REC-001

**Files to Update:** `04-Projects.md` (PROJ-013)

**What to Change:**
- Replace custom scheduler in PROJ-013A with: "Use `RecurrenceEngine` from `@/shared/recurrence` for recurring work scheduling"
- Update PROJ-013 to use `ruleToRRULE()` and `rruleToHuman()` from shared helpers
- Remove custom recurrence configuration instructions
- Ensure frequency options map to RecurrenceRule (daily, weekly, monthly, quarterly → monthly with interval 3, yearly)

---

### Task REC-005: Lists Module Integration

**Priority:** 🔴 High
**Est. Effort:** 0.5 hours
**Depends On:** REC-000, REC-001

**Files to Update:** `10-Lists.md` (LIST-010)

**What to Change:**
- Replace custom recurrence in LIST-010A with: "Use `RecurrenceRule` type from `@/shared/recurrence/types`"
- Update LIST-010C to use `RecurrenceEngine` for occurrence calculation
- Update LIST-010B to use `RecurrenceEditor` component from shared module
- Remove custom recurrence engine implementation instructions
- Update LIST-010D to use `getNextOccurrences()` for auto-generation

---

## 🏁 Completion Checklist

- [ ] `rrule.js@2.7.2` added to dependencies
- [ ] RecurrenceEngine class implemented with all helper functions
- [ ] UTC date handling enforced via `datetime()` helper
- [ ] Zod schemas for RecurrenceRule and RRULE strings
- [ ] RecurrenceEditor component using shadcn/ui
- [ ] Per-instance Zustand store via React Context
- [ ] All four module files updated to reference shared engine
- [ ] Duplicate recurrence implementations removed from module specs
- [ ] Tests written for RecurrenceEngine and RecurrenceEditor
- [ ] Documentation updated with integration examples

**Success Metric:** Post-update, the total estimated effort for duplicate recurrence implementations decreases by ~30%, and all modules use consistent RRULE handling with UTC date safety.
