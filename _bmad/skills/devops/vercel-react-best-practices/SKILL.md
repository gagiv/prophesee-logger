---
name: Vercel React Best Practices
description: Performance optimization framework for React and Next.js projects with 57 actionable rules across 8 categories
---
# Vercel React Best Practices

A thorough performance optimization framework for React and Next.js projects. Contains 57 actionable rules organized into 8 categories, ranked by potential impact.

## When to Apply

Reference these guidelines when:
- Writing new React components
- Implementing data fetching
- Reviewing code for performance concerns
- Refactoring existing applications
- Reducing bundle sizes and load times

## Rule Categories (Priority-Ordered)

### 1. Eliminating Waterfalls (CRITICAL)
Prefix: `async-`

- Avoid sequential data fetching — use parallel requests (`Promise.all`, `Promise.allSettled`)
- Prefetch data at the layout/page level rather than in deeply nested components
- Use `loading.tsx` and `Suspense` boundaries to stream content progressively
- Avoid `await` chains where requests don't depend on each other
- Colocate data fetching with the component that uses the data, but fetch in parallel at the route level
- Use React Server Components to move data fetching to the server and eliminate client-server waterfalls

### 2. Bundle Size Optimization (CRITICAL)
Prefix: `bundle-`

- Prefer `next/dynamic` or `React.lazy` for heavy components not needed on initial load
- Audit dependencies with `@next/bundle-analyzer` — remove or replace bloated packages
- Use tree-shakeable libraries and import only what you need (`import { x } from 'lib'` not `import lib from 'lib'`)
- Mark client components with `'use client'` only at the lowest necessary level
- Avoid importing server-only code into client components
- Use `next/image` instead of raw `<img>` tags for automatic optimization
- Use `next/font` to self-host fonts and eliminate external font requests

### 3. Server-Side Performance (HIGH)
Prefix: `server-`

- Default to React Server Components — only add `'use client'` when interactivity is needed
- Use the `cache()` function to deduplicate identical requests within a single render
- Leverage `unstable_cache` or `fetch` cache options for cross-request caching
- Set proper `revalidate` values — avoid `revalidate: 0` unless data truly changes on every request
- Use `generateStaticParams` for static generation of dynamic routes
- Move database queries and API calls to Server Components or Route Handlers
- Use streaming (`loading.tsx`, `Suspense`) to avoid blocking the entire page on slow data

### 4. Client-Side Data Fetching (MEDIUM-HIGH)
Prefix: `client-`

- Use SWR or React Query for client-side data fetching with caching, revalidation, and deduplication
- Implement optimistic updates for mutations to improve perceived performance
- Set appropriate `staleTime` and `cacheTime` to avoid unnecessary refetches
- Use `prefetchQuery` or `preload` to start fetching before navigation
- Avoid `useEffect` + `fetch` patterns — prefer dedicated data fetching libraries
- Paginate or infinitely scroll large datasets instead of loading everything at once

### 5. Re-render Optimization (MEDIUM)
Prefix: `rerender-`

- Lift state up only as far as necessary — keep state close to where it's used
- Split contexts to avoid triggering unnecessary re-renders on unrelated state changes
- Use `useMemo` and `useCallback` only for expensive computations or stable references passed to memoized children
- Avoid creating new objects/arrays in render — extract them as constants or memoize them
- Use `React.memo` for pure components that re-render often with the same props
- Prefer `useRef` over `useState` for values that don't need to trigger re-renders
- Avoid prop drilling — use composition (`children` prop) instead of deep prop chains

### 6. Rendering Performance (MEDIUM)
Prefix: `rendering-`

- Virtualize long lists with `react-window` or `@tanstack/virtual`
- Debounce rapid user inputs (search, resize, scroll handlers)
- Use CSS for animations and transitions instead of JS-driven re-renders
- Use `content-visibility: auto` for off-screen content
- Avoid layout thrashing — batch DOM reads and writes
- Use `will-change` sparingly and only on elements that will actually animate
- Prefer `transform` and `opacity` for GPU-accelerated animations

### 7. JavaScript Performance (LOW-MEDIUM)
Prefix: `js-`

- Avoid blocking the main thread — use `requestIdleCallback` or Web Workers for heavy computation
- Use `Map` and `Set` for frequent lookups instead of arrays
- Minimize closures in hot paths
- Prefer `for...of` or `Array.prototype` methods over manual loops for readability, but use manual loops in performance-critical sections
- Avoid deep cloning — use structural sharing (Immer) or shallow copies where possible
- Use `AbortController` to cancel stale requests and avoid race conditions

### 8. Advanced Patterns (LOW)
Prefix: `advanced-`

- Use the `Offscreen` API (when stable) for pre-rendering hidden UI
- Implement route-level code splitting with parallel route segments
- Use Edge Runtime for latency-sensitive API routes
- Implement partial prerendering (PPR) for hybrid static/dynamic pages
- Use `Server Actions` for form mutations to avoid manual API routes
- Profile with React DevTools Profiler and Chrome Performance tab before optimizing

## General Principles

- **Measure before optimizing** — use Lighthouse, Web Vitals, and React DevTools
- **Higher-priority categories yield larger gains** — focus on waterfalls and bundle size first
- **Don't prematurely optimize** — only apply lower-priority rules after addressing critical ones
- **Test performance changes** — verify improvements with real metrics, not just intuition
