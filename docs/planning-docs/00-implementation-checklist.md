# TODO.md

This TODO list provides detailed requirements for each strategic, initiation, requirements, and functional documentation artifact based on the comprehensive guides. Each task includes purpose, key content requirements, and usage context.

---

## Strategic & Initiation Documentation

Complete inventory of modern project artifacts

### Methodological Frameworks (Structuring Strategic Work)

- [ ] **PM² Programme Canvas** - Create collaborative tool from European Commission's PM² methodology for large, multi-project initiatives. Must include:
  - Programme objectives
  - Expected benefits
  - Strategic priorities
  - Stakeholder alignment
  - Risk coordination
  - Purpose: Ensure alignment on objectives and strategic priorities across related projects

- [ ] **Working Backwards Process** - Implement Amazon's product development framework that starts with desired customer outcome and reverse-engineers the path to achieve it. Must:
  - Define the end-state customer experience first
  - Work backward to determine requirements and implementation steps

### Core Strategy Artifacts (Defining Why & Where)

- [ ] **PR/FAQ (Press Release / Frequently Asked Questions)** - Write narrative document from customer's perspective imagining product is already launched. Must include:
  - One-page press release defining problem and solution
  - Customer FAQs
  - Internal FAQ addressing feasibility
  - Purpose: Align teams, evaluate ideas, ensure market viability before writing code

- [ ] **Lean Canvas** - Create Ash Maurya's one-page business template deconstructing idea into nine key assumptions. Must include all nine blocks:
  - Problem
  - Solution
  - Key Metrics
  - Unique Value Proposition
  - Unfair Advantage
  - Channels
  - Customer Segments
  - Cost Structure
  - Revenue Streams
  - Focus: Identifying and testing business model hypotheses

- [ ] **Value Proposition Canvas** - Create strategic tool aligning product features with customer needs. Must map:
  - **Customer Profile**: Jobs to be done, Pains, Gains
  - **Value Map**: Products & Services, Pain Relievers, Gain Creators
  - Used to validate problem-solution fit before detailed development

- [ ] **Opportunity Canvas** - Create concise one-page structured tool to evaluate new product features or initiatives. Must include:
  - Problem
  - Target Audience/Customers
  - Proposed Solution
  - Business Impact
  - Success Metrics
  - Potential Risks
  - Forces team alignment on specific problem and solution before committing resources

- [ ] **Strategic Initiative Alignment Canvas** - Create structured framework translating high-level strategic goals into specific, actionable initiatives. Must include:
  - Initiative name
  - Strategic goals supported
  - Key results
  - Required resources
  - Timeline
  - Stakeholders
  - Ensures projects are directly linked to business strategy

- [ ] **North Star Metric (NSM) Framework** - Document strategy identifying single core metric capturing essential value product delivers to customers. Must include:
  - Core metric (e.g., "daily active listeners")
  - Supporting leading indicators that drive the NSM
  - Clear statement of customer value captured
  - Serves as decision-making compass across all teams

- [ ] **Project Initiation Request** - Create proposal document with high-level overview. Must include:
  - Current situation (needs, problems, opportunities)
  - Desired outcomes
  - Initial estimates for effort, impact, risks, constraints, and assumptions

### Validation & Assumption Artifacts (Testing Ideas Before Building)

- [ ] **Riskiest Assumption Test (RAT)** - Document experiment to validate single most critical and uncertain assumption underlying project. Must include:
  - The single assumption to test
  - Defined hypothesis
  - Experiment design
  - Minimum success criteria
  - Learning log
  - Creates continuous improvement loop to pivot or proceed before significant development

- [ ] **Assumption Log** - Create document capturing all initial assumptions and constraints identified at project initiation. Must include for each:
  - Assumption ID
  - Description
  - Category (budget, schedule, tech)
  - Validation date
  - Status
  - Impact if false
  - Must be reviewed and updated regularly as unvalidated assumptions represent key risk factors

- [ ] **Hypothesis Template** - Create structured format for stating testable predictions linking solution to desired business outcome. Must use format:
  - "We believe that [doing this] will result in [this outcome]. We will know we are successful when we see [this signal]."
  - Used to frame experiments, features, or product backlog items, shifting from building "requirements" to validating hypotheses

### Decision & Governance Artifacts (Managing How Decisions Get Made)

- [ ] **Architectural Decision Record (ADR)** - Create append-only log documenting key architectural decisions. Must include for each:
  - Problem statement
  - Context
  - Considered alternatives
  - Chosen decision
  - Justification/trade-offs
  - Confidence level
  - Status (Proposed/Accepted/Superseded)
  - Preserves "why" behind system structure for future reviews

- [ ] **Decision Log (DACI Framework)** - Create record using DACI (Driver, Approver, Contributor, Informed) model to assign clear roles and accountability for strategic project decisions. Must include for each:
  - Decision itself
  - Driver
  - Approver(s)
  - Contributors
  - Informed parties
  - Due date
  - Status
  - Impact assessment
  - Prevents decision paralysis by specifying authority and input requirements

### Current Recommended Inventory Table

Implement comprehensive inventory organized by strategic purpose

- [ ] **Core Strategy category artifacts** - Create and maintain:
  - Product Vision Document (elevator pitch, target personas, key differentiators, success metrics OKRs/KPIs)
  - Project Charter (problem statement, high-level goals, scope, stakeholders, sponsor, authority level)
  - Business Case (cost-benefit analysis ROI/NPV, strategic alignment, alternative solutions, budgetary needs, expected outcomes)
  - North Star Metric Framework
  - Feasibility Study Report (tech stack assessment, resource availability, technical risks, regulatory compliance, TCO)
  - Project Initiation Request

- [ ] **Customer Alignment category artifacts** - Create and maintain:
  - PR/FAQ (fictional one-page press release, customer FAQs, internal FAQs on feasibility and strategy)
  - Lean Canvas (nine blocks as specified)
  - Value Proposition Canvas (Customer Profile mapped to Value Map)

- [ ] **Opportunity & Validation category artifacts** - Create and maintain:
  - Opportunity Canvas (Problem, Target Audience, Proposed Solution, Business Impact, Success Metrics, Potential Risks)
  - Strategic Initiative Alignment Canvas (initiative name, strategic goals, key results, resources, timeline, stakeholders)
  - Riskiest Assumption Test (assumption, hypothesis, experiment design, success criteria, learning log)
  - Hypothesis Template (structured "We believe" format)

- [ ] **Decision & Governance category artifacts** - Create and maintain:
  - Assumption Log (ID, description, category, validation date, status, impact)
  - Architectural Decision Record (problem, context, options, decision, justification, confidence, status)
  - Decision Log DACI (decision, Driver, Approver, Contributors, Informed, due date, status, impact)

- [ ] **Stakeholder & Context category artifacts** - Create and maintain:
  - Stakeholder Register (name, role, influence/interest level, expectations, communication preferences, engagement strategy)
  - Project Handbook/Team Charter (standards, roles, methodology, communication norms, meeting cadence, artifact list)
  - Glossary/Data Dictionary (term name, definition, data type, constraints, relationships, source)
  - PM² Programme Canvas (objectives, benefits, strategic priorities, stakeholder alignment, risk coordination)

### Modern Recommendations for Implementation

Implement strategic shift in documentation practice

