---
name: Self-Signed Certificate Generator
description: Generates secure self-signed certificates and Root CAs using OpenSSL.
---
# Self-Signed Certificate Generator

## Purpose
Automate the creation of Root CAs and self-signed certificates for internal services, local development, and testing environments.

## Instructions
1.  **Environment Check**: Ensure `openssl` is installed and available in the PATH.
2.  **Workflow Selection**:
    - **Standalone Self-Signed**: Quickest for single service testing.
    - **Root CA + Signed Cert**: Recommended for internal architectures where multiple services need to trust a single authority.
3.  **Security Standards**:
    - Key Size: Minimum 2048-bit (4096-bit preferred).
    - Hashing: SHA-256 or higher.
    - Permissions: Private keys must be set to `600`.

## Rules
- NEVER store private keys in version control.
- ALWAYS include Subject Alternative Names (SANs) for modern browser compatibility.
- Ensure the certificate Common Name (CN) matches the intended hostname.

## Usage
The skill provide both Bash (Linux/macOS) and PowerShell (Windows) scripts.

### Linux / macOS
Run `scripts/generate-cert.sh` with:
- `TYPE`: `root` or `cert`
- `NAME`: Base name for the files
- `DNS`: Primary domain/IP

Example: `bash scripts/generate-cert.sh cert my-service localhost`

### Windows (PowerShell)
Run `scripts/generate-cert.ps1` with:
- `-Type`: `root` or `cert`
- `-Name`: Base name
- `-Dns`: Primary domain/IP

Example: `.\scripts\generate-cert.ps1 -Type cert -Name my-service -Dns localhost`
