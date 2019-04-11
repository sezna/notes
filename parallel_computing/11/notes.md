# 11.1.1
## Cost Model
How to estimate communication costs and total execution time

### A simple model for message passing

The messaging cost is `a + n * b`  where `a` is the cost per message, `b` is the cost per byte, and `n` is the size of the message in bytes. For some intuition, assume `a` is 1000 times larger than `b`. The per message cost may be one microsecond on a supercomputer, and tens of microseconds on commodity clusters. The per byte cost may be as low as 1ns. When we say messaging cost, we mean latency combined with overhead of the processor.

This model assumes the network has no contention, i.e. there are no impacts of network overload or bandwidth overflows being considered. It assumes the latency is a constant, and not dependent on physical distance (which is mostly true), and it ignores packetization and per-packet overhead costs.

### Communication co-processor and CPU overhead
CPIP overhead is how much time is taken away from the CPI to deal with communication. There are function calls, potential data copying, setup and interaction with the network, and in MPI, tag matching. A co-processor (a modern NIC works) "off-loads" __some__ of this overhead.

### Communication basics: point-to-point

total time = sending processor time + sending co-processor time + network + receiving co-processor time  + receiving processor time

Except when stated otherwise, we will use this simple `a + n * b` model in this course, without separating out the overhead. 

### Overall Cost Model
The execution time (aka completion time) can be modeled, for many applications, as communication cost. `T = T_comp + T_cost`. This assumes that all processors are doing the same work, there is no overlap of communication and computation, and that with overlap, `T = T_comp + T_comm - T_overlap`. The overlap is computation done while the communication time is happening.

We need to do this analysis for each processor separately, or if they are unbalanced, go by the worst loaded processor. The critical path, which is a chain of dependencies in communication, that can also bottleneck the speed. You need to analyze this manually to determine if you have a critical path bottleneck. 

### Other Models
* LogP - Latency, overhead, gap, processor. Gap is the minimum time in between messages.
* LogGP - generalizes logp to arbitrarily sized messages, and this starts to resemble `a + n * b` with overhead

# 11.1.2
## Cost Model: Examples

# 11.1.3
## One-sided communication

We have looked at two types of communication thus far: point-to-point communication which is things like sends, recieves, etc, and collective communication, which is things like broadcasts, gathers, etc.

Now, let's look at one-sided communication, which is a type of point-to-point communication.

Thus far, our p2p communication has been two sided, meaning there is a sender and a receiver who must both be involved with separate logic. The basic idea of one-sided communication models is to decouple data movement with process synchronization. 
* You should be able to move data without requiring that the remote process synchronize
* Each process exposes a part of its memory to other processes
* Other processes can directly read from or write to this memory.

So, a process has a private memory region which only it can access, and a public memory region which every process can access. Combining all of these public memory regions constitutes a global address space, which allows you to use gets and puts all over the processes. This removes the entire overhead of packaging, sending, matching a receiver, unpackaging, etc. in MPI two-sided communication. 

In order to implement this model, each process needs a __window__ into the other processes' memory. This can be created via one of the following four models:
* `MPI_WIN_CREATE` - you already have an allocated buffer that you would like to make remotely accessible 
* `MPI_WIN_ALLOCATE` - you want to create a buffer and directly make it remotely accessible
* `MPI_WIN_CREATE_DYNAMIC` - you don't have a buffer yet, but will have one in the future
* `MPI_WIN_ALLOCATE_SHARED` - you want multiple processes on the same node to share a buffer, we won't cover this model today

### `MPI_WIN_CREATE`
```c
int MPI_Win_create(void *base, MPI_Aint size, int disp_unit, MPI_Info info, MPI_Comm comm, MPI_Win *win)
```
* base - pointer to the local data you want to expose
* size - size of the local data in bytes (a non-negative integer)
* disp\_unit - local unit size for displacements, in bytes (positive integer)
* info - info argument (handle)
* comm - communicator (handle)

Example with `MPI_WIN_CREATE`:
```c
int main(int argc, char ** argv) {
	int *a;
	MPI_Win win;
	MPI_Init(&argc, &argv)l
	
	/* create private memory */
	a = (void *) malloc(1000 * sizeof(int));
	
	/* use private memory normally */
	a[0] = 1;

	/* collectively declare memory as remotely accessible */
	MPI_Win_create(a, 1000 * sizeof(int), sizeof(int), MPI_INFO_NULL, MPI_COMM_WORLD, &win);

	/* array a is now accessible by all processes in comm_world */

	MPI_Win_free(&win);
	free(a);
	MPI_Finalize();
	return 0;
}
```

#### Data movement: `Get`
```c
MPI_Get(origin_addr, origin_count, origin_datatype, target_rank, target_disp, target_count, target_datatype, win);
```
Move data __to__ origin, __from__ target. Separate data description triples for origin and target. `target_disp` is the displacement inside of the publicly accessible window of the target.

#### Data movement: `Put`
```c
MPI_Put(origin_addr, origin_count, origin_datatype, target_rank, target_disp, target_count, target_datatype, win);
```
Move data __from__ origin, __to__ target. Same arguments as `MPI_Get`. 

#### Data aggregation: `Accumulate`
This is like `MPI_Put`, but this applies an `MPI_Op` instead. This only allows predefined ops, not user-defined ones. The result ends up in the target buffer.

#### Additional Atomic Operations
* `compare-and-swap` - compares the target  value with an input value; if they are the same, replace the target with some other value. This is useful when creating linked lists, if the next pointer is NULL, do something else.
* `fetch-and-op` - fetch old value and perform an op at the target with the provided value. For example, add 1 to the target and give me the old value. 

#### Fence: Active Target Synchronization
This is a collective synchronization model which starts __and__ ends access and exposure epochs on all processes in the window. All processes in a group of "win" do an `MPI_WIN_Fence` to open an epoch. Everyone can issue PUT/GET operations to read/write data. Then, everyone does another win\_fence to close the epoch. All operations complete at the  second fence synchronization. 
