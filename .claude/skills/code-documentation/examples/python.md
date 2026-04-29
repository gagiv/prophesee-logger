# Python Documentation (Google/NumPy Style)

### File Header
Every module should start with a docstring that provides a high-level overview.

```python
"""
data_processor.py
~~~~~~~~~~~~~~~~~
Handles high-performance transformation of raw sensor data using NumPy.

:copyright: (c) 2026 by Antigravity.
:license: MIT, see LICENSE for more details.
"""
```

### Method Documentation
Preferred style is Google or NumPy style for readability and integration with tools like Sphinx.

```python
def calculate_moving_average(data, window_size):
    """Calculates the moving average of a dataset.

    This method uses a sliding window algorithm to smooth out volatility 
    in sensor inputs.

    Args:
        data (list[float]): A list or array of float values to process.
        window_size (int): The size of the averaging window (must be > 0).

    Returns:
        float: The calculated moving average.

    Raises:
        ValueError: If data is empty or window_size is invalid.

    Note:
        This implementation assumes data is already cleaned.
    """
    if not data or window_size <= 0:
        raise ValueError("Invalid data or window_size")
    # ... implementation
```

### Class Documentation
```python
class SignalFilter:
    """A collection of signal processing utilities.
    
    Attributes:
        sampling_rate (int): The frequency at which signals are sampled.
    """
    
    def __init__(self, sampling_rate):
        """Initializes the SignalFilter with a specific sampling rate."""
        self.sampling_rate = sampling_rate
```
