---
name: sre-gitops-status
description: Monitor GitOps synchronization state and detect drift using ArgoCD or Flux
type: skill
triggers:
  - "gitops status"
  - "drift detection"
---

# workflow-gitops-status.md
# GitOps Status & Drift Detection Workflow

This workflow monitors and reports the synchronization state between your git repository and the cluster using ArgoCD or Flux.

## Instructions
1.  **Identify Tool**: Detect if ArgoCD or Flux is in use.
2.  **Sync Status**:
    -   **ArgoCD**: `argocd app list`, `argocd app get {app_name}`
    -   **Flux**: `flux get kustomizations`, `flux get helmreleases`
3.  **Drift Detection**:
    -   Identify "OutOfSync" resources.
    -   Compare live state with desired state in git.
4.  **Action**:
    -   Offer to trigger a sync: `argocd app sync {app_name}` or `flux reconcile kustomization {name}`.
    -   Analyze reasons for permanent drift (e.g., manual cluster changes).
