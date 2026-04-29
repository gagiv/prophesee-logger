# C# Documentation (XML Style)

### File Header
```csharp
/*
 * File: AuthenticationService.cs
 * Purpose: Manages user login, token validation, and multi-factor authentication.
 * Author: Antigravity / ma-agents
 * Date: 2026-02-22
 */
```

### Method Documentation
```csharp
/// <summary>
/// Validates a user's credentials against the secure identity store.
/// </summary>
/// <param name="username">The unique identifier for the user.</param>
/// <param name="password">The plain-text password (will be hashed internally).</param>
/// <returns>
/// An <see cref="AuthResult"/> indicating success or failure with a details message.
/// </returns>
/// <exception cref="SecurityException">Thrown if the account is locked.</exception>
public async Task<AuthResult> LoginAsync(string username, string password)
{
    // ...
}
```
