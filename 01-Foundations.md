# 00-Foundations — Personal AI Command Center Frontend

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.  
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.

---

## 📋 Frontend Context

All tasks implicitly rely on the shared infrastructure defined in `01-Foundations.md`.  
**Do not repeat any of the following** – they are global:

- React 18 + TypeScript (strict mode)
- Zustand (UI state) + TanStack Query (server state)
- Tailwind CSS v4 (`@theme` CSS‑first) + shadcn/ui
- Motion v12 with `useReducedMotion()` guard
- Testing: Vitest + RTL + MSW
- Routing: React Router v7 (data mode, lazy routes)
- Virtualization: `@tanstack/react-virtual`
- Drag & drop: dnd‑kit with shared `useDndSensors` hook
- Forms: react‑hook‑form + zod
- Offline: Dexie (centralised `CommandCenterDB`)
- Accessibility: WCAG 2.2 AA, keyboard navigation, focus restoration

---

## 🧱 Cross‑Cutting Foundations (Module‑Specific)

| ID | Area | Requirement |
|----|------|-------------|
| C-01 | Background Color | `#050507` (blue-shifted near-black) via `--background` CSS var |
| C-02 | Motion Library | `motion` v12 — `import { motion } from "motion/react"` |
| C-03 | Virtualisation | `@tanstack/react-virtual` (`useVirtualizer`) for all virtualized lists |
| C-04 | Design Tokens | CSS custom properties + `@theme inline` mapping, `oklch()` required |
| C-05 | Glass Scope | `.noise-overlay` only for shells, drawers, command palette |
| C-06 | Reduced Motion | `useReducedMotion()` from `motion/react` — checked before every animation |
| C-07 | Page Transitions | `AnimatePresence` + `motion.div` keyed by `location.pathname` |
| C-08 | Focus Restoration | Store trigger ref in `uiSlice`; restore on modal/drawer close |
| C-09 | Keyboard Hints | `<kbd>` tags (e.g. `⌘K`) |
| C-10 | Accessibility | WCAG 2.2 AA — Focus Not Obscured (2.4.12), Target Size (2.5.8) |
| C-11 | Test Pattern | `userEvent.setup()` called fresh per test; `screen` preferred over `container` |
| C-12 | Router Import | `import { ... } from "react-router"` — NOT `react-router-dom` |
| C-13 | Motion Tokens | All `motion` components must use shared tokens from `src/lib/motion.ts` |
| C-14 | dnd-kit Sensors | All dnd-kit usage must use the shared `useDndSensors()` hook |
| C-15 | HTML Sanitization | All untrusted HTML content MUST use shared `SanitizedHTML` component |
| C-16 | Security Policy | No `dangerouslySetInnerHTML` outside of `SanitizedHTML` implementation |

---

## 🎯 Motion Tier Assignment

| Component | Tier | Allowed Techniques |
|-----------|------|--------------------|
| AppShell | Alive | Page transitions, spring physics, layoutId |
| Sidebar | Alive | Spring width animation, layoutId active pill, accordion height |
| StatusBar | Quiet | Pulse animation (disabled if reduced motion), tooltips |
| RightPanel | Alive | Spring slide-in/out |
| CmdPalette | Alive | Spring scale-up, staggered children, backdrop fade |
| VoiceShell | Alive | Spring scale-up, waveform animation |

---

## 🗂️ Cross-Cutting Infrastructure

### Centralized IndexedDB Schema

All modules share a single `CommandCenterDB` instance with module-prefixed stores to avoid conflicts and enable centralized quota management.

