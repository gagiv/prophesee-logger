---
name: Python Dependency Management
description: Standardize Python dependency handling using uv and pip (requirements.txt).
---
# Python Dependency Management (uv & pip)

This skill ensures consistent and reproducible Python environments using modern tools like `uv` and traditional standards like `requirements.txt`.

## Policies

### 1. Modern Workflow with `uv`
*   **Rule**: Use `uv` for lightning-fast project management if available.
*   **Action**: 
    - Use `uv lock` to generate `uv.lock`.
    - Use `uv sync` to keep the environment in sync with the lockfile.
    - Declare dependencies in `pyproject.toml`.
*   **Rationale**: `uv` is significantly faster than `pip` and provides deterministic builds via lockfiles.

### 2. Standardized `requirements.txt`
*   **Rule**: If not using a modern manager, use a layered and pinned `requirements.txt` structure.
*   **Action**: 
    - **Layered**: Use `requirements.in` (top-level deps) and `requirements.txt` (fully pinned transitive deps).
    - **Environment Split**: Separate `requirements.txt` from `dev-requirements.txt`.
    - **Hashes**: Generate hashes for security (`--generate-hashes` via `pip-compile`).

### 3. Strict Version Pinning
*   **Rule**: All production dependencies must be pinned to a specific version.
*   **Action**: Use `package==1.2.3`, never `package>=1.2.3` in the final lock/txt file.

### 4. Virtual Environment Discipline
*   **Rule**: Never install dependencies globally. 
*   **Action**: 
    - Always create a `.venv` in the project root.
    - For `uv`, it handles this automatically with `uv venv` or implicitly via `uv run`.

### 5. Standard Build Systems (PEP 517/518)
*   **Rule**: Use `pyproject.toml` as the source of truth for build metadata.

## Tools of Choice
1. **uv**: (Recommended) Fastest all-in-one manager.
2. **pip-tools**: For generating pinned `requirements.txt` from `.in` files.
3. **venv**: Core standard for isolation.
