# OpenTelemetry JavaScript (Node.js) Examples

Idiomatic usage of the OpenTelemetry SDK in Node.js applications.

## Tracing a Function

```javascript
const { trace } = require('@opentelemetry/api');

const tracer = trace.getTracer('my-service');

async function processOrder(orderId) {
  // Use startActiveSpan to automatically handle context propagation
  return tracer.startActiveSpan('process.order', async (span) => {
    try {
      // Set semantic attributes
      span.setAttribute('order.id', orderId);
      
      const result = await someDatabaseCall(orderId);
      
      span.setStatus({ code: SpanStatusCode.OK });
      return result;
    } catch (error) {
      span.recordException(error);
      span.setStatus({ code: SpanStatusCode.ERROR, message: error.message });
      throw error;
    } finally {
      span.end();
    }
  });
}
```

## Creating Metrics

```javascript
const { metrics } = require('@opentelemetry/api');

const meter = metrics.getMeter('my-service');

const requestCounter = meter.createCounter('api.requests.total', {
  description: 'Total number of API requests',
});

const latencyHistogram = meter.createHistogram('api.latency', {
  description: 'API request latency',
  unit: 'ms',
});

function handleRequest(req) {
  const startTime = Date.now();
  
  // Logic...
  
  requestCounter.add(1, { 'http.method': req.method, 'status_code': 200 });
  latencyHistogram.record(Date.now() - startTime, { 'http.method': req.method });
}
```
