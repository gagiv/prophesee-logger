---
name: C++ Robust Interfaces
description: Enforce contract-based design and strong typing in C++ interfaces (C++14+).
---
# C++ Robust Interfaces (Core Guidelines Section I & E)

This skill ensures that C++ interfaces follow contract-based design principles to improve safety, clarity, and maintainability.

## Policies

### 1. Make Interfaces Explicit
*   **Rule**: Functions must explicitly state their requirements (pre-conditions) and guarantees (post-conditions).
*   **Action**: Use `Expects()` and `Ensures()` (from GSL) or standardized comments if GSL is unavailable.
*   **Rationale**: Detects integration bugs at the call site rather than deep in the implementation.

### 2. Strong Typing over Primitive Types
*   **Rule**: Avoid "Boolean Blindness" and `void*`.
*   **Action**: 
    - Use `enum class` for options instead of `bool`.
    - Use `std::chrono` for time instead of `int`.
    - Use specific types/structs instead of a long list of primitive arguments.

### 3. Clear Ownership and Lifetime
*   **Rule**: A raw pointer (`T*`) in an interface **must never** represent ownership.
*   **Action**: 
    - Use `gsl::not_null<T*>` for pointers that cannot be null.
    - Use `std::unique_ptr` or `std::shared_ptr` ONLY if the function is participating in ownership/lifetime management.
    - Prefer `T&` for arguments that must exist and aren't owned by the callee.

### 4. Sequence Safety
*   **Rule**: Never pass an array as a raw pointer + size.
*   **Action**:
    - Use `gsl::span<T>` (C++14/17 via GSL) or `std::span<T>` (C++20).
    - Use `std::string_view` for read-only strings.

## Examples

### Before (Fragile Interface)
```cpp
// What does 'flag' mean? Is data allowed to be null? Is it an array?
void processData(char* data, int size, bool flag);
```

### After (Robust Interface)
```cpp
#include <gsl/gsl>

enum class ProcessingMode { Fast, Thorough };

// Explicit contract: data must not be null, size is handled by span
void processData(gsl::span<const char> data, ProcessingMode mode) {
    Expects(!data.empty());
    // ...
}
```
