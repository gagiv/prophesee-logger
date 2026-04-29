---
name: sre-deployment-strategies
description: Guide advanced deployment strategies including Blue-Green, Canary, and Rolling Updates
type: skill
triggers:
  - "deployment strategies"
  - "canary deployment"
  - "blue green deployment"
---

# workflow-deployment-strategies.md
# Deployment Strategies Workflow

Guides on implementing and monitoring advanced deployment techniques like Blue-Green, Canary, and Rolling Updates.

## Instructions
1.  **Select Strategy**:
    -   **Rolling Update**: Standard Kubernetes strategy.
    -   **Canary**: Gradual traffic shift (requires Service Mesh or specialized CRDs like Argo Rollouts).
    -   **Blue-Green**: Instant switch between versions.
2.  **Strategy Status**:
    -   `kubectl get rollouts` (Argo Rollouts)
    -   Monitor success metrics (HTTP 2xx vs 5xx) during transition.
3.  **Health Verification**: 
    - Verify healthy startup before increasing traffic.
    - Automatically propose rollbacks if SLOs are breached.
4.  **Execution**:
    - Trigger rollout update or promotion.
