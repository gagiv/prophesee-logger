---
name: cyber-immunity-estimation
description: Assess overall security posture and immunity against common attack vectors
type: skill
triggers:
  - "immunity estimation"
  - "security posture"
---

# workflow-immunity-estimation.md
# Cyber Immunity Estimation Workflow

Assesses the overall security posture and 'immunity' of the system against common attack vectors.

## Instructions
1.  **Attack Surface Analysis**: Identify all entry points (APIs, UI, SSH, 3rd party integrations).
2.  **Control Verification**:
    - Authentication/Authorization presence.
    - Encryption in transit and at rest.
    - Secret management maturity (Hardcoded vs Vault).
3.  **Posture Scoring**: Rate 1-10 on:
    - Code quality/Sanitization.
    - Dependency health.
    - Infrastructure hardening.
    - Visibility/Logging.
4.  **Immunity Report**:
    - Summarize major gaps.
    - Provide a roadmap for reach 'Immunity Level 5' (Robust).
5.  **Verification**: Recommend automated regression tests for security controls.
