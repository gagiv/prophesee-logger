---
name: C++ Safety-First Concurrency
description: Enforce safe multi-threading patterns using RAII locking and task-based parallelism (C++14+).
---
# C++ Safety-First Concurrency (Core Guidelines Section CP)

This skill prevents common multi-threading defects like data races, deadlocks, and shared-state corruption.

## Policies

### 1. RAII Locking Only
*   **Rule**: Never call `mutex.lock()` or `mutex.unlock()` manually.
*   **Action**: 
    - Use `std::lock_guard` for single mutexes.
    - Use `std::unique_lock` if you need deferred locking or condition variables.
    - Use `std::scoped_lock` (C++17) for multiple mutexes to avoid deadlocks.
*   **Rationale**: Ensures locks are released even if an exception is thrown.

### 2. Task-Based Parallelism
*   **Rule**: Prefer tasks (`std::async`, `std::packaged_task`, `std::future`) over raw threads (`std::thread`).
*   **Action**: Use `auto result = std::async(std::launch::async, func, args...);`
*   **Rationale**: Automates thread management and handles value return/exception propagation naturally.

### 3. Minimize Shared Mutable State
*   **Rule**: Data should ideally be either "Thread-Local" or "Read-Only".
*   **Action**:
    - Pass data to threads by value where possible.
    - Use `const` for data shared between threads.
    - Group mutexes with the data they protect (e.g., in a struct).
*   **Rationale**: If data isn't shared or isn't mutable, it cannot have a race condition.

### 4. Never Sleep/Wait without a Condition
*   **Rule**: Avoid `std::this_thread::sleep_for` for synchronization.
*   **Action**: Use `std::condition_variable` with a predicate to wait for work.
*   **Rationale**: Sleeping is inefficient and bug-prone; condition variables are precise and responsive.

## Examples

### Before (Dangerous Concurrency)
```cpp
std::mutex mtx;
int sharedData = 0;

void worker() {
    mtx.lock();
    sharedData++;
    mtx.unlock(); // What if an exception happened above?
}
```

### After (Safe Concurrency)
```cpp
std::mutex mtx;
int sharedData = 0;

void worker() {
    std::lock_guard<std::mutex> lock(mtx);
    sharedData++;
} // Lock automatically released here
```
