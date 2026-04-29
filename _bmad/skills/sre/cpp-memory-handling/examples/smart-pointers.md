# C++ Smart Pointer Reference

Guidelines for selecting and using smart pointers correctly.

## unique_ptr (Preferred Default)
- Represents **exclusive ownership**.
- Zero runtime overhead compared to raw pointers.

```cpp
#include <memory>

class Widget { /* ... */ };

void exclusive_use() {
    // Use make_unique for safety and efficiency
    auto widget = std::make_unique<Widget>();
    
    // Ownership can be moved but not copied
    std::unique_ptr<Widget> other = std::move(widget);
}
```

## shared_ptr (For Shared Ownership)
- Use only when **multiple** owners truly exist.
- Reference counting has small overhead.

```cpp
void shared_use() {
    auto shared_widget = std::make_shared<Widget>();
    
    auto owner1 = shared_widget; // Count = 2
    auto owner2 = shared_widget; // Count = 3
}
```

## weak_ptr (Breaking Cycles)
- Non-owning reference. Must be locked before use.

```cpp
void weak_use(std::weak_ptr<Widget> weak_widget) {
    if (auto shared = weak_widget.lock()) {
        // Resource is still alive
        shared->do_something();
    }
}
```
