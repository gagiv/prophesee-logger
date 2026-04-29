---
name: sre-fix-deployments
description: Automated troubleshooting and fixes for common deployment issues
type: skill
triggers:
  - "fix deployments"
  - "troubleshoot deployment"
---

# workflow-fix-deployments.md
# Deployment Fix Workflow

This workflow provides automated troubleshooting steps to resolve common deployment issues.

## Instructions
1.  **Detect Issue**: Based on `check-deployment-status` output, identify the root cause.
2.  **Image issues**: If `ImagePullBackOff`, verify image name and registry secrets.
3.  **CrashLoopBackOff**:
    -   `kubectl logs {deployment_name} -n {namespace} --previous`
    -   Check for missing env vars or config maps.
4.  **Pending State**:
    -   Check node resources: `kubectl describe node`
    -   Verify PersistentVolumeClaims (PVCs).
5.  **Scaling**: If resource-related, suggest scaling or adjusting `resources.requests/limits`.
6.  **Action**: Offer to apply a fix (e.g., `kubectl apply -f ...` or `kubectl set image ...`).
