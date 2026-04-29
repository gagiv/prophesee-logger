---
name: Python Best Practices
description: Comprehensive Python coding standards covering PEP 8 conventions, type hinting (3.10+), modern patterns (match/case, exception groups), async, and packaging best practices. Cross-references security-focused Python skills.
---
# Python Best Practices

Coding standards for modern Python (3.10+). This skill covers language-level patterns, type hinting, async conventions, and packaging. For security and dependency hardening, see the cross-referenced skills at the end of this document.

---

## 1. Naming Conventions (PEP 8)

**Rule:** Use consistent naming to maximize readability and tooling compatibility.

| Element | Convention | Example |
|---------|-----------|---------|
| Module / package | `snake_case` | `order_service`, `user_auth` |
| Function / method | `snake_case` | `get_customer()`, `parse_response()` |
| Variable | `snake_case` | `customer_count`, `is_active` |
| Class | `PascalCase` | `CustomerService`, `OrderItem` |
| Exception | `PascalCase` + `Error`/`Exception` | `NotFoundError`, `ValidationException` |
| Constant | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT` |
| Type alias | `PascalCase` | `CustomerList`, `JsonPayload` |
| Private identifier | leading `_` | `_internal_helper()`, `_cache` |
| Dunder / magic | leading and trailing `__` | `__init__`, `__repr__` |

- Do not abbreviate names unless the abbreviation is universally understood in the domain (`url`, `id`, `db`).
- Avoid single-letter names except for short-lived loop indices (`i`, `j`) or mathematical variables.

---

## 2. Code Organization

**Rule:** Keep modules focused; make boundaries explicit via `__all__`.

- One logical concept per module; group related modules into packages with `__init__.py`.
- Declare `__all__` in any module intended for public consumption to control the exported API.
- Standard import order (enforced by `ruff`): stdlib → third-party → local. One blank line between each group.
- Use absolute imports; avoid relative imports except within a tightly coupled sub-package.

```python
# __init__.py — explicit public surface
from .service import CustomerService
from .models import Customer, Address

__all__ = ["CustomerService", "Customer", "Address"]
```

---

## 3. Type Hinting (3.10+)

**Rule:** Annotate all public function signatures and module-level variables. Use modern syntax.

### 3.1 Modern Syntax Table

| Pattern | Pre-3.10 (avoid) | Modern 3.10+ (use) |
|---------|-----------------|-------------------|
| Union types | `Union[str, int]` | `str \| int` |
| Optional | `Optional[str]` | `str \| None` |
| List | `List[str]` | `list[str]` |
| Dict | `Dict[str, int]` | `dict[str, int]` |
| Tuple | `Tuple[str, ...]` | `tuple[str, ...]` |
| Set | `Set[int]` | `set[int]` |
| Type alias (3.12+) | `MyType = list[str]` | `type MyType = list[str]` |
| Callable | `Callable[[int], str]` | `Callable[[int], str]` (unchanged) |

### 3.2 Advanced Typing Constructs

- **`TypeAlias`** (3.10): use for readability when the alias is used in multiple places but you cannot yet use the `type` statement.
- **`TypeVar`**: constrain generic functions to a family of types.
- **`ParamSpec`** (3.10): preserve parameter types in higher-order functions and decorators.
- **`Protocol`**: define structural (duck-typed) interfaces; prefer over ABC for external or loosely coupled types.
- **`TypeGuard`** (3.10): narrow types in user-defined type guard functions.
- **`Self`** (3.11): annotate methods that return the instance's own type (replaces `TypeVar("T", bound="MyClass")`).

```python
from typing import TypeVar, ParamSpec, Protocol, TypeGuard
from typing import Self  # 3.11+

T = TypeVar("T")
P = ParamSpec("P")

class Comparable(Protocol):
    def __lt__(self, other: Self) -> bool: ...

def is_string_list(val: list[object]) -> TypeGuard[list[str]]:
    return all(isinstance(x, str) for x in val)
```

### 3.3 Variable Annotations

Annotate module-level and class-level variables; omit annotations for obvious local assignments.

```python
# Module-level
MAX_CONNECTIONS: int = 100
_cache: dict[str, bytes] = {}

