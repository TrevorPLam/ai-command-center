# 09-Workflow — Personal AI Command Center Frontend (v1)

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.

> **Research Note**: This specification is based on comprehensive analysis of leading 2026 workflow automation platforms including n8n, Zapier, Make, Vellum AI, and enterprise AI orchestration frameworks. The module implements a node-based visual canvas for agent orchestration, human-in-the-loop workflows, and automation chain management.

---

## 🔬 Research Findings — Workflow Module

| Finding | Source | Action Required |
|---------|--------|-----------------|
| **Node-based visual editors** are the dominant UX pattern for workflow automation, with drag-and-drop nodes representing actions, triggers, and decision points. | n8n, Make, Zapier, Vellum AI | FLOW-001: Implement React Flow-based canvas with draggable nodes and connections |
| **Multi-agent orchestration** requires distributed execution contexts with isolation patterns and event-driven communication between agents. | n8n 2026 AI Agent Framework | FLOW-002: Design agent execution engine with isolation and pub/sub communication |
| **Human-in-the-loop breakpoints** are essential for enterprise workflows, requiring approval gates, manual input nodes, and escalation paths. | Vellum AI, Workato | FLOW-004: Implement approval nodes and human interaction patterns |
| **Visual debugging and observability** are critical - users need step-by-step introspection, real-time execution traces, and error recovery. | n8n, Tray.ai | FLOW-005: Build execution viewer with step tracing and error handling |
| **Template and pattern reuse** accelerates workflow creation - users need pre-built patterns for common automation scenarios. | Zapier Templates, Make Recipes | FLOW-006: Create template library and pattern reuse system |
| **Version control and environments** are enterprise requirements - dev/staging/prod deployment with safe rollbacks. | Vellum AI, Workato | FLOW-007: Implement workflow versioning and environment management |
| **Security and compliance** require input validation, audit trails, role-based access, and data protection. | n8n Security Architecture, OWASP | FLOW-008: Add security layer with validation and audit logging |

---

## 🧱 Cross-Cutting Foundations

| ID | Area | Requirement |
|----|------|-------------|
| **FLOW-C01** | Canvas Engine | React Flow for node-based visual editing with custom node types and edge types |
| **FLOW-C02** | Agent Orchestration | Distributed execution with process isolation and Redis pub/sub communication |
| **FLOW-C03** | State Management | Zustand `workflowSlice` for canvas state, execution status, and workflow definitions |
| **FLOW-C04** | Human-in-the-Loop | Approval nodes, manual input nodes, and escalation patterns with notification system |
| **FLOW-C05** | Observability | Real-time execution traces, step-by-step debugging, and error recovery mechanisms |
| **FLOW-C06** | Template System | Reusable workflow patterns with parameter substitution and inheritance |
| **FLOW-C07** | Version Control | Workflow versioning with dev/staging/prod environments and rollback capabilities |
| **FLOW-C08** | Security | Input validation, audit trails, RBAC, and data protection for sensitive workflows |
| **FLOW-C09** | Performance | Lazy loading of large workflows, virtual rendering for complex canvases |
| **FLOW-C10** | Accessibility | Keyboard navigation, screen reader support, and ARIA labels for canvas elements |

### 🎯 Motion Tier Assignment

| Component | Tier | Allowed Techniques |
|-----------|------|--------------------|
| Node drag/resize | **Alive** | Spring physics with glow effect during drag |
| Connection line drawing | **Quiet** | Smooth bezier curve animation (≤200ms) |
| Execution pulse | **Alive** | Progress indicator with electric blue glow traveling through connections |
| Panel slide-in/out | **Quiet** | Spring slide with `AnimatePresence` |
| Template library items | **Static** | No animation for performance |
| Error state shake | **Alive** | Subtle shake animation on failed nodes |
| Approval dialog | **Quiet** | Scale fade with backdrop blur |

---

## 🗃️ Task FLOW-000: Workflow Domain Model & Mock Data
**Priority:** 🔴 High | **Est. Effort:** 1.5 hours | **Depends On:** FND-001 (TypeScript Base), FND-004 (Testing)

### Related Files
- `src/domain/workflow/types.ts` · `src/domain/workflow/schemas.ts` · `src/mocks/factories/workflow.ts`

