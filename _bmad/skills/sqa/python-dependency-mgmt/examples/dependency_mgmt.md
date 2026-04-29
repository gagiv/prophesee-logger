# Python Dependency Management Examples

### 1. Modern Workspace with `uv`
**pyproject.toml:**
```toml
[project]
name = "my-app"
version = "0.1.0"
dependencies = [
    "requests==2.31.0",
    "structlog>=24.1.0",
]

[tool.uv]
managed = true
```

**Commands:**
```bash
# Add a new dependency and update lockfile
uv add pandas

# Run a script within the isolated environment
uv run main.py

# Sync environment with the lockfile
uv sync
```

### 2. Traditional `requirements.txt` (pip-tools)
**requirements.in:**
```text
flask
psycopg2-binary
```

**Workflow:**
```bash
# Generate pinned requirements.txt with hashes
pip-compile --generate-hashes requirements.in

# Install exactly what is pinned
pip install -r requirements.txt
```

### 3. Development vs Production Deps
**dev-requirements.in:**
```text
-c requirements.txt
pytest
black
ruff
```

```bash
# Generate dev-requirements.txt
pip-compile dev-requirements.in
```

### 4. Virtual Environment Setup (Standard)
```bash
python -m venv .venv
# Linux/macOS
source .venv/bin/activate
# Windows
.venv\Scripts\activate
```
