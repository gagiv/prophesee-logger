# Concurrency Safety Examples (C++14+)

### 1. Task-Based Parallelism (Async)
Avoids manual thread joining and handles return values safely.

```cpp
#include <future>
#include <vector>
#include <numeric>

int computeLargeSum(const std::vector<int>& data) {
    auto part1 = std::async(std::launch::async, [&data]() {
        return std::accumulate(data.begin(), data.begin() + data.size()/2, 0);
    });
    
    auto part2 = std::accumulate(data.begin() + data.size()/2, data.end(), 0);
    
    return part1.get() + part2;
}
```

### 2. Multi-Lock Safety (C++17 scoped_lock)
Prevents deadlocks when acquiring multiple resources.

```cpp
#include <mutex>

struct Account {
    std::mutex mtx;
    double balance;
};

void transfer(Account& from, Account& to, double amount) {
    // Acquire both locks simultaneously in a deadlock-free manner
    std::scoped_lock lock(from.mtx, to.mtx);
    
    if (from.balance >= amount) {
        from.balance -= amount;
        to.balance += amount;
    }
}
```

### 3. Condition Variables with Predicates
Always use a predicate to protect against "spurious wakeups."

```cpp
#include <mutex>
#include <condition_variable>
#include <queue>

std::queue<int> workQueue;
std::mutex workMtx;
std::condition_variable workCv;
bool finished = false;

void consumer() {
    while (true) {
        std::unique_lock<std::mutex> lock(workMtx);
        
        // Wait until there is work OR we are finished
        workCv.wait(lock, []{ return !workQueue.empty() || finished; });
        
        if (workQueue.empty() && finished) break;
        
        int task = workQueue.front();
        workQueue.pop();
        lock.unlock(); // Release lock before processing
        
        process(task);
    }
}
```