### Subtasks

- [ ] **FLOW-000A**: Define core types:
  ```ts
  export type NodeType = 'trigger' | 'agent' | 'action' | 'decision' | 'approval' | 'manual-input' | 'delay' | 'webhook'
  export type ExecutionStatus = 'idle' | 'running' | 'completed' | 'failed' | 'paused' | 'awaiting-approval'
  
  export interface WorkflowNode {
    id: string
    type: NodeType
    position: { x: number; y: number }
    data: Record<string, unknown>
    config: NodeConfig
  }
  
  export interface WorkflowEdge {
    id: string
    source: string
    target: string
    sourceHandle?: string
    targetHandle?: string
    condition?: string
  }
  
  export interface Workflow {
    id: string
    name: string
    description: string
    nodes: WorkflowNode[]
    edges: WorkflowEdge[]
    version: number
    environment: 'dev' | 'staging' | 'prod'
    status: 'draft' | 'active' | 'archived'
    createdAt: string
    updatedAt: string
  }
  ```
- [ ] **FLOW-000B**: Define execution context types:
  ```ts
  export interface WorkflowExecution {
    id: string
    workflowId: string
    status: ExecutionStatus
    startedAt: string
    completedAt?: string
    currentNodeIds: string[]
    executionLog: ExecutionLogEntry[]
    variables: Record<string, unknown>
    error?: string
  }
  ```
- [ ] **FLOW-000C**: Create mock factories:
  - `createMockWorkflow(overrides?)` with realistic node patterns
  - `createMockAgentNode()` for AI agent nodes
  - `createMockApprovalNode()` for human approval nodes
  - `createMockExecution()` for execution state
- [ ] **FLOW-000D**: Create Zod schemas for all types
- [ ] **FLOW-000E**: Define query options and mutation hooks:
  - `workflowsQueryOptions(filters)` — List with `staleTime: 60_000`
  - `workflowDetailQueryOptions(id)` — Full workflow with `staleTime: 30_000`
  - `useCreateWorkflow()` — Optimistic create with validation
  - `useUpdateWorkflow()` — Optimistic update with version increment
  - `useDeleteWorkflow()` — Optimistic archive
  - `useExecuteWorkflow()` — Optimistic execution status update
  - **Critical**: All mutation `onMutate` handlers must begin with `await queryClient.cancelQueries(...)` before `getQueryData` / `setQueryData` to prevent race conditions
- [ ] **FLOW-000F**: **Tests**: Unit tests for all domain types and factories

### Definition of Done
- Complete domain model with all workflow-related entities
- Zod schemas provide runtime validation
- Mock factories produce realistic test data
- All types are covered by tests
- Query key factory and mutation hooks with optimistic updates

### Anti-Patterns
- ❌ Skipping `cancelQueries` in `onMutate` — creates race conditions when a background refetch overwrites the optimistic state

---

## 🎨 Task FLOW-001: Visual Canvas Engine (React Flow)
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** FLOW-000, FND-003 (UI Components)

### Related Files
- `src/components/workflow/WorkflowCanvas.tsx` · `src/components/workflow/CustomNodeTypes.tsx` · `src/components/workflow/NodePalette.tsx`

### Subtasks

- [ ] **FLOW-001A**: Install and configure React Flow:
  ```bash
  pnpm add reactflow @reactflow/core @reactflow/background @reactflow/controls
  ```
- [ ] **FLOW-001B**: Implement `WorkflowCanvas` component:
  - React Flow provider with custom node and edge types
  - Grid background with snap-to-grid functionality
  - Minimap for navigation in large workflows
  - Keyboard shortcuts (Ctrl+Z undo, Ctrl+Y redo, Delete selected)
- [ ] **FLOW-001C**: Create custom node types:
  - **Trigger Node**: Lightning bolt icon, blue border
  - **Agent Node**: AI brain icon, purple border with status indicator
  - **Action Node**: Gear icon, green border
  - **Decision Node**: Diamond shape, orange border
  - **Approval Node**: Shield icon, red border with pending badge
  - **Manual Input Node**: Keyboard icon, yellow border
  - **Delay Node**: Clock icon, gray border
  - **Webhook Node**: Web icon, teal border
