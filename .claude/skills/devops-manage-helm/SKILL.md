---
name: devops-manage-helm
description: Create and manage Helm charts and Helm umbrellas for complex systems
type: skill
triggers:
  - "manage helm"
  - "helm chart"
---

# workflow-manage-helm.md
# Helm Management Workflow

This workflow handles the creation and management of Helm charts and Helm umbrellas for complex systems.

## Instructions
1.  **Analyze System**: Determine if a single chart or an umbrella chart (multiple sub-charts) is needed.
2.  **Chart Creation**: 
    - `helm create {chart_name}`
    - Structure for disconnected environments: Ensure all chart dependencies are bundled (vendorized).
3.  **Helm Umbrella Setup**:
    - Configure `Chart.yaml` with sub-chart dependencies.
    - Setup `values.yaml` to override sub-chart values.
4.  **On-prem Optimization**:
    - Prepare `chart-save` and `chart-load` routines for air-gapped systems.
    - Configure local registry mirrors.
5.  **Validation**:
    - `helm lint {chart_path}`
    - `helm template {chart_path}`
