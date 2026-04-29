---
name: Vercel React Best Practices
description: Performance optimization framework for React and Next.js projects with 57 actionable rules across 8 categories
---
# Vercel React Best Practices Skill

## Description
Performance optimization framework for React and Next.js projects with 57 actionable rules across 8 priority-ranked categories, maintained by Vercel.

## Usage
Invoke this skill when writing, reviewing, or refactoring React/Next.js code for performance.

## Instructions

When applying React and Next.js performance best practices, follow these priority-ordered categories:

### 1. Eliminating Waterfalls (CRITICAL)

- Fetch data in parallel using `Promise.all` or `Promise.allSettled` — never chain independent requests sequentially
- Prefetch data at the layout/page level, not deep in the component tree
- Use `loading.tsx` and `Suspense` boundaries to stream content progressively
- Colocate data fetching with the component that needs it, but initiate parallel fetches at the route level
- Use React Server Components to move fetching to the server and eliminate client-server waterfalls

### 2. Bundle Size Optimization (CRITICAL)

- Use `next/dynamic` or `React.lazy` for components not needed on initial load
- Audit with `@next/bundle-analyzer` — remove or replace heavy packages
- Import only what you need: `import { x } from 'lib'` not `import lib from 'lib'`
- Add `'use client'` only at the lowest necessary component level
- Use `next/image` and `next/font` for automatic optimization

### 3. Server-Side Performance (HIGH)

- Default to React Server Components — add `'use client'` only when interactivity is required
- Use `cache()` to deduplicate requests within a render pass
- Set proper `revalidate` values — avoid `revalidate: 0` unless data truly changes per request
- Use `generateStaticParams` for static generation of dynamic routes
- Use streaming (`loading.tsx`, `Suspense`) to unblock rendering on slow data

### 4. Client-Side Data Fetching (MEDIUM-HIGH)

- Use SWR or React Query — avoid raw `useEffect` + `fetch` patterns
- Implement optimistic updates for mutations
- Set appropriate `staleTime` / `cacheTime` to prevent unnecessary refetches
- Use `prefetchQuery` or `preload` to start fetching before navigation
- Paginate or infinite-scroll large datasets

### 5. Re-render Optimization (MEDIUM)

- Keep state as close to usage as possible
- Split contexts to avoid unrelated re-renders
- Use `useMemo`/`useCallback` only for expensive computations or stable refs to memoized children
- Use `React.memo` for pure components that re-render often with the same props
- Prefer `useRef` over `useState` for values that don't trigger re-renders
- Use composition (`children` prop) over deep prop drilling

### 6. Rendering Performance (MEDIUM)

- Virtualize long lists with `react-window` or `@tanstack/virtual`
- Debounce rapid inputs (search, resize, scroll)
- Use CSS for animations — prefer `transform` and `opacity` for GPU-accelerated motion
- Use `content-visibility: auto` for off-screen content

### 7. JavaScript Performance (LOW-MEDIUM)

- Avoid blocking the main thread — offload heavy work to Web Workers or `requestIdleCallback`
- Use `Map`/`Set` for frequent lookups instead of arrays
- Use `AbortController` to cancel stale requests and avoid race conditions
- Avoid deep cloning — prefer structural sharing or shallow copies

### 8. Advanced Patterns (LOW)

- Implement route-level code splitting with parallel route segments
- Use Edge Runtime for latency-sensitive API routes
- Use Server Actions for form mutations instead of manual API routes
- Profile with React DevTools Profiler and Chrome Performance tab before optimizing

## Key Principles

- **Measure first**: Use Lighthouse, Web Vitals, and React DevTools before optimizing
- **Prioritize by impact**: Waterfalls and bundle size yield the largest gains
- **Don't prematurely optimize**: Address critical categories before lower-priority ones
- **Verify with metrics**: Confirm improvements with real data, not intuition
