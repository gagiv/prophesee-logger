---
name: C# Best Practices
description: Comprehensive C# coding standards covering modern C# (C# 10-12), async/await, LINQ, dependency injection basics, nullable reference types, and testing conventions.
---
# C# Best Practices

Coding standards for modern C# (C# 10+) across .NET 6 through .NET 8+. This skill covers language-level patterns. Framework-specific patterns (ASP.NET Core middleware, EF Core, Blazor) belong in future skills.

## 1. Naming Conventions

**Rule:** Use consistent naming to maximize code readability and tooling support.

| Element | Convention | Example |
|---------|-----------|---------|
| Namespace | PascalCase, match folder | `MyApp.Services` |
| Class / Struct / Record | PascalCase | `CustomerService` |
| Interface | `I` + PascalCase | `ICustomerService` |
| Method | PascalCase | `GetCustomerAsync` |
| Property | PascalCase | `FirstName` |
| Local variable | camelCase | `customerCount` |
| Parameter | camelCase | `customerId` |
| Private field | `_` + camelCase | `_logger` |
| Constant | PascalCase | `MaxRetryCount` |
| Enum type | PascalCase singular | `OrderStatus` |
| Enum member | PascalCase | `OrderStatus.Pending` |
| Async method | suffix `Async` | `SaveAsync` |

## 2. Code Organization

**Rule:** One type per file; namespace matches folder path.

