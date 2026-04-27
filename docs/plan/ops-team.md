---
title: "Operations Team Structure"
owner: "Operations"
status: "active"
updated: "2026-04-26"
canonical: ""
---

This document describes the team structure including domain ownership, RACI matrix, on-call rotation, escalation matrix, roles & responsibilities, skills matrix, meeting schedule, communication channels, and decision framework.

---

## Quick Reference: Domain Ownership

| Domain | Owner | Key SLAs |
| :--- | :--- | :--- |
| Platform Foundation | Platform Engineering | Build <5min, deploy daily |
| Data & Sync | Data Platform | Sync <500ms, query p95<2s |
| AI Core & Agents | AI/ML Engineering | Latency <2s, halluc≤2% |
| Frontend & UX | Product Engineering | LCP≤800ms, INP≤200ms |
| Security & Compliance | Security/GRC | Response <15min, audit ready |
| Business Strategy | Product/GTM | Revenue growth tracked |

---

## 5.1 Ownership & Accountability

### RACI Matrix

| Task | Platform | Data | AI | Frontend | Security | Product | GRC |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| AI Cost Tracking | C | A | R | C | I | A | I |
| Agent Studio | C | I | R | C | I | A | I |
| MCP Security | I | I | R | C | R | A | A |
| Guardrails Engine | I | I | R | C | R | A | A |
| Offline Sync | C | R | C | I | I | I | I |
| Real-time Collab | C | C | I | R | I | I | I |
| Feature Flags | C | I | I | R | I | A | I |
| Observability | C | C | C | C | R | I | I |
| A2A Integration | I | I | R | C | R | A | I |
| Compliance Pipeline | I | I | I | I | R | R | A |
| CSP Policy | I | I | I | I | R | R | A |
| Rate Limiting | C | I | I | I | R | I | I |
| Secrets Rotation | C | I | I | I | R | R | A |
| Incident Response | C | C | C | C | R | I | I |
| SOC2 Evidence | I | I | I | I | R | R | A |

### Ownership Matrix

| Domain | Owner | Backup | Role | SLA | Escalation |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Platform Foundation | Platform Engineering | DevOps Lead | Senior SRE | Build times<5min,deploy freq daily | CTO |
| Data & Sync | Data Platform | Data Lead | Senior Data Engineer | Sync latency<500ms,query p95<2s | VP Engineering |
| AI Core & Agents | AI/ML Engineering | AI Lead | Senior ML Engineer | Model latency<2s,halluc≤2% | CTO |
| Frontend & UX | Product Engineering | Frontend Lead | Senior FE Engineer | LCP≤800ms,INP≤200ms | VP Engineering |
| Security & Compliance | Security/GRC | Security Lead | Senior Security Engineer | Incident response<15min,audit ready | CTO |
| Business Strategy | Product/GTM | Product Lead | Senior PM | Revenue growth tracked,acquisition cost monitored | CEO |

---

## 5.2 On-Call & Escalation

### On-Call Rotation

| Role | Rotation | Coverage | Response Time | Escalation | Handoff |
| :--- | :--- | :--- | :--- | :--- | :--- |
| P0 Incident | All Leads | Weekly 24/7 | 15min immediate | CTO 30min | Written postmortem 48h |
| P1 Platform | Platform Engineering | Weekly 24/7 | 1 hour | VP Engineering 2 hours | Ticket handoff with notes |
| P1 Data | Data Platform | Weekly 24/7 | 1 hour | VP Engineering 2 hours | Ticket handoff with notes |
| P1 AI | AI/ML Engineering | Weekly 24/7 | 1 hour | CTO 2 hours | Ticket handoff with notes |
| P1 Frontend | Product Engineering | Weekly 24/7 | 1 hour | VP Engineering 2 hours | Ticket handoff with notes |
| P1 Security | Security/GRC | Weekly 24/7 | 15 minutes | CTO 30 minutes | Security audit log |
| P2 Issues | All Teams | Business hours only | 4 hours | Team Lead next business day | Ticket queue assignment |

### Escalation Matrix

| Level | Trigger | Contact | Response | Decision |
| :--- | :--- | :--- | :--- | :--- |
| L1 | Routine issue | Team Slack | Team Lead responds within 1h | Team Lead resolves |
| L2 | Team blocked | Team Lead unresponsive | VP Engineering responds within 30min | VP Engineering unblocks |
| L3 | Cross-team impact | Multiple teams blocked | CTO responds within 15min | CTO coordinates resources |
| L4 | Critical incident | P0 production outage | CEO notified immediately | CEO directs crisis response |
| L5 | Security breach | Confirmed exploit | Legal/PR notified immediately | Crisis management team activated |

