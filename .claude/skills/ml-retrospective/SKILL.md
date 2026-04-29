---
name: ml-retrospective
description: ML Retrospective - Capture learnings, document what worked and what failed, and produce a reusable knowledge artifact
---

# ML Stage 8 - Retrospective

Close the experiment loop. Document learnings so the next experiment starts smarter.

## Instructions

### 1. Load Context
- Read all artifacts in `_bmad-output/planning-artifacts/`
- Read all artifacts in `_bmad-output/implementation-artifacts/`
- Reconstruct the full lifecycle: what was hypothesized, what was built, what happened

### 2. Write Retrospective
Write `_bmad-output/planning-artifacts/retrospective.md` with these sections:

#### Hypothesis Outcome
- **Original Hypothesis** (from research-thesis.md)
- **Outcome**: CONFIRMED / REFUTED / PARTIALLY CONFIRMED
- **Evidence**: Key metrics that support the conclusion

#### What Worked Well
- Data characteristics that made modelling tractable
- Preprocessing decisions that improved results
- Architecture choices that were validated
- Process decisions that saved time

#### What Did Not Work
- Approaches attempted and discarded (with evidence, not opinion)
- Data quality issues that were not caught in EDA
- Assumptions from the PRD that were wrong
- HPO strategies that did not yield improvement

#### Failure Cost Reflection
- Actual FP/FN distribution in best model
- Whether the failure cost tradeoff met business expectations
- Recommended threshold for production use (with cost justification)

#### Technical Debt
- Known shortcuts taken and their risk
- Features excluded that may still have signal
- Data collection improvements recommended for next iteration

#### Recommended Next Experiments
- Top 3 actionable hypotheses for the next iteration, ranked by expected improvement
- Each with: hypothesis, required data, estimated effort

#### Process Improvements
- Anything in the Demerzel protocol that should be adjusted for this domain
- Data pipeline improvements needed before next experiment

### 3. Archive Experiment
- Confirm all artifacts are saved under `_bmad-output/`
- Confirm model artifact is saved under `_bmad-output/implementation-artifacts/models/`
- Confirm experiment is logged and accessible in tracking tool

### 4. Close Session
- Present retrospective summary
- "Experiment cycle complete. All artifacts are saved in `_bmad-output/`. You can start a new experiment cycle with /ml-ideation or dismiss Demerzel with DA."
- STOP and WAIT for user input
