---
name: Modern CMake Best Practices
description: Enforce target-based, property-oriented CMake patterns (CMake 3.0+).
---
# Modern CMake Best Practices (Target-Based Approach)

This skill ensures that CMake definitions follow the "Modern CMake" philosophy (3.0+), focusing on targets and properties rather than global variables.

## Policies

### 1. Target-Centric Philosophy
*   **Rule**: Treat targets as objects. Use `target_*` commands instead of global commands.
*   **Action**: 
    - **Forbidden**: `include_directories()`, `link_libraries()`, `add_definitions()`.
    - **Mandatory**: `target_include_directories()`, `target_link_libraries()`, `target_compile_definitions()`.
*   **Rationale**: Encapsulates requirements and prevents property leakage to unrelated targets.

### 2. Visibility Hygiene (`PUBLIC`, `PRIVATE`, `INTERFACE`)
*   **Rule**: Always specify the scope of target properties.
*   **Action**:
    - `PRIVATE`: Requirement only for building the target.
    - `INTERFACE`: Requirement only for consumers of the target.
    - `PUBLIC`: Requirement for both.
*   **Rationale**: Ensures that internal dependencies (like a private logging library) don't bleed into the usage requirements of your high-level API.

### 3. Feature-Based C++ Standards
*   **Rule**: Do not manually set `CMAKE_CXX_STANDARD` or `-std=c++XX` flags.
*   **Action**: Use `target_compile_features(my_target PUBLIC cxx_std_17)`.
*   **Rationale**: Allows CMake to handle compiler-specific flags and ensures the compiler actually supports the requested features.

### 4. No Global Variable Manipulation
*   **Rule**: Ban direct modification of `CMAKE_CXX_FLAGS` or `CMAKE_EXE_LINKER_FLAGS`.
*   **Action**: Use `target_compile_options()` for specific compiler warnings or flags.
*   **Rationale**: Global flags make it impossible to have different settings for different targets in the same project.

### 5. Namespaced Alias Targets
*   **Rule**: Always provide an alias for library targets using a namespace.
*   **Action**: `add_library(MyLib::MyLib ALIAS my_lib_target)`.
*   **Rationale**: Makes exported targets look consistent with external dependencies (like those found via `find_package`).

## Examples

### Before (Legacy Procedural CMake)
```cmake
include_directories(${PROJECT_SOURCE_DIR}/include)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -Wall")
add_library(mylib mylib.cpp)
```

### After (Modern Target-Based CMake)
```cmake
add_library(mylib mylib.cpp)

target_compile_features(mylib PUBLIC cxx_std_17)
target_compile_options(mylib PRIVATE -Wall)

target_include_directories(mylib 
    PUBLIC 
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

add_library(MyProject::MyLib ALIAS mylib)
```
