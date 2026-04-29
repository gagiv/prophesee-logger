# JavaScript/TypeScript Logging Examples

## Backend (Node.js with `pino` or `winston`)

```typescript
import pino from 'pino';

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  formatters: {
    level: (label) => {
      return { severity: label.toUpperCase() };
    },
  },
  base: {
    process_name: 'api-gateway',
    container_id: process.env.HOSTNAME || 'unknown'
  }
});

async function handleRequest(req, res) {
  const traceId = req.headers['x-trace-id'];
  try {
    logger.info({ 
      msg: 'Handling incoming request', 
      trace_id: traceId,
      path: req.path,
      placement: 'router.ts:12'
    });
    
    // ... logic
  } catch (error) {
    // Mandatory Exception Logging
    logger.error({
      msg: 'Request handler failed',
      trace_id: traceId,
      err: error, // Pino automatically formats the stack trace
      severity: 'ERROR',
      placement: 'router.ts:25'
    });
    res.status(500).send('Internal Server Error');
  }
}
```

## Frontend (Browser)

```javascript
const logToServer = async (logEntry) => {
  try {
    await fetch('/api/logs', {
      method: 'POST',
      body: JSON.stringify({
        ...logEntry,
        datetime: new Date().toISOString(),
        browser: navigator.userAgent,
        process_name: 'frontend-spa'
      })
    });
  } catch (e) {
    console.error('Failed to ship logs', e);
  }
};

// Global error handler
window.onerror = function(msg, url, lineNo, columnNo, error) {
  logToServer({
    severity: 'ERROR',
    message: msg,
    placement: `${url}:${lineNo}`,
    exception: {
      message: error?.message,
      stack: error?.stack
    }
  });
};
```
