# 32‑Conference — Personal AI Command Center Frontend

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.
> **Source Research**: Virtual roundtable platforms, video conferencing systems, and collaborative meeting spaces — feature analysis conducted April 2026. Modern conference applications combine HD video streaming, role-based participation, session recording, real-time collaboration tools, and advanced engagement features to create immersive roundtable experiences.

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

## 🧱 Cross-Cutting Foundations

| ID | Area | Requirement |
|----|------|-------------|
| **CONF-C01** | Real-time Communication | WebRTC-based video/audio streaming with adaptive bitrate. Support for up to 16 active participants in roundtable layout. |
| **CONF-C02** | Role-Based Access Control | Four distinct roles: Moderator, Participant, Observer, and Recorder. Each role has specific permissions and UI adaptations. |
| **CONF-C03** | Session Recording & Output | Capture video, audio, chat, and shared content. Export to MP4, transcript (SRT/VTT), and summary markdown. |
| **CONF-C04** | Observer Mode Privacy | Observer participants see and hear everything but cannot interact unless promoted. Visual distinction in UI. |
| **CONF-C05** | Roundtable Layout | Dynamic video grid that maintains circular/seating arrangement perspective. Automatic speaker focus and active speaker detection. |
| **CONF-C06** | Engagement Tools | Live chat, Q&A, polls, whiteboard, screen sharing, and breakout rooms. All tools support role-based permissions. |
| **CONF-C07** | Session Analytics | Track participation metrics, speaking time, engagement levels, and content interactions. Real-time dashboard for moderators. |
| **CONF-C08** | Scenario Templates | Pre-configured role-playing scenarios (Advisory Board, Brainstorming, Product Discussion, Networking, Problem-Solving). |
| **CONF-C09** | Motion & Accessibility | Respect `prefers-reduced-motion`. All video controls keyboard accessible. Screen reader support for all UI elements. |
| **CONF-C10** | State Management | TanStack Query for session data, Zustand for UI state (active tools, layout preferences, role switching). |

### Motion Tier Assignment

| Component | Tier | Technique |
|-----------|------|-----------|
| Participant video tiles | **Static** | Instant render; no animation (performance critical) |
| Active speaker highlight | **Quiet** | Opacity fade 200ms; subtle blue glow |
| Chat message entry | **Alive** | Slide in from bottom, spring stiffness 300 damping 30 |
| Poll results update | **Quiet** | Opacity fade 150ms; bar height transitions |
| Breakout room open/close | **Alive** | Scale `0.95→1` + opacity, spring animation |
| Whiteboard tool selection | **Quiet** | Instant icon change; no transition |
| Recording indicator | **Alive** | Pulsing red dot, keyframes opacity `[0.5, 1, 0.5]` |
| Role badge assignment | **Quiet** | Fade in 100ms; slide from right |
| Scenario template card | **Alive** | Hover lift `y: -2` + shadow, spring |
| Analytics chart updates | **Quiet** | Smooth data transitions, 300ms |

---


## 🗂️ Task CONF-001: Conference Page Layout & Navigation
**Priority:** 🔴 High
**Est. Effort:** 2 hours
**Depends On:** FND-007 (Router), FND-008 (Provider Tree)

### Related Files
`src/pages/ConferencePage.tsx` · `src/components/conference/ConferenceLayout.tsx` · `src/router/routes.ts`

### Subtasks

- [ ] **CONF-001A**: Create `src/pages/ConferencePage.tsx`:
  - Main conference dashboard with session list and quick actions
  - "Start New Conference" button and "Join Conference" input
  - Recent sessions list with status indicators
  - Top navigation bar with user profile and settings

- [ ] **CONF-001B**: Create `src/components/conference/ConferenceLayout.tsx`:
  - Full-screen conference interface layout
  - Left sidebar (240px): participant list, chat, tools
  - Center area: roundtable video grid
  - Right panel (320px): session info, analytics, controls
  - Bottom control bar: video/audio controls, screen share, recording

- [ ] **CONF-001C**: Add conference routes to router:
  - `/conference` - main dashboard
  - `/conference/:id` - active conference session
  - `/conference/new` - create new conference

### Definition of Done
- Conference dashboard renders with mock session data
- Navigation between conference pages works
- Layout components are responsive and adapt to screen sizes
- All UI elements follow the established visual identity

