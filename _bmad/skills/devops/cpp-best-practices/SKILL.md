---
name: C++ Best Practices
description: Comprehensive C++ coding standards covering naming conventions, modern C++ idioms (C++17/20/23), error handling, and build guidelines. Cross-references domain-specific C++ skills for deep-dives.
---
# C++ Best Practices

This skill establishes baseline C++ coding standards applicable to modern C++ projects (C++17/20/23). It covers naming conventions, code organization, memory management, error handling, modern idioms, and build guidelines. Domain-specific topics are handled by dedicated sibling skills — this skill provides the umbrella foundation and cross-references those skills where relevant.

---

## 1. Naming Conventions

### Rule: Use consistent case styles by identifier type.

| Identifier | Convention | Example |
|---|---|---|
| Types (class, struct, enum, alias) | `PascalCase` | `UserAccount`, `ConnectionPool` |
| Functions and methods | `camelCase` | `getUserName()`, `processData()` |
| Variables (local, parameter) | `camelCase` | `userName`, `itemCount` |
| Member variables (private) | `camelCase_` with trailing underscore | `name_`, `bufferSize_` |
| Constants and enumerators | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT` |
| Macros | `UPPER_SNAKE_CASE` | `ASSERT_NOT_NULL`, `LOG_LEVEL` |
| Namespaces | `lowercase_snake_case` | `network::http`, `core::utils` |
| Template parameters | `PascalCase` | `template<typename ValueType>` |
| Files | `snake_case.cpp` / `snake_case.h` | `user_account.cpp`, `connection_pool.h` |

**Action:** Do not abbreviate unless the abbreviation is universally understood in the domain (e.g., `id`, `url`, `http`). Avoid single-letter names except for loop indices (`i`, `j`, `k`) and template parameters (`T`, `U`).

---

## 2. Code Organization

### Rule: One primary type per header file; name the file after the type.

**Action:**
- Place class declarations in `.h` files; place definitions in `.cpp` files.
- Use `#pragma once` at the top of every header (preferred over include guards in new code).
- Group headers: project headers first, then third-party, then standard library — each group separated by a blank line.
- Keep headers self-contained: every header must include what it needs to compile in isolation.

### Rule: Use namespaces to model the logical module hierarchy.

**Action:**
- Prefer deeply nested namespaces over flat ones: `namespace myapp::network::http { ... }`.
- Avoid `using namespace` in header files. Restrict `using namespace std;` to `.cpp` file scope if used at all.
- Use `inline namespace` only for versioning public APIs (e.g., `inline namespace v2`).

### Rule: Keep translation units small and focused.

**Action:**
- Limit headers to declarations and inline functions under ~20 lines.
- Move non-trivial inline logic into `.inl` files included at the bottom of the header.
- Use forward declarations in headers to reduce compilation dependencies.

---

## 3. Memory Management

**Action:** Apply RAII (Resource Acquisition Is Initialization) for all resources. Never allocate resources without an owning object responsible for releasing them.

Key policies:
- Prefer stack allocation. Use heap allocation only when lifetime exceeds scope or size is dynamic.
- Use `std::make_unique<T>()` for exclusive ownership; `std::make_shared<T>()` only when shared ownership is truly required.
- Never use raw `new` or `delete` outside of a low-level container implementation.
- Use standard containers (`std::vector`, `std::string`, `std::array`) instead of raw arrays and buffers.

> For detailed memory management patterns, see the `cpp-memory-handling` skill if installed.
> It covers RAII, smart pointer selection, Rule of Zero/Five, and ownership transfer patterns.

---

## 4. Modern C++ Idioms

### C++17

**Action:** Use these C++17 features where they improve clarity:

- **Structured bindings**: `auto [key, value] = myMap.begin()->first;` — prefer over `first`/`second`.
- **`std::optional<T>`**: Return optional values instead of `nullptr` sentinels or output parameters.
- **`std::variant<T...>`**: Model sum types explicitly instead of void pointers or inheritance hierarchies.
- **`if constexpr`**: Replace SFINAE with readable compile-time branching in templates.
- **Fold expressions**: Simplify variadic template expansions: `(args + ... + 0)`.
- **`std::filesystem`**: Use `std::filesystem::path` for all file path manipulation; never concatenate paths with string operations.
- **Class template argument deduction (CTAD)**: Write `std::pair p{1, "hello"s}` instead of `std::make_pair`.

### C++20

**Action:** Adopt C++20 features when targeting C++20 or later:

- **Concepts**: Constrain template parameters with `requires` clauses instead of relying on substitution failures.
  ```cpp
  template<std::integral T>
  T clamp(T value, T lo, T hi);
  ```
- **Ranges**: Replace hand-written loops over containers with range adaptors (`std::views::filter`, `std::views::transform`, `std::ranges::sort`).
- **`std::format`**: Replace `printf`/`sprintf`/`ostringstream` with `std::format("{} has {} items", name, count)`.
- **Three-way comparison (`<=>`)**:  Define `operator<=>` to implement all comparison operators at once.
- **Coroutines**: Use for asynchronous I/O and generator patterns; avoid raw `co_await` boilerplate — prefer a library abstraction (e.g., cppcoro, Asio).
- **Modules**: New projects targeting C++20+ should plan for module adoption; existing headers remain valid but prefer named module interface units for new public APIs.

### C++23

**Action:** Use C++23 features when the toolchain supports them:

- **`std::expected<T, E>`**: Return `expected<Result, ErrorCode>` from functions that can fail, eliminating exception-based control flow for expected failures.
- **`std::print` / `std::println`**: Replace `std::cout` for formatted output.
- **Deducing `this`**: Use explicit object parameter `this` to eliminate CRTP boilerplate and write recursive lambdas cleanly.
- **`std::flat_map` / `std::flat_set`**: Prefer over `std::map`/`std::set` for small to medium sorted collections requiring cache-friendly iteration.

