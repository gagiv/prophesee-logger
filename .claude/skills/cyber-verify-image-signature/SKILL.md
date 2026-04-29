---
name: cyber-verify-image-signature
description: Verify Docker image signatures for supply chain security
type: skill
triggers:
  - "verify image signature"
  - "check image signature"
---

# verify-image-signature.md
# Docker Image Signature Verification Workflow

This workflow guides the Cyber agent through verifying that a Docker image has been properly signed.

## Instructions
1.  **Identify Image**: Get the image name and digest.
2.  **Locate Public Key**: Obtain the public key or certificate used for signing.
3.  **Execute Verification**:
    - Use `cosign verify --key {public_key} {image_digest}`.
    - Check the output for valid signatures.
4.  **Policy Compliance**: Verify if the signing entity (certificate CN) matches the expected trusted authorities.
5.  **Report**: Alert the user if the image is unsigned or the signature is invalid.
