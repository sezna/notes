# Programming Languages

## Logistics and stuff

### scheduling a test on proctorU
 * register on proctorU

# Lesson One
 * Tail Position (1.2.3)
    * A subexpression _s_ of expression _e_ is considered in to be in tail position if, when evaluated, _s_ becomes the value of _e_. 
    * Example:
     `if x > 3 then x + 1 else x - 1`
      if subexpression `x + 1` or `x - 1` is evaluated, it becomes the value of the entire `if` expression _e_. The expression `f(x + 1)` has no proper tail position, as `x + 1` does not become the value of `f(x + 1)`, it is instead passed in.
 * Tail Call
    * If a **function call** is in  **tail position** then it is a **tail call**.
**Tail calls** are noteworthy as they "implode" when returning their values up the chain unmodified. We can pass the final tail call value straight up to the first stack frame, or we can just recycle the same stack frame. This can mean no stack overflows for tail recursive functions(?). This is called **tail call elimination**, and in the machine code it has been optimized into a loop. 
 
When converting recursion to tail recursion, you often must generate an intermediate result and give it to the recursive call. 
