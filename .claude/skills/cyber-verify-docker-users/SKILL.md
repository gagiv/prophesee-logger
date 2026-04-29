---
name: cyber-verify-docker-users
description: Audit Docker images for proper user management and least privilege
type: skill
triggers:
  - "verify docker users"
  - "docker user audit"
---

# verify-docker-users.md
# Docker User & Hardening Verification Workflow

This workflow guides the Cyber agent through auditing Docker images for proper user management and least privilege.

## Instructions
1.  **Inspect Metadata**:
    - Use the `docker-hardening-verification` skill.
    - Run: `bash skills/docker-hardening-verification/scripts/verify-hardening.sh {image_name}`.
2.  **Audit Result Analysis**:
    - **UID Check**: Confirm the defined user is non-zero.
    - **Permissive Files**: Scan for world-writable files in common paths (/tmp, /etc, /var).
3.  **Governance Check**: Ensure the image follows OpenShift/hardened cluster requirements (no root, arbitrary UID support).
4.  **Reporting**: provide a high-level summary of hardening quality and mandatory fixes.
