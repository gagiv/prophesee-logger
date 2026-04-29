---
name: sre-check-secrets
description: Debug and resolve Kubernetes secret issues
type: skill
triggers:
  - "check secrets"
  - "debug secrets"
---

# workflow-check-secrets.md
# Secret Debugging Workflow

This workflow helps identify and resolve problems related to Kubernetes Secrets.

## Instructions
1.  **Check Visibility**: `kubectl get secret -n {namespace}`
2.  **Verify Mounting**:
    -   Check if the deployment actually mounts the secret.
    -   `kubectl get deployment {deployment_name} -o yaml | grep secret`
3.  **Check Permissions**: Verify ServiceAccount has permissions to read the secret (RBAC).
4.  **Content Verification**: (Safety first!) Offer to check if keys exist WITHOUT displaying sensitive values unless explicitly requested.
    -   `kubectl get secret {name} -n {namespace} -o jsonpath='{.data}'`
5.  **Common Errors**: Look for "Secret not found" or "Authorization" errors in pod events.