```typescript
// src/lib/db.ts
import { Dexie } from 'dexie';

export class CommandCenterDB extends Dexie {
  // News module stores
  news_articles: Dexie.Table<NewsArticle, string>;
  news_bookmarks: Dexie.Table<Bookmark, string>;
  news_readStatus: Dexie.Table<ReadStatus, string>;

  // Budget module stores
  budget_transactions: Dexie.Table<Transaction, string>;
  budget_recurring: Dexie.Table<RecurringItem, string>;
  budget_goals: Dexie.Table<Goal, string>;

  // Email module stores
  email_messages: Dexie.Table<EmailMessage, string>;
  email_queue: Dexie.Table<QueuedAction, string>;
  email_attachments: Dexie.Table<Attachment, string>;

  // Contacts module stores
  contacts_records: Dexie.Table<Contact, string>;
  contacts_interactions: Dexie.Table<ContactInteraction, string>;

  // Lists module stores
  lists_items: Dexie.Table<ListItem, string>;
  lists_templates: Dexie.Table<ListTemplate, string>;

  // Documents module stores
  docs_metadata: Dexie.Table<DocumentMetadata, string>;
  docs_queue: Dexie.Table<QueuedDocumentAction, string>;
  docs_versions: Dexie.Table<DocumentVersion, string>;

  constructor() {
    super('CommandCenterDB');
    
    this.version(1).stores({
      // News: articles, bookmarks, read tracking
      'news_articles': 'id, sourceId, publishedAt, topics, url, [sourceId+publishedAt]',
      'news_bookmarks': 'id, articleId, createdAt',
      'news_readStatus': 'id, articleId, readAt',
      
      // Budget: transactions, recurring items, goals
      'budget_transactions': 'id, accountId, categoryId, date, type, amount',
      'budget_recurring': 'id, accountId, categoryId, nextDate, isActive',
      'budget_goals': 'id, targetAmount, currentAmount, deadline, status',
      
      // Email: messages, queue, attachments
      'email_messages': 'id, accountId, threadId, subject, date, isRead',
      'email_queue': 'id, type, payload, createdAt, retryCount',
      'email_attachments': 'id, messageId, filename, size, mimeType',
      
      // Contacts: records, interactions
      'contacts_records': 'id, email, phone, name, createdAt',
      'contacts_interactions': 'id, contactId, type, timestamp',
      
      // Lists: items, templates
      'lists_items': 'id, listId, parentId, position, contentType',
      'lists_templates': 'id, name, type, isBuiltIn',
      
      // Documents: metadata, queue, versions
      'docs_metadata': 'id, parentId, name, mimeType, size, createdAt',
      'docs_queue': 'id, type, documentId, payload, createdAt',
      'docs_versions': 'id, documentId, version, createdAt, checksum'
    });
  }
}

export const db = new CommandCenterDB();

### Migration Strategy

When adding new stores or modifying existing schemas, the database version must be incremented and migration functions defined. All existing stores must be re-declared in each new version.

```typescript
// Example: Adding a new module store
constructor() {
  super('CommandCenterDB');
  
  this.version(1).stores({
    // All existing stores from version 1...
    'news_articles': 'id, sourceId, publishedAt, topics, url, [sourceId+publishedAt]',
    'news_bookmarks': 'id, articleId, createdAt',
    'news_readStatus': 'id, articleId, readAt',
    // ... other existing stores
  });
  
  // Version 2: Add new module store
  this.version(2).stores({
    // Re-declare all existing stores (required by Dexie)
    'news_articles': 'id, sourceId, publishedAt, topics, url, [sourceId+publishedAt]',
    'news_bookmarks': 'id, articleId, createdAt',
    'news_readStatus': 'id, articleId, readAt',
    'budget_transactions': 'id, accountId, categoryId, date, type, amount',
    'budget_recurring': 'id, accountId, categoryId, nextDate, isActive',
    'budget_goals': 'id, targetAmount, currentAmount, deadline, status',
    'email_messages': 'id, accountId, threadId, subject, date, isRead',
    'email_queue': 'id, type, payload, createdAt, retryCount',
    'email_attachments': 'id, messageId, filename, size, mimeType',
    'contacts_records': 'id, email, phone, name, createdAt',
    'contacts_interactions': 'id, contactId, type, timestamp',
    'lists_items': 'id, listId, parentId, position, contentType',
    'lists_templates': 'id, name, type, isBuiltIn',
    'docs_metadata': 'id, parentId, name, mimeType, size, createdAt',
    'docs_queue': 'id, type, documentId, payload, createdAt',
    'docs_versions': 'id, documentId, version, createdAt, checksum',
    
    // Add new module store
    'calendar_events': 'id, calendarId, title, start, end, [calendarId+start]'
  }).upgrade(tx => {
    // Migration logic for data transformation if needed
    return tx.table('calendar_events').toCollection().modify(event => {
      // Example: Remove deprecated fields or add defaults
      event.legacyField = undefined;
      event.status = event.status || 'confirmed';
    });
  });
}
```

**Migration Rules:**
- Always increment the version number when adding/modifying stores
- Re-declare ALL existing stores in the new version (Dexie requirement)
- Use `.upgrade()` for data transformations or default value assignments
- Test migrations on both fresh installs and existing databases
- Consider user data loss when removing stores or fields

```

### Storage Quota Management Hook

