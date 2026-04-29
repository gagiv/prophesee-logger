---
name: sre-day-2-ops
description: Day 2 operations and maintenance for long-term cluster stability
type: skill
triggers:
  - "day 2 ops"
  - "day 2 operations"
  - "maintenance"
---

# workflow-day-2-ops.md
# Day 2 Operations & Maintenance Workflow

Focuses on long-term stability, cluster-to-config verification, and periodic maintenance.

## Instructions
1.  **Config Verification**:
    - Check current cluster status against the master configuration templates.
    - Verify consistency of secrets, configmaps, and resource limits.
2.  **Resource Optimization**:
    - Review `top nodes` and `top pods`.
    - Identify over-provisioned or under-utilized resources.
3.  **Maintenance Tasks**:
    - Node drain/uncordon (safe handling).
    - Certificate rotation check.
4.  **Automation**: Propose cronjobs for periodic backups or diagnostic reports.