# Class-level (with __slots__ for memory efficiency)
class Point:
    __slots__ = ("x", "y")
    x: float
    y: float

    def __init__(self, x: float, y: float) -> None:
        self.x = x
        self.y = y
```

---

## 4. Modern Python Patterns

### 4.1 Structural Pattern Matching (3.10)

Use `match/case` to replace complex `if/elif` chains on structured data.

```python
def handle_event(event: dict) -> str:
    match event:
        case {"type": "click", "button": button}:
            return f"Clicked {button}"
        case {"type": "keypress", "key": key} if key.isalpha():
            return f"Key pressed: {key}"
        case {"type": "resize", "width": w, "height": h}:
            return f"Resized to {w}x{h}"
        case _:
            return "Unknown event"
```

Prefer `match/case` over `isinstance` chains when dispatching on data shape; avoid it for simple boolean conditions.

### 4.2 Exception Groups and `except*` (3.11)

`ExceptionGroup` allows multiple unrelated exceptions to propagate together; `except*` handles them selectively.

```python
import asyncio

async def gather_tasks() -> None:
    async with asyncio.TaskGroup() as tg:
        tg.create_task(fetch_user())
        tg.create_task(fetch_orders())
    # TaskGroup raises ExceptionGroup if any task fails

try:
    await gather_tasks()
except* ValueError as eg:
    for exc in eg.exceptions:
        print(f"Validation error: {exc}")
except* IOError as eg:
    for exc in eg.exceptions:
        print(f"IO error: {exc}")
```

### 4.3 F-String Improvements (3.12)

3.12 removes restrictions on f-string content: nested quotes, backslashes, and complex expressions are now valid.

```python
# 3.12: nested quotes and backslashes inside f-strings
name = "world"
msg = f"Hello, {name!r}"
path = f"{'\\'.join(['a', 'b', 'c'])}"  # backslash inside f-string (3.12+)
```

### 4.4 Walrus Operator (`:=`)

Use assignment expressions to eliminate redundant calls in comprehensions and loops.

```python
# With walrus — single call
if result := compute_expensive():
    process(result)

# In comprehension — filter and use in one expression
filtered = [cleaned for raw in records if (cleaned := clean(raw))]
```

Use sparingly; prefer clarity over brevity when the expression becomes hard to read.

### 4.5 `__slots__` Usage

Declare `__slots__` on data-heavy classes to reduce per-instance memory by 30-50%.

```python
class Vector:
    __slots__ = ("x", "y", "z")

    def __init__(self, x: float, y: float, z: float) -> None:
        self.x, self.y, self.z = x, y, z
```

Do not use `__slots__` on classes intended to be subclassed without explicit slot coordination.

### 4.6 Dataclasses vs attrs vs Pydantic

| Tool | When to use |
|------|-------------|
| `dataclasses` (stdlib) | Simple data containers; no validation; no serialization needed |
| `attrs` | More control than dataclasses; validators, converters, `__slots__` automation |
| `Pydantic v2` | External data (API requests, config files); runtime validation and JSON serialization |

- Use `@dataclass(frozen=True, slots=True)` for immutable value objects.
- Use Pydantic `BaseModel` at system boundaries (HTTP, config); avoid deep inside the domain layer.

```python
from dataclasses import dataclass

@dataclass(frozen=True, slots=True)
class Money:
    amount: int   # in cents
    currency: str

    def __post_init__(self) -> None:
        if self.amount < 0:
            raise ValueError("Amount must be non-negative")
```

### 4.7 Modern Stdlib Additions

**`StrEnum` (3.11+):** Combine enum membership with string behavior — no need for `.value` in comparisons or string formatting.

```python
from enum import StrEnum

class Color(StrEnum):
    RED = "red"
    GREEN = "green"
    BLUE = "blue"

assert Color.RED == "red"          # True — no .value needed
print(f"Color: {Color.GREEN}")     # "Color: green"
```

**`tomllib` (3.11+ standard library):** Read TOML files without third-party dependencies; write via `tomli_w` or `tomllib` write support in 3.13+.

```python
import tomllib

with open("pyproject.toml", "rb") as f:   # must open in binary mode
    config = tomllib.load(f)