### Acceptance Criteria
- Navigate to `/conference` shows dashboard with mock sessions
- Click "Start New Conference" navigates to creation flow
- Layout components render in correct positions
- Responsive design works on tablet and mobile views

### Strict Rules
- Use semantic HTML5 elements (`main`, `aside`, `nav`, `section`)
- All interactive elements must have accessible names
- Follow established color scheme and typography

---


## 🗂️ Task CONF-002: Roundtable Video Grid & Active Speaker Detection
**Priority:** 🔴 High
**Est. Effort:** 4 hours
**Depends On:** CONF-001

### Related Files
`src/components/conference/RoundtableGrid.tsx` · `src/components/conference/ParticipantTile.tsx` · `src/hooks/useActiveSpeaker.ts`

### Subtasks

- [ ] **CONF-002A**: Create `src/components/conference/RoundtableGrid.tsx`:
  - Circular/seating arrangement layout for video tiles
  - Support for 4-16 participants with automatic repositioning
  - Active speaker highlighting and automatic focus
  - Smooth transitions when participants join/leave

- [ ] **CONF-002B**: Create `src/components/conference/ParticipantTile.tsx`:
  - Video feed with user avatar fallback
  - Name badge and role indicator
  - Mute/deafened status indicators
  - Connection quality indicator
  - Hover controls for moderator actions

- [ ] **CONF-002C**: Implement `src/hooks/useActiveSpeaker.ts`:
  - WebRTC audio level monitoring
  - Active speaker detection algorithm
  - Debounced speaker changes (500ms minimum)
  - Integration with RoundtableGrid for highlighting

### Definition of Done
- Roundtable layout maintains circular arrangement
- Active speaker is highlighted with blue glow effect
- Participants can be dynamically added/removed
- Video feeds render with proper aspect ratios
- Audio-only participants show avatar with audio visualizer

### Acceptance Criteria
- Grid displays 4, 8, 12, or 16 participants in circular layout
- Active speaker gets blue border glow within 200ms
- Adding/removing participants reorganizes grid smoothly
- Audio-only participants show animated avatar
- Connection quality indicators reflect actual stream status

### Strict Rules
- Use CSS Grid for layout (no JavaScript positioning)
- Video elements must have `playsinline` attribute for iOS
- Respect `prefers-reduced-motion` for layout transitions

---


## 🗂️ Task CONF-003: Role-Based Access Control & Permissions
**Priority:** 🔴 High
**Est. Effort:** 3 hours
**Depends On:** CONF-001

### Related Files
`src/components/conference/RoleBadge.tsx` · `src/hooks/useConferenceRoles.ts` · `src/lib/conferencePermissions.ts`

### Subtasks

- [ ] **CONF-003A**: Implement role system in `src/lib/conferencePermissions.ts`:
  - Four roles: Moderator, Participant, Observer, Recorder
  - Permission matrix for each action (speak, chat, share, record, etc.)
  - Role promotion/demotion logic
  - Observer mode privacy controls

- [ ] **CONF-003B**: Create `src/components/conference/RoleBadge.tsx`:
  - Visual role indicators with color coding
  - Moderator: gold badge with crown icon
  - Participant: blue badge with person icon
  - Observer: gray badge with eye icon
  - Recorder: red badge with record icon

- [ ] **CONF-003C**: Implement `src/hooks/useConferenceRoles.ts`:
  - Current user role tracking
  - Permission checking helpers
  - Role change event handling
  - UI adaptation based on role

### Definition of Done
- Role system controls access to all conference features
- Visual role badges are clearly distinguishable
- Observer mode prevents all interaction unless promoted
- Moderators can manage roles during active sessions
- Role changes update UI immediately

### Acceptance Criteria
- Moderators can promote/demote participants
- Observer participants cannot use chat, speak, or share
- Role badges appear on participant tiles and in chat
- UI controls are disabled/enabled based on permissions
- Role changes persist for session duration

### Strict Rules
- All permission checks must happen server-side (mocked for now)
- Observer mode must be visually distinct in all UI elements
- Role changes require confirmation dialog for moderator actions

---


## 🗂️ Task CONF-004: Session Recording & Output Capture
**Priority:** 🟠 Medium
**Est. Effort:** 4 hours
**Depends On:** CONF-002

### Related Files
`src/components/conference/RecordingControls.tsx` · `src/hooks/useRecording.ts` · `src/lib/outputCapture.ts`

### Subtasks

