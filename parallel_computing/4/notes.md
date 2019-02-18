# 4.1.1
## OpenMP: Basics of Parallel For
OpenMP directives are expressed as pragmas.
```c
#pragma omp <clause>
```
Similar language exists for Fortran. If a directive is ignored by a compiler that doesn't use OpenMP, a program is still correct sequentially (usually). The `parallel for` construct means that the very next for loop can be executed in parallel. This does not work with a while loop, and will only work with a __restricted for__ loop, meaning the number of iterations must be known at the start of the loop. 

### Double Precision a * x + y (daxpy)

```c
void daxpy(double* z, double* a, double* x, double* y, int n) {
	for (i..n) {
		z[i] = a*x[i]+y[i]
	}
	return;
}
```
This loop can be done in parallel, there is no aliasing. You can control the number of threads with either `omp_set_number_threads(x)` or by using environment variables: `export OMP_NUM_THREADS=8` (in bash). 

# 4.1.2
## OpenMP: Enabling Parallelization
### Private Clause
This means that each thread has its own copy of each variable that is declared private, but the values are all undefined when the loop starts. You can assign values to them, but you cannot assume there is anything usable in those variables from before the loop. You cannot assume anything about their initial values as you don't know which order the threads will execute in. You cannot access the value of a private variable outside a loop either. 

There are two alternatives to `private`: `firstprivate` and `secondprivate`. `firstprivate(list)` initializes each thread's copy of a private variable to the value in the master thread. `lastprivate(list of variables)` specifies that for every variable in the list, write back to the master thread the value that was in the last iteration's copy of that private variable. `firstprivate` helps get values into private variables in loops. `lastprivate` helps get them out. 

What is wrong with the following example?

```c
#pragma omp parallel for private(tmp)
for (int i = 0; i < n; i++) {
	tmp = x[i] * x[i] * 3.1415;
	z[i] = tmp * x[i] + y[i];
	t[i] = tmp * y[i];
}	
printf("tmp = %f\n", tmp);
```

In parallel execution, there is no guarantee that `tmp` is the last value of the iteration. It could hold the first, or the second, or anything. It is undefined behavior. So, in order to make this execute as a sequential program would, you can change the private to lastprivate:

```c
#pragma omp parallel for lastprivate(tmp)
for (int i = 0; i < n; i++) {
	tmp = x[i] * x[i] * 3.1415;
	z[i] = tmp * x[i] + y[i];
	t[i] = tmp * y[i];
}	
printf("tmp = %f\n", tmp);
```
# 4.1.3
This is weird;
```c
for (i in 0..20) {
	tmp = x[i] * y[i];
	z[i] = tmp * x[i];
}
```

This is __not parallelizable__ because there is a read and write from the same variable. Another thread could end up using that same tmp and causing a race condition. But this is dumb, because we can see that if each thread had its own copy of tmp, this would work fine. There is no true interdependence. So, we explicitly make an array of tmps:

```c
#pragma omp parallel for
for (i in 0..20) {
	tmp[i] = x[i] * y[i];
	z[i] = tmp[i] * x[i];
}

```
Cool, now we can use `#pragma omp parallel for`. But this seems like overkill memorywise. 
We can also eliminate tmp entirely, by just replacing it with its definition:
```c
#pragma omp parallel for 
for (i in 0..20) {
	z[i] = x[i] * y[i] * x[i]
}
```


There is yet another solution. How could we make each thread have its own tmp? Remember that each thread has its own stack. We can use the `private` clause to give a separate copy of tmp to each thread's stack.
```c
#pragma omp parallel for private(tmp)
for (i in 0..20) {
	tmp = x[i] * y[i];
	z[i] = tmp * x[i];
}

```
Loop index variables are automatically private.

## Reduction Variables
How do we designate something as a **reduction variable**? 
example:
```c
int sum = 0;
for (int i = 0; i < N; i++) {
	sum += i
} 
```
Not parallel, because sum relies on the previous iteration. But logically, this should be parallelizable, because it doesn't matter which order you add things up in. 

Solution: The OpenMP **reduction(variable list) clause**. 
```c
int sum = 0;
#pragma omp parallel for reduction(+:sum)
for (int i = 0; i < N; i++) {
	sum += i
} 
```
Where `+` is the operation that is reducing. OpenMP supports multiple operations: +, -, \*, &&, ||, &, |, ^, max, min. A loop can have multiple reduction clauses. An array subsection can be a reduction variable as well:
```c
A[53:10]
```
denotes ten values of the `A` array, starting at index 53.

In summary, there are six ways to share data among threads:
* private
* shared
* default (private, shared, or none)
* reduction
* firstprivate
* lastprivate

The docs:
http://openmp.org/specifications

