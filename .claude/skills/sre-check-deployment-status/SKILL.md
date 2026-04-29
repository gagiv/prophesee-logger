---
name: sre-check-deployment-status
description: Check deployment status across environments
type: skill
triggers:
  - "check deployment status"
  - "deployment status"
---

# workflow-check-deployment-status.md
# Deployment Status Check Workflow

This workflow guides the agent through checking the status of a specific deployment in a Kubernetes cluster.

## Parameters
- `{namespace}`: The namespace of the deployment (default: `default`)
- `{deployment_name}`: The name of the deployment to check

## Instructions
1.  **Identify Resource**: Determine the `{deployment_name}` and `{namespace}` from user input or context.
2.  **Run Diagnostics**:
    -   `kubectl get deployment {deployment_name} -n {namespace}`
    -   `kubectl describe deployment {deployment_name} -n {namespace}`
3.  **Check Pods**:
    -   `kubectl get pods -l app={deployment_name} -n {namespace}`
    -   Identify any pods that are NOT in `Running` state.
4.  **Analyze Events**:
    -   Look at the `Events` section of the `describe` output for error messages (e.g., `ImagePullBackOff`, `CrashLoopBackOff`).
5.  **Report**:
    -   Summarize the current status.
    -   Highlight any issues found.
    -   Suggest next steps (e.g., "Check logs", "Check resource limits").
