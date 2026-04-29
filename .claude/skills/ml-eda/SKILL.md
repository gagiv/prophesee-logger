---
name: ml-eda
description: ML EDA — Exploratory Data Analysis and Research Thesis validation
---

# ML Stage 2 — EDA & Research Thesis

No modelling without high-quality EDA. This stage validates the data against the research thesis.

## Instructions

### 1. Load Context
- Read `_bmad-output/planning-artifacts/research-thesis.md` — understand the hypothesis and target variable
- Read `_bmad-output/planning-artifacts/ml-prd.md` — understand the success metrics and failure cost matrix
- Confirm raw data path with the user (default: `data/raw/`)

### 2. Run EDA Script
- If `scripts/eda_analyzer.py` exists, execute it: `uv run python scripts/eda_analyzer.py`
- If it does not exist, write a minimal `scripts/eda_analyzer.py` that:
  - Loads the dataset
  - Prints shape, dtypes, null counts
  - Plots target distribution
  - Computes correlation matrix for numeric features
  - Saves outputs to `_bmad-output/planning-artifacts/eda-figures/`

### 3. Analyze and Document
Write `_bmad-output/planning-artifacts/eda-report.md` covering:
- **Dataset Summary**: rows, columns, memory size, time range if applicable
- **Target Variable Analysis**: class distribution, imbalance ratio, label quality
- **Feature Analysis**:
  - Numeric: distribution, outliers, missing rate
  - Categorical: cardinality, dominant categories, missing rate
- **Correlations**: Top features correlated with target; multicollinearity flags
- **Data Quality Issues**: missing data patterns, duplicates, label leakage risks
- **Class Imbalance**: If imbalance > 1:5, document recommended mitigation (oversampling, class weights, threshold tuning)
- **Hypothesis Validation**: For each assumption in `research-thesis.md`, state CONFIRMED / CHALLENGED / UNKNOWN with evidence

### 4. Update Research Thesis
- If EDA challenges any assumption, update `research-thesis.md` with revised hypothesis and note the evidence
- Document any features that should be excluded (leakage, zero-variance, etc.)

### 5. Surface Dilemmas & Commit Gate

Before presenting and **before any git commit**:

- Identify every data or preprocessing decision where two or more reasonable options existed (missing value strategy, feature exclusion, class imbalance approach, hypothesis revisions, etc.)
- Format each as: **Dilemma [Letter] — Title** / **Context** / **Options (a/b/c)** / **Recommendation** / **Your decision:** [blank]
- If all choices were unambiguous, state explicitly: "No open dilemmas."
- **Do NOT commit any artifact (report, figures, updated thesis) until the user has responded and given explicit approval.**

### 6. Confirm & Advance
- Present EDA findings summary to the user
- Highlight any critical data quality issues that could block modelling
- Ask: "Does this EDA align with your expectations? Any features to add or exclude?"
- On approval: commit all artifacts, then say "Stage 2 complete. Proceed to **Stage 3 — /ml-architecture** to design the model stack."
- STOP and WAIT for user confirmation
