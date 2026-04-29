# Logging Standards Reference

This document defines the semantic conventions and levels used in the Logging Best Practices skill.

## Log Levels

| Level | Usage |
| :--- | :--- |
| **TRACE** | Fine-grained informational events (mostly for debugging logic flows). |
| **DEBUG** | Detailed information for developer troubleshooting. |
| **INFO** | Regular operational events (startup, shutdown, successful requests). |
| **WARN** | Potential issues or degraded states that don't stop the service. |
| **ERROR** | Operational failures that affect a specific request or operation. |
| **CRITICAL** | System-wide failures requiring immediate attention. |

## OpenTelemetry Semantic Conventions

To ensure interoperability, use the following field names where possible:

- `timestamp`: The time when the event occurred.
- `severity_text`: The string representation of the log level.
- `body`: The primary log message.
- `attributes.service.name`: The value of `process_name`.
- `attributes.container.id`: The value of `container_id`.
- `attributes.code.filepath`: Path to the source file.
- `attributes.code.lineno`: Line number in the source file.
- `attributes.exception.type`: Class name of the exception.
- `attributes.exception.message`: Message from the exception.
- `attributes.exception.stacktrace`: Full stack trace.
