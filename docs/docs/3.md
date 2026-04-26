# Technical Design & Architecture Documentation

Research into technical documentation practices reveals three major shifts happening right now: AI-automated architecture extraction, the rise of architecture as code tooling, and the integration of green architecture principles into design decisions. The artifacts listed below reflect these 2025–2026 trends, moving documentation from static Word documents living outside the repo to living, version-controlled artifacts stored alongside the code they describe.

## Refreshed Inventory: Technical Design & Architecture Documentation

### I. Standards-Based Architecture Frameworks
Modern architecture documentation increasingly starts with an established standard to ensure completeness and reduce "blank page syndrome."

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **arc42 Architecture Documentation** | Provide a complete, ISO-compliant template for software architecture documentation in both agile and traditional projects. | A structured template with 12 mandatory sections covering constraints, context, building block view, runtime view, deployment view, cross-cutting concepts, architecture decisions, and quality requirements. The approach is lightweight enough for agile teams but comprehensive enough for safety‑critical systems. |
| **ISO/IEC/IEEE 42010 Documentation Set** | Document a system's architecture in accordance with the international standard for architecture description. | Architecture description contains stakeholders (who has concerns), concerns (what matters to each stakeholder), architecture viewpoints (conventions for framing concerns), and architecture views (concrete representations of the system addressing specific concerns). The standard also defines architecture frameworks for organizing related practices. |

### II. Technology Stack & Quality Attribute Documentation
These artifacts capture the foundational technology choices and non‑functional requirements that shape every subsequent design decision.

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **Technology Stack Specification** | Formally document the programming languages, frameworks, libraries, databases, and infrastructure components selected for the project. | Complete inventory of languages, frameworks, data stores, message brokers, caching layers, and infrastructure orchestration. For each component, include version, licensing constraints, support status, sunset policies, and rationale for selection. |
| **Quality Attribute Scenario (QAS) Specification** | Quantify non‑functional requirements as testable scenarios, preventing vague "the system must be fast" statements. | Each scenario follows a structured format: Source (who stimulates the system), Stimulus (what happens), Environment (context at time of stimulus), Artifact (part of system stimulated), Response (required activity), and Response Measure (how success is quantified, e.g., "10,000 transactions per second"). |
| **Architectural Pattern Decision Record** | Capture the rationale for selecting a high‑level architectural pattern (e.g., monolith vs. microservices, event‑driven vs. request‑response). | Architects define the desired quality attributes, present alternative patterns considered, analyze trade‑offs (e.g., microservices improve scalability but increase distribution complexity), and document the final selection with justifications. This artifact is often the first Architectural Decision Record (ADR) in a project. |

### III. Hierarchical Architecture Views (C4 + Deployment)
The C4 model has emerged as the industry‑standard approach for visualizing software architecture, with tooling (PlantUML + Markdown) enabling full documentation‑as‑code. The model defines exactly four levels of abstraction—no more, no less—ensuring consistent communication across stakeholder groups.

| Level | Artifact | Audience | Key Content |
| :--- | :--- | :--- | :--- |
| **L1** | **System Context Diagram** | Everyone (non‑technical stakeholders) | Shows the software system as a central box, surrounded by the users (actors) and other software systems it interacts with. No technologies, protocols, or deployment details. Focuses on what the system does for whom. |
| **L2** | **Container Diagram** | Technical teams (developers, architects, operations) | Zooms into the system, showing the high‑level technology building blocks—applications, data stores, message brokers, serverless functions. Each container is an individually deployable/runnable unit. Answers: What are the major applications? How do they communicate? |
| **L3** | **Component Diagram** | Individual teams, new developers joining the team | Decomposes a single container into its internal structural components and their interactions. Shows which components call which others, code‑level dependencies, and component boundaries. Answers: What major components exist inside this application? |
| **L4** | **Code Diagram (optional)** | Developers doing detailed implementation work | Zooms into a single component, showing UML class diagrams, database schemas, or entity‑relationship diagrams. Most teams maintain L4 diagrams only for the most critical or complex components. |
| | **Deployment Diagram** | Operations, infrastructure, SRE teams | Extends the C4 model by showing how containers are mapped to infrastructure—physical servers, virtual machines, Kubernetes pods, cloud regions, availability zones, load balancers, firewalls, and CDN edges. Essential for understanding runtime topology, scalability constraints, and failure domains. |