- [ ] **Start with validation before heavy documentation** - In uncertain or early-stage projects, prioritize lightweight validation artifacts over detailed specifications. Begin by:
  - Documenting riskiest assumptions
  - Using Hypothesis Template to frame experiment
  - Using RAT as guide to pivot or proceed before significant investment

- [ ] **Use Narrative for Strategic Alignment** - For ideas involving multiple teams or significant investment, use PR/FAQ process to build alignment before writing code:
  - Fictional press release forces customer-centric thinking
  - FAQ anticipates tough internal questions to reduce later friction

- [ ] **Make documentation a decision dashboard, not a shelf** - Ensure every strategic artifact is living document linked to decision or test:
  - Store ADRs in code repository
  - Treat Assumption Log as to-validate list for product trio
  - Ensure North Star Metric framework is accessible not hidden

- [ ] **Contextualize artifact selection** - Tailor documentation suite to project context:
  - **Startup new product**: Focus on Lean Canvas as one-page business model, RATs as validation engine, Hypothesis Template for early experiments
  - **Established enterprise feature**: PR/FAQ for cross-functional alignment, ADRs for architectural choices, DACI log for governance

- [ ] **Include ethical and strategic oversight** - For initiatives with significant user impact, ensure Strategic Initiative Alignment Canvas includes field for:
  - Ethical considerations
  - Potential negative externalities

---

## Requirements & Functional Documentation (2025-2026)

Comprehensive inventory of modern requirements artifacts

### Business & High-Level Requirements Documentation

Capture project context, high-level functional needs, and operational rules

- [ ] **Business Requirements Document (BRD)** - Capture high-level business needs, objectives, and scope. Must include:
  - Business objectives
  - High-level functional scope
  - Key performance indicators (KPIs)
  - Business risks
  - Stakeholder needs
  - Represents the "voice of the business" and forms foundation for all subsequent requirements artifacts

- [ ] **Stakeholder Requirements Specification (StRS)** - Define needs of each stakeholder group. Must include for each stakeholder group:
  - Their explicit needs
  - Expectations
  - Constraints
  - Success criteria
  - Ensures all stakeholder perspectives are captured and addressed

- [ ] **Project Glossary / Data Dictionary** - Establish shared domain language and define key data entities. Must include:
  - Term or data entity name
  - Precise definition
  - Data type
  - Constraints
  - Relationships to other terms
  - The source system of record
  - Critical for communication clarity and data consistency

- [ ] **Business Rules Catalog** - Document policies, regulations, and logic software must enforce. Must include:
  - Rule ID
  - Clear description of rule/calculation
  - Its trigger (on event A or condition B)
  - Exception handling
  - Priority (Mandatory, High)
  - Ensures business logic is systematically captured and implemented

- [ ] **System Requirements Specification (SRS)** - Create detailed comprehensive description of system's intended capabilities. Modern evolution of classic SRS. Content must be:
  - Graded for project's risk level (low, medium, high)
  - Include: detailed functional requirements, system interfaces, and initial plan for non-functional requirements

- [ ] **Use Case Specification** - Describe goal-oriented interaction between actor and system to achieve outcome. Must include:
  - Use case name
  - Actors (primary/secondary)
  - Preconditions
  - Postconditions
  - Detailed flow of events (basic and alternative paths)
  - Should include use case model diagram providing visual overview of actors and related use cases

### Customer Journey & UX Requirements Documentation

Shift focus from system features to user experience and goals

- [ ] **User Persona** - Create detailed fictional profile of key user segment. Must include:
  - Demographics
  - Biography
  - Key goals
  - Frustrations
  - Behavioral traits
  - Context in which they will use the product
  - Critical for ensuring product-market fit and user-centered design

- [ ] **User Journey Map** - Visualize end-to-end experience of user accomplishing specific goal. Must include:
  - Persona-specific stages (from initial trigger to goal completion)
  - User actions
  - Thoughts
  - Emotional highs/lows
  - Key opportunities for improvement
  - Helps identify pain points and optimization opportunities

- [ ] **User Story Map** - Visually organize and prioritize user tasks along timeline of user's activities. Must include:
  - "Backbone" of high-level user activities mapped left-to-right
  - Detailed user stories as "cards" under each activity in rough priority order
  - Provides visible representation of backlog structure

- [ ] **Wireframes** - Create low-fidelity structural blueprints of user interface. Must include:
  - Page/screen layout
  - Hierarchy of information
  - Placement of key UI elements (buttons, forms, etc.)
  - Basic navigation paths
  - Excludes color, typography, and imagery
  - Focuses on structure and layout

- [ ] **Wireflows** - Map user's path across multiple screens or pages of digital product. Must include:
  - Series of low-fidelity wireframes with arrows and annotations
  - Depict user flows, branch logic, and decision points
  - Hybrid artifact combining wireframes with flow diagrams

- [ ] **(UX) Task Model** - Decompose user's high-level goal into goal, subgoals, and granular tasks needed to achieve them. Must include:
  - A goal
  - Set of related subgoals
  - Sequence of tasks and atomic operations user performs
  - Provides deep analytical view of user intent and work structure

### Agile & Behavior-Driven Development (BDD) Artifacts

Capture requirements in human-readable and executable format

- [ ] **Epic** - Represent large high-level body of work too big for single iteration. Must include:
  - Name
  - Clear summary of business value
  - Set of high-level acceptance criteria
  - Serves as container for related user stories

- [ ] **User Story** - Describe small valuable piece of functionality from end-user's perspective. Must:
  - Use format: "As a [type of user], I want [an action] so that [a benefit]."
  - Include clear Definition of Done
  - Include set of Acceptance Criteria
  - Fundamental unit of agile development

- [ ] **Job Story** - Capture user's motivation in specific context without assumptions about solution. Must:
  - Use format: "When [situation], I want [motivation], so I can [expected outcome]."
  - Focuses on "job to be done," ideal for innovative or new product development

- [ ] **Feature File (Gherkin)** - Provide executable specification of system's behavior as set of scenarios. Must include:
  - Feature keyword
  - User story or rationale
  - One or more Scenario or Scenario Outline blocks using Given-When-Then syntax
  - Serve as both documentation and automated test scripts

- [ ] **Acceptance Criteria** - Define specific testable conditions user story must satisfy to be accepted. Must:
  - Often be expressed in Scenario format using Given-When-Then syntax
  - Cover happy paths, edge cases, and error conditions

- [ ] **Acceptance Test-Driven Development (ATDD) Documentation** - Formalize collaborative practice of defining acceptance tests before development begins. Must document:
  - Team's approach and ground rules
  - How criteria are defined
  - How tests are written
  - How they are run
  - Makes acceptance tests definitive source of truth

- [ ] **Specification by Example Documentation** - Document collaborative practice of using concrete examples to discover and define requirements. Must include:
  - Repository of examples (tables, scenarios) that serve as both requirements and specifications
  - Guides development and automated testing

### Modeling, Contract-Based & Formal Documentation

Leverage visual models and formal logic for high-integrity systems

- [ ] **System/Software Architecture Model (SysML/UML)** - Create visual integrated model of system's requirements, structure, and behavior. Must include diagrams:
  - Requirement Diagrams (capture and relate text-based requirements)
  - Use Case Diagrams
  - Sequence Diagrams
  - Block Definition Diagrams (for structure)
  - Activity Diagrams (for behavior)

