---
name: sqa-ieee12207
description: IEEE/ISO/IEC 12207 compliance workflow — audits the project against software lifecycle process requirements, producing a compliance report with findings per process area
type: skill
triggers:
  - "ieee 12207"
  - "iso 12207"
  - "12207"
  - "lifecycle compliance"
---

# IEEE/ISO/IEC 12207 Compliance Workflow

## Purpose

Evaluate the project's compliance with **IEEE/ISO/IEC 12207:2017** — the international standard for software lifecycle processes. The audit maps available project artifacts to standard process areas, identifies gaps, and produces a compliance report.

This workflow focuses on the processes most verifiable from a BMAD project's artifacts. Processes that require organizational-level evidence (HR management, infrastructure management, etc.) are flagged as "Organization-scope — verify separately."

---

## Step 1 — Scope Selection

Introduce the workflow:

> "I will audit this project against IEEE/ISO/IEC 12207:2017. The standard defines processes across four groups. I can audit all applicable process areas or focus on selected ones.
>
> **Process Groups:**
> 1. **Technical Processes** — Requirements, Architecture, Design, Implementation, Integration, Verification, Validation
> 2. **Technical Management Processes** — Project Planning, Configuration Management, Risk Management, Quality Assurance, Measurement
> 3. **Agreement Processes** — Acquisition, Supply (traceability of delivered scope to stated needs)
> 4. **Organizational Enabling Processes** — Knowledge Management, Life Cycle Model Management *(limited verifiability from artifacts)*
>
> Type **'full'** to audit all groups, or list group numbers (e.g., '1,2')."

Wait for user selection. Store as {ieee12207_scope}.

---

## Step 2 — Data Collection

Load the following artifacts. Note their presence or absence — missing artifacts affect compliance scores.

| Artifact | Standard Relevance | Path |
|----------|-------------------|------|
| PRD / stakeholder needs | Requirements Definition (6.4.2) | `{output_folder}/planning-artifacts/prd.md` |
| Architecture document | Architecture Definition (6.4.4) | `{output_folder}/planning-artifacts/architecture.md` |
| Epics & stories | Requirements traceability (6.4.2, 6.4.3) | `{output_folder}/planning-artifacts/epics.md` |
| Sprint status | Project Planning (6.3.1), Implementation (6.4.7) | `{output_folder}/implementation-artifacts/sprint-status.yaml` |
| Test artifacts | Verification (6.4.9), Validation (6.4.10) | Any `*.test.*`, `tests/`, `spec/` files |
| Design docs | Design Definition (6.4.5) | Any SDD, design.md, or detailed design files |
| Release / change log | Configuration Management (6.3.5) | `CHANGELOG.md`, `package.json`, version files |
| Risk register | Risk Management (6.3.4) | Any risk log or risk section in PRD/architecture |
| Project context | General | `{output_folder}/project-context.md` |

Inform the user of which artifacts were found before proceeding.

---

## Step 3 — Evaluate Process Areas

**Scope guard:** For each process group below, only evaluate if that group's number is in {ieee12207_scope}. Skip all process areas in unselected groups.

Evaluate each selected process group. For each process area, assign a compliance level:

- **COMPLIANT** — Evidence found that satisfies the process intent
- **PARTIAL** — Some evidence exists but gaps remain
- **NON-COMPLIANT** — No evidence found or clear violation of process intent
- **NOT APPLICABLE** — Process not relevant to this project type
- **ORGANIZATION-SCOPE** — Verifiable only at organizational level, not from project artifacts
- **SKIPPED** — The primary evidence source for this process area is missing; evaluation cannot be completed. Record the missing artifact path.

---

### Group 1 — Technical Processes

#### 1.1 Business or Mission Analysis (6.4.1)
- Is there a stated business problem, opportunity, or mission need driving the project?
- Evidence: PRD problem statement, project context, vision section
- Check: Does the PRD contain a clear problem statement and project rationale?

