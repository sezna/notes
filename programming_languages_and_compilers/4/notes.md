# 4.1.1 Semantics
* Define **judgment**, which is something that asserts a property about a piece of code or syntactic object
* **proof rules**, recursive inductive objects which define when judgments are valid
* **proof trees**, which look like proof rules stacked together to prove something about more complex syntactic object

## Judgments
A judgment is an assertion about a syntactic object. Example: 3 is odd. Asserting the object 3 is odd is a judgment.

A **rule** tells us when a judgment is true and when it is not true. We can define judgments inductively from sets of judgments called **assumptions** or **premises**. If a judgment has no assumptions or premises, it is an **axiom**. To see, visually, how this works, see the 4.1.1 video.

A **side condition** is a premise that is not a judgment. It is written off to the right side of a rule. 

## Building Proof Trees
When you build a rule, sometimes the conclusion is complicated enough that the premises need to be proved. This makes a recursive structure and forms a proof tree. In real life, you typically start with your conclusion and work backwards to figure out what you need to prove. 

# 4.1.2 Big Step Semantics

