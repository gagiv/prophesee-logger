---
name: cyber-vault-secrets
description: Manage secrets, policies, and authentication in HashiCorp Vault
type: skill
triggers:
  - "vault secrets"
  - "manage vault"
---

# workflow-vault-secrets.md
# HashiCorp Vault Secret Management Workflow

This workflow guides the agent through managing secrets, policies, and authentication in HashiCorp Vault.

## Instructions
1.  **Check Connection**: Verify `vault status` and authentication.
2.  **Secret Creation/Update**:
    - `vault kv put secret/{path} {key}={value}`
    - Ensure secrets are never logged or echoed in plain text.
3.  **Policy Management**:
    - Define HCL policies for restricted access.
    - `vault policy write {name} {policy_file}`
4.  **Integration**:
    - Manage Kubernetes auth method: `vault auth enable kubernetes`
    - Setup Vault Agent injector configurations.
5.  **Audit**:
    - Check for expired tokens or orphaned secrets.
    - Review access logs if available.
