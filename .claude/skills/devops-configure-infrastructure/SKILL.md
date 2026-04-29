---
name: devops-configure-infrastructure
description: Define and configure core infrastructure components in Kubernetes
type: skill
triggers:
  - "configure infrastructure"
  - "infrastructure configuration"
---

# workflow-configure-infrastructure.md
# Infrastructure Configuration Workflow

This workflow focuses on defining and configuring core infrastructure components in a Kubernetes environment.

## Instructions
1.  **Storage Definition**:
    - Define `PersistentVolume` (PV) with appropriate access modes and storage classes.
    - Define `PersistentVolumeClaim` (PVC) for application workloads.
2.  **Networking**:
    - Configure `Service` type `LoadBalancer` or `Ingress` controllers.
    - Define `NetworkPolicies` for secure communication.
3.  **Disconnected Environments**:
    - Provide templates for local storage provisioners (e.g., hostPath, Local Persistent Volumes).
    - Configure static IP assignments for on-prem load balancers.
4.  **Validation**:
    - Verify binding status: `kubectl get pv,pvc`
    - Verify endpoint availability: `kubectl get endpoints`
