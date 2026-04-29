# Modern CMake Examples

### 1. Project Structure and App
```cmake
cmake_minimum_required(VERSION 3.14)
project(MyAwesomeApp VERSION 1.0 LANGUAGES CXX)

# Use target_compile_features for the whole project standard if needed
# but target-specific is better.
add_executable(app main.cpp)

target_compile_features(app PRIVATE cxx_std_17)
target_link_libraries(app PRIVATE MyProject::Core)
```

### 2. Library with Internal/External Dependencies
```cmake
add_library(core src/core.cpp)

# Internal include dir
target_include_directories(core 
    PUBLIC  include
    PRIVATE src
)

# Link against a 3rd party library found via find_package
find_package(fmt REQUIRED)
target_link_libraries(core 
    PUBLIC  fmt::fmt
    PRIVATE Threads::Threads
)

add_library(MyProject::Core ALIAS core)
```

### 3. Proper Header-Only Library
```cmake
add_library(utils INTERFACE)

target_include_directories(utils 
    INTERFACE 
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

# Requirement: anyone using utils MUST have C++14
target_compile_features(utils INTERFACE cxx_std_14)

add_library(MyProject::Utils ALIAS utils)
```

### 4. Compiler-Specific Options Safely
```cmake
if(MSVC)
    target_compile_options(core PRIVATE /W4 /WX)
else()
    target_compile_options(core PRIVATE -Wall -Wextra -Werror)
endif()
```