Global quota monitoring with warnings at 80% capacity:

```typescript
// src/hooks/useStorageQuota.ts
import { useEffect, useState } from 'react';
import { db } from '@/lib/db';

export interface StorageQuota {
  usage: number;
  quota: number;
  percentage: number;
  isNearLimit: boolean;
}

export function useStorageQuota() {
  const [quota, setQuota] = useState<StorageQuota | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const estimateQuota = async () => {
      try {
        const estimate = await navigator.storage.estimate();
        const usage = estimate.usage || 0;
        const quotaLimit = estimate.quota || 0;
        const percentage = quotaLimit > 0 ? (usage / quotaLimit) * 100 : 0;
        const isNearLimit = percentage >= 80;

        setQuota({ usage, quota: quotaLimit, percentage, isNearLimit });
      } catch (error) {
        console.warn('Failed to estimate storage quota:', error);
      } finally {
        setIsLoading(false);
      }
    };

    estimateQuota();
    
    // Re-estimate every 5 minutes
    const interval = setInterval(estimateQuota, 5 * 60 * 1000);
    
    return () => clearInterval(interval);
  }, []);

  const formatBytes = (bytes: number) => {
    const units = ['B', 'KB', 'MB', 'GB'];
    let size = bytes;
    let unitIndex = 0;
    
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    
    return `${size.toFixed(1)} ${units[unitIndex]}`;
  };

  return {
    quota,
    isLoading,
    formatBytes,
    // Helper for warning UI
    shouldShowWarning: quota?.isNearLimit ?? false,
    warningMessage: quota 
      ? `Storage usage at ${quota.percentage.toFixed(1)}% (${formatBytes(quota.usage)} / ${formatBytes(quota.quota)})`
      : undefined
  };
}

### Shared SanitizedHTML Component

All untrusted HTML content must use the shared `SanitizedHTML` component to ensure consistent security and prevent XSS vulnerabilities.

```typescript
// src/components/shared/SanitizedHTML.tsx
import DOMPurify from 'dompurify';
import parse from 'html-react-parser';

interface SanitizedHTMLProps {
  html: string;
  allowlist?: DOMPurify.Config['ALLOWED_TAGS'];
  className?: string;
}

const DEFAULT_ALLOWLIST = {
  ALLOWED_TAGS: [
    'p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
    'ul', 'ol', 'li', 'strong', 'em', 'a',
    'img', 'blockquote', 'pre', 'code', 'br', 'hr',
    'table', 'thead', 'tbody', 'tr', 'th', 'td'
  ],
  ALLOWED_ATTR: ['href', 'src', 'alt', 'title', 'target', 'rel', 'class'],
};

