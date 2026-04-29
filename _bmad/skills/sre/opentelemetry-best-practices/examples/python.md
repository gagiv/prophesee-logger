# OpenTelemetry Python Examples

Idiomatic usage of the OpenTelemetry Python SDK.

## Tracing with Decorators

```python
from opentelemetry import trace

tracer = trace.get_tracer(__name__)

@tracer.start_as_current_span("process_data")
def process_data(data):
    span = trace.get_current_span()
    span.set_attribute("data.size", len(data))
    
    # Process...
    return True
```

## Manual Span Management

```python
def fetch_external_resource(url):
    with tracer.start_as_current_span("http_request") as span:
        span.set_attribute("http.url", url)
        span.set_attribute("http.method", "GET")
        
        try:
            response = requests.get(url)
            span.set_attribute("http.status_code", response.status_code)
            return response.json()
        except Exception as e:
            span.record_exception(e)
            span.set_status(trace.Status(trace.StatusCode.ERROR))
            raise
```
