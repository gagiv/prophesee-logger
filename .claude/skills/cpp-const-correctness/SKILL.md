---
name: C++ Const-Correctness & Logic
description: Enforce immutability-by-default and push logic to compile-time using constexpr (C++14+).
---
# C++ Const-Correctness & Logic (Core Guidelines Section Con & ES)

This skill ensures that C++ code is "immutable by default," reducing side effects and enabling better compiler optimizations.

## Policies

### 1. By Default, Make Objects Immutable
*   **Rule**: Declare all variables `const` unless they *must* be modified.
*   **Action**: 
    - Use `const auto x = ...;` instead of `auto x = ...;`.
    - Use `const` for function results that won't be modified.
*   **Rationale**: Prevents accidental state mutation and improves code reasoning.

### 2. Const Member Functions
*   **Rule**: Any member function that does not modify the object's observable state must be `const`.
*   **Action**: Append `const` to the function signature: `T getValue() const { ... }`.
*   **Rationale**: Necessary for calling functions on `const` objects and `const&` parameters.

### 3. Compute at Compile-Time (`constexpr`)
*   **Rule**: Prefer `constexpr` for any value or simple logic that *can* be computed at compile-time.
*   **Action**:
    - Use `constexpr` for constants.
    - Declare mathematical or configuration functions as `constexpr` (C++14 allows complex logic in `constexpr`).
*   **Rationale**: Moves work from runtime to compile-time, reducing binary size and execution time.

### 4. Consistent Parameter Logic
*   **Rule**: Avoid passing by value for large types; avoid passing by non-const reference unless it's an "out" or "in-out" parameter.
*   **Action**:
    - **In parameters**: Pass cheap types (int, double, pointers, `string_view`) by value. Pass large types by `const&`.
    - **Out/In-out parameters**: Pass by `T&`.
    - **Sinks**: Pass by `T&&` (rvalue reference).

## Examples

### Before (Mutable/Runtime Logic)
```cpp
int getMultiplier(int x) {
    return x * 10;
}

void process() {
    auto data = loadData();
    auto mult = getMultiplier(5); // mutable by accident
    data.apply(mult);
}
```

### After (Const/Compile-time Logic)
```cpp
constexpr int getMultiplier(int x) {
    return x * 10;
}

void process() {
    const auto data = loadData(); // data won't change
    constexpr auto mult = getMultiplier(5); // computed at compile time
    data.apply(mult);
}
```