- [ ] **Requirement Table (SysML)** - Provide spreadsheet-like view for managing and editing text-based requirements within model. Must include:
  - Sortable filterable table listing requirement IDs, names, text, and relationships
  - More practical interface for viewing and maintaining requirements from large model

- [ ] **Component Contract (Assume/Guarantee)** - Formally define component's obligations and dependencies on system's environment. Must include:
  - Assume guarantee contract detailing what component assumes about environment's state
  - What it guarantees to provide
  - Allows formal verification of composition

- [ ] **Requirements Traceability Matrix (RTM)** - Map links between requirements and downstream artifacts (design, code, tests). Must include:
  - Table or automated traceability tool linking Requirement IDs to Design Specifications, Code Modules, Test Cases, and Risk Assessments
  - Critical for compliance and change management

- [ ] **Suspect Link Management** - Identify and manage links between artifacts that become outdated or invalid due to changes. Must include:
  - Automated process within modeling tool that flags links (satisfies or verifies) as "suspect" when one side is updated
  - Triggers manual review and possible repair

### Specialized & Regulatory Documentation

Address requirements in high-risk domains like compliance, AI, and safety

- [ ] **EU AI Act Technical Documentation & Risk Management** - Fulfill mandatory documentation for high-risk AI systems (effective August 2026). Must include extensive set of documents:
  - Detailed description of AI system's development, design, data governance, risk assessment, and post-market monitoring
  - Must comply with Articles 9-15 and Annex IV

- [ ] **Safety Requirements Specification** - Derive specific verifiable safety requirements from system's hazard analysis. Must include:
  - Requirements categorized by Safety Integrity Level (SIL) or ASIL
  - Detailing required safety functions, safe states, and fault detection/handling mechanisms
  - Critical for safety-critical systems

- [ ] **Verification & Validation (V&V) Plan** - Outline overall strategy and activities to ensure software meets requirements and is fit for intended use. Must define:
  - Scope, approach, resources, and schedule for all V&V activities
  - Plans for unit, integration, system, and acceptance testing

### AI-Augmented & Agile Requirements Engineering Artifacts

Support requirements management using LLMs and GenAI

- [ ] **AI-Assisted Requirements List** - Generate broad structured initial list of functional requirements from unstructured text (meeting notes, BRDs). Must:
  - Use method orchestrating multiple complementary LLMs in iterative loops
  - Output raw comprehensive list of candidate requirements serving as high-quality starting point for business analyst

- [ ] **GenAI-Driven SDLC Documentation Pipeline** - Automate production of downstream artifacts (user stories, test cases, automated scripts) directly from BRD to ensure consistent traceability. Process:
  - Input BRD into AI-powered system
  - Generates: Standardized User Stories with acceptance criteria, Test Cases, and Executable Cucumber and Selenium scripts
  - Result: 100% traceable chain from business need to automated test

- [ ] **Quality-Checked Requirements** - Use LLM to assess and improve quality of requirements set. Must include:
  - Custom software tool taking natural language requirements
  - Reformulating them for clarity and consistency
  - Assessing against predefined quality criteria (atomicity, completeness, verifiability)

- [ ] **Human-AI Collaboration (HAIC) Framework** - Document specific processes and guidelines for how team will use AI tools on project. Must include plan detailing:
  - Which RE phases will use AI (elicitation, classification)
  - How much automation is involved (AI validation, HAIC)
  - Governance model for reviewing and accepting AI-generated content

### How to Choose and Apply Documentation

Implement guidelines for building tailored documentation strategy

- [ ] **Map artifacts to workflow** - Don't treat as checklist:
  - Start with high-level Business Requirements to define project value
  - Use User Journey Maps to understand user needs before detailing specific User Stories
  - Bridge gap with User Story Maps for holistic backlog planning

- [ ] **Embrace traceability** - For every requirement, ensure:
  - Trace back to business goal
  - Trace forward to test
  - Use Traceability Matrix or dedicated tool
  - When using AI, GenAI-Driven SDLC Documentation Pipeline artifact is powerful mechanism for establishing and guaranteeing traceability

- [ ] **Tier documentation by risk** - Level of detail should be proportional to risk. Use SRS to extend Business Requirements, but grade content:
  - **Low-Risk Features**: SRS may only need user story and acceptance criteria
  - **Medium-Risk Features**: Add non-functional requirements
  - **High-Risk/Regulated Features**: Incorporate full detailed SRS with formal language and traceability to safety standards

- [ ] **Align artifacts with AI strategy** - Formalize Human-AI Collaboration (HAIC) Framework to define how generative AI will produce, refine, or check requirements artifacts:
  - AI-Assisted Requirements List can generate initial draft from PR/FAQ
  - Becomes basis for stakeholder review
  - Creates faster elicitation process

---

## Technical Design & Architecture Documentation

Comprehensive inventory covering standards, C4 architecture, ADRs, API contracts, and modern architecture-as-code

### Standards-Based Architecture Frameworks

- [ ] **arc42 Architecture Documentation** - Provide complete, ISO-compliant template for software architecture documentation in both agile and traditional projects
- [ ] **ISO/IEC/IEEE 42010 Documentation Set** - Document a system's architecture in accordance with the international standard for architecture description

### Technology Stack & Quality Attribute Documentation

- [ ] **Technology Stack Specification** - Formally document programming languages, frameworks, libraries, databases, and infrastructure components selected for the project
- [ ] **Quality Attribute Scenario (QAS) Specification** - Quantify non-functional requirements as testable scenarios
- [ ] **Architectural Pattern Decision Record** - Capture rationale for selecting high-level architectural pattern

### Hierarchical Architecture Views (C4 + Deployment)

- [ ] **System Context Diagram (L1)** - Shows software system as central box surrounded by users and other systems
- [ ] **Container Diagram (L2)** - Zooms into system showing high-level technology building blocks
- [ ] **Component Diagram (L3)** - Decomposes single container into internal structural components
- [ ] **Code Diagram (L4)** - Zooms into single component showing UML class diagrams or database schemas
- [ ] **Deployment Diagram** - Extends C4 model showing how containers map to infrastructure

### Architecture Decision Management

- [ ] **Architectural Decision Record (ADR)** - Capture single significant architecture decision including context, alternatives, and consequences
- [ ] **Architectural Decision Log (ADL)** - Act as registry of all ADRs serving as historical record
- [ ] **ADR Metadata & Traceability** - Provide governance hooks linking decisions to design reviews and pull requests

### API Contract & Specification Documentation

- [ ] **OpenAPI Specification (REST APIs)** - Provide machine-readable contract for HTTP APIs
- [ ] **AsyncAPI Specification (Event-driven APIs)** - Document asynchronous, message-driven APIs
- [ ] **API Versioning & Change Management Plan** - Define policies for API versioning and breaking changes
- [ ] **Generated API Documentation (Redoc, Swagger UI)** - Provide live, interactive documentation from contracts

### Implementation-Level Design Documentation

- [ ] **Low-Level Design Document (LLD)** - Provide detailed technical specifications for implementing module, component, or microservice
- [ ] **Database Design Document** - Document logical and physical schema for persistent storage
- [ ] **Sequence Diagrams** - Visualize interaction flow between components for specific use case
- [ ] **State Diagrams** - Model lifecycle of business entity with finite states and transition events

### Infrastructure & Deployment Documentation

- [ ] **Infrastructure as Code (IaC) Templates** - Express infrastructure as declarative code enabling version control
- [ ] **Deployment Topology Map** - Visualize physical arrangement of software containers on infrastructure
- [ ] **Security Architecture Diagram** - Document security controls, threat boundaries, and compliance measures

