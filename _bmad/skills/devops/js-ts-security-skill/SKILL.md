---
name: JS/TS Security
description: Verify security of JavaScript and TypeScript codebases against OWASP Top 10 2025 standards
---

# JS/TS Security Skill

This skill provides a set of tools and best practices to ensure that JavaScript and TypeScript code (both client-side and server-side) is secure and compliant with the latest security standards, specifically the **OWASP Top 10 2025**.

## When to Use
- Before committing code to a repository.
- During a security audit of an existing codebase.
- When adding new dependencies or updating CI/CD pipelines.
- When implementing critical features like authentication, authorization, or error handling.

## Security Checks (OWASP 2025 Mapping)

### A01:2025 - Broken Access Control
- Verification of authorization logic.
- **SSRF (Server-Side Request Forgery)**: Detecting unvalidated URL fetching in `fetch`, `axios`, `http.get`.

### A02:2025 - Security Misconfiguration
- Auditing configuration files (`.env`, `docker-compose.yml`).
- Checking for insecure defaults and exposed debug endpoints.

### A03:2025 - Software Supply Chain Failures
- **NEW**: Focusing on dependency integrity.
- Verification of lockfiles (`package-lock.json`, `yarn.lock`).
- Checking for insecure registry URLs (HTTP).

### A04:2025 - Cryptographic Failures
- Detecting weak hashing (MD5, SHA1).
- Checking for insecure randomness (`Math.random()`).

### A05:2025 - Injection
- Expanded detection for OS commands (`child_process.exec`), SQL injection, and NoSQL injection.

### A06:2025 - Insecure Design
- Documentation on secure design principles (e.g., Fail Secure, Least Privilege).

### A07:2025 - Authentication Failures
- Checking for insecure cookies (`httpOnly: false`).
- Hardcoded credentials and weak session management.

### A08:2025 - Software or Data Integrity Failures
- Detecting unsafe deserialization (`unserialize`, `JSON.parse` of untrusted input).

### A09:2025 - Logging & Alerting Failures
- Identifying lack of security logging.
- Empty catch blocks that swallow security errors.

### A10:2025 - Mishandling of Exceptional Conditions
- **NEW**: Identifying insecure error handling.
- Detecting empty `catch` blocks and `console.log(err)` in critical paths.

## Usage

### Run OWASP 2025 Security Scan
The primary method for automated security verification is the `verify-security.sh` script. This script executes multiple scanning phases (SAST, Audit, Secret Scanning) and maps all findings directly to OWASP 2025 categories.

Run the scan from the project root:
```bash
/d/Code/agents/skills/js-ts-security-skill/scripts/verify-security.sh
```
