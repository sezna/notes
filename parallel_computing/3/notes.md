# 3.1.1
## Vector (SIMD) Hardware
Many computationally intensive applications loop over data and do identical operations.
```c
for (i = 0; i < N; i++)
	A[i] += x * B[i];
```
The instructions themselves are identical, but the values change each iteration. We can make this kind of code execute faster by simply duplicating floating point hardware. Instruction fetch and decode would be the same, and then loading and storing would handle consecutive values at once. As floating point units are cheap and take less than 1 square millimeter on the chip, this is easy to accomplish.

Now, in one clock cycle, you can do four FLOPs, or maybe eight, or whatever depending on the chip. In order for this to work, we need to add a few other features, though. First, we must add to our minds the logical construct of the vector: consecutive values in memory. We must add a vector register to store a vector (must be bigger than a normal one word register), and we need to add instructions to our processor for these new operations.
## How to Vectorize your Code/use SIMD
In an ideal world, a compiler can provide this optimization automatically. However, it cannot always do this, as it cannot always guarantee that each iteration is independent of the previous one. Depending on the language, you may need to use special data types or annotations.

In order to find out if the compiler automatically vectorized your code, many compilers can provide a report. For Intel compilers, you can use `-vec-report`.

```c
void add(float* a, float* b, float* c) {
	for (int i = 0; i < SIZE; i++) {
		c[i] += a[i] + b[i]
	}
}
```
Why would this code not be vectorized? If `c[i]` contains a pointer to a value in `a` or `b`, it could be dependent on a previous iteration and vectorization would therefore result in inaccurate code. If you, as the programmer, know for a fact that your code is not convoluted and weird in this way, you can use the `restrict` keyword.
```c
void add(float* restrict a, float* restrict b, float* restrict c) {
	for (int i = 0; i < SIZE; i++) {
		c[i] += a[i] + b[i]
	}
}
```
The `restrict` keyword informs the compiler that these variables will not be **aliased**, or redirecting to each other(?). 

# 3.1.2
## Performance Analysis: Counters and Timers
You can count things like the number of cache misses, hit ratios, FLOPs and intensity, etc., with some tools built in to processors. Performance counters are fairly standard in processors right now, although they are fairly low level and somewhat difficult to use. The specific performance counters on chips may vary from chip to chip, as well. 

Some libraries exist to handle all of this variation and provide a layer of abstraction to simplify use. The main one is called PAPI. 

```c
int EventSet = PAPI_NULL;
long long values[3];
retval = PAPI_libarary_init(PAPI_VER_CURRENT);
PAPI_create_eventset(&EventSet);
PAPI_add_event(EventSet, PAPI_TOT_INS);
PAPI_start(EventSet);
PAPI_read(EventSet, values);
PAPI_stop(EventSet, values);

```
To learn more about the excerpt above, see lecture 3.1.2 at around 4:00. Basically, however many events you have in `EventSet` are recorded to the `values` array when you read/stop. 

Timers are also very useful, trying to figure out how long certain parts of a program take vs the whole program, etc. It is important to have a low overhead timer tat has high resolution. You can time in either real time, or clock ticks. Clock ticks are not a constant frequency in modern processors, though, so these two units are very different. You can check the overhead and resolution of timers by calling them repeatedly in a loop and testing them. I guess initializing and stopping every iteration of a loop can effectively time initialization/deinitialization of a timer.

# 3.1.3
## Profiling with gprof
The basic idea of **profiling** is to collect data on execution characteristics of blocks of code (or functions). Metrics can be time, memory usage, performance counters, tracing, memory leak checking, etc. 

To use gprof, use `-pg` at link time. Execute the program normally, and it will produce a file called `gmon.out`. Then, in that same folder, run `gprof <name-of-executable>`. This generates profiling output.

The first part of the profiling info is self explanatory. The second part is more complicated, it is called the **Call Graph View**. It shows you where functions were called from, who they called, and how many times they were called.

