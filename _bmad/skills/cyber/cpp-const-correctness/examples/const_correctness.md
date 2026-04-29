# Const-Correctness Examples (C++14+)

### 1. Complex Const Initialization (Lambda)
Sometimes you need to conditionally initialize a variable, but you want it to be `const` afterward.

**Modern (C++14):**
```cpp
const auto path = []() {
    if (auto env = std::getenv("APP_PATH")) {
        return std::string(env);
    }
    return std::string("/default/path");
}(); // Immediately invoked lambda
```

### 2. Const-Correct Member Functions
Ensure getters and inspectors are `const`.

```cpp
class Config {
    int timeout = 30;
public:
    // This is an inspector, must be const
    int getTimeout() const { return timeout; }
    
    // This is a mutator, cannot be const
    void setTimeout(int t) { timeout = t; }
};
```

### 3. C++14 constexpr Logic
C++14 expanded `constexpr` significantly (loops, branches allowed).

```cpp
constexpr int fibonacci(int n) {
    if (n <= 1) return n;
    int a = 0, b = 1;
    for (int i = 2; i <= n; ++i) {
        int next = a + b;
        a = b;
        b = next;
    }
    return b;
}

// Result is computed by the compiler
constexpr int fib10 = fibonacci(10);
```

### 4. Parameter Passing Guide
- `void f(int)` : Fast to copy (Value)
- `void f(const LargeObject&)` : Expensive to copy (Const Ref)
- `void f(LargeObject&)` : I will modify this (Ref)
- `void f(LargeObject&&)` : I will MOVE/OWN this (Rvalue Ref)