- [ ] **FLOW-001D**: Implement node interactions:
  - Drag to move nodes with grid snapping
  - Resize handles for larger nodes
  - Right-click context menu with node actions
  - Double-click to edit node configuration
- [ ] **FLOW-001E**: Create `NodePalette` sidebar:
  - Categorized node types (Triggers, Actions, AI, Control Flow)
  - Drag from palette to canvas to create nodes
  - Search functionality for node types
  - Recently used nodes section
- [ ] **FLOW-001F**: Implement edge creation:
  - Click and drag from node handles to create connections
  - Connection validation (compatible node types)
  - Edge labels and conditions
  - Animated edge rendering during execution
- [ ] **FLOW-001G**: **Tests**: Canvas rendering, node creation, edge creation, keyboard shortcuts

### Definition of Done
- Fully functional visual canvas with React Flow
- All custom node types implemented with proper styling
- Node palette with drag-and-drop functionality
- Edge creation with validation
- Keyboard navigation and shortcuts working

---

## ⚙️ Task FLOW-002: Agent Orchestration Engine
**Priority:** 🔴 High | **Est. Effort:** 4 hours | **Depends On:** FLOW-000

### Related Files
- `src/services/workflowExecutor.ts` · `src/services/agentManager.ts` · `src/services/eventBus.ts`

### Subtasks

- [ ] **FLOW-002A**: Implement `WorkflowExecutor` class:
  ```ts
  class WorkflowExecutor {
    private eventBus: EventBus
    private agentManager: AgentManager
    private executionState: Map<string, WorkflowExecution>
    
    async executeWorkflow(workflowId: string, triggerData?: unknown): Promise<string>
    async pauseExecution(executionId: string): Promise<void>
    async resumeExecution(executionId: string): Promise<void>
    async cancelExecution(executionId: string): Promise<void>
  }
  ```
- [ ] **FLOW-002B**: Create `AgentManager` for agent lifecycle:
  - Agent isolation using Web Workers or process boundaries
  - Agent registration and discovery
  - Agent health monitoring and restart
  - Resource allocation and limits
- [ ] **FLOW-002C**: Implement `EventBus` for node communication:
  - Redis-like pub/sub pattern (mocked in frontend)
  - Event validation with JSON schemas
  - Event routing and filtering
  - Event persistence and replay
- [ ] **FLOW-002D**: Create execution engine:
  - Topological sort for node execution order
  - Parallel execution where possible
  - Conditional branching based on decision nodes
  - Error handling and retry logic
- [ ] **FLOW-002E**: Implement node execution handlers:
  - `executeTriggerNode()` - Handle webhook and scheduled triggers
  - `executeAgentNode()` - Execute AI agent with context
  - `executeActionNode()` - Perform API calls and integrations
  - `executeDecisionNode()` - Evaluate conditions and route flow
  - `executeApprovalNode()` - Wait for human approval
  - `executeManualInputNode()` - Collect user input
  - `executeDelayNode()` - Wait for specified time
- [ ] **FLOW-002F**: Add execution persistence:
  - Save execution state to IndexedDB
  - Resume interrupted executions
  - Execution history and audit trail
- [ ] **FLOW-002G**: **Tests**: Execution engine, agent management, event bus, error handling

### Definition of Done
- Complete workflow execution engine with parallel processing
- Agent isolation and management system
- Event-driven communication between nodes
- Execution persistence and recovery
- Comprehensive error handling and retry logic

---

## 👤 Task FLOW-003: Human-in-the-Loop System
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** FLOW-001, FLOW-002

### Related Files
- `src/components/workflow/ApprovalPanel.tsx` · `src/components/workflow/ManualInputDialog.tsx` · `src/services/notificationService.ts`

### Subtasks

- [ ] **FLOW-003A**: Create `ApprovalPanel` component:
  - List of pending approvals with workflow context
  - Approve/Reject/Request More Info actions
  - Batch approval capabilities
  - Approval history and comments
- [ ] **FLOW-003B**: Implement approval workflow:
  - Approval node pauses execution
  - Notification system (email, in-app, push)
  - Approval assignment and routing
  - Escalation rules and timeouts
