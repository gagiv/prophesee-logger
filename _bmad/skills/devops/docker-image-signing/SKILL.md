---
name: Docker Image Signing
description: Automates the signing of Docker images using certificates and Cosign/Notary.
---
# Docker Image Signing

## Purpose
Ensure the integrity and authenticity of Docker images by signing them with a cryptographic key/certificate. This prevents unauthorized image substitution and ensures only trusted images are deployed.

## Instructions
1.  **Tool Selection**: Use `cosign` (recommended) or `notary`.
2.  **Environment Check**: Verify that the signing tool and Docker/Podman are installed.
3.  **Signing Process**:
    - Load the provided certificate/key.
    - Run the signing command against the target image (using its SHA256 digest for immutability).
4.  **Verification**: Always run a verification check immediately after signing.

## Rules
- NEVER sign images by tag alone; use the immutable digest (e.g., `image@sha256:...`).
- Private keys must be handled as secrets and never stored in the clear.
- Ensure the certificate provided is valid and not expired.

## Usage
Run the provided script in `scripts/sign-image.sh` with:
- `IMAGE`: The image reference with digest.
- `CERT`: Path to the certificate file.
- `KEY`: Path to the private key file.
- `PASSPHRASE`: (Optional) Key passphrase.