export function SanitizedHTML({ html, allowlist = DEFAULT_ALLOWLIST, className }: SanitizedHTMLProps) {
  const cleanHtml = DOMPurify.sanitize(html, {
    ALLOWED_TAGS: allowlist.ALLOWED_TAGS,
    ALLOWED_ATTR: allowlist.ALLOWED_ATTR,
    FORBID_TAGS: ['script', 'iframe', 'object', 'embed', 'form', 'input'],
    FORBID_ATTR: ['onclick', 'onload', 'onerror', 'onmouseover'],
  });

  // Add security attributes to external links
  const processedHtml = cleanHtml.replace(
    /<a\s+href=(["'])(https?:\/\/[^"']+)\1/gi,
    '<a href="$1$2$1 target="_blank" rel="noopener noreferrer"'
  );

  const parsedContent = parse(processedHtml);

  return (
    <div className={className}>
      {parsedContent}
    </div>
  );
}
```

**Security Requirements:**
- All `script`, `iframe`, `object`, `embed`, `form`, and `input` tags are forbidden
- All event handlers (`onclick`, `onload`, etc.) are forbidden
- External links automatically get `target="_blank" rel="noopener noreferrer"`
- Default allowlist covers common content tags (headings, paragraphs, lists, links, images, tables)
- Modules can extend the allowlist but never reduce security restrictions

**Usage Pattern:**
```tsx
// Correct usage
<SanitizedHTML html={articleContent} className="prose prose-invert" />

// Extended allowlist for specific needs
const extendedAllowlist = {
  ...DEFAULT_ALLOWLIST,
  ALLOWED_TAGS: [...DEFAULT_ALLOWLIST.ALLOWED_TAGS, 'video', 'source'],
  ALLOWED_ATTR: [...DEFAULT_ALLOWLIST.ALLOWED_ATTR, 'controls', 'type']
};
<SanitizedHTML html={mediaContent} allowlist={extendedAllowlist} />
```

**Priority:** 🔴 High  
**Est. Effort:** 0.5 hours  
**Depends On:** FND-002 (DOMPurify and html-react-parser dependencies)

**Related Files**  
- `src/components/shared/SanitizedHTML.tsx`
- `package.json` (DOMPurify, html-react-parser dependencies)

**Anti‑Patterns**

- ❌ Using `dangerouslySetInnerHTML` directly on untrusted content
- ❌ Creating module-specific sanitization functions
- ❌ Omitting `target="_blank" rel="noopener noreferrer"` on external links
- ❌ Allowing `script`, `iframe`, or event handler attributes

### Subtasks

- [ ] **FND-000A**: Define `@theme inline` block in `src/index.css` with `oklch()` color tokens.
- [ ] **FND-000B**: Configure dark mode selector variant: `@custom-variant dark (&:where(.dark, .dark *));`.
- [ ] **FND-000C**: Define semantic color tokens (`--background`, `--foreground`, etc.) with `--background` at `oklch(9.8% 0.006 264)`.
- [ ] **FND-000D**: Add `@layer base` for body background-color and color-scheme.
- [ ] **FND-000E**: Add `.noise-overlay` utility in `@layer utilities`.
- [ ] **FND-000F**: Add `@property` declarations for animated conic-gradient borders.
- [ ] **FND-000G**: Create `ThemeProvider` using `next-themes`.
- [ ] **FND-000H**: Create `ThemeToggle` component.
- [ ] **FND-000I**: Create `src/lib/tokens.ts` for typed token constants.
- [ ] **FND-000J**: Create `src/lib/motion.ts` for shared animation tokens.

### Definition of Done

- [ ] No `tailwind.config.ts` file exists.
- [ ] `@theme inline` block contains all tokens with `oklch()` values.
- [ ] `@custom-variant dark` directive is present.
- [ ] Dark mode toggles correctly using class switching.
- [ ] `body` background renders `#050507`.
- [ ] `.noise-overlay` class is available.
- [ ] `src/lib/tokens.ts` and `src/lib/motion.ts` export typed constants.
- [ ] All tests pass.

### Anti‑Patterns

- ❌ `tailwind.config.ts` usage.
- ❌ Hex or HSL color values.
- ❌ `@apply` for component styles.
- ❌ Applying dark mode via media query alone.

---

## 🗂️ Task FND-001: Project Scaffold & Vite Configuration

**Priority:** 🔴 High  
**Est. Effort:** 0.5 hours  
**Depends On:** None  

**Related Files**  
- `package.json`
- `vite.config.ts`
- `tsconfig.json`
- `index.html`

### Subtasks

- [ ] **FND-001A**: Scaffold project with `pnpm create vite@latest . --template react-ts`.
- [ ] **FND-001B**: Configure `vite.config.ts` with `@tailwindcss/vite`, path aliases, and build settings.
- [ ] **FND-001C**: Configure `tsconfig.json` with strict mode, path aliases, and bundler resolution.
- [ ] **FND-001D**: Add `@types/node` dev dependency.
- [ ] **FND-001E**: Create initial `src/index.css`.
- [ ] **FND-001F**: Clean up Vite boilerplate.
- [ ] **FND-001G**: **[TEST]** Verify `pnpm dev` starts and `tsc --noEmit` passes.

### Definition of Done

- [ ] Dev server starts on `localhost:5173`.
- [ ] TypeScript strict mode: `tsc --noEmit` passes with 0 errors.
- [ ] Path alias `@/` resolves correctly.
- [ ] No `tailwind.config.ts` exists.
- [ ] All tests pass.

### Anti‑Patterns

- ❌ `"moduleResolution": "node"` in `tsconfig.json`.
- ❌ Forgetting to sync `tsconfig.json` paths with Vite aliases.

---

## 🗂️ Task FND-002: Core Dependencies Installation

**Priority:** 🔴 High  
**Est. Effort:** 0.3 hours  
**Depends On:** FND-001  

**Related Files**  
- `package.json`
- `components.json`
- `src/lib/utils.ts`

### Subtasks

- [ ] **FND-002A**: Install Tailwind v4 + Vite plugin.
- [ ] **FND-002B**: Install shadcn/ui runtime dependencies.
- [ ] **FND-002C**: Install `motion` v12.
- [ ] **FND-002D**: Install Zustand, TanStack Query, and Zod.
- [ ] **FND-002E**: Install `react-router` v7.
- [ ] **FND-002F**: Install `@tanstack/react-virtual`.
- [ ] **FND-002G**: Install `next-themes`.
- [ ] **FND-002H**: Install dev dependencies (`tw-animate-css`, `@types/node`).
- [ ] **FND-002I**: Create `src/lib/utils.ts` with `cn()` utility.
- [ ] **FND-002J**: Create `components.json` for shadcn.
- [ ] **FND-002K**: **[TEST]** Add first shadcn component and verify rendering.
- [ ] **FND-002L**: Install React Query DevTools.

### Definition of Done

- [ ] All packages installed without peer dependency warnings.
- [ ] `motion/react` and `react-router` imports compile.
- [ ] shadcn Button renders correctly.
- [ ] `pnpm build` succeeds.
- [ ] All tests pass.

### Anti‑Patterns

- ❌ Installing `framer-motion` (use `motion`).
- ❌ Installing `react-router-dom` (use `react-router`).
- ❌ Defining Zod schemas inside components (performance hit).

---

## 🗂️ Task FND-003: Code Quality Toolchain

**Priority:** 🔴 High  
**Est. Effort:** 1.0 hours  
**Depends On:** FND-001  

**Related Files**  
- `eslint.config.js`
- `.prettierrc`
- `.husky/`
- `lint-staged.config.js`

### Subtasks

- [ ] **FND-003A**: Install ESLint 9 plugins and Prettier.
- [ ] **FND-003B**: Create `eslint.config.js` using `defineConfig()` and `tseslint.config()`.
- [ ] **FND-003C**: Create `.prettierrc` with project standards.
- [ ] **FND-003D**: Create `.prettierignore`.
- [ ] **FND-003E**: Add lint and format scripts to `package.json`.
- [ ] **FND-003F**: Initialize Husky and configure `lint-staged`.
- [ ] **FND-003G**: Configure Commitlint.
- [ ] **FND-003H**: **[TEST]** Verify `pnpm lint` and `pnpm format:check` pass.

### Definition of Done

- [ ] `pnpm lint` passes with 0 warnings.
- [ ] Committing invalid code is blocked by Husky.
- [ ] Conventional commits enforced.
- [ ] Type-aware linting is active.
- [ ] All tests pass.

### Anti‑Patterns

- ❌ Using legacy `.eslintrc.js` format.
- ❌ Placing Prettier plugin anywhere but last in ESLint config.

---

## 🗂️ Task FND-004: Testing Infrastructure

**Priority:** 🔴 High  
**Est. Effort:** 1.5 hours  
**Depends On:** FND-001, FND-002  

**Related Files**  
- `vitest.config.ts`
- `src/test/setup.ts`
- `src/mocks/server.ts`
- `playwright.config.ts`

### Subtasks

- [ ] **FND-004A**: Install Vitest, Browser Mode, RTL, and MSW.
- [ ] **FND-004B**: Configure `vitest.config.ts` with coverage thresholds.
- [ ] **FND-004C**: Create `src/test/setup.ts` with global mocks (matchMedia, Observers).
- [ ] **FND-004D**: Configure MSW server with `onUnhandledRequest: 'error'`.
- [ ] **FND-004E**: Configure Vitest Browser Mode with Playwright.
- [ ] **FND-004F**: Add test scripts to `package.json`.
- [ ] **FND-004G**: **[TEST]** Write and run smoke test for `cn()` utility.
- [ ] **FND-004H**: Create `src/test/motion-helpers.ts` for animation testing.
- [ ] **FND-004I**: Verify `pnpm test` passes.
- [ ] **FND-004J**: Update `.gitignore` for test artifacts.

### Definition of Done

- [ ] `pnpm test` and `pnpm test:coverage` pass.
- [ ] MSW blocks unhandled network requests.
- [ ] Browser Mode correctly configured for component tests.
- [ ] All tests pass.

### Anti‑Patterns

- ❌ Omitting `onUnhandledRequest: 'error'` in MSW.
- ❌ Testing animations without fake timers.

---

## 🗂️ Task FND-005: Zustand Store Architecture

**Priority:** 🔴 High  
**Est. Effort:** 1.5 hours  
**Depends On:** FND-002  

**Related Files**  
- `src/stores/index.ts`
- `src/stores/slices/uiSlice.ts`
- `src/stores/slices/projectSlice.ts`

### Subtasks

- [ ] **FND-005A**: Define `AppStateCreator` type for safe cross-slice access.
- [ ] **FND-005B**: Create typed slices (`uiSlice`, `projectSlice`, etc.) with state and actions.
- [ ] **FND-005C**: Compose slices into root store in `src/stores/index.ts`.
- [ ] **FND-005D**: Export atomic selector hooks for each state property.
- [ ] **FND-005E**: Implement imperative focus registry for restoration.
- [ ] **FND-005F**: **[TEST]** Write unit tests for all slice actions.

### Definition of Done

- [ ] Middleware applied only at combined root store level.
- [ ] `persist` uses `partialize` to limit persistence scope.
- [ ] Atomic selectors prevent unnecessary re-renders.
- [ ] No React refs stored in Zustand.
- [ ] All tests pass.

### Anti‑Patterns

- ❌ Storing server data in Zustand (use TanStack Query).
- ❌ Naming slice creator functions with `use` prefix.

---

## 🗂️ Task FND-006: TanStack Query v5 Configuration

**Priority:** 🔴 High  
**Est. Effort:** 1.0 hours  
**Depends On:** FND-002  

**Related Files**  
- `src/lib/queryClient.ts`
- `src/queries/`
- `src/lib/useOptimisticMutation.ts`

### Subtasks

- [ ] **FND-006A**: Create `queryClient.ts` with global defaults (staleTime, gcTime).
- [ ] **FND-006B**: Set up `src/queries/` directory with domain-specific files.
- [ ] **FND-006C**: Define `queryOptions` as single source of truth for all queries.
- [ ] **FND-006D**: Create custom hooks consuming `queryOptions`.
- [ ] **FND-006E**: Set `staleTime: Infinity` for static data.
- [ ] **FND-006F**: Set up lazy-loaded React Query DevTools.
- [ ] **FND-006G**: **[TEST]** Write tests for `queryOptions` using MSW.
- [ ] **FND-006H**: Implement `useOptimisticMutation` unified wrapper with canonical pattern:

  **Canonical Pattern (Required for ALL mutations):**
  ```ts
  // src/lib/useOptimisticMutation.ts
  export function useOptimisticMutation<TData, TError, TVariables>({
    mutationFn,
    queryKey,
    optimisticUpdate,
    onSettled,
  }: {
    mutationFn: (vars: TVariables) => Promise<TData>
    queryKey: QueryKey
    optimisticUpdate: (old: TData | undefined, vars: TVariables) => TData
    onSettled?: () => void
  }) {
    const queryClient = useQueryClient()
    return useMutation({
      mutationFn,
      onMutate: async (vars) => {
        await queryClient.cancelQueries({ queryKey })
        const previous = queryClient.getQueryData<TData>(queryKey)
        queryClient.setQueryData<TData>(queryKey, (old) => optimisticUpdate(old, vars))
        return { previous }
      },
      onError: (err, vars, context) => {
        if (context?.previous !== undefined) {
          queryClient.setQueryData(queryKey, context.previous)
        }
      },
      onSettled: () => {
        queryClient.invalidateQueries({ queryKey })
        onSettled?.()
      },
    })
  }
  ```

  **Usage Pattern:**
  ```ts
  const mutation = useOptimisticMutation({
    mutationFn: sendMessage,
    queryKey: chatKeys.messages(threadId),
    optimisticUpdate: (old, vars) => [...(old || []), vars.optimisticMessage],
  })
  ```

  **Rules:**
  - All module mutations MUST use this wrapper — no inline `onMutate/onError/onSettled` patterns
  - Pattern: `cancelQueries → snapshot → setQueryData → rollback → invalidate`
  - `onSettled` (not `onSuccess`) for invalidation to handle both success and error paths

### Definition of Done

- [ ] `queryOptions` pattern used consistently for full type inference.
- [ ] Optimistic mutations follow canonical pattern via wrapper.
- [ ] No manual query key strings outside `queryOptions`.
- [ ] All tests pass.

### Anti‑Patterns

- ❌ Not setting `staleTime` (results in excessive refetching).
- ❌ Using `useEffect` to fetch data instead of `useQuery`.

---

## 🗂️ Task FND-007: React Router v7 Route Architecture

**Priority:** 🔴 High  
**Est. Effort:** 1.0 hours  
**Depends On:** FND-002  

**Related Files**  
- `src/router/index.tsx`
- `src/router/routes.ts`
- `src/pages/`

### Subtasks

- [ ] **FND-007A**: Implement Router in **Data Mode** using `createBrowserRouter`.
- [ ] **FND-007B**: Define route tree with code-split children.
- [ ] **FND-007C**: Configure `lazy` loading for every route.
- [ ] **FND-007D**: Integrate TanStack Query prefetching in route `loader` functions.
- [ ] **FND-007E**: Add root `errorElement` for boundary handling.
- [ ] **FND-007F**: Wrap RouterProvider in `Suspense`.
- [ ] **FND-007G**: **[TEST]** Verify navigation between placeholder pages.

### Definition of Done

- [ ] Data loaders eliminate request waterfalls.
- [ ] Route-level code splitting active.
- [ ] All routes navigable without console errors.
- [ ] All tests pass.

### Anti‑Patterns

- ❌ Using `<BrowserRouter>` (Declarative Mode).
- ❌ Importing from `react-router-dom`.

---

## 🗂️ Task FND-008: App Entry Point & Provider Composition

**Priority:** 🔴 High  
**Est. Effort:** 0.5 hours  
**Depends On:** FND-005, FND-006, FND-007  

**Related Files**  
- `src/main.tsx`
- `src/layouts/AppShell.tsx`

### Subtasks

- [ ] **FND-008A**: Compose provider tree in `main.tsx`: `QueryClient` → `Theme` → `Router`.
- [ ] **FND-008B**: Clean up `App.tsx` and move root layout to `AppShell.tsx`.
- [ ] **FND-008C**: Implement `AppShell` with Sidebar, Main, Outlet, and Status Bar.
- [ ] **FND-008D**: Implement page transitions using `AnimatePresence` and `location.pathname`.
- [ ] **FND-008E**: Add `SkipLink` for keyboard accessibility.
- [ ] **FND-008F**: **[TEST]** Verify full render tree mount.

### Definition of Done

- [ ] Provider order allows loaders access to QueryClient.
- [ ] Root layout shell correctly wraps all route content.
- [ ] Page transitions active between routes.
- [ ] All tests pass.

### Anti‑Patterns

- ❌ Placing `RouterProvider` above `QueryClientProvider`.

---

## 🗂️ Task FND-009: Global Layout — Sidebar Shell

**Priority:** 🔴 High  
**Est. Effort:** 2.0 hours  
**Depends On:** FND-005, FND-008  

**Related Files**  
- `src/components/layout/Sidebar.tsx`
- `src/components/layout/NavItem.tsx`

### Subtasks

- [ ] **FND-009A**: Build Sidebar component driven by Zustand state.
- [ ] **FND-009B**: Implement spring-animated expansion/collapse.
- [ ] **FND-009C**: Create NavItems for all 7 modules.
- [ ] **FND-009D**: Implement `layoutId` active route indicator.
- [ ] **FND-009E**: Add Settings accordion with height animation.
- [ ] **FND-009F**: Apply glass styling and noise overlay.
- [ ] **FND-009G**: **[TEST]** Verify expansion, active state, and keyboard nav.
- [ ] **FND-009H**: Respect `useReducedMotion` for width changes.

### Definition of Done

- [ ] Sidebar feels responsive and smooth.
- [ ] Active state matches current route.
- [ ] WCAG 2.5.8 Target Size compliance (≥24px targets).
- [ ] All tests pass.

### Anti‑Patterns

- ❌ Managing sidebar open state in local `useState`.

---

## 🗂️ Task FND-010: Global Layout — StatusBar Shell

**Priority:** 🔴 High  
**Est. Effort:** 1.0 hours  
**Depends On:** FND-008  

**Related Files**  
- `src/components/layout/StatusBar.tsx`

### Subtasks

- [ ] **FND-010A**: Create fixed 32px height bottom status bar.
- [ ] **FND-010B**: Implement connection status pulse animation.
- [ ] **FND-010C**: Display connection, agent count, time, and token spend.
- [ ] **FND-010D**: Ensure all items are keyboard-focusable.
- [ ] **FND-010E**: **[TEST]** Verify pulse respects `useReducedMotion`.

### Definition of Done

- [ ] StatusBar remains visible and non-intrusive.
- [ ] Accessibility audit for focus indicators passes.
- [ ] All tests pass.

---

## 🗂️ Task FND-011: Global Layout — RightPanel Shell

**Priority:** 🔴 High  
**Est. Effort:** 1.0 hours  
**Depends On:** FND-005, FND-008  

**Related Files**  
- `src/components/layout/RightPanel.tsx`

### Subtasks

- [ ] **FND-011A**: Create 320px slide-out right panel.
- [ ] **FND-011B**: Implement slide transition with `AnimatePresence`.
- [ ] **FND-011C**: Apply glass + noise styling.
- [ ] **FND-011D**: Implement focus restoration for panel close.
- [ ] **FND-011E**: **[TEST]** Verify slide animation and focus return.

### Definition of Done

- [ ] Panel opens/closes via Zustand `uiSlice`.
- [ ] Backdrop blur correctly layers behind panel.
- [ ] All tests pass.

---

## 🗂️ Task FND-012: Global Layout — CommandPalette Shell

**Priority:** 🔴 High  
**Est. Effort:** 2.0 hours  
**Depends On:** FND-005, FND-008  

**Related Files**  
- `src/components/layout/CommandPalette.tsx`
- `src/hooks/useIntentHandler.ts`

### Subtasks

- [ ] **FND-012A**: Create global `useKeyboardShortcut` for `Cmd+K`.
- [ ] **FND-012B**: Build Portal-based centered Command Palette.
- [ ] **FND-012C**: Implement spring-scale entry and staggered children.
- [ ] **FND-012D**: Add ARIA combobox roles and focus trap.
- [ ] **FND-012E**: Implement categorized results (Commands, Pages, etc.).
- [ ] **FND-012F**: Connect to `useIntentHandler` for AI parsing and preview.
- [ ] **FND-012G**: **[TEST]** Verify shortcut, arrow nav, and focus return.

### Definition of Done

- [ ] Fast, keyboard-first navigation.
- [ ] AI intent parsing with visual confirmation.
- [ ] Correct categorization of all searchable items.
- [ ] All tests pass.

---

## 🗂️ Task FND-013: Accessibility Foundation

**Priority:** 🔴 High  
**Est. Effort:** 1.5 hours  
**Depends On:** FND-009, FND-010, FND-011, FND-012  

**Related Files**  
- `src/layouts/AppShell.tsx`
- `src/hooks/useFocusRestoration.ts`

### Subtasks

- [ ] **FND-013A**: Add ARIA landmarks to `AppShell`.
- [ ] **FND-013B**: Verify `SkipLink` is first focusable element.
- [ ] **FND-013C**: Audit all focus indicators for 3:1 contrast and visibility.
- [ ] **FND-013D**: Implement `aria-live` for status bar updates.
- [ ] **FND-013E**: Resolve WCAG 2.4.12 Focus Not Obscured via `scroll-padding`.
- [ ] **FND-013F**: **[TEST]** Run Axe automated audit and voice smoke test.

### Definition of Done

- [ ] Zero accessibility violations in Axe audit.
- [ ] Keyboard-only navigation fully supported.
- [ ] Screen reader hierarchy correct.
- [ ] All tests pass.

---

## 🗂️ Task FND-014: Global Layout — Voice Shell

**Priority:** 🔴 High  
**Est. Effort:** 2.5 hours  
**Depends On:** FND-005, FND-008, FND-012  

**Related Files**  
- `src/components/layout/VoiceShell.tsx`
- `src/hooks/useWebSpeech.ts`

### Subtasks

- [ ] **FND-014A**: Create `useWebSpeech` hook for STT/TTS.
- [ ] **FND-014B**: Build Portal-based Voice Orb with waveform animation.
- [ ] **FND-014C**: Implement voice status lifecycle (Listening → Processing → Preview).
- [ ] **FND-014D**: Bind `Ctrl+Space` for global voice activation.
- [ ] **FND-014E**: Integrate with shared `useIntentHandler`.
- [ ] **FND-014F**: **[TEST]** Verify voice transcript, parsing, and execution.

### Definition of Done

- [ ] Hands-free command execution active.
- [ ] Visual feedback for all speech states.
- [ ] `aria-live` transcript regions present.
- [ ] All tests pass.

---

## 📊 Dependency Graph

```
FND-000
   |
FND-001
   |
FND-002
   +-- FND-003
   +-- FND-004
          |
          +-- FND-005
          +-- FND-006
          |      |
          +------+-- FND-007
                     |
               FND-008
               |
      +--------+--------+--------+
      |        |        |        |
    FND-009  FND-010  FND-011  FND-012
      |        |        |        |
      +--------+--------+--------+
               |
            FND-013
               |
            FND-014
```

---

## ✅ Module Completion Checklist

- [ ] All tasks marked ✅
- [ ] All tests pass