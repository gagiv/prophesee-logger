---
name: OpenTelemetry Best Practices
description: Standardizes distributed tracing, metrics, and semantic conventions for high-quality system observability.
---
# OpenTelemetry Best Practices

Guidelines for implementing standardized distributed tracing and metrics using OpenTelemetry to ensure high-quality observability.

## Mandatory Policies

### 1. Semantic Conventions
You MUST use OpenTelemetry Semantic Conventions for all attribute names. Never invent custom names for standard concepts (e.g., use `http.method` instead of `method` or `http_method`).

### 2. Context Propagation
You MUST ensure trace context is propagated across asynchronous boundaries. When starting a background task or making a network call, ensure the active span is correctly parented or the context is injected into headers.

### 3. Span Granularity
- **Database**: Every query MUST have its own span with attributes for the statement (sanitized) and database name.
- **External API**: Every outgoing request MUST have a span.
- **Complex Logic**: Large internal computation blocks SHOULD have spans if they represent a distinct logical step.

### 4. Meaningful Metrics
- **Counters**: Use for discrete events (e.g., `api.requests.total`).
- **Histograms**: Use for durations and sizes (e.g., `api.latency`).
- **Attributes**: Common attributes (e.g., `status_code`, `service.name`) SHOULD be applied to both spans and metrics.

## Critical Rules
- **No Sensitive Data**: Never include PII, passwords, or tokens in span attributes or logs associated with spans.
- **Fail Gracefully**: Instrumentation should never crash the application. Use `tracer.startActiveSpan` carefully with `try...finally` to ensure spans are always ended.
- **Status Codes**: Always set the span status to `Error` when an exception is caught that isn't handled.

## Resources
- [Semantic Conventions Reference](file:///skills/opentelemetry-best-practices/references/otel-standards.md)
- [Example Implementations](file:///skills/opentelemetry-best-practices/examples/javascript.md)
