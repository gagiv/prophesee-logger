---
name: sre-check-system-status
description: Overall system health check across container runtimes
type: skill
triggers:
  - "check system status"
  - "system status"
---

# workflow-check-system-status.md
# Overall System Status Workflow

This workflow provides a high-level overview of the health of the container runtime and orchestration environment.

## Instructions
1.  **Detect Runtime**: Check if reachable:
    -   `kubectl cluster-info` (Kubernetes)
    -   `docker info` (Docker)
    -   `podman info` (Podman)
2.  **Resource Overview**:
    -   **K8s**: `kubectl get nodes`, `kubectl get pods -A | grep -v Running`
    -   **Docker**: `docker ps`, `docker stats --no-stream`
    -   **Podman**: `podman ps`, `podman stats --no-stream`
3.  **Cross-Platform Diagnostics**:
    -   Check for resource exhaustion (High CPU/Memory).
    -   Verify network connectivity between key services.
4.  **Summary Table**: Present a status table of all detected environments.
