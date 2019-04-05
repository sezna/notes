# 9.1.1
## Send/Receive Variants

__warning: this section has no structure and he just kinda rambles in the lecture__


When using send and recv, there are issues that arise. There is a cost to copying data when sending a message, there is an overhead to buffer availability and allocation, data must be packaged up, you must match tags, and 

In a __ping pong__ program, two threads will send data back and forth. This has a lot of overhead from copying and packeting the messages frequently. We have some ways to reduce copying cost. 

Sometimes these copies need to be made into MPI buffers, and we need to keep track of if we have enough MPI buffers. 

Finding and matching tags can be hard.

When passing a message, the message gets packaged, copied into the sending device's MPI library buffer, then sent to the receiving device's MPI library buffer, then decoded. This is a fair bit of overhead. You also probably need to break down a packet into smaller sizes before sending. A receiving device can also say it isn't ready to receive a packet yet.

### Messaging Protocols
A message consists of an "envelope" (header) and data. Envelopes contain a tag, a communicator, the length of the data, the information about the source, and implementation-specific private data. Different MPI implementations use different protocols for different messages. 
* Short - data fits inside the header, so you just put it there.
* Eager - you send and just assume the destination has enough storage, usually used for smaller messages.
* Rendezvous - header sent first, wait for permission, send data

### Basic MPI Terminology
* Immediate - Operation does not wait for completion. Also called non-blocking.
* Synchronous - Completion of a send __requires__ initiation, but not completion, of a receive 
* Buffered - The MPI implementation can use a buffer the user has already supplied to it for its internal copies
* Ready - Programmer guarantees a matching receive has already been programmed but MPI doesn't check
* Asynchronous - Communication and computation take place simultaneously. This isn't an MPI concept, but it is a common implementation strategy. 

### Basic Send/Receive modes
* MPI\_Send - could potentially wait for matching recv based on implementation
* MPI\_Recv
* MPI\_Ssend - sends but waits for matching recv to start (synchronous send)
* MPI\_Rsend - expects matching receive to be already posted (ready send)

MPI\_Send and MPI\_Recv are not controlled by the standard, they will just send and receive data in general. 

### Nonblocking Modes
* MPI\_Isend - Returns immediately, but does not finish until the send buffer is abailable for reuse
* MPI\_Irsend - Expects a matching receive to be posted when called
* MPI\_Issend - Does not compute until buffer is abailable and matching receive posted
* MPI\_Irecv - Does not complete until a receive buffer is available for use

### Completion
* MPI\_Test - nonblocking test for the completion of a nonblocking operation
* MPI\_Wait - blocking test
* MPI\_Testall,  MPI\_Waitall - used to wait for all calls
* MPI\_Testany, MPI\_Waitany 
* MPI\_Testsome, MPI\_Waitsome
* MPI\_Cancel

### Persistent Communications
Often, the same communication happens over and over. You can package up a buffer ready to send with send init, and then later on send it whenever you need. 
* MPI\_Send\_init
* MPI\_Start
* MPI\_Startall
* MPI\_Recv equivalents

### Testing
* MPI\_Probe -  blocking test for a message in a specific communicator
* MPI\_Iprobe - nonblocking test

For the above tests, you can use a wildcard tag for dynamic communication patterns. There is no way to test in all or any communicators like the completion section.

### Buffered Communications
__Hey MPI, don't worry about the buffers, I will handle them.__

* MPI\_Bsend - uses user-defined buffer
* MPI\_Buffer\_attach - Defines buffer for all buffered sends
* MPI\_Buffer\_detach - completes all pending buffered sends and releases buffer
* MPI\_Ibsend - nonblocking version of Bsend

### Why do we need so many commands?
There are trade offs with complexity and ease of use. Many MPI programmers just use send, wait all, and recv. This is very basic but not always perfectly optimal.


