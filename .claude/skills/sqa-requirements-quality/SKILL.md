---
name: sqa-requirements-quality
description: Requirements Quality Audit workflow — evaluates requirements in selected project documents against 14 quality criteria, producing a per-requirement audit table, missing-elements section, and overall quality score
type: skill
triggers:
  - "requirements quality"
  - "audit requirements"
  - "req quality"
  - "requirements audit"
---

# Requirements Quality Audit Workflow

## Purpose

Evaluate requirements in selected project documents against **14 established quality criteria** (Clarity, Single Verb, Sentence Structure, Glossary Presence, Necessity, Implementation-Independence, Unambiguity, Completeness, Feasibility, Testability, Stakeholder Alignment, Convention Conformance, Understandability, Precision). Produce a structured per-requirement audit report and offer corrective-action support for failing requirements.

---

## Quality Criteria Reference

| # | Criterion | Definition |
|---|-----------|------------|
| 1 | **Clarity & Directness** | No source-form verbs (e.g., "to save", "to keep"). States the required behavior, not a capability. |
| 2 | **Single Primary Verb** | Each requirement contains exactly one main action verb; any conditions are separated by commas or placed on a new line. |
| 3 | **Sentence Structure** | Follows the pattern: `Condition + Subject + Predicate + Object [+ Constraint]`. |
| 4 | **Glossary Presence** | All domain-specific terms used in the requirement are defined in a dedicated glossary. |
| 5 | **Necessity** | The requirement appears only once in the document and does not duplicate another. If conceptually identical to another, identify which requirement it duplicates. |
| 6 | **Implementation-Independent** | Describes the need, not a specific solution or technology. |
| 7 | **Unambiguous** | Has only one possible interpretation for all relevant stakeholders. |
| 8 | **Completeness** | Self-contained; does not rely on other requirements for its meaning. |
| 9 | **Feasibility** | Realistic and achievable within reasonable cost, schedule, and technology limits. |
| 10 | **Testability** | Can be verified by a concrete test or inspection. |
| 11 | **Stakeholder Alignment** | Accurately reflects the expressed needs of the identified stakeholders. |
| 12 | **Conformance to Conventions** | Uses the project's standard format (e.g., Epic → User Stories → Acceptance Criteria) and consistent look-and-feel. |
| 13 | **Understandability** | Written in plain language that the supplier can readily comprehend. |
| 14 | **Precision** | Uses definite nouns, explicit units, and avoids vague qualifiers (e.g., "approximately", "usually", "high"). |

---

## Step 1 — Scope Selection

Ask the user:

> "Welcome to the Requirements Quality Audit. Which documents should I audit?
>
> **Available sources:**
> 1. **PRD — Functional Requirements (FR)**: All FR-prefixed requirements in `prd.md`
> 2. **PRD — Non-Functional Requirements (NFR)**: All NFR-prefixed requirements in `prd.md`
> 3. **Epics & User Stories**: Epic goals and story acceptance criteria in `epics.md`
> 4. **All of the above**
>
> Type **'all'** or list the numbers you want (e.g., '1,2')."

Wait for user selection. Store as {rq_scope}.

---

## Step 2 — Data Collection

Load the selected documents. Note presence or absence — missing documents result in that scope item being SKIPPED.

| Source | Path |
|--------|------|
| PRD | `{output_folder}/planning-artifacts/prd.md` |
| Epics & Stories | `{output_folder}/planning-artifacts/epics.md` |

Inform the user which documents were found and which were missing before proceeding.

---

## Step 3 — Extract Requirements

**Scope guard:** Only extract from documents selected in {rq_scope}.

For each selected source, identify and list all requirements to be evaluated:

- **PRD FRs**: All items prefixed `FR` in the Functional Requirements section
- **PRD NFRs**: All items prefixed `NFR` in the Non-Functional Requirements section
- **Epics**: Epic goal statements (the "Goal:" or intent sentence of each epic)
- **User Stories**: The "As a / I want / so that" statement plus all Acceptance Criteria items

If the total requirement count exceeds 30, ask the user:
> "I found {N} requirements. Would you like me to audit all of them, or focus on a specific section? (Type 'all' or describe which section to prioritize)"

---

## Step 4 — Evaluate Requirements

For each requirement, evaluate all 14 criteria. Produce a table per requirement:

| Requirement ID | Requirement Summary | Type | Criterion | Pass/Fail | Comments / Suggested Revision |
|----------------|-------------------|------|-----------|-----------|-------------------------------|
| [ID] | [one-line summary] | [type] | 1 — Clarity & Directness | ✅ / ❌ | [comment or suggested revision if failed] |
| | | | 2 — Single Primary Verb | ✅ / ❌ | |
| | | | 3 — Sentence Structure | ✅ / ❌ | |
| | | | 4 — Glossary Presence | ✅ / ❌ | |
| | | | 5 — Necessity | ✅ / ❌ | |
| | | | 6 — Implementation-Independent | ✅ / ❌ | |
| | | | 7 — Unambiguous | ✅ / ❌ | |
| | | | 8 — Completeness | ✅ / ❌ | |
| | | | 9 — Feasibility | ✅ / ❌ | |
| | | | 10 — Testability | ✅ / ❌ | |
| | | | 11 — Stakeholder Alignment | ✅ / ❌ | |
| | | | 12 — Convention Conformance | ✅ / ❌ | |
| | | | 13 — Understandability | ✅ / ❌ | |
| | | | 14 — Precision | ✅ / ❌ | |

**Requirement Type codes:** `FR` `NFR` `US` (User Story) `AC` (Acceptance Criterion) `EPIC`

**Rules:**
- For every ❌, provide a specific, actionable suggested revision in the Comments column
- For Criterion 5 (Necessity), if a duplicate is found, name the duplicating requirement by ID
- A requirement FAILS overall if it fails 3 or more criteria (mark the ID row with ⚠️)
- A requirement CRITICALLY FAILS if it fails criteria 7 (Unambiguous), 10 (Testability), or 14 (Precision) (mark the ID row with ❌)

---

## Step 5 — Missing Elements

After all requirement tables, produce a **Missing Elements** section:

```
### Missing Elements

- Glossary: [domain-specific terms used across requirements that lack a definition]
- Acceptance Criteria: [User Stories with no AC]
- Traceability: [requirements not linked to a parent epic, stakeholder need, or PRD section]
- Testability gaps: [requirements where no concrete verification method is apparent]
- Other: [any absent artifacts or structural issues]
```

If nothing is missing, state: *No missing elements identified.*

---

## Step 6 — Overall Quality Score

```
### Overall Quality Score

{X} / {Y} criteria passed across {Z} requirements ({P}%)

**By severity:**
- Critical failures (failing criterion 7, 10, or 14): {N} requirements
- Overall failures (≥3 criteria failing): {N} requirements
- Minor issues (1-2 criteria failing): {N} requirements
- Fully passing: {N} requirements
```

---

## Step 7 — Compile and Save Report

Compile the full report in this structure:

```
# Requirements Quality Audit Report
**Date:** {today's date}
**Auditor:** Gad (SQA Agent)
**Scope:** {selected document sources}
**Requirements Audited:** {total count}
**Overall Quality Score:** {X}/{Y} ({P}%)

---

## Executive Summary
{3-4 sentences: overall quality posture, most common failure patterns, primary recommendations}

---

## Per-Requirement Audit

{requirement tables from Step 4}

---

## Missing Elements

{section from Step 5}

---

## Overall Quality Score

{section from Step 6}

---

## Top Recommendations

{Ordered list of the most impactful improvements — focus on patterns, not individual requirements}

| Priority | Pattern | Affected Requirements | Recommended Fix |
|----------|---------|-----------------------|-----------------|
| P1       | ...     | FR12, FR18, FR24      | ...             |
```

Save the report to:
`{output_folder}/sqa-requirements-quality-report-{YYYY-MM-DD}.md`

Inform the user of the saved path.

---

## Step 8 — Corrective Action Offers

Ask:
> "Would you like me to generate a remediation plan with suggested revisions for all failing requirements?"

If yes, save a remediation plan to:
`{output_folder}/sqa-remediation-plan-requirements-{YYYY-MM-DD}.md`

### Remediation Plan Format

```
# Requirements Quality Remediation Plan
**Date:** {today's date}
**Auditor:** Gad (SQA Agent)
**Source Report:** sqa-requirements-quality-report-{YYYY-MM-DD}.md

---

## Summary
{count of critical failures, overall failures, minor issues}

---

## Corrective Actions

| Priority | Req ID | Type | Failed Criteria | Issue | Suggested Revision | Effort |
|----------|--------|------|----------------|-------|-------------------|--------|
| P1       | FR12   | FR   | 7, 10          | ...   | ...               | Low    |

---

## Pattern-Level Fixes
{If multiple requirements share the same failure pattern, describe a single structural fix that would resolve the pattern across all affected requirements}
```

Then, for each critically failing requirement (criterion 7, 10, or 14 failing), offer one at a time:
> "Would you like me to create a backlog story to rewrite requirement [ID]? (yes/skip)"

If yes, invoke `create-bug-story` for that item.