### IV. Architecture Decision Management
Architectural Decision Records (ADRs) have become the standard mechanism for documenting the "why" behind technical choices, with governments published formal ADR frameworks as recommended best practices. ADRs are designed to be quick to write, easy to read, and useful to others, maintaining transparency in decision‑making.

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **Architectural Decision Record (ADR)** | Capture a single significant architecture decision, including context, alternatives considered, and consequences. | Standard fields include: Title (descriptive, searchable), Status (Proposed, Accepted, Deprecated, Superseded), Context (problem statement and constraints driving the decision), Decision (the choice made, described in precise terms), Consequences (positive and negative outcomes expected), Alternatives Considered (options rejected with reasoning), and Related ADRs (links to connected decisions). |
| **Architectural Decision Log (ADL)** | Act as a registry of all ADRs, serving as the historical record of a system's architectural evolution. | A simple index listing each ADR by ID, title, decision date, status, and affected system components. One established best practice is to store ADRs in a /docs/adr/ folder within each repo, with one ADR file per significant decision, superseding old ones rather than editing history. |
| **ADR Metadata & Traceability** | Provide governance hooks for ADRs, linking decisions to design reviews, pull requests, and compliance checkpoints. | Each ADR includes decision date, decision author, approver (when formal governance exists), reviewers, link to relevant design review or PR, ticket/issue IDs, affected version(s), and review history. This transforms informal team decisions into auditable records while preserving the lightweight, agile character of ADRs. |