- [ ] **CONF-004A**: Create `src/components/conference/RecordingControls.tsx`:
  - Record/pause/stop buttons with visual feedback
  - Recording indicator with pulsing red dot
  - Recording quality settings (720p/1080p)
  - Output format selection (MP4, WebM, Audio Only)

- [ ] **CONF-004B**: Implement `src/hooks/useRecording.ts`:
  - MediaRecorder API integration
  - Recording state management
  - Blob storage for recorded chunks
  - Recording metadata tracking

- [ ] **CONF-004C**: Create `src/lib/outputCapture.ts`:
  - Chat transcript generation
  - Participant speaking time analytics
  - Session summary generation
  - Export functionality (JSON, CSV, Markdown)

### Definition of Done
- Recording captures video, audio, and chat simultaneously
- Multiple output formats are supported
- Recording controls are accessible to authorized roles
- Output capture includes comprehensive session analytics
- Export functionality generates downloadable files

### Acceptance Criteria
- Clicking record starts recording with visual indicator
- Recording can be paused and resumed
- Stop recording generates downloadable file
- Transcript includes timestamps and speaker identification
- Analytics show speaking time per participant

### Strict Rules
- Recording must be announced to all participants
- Only moderators and recorders can control recording
- Recording files must be stored locally (no backend)
- Include consent recording notification

---


## 🗂️ Task CONF-005: Engagement Tools (Chat, Q&A, Polls, Whiteboard)
**Priority:** 🔴 High
**Est. Effort:** 5 hours
**Depends On:** CONF-003

### Related Files
`src/components/conference/ChatPanel.tsx` · `src/components/conference/QAPanel.tsx` · `src/components/conference/PollPanel.tsx` · `src/components/conference/Whiteboard.tsx`

### Subtasks

- [ ] **CONF-005A**: Create `src/components/conference/ChatPanel.tsx`:
  - Real-time chat with message history
  - Role-based message styling (moderator messages highlighted)
  - Emoji reactions and message threading
  - Chat export functionality

- [ ] **CONF-005B**: Create `src/components/conference/QAPanel.tsx`:
  - Q&A queue with upvoting system
  - Moderator controls for answering/dismissing questions
  - Anonymous question option for participants
  - Question status tracking (pending, answered, dismissed)

- [ ] **CONF-005C**: Create `src/components/conference/PollPanel.tsx`:
  - Live poll creation and management
  - Multiple question types (multiple choice, ranking, yes/no)
  - Real-time result visualization
  - Poll export and sharing

- [ ] **CONF-005D**: Create `src/components/conference/Whiteboard.tsx`:
  - Collaborative drawing canvas
  - Drawing tools (pen, shapes, text, eraser)
  - Canvas export and clear functions
  - Multi-user cursor tracking

### Definition of Done
- All engagement tools support role-based permissions
- Real-time updates work smoothly across all participants
- Tools are accessible via keyboard and screen reader
- Export functionality works for all tools
- Analytics track engagement metrics

### Acceptance Criteria
- Chat messages appear instantly for all participants
- Q&A questions can be upvoted and moderated
- Polls show live results as participants vote
- Whiteboard supports simultaneous drawing
- All tools work in breakout rooms

### Strict Rules
- Observer participants cannot interact with engagement tools
- All interactive elements must have focus indicators
- Real-time updates use efficient batching (max 100ms)

---


## 🗂️ Task CONF-006: Scenario Templates & Role-Playing Framework
**Priority:** 🟠 Medium
**Est. Effort:** 3 hours
**Depends On:** CONF-005

### Related Files
`src/components/conference/ScenarioTemplates.tsx` · `src/lib/scenarios.ts` · `src/hooks/useScenario.ts`

### Subtasks

- [ ] **CONF-006A**: Create `src/lib/scenarios.ts`:
  - Pre-configured scenario templates:
    - Advisory Board Meeting
    - Peer-to-Peer Learning Session
    - Problem-Solving & Brainstorming
    - Focused Product Discussion
    - Networking Session
  - Scenario metadata (duration, participants, roles, objectives)
  - Scenario-specific tool configurations

- [ ] **CONF-006B**: Create `src/components/conference/ScenarioTemplates.tsx`:
  - Scenario selection grid with preview cards
  - Scenario customization interface
  - One-click scenario setup
  - Scenario progress tracking

