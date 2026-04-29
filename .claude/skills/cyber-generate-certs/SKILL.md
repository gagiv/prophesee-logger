---
name: cyber-generate-certs
description: Generate self-signed certificates using the self-signed-cert skill
type: skill
triggers:
  - "generate certs"
  - "generate certificates"
---

# workflow-generate-certs.md
# Secure Certificate Generation Workflow

Automated workflow for generating self-signed certificates using the `self-signed-cert` skill.

## Instructions
1.  **Load Skill**: Activate the `self-signed-cert` skill instructions.
2.  **Requirement Analysis**: Determine common name (CN) and Subject Alternative Names (SANs).
3.  **Execution**:
    - **Linux/macOS**:
        - `bash scripts/generate-cert.sh root my-internal-ca`
        - `bash scripts/generate-cert.sh cert my-service localhost`
    - **Windows**:
        - `.\scripts\generate-cert.ps1 -Type root -Name my-internal-ca`
        - `.\scripts\generate-cert.ps1 -Type cert -Name my-service -Dns localhost`
4.  **Packaging**: Provide instructions for importing the cert into trust stores (OS, Browsers) or mounting in Kubernetes secrets.
5.  **Security**: Ensure private keys are stored with restricted permissions (600).
6.  **Rotation**: Offer a schedule for certificate renewal.
