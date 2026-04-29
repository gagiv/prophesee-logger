---
name: ml-analysis
description: ML Analysis - Evaluate experiment results against the locked TechSpec contract and produce a verdict
---

# ML Stage 7 - Analysis (vs TechSpec)

Evaluate results objectively against the locked contract. Do not rationalize failures.

## Instructions

### 1. Load Context
- Read `_bmad-output/planning-artifacts/ml-techspec.md`
- Read `_bmad-output/implementation-artifacts/experiment-log.md`
- Read `_bmad-output/planning-artifacts/ml-prd.md` (failure cost matrix)

### 2. Acceptance Criteria Evaluation
For each criterion in the TechSpec, produce a verdict table:

| Criterion | Threshold | Achieved | Status |
|-----------|-----------|----------|--------|
| Recall    | >= 0.85   | 0.88     | PASS   |
| AUC-ROC   | >= 0.80   | 0.79     | FAIL   |
| Beat baseline | Yes   | Yes      | PASS   |

Overall verdict: PASS only if ALL primary criteria pass and NO guardrails are violated.

### 3. Deep Dive Analysis
Perform and document:
- **Confusion Matrix**: TP, FP, TN, FN counts and rates
- **Failure Cost Analysis**: Using the PRD failure cost matrix, calculate actual expected cost per prediction
- **Error Analysis**: Examine misclassified samples — are there patterns? (demographic, feature range, data quality)
- **Threshold Sensitivity**: Show primary metric vs decision threshold curve; identify optimal threshold per cost matrix
- **Feature Importance**: Top 10 features driving predictions (SHAP values or model-native importance)
- **Overfitting Check**: Compare train vs validation metrics; flag if gap > 10%
- **Distribution Shift Check**: Compare test feature distributions vs training distributions

### 4. Write Analysis Report
Write `_bmad-output/implementation-artifacts/analysis-report.md` with all findings and the overall PASS/FAIL verdict.

### 5. Determine Next Step
- **If PASS**: "All acceptance criteria met. The model is a candidate for deployment review. Proceed to **Stage 8 — /ml-retrospective**."
- **If FAIL**:
  - Diagnose root cause: data quality issue? wrong model family? HPO budget too small? Feature engineering gap?
  - Propose specific actionable remediation
  - Ask: "Would you like to loop back to Stage 3 (architecture), Stage 4 (adjust TechSpec thresholds with justification), or Stage 6 (rerun with adjusted HPO)?"
  - Note: Adjusting TechSpec thresholds requires explicit user acknowledgement that the contract is being changed and why

### 6. Surface Dilemmas & Commit Gate

Before presenting and **before any git commit**:

- Identify every analytical judgement call where two or more interpretations existed (threshold selection rationale, error pattern root cause, overfitting diagnosis, remediation path selection, etc.)
- Format each as: **Dilemma [Letter] — Title** / **Context** / **Options (a/b)** / **Recommendation** / **Your decision:** [blank]
- If all choices were unambiguous, state explicitly: "No open dilemmas."
- **Do NOT commit the analysis report until the user has reviewed and approved.**

### 7. Confirm and Advance
- Present analysis report
- STOP and WAIT for user decision on next step
