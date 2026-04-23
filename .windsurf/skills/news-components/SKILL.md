---
name: news-components
description: Guides the creation of news feed components including NewsPage, NewsFeed, NewsCard, TopicSelector, SourceManager, FrequencySlider, and NewsSidebar with preference-driven curation
---

## News Components

### NewsPage.tsx
Two-column layout on desktop — left NewsSidebar (280px, fixed) + right NewsFeed (scrollable).

### NewsSidebar.tsx
Fixed sidebar (280px) with preference controls:

**My Topics section:**
- TopicSelector showing active topic chips
- Topics: Technology, AI/ML, Business, Science, Health, Finance, Design, Geopolitics, Sports
- User picks subset
- Active chips: blue
- Inactive chips: charcoal
- Click to toggle

**My Sources section:**
- SourceManager — list of news sources
- Each source has trust tier badge (Tier 1: Editorial, Tier 2: Independent, Tier 3: Community)
- Toggle each source on/off
- "Add Source" opens modal with URL input

**Update Frequency section:**
- FrequencySlider with stops: Real-time | Hourly | Every 6 hrs | Daily Digest
- Shows time of last refresh
- "Refresh Now" button

**Saved Articles link:**
- Shows count of bookmarked articles
- Click to view saved articles

**"Save Preferences" button** (blue, bottom of sidebar)

### TopicSelector.tsx
- Grid of topic chips
- Each chip: topic name, toggle state
- Active: blue background, white text
- Inactive: charcoal background, gray text
- Click to toggle
- Multi-select enabled
- Visual feedback on selection

### SourceManager.tsx
- List of news sources
- Each item: source name + logo placeholder, trust tier badge, toggle switch
- Trust tier colors: Tier 1 (green), Tier 2 (amber), Tier 3 (gray)
- Toggle switch: on/off
- "Add Source" button at top
- Opens modal with URL input and name field

### FrequencySlider.tsx
- Slider control with labeled stops
- Stops: Real-time | Hourly | Every 6 hrs | Daily Digest
- Shows current selection with blue indicator
- Smooth slide animation
- Shows estimated next refresh time

### NewsFeed.tsx
Scrollable main content area:
- Sorted by recency by default
- Toggle to Relevance or Trending
- Filter tabs at top: All | Technology | Business | Science | (active topics only shown)
- Each article rendered as NewsCard
- Infinite scroll or pagination
- "Load more" button

### NewsCard.tsx
Each card shows:
- Source name + logo placeholder + trust tier badge
- Published timestamp (relative: "2 hours ago")
- Headline (bold, 2 lines max)
- AI-generated 2-sentence summary (italicized, gray)
- Sentiment indicator: Positive (green dot) / Neutral (gray dot) / Negative (red dot)
- Topic tag chips
- Read time estimate
- Actions: Bookmark (star icon), Share, Open Full Article (external link icon), Hide article (x icon)
- "Read more" expands the full AI summary inline
- Hover: subtle lift and shadow
- Click headline: opens article in new tab

## Data Requirements

All news components must use realistic mock data from `src/lib/mockData/news.ts` with:
- Multiple news articles with various topics
- Different sources with trust tiers
- AI-generated summaries
- Sentiment indicators
- Realistic timestamps
- Various topics and sources

## State Management

- Use TanStack Query for fetching news feed and preferences
- Use Zustand for UI-only state (active topics, source toggles, frequency selection)
- Persist preferences to localStorage or mock API

## Accessibility Requirements (WCAG 2.2 AA)

- NewsPage: proper ARIA landmarks (main, aside, navigation), semantic HTML
- NewsSidebar: proper landmark (complementary), keyboard navigation for controls
- TopicSelector: toggle button role, aria-pressed state, aria-label for each topic
- SourceManager: proper labels for toggles, aria-describedby for source descriptions
- NewsCard: proper heading hierarchy (h2-h3), link roles, aria-label for actions
- All interactive elements: 4.5:1 color contrast ratio minimum
- Focus management: visible focus indicators, logical tab order
- Dynamic content: aria-live regions for feed updates
- Screen readers: announce article loading, preference changes
- Keyboard navigation: arrow keys for topic/source lists, escape to close modals

## Visual Identity

- Glass panels: backdrop-blur-md bg-white/5 border border-white/10 rounded-xl
- Electric blue accent: #0066ff → #00aaff for CTAs and active states
- Trust tier colors: Tier 1 (green), Tier 2 (amber), Tier 3 (gray)
- Sentiment colors: Positive (green), Neutral (gray), Negative (red)
- 150ms ease-out transitions on all interactive elements
- Skeleton loaders on all data fetch states

**Tailwind v4 & shadcn/ui Notes (2026):**
- shadcn/ui v2+ uses Tailwind v4 with @theme directive
- Components have data-slot attributes for styling
- forwardRef removed from components (React 19 pattern)
- HSL colors converted to OKLCH in v4
- Default style deprecated, new projects use new-york style

## Content Handling

- Truncate headlines to 2 lines with ellipsis
- Show AI summary in italicized gray text
- "Read more" expands full summary inline
- Bookmark state persists across sessions
- Hide article removes it from feed (can be undone)
- Share button copies URL to clipboard (mocked)