---

## 5.3 Team Structure

### Roles & Responsibilities

| Role | Responsibilities | Skills | On Call | Backup |
| :--- | :--- | :--- | :--- | :--- |
| Platform Lead | Infra,CI/CD,deployment | Kubernetes,Fly.io,Turborepo | Yes | Senior SRE |
| Data Lead | DB,sync,vector store | Postgres,TimescaleDB,pgvector | Yes | Senior Data Engineer |
| AI Lead | LLM gateway,agents,guardrails | LangChain,LiteLLM,eval frameworks | Yes | Senior ML Engineer |
| Frontend Lead | React,performance,a11y | React 19,Motion,Tailwind | Yes | Senior FE Engineer |
| Security Lead | MCP,CSP,audit | OWASP,MCPSec,Vault | Yes | Senior Security Engineer |
| Product Lead | PRD,roadmap,metrics | RICE,MoSCoW,analytics | No | Senior PM |
| GRC Lead | SOC2,EU AI Act,compliance | Vanta,PIA,evidence pipeline | No | Compliance Analyst |

### Skills Matrix

| Skill | Team | Proficiency | Training | Certification |
| :--- | :--- | :--- | :--- | :--- |
| Kubernetes | Platform | Expert | quarterly K8s training | CKA |
| Postgres | Data | Expert | Postgres Deep Dive course | Postgres Certified |
| LangChain | AI | Expert | LangChain workshops | Internal cert |
| React 19 | Frontend | Expert | React Conf attendance | Meta cert |
| OWASP MCP | Security | Expert | OWASP training | CISSP |
| SOC2 | GRC | Expert | Vanta training | SOC2 audit experience |
| Incident Response | All | Intermediate | GameDay exercises | ITIL Foundation |

---

## 5.4 Operations

### Meeting Schedule

| Meeting | Frequency | Attendees | Duration | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| Daily Standup | Daily | All engineers | 15min | Blockers,progress,plan |
| Weekly Planning | Weekly | All leads | 1h | Sprint planning,review,retro |
| Biweekly Architecture | Biweekly | Tech leads | 1h | Design reviews,ADR discussions |
| Monthly All-Hands | Monthly | All company | 1h | Roadmap,metrics,announcements |
| Quarterly Planning | Quarterly | All leads | 4h | OKR setting,resource allocation |
| Incident Review | Ad-hoc | On-call team | 1h | Postmortem,action items |
| Security Review | Monthly | Security+GRC | 1h | Vulnerability scan,compliance status |

### Communication Channels

| Channel | Purpose | Audience | Etiquette |
| :--- | :--- | :--- | :--- |
| #incidents | P0/P1 incidents | All engineers | Alerts only,use threads for discussion |
| #platform | Platform issues | Platform team | Technical discussions,decisions |
| #data | Data issues | Data team | Schema changes,performance |
| #ai | AI issues | AI team | Model changes,eval results |
| #frontend | Frontend issues | Frontend team | UI/UX discussions,performance |
| #security | Security issues | Security+GRC | Vulnerabilities,compliance |
| #product | Product updates | All | Roadmap,features,metrics |
| #random | Non-work | All | Social,team building |

### Decision Framework

| Type | Maker | Consult | Inform | Timeline | Appeal |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Technical | Tech Lead | Team | All | Immediate | CTO |
| Product | Product Lead | Stakeholders | All | Weekly | CEO |
| Security | Security Lead | GRC | CTO | Immediate | CEO |
| Budget | VP Engineering | Finance | CTO | Monthly | CEO |
| Hiring | Hiring Manager | Team | HR | As needed | CEO |
| Pricing | Product Lead | Sales | CEO | Quarterly | Board |

### Domain Ownership Map (April 2026)

| Domain | Owner | Backup | Cross-Cutting |
| :--- | :--- | :--- | :--- |
| A: Platform & DX | Platform Eng | Senior SRE | DB infra,CI/CD,monorepo |
| B: Data & Sync | Data Platform | Data Lead | AI vector/graph,frontend sync state |
| C: AI Core & Agents | AI/ML Eng | AI Lead | Frontend GenUI streaming,business metering |
| D: Frontend & UX | Product Eng | Frontend Lead | AI prompt/agent UI,business telemetry |
| E: Security & GRC | Security/GRC | Security Lead | Identity,audit,compliance across all |
| F: Business & Monetization | Product/GTM | Product Lead | Budget gates,feature flags |