- [ ] **FLOW-003C**: Create `ManualInputDialog`:
  - Dynamic form generation based on node configuration
  - Input validation and sanitization
  - File upload support
  - Progress saving for complex forms
- [ ] **FLOW-003D**: Implement notification service:
  - Real-time notifications for pending approvals
  - Notification preferences and routing
  - Reminder and escalation logic
  - Notification history and tracking
- [ ] **FLOW-003E**: Add approval analytics:
  - Approval time metrics
  - Rejection reasons analysis
  - Bottleneck identification
  - Performance dashboards
- [ ] **FLOW-003F**: **Tests**: Approval workflow, notification system, manual input handling

### Definition of Done
- Complete human-in-the-loop system with approvals and manual input
- Real-time notification system for workflow events
- Comprehensive approval analytics and reporting
- All human interaction patterns tested and functional

---

## 🔍 Task FLOW-004: Workflow Templates & Patterns
**Priority:** 🟠 Medium | **Est. Effort:** 2.5 hours | **Depends On:** FLOW-001

### Related Files
- `src/components/workflow/TemplateLibrary.tsx` · `src/components/workflow/TemplateEditor.tsx` · `src/data/workflowTemplates.ts`

### Subtasks

- [ ] **FLOW-004A**: Create template data structure:
  ```ts
  export interface WorkflowTemplate {
    id: string
    name: string
    description: string
    category: string
    tags: string[]
    thumbnail?: string
    workflow: Omit<Workflow, 'id' | 'createdAt' | 'updatedAt'>
    parameters: TemplateParameter[]
    usage: number
    rating: number
  }
  ```
- [ ] **FLOW-004B**: Implement template library:
  - Category filtering (AI, Automation, Integration, etc.)
  - Search and discovery functionality
  - Template preview and details
  - Usage statistics and ratings
- [ ] **FLOW-004C**: Create pre-built templates:
  - **AI Agent Chain**: Multi-agent processing with human review
  - **Document Processing**: OCR → AI analysis → Human verification
  - **Customer Support**: Ticket routing → AI response → Escalation
  - **Data Pipeline**: Extract → Transform → Load with validation
  - **Approval Workflow**: Multi-level approval with notifications
  - **Integration Pattern**: Webhook → Process → Response
- [ ] **FLOW-004D**: Implement template instantiation:
  - Parameter substitution in workflow nodes
  - Dynamic node configuration based on parameters
  - Validation of required parameters
  - Template customization wizard
- [ ] **FLOW-004E**: Create template editor:
  - Visual template builder
  - Parameter definition interface
  - Template preview and testing
  - Version control for templates
- [ ] **FLOW-004F**: Add template sharing:
  - Export/import templates
  - Team template library
  - Community templates (mock)
  - Template marketplace integration
- [ ] **FLOW-004G**: **Tests**: Template creation, instantiation, parameter substitution

### Definition of Done
- Comprehensive template library with pre-built patterns
- Template instantiation with parameter substitution
- Template editor for custom workflow creation
- Template sharing and community features

---

## 📊 Task FLOW-005: Execution Monitoring & Debugging
**Priority:** 🟠 Medium | **Est. Effort:** 3 hours | **Depends On:** FLOW-002

### Related Files
- `src/components/workflow/ExecutionViewer.tsx` · `src/components/workflow/ExecutionLog.tsx` · `src/components/workflow/PerformanceMetrics.tsx`

### Subtasks

- [ ] **FLOW-005A**: Create `ExecutionViewer`:
  - Real-time visualization of workflow execution
  - Animated node highlighting during execution
  - Progress indicators and status badges
  - Execution timeline view
- [ ] **FLOW-005B**: Implement execution log:
  - Step-by-step execution details
  - Input/output data for each node
  - Error messages and stack traces
  - Log filtering and search
- [ ] **FLOW-005C**: Add debugging features:
  - Breakpoints for pausing execution
  - Step-through execution mode
  - Variable inspection and modification
  - Node-level testing
- [ ] **FLOW-005D**: Create performance metrics:
  - Execution time per node
  - Resource utilization tracking
  - Cost analysis for AI agent usage
  - Bottleneck identification