### Quality & Cross-Cutting Specifications

- [ ] **Quality Assurance & Testing Strategy** - Document overall approach to verifying system meets requirements
- [ ] **Cross-Cutting Concepts Specification** - Document technical concerns applying system-wide

### Modern & Emerging Architecture Artifacts

- [ ] **Architecture as Code Artifacts** - Write architecture diagrams and specifications in plain text files stored in version control
- [ ] **Platform Engineering Artifacts** - Document internal development platform (IDP) with curated tools and services
- [ ] **Green Software Architecture Specification** - Document architectural decisions minimizing energy consumption and carbon footprint
- [ ] **AI-Generated Architecture Documentation** - Use LLMs to automatically extract and generate system-level architecture documentation
- [ ] **AI-Assisted Architecture Decision Records** - Augment ADR creation using LLMs to generate alternatives and evaluate trade-offs

### Governance & Collaboration Artifacts

- [ ] **Architecture Design Review Record** - Document output of formal or informal architecture review sessions
- [ ] **Architecture Technical Debt Register** - Track architectural shortcuts and incomplete implementations
- [ ] **Architecture & Design Wiki / Knowledge Base** - Provide centralized searchable repository for all architecture documentation
- [ ] **Architecture Decision Framework** - Document process for when and how architecture decisions get made

---

## Project Management & Process Documentation

Comprehensive inventory of over 40 artifacts organized into logical categories

### Foundational Standards & Core Management Plans

- [ ] **Project Management Plan (PMP)** - Master document defining how project is executed, monitored, and controlled
- [ ] **Software Development Plan (SDP)** - Details technical execution strategy including lifecycle, environment, tools, and standards
- [ ] **Project Assessment & Control Plan** - Component of PMP defining metrics, measurement, and control processes
- [ ] **Management Plans (Subsidiary Plans)** - Set of detailed interconnected plans covering key knowledge areas
- [ ] **Configuration Management Plan** - Defines how changes to project artifacts and product baseline are managed
- [ ] **Measurement Plan** - Defines data to be collected and analyzed to inform decision-making
- [ ] **Information Management Plan** - Defines how project information is created, stored, shared, and archived
- [ ] **Quality Assurance Plan** - Details activities to verify project processes and deliverables meet requirements
- [ ] **Communications Management Plan** - Formalizes stakeholder information needs

### Modern Planning & Coordination Artifacts

- [ ] **Project Initiation Request (PIR)** - Proposal document for new project, often used as gatekeeper to intake
- [ ] **Project Brief** - Outlines "what," "why," and "who" for project as high-level foundation
- [ ] **Project Roadmap** - High-level timeline-based visual of project's major milestones, deliverables, and dependencies
- [ ] **Work Breakdown Structure (WBS)** - Hierarchical decomposition of total project scope into manageable work packages
- [ ] **Team Charter / Working Agreement** - Document drafted by team defining its own norms, values, and operational rules
- [ ] **Responsibility Assignment Matrix (RACI)** - Clarifies roles and responsibilities for deliverables or activities
- [ ] **Methodology-to-Artifacts Map** - Reference document mapping chosen methodology to artifacts it produces
- [ ] **Decision Log (DACI Framework)** - Records key project decisions using DACI model

### Agile & Lean Delivery Artifacts

- [ ] **Product Backlog** - Emergent, ordered list of everything needed in the product
- [ ] **Sprint Backlog** - Set of Product Backlog items selected for current Sprint plus plan for delivering them
- [ ] **Definition of Ready (DoR)** - Checklist ensuring backlog item is ready to be taken into Sprint
- [ ] **Definition of Done (DoD)** - Checklist defining quality criteria backlog item must meet to be considered complete
- [ ] **Kanban Board** - Visual workflow management tool to track work in progress and identify bottlenecks
- [ ] **Value Stream Map (VSM)** - Lean tool visualizing end-to-end process from request to delivery to identify waste

### Risk & Performance Management Artifacts

- [ ] **Risk Register** - Living document for identifying, assessing, and tracking risks and opportunities
- [ ] **Quality Register / Defect Log** - Tracks all reported defects or quality issues, their severity, and resolution path
- [ ] **Issue Log** - Documents any significant problem or point of conflict affecting the project
- [ ] **Status Report** - Regular summary of project health, progress, and upcoming work
- [ ] **Dashboard (Live)** - Real-time visual representation of key project metrics

### Change, Procurement & Formal Documentation

- [ ] **Change Request / Change Log** - Formal proposal to modify any formally controlled baseline
- [ ] **Procurement Plan** - Manages acquisition of products or services from outside project team
- [ ] **Formal Agreement (Contract / MOU / SLA)** - Legally binding or formal document outlining terms of engagement

### Phase / Stage Gate Review Artifacts

- [ ] **Business Case** - Justifies the project and is validated at stage gates
- [ ] **Stage Plan** - Detailed plan for next stage of project (common in PRINCE2)
- [ ] **Highlight Report** - Regular progress report from Project Manager to Project Board
- [ ] **End Stage Report** - Review at end of management stage to summarize performance
- [ ] **End Project Report** - Final review of project comparing actual outcomes against planned objectives

### Lessons & Closure Artifacts

- [ ] **Lessons Learned Register** - Repository of insights captured throughout project
- [ ] **Retrospective Notes** - Record of regular facilitated discussion focused on team process improvement
- [ ] **Follow-On Actions Recommendations** - Document from closure process recommending actions for ongoing operations
- [ ] **Post-Project Analysis Report** - Formal analysis of overall project performance for future reference

### Scale-Specific Artifacts (Program & Portfolio)

- [ ] **Agile Release Train (ART) Backlog** - Prioritized list of features and enablers for SAFe Agile Release Train
- [ ] **Value Stream Map (Portfolio-Level VSM)** - High-level end-to-end map of value delivery system across multiple projects
- [ ] **PI (Program Increment) Objectives** - Set of SMART objectives for teams in ART for next PI
- [ ] **PI Planning Readiness Checklist** - Tool to verify necessary preconditions for successful PI Planning event
- [ ] **Program / Portfolio Dashboard** - High-level executive dashboard summarizing health and progress of multiple projects
- [ ] **Enterprise Architecture Maturity Assessment** - Document to baseline current state and set targets for enterprise architecture

### AI-Augmented Project Management Artifacts

- [ ] **AI-Assisted Project Initiation Artifacts (MAPS-AI)** - Tool prototype generating Project Plans and Scope Documents
- [ ] **AI-Generated Document Summaries & Drafts** - AI agents prepare clear and structured work from initial drafts
- [ ] **AI-Generated Architecture Artifacts (TOGAF ADM)** - AI support generating common artifacts for each phase
- [ ] **AI-Enhanced Dashboards** - Automated executive summaries, real-time project health scores, and risk signals
- [ ] **Human-AI Collaboration (HAIC) Framework** - Documented plan defining how AI tools will be used on project

### Green & Sustainable Project Management Artifacts

- [ ] **Sustainability Management Plan** - Documents project's strategy to minimize environmental footprint
- [ ] **Sustainability Impact Assessment** - Evaluates potential environmental impacts of project before it begins
- [ ] **ESG (Environmental, Social, Governance) Report** - Report documenting project's performance on sustainability metrics
- [ ] **Carbon Accounting Data** - Operational data captured and analyzed to inform project sustainability