# 9.1.2
## MPICollectives: Reductions and Broadcasts
Everyone within a communicator must make a call before that call can be effected. Essentially, a collective call requires coordination among all the processes of a communiator.
* `MPI_Barrier(MPI_Comm comm)` - blocks the caller unntil all processes have entered the call
* `MPI_Bcast(void* buffer, int count, MPI_Database datatype, int root, MPI_Comm comm)` - Broadcasts a message from rank 'root' to all processes of the group. This is called by all members of the group using the same arguments.
* `MPI_Allreduce(void* sendbuf, void* recvbuf, int count, MPI_Datatype datatype, MPI_Op op, MPI_Comm comm)` - Takes a communicator and send/recv buffers. This takes the data off the send buffer of every process, apply the MPI operation to each send buffer, and put the result in the recv buffer. Operations are typically commutative and associative. 
* `MPI_Reduce(void* sendbuf, void* recvbuf, int count, MPI_Datatype datatype, MPI_Op op, int root, MPIComm comm)` - Similar to Allreduce, the result goes to everyone. It puts the result value in a single process's buffer,  specified by `int root`.

# 9.1.3
## More Collectives
* `int MPI_Bcast(void* buffer, int count, MPI_Datatype datatype, int root, MPI_Comm comm)` - broadcasts a piece of data into every process's buffer. 

`MPI_Gather` takes a value from every process and puts them all into one process, and `MPI_Scatter` takes a collection of values in one process and s catters it out to every process.

`MPI_Allgather` gathers all data into a single process and then broadcasts it out to everybody. 

`MPI_AlltoAll` is like a matrix transpose. All of value 1 from all processes goes into process 1, all of value 2 goes into process 2, etc. 

These approaches only work if all data is the same size. There are variants of these with the letter "v" appended on the end, and they allow for variable sized data. There are also versions with "I" prepended for nonblocking features. 

# 9.1.4
## MPI Sub-Communicators
A communicator represents a set of processes. Each member process has a rank in that communicator. So far, we have only used `MPI_COMM_WORLD`, which has all the processes of a program contained with it. In this lecture, we will introduce how to create new communicators via `mpi_Comm_split`, by splitting an existing communicator. 

Cartesian communicators "reshape" or reorganize an existing set of processes in an existing communicator into a multi-dimensional structure via `mpi_Cart_create`. This does not split a communicator, rather, it does things like let you think of 100 communicators as 10x10, or 5x5x5, or something like that.


### Example of a 2d communicator:
```c
MPI_Comm comm2d;

MPI_Cart_create(MPI_COMM_WORLD, 2, dimSize, periodic, 0, &comm2d);o

int myRow, myCol;
MPI_Cart_coords(comm2d, myrank, 2, myCoordsBuff);
myRow = myCoordsBuff[0];
myCol = myCoordsBuff[1];

MPI_Comm commRow, commCol;
MPI_Comm_split(comm2d, myRow, myCol, &commRow); 
MPI_Comm_split(comm2d, myCol, myRow, &commCol);
```

# 9.1.5
## Parallel Algorithms in MPI: Prefix Sum Part 1

The **prefix sum problem** is: given an array, produce another array such that each element is the sum of all previous indexes in the initial array. i.e.:

```
A = [1,3,3,1, 5, 2]
B = [1,4,7,8,13,15]
```

How would we do this with these MPI style commands? B[3] can be computed as the sum of A[1] + A[2] + A[3], or B[2] + A[3]. This seems inherently sequential, with dependencies on the previous iterations. This is why we have the recursive doubling algorithm.

The first iteration, you send your value to the next process. Then in the next iteration, you send two over. Then, three over. Etc. 

Pseudocode for parallel prefix with MPI is at 10:50 in 9.1.5. 

# 9.1.6
The function commonly called `scan`, which is also known as a parallel prefix, has some useful applications. What if you have a collection of sorted numbers, but they are not distributed evenly across processors? How would you load balance without losing their sorted-ness? See 4:18. 
