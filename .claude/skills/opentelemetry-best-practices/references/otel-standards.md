# OpenTelemetry Standards & Semantic Conventions

This document outlines the specific attributes and naming conventions to follow when instrumenting services.

## Common Attributes

| Attribute | Description | Example |
|-----------|-------------|---------|
| `service.name` | Logical name of the service | `user-auth-service` |
| `service.version` | Version of the service | `1.2.3` |
| `deployment.environment` | Target environment | `production` |

## HTTP Semantic Conventions

| Attribute | Description | Example |
|-----------|-------------|---------|
| `http.method` | HTTP request method | `GET` |
| `http.status_code` | response status | `200` |
| `http.url` | Full request URL | `https://api.example.com/v1/users` |
| `http.user_agent` | User agent header | `Mozilla/5.0...` |

## Database Semantic Conventions

| Attribute | Description | Example |
|-----------|-------------|---------|
| `db.system` | Database vendor | `postgresql` |
| `db.statement` | Sanitized SQL/query | `SELECT * FROM users WHERE id = ?` |
| `db.name` | Database name | `prod_db` |
| `db.operation` | Operation name | `SELECT` |

## Span Status Values
- **Unset**: Default status.
- **Ok**: Explicitly marked as successful.
- **Error**: Encountered a failure. Describe the error in the `exception` event or attributes.

## Useful links
- [Official OTel Semantic Conventions](https://opentelemetry.io/docs/specs/otel/common/semantic-conventions/)