#### 1.2 Stakeholder Needs and Requirements Definition (6.4.2)
- Are stakeholder needs identified, prioritized, and documented?
- Are requirements testable, unambiguous, and traceable?
- Evidence: PRD user stories, epics, acceptance criteria
- Check: Do epics map to stakeholder needs? Are acceptance criteria present in stories?

#### 1.3 System/Software Requirements Definition (6.4.3)
- Are software requirements formally defined, including functional and non-functional requirements?
- Evidence: PRD functional requirements section, NFRs, constraints
- Check: Are NFRs (performance, security, availability) explicitly documented?

#### 1.4 Architecture Definition (6.4.4)
- Is a software architecture defined that satisfies the requirements?
- Does the architecture identify components, interfaces, and their relationships?
- Evidence: `architecture.md` — component diagram, technology choices, integration points
- Check: Are all major components documented? Are interfaces defined? Does architecture address NFRs?

#### 1.5 Design Definition (6.4.5)
- Is there a detailed design that refines the architecture to implementable units?
- Evidence: `{output_folder}/planning-artifacts/` — look for SDD, design.md, or detailed design files; API specs or data models within story files
- Check: Is there design documentation below the architecture level?

#### 1.6 System Analysis (6.4.6)
- Are design decisions analyzed and justified?
- Evidence: `{output_folder}/planning-artifacts/architecture.md` — look for ADR sections, decision rationale, or trade-off notes
- Check: Are significant technology/design choices explained with rationale?

#### 1.7 Implementation (6.4.7)
- Is the software being implemented according to design, with traceability to requirements?
- Evidence: Sprint stories in done/in-progress state, code in repository
- Check: Are done stories traceable to epics? Is there evidence of implementation progress?

#### 1.8 Integration (6.4.8)
- Is there a strategy for integrating components?
- Evidence: Integration stories, CI/CD pipeline, integration tests
- Check: Is component integration planned? Are integration tests defined?

#### 1.9 Verification (6.4.9)
- Is the software verified to meet its specified requirements?
- Evidence: Test files, test stories, test plan, CI test results
- Check: Are unit/integration tests present? Do tests reference requirements or acceptance criteria?

#### 1.10 Validation (6.4.10)
- Is the software validated against the stakeholder needs (not just the specification)?
- Evidence: UAT plans, demo records, user feedback sessions, acceptance criteria sign-off
- Check: Is there evidence of validation beyond code-level testing?

#### 1.11 Transition (6.4.11)
- Is there a plan for deploying/transitioning the software to its operational environment?
- Evidence: Deployment documentation, deployment stories, runbooks
- Check: Is deployment documented or planned?

---

### Group 2 — Technical Management Processes

#### 2.1 Project Planning (6.3.1)
- Is there a project plan with scope, schedule, resources, and milestones?
- Evidence: `sprint-status.yaml` (sprints with dates/capacity), epics with priorities
- Check: Are sprints defined with dates? Is backlog groomed and prioritized?

#### 2.2 Project Assessment and Control (6.3.2)
- Is project progress measured and corrective actions taken?
- Evidence: Sprint health data, sprint retrospectives, burn-down tracking
- Check: Are completed vs. planned sprint items tracked? Are risks acted upon?

#### 2.3 Decision Management (6.3.3)
- Are significant decisions documented with rationale?
- Evidence: `{output_folder}/planning-artifacts/architecture.md` (ADR or decision sections), `{output_folder}/planning-artifacts/prd.md` (revision history table), sprint retrospectives
- Check: Are key architectural or design decisions recorded?

#### 2.4 Risk Management (6.3.4)
- Are project risks identified, analyzed, and tracked?
- Evidence: Risk register in PRD, risk section in architecture, sprint blockers
- Check: Is there a documented risk register or risk section? Are blockers tracked?

#### 2.5 Configuration Management (6.3.5)
- Is software configuration (versions, artifacts, baselines) managed?
- Evidence: Git repository, version files (package.json), CHANGELOG, release tags
- Check: Is there version control? Are releases tagged? Is there a changelog?