### Living Documentation & Knowledge Artifacts

- [ ] **Living Design Documents** - Three interconnected documents evolving with project to maintain traceability
- [ ] **Repository-First Documentation** - Structured workflow where all documentation stored in code repository
- [ ] **Living Knowledge Graph** - Emergent model linking project data sources into unified searchable network

### Governance, Certification & Methodology-Specific Artifacts

- [ ] **PRINCE2 7** - Project Brief, Business Case, Project Initiation Document, Highlight Report, End Stage Report, End Project Report
- [ ] **Scaled Agile Framework (SAFe)** - Agile Release Train Backlog, Program Backlog, Features, Enablers, PI Objectives, Roadmap
- [ ] **Lean Portfolio Management (LPM)** - Value Streams, Portfolio Backlog, Epic, Lean Budgets, Guardrail documents
- [ ] **PRINCE2 & SAFe Alignment** - SAFe provides "how" for delivery and PRINCE2 provides "why" and governance framework

---

## Agile & Iteration Planning Artifacts

Updated inventory reflecting latest industry practices and emerging trends

### Core & Canonical Artifacts (Scrum Guide)

- [ ] **Product Backlog** - Emergent, ordered list of everything needed in product as single source of truth
- [ ] **Sprint Backlog** - Set of Product Backlog items selected for current Sprint plus plan for delivering Sprint Goal
- [ ] **Increment** - Sum of all completed Product Backlog items from past Sprints representing fully integrated usable product
- [ ] **Definition of Done (DoD)** - Shared explicit checklist of quality criteria backlog item must meet to be considered complete
- [ ] **Sprint Goal** - Short coherent statement of what team plans to achieve during Sprint providing flexibility and focus

### Planning & Prioritization Artifacts

- [ ] **User Story** - Small valuable piece of functionality expressed from end-user's perspective forming smallest unit of work
- [ ] **Epic** - Large high-level body of work too big for single Sprint broken down into smaller user stories
- [ ] **Story Map** - Two-dimensional graphical visualization of Product Backlog organizing user stories along user's journey
- [ ] **OKR (Objectives and Key Results) Integration** - Strategic alignment artifact connecting quarterly business objectives to measurable key results
- [ ] **Discovery Backlog** - Separate backlog for exploration and validation work supporting Dual-Track Agile
- [ ] **Impact Map** - Strategic planning artifact visualizing path from business goals to specific deliverables
- [ ] **Work Items List** - Captures all scheduled work to be done within project including proposed work affecting product

### Continuous Discovery & Refinement Artifacts

- [ ] **Definition of Ready (DoR)** - Shared checklist ensuring Product Backlog item is sufficiently understood and prepared
- [ ] **Backlog Refinement (Grooming) Output** - Result of continuous process where Product Owner and team review, estimate, and re-prioritize items
- [ ] **Upstream Kanban System for Refinement** - Visual workflow for managing backlog items as they move through stages of refinement
- [ ] **Sprint Readiness Check** - Brief pre-Sprint meeting or checklist ensuring top items on Product Backlog meet DoR
- [ ] **Spike Story** - Time-boxed research or exploration story designed to reduce uncertainty on technical or functional problem

### Execution & Flow Artifacts (Kanban-Centric)

- [ ] **Kanban Board** - Visual workflow management tool designed to track work in progress and identify bottlenecks
- [ ] **Kanban Backlog (Continuous vs. Release-Bound)** - Prioritization and visualization list managed per release or continuously
- [ ] **Cumulative Flow Diagram (CFD)** - Analytical chart visualizing number of work items in each state of Kanban board over time
- [ ] **Policy Explicit Artifact** - Documented set of explicit rules governing how Kanban system operates
- [ ] **Kanplan Backlog** - Hybrid artifact combining Kanban's continuous flow with Scrum's backlog grooming practices

### Scaling Frameworks Artifacts

- [ ] **Large Scale Scrum (LeSS)** - Applies principles of Scrum at scale maintaining single Product Backlog and Product Owner
- [ ] **Nexus Framework (Scrum.org)** - Extends Scrum's artifacts to coordinate 3-9 Scrum teams working on single product
- [ ] **Scaled Agile Framework (SAFe)** - Provides structured artifacts for Lean-Agile development at portfolio, program, and team levels

### AI-Augmented & Automated Artifacts (2025-2026)

- [ ] **AI-Generated Draft Acceptance Criteria** - Automated generation of acceptance criteria for user stories
- [ ] **AI-Powered Backlog Grooming Output** - NLP and ML-powered framework automatically evaluating and prioritizing backlog items
- [ ] **AI-Assisted Sprint Planning (Jira Rovo, Integrations)** - AI assistant embedded in tools providing instant AI-powered answers
- [ ] **Automated Sprint Analysis & Retrospective Generator** - AI-driven processing of sprint metrics to produce retrospective discussion points
- [ ] **Agentic AI Workflow Assistant** - Intelligent agent integrated into workflow tools predicting outcomes and identifying blockers
- [ ] **Human-AI Collaboration (HAIC) Framework for Agile** - Documented plan defining how AI tools will be used in each Agile ceremony

### Hybrid & Emerging Methodologies Artifacts

- [ ] **Scrumban Board** - Hybrid artifact combining Scrum's structured Sprint cadence with Kanban's continuous flow
- [ ] **Mixed Scrum-Kanban Workflow** - Workflow where Sprint Backlog items managed with pull system allowing flexibility within Sprint
- [ ] **Agile Portfolio Wall** - Large-format visualization showing all active epics, features, and status across portfolio
- [ ] **Lean Governance Artifact** - Documented framework providing "just enough" oversight to enable value flow
- [ ] **Hybrid Delivery Approach Documentation (PMBOK 7)** - Plan blending predictive high-level planning with adaptive execution

---

## Communication & Collaboration Artifacts

Comprehensive inventory organized into functional categories

### Foundational Collaboration Infrastructure Artifacts

- [ ] **Team Charter** - Living document co-created by team defining purpose, values, responsibilities, and ways of working
- [ ] **Working Agreement / Team Social Contract** - Explicit collaboratively created standards defining how team members work together
- [ ] **Team Communication Plan / Communication Matrix** - Structured framework mapping who needs what information, when, and via which channel
- [ ] **Communication Cadence Schedule** - Pre-defined calendar of recurring touchpoints for team updates and stakeholder reports

### Meeting & Ceremony Documentation (Agile & General)

- [ ] **Sprint Planning Template** - Structured agenda for selecting and committing to work for upcoming sprint
- [ ] **Daily Standup / Daily Scrum Template** - Concise time-boxed coordination format (15 minutes max)
- [ ] **Sprint Review Template** - Guide for demonstrating completed work to stakeholders and collecting feedback
- [ ] **Sprint Retrospective Template** - Framework for reflecting on past sprint and identifying actionable improvements
- [ ] **Backlog Refinement Template** - Structured session for grooming and prioritizing product backlog
- [ ] **Ritual Inventory / Ceremony Checklist** - Simple inventory of all team rituals helping identify friction points
- [ ] **Meeting Agenda Template** - Pre-configured agenda structure applicable to any meeting type
- [ ] **Meeting Minutes / Decision Record** - Structured capture of meeting discussions, decisions, and action items

### Asynchronous Collaboration Artifacts

