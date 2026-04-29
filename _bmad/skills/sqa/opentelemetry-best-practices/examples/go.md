# OpenTelemetry Go Examples

Idiomatic usage of the OpenTelemetry Go SDK.

## Context-Aware Tracing

```go
import (
	"context"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/codes"
)

var tracer = otel.Tracer("my-service")

func (s *Server) GetUser(ctx context.Context, id string) (*User, error) {
	ctx, span := tracer.Start(ctx, "GetUser")
	defer span.End()

	span.SetAttributes(attribute.String("user.id", id))

	user, err := s.db.FetchUser(ctx, id)
	if err != nil {
		span.RecordError(err)
		span.SetStatus(codes.Error, err.Error())
		return nil, err
	}

	return user, nil
}
```