- File-scoped namespace declaration (C# 10+): `namespace MyApp.Services;` — no extra indentation level.
- Organize types in the order: constants, fields, constructors, properties, methods (public first, then private).
- Use `global using` directives in a dedicated `GlobalUsings.cs` file to eliminate repetitive `using` statements project-wide.
- Prefer `record` types for immutable data containers; use `record struct` for small value-type data.

## 3. Nullable Reference Types

**Rule:** Enable NRT project-wide and treat warnings as errors.

```xml
<Nullable>enable</Nullable>
<TreatWarningsAsErrors>true</TreatWarningsAsErrors>
```

- Never use `!` (null-forgiving) to silence warnings without a documented reason.
- Use `string?` for intentionally nullable references; non-nullable types must be initialized before use.
- Initialize fields in the constructor or use `required` members (C# 11+) to enforce initialization at the call site.

```csharp
public class Order
{
    public required string CustomerId { get; init; }
    public string? Notes { get; init; }
}
```

## 4. Modern C# Language Features

### 4.1 Primary Constructors (C# 12)

Use primary constructors for classes and structs that primarily capture injected dependencies.

```csharp
public class OrderService(IOrderRepository repository, ILogger<OrderService> logger)
{
    public async Task<Order?> GetAsync(int id, CancellationToken ct)
    {
        logger.LogInformation("Getting order {Id}", id);
        return await repository.FindAsync(id, ct);
    }
}
```

### 4.2 Collection Expressions (C# 12)

Prefer collection expressions over explicit constructors for collection initialization.

```csharp
// Preferred
int[] ids = [1, 2, 3];
List<string> names = ["Alice", "Bob"];

// Also valid for spread
int[] combined = [..ids, 4, 5];
```

### 4.3 Raw String Literals (C# 11)

Use raw string literals for JSON, SQL, or multi-line strings to avoid escaping.

```csharp
var json = """
    {
        "name": "Alice",
        "age": 30
    }
    """;
```

### 4.4 Pattern Matching

Use pattern matching to simplify type checks and conditional logic.

```csharp
// Type patterns
string Describe(object obj) => obj switch
{
    int n when n > 0 => "positive integer",
    int n            => "non-positive integer",
    string s         => $"string: {s}",
    null             => "null",
    _                => "other"
};

// List patterns (C# 11)
bool IsFirstTwo(int[] arr) => arr is [var first, var second, ..];
```

### 4.5 Records and Record Structs

Use `record` for immutable reference-type DTOs and value objects. Use `readonly record struct` for small immutable value types that benefit from stack allocation.

```csharp
// Reference-type record (class semantics, heap allocated)
public record Address(string Street, string City, string PostalCode);

// with-expressions for non-destructive mutation
var updated = original with { City = "New York" };

// Value-type record (struct semantics, stack allocated)
public readonly record struct Point(double X, double Y);

// Mutable record struct — only when mutation is explicitly needed
public record struct Range(int Start, int End);
```

Choose `readonly record struct` over `record` when: the data is small (2-4 fields), frequently allocated in hot paths, and value semantics (equality by value, copied on assignment) are correct.

### 4.6 File-Scoped Types (C# 11)

Use the `file` access modifier to restrict a type's visibility to the single file where it is declared. This is useful for implementation detail types that should not leak into other files.

```csharp
// Only visible within this .cs file — cannot be used from any other file
file class OrderValidator
{
    public bool IsValid(Order order) => order.CustomerId is not null;
}

// Also applies to records, structs, interfaces, delegates
file record struct ValidationResult(bool IsValid, string? Error);
```

Use `file`-scoped types for: helper classes private to a single implementation file, source generators' internal scaffolding, and avoiding name collisions across files without polluting `internal` scope.

## 5. Async/Await

**Rule:** Use async all the way up the call stack; never block on async code.

- Prefer `async Task` / `async Task<T>` over returning naked `Task`.
- Never use `async void` except for event handlers; use `async Task` instead.
- Always propagate `CancellationToken` from public API boundaries down to I/O calls.
- Prefer `ConfigureAwait(false)` in library code where the calling context does not matter.
- Use `ValueTask<T>` when a method frequently returns a synchronous result (hot-path optimization); default to `Task<T>` for simplicity.

```csharp
// Correct — async all the way, CancellationToken propagated, ConfigureAwait in library code
public async Task<Order?> FindOrderAsync(int id, CancellationToken ct = default)
{
    return await _repository.GetByIdAsync(id, ct).ConfigureAwait(false);
}

// Correct — multiple I/O operations with cancellation
public async Task<IReadOnlyList<Order>> GetActiveOrdersAsync(CancellationToken ct = default)
{
    var orders = await _repository.ListAsync(ct).ConfigureAwait(false);
    return orders.Where(o => o.IsActive).ToList();
}

// Wrong — blocks the thread pool, risks deadlock
public Order? FindOrder(int id) => FindOrderAsync(id).Result;
```

## 6. LINQ

**Rule:** Prefer method syntax; be aware of deferred execution.

- Use method syntax (`Where`, `Select`, `FirstOrDefault`) over query syntax for consistency with the rest of the codebase.
- LINQ queries execute lazily — materialize with `.ToList()`, `.ToArray()`, or `.ToDictionary()` when the result will be enumerated more than once or when you need a stable snapshot.
- Avoid LINQ inside tight loops on large collections; profile before assuming LINQ is a bottleneck.
- For in-memory filtering on large datasets, consider `AsSpan()` or `ArrayPool<T>` instead of repeated LINQ queries.

```csharp
// Materialize when enumerating multiple times
var activeOrders = orders.Where(o => o.IsActive).ToList();

// Avoid multiple enumeration of IEnumerable
foreach (var order in activeOrders) { /* ... */ }
int count = activeOrders.Count;
```

## 7. Error Handling

**Rule:** Use structured exception handling; reserve exceptions for truly exceptional conditions.

- Define a domain exception hierarchy derived from a base exception: `AppException : Exception`.
- Use the Result pattern for expected failure cases (validation, not-found) where exceptions are expensive overhead.
- For HTTP APIs, structure error responses using ProblemDetails (RFC 9457) — the language-level concern is ensuring your exceptions carry enough data to produce one; the middleware that converts them belongs in a future `csharp-aspnet-patterns` skill.
- Never swallow exceptions silently; always log or rethrow.

```csharp
// Result pattern for expected failures
public record Result<T>(T? Value, string? Error)
{
    public bool IsSuccess => Error is null;
    public static Result<T> Ok(T value) => new(value, null);
    public static Result<T> Fail(string error) => new(default, error);
}

// Exception hierarchy
public class AppException(string message) : Exception(message);
public class NotFoundException(string entity, object id)
    : AppException($"{entity} with id '{id}' was not found.");
```

## 8. Dependency Injection

**Rule:** Favor constructor injection; choose service lifetimes deliberately.

- Constructor injection is the standard pattern — inject only what the type needs.
- **Singleton:** One instance for the application lifetime. Use for stateless services and configuration.
- **Scoped:** One instance per request (web) or operation scope. Use for database contexts and unit-of-work patterns.
- **Transient:** New instance per resolution. Use for lightweight, stateless utilities.
- Never inject a Scoped or Transient service into a Singleton — this causes captive dependency bugs.

```csharp
// Registration via IServiceCollection (Microsoft.Extensions.DependencyInjection)
// Works in console apps, workers, ASP.NET Core, and any .NET host
IServiceCollection services = new ServiceCollection();
services.AddSingleton<IConfigService, ConfigService>();
services.AddScoped<IOrderService, OrderService>();
services.AddTransient<IEmailFormatter, EmailFormatter>();
```

## 9. Testing

**Rule:** Follow Arrange-Act-Assert; use framework-agnostic patterns.

- Name tests: `MethodName_StateUnderTest_ExpectedBehavior`.
- Arrange all preconditions, act on the system under test, assert the single observable outcome.
- Major test frameworks: xUnit (most popular for .NET), NUnit, MSTest — choose based on team preference.
- Popular assertion libraries: FluentAssertions, Shouldly. Popular mock libraries: NSubstitute, Moq.
- Avoid test logic that depends on execution order; each test must be independent.

```csharp
// xUnit example (patterns apply to NUnit/MSTest)
public class OrderServiceTests
{
    [Fact]
    public async Task GetAsync_ExistingId_ReturnsOrder()
    {
        // Arrange
        var repository = Substitute.For<IOrderRepository>();
        var logger = Substitute.For<ILogger<OrderService>>();
        repository.FindAsync(1, Arg.Any<CancellationToken>())
            .Returns(new Order { Id = 1 });
        var sut = new OrderService(repository, logger);

        // Act
        var result = await sut.GetAsync(1, CancellationToken.None);

        // Assert
        result.Should().NotBeNull();
        result!.Id.Should().Be(1);
    }
}
```
