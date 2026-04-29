# C# Logging Examples

## Structured Logging with Serilog

```csharp
using Serilog;
using System;

public class DataService
{
    private readonly ILogger _logger = Log.ForContext<DataService>();

    public void ProcessAlgorithm(double[] data)
    {
        try
        {
            _logger.Information("Algorithm iteration started. Data points: {Count}. Placement: {Placement}", 
                data.Length, "DataService.cs:45");

            // Realtime/Algorithmic specific logging
            var startTime = DateTime.UtcNow;
            RunComplexMath(data);
            var duration = (DateTime.UtcNow - startTime).TotalMilliseconds;

            _logger.Information("Iteration complete. Latency: {Latency}ms", duration);
        }
        catch (Exception ex)
        {
            // Mandatory Exception Logging
            _logger.Error(ex, "Algorithm execution failed at {Placement}. Container: {ContainerId}", 
                "DataService.cs:55", Environment.GetEnvironmentVariable("HOSTNAME"));
        }
    }
}
```

## Microsoft.Extensions.Logging (JSON Console)

```csharp
// In Program.cs
builder.Logging.AddJsonConsole(options => {
    options.TimestampFormat = "yyyy-MM-ddTHH:mm:ssZ ";
    options.JsonWriterOptions = new JsonWriterOptions { Indented = true };
});

// Usage
_logger.LogError(exception, "Request failed at {Placement}. TraceId: {TraceId}", 
    "OrderController.cs:120", HttpContext.TraceIdentifier);
```
