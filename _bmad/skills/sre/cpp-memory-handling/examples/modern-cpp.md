# Modern C++ Safe Memory Examples

Demonstrating RAII and safe resource management in modern C++.

## RAII Resource Management

```cpp
#include <iostream>
#include <fstream>
#include <vector>
#include <memory>

class FileHandler {
public:
    FileHandler(const std::string& filename) : file(filename) {
        if (!file.is_open()) throw std::runtime_error("Could not open file");
    }
    // Destructor automatically closes the file
    ~FileHandler() { if (file.is_open()) file.close(); }

    void write(const std::string& data) { file << data; }

private:
    std::ofstream file;
};

void log_data(const std::string& message) {
    // RAII handles lifetime. No manual close needed.
    FileHandler handler("app.log");
    handler.write(message);
}
```

## Vector vs Raw Arrays

```cpp
// BAD: Manual memory management
void bad_array() {
    int* arr = new int[100];
    // ... logic ...
    delete[] arr; // Manual cleanup is error-prone
}

// GOOD: Automatic memory management
void safe_vector() {
    std::vector<int> arr(100);
    // Vector manages its own heap memory. RAII cleans up at scope exit.
}
```
