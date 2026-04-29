# C++ Documentation (Doxygen Style)

### File Header
```cpp
/**
 * @file DataProcessor.hpp
 * @brief Handles high-performance transformation of raw sensor data.
 * @author Antigravity / ma-agents
 * @date 2026-02-22
 * @version 1.0.0
 */
```

### Method Documentation
```cpp
/**
 * @brief Calculates the moving average of a dataset.
 * 
 * This method uses a sliding window algorithm to smooth out volatility 
 * in sensor inputs.
 * 
 * @param data A span of float values to process.
 * @param windowSize The size of the averaging window (must be > 0).
 * @return The calculated moving average as a float.
 * @throw std::invalid_argument If data is empty or windowSize is invalid.
 * @see SignalFilter
 */
float calculateMovingAverage(gsl::span<const float> data, size_t windowSize);
```
