---
name: sqa-audit
description: SQA Audit workflow — comprehensive project quality audit covering code-to-story traceability, story-to-architecture alignment, process compliance, sprint health, and release state
type: skill
triggers:
  - "audit"
  - "audit project"
  - "run audit"
---

# SQA Audit Workflow

## Purpose
Perform a structured quality audit of the project, reporting findings per dimension with severity levels (PASS / WARNING / FAIL). The audit produces a written report saved to the output folder.

---

## Step 1 — Scope Selection

Ask the user:

> "Welcome to the SQA Audit. Would you like to run a **full audit** (all dimensions) or a **partial audit** (select specific areas)?
>
> Available audit dimensions:
> 1. **Code ↔ Stories**: Verify that implemented code corresponds to active/done stories
> 2. **Stories ↔ Architecture & PRD**: Verify that epics and stories align with the architecture and product requirements
> 3. **Process Compliance**: Verify adherence to the defined development process (branching, commits, testing, reviews)
> 4. **Sprint Health**: Analyze the state and health of active and recent sprints
> 5. **Release State**: Review the status of releases, deployments, and delivery readiness
>
> Type **'full'** to run all dimensions, or list the numbers of the dimensions you want (e.g., '1,3,5')."

Wait for user response. Store the selected dimensions as {audit_scope}.

---

## Step 2 — Data Collection

Before running any audit dimension, collect the following project artifacts:

### Required reads
- `{project-root}/_bmad/bmm/config.yaml` — resolve {output_folder}
- `{output_folder}/planning-artifacts/prd.md` — product requirements (if exists)
- `{output_folder}/planning-artifacts/architecture.md` — architecture doc (if exists)
- `{output_folder}/planning-artifacts/epics.md` — epics (if exists)
- `{output_folder}/implementation-artifacts/sprint-status.yaml` — sprint and backlog state

### Optional reads (load if they exist)
- `{output_folder}/project-context.md` — project context summary
- Any story files referenced in sprint-status.yaml that are relevant to active/done items

Inform the user which artifacts were found and which were missing before proceeding. Missing artifacts for a dimension will result in a SKIPPED status for that dimension.

---

## Step 3 — Run Selected Audit Dimensions

**Scope guard:** For each dimension below, only execute if that dimension's number is in {audit_scope}. Skip silently — do not mention skipped dimensions until the report.

Run each selected dimension in order. For each dimension, produce a findings block (see format below).

### Dimension 1 — Code ↔ Stories Traceability

**Goal:** Verify that code in the repository corresponds to stories marked as done or in-progress, and that no significant code exists without a backing story.

**Process:**
1. Read the `done` and `in_progress` items from sprint-status.yaml
2. For each story/task, check whether the described changes can be traced to actual code (ask the user to confirm or provide relevant file paths if direct code scanning is not feasible)
3. Identify stories marked done but with no apparent code changes (ask user to verify)
4. Identify significant recent commits (from git log summary if available) not linked to any story
5. Report gaps

**Findings format:**
- List each story ID and its traceability status
- Flag any untraced code changes
- Flag any stories with no code evidence

---

### Dimension 2 — Stories ↔ Architecture & PRD Alignment

**Goal:** Verify that the epics and stories correctly implement the requirements in the PRD and are consistent with the architecture.

**Process:**
1. For each epic in epics.md, identify the corresponding PRD section(s)
2. Check that epic goals are derived from PRD requirements — flag any epic with no clear PRD backing
3. For each epic/story with technical decisions, check alignment with architecture.md:
   - Technology choices match the architecture
   - System boundaries and component assignments are respected
   - Non-functional requirements (NFRs) from the PRD are reflected in stories
4. Flag any stories that introduce architectural decisions not documented in architecture.md
5. Flag any PRD requirements with no corresponding epic/story

**Findings format:**
- PRD coverage table (requirement → epic/story mapping, with COVERED / MISSING / PARTIAL)
- Architecture compliance issues list

---

### Dimension 3 — Process Compliance

**Goal:** Verify that the team is following the defined development process.

**Process:**
1. Check for the presence of a git-workflow-skill or equivalent branching policy definition
2. Retrieve recent git log using available git tools (run `git log --oneline -20` directly). Fall back to asking the user to paste the output only if tool execution fails or is not permitted:
   - Are commit messages following conventional commit format?
   - Are changes going through feature branches and PRs (not committed directly to main)?
3. Check for test coverage evidence:
   - Are test files present alongside implementation files for new code?
   - Are there failing tests in the repository?
4. Check for code review evidence (PR descriptions, review comments) if accessible
5. Check that story files are being maintained (status updates, implementation notes)

**Findings format:**
- Process checklist with PASS / FAIL / UNKNOWN per item
- Specific violation examples with file/commit references where available

---

### Dimension 4 — Sprint Health

**Goal:** Assess the health of active and recent sprints.

