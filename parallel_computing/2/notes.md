# 2.1.1
Cache lines are usually 64 or 128 bytes. If you make the cache line too short, your hit ratio will go down and you will need to access memory more often. If it is too big, you will be wasting bandwidth with a lot of extra values.
The best possible hit ratio is 1, and can be higher than the reuse ratio.

## Cache Mapping
Picture an example cache with 64KB of cache w/ 64 byte cache lines, 1024 cache blocks in total. On a read miss, you have to go load the value from memory into the cache, along with the rest of the cache line. Where in the cache should it go? A common tactic is to just ignore the last few bits of the address and put it in that spot in the cache. This is called a **direct map cache**. But what if you replace something you needed? What if you have empty space available?
A **fully associated cache** puts things anywhere there is space. Keeping track of where things are requires hardware and time, and when you read from the cache you have to check the entire cache for your value in the worst case.  What we have here is a tradeoff, and there is a compromise: the **set associative cache**. Set associative caches are a mixture: sets of direct mapped caches, so that you only have to check a few spots in the cache for a value. 

## Cache Replacement Policy
When something is already in the spot you wish to put your cache line, what do you do? For a direct mapped cache, there is only one place to put a cache line so there is no option. But for a set associative cache, you may have a few options, and for a fully associative cache, you will have a ton of options. You can do this randomly, or the least recently used one, etc. It actually doesn't matter what you do here, there is no discernable impact on performance, so multiple strategies are applied in the real world. 

## Categorizing Cache Misses
A **cache miss** is when you look
* Compulsory Cache Misses - "Cold" cache accesses, the first time you access it 
* Capacity Misses - no space left in the cache, and the value you wanted was evicted already
* Conflict Misses - there is space, but your value was evicted because something else needed to go in that spot in a direct mapped or set associative cache. If there was no space in the rest of the cache, this would be a capacity miss. 


A **working set** is the set of values that a program accesses during its execution over a certain time period.

# 2.1.2
Consider the following example.
```
for (i = 0; i < n; i += M):
	A[i] = B[i] + C[i]
```
64 bytes expressed in 4 byte words is 16 words. `M` is 16.
What happens with direct mapped, set associative, and fully associative caches?

Note that the program is designed maliciously such that it will always move ahead by the size of the cache line, so no two accesses access the same cache line. 

It doesn't matter what the cache is, everything will miss. Now, consider there is another loop outside of this one, iterating this code 1000 times. Now, we have the idea of a working set. It is always working on A, B, and C for certain values. If the size of these values in A, B, and C fits completely in the cache, then we see a difference in the various cache types. 

# 2.1.3
## Architectural Innovations
### Prefetching
Prefetching is trying to analyze what will be accessed next via pattern analysis. If you can make hardware to notice when memory is being accessed sequentially, you can prefetch multiple cache lines asynchronously while the program executes, or bring in multiple on a miss. 
### Out of Order Execution
By keeping a lot of instructions in progress at the same time, and not waiting for your current operation to finish to start the next one, you can increase speed a lot. This is pipelining. Bubbling and stuff can happen, remember. Techniques for this tactic require extra registers to temporarily store intermediate values and keep track of the status of dependencies in between instructions.

### Superscalar Processors
Can we execute multiple instructions per cycle? FMAD was a single instruction. __I think this is SIMD__. You need more hardware to keep track of logistics, but you can load multiple instructions and execute them at once.

## Impact on Programming
We generally just let the compiler handle these optimizations, but it is useful to know whether our program exploits superscalar processors well. **IPC**, or **Instructions Per Cycle** is a good metric for this. Sometimes you can restructure your code to avoid data dependencies or bubbles, as well.

# 2.1.4 
## Multiprogramming and Virtual Memory
A computer runs many programs simultaneously and gives each program a time slice of some milliseconds at a time. How does it keep the memories straight? **Virtual memory**. 

Basically, a program just views its memory addresses as 0..n, and the computer maps those virtual addresses to their real physical addresses via virtual memory. This way, programs can just  view memory in a simple, contiguous, way that starts at 0. Virtual memory can even hide SWAP space inside of it, so the program doesn't know some of its memory is on disk. 

The virtual memory paging table is stored in memory as well. In order to prevent having to look up a value to look up a value (i.e. check the table before accessing any memory, effectively doubling read times), the mapping itself is supported with a hardware unit called a **TLB** or **Translation Lookaside Buffer**. The TLP is often limited and size and doesn't know every value, you may have to check the in-memory page table if it doesn't have it.

You sort of have two caches then, a cache for physical addresses themselves and then a cache for what those addresses contain. You want to monitor **page faults** as well.

## What is a Good Page Size?
Most ODs set it to 4kb. That is good for general multiprogramming machines, but for a dedicated parallel computer, like a cluster...4KB is not enough. You need a ton of TLB entries to address every page. Instead, we can change the page size to 2MB, not have a ton of TLB misses, and if our working set is inside of our TLB size times our page size, we won't have any TLB misses. With HugePages, 2MB and 4MB page sizes are options, while with BlueWaters, 2MB pages are available as a module. Loading this module redirects mallocs to use larger pages.

## Compilers
Be careful with opimization levels and know what they do. They can rarely compile incorrectly, as they try to make inferences about your code and those can fail, albeit extremely rarely. There are more flags for more nuanced control over optimizations. 


The bottom line is that speed has been acquired at the cost of complexity. Paging, tables, various levels of memory, optimization, etc, are all extra complications for the sake of speed. 

Keep in mind that **peak speed** is the speed which a processor will never __exceed__. 10% of peak speed is not unheard of. 

__For clarification on pages vs cache lines, see: https://softwareengineering.stackexchange.com/questions/270192/relation-between-cache-line-and-memory-page__

# 2.2.1
## Multi-dimensional Arrays
### Importance of how Arrays are Allocated in Memory
We know that enhancing **spatial locality** is important for performance. I.e. logically correlated values should be physically close in memory, so they will probably be read in the same cache line.

Architects noticed that programmers tend to access nearby memory locations so they optimized this, and now programmers really try to access memory consecutively. 

A 1-D array is laid out exactly as expected: consecutively. It is multi-dimensional arrays where things get interesting. A **statically allocated multi-dimensional array** is either a globally declared value or declared inside a function (and thusly allocated on stack). The layout for statically allocated 2-D arrays in C and C++ is "row major". `A[i][j+1]` is adjacent to `A[i][j]`. This is assuming you are visualizing your 2-D array as `Array[col][row]`. As a programmer, this means that in 2-D arrays you want to vary `j` faster than `i`, iterate through the second index. This is inverse in Fortran for whatever reason. 

What about **dynamically allocated multi-dimensional arrays?**. A common tactic is to  create an array of array pointers. 
```
A = malloc(sizeof(float* *M);
for (i = 0; i < M; i++) 
	A[i] = malloc(sizeof(float) * N);
```
This isn't good for spatial locality, you are at the whim of malloc. Padding in allocation wastes memory, consecutive rows may be arbitrarily separated in physical memory, and predictability is reduced as prefetchers don't know where the next row will be.

A better, and more general, method is to allocate all the space with one allocation call, and then to do index calculation explicitly. This can be awkward programatically, but you can get used to it.

Here is an example:
```
A = malloc(sizeof(float *) * M * N);
// Index A with A[N*i + j] instead of A[i][j]

```