### V. API Contract & Specification Documentation
Contract‑first API development has emerged as the dominant pattern—defining the contract before implementation, then generating servers, clients, and documentation.

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **OpenAPI Specification (REST APIs)** | Provide a machine‑readable, language‑agnostic contract for HTTP APIs, enabling automated client generation, documentation, and validation. | Endpoints, HTTP methods, path parameters, query parameters, request headers, request/response schemas (using JSON Schema), error codes (4xx/5xx with error payload templates), security schemes (OAuth, API keys, JWT), servers, and examples. Treat API specifications as a contract between frontend, backend, and third‑party consumers. Contract amendments require versioning the API or supporting both old and new contracts until all clients migrate. |
| **AsyncAPI Specification (Event‑driven APIs)** | Document asynchronous, message‑driven APIs for Kafka, RabbitMQ, MQTT, SQS, or WebSockets. | Channels (topics/queues), operations (publish/subscribe), message payload schemas (using JSON Schema or Avro), headers, correlation IDs, protocol binding details (Kafka partitioning, AMQP routing), and service discovery metadata. Unified OpenAPI + AsyncAPI best practices require extracting common JSON schemas into shared files, applying the DRY (Don't Repeat Yourself) principle. |
| **API Versioning & Change Management Plan** | Define policies for how APIs are versioned and how breaking changes are communicated and migrated. | Versioning strategy (URI versioning, custom header, content negotiation), deprecation policy with sunset dates, backward‑compatible change guidelines (adding optional fields is safe; removing fields is breaking), and consumer notification process. |
| **Generated API Documentation (Redoc, Swagger UI)** | Provide live, interactive documentation automatically generated from OpenAPI or AsyncAPI contracts. | Never write API documentation by hand. Generate beautiful, interactive docs directly from the machine‑readable contract specification. |

**Tooling for Contract-First Development**

| Tool | Key Capabilities | Best For |
| :--- | :--- | :--- |
| **OpenAPI Generator** | Generate client SDKs, server stubs (Node.js, Spring, Python, Go, etc.), and documentation from an OpenAPI spec. | Teams needing multi‑language client generation. |
| **AsyncAPI Generator** | Generate documentation, code (subscribers/publishers), and boilerplate from an AsyncAPI spec. | Teams building event‑driven or message-based systems. |
| **Spectral** | Lint and validate OpenAPI/AsyncAPI specs against custom rulesets (naming conventions, security requirements, field completeness). | Teams enforcing API governance through automation. |
| **Stoplight** | Visual API design, spec editing, mocking, and documentation hub with governance workflows. | Teams adopting API‑first across the full lifecycle. |
| **Bump.sh** | Automated changelog generation from API spec changes, contract testing in CI, and hosted documentation. | Teams needing diff‑based change tracking. |
| **Arazzo Specification** | Document multi‑step workflows across multiple APIs, chain API calls, and orchestrate complex interactions. | Teams building composite APIs or complex integrations requiring sequential API calls with dependent results. |

### VI. Implementation-Level Design Documentation
These artifacts bridge the gap between architecture and code, guiding developers building individual components.

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **Low‑Level Design Document (LLD)** | Provide detailed technical specifications for implementing a module, component, or microservice. | Data model (entities, attributes, relationships), API endpoints (often as a referenced OpenAPI spec), database schema (tables, indexes, constraints), algorithm descriptions or pseudocode for complex logic, concurrency and locking strategy, error handling (what errors, how propagated), and logging/observability specifications. |
| **Database Design Document** | Document the logical and physical schema for persistent storage. | Entity‑Relationship Diagram (ERD), physical schema(s) with table definitions, columns, data types, primary/foreign keys, indexes, partitioning strategy, and backup/restore plan. |
| **Sequence Diagrams** | Visualize the interaction flow between components for a specific use case, showing precise message ordering. | Lifelines (objects/actors), messages (synchronous vs. asynchronous), activation boxes, return values, alt/opt/loop fragments for alternative flows, and duration constraints. Sequence diagrams are particularly valuable for distributed tracing, transaction boundaries, and understanding timeout behavior. |
| **State Diagrams** | Model the lifecycle of a business entity—the finite states it can be in and the events triggering transitions. | States (Start, Intermediate, End), transitions (events + guards + actions), orthogonal regions for concurrent substates, deferrable events, and history states for resumable workflows. Critical for any system with workflows, approvals, or long‑running processes. |

### VII. Infrastructure & Deployment Documentation
These artifacts capture infrastructure as code (IaC) and deployment topology, enabling reproducible, auditable environments.

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **Infrastructure as Code (IaC) Templates** | Express infrastructure (servers, networking, databases, load balancers) as declarative code, enabling version control, review, and automated provisioning. | Cloud provider configuration (AWS CloudFormation/Terraform/CDK, Azure Resource Manager, Google Cloud Deployment Manager) defining compute instances, VPCs, subnets, security groups, IAM roles, databases, and load balancers. Modern IaC is the source of truth for infrastructure—any manual change is a bug. |
| **Deployment Topology Map** | Visualize the physical arrangement of software containers on infrastructure, including networking, scaling, and failure domains. | Extends C4 Deployment Diagram level showing each container's placement (Kubernetes pod, virtual machine, serverless function), network paths (service mesh, API gateway, ingress controllers), scaling replicas, availability zones, load balancers, CDN origins, and database read replicas. |
| **Security Architecture Diagram** | Document security controls, threat boundaries, and compliance measures for the deployed system. | Threat boundaries (trust zones), data flows with encryption indicators (TLS at rest and in transit), authentication/authorization mechanisms (OAuth2/OIDC, service accounts), secret stores (HashiCorp Vault, AWS Secrets Manager), audit logging points, compliance controls (SOC2, HIPAA, PCI‑DSS), and WAF/API gateway placements. |

### VIII. Quality & Cross‑Cutting Specifications
These artifacts document quality mechanisms and design patterns applied consistently across the system.

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **Quality Assurance & Testing Strategy** | Document the overall approach to verifying that the system meets its functional and non‑functional requirements. | Testing pyramid (unit/integration/e2e ratios), test automation approach (CI/CD integration, test data management, environment strategy), performance and load testing plan, security testing plan (SAST/DAST schedules), defect tracking process, quality metrics (e.g., code coverage thresholds, maximum defect density). |
| **Cross‑Cutting Concepts Specification** | Document technical concerns that apply system‑wide, avoiding repetition across component‑level designs. | Logging (structured logs, log levels, sensitive data filtering, aggregation to ELK/Datadog), Observability (metrics, distributed tracing, SLI/SLO definitions, dashboard ownership), Error Handling (error taxonomy, retry policies, circuit‑breakers, graceful degradation), Internationalization (message catalogs, date/time formatting, RTL layout, translation pipelines), Configuration Management (configuration sources, environment overrides, secret injection, reload behavior), and Security (JWT validation patterns, role‑based access policies, CORS, audit trail). |

### IX. Modern & Emerging Architecture Artifacts
These artifacts reflect 2025–2026 trends: automated documentation using LLMs, architecture as code, platform engineering, green software principles, and AI‑assisted decision making.

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **Architecture as Code Artifacts** | Write architecture diagrams and specifications in plain text files stored in version control, enabling code review of architecture changes. | C4 diagrams expressed as PlantUML or Mermaid code within Markdown files, reviewed via pull requests. OpenAPI/AsyncAPI specs as YAML/JSON. ADRs as Markdown files in /docs/adr/. NFRs as quantifiable test definitions using tooling like OWASP ZAP API scanning or k6 load testing scripts. Tooling such as Structurizr builds upon the C4 model to provide a diagramming tool where the model is code, supporting real‑time collaborative editing, interactive diagrams, quality checks, and CI/CD integrations. |
| **Platform Engineering Artifacts** | Document the internal development platform (IDP)—the curated set of tools, services, and APIs that developers consume to build and deploy applications. | Golden Path templates (scaffolding for new services), Guardrails (non‑negotiable rules, e.g., "every repo must have a security scan"), Service Catalog (documented capabilities with SLAs), Developer Portal configuration (Backstage, Humanitec). |
| **Green Software Architecture Specification** | Document architectural decisions aimed at minimizing energy consumption and carbon footprint of the software. | Carbon intensity targets for compute regions (choose regions with cleaner grids), energy per transaction metrics, load‑shifting strategies (batch jobs run when grid is cleaner), right‑sizing of compute resources, efficient data structure and algorithm choices, data residency carbon accounting (transfer vs. in‑region processing), and garbage collection efficiency for languages with managed memory. Many teams now require green architecture reviews for significant design decisions, using tools like Kepler for power monitoring and Scaphandre for metric export. |
| **AI‑Generated Architecture Documentation** | Use Large Language Models (LLMs) to automatically extract and generate system‑level architecture documentation directly from source code repositories. | Automated extraction tools: CIAO (Code In Architecture Out) follows a template derived from ISO/IEC/IEEE 42010, SEI Views & Beyond, and the C4 model, taking a GitHub repository as input and producing system‑level architectural documentation in minutes. CodeWiki generates holistic, repository‑level documentation including architecture diagrams, data flow visualizations, and sequence diagrams. Developers generally perceive AI‑generated architecture documentation as valuable, comprehensible, and broadly accurate, though limitations remain in diagram quality, high‑level context modeling, and deployment views. |
| **AI‑Assisted Architecture Decision Records** | Augment ADR creation using LLMs to generate alternatives, evaluate trade‑offs, and summarize consequences. | Human‑led, AI‑powered workflows where the architect frames the problem and constraints (budget caps, SLOs, team size, compliance requirements); the LLM generates structured alternatives with trade‑off analyses. The architect makes the final decision and records it in a standard ADR. This reduces cognitive load while keeping humans in the loop for value judgments. |

### X. Governance & Collaboration Artifacts
These artifacts enable team collaboration, knowledge transfer, and architectural governance.

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **Architecture Design Review Record** | Document the output of formal or informal architecture review sessions, capturing feedback and decisions. | Review participants (architects, leads, stakeholders), artifacts reviewed (diagrams, ADRs, specs, model), identified risks and concerns, required changes with owners and deadlines, and approval status (Approved, Approved with Conditions, Rejected). |
| **Architecture Technical Debt Register** | Track architectural shortcuts, incomplete implementations, and known deviations from the planned architecture that carry future rework cost. | Debt description, affected components, severity/cost estimate of remediation, date of introduction, responsible team, and current status. This transforms "we'll fix it later" into a visible, manageable backlog, preventing silent architectural erosion where undocumented drift gradually invalidates the architecture. |
| **Architecture & Design Wiki / Knowledge Base** | Provide a centralized, searchable repository for all architecture documentation, ADRs, decisions, and patterns, often integrated with the code repository. | Indexed by component and decision date, with cross‑links between ADRs, diagrams, specifications, and code modules. The goal is documentation where developers already work—embedded in the repo, editable via pull request, and searchable through standard IDE and GitHub interfaces. |
| **Architecture Decision Framework** | Document the process for when and how architecture decisions get made, aligned with team governance. | Criteria for which decisions require an ADR (e.g., any cross‑team technology choice, any decision with cost or compliance implications); approval thresholds (LGTM from two senior engineers vs. formal architecture board review); and escalation paths for unresolved trade‑offs. |

## 🔍 How to Choose and Apply Architecture Documentation

A successful architecture documentation practice is about selecting the right artifact for the context—not documenting everything possible. The following guidelines help you build a tailored, effective documentation strategy:

- **Start With the Framework, Not a Blank Page**: Use arc42 or ISO/IEC/IEEE 42010 as a backbone for complete architecture documentation, reducing both omission risk and blank page syndrome. The C4 model is ideal for visualizing structure, while ADRs instrument decision management.

- **Store Documentation in the Code Repository**: Adopt documentation as code. Store architecture diagrams as PlantUML/Mermaid text (enabling diffs and versioning), ADRs as Markdown in /docs/adr/, and OpenAPI/AsyncAPI specs as YAML files. This ensures documentation stays fresh because changing it requires a pull request reviewed by the same engineers changing the code. Many teams now require diagram updates as part of the definition of done for any pull request that changes architecture.

- **Let AI Do the Heavy Lifting for Existing Systems**: For brownfield projects (existing codebases with little or no documentation), tools like CIAO and CodeWiki can generate initial architecture documentation automatically from the repository. The generated output serves as a starting point that architects can review, correct, and extend—turning months of reverse engineering into days of validation.

- **Keep It Lightweight—Don't Overdocument**: Modern practice favors "just enough" documentation—what matters to stakeholders who need it, when they need it. A 2022 IEEE study of six open‑source projects found that most architecture documentation stays at the lowest maturity level, often informal natural language on wikis. The goal is not exhaustive detail but sufficient clarity for future decision‑making. For every artifact, ask: "Does this provide value that outweighs the maintenance cost?"

- **Document Decisions, Not Just Structure**: The most valuable part of architecture documentation is the why. Prioritize ADRs for significant choices (technologies, patterns, trade‑offs) over exhaustive structural descriptions—especially in agile environments, where architecture and design emerge iteratively, but the reasons behind convergence must persist.

- **Integrate ADRs Into Daily Workflow**: An ADR is only useful if it is read, reviewed, and updated. Link ADRs in design reviews and pull requests. Supersede old ADRs rather than editing history. Include ADRs in onboarding materials. Most importantly, make ADRs searchable—a decision nobody can find is a decision that didn't happen.

By integrating these updated artifacts into a coherent, context‑appropriate strategy, you create an architecture documentation practice that drives better decisions, enables effective collaboration, and adapts to modern development workflows—without becoming the bureaucratic burden that derails so many documentation efforts.