- [ ] **Async Standup Template** - Distributed daily coordination posted in shared channel enabling work across time zones
- [ ] **Async Demo / Showcase Template** - Pre-recorded demonstration of completed work for asynchronous consumption
- [ ] **Async Decision-Making Workflow** - Structured process for making team decisions without synchronous meetings
- [ ] **Async Design Review / RFC Template** - Structured format for submitting design proposals for asynchronous review
- [ ] **Time Zone Fairness Schedule** - Rotating meeting times or facilitation schedule to share burden across time zones
- [ ] **Pull Request / Code Review Expectations** - Explicit guidelines for PR review turnaround times and quality standards

### Decision Management & Structured Choice Artifacts

- [ ] **Structured Decision Record** - Formal documentation of team decision including context, options, evaluation criteria, and outcome
- [ ] **Decision Matrix / Weighted Criteria Table** - Quantitative tool for comparing multiple options against weighted evaluation criteria
- [ ] **RACI / DACI Decision Register** - Documentation of decision roles using RACI or DACI framework
- [ ] **Decision Traceability Log** - Index or log of all significant team decisions enabling easy retrieval

### Remote & Distributed Team-Specific Artifacts

- [ ] **Remote Team Ops Playbook** - Comprehensive guide for how distributed team operates day-to-day
- [ ] **Inter-Team Agreement (ITA)** - Structured framework to design, analyze, and improve interactions between teams
- [ ] **Team API / Team Interface Document** - Formal specification of what other teams can expect from this team
- [ ] **Team Launch Canvas / Onboarding Document** - One-page framework capturing essential team information for new member onboarding
- [ ] **Handoff Checklist / Service Level Expectation (SLE)** - Explicit documentation of handoff points between teams or roles

### Knowledge Transfer & Documentation Artifacts

- [ ] **Living Documentation Repository** - Centralized version-controlled knowledge base that evolves with project
- [ ] **Knowledge Transfer / Onboarding Suite** - Curated set of documents accelerating new team members' integration
- [ ] **Standard Operating Procedure (SOP) Library** - Collection of documented procedures for recurring tasks
- [ ] **Video-to-Documentation Conversion Artifact** - Automated documentation generated from recorded walkthroughs
- [ ] **Knowledge Graph / Searchable Repository** - AI-powered unified knowledge base ingesting and organizing documents

### AI-Augmented Communication Artifacts

- [ ] **AI-Summarized Meeting Output** - Automated meeting minutes generated from transcripts
- [ ] **AI-Transcribed Meeting Repository** - Searchable archive of AI-generated meeting transcripts and summaries
- [ ] **AI Action Item Auto-Creation Artifact** - Automated creation of tickets, tasks, and action items from meeting transcripts
- [ ] **AI Decision Extractor Output** - Automated identification and capture of decisions made during meetings
- [ ] **Meeting Bot Orchestration Policy** - Documented policy governing when and how AI meeting bots join calls
- [ ] **HAIC (Human-AI Collaboration) Framework for Communication** - Documented guidelines defining how AI will be used

### Continuous Improvement & Retrospective Artifacts

- [ ] **Ritual Inventory Review Log** - Documentation of scheduled reviews of team's ritual inventory
- [ ] **Ritual Refresh / Ceremony Tuning Log** - Record of adjustments made to team ceremonies based on retrospective learnings
- [ ] **Team Health Check Artifact** - Periodic assessment of team collaboration health using standardized metrics
- [ ] **Action Item Tracking Dashboard** - Visual tracker for retrospective action items visible to whole team

### Accessibility & Inclusivity Artifacts

- [ ] **Accessibility Checklist for Team Artifacts** - Standards ensuring all team outputs are accessible to all team members
- [ ] **Inclusive Communication Guidelines** - Explicit norms for language and interaction creating psychological safety

### Minimalist & Lean Documentation Artifacts

- [ ] **LeanSpec Workflow** - Adaptive living specification workflow embracing agile thinking
- [ ] **Minimal Viable Documentation (MVD) Standard** - Documented standard for "just enough" documentation
- [ ] **Documentation-As-Code Artifact** - Documentation stored alongside code in version control
- [ ] **Cross-Functional Project Canvas** - One-page visual management tool giving all team members clear communication framework

---

## Risk & Compliance Documentation

Comprehensive inventory integrating new artifacts and updated frameworks

### Core Risk Management Artifacts (ISO 31000 & NIST SSDF)

- [ ] **ISO 31000 Implementation Guide for Technology** - Translate ISO 31000 principles into technology-specific actionable risk management
- [ ] **Risk Management Plan (RMP)** - Define how team will identify, assess, respond to, monitor, and report risks throughout project
- [ ] **Risk Register** - Capture and track all identified risks, their assessment, mitigation actions, owners, and status
- [ ] **Structured Risk Assessment Document** - Apply systematic codified methodology for identification, quantification, and prioritization of risks
- [ ] **Risk Treatment & Monitoring Plan** - Document how each identified risk will be avoided, mitigated, transferred, or accepted

### AI & Model Governance Documentation

- [ ] **NIST AI RMF Documentation Profile** - Implement NIST's structured operational AI risk management process
- [ ] **EU AI Act Risk Management System Documentation (Article 9)** - Fulfill comprehensive risk management system requirements for high-risk AI
- [ ] **EU AI Act Technical File (Annex IV)** - Comprehensive technical documentation set for high-risk AI systems
- [ ] **AI Incident Response Plan** - Define processes for detecting, responding to, and recovering from AI-specific incidents
- [ ] **AI Model Transparency & Performance Log** - Document all AI models' behavior and performance metrics for auditing
- [ ] **Foundation Model Risk Profile (GPAI)** - Specialized risk management profile for General-Purpose AI and foundation models
- [ ] **Accountability & Governance Framework for AI** - Establish clear ownership, accountability, and governance structures for AI systems

### Privacy & Data Protection Documentation (GDPR, CPRA)

- [ ] **Data Protection Impact Assessment (DPIA)** - Identify and mitigate privacy risks arising from data processing activities
- [ ] **Record of Processing Activities (RoPA)** - Document all personal data processing activities to satisfy GDPR accountability
- [ ] **Privacy by Design Technical Specification** - Translate GDPR Article 25 and CCPA/CPRA requirements into implemented technical controls
- [ ] **Cross-Jurisdictional Privacy Compliance Plan** - Align GDPR and CPRA requirements for organizations handling both EU and California data
- [ ] **Data Subject Rights Automation Record** - Document automated systems for handling privacy rights requests
- [ ] **Software Supply Chain Privacy Assessment** - Evaluate privacy risks introduced by third-party SDKs, libraries, or SaaS components

### Cybersecurity & Compliance Frameworks

- [ ] **Unified Compliance Control Mapping** - Map security controls from single framework to multiple regulatory standards
- [ ] **NIST CSF 2.0 Cybersecurity Program Documentation** - Implement latest NIST Cybersecurity Framework with expanded six-function structure
- [ ] **EU Cyber Resilience Act (CRA) Technical File** - Mandatory cybersecurity documentation for products with digital elements sold in EU
- [ ] **FedRAMP Security Package** - Comprehensive documentation for U.S. federal cloud service authorization
- [ ] **SOC 2 / ISO 27001 Assurance Package** - Documentation for service organization controls and information security management system
- [ ] **Cybersecurity Supply Chain Risk Management (C-SCRM) Plan** - Address risks from third-party components, suppliers, and integration partners