- [ ] **FLOW-005E**: Implement error recovery:
  - Automatic retry with exponential backoff
  - Manual retry options
  - Alternative path execution
  - Error notification and escalation
- [ ] **FLOW-005F**: Add execution analytics:
  - Success/failure rates
  - Performance trends
  - Usage patterns analysis
  - Optimization recommendations
- [ ] **FLOW-005G**: **Tests**: Execution viewer, debugging tools, error recovery

### Definition of Done
- Real-time execution monitoring with visual feedback
- Comprehensive debugging tools with breakpoints and step-through
- Performance metrics and analytics
- Robust error recovery and retry mechanisms

---

## 🔄 Task FLOW-006: Version Control & Environments
**Priority:** 🟠 Medium | **Est. Effort:** 2.5 hours | **Depends On:** FLOW-000

### Related Files
- `src/services/workflowVersioning.ts` · `src/components/workflow/EnvironmentManager.tsx` · `src/components/workflow/DeploymentPanel.tsx`

### Subtasks

- [ ] **FLOW-006A**: Implement versioning system:
  ```ts
  export interface WorkflowVersion {
    id: string
    workflowId: string
    version: number
    name: string
    description: string
    workflow: Workflow
    changelog: string
    author: string
    createdAt: string
    isCurrent: boolean
  }
  ```
- [ ] **FLOW-006B**: Create version management:
  - Automatic version increment on save
  - Version comparison and diff visualization
  - Rollback to previous versions
  - Branching and merging (basic)
- [ ] **FLOW-006C**: Implement environment management:
  - Dev/Staging/Prod environments
  - Environment-specific configurations
  - Deployment pipeline simulation
  - Environment isolation
- [ ] **FLOW-006D**: Create deployment panel:
  - Environment selection and validation
  - Deployment history and status
  - Rollback capabilities
  - Deployment approval workflow
- [ ] **FLOW-006E**: Add change tracking:
  - Audit trail for all changes
  - Author attribution and timestamps
  - Change impact analysis
  - Compliance reporting
- [ ] **FLOW-006F**: **Tests**: Versioning system, environment management, deployment flow

### Definition of Done
- Complete version control system with rollback capabilities
- Multi-environment support with isolation
- Deployment pipeline with approval workflows
- Comprehensive audit trail and change tracking

---

## 🔐 Task FLOW-007: Security & Compliance
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** FLOW-002

### Related Files
- `src/services/workflowSecurity.ts` · `src/components/workflow/SecurityPanel.tsx` · `src/services/auditLogger.ts`

### Subtasks

- [ ] **FLOW-007A**: Implement input validation:
  - JSON schema validation for all node inputs
  - SQL injection prevention
  - XSS protection for user inputs
  - File upload security scanning
- [ ] **FLOW-007B**: Create access control system:
  - Role-based permissions (Admin, Editor, Viewer)
  - Workflow-level access controls
  - Node-level permission checks
  - API key management
- [ ] **FLOW-007C**: Implement audit logging:
  - All workflow executions logged
  - User action tracking
  - Security event monitoring
  - Compliance reporting
- [ ] **FLOW-007D**: Add data protection:
  - Sensitive data encryption
  - PII detection and masking
  - Data retention policies
  - GDPR/CCPA compliance features
- [ ] **FLOW-007E**: Create security dashboard:
  - Security metrics and alerts
  - Access review workflow
  - Compliance status tracking
  - Security incident response
- [ ] **FLOW-007F**: **Tests**: Security validation, access controls, audit logging

### Definition of Done
- Comprehensive security validation and access control
- Complete audit logging and compliance features
- Data protection and privacy controls
- Security monitoring and incident response

---

## 📱 Task FLOW-008: Workflow Page Layout & Integration
**Priority:** 🔴 High | **Est. Effort:** 2 hours | **Depends On:** FLOW-001, FND-007 (Router)

### Related Files
- `src/pages/WorkflowPage.tsx` · `src/components/workflow/WorkflowLayout.tsx` · `src/router/routes.ts`

### Subtasks

- [ ] **FLOW-008A**: Create `WorkflowPage` with responsive layout:
  - Left sidebar: Node palette and template library
  - Main canvas area: Workflow editor
  - Right panel: Properties and configuration
  - Bottom panel: Execution status and logs
