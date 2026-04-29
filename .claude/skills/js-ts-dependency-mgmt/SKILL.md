---
name: JS/TS Dependency Management
description: Standardize package management and security across NPM, Yarn, and PNPM.
---
# JS/TS Dependency Management (NPM, Yarn, PNPM)

This skill enforces best practices for managing dependencies in the JS/TS ecosystem, focusing on build stability, supply chain security, and environment hygiene.

## Policies

### 1. Build Stability & Reproducibility
*   **Rule**: Always use a lockfile (`package-lock.json`, `yarn.lock`, or `pnpm-lock.yaml`) and pin versions.
*   **Action**: 
    - Use specific versions in `package.json` (prefer `1.2.3` over `^1.2.3` for critical production apps).
    - NEVER use `*` or `latest`.
    - Always commit the lockfile to version control.

### 2. Supply Chain Security (OWASP A03:2025)
*   **Rule**: Mandatory scanning for known vulnerabilities in dependencies.
*   **Action**: 
    - Consistently run `npm audit` or `yarn audit`.
    - Ban insecure registry URLs (use HTTPS only).
    - Avoid Git-based dependencies (`"pkg": "git+https://..."`) unless from an internal/verified source.
    - Be cautious of "Typosquatting"—double-check package names before installation.

### 3. Dependency Categorization
*   **Rule**: Correctly distinguish between runtime and development dependencies.
*   **Action**: 
    - **dependencies**: Packages needed for the app to run (e.g., `express`, `react`).
    - **devDependencies**: Packages needed only for building/testing (e.g., `typescript`, `jest`, `eslint`).
    - **peerDependencies**: Libraries intended to be used with other specific versions of a host package.

### 4. Registry Hygiene
*   **Rule**: Standardize configuration via `.npmrc`.
*   **Action**: 
    - Define `save-exact=true` if pinning is the default project policy.
    - Set up scoped registries for private packages correctly.

### 5. Automated Updates
*   **Rule**: Keep dependencies current while maintaining safety.
*   **Action**: Use tools like `npm-check-updates` (ncu) to audit updates, but verify them in separate PRs/branches.

## Process Reference

| Tool | Lockfile | Installation | Audit |
| :--- | :--- | :--- | :--- |
| **NPM** | `package-lock.json` | `npm install` | `npm audit` |
| **Yarn** | `yarn.lock` | `yarn install` | `yarn audit` |
| **PNPM** | `pnpm-lock.yaml` | `pnpm install` | `pnpm audit` |
