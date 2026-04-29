---
name: Docker Hardening Verification
description: Audits Docker images for security best practices, least privilege, and OpenShift compliance.
---
# Docker Hardening Verification

## Purpose
Audit Docker images to ensure they follow security best practices, specifically focusing on non-root execution and least privilege principles required for hardened clusters like OpenShift.

## Instructions
1.  **Inspect Image**: Use `docker inspect` or `podman inspect` to check metadata.
2.  **Verify User**: 
    - Ensure `USER` is defined and is NOT `root` or `0`.
    - Recommended: Use a high-numbered UID (e.g., `1001`).
3.  **Check Permissions**:
    - Ensure sensitive directories are not world-writable.
    - Check for `setuid`/`setgid` bits on binaries.
4.  **OpenShift Compliance**:
    - Verify that the image doesn't require specific UIDs if it's meant to run with an arbitrary assigned UID (OpenShift's default).
    - Check if the `/etc/passwd` entry handles arbitrary UIDs (e.g., by using `nss_wrapper` or similar).

## Rules
- Fail the audit if `USER root` is detected.
- Flag a warning if many unnecessary packages/tools are present.
- Ensure only necessary ports are exposed.

## Usage
Run `scripts/verify-hardening.sh <image_name>`
