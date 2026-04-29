# JavaScript & TypeScript Documentation (JSDoc Style)

### File Header
```typescript
/**
 * @file api-client.ts
 * @description Centralized HTTP client with automatic retry and error handling.
 * @author Antigravity / ma-agents
 * @version 1.2.0
 */
```

### Method Documentation
```typescript
/**
 * Fetches data from a specific endpoint with optional caching.
 * 
 * @template T The expected type of the response data.
 * @param {string} url The target URL (must be absolute).
 * @param {RequestOptions} [options] Optional configuration for headers and timeouts.
 * @returns {Promise<T>} A promise that resolves to the parsed JSON response.
 * @throws {NetworkError} If the server is unreachable.
 * @throws {ValidationError} If the response schema does not match T.
 */
async function fetchData<T>(url: string, options?: RequestOptions): Promise<T> {
  // ...
}
```