### Digital Operational Resilience Documentation (DORA)

- [ ] **DORA Register of Information (Article 28)** - Mandatory comprehensive register documenting all contractual arrangements with ICT third-party service providers
- [ ] **ICT Risk Management Framework (DORA Pillar 1)** - Internal governance and control framework for ICT risk management within financial entities
- [ ] **Resilience Testing Plan (DORA Pillar 4)** - Document entity's approach to testing digital operational resilience
- [ ] **Third-Party Risk Oversight Plan (DORA Pillar 3)** - Document due diligence, contractual controls, and ongoing monitoring for ICT third-party service providers

### SBOM & Software Supply Chain Transparency

- [ ] **Software Bill of Materials (SBOM)** - Machine-processable inventory of software components, dependencies, and licensing
- [ ] **SBOM Generation & Verification Record** - Document automated process and tools used to generate SBOM
- [ ] **Third-Party Component Risk Assessment** - Evaluate security, licensing, and maintenance risks associated with third-party software components
- [ ] **Vulnerability Management & Patching Plan** - Document how known vulnerabilities in third-party components will be tracked, prioritized, and addressed

### Environmental & Green Software Documentation

- [ ] **Sustainability Requirements Specification (ISO/IEC TS 20125-1)** - Capture environmental requirements as explicit measurable constraints
- [ ] **Carbon-Aware Deployment Plan** - Specify how deployment scheduling and resource allocation optimized for carbon efficiency
- [ ] **Green Software Pattern Application Record** - Document which green patterns from GSF catalog applied and measured emissions reduction
- [ ] **Energy Telemetry & Carbon Emissions Data** - Quantified measurement data from energy monitoring tools
- [ ] **Sustainability Impact Assessment (CSRD / ESRS)** - Mandatory assessment for organizations subject to CSRD reporting obligations
- [ ] **ESRS Compliance Checklist / Tool Output** - Structured checklist meeting European Sustainability Reporting Standards
- [ ] **Green Software Maturity Matrix Assessment (GSF)** - Document current and target maturity levels across sustainable software lifecycle

### Emerging Compliance & Regulatory Artifacts

- [ ] **PCI DSS Compliance Documentation** - Document security controls and evidence for payment card industry compliance
- [ ] **HIPAA Security Rule Documentation** - Document administrative, physical, and technical safeguards for ePHI
- [ ] **BSI TR-03183-2 SBOM Compliance Record** - Evidence of compliance with German Federal Office for Information Security SBOM requirements
- [ ] **Cert-In SBOM & AIBOM Compliance Report** - Documentation satisfying Indian CERT-In guidelines for SBOM, Q(BOM), C(BOM), AIBOM, and H(BOM)
- [ ] **StateRAMP / Texas DIR Authorization Package** - State-level cloud service authorization for government contracts

### Automation & AI-Powered Risk Artifacts

- [ ] **AI-Assisted Risk Register Generator** - Document use of LLMs to generate initial risk registers from project documentation
- [ ] **Automated Compliance Evidence Collection Log** - Automate collection and validation of compliance evidence from CI/CD pipelines
- [ ] **NLP-Based Risk from Requirements Report** - Use natural language processing to automatically extract risk information from requirements
- [ ] **Continuous Control Monitoring Dashboard** - Real-time visualization of control compliance across multiple frameworks

### Cross-Cutting & Governance Artifacts

- [ ] **Compliance Traceability Matrix** - Map compliance requirements to implemented controls, test cases, and evidence artifacts
- [ ] **Responsible AI & Digital Ethics Statement** - Document organization's principles and commitments for ethical AI development
- [ ] **Third-Party & Open Source Risk Management Plan** - Document processes for evaluating and managing risks from external code
- [ ] **Compliance Audit Readiness Pack** - Curated package of evidence, reports, and documentation prepared for periodic audits

---

## Platform Engineering & Modern Operational Documentation

Comprehensive inventory defining, managing, and operating Internal Developer Platform

### Platform Strategy & Product Management Artifacts

- [ ] **Platform Charter** - Formally authorize platform initiative and define its mandate
- [ ] **Platform-as-a-Product Vision Document** - Articulate long-term product goal for internal developer platform
- [ ] **Internal Developer Platform (IDP) Definition** - Curated set of self-service capabilities built on top of underlying infrastructure
- [ ] **Platform Engagement & Adoption Plan** - Document how developer teams will be onboarded, supported, and measured on platform
- [ ] **Platform Technical Debt Register** - Track architectural shortcuts, incomplete capabilities, and known deviations from planned platform

### Platform Architecture & Foundational Artifacts

- [ ] **Platform Architecture Blueprint** - High-level design of IDP showing how it orchestrates underlying infrastructure
- [ ] **Platform Reference Architecture** - Pre-architected reusable infrastructure pattern standardizing and accelerating cloud development
- [ ] **Platform API Contract (Kratix Promise / Crossplane Composition)** - Formal machine-readable definition of self-service capability offered by platform
- [ ] **Platform Architecture Decision Records (ADR)** - Document "why" behind significant platform architecture choices

### Core IDP Components Artifacts

- [ ] **Service Catalog Definition (Backstage Software Catalog)** - Registry of every service, library, API, and resource in organization
- [ ] **Software Template Definition (Scaffolder)** - Self-service scaffolding for creating new projects with standardized secure workflows
- [ ] **TechDocs Artifact (docs-as-code)** - Documentation generator rendering technical documentation inside developer portal
- [ ] **Backstage Plugin Configuration & Customization Record** - Document which Backstage plugins installed, configured, and custom plugins developed
- [ ] **IDP Extensibility & Integration Map** - Map how IDP connects to CI/CD pipelines, IaC engines, cloud APIs, security scanners

### Golden Paths, Guardrails & Governance Artifacts

- [ ] **Golden Path Template** - Pre-configured paved road providing end-to-end workflow for developers
- [ ] **Guardrails Documentation** - Non-negotiable rules enforced by platform often implemented as Policy as Code
- [ ] **Safety Nets Specification** - Automated recovery and rollback policies protecting production environments
- [ ] **Platform Service Level Objectives (SLOs) & Metrics** - Quantitative targets platform provides to its users treating platform as product

### Cloud Infrastructure & IaC Artifacts

- [ ] **Infrastructure as Code (IaC) Module Specification (Azure Verified Modules)** - Standards for creating reusable trustworthy infrastructure modules
- [ ] **Crossplane Provider Configuration** - Document Crossplane providers installed and configurations cloud provider credentials
- [ ] **Crossplane Composition Artifact** - YAML definition composing managed resources into single reusable unit
- [ ] **Crossplane Claim Definition** - Namespace-scoped API allowing application teams to request infrastructure resources
- [ ] **Terraform/Pulumi Module Registry Inventory** - Catalog of approved versioned modules developers can use to provision infrastructure

### Platform Orchestration & Delivery Artifacts

- [ ] **Kratix Promise Definition** - Machine-readable contract defining self-service capability including API schema and workflows
- [ ] **Humanitec Platform Orchestrator Configuration** - Defines how application configurations dynamically generated and deployed across environments
- [ ] **KubeVela Application Delivery Workflow** - Declarative application deployment plan capturing and executing full microservice deployments
- [ ] **Fleet Management & GitOps Configuration (Kratix/KubeVela)** - Document how multi-cluster deployments managed through GitOps principles