- [ ] **FLOW-008B**: Implement workflow management:
  - Workflow list with search and filtering
  - Create new workflow wizard
  - Workflow duplication and archiving
  - Bulk operations on workflows
- [ ] **FLOW-008C**: Add navigation and routing:
  - `/workflows` - Workflow list
  - `/workflows/:id` - Workflow editor
  - `/workflows/:id/executions` - Execution history
  - `/workflows/templates` - Template library
- [ ] **FLOW-008D**: Create responsive design:
  - Mobile-friendly interface
  - Touch interactions for tablets
  - Keyboard navigation support
  - Accessibility compliance
- [ ] **FLOW-008E**: Add integration points:
  - Global workflow trigger from other modules
  - Workflow status in dashboard
  - Workflow notifications in activity feed
  - Cross-module workflow templates
- [ ] **FLOW-008F**: **Tests**: Page layout, navigation, responsive design

### Definition of Done
- Complete workflow management interface
- Responsive design for all device types
- Integration with existing application modules
- Accessibility and keyboard navigation support

---

## 🧪 Task FLOW-009: Testing & Quality Assurance
**Priority:** 🔴 High | **Est. Effort:** 2 hours | **Depends On:** All FLOW tasks

### Related Files
- `src/tests/workflow/*.test.tsx` · `src/tests/workflow/integration.test.ts` · `vitest.config.ts`

### Subtasks

- [ ] **FLOW-009A**: Unit tests for all services:
  - WorkflowExecutor test suite
  - AgentManager test suite
  - EventBus test suite
  - Security validation tests
- [ ] **FLOW-009B**: Component tests:
  - Canvas rendering and interactions
  - Node palette functionality
  - Approval panel workflows
  - Template instantiation
- [ ] **FLOW-009C**: Integration tests:
  - End-to-end workflow execution
  - Human-in-the-loop scenarios
  - Multi-agent orchestration
  - Error handling and recovery
- [ ] **FLOW-009D**: Performance tests:
  - Large workflow rendering
  - Memory usage monitoring
  - Execution performance benchmarks
  - Concurrent execution limits
- [ ] **FLOW-009E**: Accessibility tests:
  - Screen reader compatibility
  - Keyboard navigation testing
  - Color contrast validation
  - ARIA compliance checking
- [ ] **FLOW-009F**: Security tests:
  - Input validation bypass attempts
  - Access control escalation testing
  - Data leakage prevention
  - Authentication bypass testing

### Definition of Done
- Comprehensive test coverage for all workflow functionality
- Performance benchmarks and optimization
- Full accessibility and security compliance
- Quality gates for production deployment

---

## 📊 Dependency Graph

```
FLOW-000 (Domain Model & Mock Data)
     │
FLOW-001 (Visual Canvas Engine)
     │
     ├── FLOW-002 (Agent Orchestration Engine)
     │
     ├── FLOW-003 (Human-in-the-Loop System)
     │
     ├── FLOW-004 (Templates & Patterns)
     │
     ├── FLOW-005 (Monitoring & Debugging)
     │
     ├── FLOW-006 (Version Control & Environments)
     │
     ├── FLOW-007 (Security & Compliance)
     │
     ├── FLOW-008 (Page Layout & Integration)
     │
     └── FLOW-009 (Testing & Quality Assurance)
```

---

## 🎯 Success Metrics

### User Experience
- **Workflow Creation Time**: < 5 minutes for basic automation
- **Canvas Performance**: < 100ms response for interactions with 100+ nodes
- **Execution Reliability**: > 99.5% successful completion rate
- **User Satisfaction**: > 4.5/5 rating for ease of use

### Technical Metrics
- **Code Coverage**: > 90% for all workflow modules
- **Bundle Size**: < 2MB for workflow module
- **Memory Usage**: < 100MB for large workflows
- **Execution Speed**: < 2 seconds for simple workflows

### Business Metrics
- **Workflow Adoption**: > 70% of users create at least one workflow
- **Automation Coverage**: > 60% of repetitive tasks automated
- **Error Reduction**: > 80% fewer manual errors
- **Productivity Gain**: > 3x improvement in task completion time
