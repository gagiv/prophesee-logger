# Python Security Examples

### 1. Secure Subprocess (Avoiding Injection)
**Dangerous:**
```python
import os
def delete_file(filename):
    os.system(f"rm -rf {filename}") # VULNERABLE to injection
```

**Secure:**
```python
import subprocess
def delete_file(filename):
    # Pass as a list, shell=False by default
    subprocess.run(["rm", "-rf", filename], check=True)
```

### 2. Secure Serialization
**Dangerous:**
```python
import pickle
def load_user(data):
    return pickle.loads(data) # VULNERABLE to arbitrary code execution
```

**Secure:**
```python
import json
def load_user(data):
    return json.loads(data) # Safe for untrusted input
```

### 3. Preventing SQL Injection
**Dangerous:**
```python
cursor.execute(f"SELECT * FROM users WHERE id = '{user_id}'")
```

**Secure:**
```python
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
```

### 4. Secure Randomness
**Dangerous:**
```python
import random
token = str(random.random()) # Predictable
```

**Secure:**
```python
import secrets
token = secrets.token_urlsafe(32) # Cryptographically secure
```