- [ ] **CONF-006C**: Implement `src/hooks/useScenario.ts`:
  - Active scenario state management
  - Scenario step tracking and timing
  - Role assignment based on scenario
  - Scenario completion analytics

### Definition of Done
- Five pre-configured scenarios are available
- Scenarios can be customized before starting
- Role assignments happen automatically based on scenario
- Progress tracking shows current step and time remaining
- Analytics capture scenario-specific metrics

### Acceptance Criteria
- Select "Advisory Board" scenario sets up moderator + board roles
- "Brainstorming" scenario enables whiteboard and chat tools
- Scenario timer shows progress and remaining time
- Completion generates scenario-specific report
- Custom scenarios can be saved and reused

### Strict Rules
- Scenario templates must be customizable
- Role assignments respect user permissions
- Scenario timing includes breaks and transitions
- All scenarios must be accessible to screen readers

---


## 🗂️ Task CONF-007: Breakout Rooms & Sub-Conferences
**Priority:** 🟠 Medium
**Est. Effort:** 4 hours
**Depends On:** CONF-006

### Related Files
`src/components/conference/BreakoutRoomManager.tsx` · `src/components/conference/BreakoutRoom.tsx` · `src/hooks/useBreakoutRooms.ts`

### Subtasks

- [ ] **CONF-007A**: Create `src/components/conference/BreakoutRoomManager.tsx`:
  - Breakout room creation and management interface
  - Automatic and manual participant assignment
  - Timer for breakout sessions
  - Broadcast message to all rooms

- [ ] **CONF-007B**: Create `src/components/conference/BreakoutRoom.tsx`:
  - Independent conference room instance
  - Shared tools (chat, whiteboard, screen share)
  - Room-specific recording capabilities
  - Help request system for moderators

- [ ] **CONF-007C**: Implement `src/hooks/useBreakoutRooms.ts`:
  - Room state management
  - Participant assignment tracking
  - Timer and countdown functionality
  - Room broadcast system

### Definition of Done
- Moderators can create multiple breakout rooms
- Participants can be automatically or manually assigned
- Each room operates as independent conference
- Broadcast messages reach all rooms simultaneously
- Rooms can be extended or closed early

### Acceptance Criteria
- Create 4 breakout rooms for 16 participants (4 per room)
- Timer counts down and automatically returns participants
- Broadcast message appears in all rooms
- Participants can request help from moderator
- Room recordings are captured independently

### Strict Rules
- Only moderators can manage breakout rooms
- Room assignments must respect user preferences when possible
- All rooms must have equal tool access
- Recording permissions follow main conference rules

---


## 🗂️ Task CONF-008: Conference Analytics & Reporting
**Priority:** 🟠 Medium
**Est. Effort:** 3 hours
**Depends On:** CONF-007

### Related Files
`src/components/conference/AnalyticsDashboard.tsx` · `src/components/conference/SessionReport.tsx` · `src/hooks/useConferenceAnalytics.ts`

### Subtasks

- [ ] **CONF-008A**: Create `src/components/conference/AnalyticsDashboard.tsx`:
  - Real-time participation metrics
  - Speaking time analysis
  - Engagement tool usage statistics
  - Network quality monitoring

- [ ] **CONF-008B**: Create `src/components/conference/SessionReport.tsx`:
  - Comprehensive session summary
  - Participant contribution analysis
  - Tool usage breakdown
  - Exportable report formats

- [ ] **CONF-008C**: Implement `src/hooks/useConferenceAnalytics.ts`:
  - Real-time metrics calculation
  - Historical data aggregation
  - Report generation logic
  - Export functionality

### Definition of Done
- Analytics update in real-time during conferences
- Multiple visualization types (charts, graphs, heatmaps)
- Reports include all session data and insights
- Export formats include PDF, Excel, and JSON
- Analytics respect privacy and observer mode

### Acceptance Criteria
- Speaking time chart shows top contributors
- Engagement metrics track chat, poll, and Q&A participation
- Network quality indicators reflect actual performance
- Session report generates within 10 seconds
- Export files include all relevant data

### Strict Rules
- Observer mode data must be anonymized
- Analytics must not impact conference performance
- All charts must be accessible with keyboard navigation
- Export files must comply with data privacy standards

---


## 🗂️ Task CONF-009: Conference Settings & Configuration
**Priority:** 🟢 Low
**Est. Effort:** 2 hours
**Depends On:** CONF-008

