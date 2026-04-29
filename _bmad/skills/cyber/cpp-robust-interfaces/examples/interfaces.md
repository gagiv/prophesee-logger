# Robust Interface Examples (C++14+)

### 1. Avoiding Boolean Blindness
**Incorrect:**
```cpp
void setWindowVisible(bool visible, bool animate);
// Call site: setWindowVisible(true, false); // What is false?
```

**Correct (C++14):**
```cpp
enum class Visibility { Visible, Hidden };
enum class Animation { Enabled, Disabled };

void setWindowVisible(Visibility v, Animation a);
// Call site: setWindowVisible(Visibility::Visible, Animation::Disabled);
```

### 2. Contract-Based Validation
Using GSL (Guidelines Support Library) style:

```cpp
#include <gsl/gsl>

class User {
public:
    // Ensure name is never null or empty
    void setName(gsl::not_null<const char*> name) {
        Expects(std::strlen(name) > 0);
        this->name = name;
    }
private:
    std::string name;
};
```

### 3. Safe Sequences with Span
Replaces pointer + length pairs which are prone to buffer overflows.

```cpp
#include <gsl/gsl> // Use gsl::span in C++14

float calculateAverage(gsl::span<const float> values) {
    Expects(!values.empty());
    
    float sum = 0.0f;
    for (float v : values) {
        sum += v;
    }
    return sum / values.size();
}

// Usage:
// float arr[] = {1, 2, 3};
// calculateAverage(arr); // Automatic conversion to span
```