#### 2.6 Information Management (6.3.6)
- Is project information organized, accessible, and preserved?
- Evidence: `{output_folder}/project-context.md`, `{output_folder}/` directory listing — assess whether artifacts are organized in a consistent, navigable structure
- Check: Are project artifacts organized in a consistent structure?

#### 2.7 Measurement (6.3.7)
- Are project metrics collected and used for decision-making?
- Evidence: Sprint velocity, bug counts, test coverage metrics
- Check: Are any quantitative metrics tracked for the project?

#### 2.8 Quality Assurance (6.3.8)
- Is there an active QA process ensuring process and product compliance?
- Evidence: This audit itself, code review records, QA stories
- Check: Is QA planned? Are code reviews performed? Are defects tracked?

---

### Group 3 — Agreement Processes

#### 3.1 Acquisition (6.1.1)
- If external components or services are acquired, is there a defined acquisition process?
- Evidence: Dependency management files (package.json, requirements.txt), third-party licenses
- Check: Are third-party dependencies documented and managed?

#### 3.2 Supply (6.1.2)
- Is the delivered software traceable to the agreed-upon scope?
- Evidence: Epics vs. PRD requirements, sprint done items vs. release scope
- Check: Can the delivered features be mapped back to the original requirements?

---

### Group 4 — Organizational Project-Enabling Processes

Note to Gad: For Group 4 items, briefly assess based on available evidence only. These are primarily organizational-scope and marked accordingly.

#### 4.1 Life Cycle Model Management (6.2.1)
- Is a defined software life cycle model being followed?
- Evidence: BMAD methodology presence, sprint cycle, defined phases
- Rating: COMPLIANT if BMAD lifecycle is actively used; otherwise ORGANIZATION-SCOPE

#### 4.2 Knowledge Management (6.2.7)
- Is project knowledge captured and available to the team?
- Evidence: project-context.md, architecture doc, sprint retrospectives
- Check: Is accumulated knowledge documented for future reference?

---

## Step 4 — Compliance Report

Compile the full compliance report.

### Report format

```
# IEEE/ISO/IEC 12207:2017 Compliance Report
**Date:** {today's date}
**Auditor:** Gad (SQA Agent)
**Standard:** IEEE/ISO/IEC 12207:2017 — Systems and software engineering — Software life cycle processes
**Scope:** {selected process groups}
**Overall Compliance Level:** COMPLIANT | PARTIAL | NON-COMPLIANT

---

## Executive Summary
{3-5 sentences describing the project's overall compliance posture, major strengths, and primary gaps}

---

## Compliance Matrix

### Group 1 — Technical Processes
| Clause | Process Area | Compliance | Key Evidence | Gaps |
|--------|-------------|------------|--------------|------|
| 6.4.1  | Business/Mission Analysis | ... | ... | ... |
| 6.4.2  | Stakeholder Needs & Requirements | ... | ... | ... |
| 6.4.3  | Software Requirements Definition | ... | ... | ... |
| 6.4.4  | Architecture Definition | ... | ... | ... |
| 6.4.5  | Design Definition | ... | ... | ... |
| 6.4.6  | System Analysis | ... | ... | ... |
| 6.4.7  | Implementation | ... | ... | ... |
| 6.4.8  | Integration | ... | ... | ... |
| 6.4.9  | Verification | ... | ... | ... |
| 6.4.10 | Validation | ... | ... | ... |
| 6.4.11 | Transition | ... | ... | ... |

### Group 2 — Technical Management Processes
| Clause | Process Area | Compliance | Key Evidence | Gaps |
|--------|-------------|------------|--------------|------|
| 6.3.1  | Project Planning | ... | ... | ... |
| 6.3.2  | Project Assessment & Control | ... | ... | ... |
| 6.3.3  | Decision Management | ... | ... | ... |
| 6.3.4  | Risk Management | ... | ... | ... |
| 6.3.5  | Configuration Management | ... | ... | ... |
| 6.3.6  | Information Management | ... | ... | ... |
| 6.3.7  | Measurement | ... | ... | ... |
| 6.3.8  | Quality Assurance | ... | ... | ... |

### Group 3 — Agreement Processes
| Clause | Process Area | Compliance | Key Evidence | Gaps |
|--------|-------------|------------|--------------|------|
| 6.1.1  | Acquisition | ... | ... | ... |
| 6.1.2  | Supply | ... | ... | ... |

### Group 4 — Organizational Enabling Processes
| Clause | Process Area | Compliance | Notes |
|--------|-------------|------------|-------|
| 6.2.1  | Life Cycle Model Management | ... | ... |
| 6.2.7  | Knowledge Management | ... | ... |

---

## Gap Analysis

### Critical Gaps (NON-COMPLIANT items)
{List each non-compliant area with specific missing evidence and recommended action}

### Partial Compliance Items
{List each partial area with what is present and what is missing}

---

## Recommended Actions

| Priority | Action | Clause | Effort |
|----------|--------|--------|--------|
| P1 | ... | 6.x.x | Low / Medium / High |

---

## Compliance Summary

| Group | Total Clauses | Compliant | Partial | Non-Compliant | Org-Scope | N/A | Skipped |
|-------|--------------|-----------|---------|---------------|-----------|-----|---------|
| Technical Processes | 11 | ... | ... | ... | ... | ... | ... |
| Technical Management | 8 | ... | ... | ... | ... | ... | ... |
| Agreement Processes | 2 | ... | ... | ... | ... | ... | ... |
| Organizational Enabling | 2 | ... | ... | ... | ... | ... | ... |
| **Total** | **23** | ... | ... | ... | ... | ... | ... |

**Overall Compliance Rate:** {compliant + partial} / {total applicable (excluding Skipped and N/A)} = {X}%

---

## Skipped Process Areas
{List each process area rated SKIPPED, with the artifact path that was missing and is required to complete evaluation}

| Clause | Process Area | Missing Artifact |
|--------|-------------|-----------------|
| ...    | ...         | ...             |
```

