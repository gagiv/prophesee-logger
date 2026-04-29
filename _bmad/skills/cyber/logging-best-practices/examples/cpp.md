# C++ Logging Examples

## Structured Logging with `spdlog`

```cpp
#include "spdlog/spdlog.h"
#include "spdlog/sinks/stdout_color_sinks.h"
#include <exception>

void run_realtime_loop() {
    auto logger = spdlog::get("realtime_logger");
    
    try {
        // Realtime/Algorithmic domain logging
        logger->info("Computation step started. Input size: {}. Placement: {}:{}", 
                     1024, __FILE__, __LINE__);
        
        if (check_anomaly()) {
            logger->warn("Numerical anomaly detected! Severity: WARN");
        }
        
    } catch (const std::exception& e) {
        // Mandatory Exception Logging
        logger->critical("Critical failure in realtime loop! Error: {}. File: {}. Line: {}", 
                        e.what(), __FILE__, __LINE__);
        throw;
    }
}

// Global setup for JSON output
void setup_logging() {
    // Note: spdlog requires a custom formatter or sink for pure JSON output 
    // to match OTel standards perfectly.
    spdlog::set_pattern("{\"datetime\":\"%Y-%m-%dT%H:%M:%SZ\",\"severity\":\"%l\",\"message\":\"%v\",\"process_name\":\"engine_v1\"}");
}
```
