# Modern Composition Examples (C++14+)

### 1. Data Transformation (Transform)
**Legacy:**
```cpp
std::vector<int> inputs = {1, 2, 3};
std::vector<int> outputs;
for (size_t i = 0; i < inputs.size(); ++i) {
    outputs.push_back(inputs[i] * 2);
}
```

**Modern (C++14):**
```cpp
std::vector<int> inputs = {1, 2, 3};
std::vector<int> outputs;
outputs.reserve(inputs.size());
std::transform(inputs.begin(), inputs.end(), std::back_inserter(outputs), 
               [](int n) { return n * 2; });
```

### 2. Summation and Reduction (Accumulate)
**Modern (C++14):**
```cpp
#include <numeric>

std::vector<double> prices = {10.5, 20.0, 5.25};
double total = std::accumulate(prices.begin(), prices.end(), 0.0);
```

### 3. Safe Narrowing Protection
**Logic:**
```cpp
double d = 7.9;
// int i{d}; // Error: narrowing conversion from 'double' to 'int'
int i = static_cast<int>(d); // Explicit and safe
```

### 4. Replacing Function Macros
**Legacy:**
```cpp
#define SQUARE(x) ((x)*(x))
```

**Modern (C++14):**
```cpp
template<typename T>
constexpr T square(T t) {
    return t * t;
}
```
