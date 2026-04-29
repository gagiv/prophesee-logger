---
name: cyber-security-audit
description: Comprehensive security audit of infrastructure and application configuration
type: skill
triggers:
  - "security audit"
  - "run security audit"
---

# workflow-security-audit.md
# Comprehensive Security Audit Workflow

Deep-dive audit of infrastructure and application configuration.

## Instructions
1.  **Infrastructure Audit**:
    - **K8s**: Check for privileged containers, missing network policies, root users.
    - **Docker**: Check for exposed ports, unnecessary packages in images.
2.  **Code Audit**:
    - Static Analysis (SAST) for common patterns (SQLi, XSS).
    - Check for insecure defaults in frameworks.
3.  **Identity Audit**:
    - Review ServiceAccount permissions (RBAC).
    - Check for hard-coded credentials.
4.  **Final Recommendation**: 
    - Provide a prioritized list of hardening tasks.
    - Propose CIDCD guardrails.
