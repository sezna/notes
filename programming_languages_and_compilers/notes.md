# 3.1.1
## Interpreters
There are two ways to execute code on a computer: **interpreting** and **compiling**. 

### Parts of an Interpreter
* The **parser**
* The **evaluator**
* An **environment**
* A top-level **REPL**, or **Read Evaluate Print Loop**

The parser converts (typically ASCII) input into an **abstract syntax tree**, and hands that off to the evaluator. The evaluator processes the abstract syntax tree and yields a result. A function is required to evaluate the expressions into values. This all runs inside of an environment which keeps track of variable values, and is interacted with via the REPL. 

We are going to write a toy interpreter for a simple functinal language. We will include the following features:
* Integers
* Variables
* Arithmetic (+, -, \*, /)
* Comparisons (<, <=, >, >=, =, !=)
* Booleans and boolean operations
* Local variables (via `let`)
* Conditionals (`if`)
* Functions 