**Process:**
1. Read sprint-status.yaml — load all sprints, backlog, and epics sections
2. For each active sprint:
   - Calculate completion percentage (done items / total items)
   - Identify overdue items (items that should be done based on sprint timeline)
   - Flag items that have been in-progress for an unusually long time (no status change)
   - Identify blockers and high-priority items not yet started
3. For the most recently closed sprint:
   - Report carry-over items (items that were not completed and moved back to backlog)
   - Report the final completion rate
4. Assess backlog health:
   - Is the backlog groomed? (items have priorities, estimates, and clear descriptions)
   - Are there orphaned items not belonging to any epic?

**Findings format:**
- Per-sprint summary table (sprint name, total items, done, in-progress, not started, completion %)
- Risk flags (overdue, stalled, blockers)
- Backlog health summary

---

### Dimension 5 — Release State

**Goal:** Assess the readiness and status of releases and deployments.

**Process:**
1. Ask the user: "Do you have a release tracking document, deployment pipeline, or version file? If so, please share the path or content."
2. Check for version files in the project (package.json, version.txt, CHANGELOG.md, etc.)
3. Identify which stories/epics are included in the current or upcoming release
4. Verify that all stories slated for the release are marked done
5. Check for open bugs or blockers tagged to the current release
6. Ask about deployment status: "Has the current release been deployed to any environment? If so, which ones?"
7. Identify any release-critical stories that are still in-progress or not started

**Findings format:**
- Release readiness summary (READY / AT RISK / NOT READY)
- List of blocking items preventing release
- Deployment status per environment (if available)

---

## Step 4 — Audit Report

After running all selected dimensions, compile a full audit report.

### Report format

```
# SQA Audit Report
**Date:** {today's date}
**Auditor:** Gad (SQA Agent)
**Scope:** {list of audited dimensions}
**Overall Status:** PASS | WARNING | FAIL

---

## Executive Summary
{2-4 sentences summarizing the overall quality posture of the project}

---

## Findings by Dimension

### [Dimension Name]
**Status:** PASS | WARNING | FAIL | SKIPPED
**Summary:** {one-line summary}

#### Issues Found
| Severity | Item | Detail | Recommendation |
|----------|------|--------|----------------|
| FAIL     | ...  | ...    | ...            |
| WARNING  | ...  | ...    | ...            |

#### Observations
{Any noteworthy observations that are not blocking issues}

---

## Action Items
{Prioritized list of recommended corrective actions}

| Priority | Action | Owner (if known) | Related Dimension |
|----------|--------|------------------|-------------------|
| P1       | ...    | ...              | ...               |

---

## Skipped Dimensions
{List dimensions that were skipped due to missing artifacts, and what artifacts are needed to run them}
```

### Severity definitions
- **FAIL**: A clear gap or violation that should be resolved before continuing or releasing
- **WARNING**: A concern that should be addressed but is not immediately blocking
- **PASS**: The dimension meets quality expectations

### Overall status rule
- If any dimension is FAIL → overall is FAIL
- If no FAIL but any WARNING → overall is WARNING
- All PASS or SKIPPED → overall is PASS

---

## Step 5 — Save Report

Save the report to:
`{output_folder}/sqa-audit-report-{YYYY-MM-DD}.md`

Inform the user of the saved path.

Then, for each FAIL finding in the report, present it one at a time and ask:
> "Would you like me to create a backlog story for this issue: [finding summary]? (yes/skip)"

Wait for the user's response before proceeding to the next FAIL. If yes, invoke the `create-bug-story` workflow for that item. The user may accept or skip each item individually. Once all FAILs have been offered, ask:
> "Would you like me to generate a remediation plan for all findings? This will produce a prioritized corrective-action document saved alongside the audit report."

If yes, generate and save a remediation plan to:
`{output_folder}/sqa-remediation-plan-{YYYY-MM-DD}.md`

### Remediation Plan Format

```
# SQA Remediation Plan
**Date:** {today's date}
**Auditor:** Gad (SQA Agent)
**Source Report:** sqa-audit-report-{YYYY-MM-DD}.md
**Scope:** {audited dimensions}

---

## Summary

{1-2 sentences: number of findings, overall risk level, key themes}

---

## Corrective Actions

| Priority | Dimension | Finding | Corrective Action | Target State | Effort | Owner |
|----------|-----------|---------|-------------------|--------------|--------|-------|
| P1       | ...       | ...     | ...               | ...          | Low/Medium/High | ... |

**Priority definitions:**
- P1 — FAIL severity; must be resolved before next release or sprint boundary
- P2 — WARNING severity; should be resolved within current or next sprint
- P3 — Observation; address when capacity allows

---

## Resolution Tracking

{Instructions to the team: update this table as items are resolved; re-run the audit after P1 items are addressed to verify closure}
```

Inform the user of the remediation plan path and ask if they want to review any finding in more detail.
