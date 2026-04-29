# Python Logging Examples

## Structured Logging with `structlog`

```python
import structlog
import os

logger = structlog.get_logger()

def process_data(data):
    try:
        # Algorithmic step logging
        logger.info("calculation_step_started",
                    step="matrix_multiplication",
                    data_size=len(data),
                    placement="processor.py:45")
        
        result = perform_complex_math(data)
        return result
    except Exception as e:
        # Mandatory Exception Logging
        logger.error("calculation_failed",
                     exception_type=type(e).__name__,
                     exception_msg=str(e),
                     stack_trace=True, # structlog captures this
                     severity="ERROR",
                     placement="processor.py:52",
                     container_id=os.getenv("HOSTNAME"))
        raise
```

## Standard Library with JSON Formatter

```python
import logging
import json
from datetime import datetime

class JsonFormatter(logging.Formatter):
    def format(self, record):
        log_entry = {
            "datetime": datetime.utcnow().isoformat(),
            "severity": record.levelname,
            "message": record.getMessage(),
            "placement": f"{record.filename}:{record.lineno}",
            "process_name": record.processName,
            "trace_id": getattr(record, 'trace_id', 'none')
        }
        if record.exc_info:
            log_entry["exception"] = self.formatException(record.exc_info)
        return json.dumps(log_entry)

# usage
logger = logging.getLogger("backend_service")
logger.error("Database connection failed", exc_info=True)
```
