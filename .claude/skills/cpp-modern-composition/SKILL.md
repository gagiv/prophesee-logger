---
name: C++ Modern Composition
description: Replace legacy C patterns with STL, Ranges, and modern C++ abstractions (C++14+).
---
# C++ Modern Composition (Core Guidelines Section STL, CPL, ES)

This skill forces the transition from legacy "C-style" C++ to modern, declarative, and safer C++ idioms.

## Policies

### 1. STL Algorithms over Manual Loops
*   **Rule**: Never write a raw `for` or `while` loop for operations supported by `<algorithm>` or `<numeric>`.
*   **Action**: 
    - Use `std::any_of`, `std::all_of`, `std::find_if`, `std::transform`, `std::accumulate`.
    - In C++20 projects, prefer `std::ranges` versions.
*   **Rationale**: Reduces "off-by-one" errors and improves intent readability.

### 2. Eradicate C-style Casts and Macros
*   **Rule**: Ban `(type)value` and `#define` for logic/constants.
*   **Action**:
    - Use `static_cast`, `reinterpret_cast`, or `const_cast`.
    - Replace macros with `constexpr` variables or `inline` functions/templates.
*   **Rationale**: Named casts are searchable and safer; `constexpr` respects namespaces and scopes.

### 3. Universal Initialization
*   **Rule**: Prefer `{}` initialization to avoid the "Most Vexing Parse".
*   **Action**: Use `auto x = Type{args...};` or `Type x{args...};`.
*   **Rationale**: Prevents narrowing conversions (e.g., `int x{3.5}` is a compiler error, while `int x = 3.5` is not).

### 4. Zero Raw Memory Manipulation
*   **Rule**: Ban `memset`, `memcpy`, and `malloc`.
*   **Action**:
    - Use `std::fill`, `std::copy`, or `container.assign()`.
    - Use `std::vector` or `std::array` instead of raw arrays.
*   **Rationale**: Standard containers are bounds-checked (via `.at()`) and manage their own memory.

## Examples

### Before (C-style C++)
```cpp
#define MAX_BUFFER 1024
int arr[MAX_BUFFER];
memset(arr, 0, sizeof(arr));

bool found = false;
for (int i = 0; i < MAX_BUFFER; ++i) {
    if (arr[i] == (int)someFloat) {
        found = true;
        break;
    }
}
```

### After (Modern C++)
```cpp
constexpr size_t MaxBuffer = 1024;
std::array<int, MaxBuffer> arr;
arr.fill(0);

auto target = static_cast<int>(someFloat);
bool found = std::any_of(arr.begin(), arr.end(), [target](int v) {
    return v == target;
});
```