version = config["project"]["version"]
```

**`@override` decorator (3.12+, `typing`):** Explicitly mark methods that override a base-class method; type checkers flag mismatches (wrong signature, missing base method).

```python
from typing import override

class Base:
    def process(self, data: str) -> str:
        return data

class Child(Base):
    @override
    def process(self, data: str) -> str:   # type checker verifies this overrides Base.process
        return data.strip()
```

Use `@override` on every intentional override; it serves as both documentation and a static-analysis safety net.

---

## 5. Async Patterns

**Rule:** Use `asyncio` conventions consistently; never mix sync-blocking calls into async code paths.

- Prefer `async def` for I/O-bound functions; use `asyncio.to_thread()` to run blocking code in a thread pool.
- Use `async for` and `async with` for async iteration and context management.
- Use `asyncio.TaskGroup` (3.11) over `asyncio.gather` for structured concurrency with proper error propagation.
- Never call `asyncio.sleep(0)` in a busy loop — use proper awaitable primitives.
- Avoid mixing `asyncio.run()` inside an already-running event loop; use `asyncio.get_event_loop().run_until_complete()` only in legacy contexts.

```python
import asyncio
from pathlib import Path

async def fetch_all(urls: list[str]) -> list[bytes]:
    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(fetch(url)) for url in urls]
    return [t.result() for t in tasks]

async def read_file_async(path: str) -> str:
    # Run blocking I/O in a thread pool — pass callable, not result
    return await asyncio.to_thread(Path(path).read_text)
```

---

## 6. Packaging Best Practices

**Rule:** Use `pyproject.toml` as the single configuration file; use `src/` layout.

### 6.1 Project Layout

```
my-project/
  src/
    my_package/
      __init__.py
      service.py
  tests/
    test_service.py
  pyproject.toml
  README.md
```

The `src/` layout prevents accidental imports of the development tree; tests always import the installed package.

### 6.2 pyproject.toml (PEP 621)

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "my-package"
version = "1.0.0"
requires-python = ">=3.10"
dependencies = [
    "httpx>=0.27",
    "pydantic>=2.0",
]

[project.optional-dependencies]
dev = ["pytest>=8", "ruff", "mypy"]

[tool.ruff]
line-length = 100
target-version = "py310"

[tool.mypy]
python_version = "3.10"
strict = true
```

### 6.3 Recommended Toolchain

| Tool | Purpose | Replaces |
|------|---------|---------|
| `uv` | Package manager and virtual env (Rust-based, fast) | `pip` + `venv` + `pip-tools` |
| `ruff` | Linting and formatting | `flake8` + `black` + `isort` |
| `mypy` or `pyright` | Static type checking | — |
| `pytest` | Testing framework | `unittest` |
| `hatchling` | Build backend | `setuptools` |

- Use `uv sync` to install from lockfile; `uv add <dep>` to add dependencies with automatic lockfile update.
- Run `ruff check . --fix` and `ruff format .` in CI to enforce formatting and linting.
- Enable `mypy --strict` or equivalent `pyright` settings in CI.

### 6.4 Virtual Environments

Use `uv venv` to create isolated environments; name the directory `.venv` (the conventional default recognized by editors and CI tools).

```bash
uv venv            # creates .venv/ in the current directory
source .venv/bin/activate   # Linux/macOS
.venv\Scripts\activate      # Windows
uv sync            # install dependencies from lockfile into .venv
```

- Commit the `uv.lock` lockfile; add `.venv/` to `.gitignore`.
- Prefer `uv run <command>` in CI to avoid activating the environment explicitly.

---

## 7. Python Version Awareness (3.13 forward-looking)

**Python 3.13 (awareness only — not yet required):**

- **Free-threaded mode** (`--disable-gil` / `python3.13t`): removes the GIL, enabling true multi-core parallelism in CPython. Do not design code around GIL removal yet; avoid shared mutable state as a general practice.
- **Improved error messages**: Python 3.13 continues the trend of actionable `TypeError`/`NameError` messages — write tests that do not over-assert on exception message strings.

---

## Cross-References

This skill covers broad Python coding standards. For deeper coverage of specialized domains, refer to:

> For Python security best practices (OWASP 2025 aligned), see the `python-security-skill`.
> For dependency security, supply chain protection, and lockfile management, see the `python-dependency-mgmt` skill.