### Security, Compliance & Cloud Posture Artifacts

- [ ] **Security Architecture Diagram** - Document security controls, threat boundaries, and compliance measures for deployed system
- [ ] **Cloud Security Posture Management (CSPM) Policy & Assessment** - Set of rules and configurations assessing overall posture of cloud environment
- [ ] **Policy as Code (OPA/Rego) Repository** - Collection of declarative policies enforcing guardrails, security requirements, and compliance mandates
- [ ] **Software Supply Chain Security Posture (OpenSSF Scorecard)** - Documented security score for each component in supply chain

### Observability, Measurement & Cost Management Artifacts

- [ ] **Platform Observability Configuration (Logging, Metrics, Tracing)** - Document how platform and workloads monitored
- [ ] **Cost Allocation & Chargeback Model** - Document how cloud infrastructure costs attributed to teams or products
- [ ] **Carbon-Aware Deployment Plan (Cloud)** - Specify how deployment scheduling and resource allocation optimized for carbon efficiency
- [ ] **Post-Incident Review (PIR) Artifact** - Record of significant operational failure, root cause, and remediation

### Edge & IoT-Specific Platform Artifacts

- [ ] **Edge Blueprint Definition (Akraino)** - Reusable blueprint for edge infrastructure and application
- [ ] **Edge-Native App Orchestration Workflow (KubeVela / Kratix)** - Deployment plan specifically designed for edge devices
- [ ] **Edge Site Configuration Manifest (Akraino Edge Site)** - Declarative specification for single or multi-node edge site

### AI-Augmented & Intelligent Platform Artifacts

- [ ] **AI-Assisted Golden Path Generation** - Use Generative AI to automatically generate golden path templates
- [ ] **Intelligent Document Processing (IDP) Pipeline** - Configuration for AI-driven framework ingesting, classifying, extracting data
- [ ] **Human-AI Collaboration (HAIC) Framework for Platform Engineering** - Documented set of policies defining how AI tools used

### Platform Maturity, Career & Governance Artifacts

- [ ] **CNCF Platform Engineering Maturity Model Assessment** - Structured framework assessing organization's platform maturity
- [ ] **Platform Career Ladder** - Document defining roles, responsibilities, and progression paths for platform engineers
- [ ] **Platform Engineering Org Structure Policy** - Define structure, reporting lines, stakeholder mapping, collaboration model
- [ ] **Developer Experience (DevEx) Measurement Framework** - Document metrics, collection methods, and review process for developer experience

---

## Estimation & Forecasting Documentation

Comprehensive inventory characterized by four major shifts

### Functional Size Measurement Artifacts

- [ ] **IFPUG FPA (Function Point Analysis)** - Measure software functional size based on functional user requirements
- [ ] **COSMIC Function Point Measurement** - ISO 19761 method sizing by counting data movements across functional processes
- [ ] **Non-Functional Size Measurement (ISO/IEC/IEEE 32430:2025)** - Quantify non-functional requirements to complement functional sizing
- [ ] **Use Case Points (UCP)** - Estimate based on use case models in object-oriented analysis

### Parametric & Algorithmic Estimation Models

- [ ] **COCOMO (Basic / Intermediate / Detailed)** - Effort = a × KSLOCᵇ × EM; three modes: organic, semi-detached, embedded
- [ ] **COCOMO II (Post-Architecture / Early Design)** - Estimates based on source lines of code or function points
- [ ] **CoBRA (Cost Estimation, Benchmarking, and Risk Assessment)** - Combines human judgment with measurement data
- [ ] **SLIM / ESTIMACS** - Commercial tools based on Putnam's model (Norden-Rayleigh curve)

### Agile & Relative Estimation Artifacts

- [ ] **Baseline Story / Reference Story** - Define team-specific story point scale
- [ ] **Estimation Factor Definition** - Explicitly define factors considered in story points (Complexity, Effort, Risk/Doubt)
- [ ] **Planning Poker Deck / Template** - Facilitate consensus-based relative estimation
- [ ] **Affinity Estimation (Bucket System)** - Quickly estimate large numbers of backlog items
- [ ] **T-Shirt Sizing** - High-level relative sizing without numeric precision
- [ ] **Estimation Confidence Record** - Track estimation certainty per item

### Probabilistic & Uncertainty Quantification Artifacts

- [ ] **Monte Carlo Simulation Engine** - Generate probabilistic completion forecasts using historical data
- [ ] **Probabilistic Forecast Report** - Communicate estimation uncertainty to stakeholders
- [ ] **Velocity Range Forecast** - Predict future sprint capacity using historical velocity distribution
- [ ] **What-If Scenario Analysis** - Model capacity changes (team size, availability)
- [ ] **Human-AI Collaboration (HAIC) Framework for Estimation** - Document governance policies for AI-assisted estimation

### AI & LLM-Driven Estimation Artifacts

- [ ] **LLM-Based COSMIC Measurement Report** - Automate functional size measurement from textual requirements
- [ ] **Predictive Functional Size via NLP** - Estimate size of unmeasured requirements using natural language processing
- [ ] **LLM-Generated Story Point Estimate** - Automate relative sizing using project-specific calibration
- [ ] **Comparative Learning Framework** - Calibrate project-specific prediction models via comparative learning
- [ ] **Multi-Agent LLM Estimation Consensus Record** - Simulate Planning Poker using autonomous agent conversations
- [ ] **AI-Generated Project Cost Estimate** - Produce natural-language estimate containing tasks, dependencies, timeline, and budget
- [ ] **Human Equivalent Effort (HEE) Report** - Translate AI agent task telemetry into business-legible effort units
- [ ] **AI-Driven Budget Recommendation (Historical Data)** - Auto-generate budgets using actual past project data

### Database-Driven & Template-Based Estimation

- [ ] **Feature Lego Block Catalog** - Reusable component database for bottom-up estimation
- [ ] **Historical Benchmark Database** - Industry/organizational benchmark data for estimation calibration
- [ ] **Template-Based Estimation Workflow** - Prebuilt templates for speed and consistency

### Estimation Validation & Improvement Artifacts

- [ ] **Estimation Accuracy Log** - Track accuracy of previous estimates to improve future projections
- [ ] **Spike Result / Research Record** - Document uncertainty reduction activities
- [ ] **Phase-Specific Estimate Update** - Refresh estimates at each lifecycle stage

### Estimation Templates & Tools (2026)

- [ ] **Spreadsheet-Based Templates** - Agile Project Estimation Excel, Function Point Analysis Workbook, Budget Estimate Template, Use Case Points Calculator
- [ ] **Specialized Estimation Platforms** - Sourcetable (AI-Powered Spreadsheets), Devtimate, ai-estimator2, COCOMO II Python Implementation

### Supporting Estimation Governance Artifacts

- [ ] **Estimation Strategy Document** - Define estimation approach tailored to project phase
- [ ] **Bottom-Up vs Top-Down Reconciliation Summary** - Quantify differences between approaches to align stakeholders
- [ ] **Three-Point Estimate (PERT) Document** - Template for single-item estimates giving approximation's risk
- [ ] **Reserve / Contingency Calculation** - Document contingency buffers for risk mitigation
- [ ] **Measurement Plan (per ISO/IEC 15939)** - Define measurement process with goals, scope, and data quality controls
- [ ] **Benchmarking Agreement / Calibration Log** - Document calibration using industry benchmarks or historical data
