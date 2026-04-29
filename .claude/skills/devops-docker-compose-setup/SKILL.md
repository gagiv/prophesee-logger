---
name: devops-docker-compose-setup
description: Multi-container orchestration using Docker Compose for development and on-prem
type: skill
triggers:
  - "docker compose setup"
  - "docker compose"
---

# workflow-docker-compose-setup.md
# Docker Compose Management Workflow

This workflow handles multi-container orchestration using Docker Compose, optimized for development and on-prem deployments.

## Instructions
1.  **Define Services**: Map application components to Docker services.
2.  **Environment Sync**: Setup `.env` file management for different environments (on-prem, dev).
3.  **Disconnected Operations**:
    - Build images with `--pull=false` if registry is unavailable.
    - Use local image tags.
4.  **Orchestration**:
    - Setup dependencies with `depends_on` and health checks.
    - Configure volumes for persistence.
5.  **Execution**:
    - `docker-compose up -d`
    - `docker-compose ps`
