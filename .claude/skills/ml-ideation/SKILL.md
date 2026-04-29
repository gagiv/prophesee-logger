---
name: ml-ideation
description: ML Ideation — Frame the research problem, define success criteria, and produce a Machine Learning PRD
---

# ML Stage 1 — Ideation & PRD

Frame the ML problem rigorously before any data or modelling work begins.

## Instructions

### 1. Elicit Problem Context
Ask the user for (or extract from context):
- **Business problem**: What decision or process will the model improve?
- **Target variable**: What are we predicting? (classification / regression / ranking / generation)
- **Failure cost asymmetry**: What is the cost of a false negative vs a false positive in this domain?
- **Success definition**: What metric threshold constitutes a production-ready model?
- **Data availability**: What raw datasets exist and where are they located?

### 2. Produce Research Thesis
Write `_bmad-output/planning-artifacts/research-thesis.md` with:
- **Hypothesis**: A single falsifiable statement (e.g. "We can predict X with >Y recall using features A, B, C")
- **Assumptions**: List all assumptions that must hold for the hypothesis to be testable
- **Risks**: Top 3 risks that could invalidate the hypothesis (data quality, label noise, distribution shift)
- **Null Hypothesis**: The baseline we must beat (random, heuristic, or existing system)

### 3. Produce ML PRD
Write `_bmad-output/planning-artifacts/ml-prd.md` with sections:
- **Problem Statement** (1 paragraph)
- **Stakeholders & Users**
- **Success Metrics** (primary metric, secondary metrics, guardrail metrics)
- **Failure Cost Matrix** (FP cost vs FN cost with domain justification)
- **Data Requirements** (source, volume, freshness, labelling)
- **Out of Scope** (explicit non-goals)
- **Dependencies** (upstream data pipelines, external APIs)

### 4. Surface Dilemmas & Commit Gate

Before presenting and **before any git commit**:

- Identify every framing choice where two or more reasonable options existed (metric threshold, failure cost ratio, scope boundary, two-stage vs single-stage, etc.)
- Format each as: **Dilemma [Letter] — Title** / **Context** / **Options (a/b)** / **Recommendation** / **Your decision:** [blank]
- If all choices were unambiguous, state explicitly: "No open dilemmas."
- **Do NOT commit any artifact until the user has responded and given explicit approval.**

### 5. Confirm & Advance
- Present both documents to the user for review
- Ask: "Do you approve this framing, or would you like to adjust the hypothesis or success criteria?"
- On approval: commit artifacts, then say "Stage 1 complete. When ready, proceed to **Stage 2 — /ml-eda** to analyze the raw data."
- STOP and WAIT for user confirmation before advancing
