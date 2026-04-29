---
name: ml-architecture
description: ML Architecture — Define the model stack, feature engineering strategy, and training pipeline design
---

# ML Stage 3 — Architecture Design

Define the full technical stack before writing any training code.

## Instructions

### 1. Load Context
- Read `_bmad-output/planning-artifacts/eda-report.md`
- Read `_bmad-output/planning-artifacts/ml-prd.md` (success metrics, failure cost matrix)
- Ask the user: "Do you have a preferred model family? (e.g. XGBoost, LightGBM, sklearn, PyTorch, Transformers, or let me recommend)"

### 2. Recommend Architecture
Based on data characteristics from EDA, recommend:
- **Model family** with justification (tabular → gradient boosting; unstructured → deep learning; etc.)
- **Baseline model** (logistic regression / dummy classifier) — always required as sanity check
- **Candidate models** (1–3 options with trade-offs)
- **Feature engineering strategy**: encoding, scaling, imputation, feature selection approach
- **Class imbalance strategy**: class_weight, SMOTE, threshold tuning — choose based on failure cost matrix
- **Validation strategy**: stratified k-fold, time-series split, or held-out — justify choice

### 3. Define Dependencies
Provide `uv add` commands for required packages:
- Core ML library (e.g. `xgboost`, `lightgbm`, `scikit-learn`)
- Tracking tool already configured (wandb / mlflow / clearml / none)
- Supporting libraries (optuna for HPO, shap for explainability if needed)

### 4. Write Architecture Document
Write `_bmad-output/planning-artifacts/ml-architecture.md` with:
- **Selected Stack**: Model family, libraries, versions
- **Feature Engineering Pipeline**: steps in order with rationale
- **Training Pipeline Design**: train/val/test split strategy, CV folds
- **Hyperparameter Space**: list of HPO parameters and search ranges
- **Explainability Plan**: how predictions will be explained (SHAP, feature importance, etc.)
- **Experiment Tracking**: which metrics will be logged and to which tool
- **Rejected Alternatives**: models considered but rejected, with reasons

### 5. Surface Dilemmas & Commit Gate

Before presenting and **before any git commit**:

- Identify every architectural choice where two or more reasonable options existed (model family, HPO objective, imbalance strategy, CV folds, Stage 2 model, tracking tool, feature encoding, etc.)
- Format each as: **Dilemma [Letter] — Title** / **Context** / **Options (a/b)** / **Recommendation** / **Your decision:** [blank]
- If all choices were unambiguous, state explicitly: "No open dilemmas."
- **Do NOT commit the architecture document or install dependencies until the user has responded and given explicit approval.**

### 6. Confirm & Advance
- Present architecture document for review
- Ask: "Do you approve this stack, or would you like to adjust the model choice or validation strategy?"
- On approval: commit artifacts, then say "Stage 3 complete. Proceed to **Stage 4 — /ml-techspec** to lock the experiment contract."
- STOP and WAIT for user confirmation
