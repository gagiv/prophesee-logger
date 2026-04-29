---
name: ml-infra
description: ML Infra — Set up the Python environment, install dependencies, and run a smoke test before full training
---

# ML Stage 5 — Infrastructure & Smoke Test

Validate the full pipeline end-to-end on a tiny data slice before committing to a full training run.

## Instructions

### 1. Load Context
- Read `_bmad-output/planning-artifacts/ml-techspec.md` — confirm it is LOCKED
- If TechSpec is not locked, STOP: "TechSpec must be locked before infrastructure setup. Run /ml-techspec first."
- Read `configs/ml_config.yaml` for tracking_tool setting

### 2. Environment Setup
Guide the user through (or execute if tools are available):
```bash
uv venv
uv sync
```
If new dependencies were added in architecture stage:
```bash
uv add <package1> <package2>
```

### 3. Configure Experiment Tracking
Based on `tracking_tool` in config:
- **wandb**: Verify `import wandb; wandb.login()` works. Create project if needed.
- **mlflow**: Verify `import mlflow; mlflow.set_tracking_uri(...)` works.
- **clearml**: Verify `clearml-init` has been run.
- **local**: Confirm `logs/` directory exists for CSV/JSON run logs.

### 4. Write Smoke Test Script
If `scripts/smoke_test.py` does not exist, create it:
- Load first 100 rows of training data
- Run the full preprocessing pipeline
- Instantiate the model with fixed hyperparameters from TechSpec
- Train on 80 rows, predict on 20 rows
- Log one metric to the tracking tool
- Assert the pipeline completes without error

Run the smoke test: `uv run python scripts/smoke_test.py`

### 5. Verify Outputs
Confirm:
- Environment activates cleanly (`uv run python --version`)
- All imports resolve (no ModuleNotFoundError)
- Data loads from the path specified in TechSpec
- Preprocessing pipeline runs without error
- Smoke test metric appears in tracking tool dashboard (or local log)

### 6. Confirm & Advance
- Report smoke test result: PASS or FAIL with error details
- On PASS: "Infrastructure validated. Proceed to **Stage 6 — /ml-experiment** to run the full experiment."
- On FAIL: Fix the issue before advancing. Do not proceed to full training with a broken pipeline.
- STOP and WAIT for user confirmation
