# 5.1.1
## Synchronization Constructs
Critical sections (sections where no two threads are executing it at the same time) are expensive. 
```c
#pragma omp atomic
x++; x--; ++x; --x; // only limited things can be put here
```
Some hardware provide tools for this, and the **atomic clause** helps with this. 
This allows for atomic critical sections. There is also a **capture clause** that can be used with atomic.

```c
#pragma omp atomic capture
v = x++;
v = x--';

```

Now we can increment `x` and capture its value into a variable we can continue to use non-atomically/non-critically. You can also use a restricted capture block, but it is also heavily restricted.
Don't forget that `#pragma omp critical` also exists, and you can put any code block after it, but is not as efficient.

You can also use locks to synchronize your execution (plock is a pointer to a `omp_lock_t`:
* Creating a lock: `omp_init_lock(plock)`
* Acquire a lock or wait until it is available: `omp_set_lock(plock)`
* Release a lock, allowing a waiting thread to take it if one exists: `omp_unset_lock(plock)`
* Attempt to acquire a lock but return if you can't: `omp_test_lock(plock)` (returns true if acquired)
* Destroy a lock: `omp_destroy_lock(plock)` 

# 5.1.2
## Finding Primes
useless lecture, terrible code, non intelligible explanations

# 5.1.3
## Additional Coordination Constructs
### Parallel Sections
Independent sections of code for different threads.
```c
#pragma omp sections
{
	[#pragma omp section]
		{block of code}
	[#pragma omp section]
		{block of code}
}
```
A thread will execute each section. 

### Parallel Barriers
```c
#pragma omp barrier
```
A **barrier** forces threads to wait at that barrier until all threads have arrived at the barrier. 

### The `master` Construct
In a parallel region, sometimes you only want the master thread to execute something. 
```c
#pragma omp master
{
	block o' code
}
```
The master thread will execute this and all the other threads will skip it and continue on.

### The `single` Construct
```c
#pragma omp single
{
	block o' code
}
```
Similar to above, but doesn't need to be the master thread.

# 5.1.6
## More Synchronization
**Sequential Consistency** means that the executing of a program of _k_ threads should behave the same as some arbitrary interweaving of statements executed by each thread. Modern processors do not satisfy sequential consistency. 
OpenMP provides a **flush** primitive set that is an abstraction over processor flush primitives. Flush forces a variable to be written out to memory instead of being held in a register or cache local to a thread. It also forces a variable to be read freshly from memory.
If no variable is specified, all variables are flushed. Flush is useful for **point-to-point** synchronization, i.e. communicating between threads.

```c
int x = 5;
#pragma omp flush (x)
```

# 5.1.7
## The `ordered` Directive
The **ordered directive** allows you to specify dependencies between iterations. But that's a contradiction and not parallel right? 

```c
#pragma omp ordered
{ 
	block o' code
}
```
`ordered` waits for the previous iteration to finish until it executes its own block. 

```c
#pragma omp parallel for ordered
for (10..20) {
	{}
	#pragma omp ordered
	{}
}

```
### Using `depend` with `ordered`
`depend` allows you to depend on a previous iteration:
`#pragma omp ordered depend(sink:i-1)` looks for a beacon from one iteration ago, and `#pragma omp ordered depend(source)` broadcasts a beacon. 
When using ordered in parallel for, you need to specify how many levels of nesting there are. If it is nested twice, i.e. n^2, `#pragma omp parallel for ordered(2)`.


