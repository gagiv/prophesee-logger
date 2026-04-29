# Naming and Organization Examples

## Naming Conventions

```cpp
// File: user_account.h
#pragma once

#include <string>
#include <string_view>
#include <optional>

namespace myapp::domain {

// Types use PascalCase
class UserAccount {
public:
    // Constants use UPPER_SNAKE_CASE
    static constexpr int MAX_NAME_LENGTH = 128;

    // Constructors and methods use camelCase
    explicit UserAccount(std::string_view userName, int accountId);

    // Const member function — does not modify the object
    [[nodiscard]] std::string_view getUserName() const;
    [[nodiscard]] int getAccountId() const;

    // Mutating method
    void setUserName(std::string_view newName);

private:
    // Private members use camelCase with trailing underscore
    std::string userName_;
    int accountId_;
};

} // namespace myapp::domain
```

## Header Organization

```cpp
// File: connection_pool.cpp

// 1. Project headers first
#include "connection_pool.h"
#include "network/socket.h"

// 2. Third-party headers
#include <boost/asio.hpp>

// 3. Standard library
#include <algorithm>
#include <chrono>
#include <memory>
#include <vector>

namespace myapp::network {
// ...
} // namespace myapp::network
```

## Forward Declarations to Reduce Coupling

```cpp
// File: request_handler.h
#pragma once

// Forward declare instead of including the full header
namespace myapp::domain {
class UserAccount;
}

namespace myapp::network {

class RequestHandler {
public:
    // Only a reference/pointer is needed here — forward declaration is sufficient
    void handle(const myapp::domain::UserAccount& user);
};

} // namespace myapp::network
```

## Namespace Usage

```cpp
// Good: deeply nested namespace matching directory structure
namespace myapp::network::http {

class Client {
    // ...
};

} // namespace myapp::network::http

// Avoid in headers — pollutes every translation unit that includes this header:
// using namespace std; // BAD in headers

// OK in .cpp files, restricted to file scope:
// using namespace myapp::network::http;
```
