---
name: C++ Safe Memory Handling
description: Enforces Modern C++ practices (RAII, Smart Pointers) to prevent memory leaks, dangling pointers, and buffer overflows.
---
# C++ Safe Memory Handling

Guidelines for writing robust, memory-safe C++ code by leveraging Modern C++ features and RAII principles.

## Mandatory Policies

### 1. Smart Pointers by Default
You MUST use smart pointers for all heap allocations.
- Use `std::unique_ptr` for exclusive ownership. This is the preferred default.
- Use `std::shared_ptr` only when multiple objects share ownership of a resource.
- Use `std::weak_ptr` to break circular dependencies or for non-owning references that must be checked for validity.

### 2. Forbid raw new/delete
You MUST NOT use raw `new` and `delete` operators.
- Use `std::make_unique` (C++14+) or `std::make_shared` to allocate objects on the heap.
- Exceptions are only allowed within low-level custom container implementations, which must be encapsulated.

### 3. Prefer Value Semantics
Always prefer stack-allocated objects and value semantics over pointer-based indirection unless heap allocation is strictly necessary (e.g., polymorphism, very large objects, or dynamic lifetimes).

### 4. RAII for All Resources
Every resource (file handles, sockets, mutexes, memory) MUST be managed by an object whose constructor acquires the resource and destructor releases it. Never rely on manual cleanup blocks.

### 5. Standard Containers
NEVER use raw buffers or manually managed arrays.
- Use `std::vector` for dynamic arrays.
- Use `std::string` for text.
- Use `std::array` (C++11) for fixed-size stack arrays.
- Access elements using `.at()` if bounds checking is required for security-critical logic.

## Critical Rules
- **No Dangling Pointers**: Never return a pointer or reference to a local stack-allocated variable.
- **Rule of Zero/Five**: Follow the "Rule of Zero" (prefer components that handle their own resource management). If manual management is needed, correctly implement the "Rule of Five".
- **Nullable Checks**: Always check pointers (even smart ones) for `nullptr` before dereferencing if there is any chance they could be empty.

## Resources
- [Modern C++ Examples](file:///skills/cpp-memory-handling/examples/modern-cpp.md)
- [Smart Pointer Reference](file:///skills/cpp-memory-handling/examples/smart-pointers.md)
