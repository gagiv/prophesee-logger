---
name: ml-experiment
description: ML Experiment - Execute training, hyperparameter optimization, and log all runs to the tracking tool
---

# ML Stage 6 - Experiment Execution

Execute the training pipeline as specified in the locked TechSpec. Log everything. Touch nothing outside the HPO space.

## Instructions

### 1. Load Context
- Read `_bmad-output/planning-artifacts/ml-techspec.md` — MUST be LOCKED. If not, STOP.
- Read `_bmad-output/planning-artifacts/ml-architecture.md`
- Note the fixed random seed, feature set, and validation strategy — do not deviate

### 2. Write Training Script
If `scripts/train.py` does not exist, generate it following the TechSpec exactly:
- Load data from TechSpec data contract paths
- Apply preprocessing pipeline (from ml-architecture)
- Create train/val split using TechSpec validation strategy and fixed seed
- Instantiate tracking run (wandb.init / mlflow.start_run / local log)
- Log all TechSpec fixed params as run config
- Run baseline model first — log its metrics
- Run candidate model with fixed hyperparameters — log metrics
- If HPO is specified: run HPO trials, log each trial
- Select best model; log final metrics against ALL TechSpec acceptance criteria
- Save model artifact to `_bmad-output/implementation-artifacts/models/`
- Log pass/fail for each acceptance criterion explicitly

Use `assets/` templates if they exist (e.g. `assets/train_template.py`).

### 3. Execute Baseline
Run baseline first — always:

    uv run python scripts/train.py --mode baseline

Log baseline metrics. The candidate model must beat this.

### 4. Execute Candidate Model

    uv run python scripts/train.py --mode candidate

### 5. Execute HPO (if specified in TechSpec)
Run hyperparameter optimization within the HPO space defined in TechSpec:

    uv run python scripts/train.py --mode hpo

Log all trials. Select best params by primary metric on validation set only.

### 6. Write Experiment Log
Write `_bmad-output/implementation-artifacts/experiment-log.md` with:
- **Run IDs**: Tracking tool run IDs or local log paths
- **Baseline Results**: metrics for each acceptance criterion
- **Best Model Results**: metrics for each acceptance criterion
- **Best Hyperparameters**: final selected values
- **Acceptance Criteria Status**: PASS / FAIL for each criterion from TechSpec
- **Training Time**: wall-clock time
- **Model Artifact Path**: path to saved model

### 7. Surface Dilemmas & Commit Gate

Before presenting and **before any git commit**:

- Identify every execution decision where two or more options existed (early stopping patience, batch size, resampling applied or not, model variant selected, etc.)
- Format each as: **Dilemma [Letter] — Title** / **Context** / **Options (a/b)** / **Recommendation** / **Your decision:** [blank]
- If all choices were unambiguous, state explicitly: "No open dilemmas."
- **Do NOT commit the experiment log or model artifacts until the user has reviewed and approved.**

### 8. Confirm and Advance
- Present experiment log summary
- State clearly: "Primary criterion ([metric] >= [threshold]): PASS / FAIL"
- On approval: commit artifacts, then say "Proceed to **Stage 7 — /ml-analysis** to evaluate results against the TechSpec contract."
- STOP and WAIT for user confirmation
