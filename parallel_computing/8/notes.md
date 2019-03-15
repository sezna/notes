# 8.1.1
## Pthreads
### Basic Commands
**Pthreads**, or **Posix Threadsa** are available on all posix machines. It's like using `omp parallel` (not `parallel for`). Basic calls include:
* `pthread_create`
* `pthread_join`
* `barrier, lock, mutex`
* `Thread private variables`

```c++
pthread_create(&thread1, NULL, foo, &arg); // create a thread

...

pthread_join(thread1, status) // wait for the thread

void foo(&arg) {
	// code for thread
	return (fooVal)
}
```

`pthread_join`  waits for the function `foo` to finish. `status` will be assigned the value `fooVal` upon joining.

### Basic Locks
* Declaring a lock: `pthread_mutex_t mutex;`
* Initialize a mutex: `pthread_mutex_init(&mutex, NULL); // using defaults`
* Entering and releasing a mutex: `pthread_mutex_lock(&mutex);` and `pthread_mutex_unlock(&mutex);`
* Checking a lock without blocking it: `pthread_mutex_trylock(&mutex);`
* Release resources: `pthread_mutex_destroy(mutex);`

Hello world with pthreads:
```c++
int main(int argc, char ** argv) {
	long threads = strtol(argv[1], NULL, 10);
	pthread_t * threadHandles = malloc(threads * sizeof(pthread_t));
	long * ids = (long *) malloc(sizeof(long) * threads);
	for (long t = 0; t < threads; t++) {
		ids[t] = t;
		pthread_create(&threadHandles[t], NULL, Hello, (void *) & (ids[t]));
	}
	printf("Hello from the main thread\n");
	for (long t = 0; t < threads; t++) {
		pthread_join(threadHandles[t], NULL);
	}
	free(threadHandles);
	free(ids);
}
```
### Threads and Resources
If you have x cores, and each core has 2 "hardware threads" (hyperthreading). You can hypothetically create as many threads as you want, but in this case, you don't want to make more than 2x threads. If you have more than 2x threads, the OS will spend more time context switching. This hurts cache performance as well. 

Sometimes, the OS will actually just pause threads every few ms even if you have fewer logical threads than hardware threads. This can slow you down, so pthreads provide a way to bind threads to hardware resources. This is called **pthread affinity** or **pinning**.

Example of pinning:
```c++
cpu_set_t cpuset;
CPU_ZERO(&cpuset);
CPU_SET(PEnum, &cpuset); // can be called multiple times
pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset);
```
(?) come back to this, not sure how this works.

You should always use some sort of affinity to improve performance. You want to decide how many pthreads to create to avoid over-subscription and use SMT only if memory bandwidth (and floating point intensity) permit. Minimize barriers and synchronization, and reduce cross-core communication.

Also, avoid locks when possible, because they hurt performance. Atomics are generally faster.

### OpenMP vs. Pthreads
* OpenMP is simpler, and easy to implement parallel loops
* When much more granular control is needed, pthreads can be used
* pthreads are not available in all OSs (Windows), but Windows provides an alternative that is similar.

Things to research:
* Over-subscription
* SMT
* Using affinity/pinning in pthreads


# 8.1.2
## Basic C++11 Atomics
Recall why we often need to flush variables when waiting for changes from other threads. And recall the definition of sequential consistency: a arbitrarily parallel program produce the same outcome as a sequential one. 

In pthreads, we do not have access to OpenMp's `flush`. Instead, we can use C++11 atomics (before C++11, we had to use processor-specific memory fence operations). 

Example:
```c++
#include <atomic>
std::atomic<T> atomic_variable;
std::atomic<T*> atomic_pointer;
std::atomic<T>* atomic_array;
```

With an atomic variable, you have access to the following functions:
* `atomic_store` - replaces the value of the atomic object with a non-atomic argument
* `atomic_load` - obtains the value stored in the atomic object
* `atomic_fetch_add` - adds a non-atomic value to an atomic object and obtains the previous value of the atomic
* `atomic_compare_exchange_strong(obj, expected, desired)` - automatically compares the value of the atomic object with a non-atomic argument, and it performs an atomic exchange if they are equal, or atomic load if not.

Example of ACES:
```c++
int a = std::atomic<int> 5;
int b = 0;
int c = 7;

atomic_compare_exchange_strong(a,b,c);

// if a != b, then b becomes 5. You know this happened because b changes value.
b = 5;
// if a == b, then a becomes 7. You know this happened because b keeps the same value.
```


# 8.1.3
## Single Producer Single Consumer
Locks are an established way of enforcing mutual exclusion. Locks are expensive, though, because they cause serialization. How can we synchronize without waiting?
Suppose work of the following structure is happening:
```c++
for (i .. n) {
	work();
	lock(x);
	critical();
	unlock(x);
}
```

If the work inside the critical section is tiny, or the number of threads is tiny, this is not a big deal. If the work inside the non-critical section is more than the critical work times the number of threads, there will be a lot of waiting time. See 8.1.3 4:10ish for a visualization of this. If we can break up the critical section and add more non-critical work in the middle, you can solve this problem. 

In reality, most of the time, locks are good enough. However, when you really want to get dirty with parallelism, **lock-free algorithms** or **wait-free algorithms** need no locking. However, most famous lock-free algorithms were innovated with sequential consistency in mind, which processors no longer guarantee. 

### Lockless/Thread Unsafe SPSC
```c++
class SPSCQueue {
	private:
		T* arr;
 		int count;
		int head, tail;
		// add mutex for locking
		// mutex mtx;

	public:
		bool enqueue(T &data) {
			int ret = 0;
			// add a lock here to make it safe			
			// mtx.lock();
			if (count < capacity) {
				count++l
				arr[mask(tail++)] = data;
				ret = 1;
			}
			// mtx.unlock();
			return ret;
}
```

If you uncomment the commented code, this becomes safe.

### Lockless/Thread Safe SPSC
```c++
class SPSCQueue {
	private:
		array<atomic<T>, capacity> arr;
		atomic<int> count;
		int head, tail;
	public:
		bool enqueue(T &data) {
			if (count.load() < capacity) {
				arr[mask(tail++)].store(data);
				count.fetch_add(i);
				return 1;
			}
			return 0;
		} 
```

# 8.1.4
## Message Passsing in Distributed Systems
A shared memory machine is basically a bunch of processors attached to the same memory. 
