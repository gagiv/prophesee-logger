---
name: devops-sign-docker-image
description: Cryptographically sign Docker images using certificates and Cosign
type: skill
triggers:
  - "sign docker image"
  - "docker image signing"
---

# sign-docker-image.md
# Docker Image Signing Workflow

This workflow guides the DevOps agent through the process of cryptographically signing a Docker image.

## Instructions
1.  **Select Image**: Identify the image to sign.
2.  **Get Digest**: Retrieve the immutable digest: `docker inspect --format='{{index .RepoDigests 0}}' {image_name}`.
3.  **Prepare Certificate**: Locate the certificate file provided by the user.
4.  **Execute Signing**:
    - Use the `docker-image-signing` skill.
    - Path: `skills/docker-image-signing/scripts/sign-image.sh`
    - Run: `bash skills/docker-image-signing/scripts/sign-image.sh {image_digest} {cert_file} {key_file}`
5.  **Verify**: Confirm the signature using `cosign verify`.
6.  **Report**: provide the signed image reference to the user.