### Related Files
`src/components/conference/ConferenceSettings.tsx` · `src/components/conference/DeviceSettings.tsx` · `src/hooks/useConferenceSettings.ts`

### Subtasks

- [ ] **CONF-009A**: Create `src/components/conference/ConferenceSettings.tsx`:
  - Conference preferences and defaults
  - Recording settings and permissions
  - Engagement tool configurations
  - Scenario template management

- [ ] **CONF-009B**: Create `src/components/conference/DeviceSettings.tsx`:
  - Camera and microphone selection
  - Audio/video quality settings
  - Network bandwidth optimization
  - Device testing interface

- [ ] **CONF-009C**: Implement `src/hooks/useConferenceSettings.ts`:
  - Settings persistence
  - Default configuration management
  - Device capability detection
  - Settings validation

### Definition of Done
- Settings persist across browser sessions
- Device detection works for camera, microphone, and speakers
- Quality settings adapt to network conditions
- Settings include accessibility options
- Configuration can be exported/imported

### Acceptance Criteria
- Camera selection works with multiple devices
- Audio quality adjusts based on bandwidth
- Settings are saved and restored on reload
- Device test confirms functionality before conference
- Accessibility settings are respected

### Strict Rules
- Settings must work without backend (localStorage)
- Device permissions must be requested explicitly
- Quality settings must not degrade below usable levels
- All settings must be keyboard accessible

---


## 🗂️ Task CONF-010: Conference Integration & Mock Data
**Priority:** 🔴 High
**Est. Effort:** 2 hours
**Depends On:** CONF-009

### Related Files
`src/mocks/handlers/conference.ts` · `src/lib/mockData/conference.ts` · `src/hooks/useConferenceMock.ts`

### Subtasks

- [ ] **CONF-010A**: Create `src/lib/mockData/conference.ts`:
  - Mock conference sessions with realistic data
  - Participant profiles with roles and permissions
  - Scenario templates with sample configurations
  - Analytics data with realistic metrics

- [ ] **CONF-010B**: Create `src/mocks/handlers/conference.ts`:
  - MSW handlers for conference API endpoints
  - Realistic response delays (300-800ms)
  - State management for ongoing sessions
  - Error simulation for edge cases

- [ ] **CONF-010C**: Implement `src/hooks/useConferenceMock.ts`:
  - Mock WebRTC video streams
  - Simulated active speaker detection
  - Fake recording and analytics generation
  - Real-time collaboration simulation

### Definition of Done
- All conference features work with mock data
- Mock WebRTC streams show placeholder videos
- Real-time features update smoothly
- Error handling works for edge cases
- Mock data is realistic and comprehensive

### Acceptance Criteria
- Conference dashboard shows 5-10 mock sessions
- Video tiles show placeholder content with user avatars
- Chat messages update in real-time
- Recording generates fake output files
- Analytics show realistic participation metrics

### Strict Rules
- Mock data must use @faker-js/faker with seed
- All network calls must go through MSW
- WebRTC simulation must not require actual camera
- Real-time updates must use proper timing

---

## 🎯 Conference Feature Summary

### Core Capabilities
- **Roundtable Layout**: Dynamic video grid maintaining circular seating arrangement
- **Role System**: Moderator, Participant, Observer, Recorder with distinct permissions
- **Session Recording**: Multi-format capture with comprehensive output options
- **Engagement Tools**: Chat, Q&A, Polls, Whiteboard with real-time collaboration
- **Scenario Templates**: Pre-configured role-playing frameworks for different meeting types
- **Breakout Rooms**: Independent sub-conferences with full tool support
- **Analytics Dashboard**: Real-time participation metrics and session insights
- **Accessibility**: WCAG 2.2 AA compliance with keyboard navigation and screen reader support

### Technical Implementation
- **WebRTC**: Real-time video/audio streaming with adaptive bitrate
- **State Management**: TanStack Query for server state, Zustand for UI state
- **Motion**: Respect reduced motion preferences with appropriate animation tiers
- **Virtualization**: Efficient rendering for large participant lists
- **Mock Infrastructure**: Comprehensive MSW handlers and realistic test data

### User Experience
- **Responsive Design**: Works seamlessly on desktop, tablet, and mobile
- **Real-time Collaboration**: Instant updates across all participants
- **Privacy Controls**: Observer mode and role-based access control
- **Export Capabilities**: Multiple formats for recordings and analytics
- **Customization**: Flexible settings and scenario configuration
