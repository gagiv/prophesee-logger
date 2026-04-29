---
name: Python Security Best Practices
description: Enforce secure Python coding standards following OWASP Top 10 2025.
---
# Python Security Best Practices (OWASP 2025 aligned)

This skill provides mandatory security guardrails for Python applications, ensuring protection against common vulnerabilities and alignment with OWASP Top 10 standards.

## Policies

### 1. Zero Insecure Function Usage
*   **Rule**: Ban functions that allow arbitrary code execution or insecure OS commands.
*   **Action**: 
    - NEVER use `eval()` or `exec()`.
    - Avoid `subprocess.run(..., shell=True)`. Use lists for commands instead.
    - Avoid `yaml.load()` without specifying a loader (use `yaml.safe_load()`).

### 2. Secure Data Serialization
*   **Rule**: Protect against insecure deserialization.
*   - **Action**: 
    - NEVER use `pickle` for untrusted data. Use `json` instead.
    - Be cautious with `xml.etree.ElementTree` (vulnerable to XXE); use `defusedxml` if possible.

### 3. Injection Prevention (A05:2025)
*   **Rule**: Use parameterized queries for all database and API interactions.
*   **Action**: 
    - Never use f-strings or `.format()` for SQL queries.
    - Use ORM features (Django ORM, SQLAlchemy) or parameter placeholders (`%s`, `?`).

### 4. Cryptographic Standards (A04:2025)
*   **Rule**: Use modern, collision-resistant hashing and encryption.
*   **Action**: 
    - Use `hashlib.sha256()` or better. Ban MD5 and SHA1.
    - Use `secrets` module for tokens/passwords, not `random`.

### 5. Dependency Integrity (A03:2025)
*   **Rule**: Lock dependencies and scan for known vulnerabilities.
*   **Action**: 
    - Always commit lockfiles (`uv.lock`, `poetry.lock`, or `requirements.txt` with hashes).
    - Periodically run `pip-audit` or `safety`.

### 6. Secure Error Handling (A10:2025)
*   **Rule**: Do not leak sensitive information in tracebacks or logs.
*   **Action**: 
    - Never log `pydantic` models or raw request bodies containing PII/Secrets.
    - Use generic error messages for end-users while keeping detailed logs internally.

## Python Security Mapping (OWASP 2025)

| Category | Python Vulnerability | Secure Alternative |
| :--- | :--- | :--- |
| **A01: Access Control** | URL hijacking in `requests` | Validate redirect targets |
| **A02: Configuration** | Debug mode in Flask/Django | `DEBUG = False` in production |
| **A03: Supply Chain** | Typosquatting/Old deps | Pin versions + `pip-audit` |
| **A05: Injection** | `os.system()` / RAW SQL | `subprocess.run()` list / ORM |
| **A08: Integrity** | `pickle.load()` | `json.loads()` |
