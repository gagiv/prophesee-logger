# Modern C++ Idioms Examples

## C++17: Structured Bindings and std::optional

```cpp
#include <map>
#include <optional>
#include <string>

// Structured bindings — prefer over .first/.second
std::map<std::string, int> scores = {{"Alice", 95}, {"Bob", 87}};
for (const auto& [name, score] : scores) {
    // name and score are directly named — no .first/.second
}

// std::optional — no more nullptr sentinels or bool out-parameters
std::optional<std::string> findUser(int id) {
    if (id == 42) return "Alice";
    return std::nullopt; // Not found — explicit, type-safe
}

void example() {
    if (const auto user = findUser(42); user.has_value()) {
        // C++17 if-with-initializer keeps 'user' scoped tightly
        doSomethingWith(*user);
    }
}
```

## C++17: std::variant for Sum Types

```cpp
#include <variant>
#include <string>

struct Success { std::string message; };
struct NotFound { int id; };
struct PermissionDenied { std::string reason; };

using LookupResult = std::variant<Success, NotFound, PermissionDenied>;

LookupResult lookup(int id) {
    if (id == 0) return NotFound{id};
    if (id < 0) return PermissionDenied{"negative ids reserved"};
    return Success{"found item " + std::to_string(id)};
}

void handle(const LookupResult& result) {
    std::visit([](const auto& v) {
        using T = std::decay_t<decltype(v)>;
        if constexpr (std::is_same_v<T, Success>) {
            log(v.message);
        } else if constexpr (std::is_same_v<T, NotFound>) {
            log("not found: " + std::to_string(v.id));
        } else {
            log("denied: " + v.reason);
        }
    }, result);
}
```

## C++20: Concepts

```cpp
#include <concepts>
#include <iostream>
#include <vector>

// Before concepts: SFINAE was required — hard to read and debug
// After concepts: clear, readable constraints

template<std::integral T>
T clamp(T value, T lo, T hi) {
    return std::max(lo, std::min(value, hi));
}

// Custom concept
template<typename T>
concept Printable = requires(T t) {
    { t.toString() } -> std::convertible_to<std::string>;
};

template<Printable T>
void printAll(const std::vector<T>& items) {
    for (const auto& item : items) {
        std::cout << item.toString() << '\n';
    }
}
```

## C++20: Ranges

```cpp
#include <algorithm>
#include <iostream>
#include <ranges>
#include <vector>
#include <string>

void modernRanges() {
    std::vector<int> numbers = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

    // Chain range adaptors — lazy, composable, readable
    auto evenSquares = numbers
        | std::views::filter([](int n) { return n % 2 == 0; })
        | std::views::transform([](int n) { return n * n; });

    // Iterate result without materializing an intermediate container
    for (int v : evenSquares) {
        std::cout << v << '\n'; // 4 16 36 64 100
    }

    // Sorting with ranges — no begin/end iterator boilerplate
    std::vector<std::string> names = {"Charlie", "Alice", "Bob"};
    std::ranges::sort(names);
}
```

## C++23: std::expected for Error Handling

```cpp
#include <expected>
#include <string>
#include <fstream>

enum class ParseError { InvalidFormat, EmptyInput, Overflow };

// Return expected<T, E> instead of throwing for anticipated failures
std::expected<int, ParseError> parsePositiveInt(std::string_view input) {
    if (input.empty()) return std::unexpected(ParseError::EmptyInput);
    int result = 0;
    for (char c : input) {
        if (c < '0' || c > '9') return std::unexpected(ParseError::InvalidFormat);
        result = result * 10 + (c - '0');
        if (result < 0) return std::unexpected(ParseError::Overflow);
    }
    return result;
}

void usage() {
    const auto result = parsePositiveInt("123");
    if (result) {
        std::println("Parsed: {}", *result);
    } else {
        // Handle error without try/catch — expected path, not exceptional
        switch (result.error()) {
            case ParseError::InvalidFormat: std::println("invalid format"); break;
            case ParseError::EmptyInput:    std::println("empty input");    break;
            case ParseError::Overflow:      std::println("overflow");       break;
        }
    }
}
```

## Class Design: Rule of Zero

```cpp
#include <memory>
#include <string>
#include <vector>

// Good: Rule of Zero — all members manage themselves
class Document {
public:
    explicit Document(std::string title) : title_(std::move(title)) {}

    void addSection(std::string content) {
        sections_.emplace_back(std::move(content));
    }

private:
    std::string title_;                    // manages its own lifetime
    std::vector<std::string> sections_;    // manages its own lifetime
    // No destructor, no copy/move definitions needed — compiler generates correct ones
};

// Bad: unnecessary manual resource management
class BadDocument {
public:
    BadDocument(const char* title) {
        title_ = new char[strlen(title) + 1]; // raw new — avoid this
        strcpy(title_, title);
    }
    ~BadDocument() { delete[] title_; }       // manual cleanup — fragile
    // Must also define copy ctor, copy assign, move ctor, move assign correctly...
private:
    char* title_;
};
```