---

## 5. Const-Correctness

### Rule: Make everything const by default; relax only when mutation is required.

**Action:**
- Declare local variables `const auto` unless reassignment is needed.
- Mark member functions `const` whenever they do not modify observable state.
- Use `constexpr` for values and functions computable at compile-time.
- Pass large types by `const&`; pass cheap types (scalars, pointers, `string_view`) by value.
- Never return `const` by value from a function — it prevents move semantics.

> For detailed const-correctness policies, see the `cpp-const-correctness` skill if installed.

---

## 6. Error Handling

### Rule: Choose an error-handling strategy per layer and apply it consistently.

| Context | Preferred Mechanism |
|---|---|
| Programmer errors (precondition violations) | `assert()` or contracts (C++26); never exceptions |
| Expected failures in library APIs | `std::expected<T, E>` (C++23) or error codes |
| Exceptional conditions that prevent normal flow | Exceptions (`std::runtime_error` hierarchy) |
| Async / coroutine code | Error channels in the coroutine framework |

**Action:**
- Mark functions that cannot throw `noexcept`. Destructors, move constructors, and swap functions MUST be `noexcept`.
- Catch exceptions by `const&` only: `catch (const std::exception& e)`.
- Never catch `...` (catch-all) except at top-level handlers or plugin boundaries.
- Do not use exceptions for control flow or expected failure paths — use `std::optional` or `std::expected` instead.

---

## 7. Class Design

### Rule: Follow the Rule of Zero.

**Action:**
- Design classes so that the compiler-generated special members (copy/move constructor, copy/move assignment, destructor) are correct by default.
- Use RAII members (smart pointers, standard containers) to make this automatic.
- If you must define any special member function, define all five (destructor, copy ctor, move ctor, copy assign, move assign) — the Rule of Five.

### Rule: Prefer composition over inheritance for code reuse.

**Action:**
- Use `public` inheritance only to model true "is-a" relationships with polymorphic behavior.
- Mark base class destructors `virtual` when the class is intended to be used polymorphically.
- Mark overriding methods `override`; mark non-overridable methods `final`.
- Prefer free functions over member functions for operations that do not require access to private state.
- Mark factory functions and pure query methods with `[[nodiscard]]` (C++17) to turn silent result-discard into a compiler warning.

> For detailed composition patterns and elimination of legacy C patterns, see the `cpp-modern-composition` skill if installed.
> For interface design contracts and strong typing, see the `cpp-robust-interfaces` skill if installed.

---

## 8. Concurrency

### Rule: Never share mutable state between threads without synchronization.

**Action:**
- Prefer task-based concurrency (`std::async`, thread pools) over raw `std::thread`. Always specify `std::launch::async` explicitly — `std::async` without a launch policy may run deferred (synchronously on the calling thread), which defeats the purpose of async execution.
- Protect shared data with `std::mutex`; always use `std::lock_guard` or `std::unique_lock` — never call `lock()`/`unlock()` manually.
- Declare data accessed from multiple threads as `std::atomic<T>` when appropriate (single-variable synchronization, counters, flags).
- Avoid `volatile` for inter-thread communication; use `std::atomic` instead.

> For detailed concurrency safety patterns, see the `cpp-concurrency-safety` skill if installed.

---

## 9. Build and Compilation Guidelines

### Rule: Enable high-warning levels and treat warnings as errors.

**Action:**
- GCC/Clang: `-Wall -Wextra -Wpedantic -Wconversion -Wshadow -Werror`
- MSVC: `/W4 /WX`
- Do not disable warnings without an inline comment explaining the rationale.

### Rule: Use sanitizers during development and CI.

| Sanitizer | Flag (GCC/Clang) | Detects |
|---|---|---|
| AddressSanitizer | `-fsanitize=address` | Buffer overflows, use-after-free |
| UndefinedBehaviorSanitizer | `-fsanitize=undefined` | UB (integer overflow, null deref) |
| ThreadSanitizer | `-fsanitize=thread` | Data races |

**Action:** Enable at least `-fsanitize=address,undefined` in Debug and CI builds. Do not ship sanitizer builds.

### Rule: Set the C++ standard explicitly.

**Action:** Always specify `-std=c++17` (or higher) explicitly. Do not rely on compiler defaults, which differ across vendors.

> For CMake-specific build configuration patterns, see the `cmake-best-practices` skill if installed.
> It covers target-based CMake, `target_compile_options`, and compiler flag propagation.

---

## 10. General Code Quality

### Rule: Prefer clarity over cleverness.

**Action:**
- Write code for the next reader, not the compiler. Compilers optimize well; humans struggle with obfuscation.
- Extract magic numbers into named `constexpr` constants.
- Prefer algorithms from `<algorithm>` and `<numeric>` over hand-written loops.
- Limit function length to what fits on one screen (~50 lines). If longer, extract named helper functions.
- Avoid deep nesting (more than 3 levels). Use early-return and guard clauses to flatten control flow.

### Rule: Use `auto` judiciously.

**Action:**
- Use `auto` when the type is verbose and already clear from context (e.g., iterators, lambda types, CTAD).
- Do not use `auto` when the type communicates intent and is not immediately obvious from the right-hand side.
- Always specify `auto&` or `const auto&` for range-for loops over containers of non-trivial types.

---

## Resources

- [Naming and Organization Examples](examples/naming-and-organization.md)
- [Modern C++ Idioms Examples](examples/modern-idioms.md)