---

## Step 5 — Save Report

Save the report to:
`{output_folder}/sqa-ieee12207-report-{YYYY-MM-DD}.md`

Inform the user of the saved path and ask:
> "The IEEE/ISO/IEC 12207 compliance report has been saved. Would you like to create backlog stories for the P1 (NON-COMPLIANT) gaps?"

After the gap-to-story flow completes (or is declined), ask:
> "Would you like me to generate a remediation plan for all compliance gaps? This will produce a prioritized corrective-action document saved alongside the compliance report."

If yes, generate and save a remediation plan to:
`{output_folder}/sqa-remediation-plan-ieee12207-{YYYY-MM-DD}.md`

### Remediation Plan Format

```
# IEEE/ISO/IEC 12207 Remediation Plan
**Date:** {today's date}
**Auditor:** Gad (SQA Agent)
**Source Report:** sqa-ieee12207-report-{YYYY-MM-DD}.md
**Standard:** IEEE/ISO/IEC 12207:2017

---

## Summary

{1-2 sentences: number of non-compliant and partial areas, overall compliance rate, primary themes}

---

## Corrective Actions

| Priority | Clause | Process Area | Gap Description | Corrective Action | Missing Artifact / Evidence | Effort | Owner |
|----------|--------|-------------|-----------------|-------------------|----------------------------|--------|-------|
| P1       | 6.x.x  | ...         | ...             | ...               | ...                        | Low/Medium/High | ... |

**Priority definitions:**
- P1 — NON-COMPLIANT; address before next formal review or release
- P2 — PARTIAL compliance; address within current or next sprint
- P3 — ORGANIZATION-SCOPE; escalate to organizational process owner

---

## Resolution Tracking

{Re-run the IEEE 12207 compliance workflow after P1 items are addressed to verify closure}
```

Inform the user of the remediation plan path.

If the user says yes, present P1 gaps one at a time. For each gap:
1. Display the gap summary (clause, process area, missing evidence)
2. Ask: "Create a backlog story for this gap? (yes/skip)"
3. Wait for the user's response before moving to the next gap
4. If yes, invoke the `create-bug-story` workflow for that item

Once all P1 gaps have been offered, ask:
> "Would you like to drill into any specific process area in more detail?"
