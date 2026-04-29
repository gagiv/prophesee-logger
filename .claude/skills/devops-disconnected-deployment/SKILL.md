---
name: devops-disconnected-deployment
description: Deploy applications in air-gapped or restricted on-prem environments
type: skill
triggers:
  - "disconnected deployment"
  - "air-gapped deployment"
---

# workflow-disconnected-deployment.md
# Disconnected Environment Deployment Workflow

Strategies and actions for deploying applications in air-gapped or restricted on-prem environments.

## Instructions
1.  **Dependency Gathering**:
    - Identify all required container images.
    - Export images: `docker save {image_list} | gzip > images.tar.gz`
    - Package Helm charts: `helm package {chart_path}`
2.  **Target Readiness**:
    - Verify local registry availability.
    - Import images: `docker load < images.tar.gz`
3.  **Deployment**:
    - Use `--set image.repository={local_registry}/{repo}` for Helm.
    - Verify offline connectivity between components.
4.  **Troubleshooting**:
    - Check for 'ImagePullBackOff' due to incorrect registry paths.
