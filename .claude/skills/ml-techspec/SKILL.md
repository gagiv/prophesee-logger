---
name: ml-techspec
description: ML TechSpec — Lock the experiment contract. Defines acceptance criteria that cannot be changed during training.
---

# ML Stage 4 — TechSpec (The Contract)

The TechSpec is a locked contract. Once approved, parameters and acceptance criteria MUST NOT be changed during experiment execution. This prevents moving the goalposts after seeing results.

## Instructions

### 1. Load Context
- Read `_bmad-output/planning-artifacts/ml-prd.md`
- Read `_bmad-output/planning-artifacts/eda-report.md`
- Read `_bmad-output/planning-artifacts/ml-architecture.md`

### 2. Draft the TechSpec
Write `_bmad-output/planning-artifacts/ml-techspec.md` with the following sections — every field is REQUIRED:

```
# ML TechSpec — [Project Name]
Status: DRAFT -> LOCKED (set to LOCKED on user approval)
Locked At: [timestamp on approval]

## Experiment Identity
- Project: [project_name from configs/ml_config.yaml]
- Tracking Tool: [wandb / mlflow / clearml / local]
- Run Name Convention: [e.g. xgb_v{version}_{date}]

## Data Contract
- Training Data: [path, row count, date range]
- Validation Strategy: [stratified k-fold N=X / time-series split / holdout ratio]
- Test Set: [path or split ratio — NEVER touched until final evaluation]
- Feature Set: [list of features, with preprocessing step for each]
- Excluded Features: [list with reason for exclusion]

## Model Contract
- Algorithm: [exact algorithm name and library]
- Baseline: [exact baseline — e.g. DummyClassifier(strategy='most_frequent')]
- Fixed Hyperparameters: [params NOT being tuned, with values]
- HPO Space: [params being tuned, with ranges and search strategy]
- HPO Budget: [max trials or max wall-clock time]

## Acceptance Criteria (PRIMARY — must ALL pass)
- Primary Metric: [e.g. Recall >= 0.85 on validation set]
- Secondary Metric: [e.g. AUC-ROC >= 0.80]
- Baseline Beat: [model must beat baseline on primary metric]

## Guardrail Criteria (MUST NOT violate)
- [e.g. Precision >= 0.50 — below this FP rate is unacceptable in domain]
- [e.g. Inference latency < 100ms per sample]

## Failure Cost Reminder
- False Negative cost: [from PRD]
- False Positive cost: [from PRD]
- Threshold selection strategy: [maximize recall / F-beta / cost-weighted]

## Reproducibility
- Random seed: [integer]
- uv lockfile: pyproject.toml + uv.lock
```

### 3. Surface Dilemmas & Commit Gate

Before presenting and **before any git commit**:

- Identify every contract decision where two or more reasonable options existed (metric threshold values, HPO budget, random seed choice, held-out split ratio, guardrail definitions, etc.)
- Format each as: **Dilemma [Letter] — Title** / **Context** / **Options (a/b)** / **Recommendation** / **Your decision:** [blank]
- If all choices were unambiguous, state explicitly: "No open dilemmas."
- **Do NOT commit the TechSpec until the user has resolved all dilemmas and given explicit lock approval.**

### 4. Lock the Contract
- Present the TechSpec draft and all surfaced dilemmas to the user
- State explicitly: "Once you approve this, the acceptance criteria and data contract are locked. You may tune hyperparameters but may NOT change the primary metric threshold, feature set, or validation strategy during training."
- Ask: "Do you approve and lock this TechSpec?"
- On approval: Set Status to LOCKED, add Locked At timestamp, then commit

### 5. Confirm & Advance
- "TechSpec locked. Proceed to **Stage 5 — /ml-infra** to set up the environment and run a smoke test."
- STOP and WAIT for user confirmation
