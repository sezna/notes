# 1.1,1a
* Computers are made up of "the modest switch", high voltage or low voltage gates that can represent boolean values.
* Can be wired for or and and gates
* You can make adders
* You can make memory 
The fundamental idea that allows the creation of memory is **feedback**. We make a loop in the circuit so the circuit outputs are inputs as well. 
A modern computer contains adders and memory. There is intruction memory, an ALU, a program counter, register set, and data memory.

# 1.1.1b
## How to make switches
Switches can be made with mechanical or hydraulic power, or electromagnets, but more commonly are made with semiconductor transistors. In 1837, Charles Babbage thought of the idea of the processor and made a "difference engine". He designed it but was unable to build it in his lifetime. Ada Lovelace was the first person to have the concept of programming, and could be considered the first programmer. Konrad Zuse made a machine that could do loops but had no conditional execution, so it was limited. This happened in 1940, then in 1941 Alan Turing made _Bombe_, the machine for decoding the German _Enigma Machine_. During WWII, modern designs based on vacuum tubes were made. In the 1960's, integrated circuits with multiple transistors were created, then in 1971 Intel released their first microprocessor. 

# 1.1.2
## Moore's Law
* In our simple computer, a single instruction is executed in a clock cycle. Instruction is fetched from memory, operands fetched, arithmetic performed, results are stored. 
* Clock time is specifically selected so parts can finish their work before the next one starts.
* Gates/Switches have two important properties: size, and switching/propogation delay.
* Smaller transistors can switch faster, as they contain less electrons. 
* With smaller transistors, cost decreases. Performance increases. This leads to...

**Moore's Law**.

The number of transistors on a chip roughly doubles per year, and will probably continue for ten years (from 1965). This empirical observation ended up holding for at least 50 years, and is still holding. Clock frequencies stopped being better after 2003ish, though. This is because chips were just getting way too hot. After 2005, while the number of transistors kept increasing, power/heat/speed started stagnating. Soon, Moore's law will break as we cannot make transistors smaller than an atom. 

# 1.1.3
In the end, Moore's Law will break and we will get to 30-50 billion transistors per chip. 

## How did we take advantage of the extra transistors?
One way we have increased speed is by putting more cores on a chip. That worked, and logically separated processors, allowing for parallelism. The individual cores were not faster, but being able to have them work in parallel helps a lot. We are now in the era of parallel programming, where the only way to fully utilize a processor is to program in parallel effectively. 

## Applications of highly parallel processing
* Speech recognition
* Machine learning/AI
* Real-time video processing
* Search algorithms, scanning files
* Data centers
* HPC in general (High Performance Computing)

# 1.1.4
## Predicting the Future
### Multicore Computers
* Desktops
* Laptops
* Cell phones
* Individual nodes in HPC clusters
* Server nodes
* General purpose GPUs

The biggest impact will probably be on small clusters. Every company can afford a decent cluster. Fashion designers may need to simulate clothes draping over a model's body before manufacturing it. Business strategies are needed. Even customers in a clothing store may want to simulate themselves wearing clothes. Supply chain optimization is another big area of demand...

### Supercomputers
By 2022, there will be at least exaflop machines. Society will continually demand more powerful computers.
After Moore's Law ends, innovation will shift to application optimization and functional performance. In 7 to 10 years, processor speed will probably become totally stagnant.


# 1.2.1
Modern processors attain their performance through a cost of increased complexity which we must deal with. 

# 1.2.2
## Performance vis Complexity: What are the obstacles to speed?
* Gate delays
* Floating point computations
* Memory is slow

## Latency vs. Throughput
Think of a bucket brigade, or any assembly line. The latency is related to the length of the pipeline and is how much time transpires between putting something in the pipeline and getting it out. This is different from throughput, though, because once the latency period has ended, you can start getting things in rapid succession out the end of the assembly line. We want to increase throughput as much as possible.

So, we pipeline in processors. It is sort of an assembly line. As an instruction is decoded and sent to retrieve the memory or go to the ALU, another instruction is loaded from memory and decoded, etc. 

**Hazards, or bubbles** stall the pipeline. They come in two varieties:
* Data hazards: instructions which need results from previous instructions
* Control hazards: conditional execution. I don't know where the next instruction is without first evaluating this instruction.

We can address data hazards with **data fowarding**. In addition to storing a result in a register, forward it into the next instruction in the pipeline buffer.

We attempt to address control hazards with guessing, or **branch prediction**. If a loop runs a lot, you can do a relatively basic statistical analysis and guess. If it goes wrong, you are penalized, but not as much as the benefit from getting it right (?).

## Branch prediction
Consider the following code:
```
for (i in 0...n) {
	if n > data[n] then sum += 5
}
```
If `data` is random numbers, the branch prediction can't make any guesses. If `data` is sorted, then after a certain point `n` will always be greater and the branch prediction can get 100% accuracy. This sorting allegedly speeds up the code five fold.

You can program keeping branch prediction in mind to avoid branch misdirection. 

## Minimizing the damage of floating point operations

With floating point numbers, you first have to compute exponents and shift them so they match, and then deal with the results. Multiplication of exponents is harder than basic adding as well. It is actually beneficial to have a specific hardware unit for floating point arithmetic to do multiplication and addition together. 

# 1.2.3
## Memory Access Challenges
_footnote: 1 nanosec clock cylce = 1GHz_
What is a memory access challenge? 
1.  DRAM: Large, inexpensive, non volatile memory. ~50ns latency. Stands for dynamic random access memory, and dynamic is a bad thing. The memory we discussed earlier with feedback loops requires at least six transistors per bit, which is expensive. Instead, this just uses capacitors. They lose their charge over time and need to be refreshed, hence dynamic. This memory is inexpensive but slow.
2. Our clock cycles are in excess of 2GHz, which means about half a ns per clock. This memory access time is very slow.
3. We can build faster memory, or utilize bandwidth. The latest chips have memory stacked in the third dimension. If latency is a big issue, we can try to compensate with bandwidth like a bucket brigade.
4. If we can shift our problems from latency to bandwidth, we can compensate. 
 We can make faster memory, a cache. It necessarily has to be smaller, though, as more space means it is harder to address individual spots.
DRAM is off-chip, while cache memory is on-chip, small, expensive, and very fast.
**Temporal and Spatial Locality**: Programs tend to access the same and/or nearby data repeatedly. 
Since bandwidth is easier to acquire, when you get a piece of data you can also get a ton of nearby data with it for free. That free data is called a cache line, and is typically between 32-128 bytes. Increasing spatial locality helps facilitate this process.

We typically have, in order from fastest to slowest, L1, L2, and L3 caches with L3 potentially being off-chip, and then DRAM. 

# 1.2.3b
## Some basic benchmarks worth knowing.
* Modern processor: latency of .25ns
* L1 cache: several ns
* L2-L3 cache: 10s of ns
* DRAM: 30-70NS
* SSD: 0.1ms

