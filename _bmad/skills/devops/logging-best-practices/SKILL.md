---
name: Logging Best Practices
description: Standardizes structured logging across Backend, Frontend, Realtime, and Algorithmic domains with mandatory exception handling.
---
# Logging Best Practices

Enforce structured, context-rich logging according to market standards (OpenTelemetry) across all application domains.

## Policy

**All logs must be structured (preferably JSON) and include mandatory context. Every exception MUST be logged with its full stack trace.**

## Core Mandatory Fields

Every log entry must contain:
- `datetime`: ISO 8601 timestamp with timezone.
- `severity`: Standard level (DEBUG, INFO, WARN, ERROR, CRITICAL).
- `message`: Clear, concise description of the event.
- `placement`: File name and line number where the log was triggered.
- `process_name`: Name of the service or application.
- `container_id`: (If applicable) Docker/K8s container identifier.
- `trace_id` / `span_id`: For distributed tracing and request correlation.

## Domain-Specific Requirements

### 1. Backend Systems
- **Log**: Incoming/outgoing requests (method, status, duration).
- **Log**: Database query latencies and connection states.
- **Mandatory**: Full exception details in catch blocks.

### 2. Frontend Applications
- **Log**: Client-side errors (JS runtime, UI crashes).
- **Log**: User interaction context (last clicked component, breadcrumbs).
- **Context**: Browser version, OS, Resolution.

### 3. Realtime & Algorithmic Work
- **Log**: Iteration throughput and step-by-step latency.
- **Log**: Mathematical anomalies or convergence failures.
- **Mandatory**: Timeout exceptions and resource exhaustion warnings.

## Rules

- **No PII/Secrets**: Never log passwords, keys, or private user data.
- **Asynchronous**: Prefer non-blocking logging to maintain performance.
- **Traceability**: Always include `trace_id` in logs that are part of a request flow.
- **Exception Policy**: Use the `ERROR` level for caught exceptions that affect flow, and `CRITICAL` for system-wide failures.

## Reference

See [logging-standards.md](./references/logging-standards.md) for detailed field definitions and level guidance.
