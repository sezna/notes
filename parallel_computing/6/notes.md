# 6.1.1
> "how do ensure good parallel performance when writing openmp program"

## Problems with the OpenMP model
Programming doesn't reflect performance. You must be aware of cache lines. Creates contention on the shared bus or arbitrator. 

With **Gauss-Seidel**, sequential is faster than parallel. 

# 6.1.3 
## False Sharing
Consider the following code:
```c
#pragma omp parallel for
for (1..n) {
	#pragma omp critical
	{
		code
	}
}
```
This loop hits the critical section a lot. We could try to add a test beforehand to only enter the critical section when we really need to. We can also privatize the value used in the critical section and save it to an array instead of a single variable, and look at all the best options at the end. 

**False sharing** is when two threads access areas near in an array, but not the same areas. There is no true sharing, but they are accessing the same cache lines and this causes heavy cache traffic. We can insert misdirection to avoid this, either by storing structs with padding in them and accessing a member of that struct, or by padding. 

# 6.2.1
## Nested Parallelism
The `#pragma omp parallel for collapse(n)` clause tells the system that we want to collapse three levels of nesting into one level of nesting so that the outer loop has more iterations, allowing for more threads and more parallelism. If three nested loops each iterate 10 times, you have to choose which one to parallelize. But if you have 30 cores, you would rather use all 30 cores. That's the type of situation this is useful for. 

When nesting parallelism:
```c
#pragma omp parallel for num_threads(8)
for (i..n) {
	#pragma omp parallel for num_threads(2)
	{
		// how many threads execute this section?
	}
}
```

16 threads execute that region as each of the eight threads gave two threads to it. The thread nums for the inner section will be 0 and 1, and the outer section will be 0-7.  

Specifying `num_threads` overrides environment variables.

# 6.2.2
## `task` and `depends`. 
`#pragma omp task` allows for letting the system do work balancing automatically, without you manually specifying. `#pragma omp taskwait` waits for child tasks of the current task to finish before moving on. The current task will suspend until the wait is over. Also, as an aside, an `if` clause exists that you can add into the clauses after a directive, and if it is false, the openmp won't parallelize that section. It has the usual clauses:
* firstprivate, lastprivate
* shared, default
* if
* untied - task can be executed by different threads over a period of time
* priority(value) - higher value is higher priority, opposite of Unix priorities
* depend(type:list) - in, out, inout - dependencies on variables instead of specific places like before, you can also do array sub-ranges `A[start:end]`. `in` depends on a value being there as it will be read, `out` means it will be written to, `inout` is both.