## Utility of gprof and Profiling
* Gives a quick overview of where a program's execution time went
* Allows the programmer to focus their optimization efforts on a smaller fraction of code
* It does not show which function instances or objects are costly, as it shows total and average execution time spent in each function(?)
* It does not show how time spent in functions changes over time (oh -- it only has total stats, not individual calls, makes sense)
* It is based on sampling, so there can be errors, especially for functions with tiny execution times. 

# 3.2.1
## Shared Memory Multiprocessors
This topic relates to putting multiple processors ("cores") on a chip, resulting in multi-core processors which have shared memory. Each core on a multi-core processor has its own cache, but they all share DRAM memory. This introduces race conditions. What if CPU 3 requests value X, then CPU 1 writes back to value X? Now CPU 3 has an out of date value X. (4:30ish in 3.2.1). This **cache coherence** problem needs to be solved. To solve this, a **cache controller** monitors cache coherence.

Two types of cache controllers:

* Snoopy Controllers
* Directory-based Approaches (MSI Protocol, MESI Protocol)

Real cache coherence hardware is more complicated than what we have discussed, there is not a single shared bus but rather complicated interconnections with L1, L2, and L3 caches. L2 is sometimes shared and L3 is typically shared between cores. **SMT** is **symmetric multi-threading** and it is just hyperthreading within a core.
 
**Snoopy Cache Controllers** basically watch the shared memory bus and snoop what the other caches are doing, and keep things coherent. On some modern machines, there are too many cores so a snoopy controller is not valid. We need to instead use a directory based protocol, and store the state of cache lines in a directory to be checked later. In the **MSI Protocol**, a cache line is either:
* Modified: meaning it is changed but has yet to be written to DRAM -- prevent other cores from reading DRAM value.
* Shared: I have a copy from DRAM, unmodified, and others also have unmodified copies.
* Invalud: I have a copy, but another processor's cache has a more recent version.

Modified is sometimes called **dirty**, which is sort of a good thing, it means the most up-to-date copy. There is an alternative to MSI, known as the **Illinois Protocol** or **MESI Protocol**. In MESI, each cache line is either:

* Modified
* Exclusive: I have a copy and nobody else has a copy, and my copy is not dirty (is unmodified from DRAM value)
* Shared: I have a copy, I know others have a copy, and none of them is dirty/"M"
* Invalid

Each cache controller monitors transactions on the shared bus via snooping.

**Cache traffic** trying to keep cache lines up to date can be a bottleneck. Data written by one core and read by another core causes cache traffic, and it can be made worse with large cache lines. 

# 3.2.2
## Shared Address Space Programming
* Processes
* Address spaces and their relation to real physical memory
* Division of address space into global variables, stack, and heap
* OS scheduler
* Threads and their relationship to the above things
* Basic Challenges of shared address space programming

A **process** is your program taking actions. If a program is a recipe, a process is actually executing a recipe. A process's view of memory is called its **address space**. It sees its address space as pages of contiguous memory. There is then a mapping from this address space to physical memory, where it is probably not actually physically in order. The address space itself has **global variables**, the **stack**, and the **heap**. As you call a function, the variables of that function get pushed onto the stack, and then if another function is called, that is pushed onto the stack, etc. If you use `malloc()` or some dynamic memory assignment, that goes onto the heap. If a second process is running on the same core, it has its own address space, but it shares the CPU, cache, and physical memory. When a process pauses to let another process execute, its program counter and stack pointer are saved off into the heap. 

The time a program runs before switching is called a **time quanta** and is often only a few milliseconds. Switching between processes is called a **context switch**. Note that when a process is switched back to, the cache may not be in the same state. From the process's point of view, the cache is considered "polluted" in this case. Your data is still in DRAM, and must be re-fetched. 

See 5:20 in 3.2.2 for an example with two cores and three processes. 

To program with shared address space, we can't use two processes. Every process has its own address space. We need something smaller than a process: we use **LWP** (light-weight processes), **pthread** (POSIX thread), **Windows threads**, **fibers**, etc. There are many names, but they're basically threads. Threads are like processes but share address space. They're visible to the OS for scheduling.

For optimal performance, you don't want any more threads than cores. If you have more threads than cores, you risk wasting too many resources on context switching. 
