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


### Getting Started

The starter code includes a parser. Parsers will be covered later, they're complicated.

To interact with the starter code:
* `stack build` compiles the interpreters
* `stack exec i1` runs the first interpreter
* `stack repl i1/Main.hs` will load the interpreter but give you a HASKELL prompt.
* `quit` to exit the interpreter.

It is often good practice to start by defining types. In `Types.hs`, we will need three types for our interpreter:
```haskell
data Exp = IntExp Integer
	deriving (Show,Eq)

data Val = Intval Integer
	deriving(Show,Ew)

type Env = [(String,Val)]
```
(At first, we will only support integers).

Now, we are equipped to write some code to evaluate expressions. In `l1.hs`, we can:
```haskell
eval :: Exp -> Env -> Val -- an expression, coupled with an environment, returns a value
eval (IntExp i) _ = IntVal i -- the identity; if no environment is specified, the intval is returned.
```
We can now use `stack repl` and `main` to launch the interpreter. 

### Adding Arithmetic and Abstract Syntax Trees
By adding the following to the `Exp` type, we are able to make a tree structure for expressions.
```haskell
data Exp = IntOpExp String Exp Exp
	| ...

-- Now, to represent 3 + 4 * 5
IntOpExp "+" (IntExp 3)
	(IntOpExp "*" (IntExp 4) (IntExp 5))
```

### Making a dictionary to look up expressions
```haskell
intOps = [ ("+",(+)),
	   ("-",(-)),
	   ("*",(*)),
	   ("/",(div))]

liftIntOp f (IntVal i1) (intVal i2) = IntVal (f i1 i2)
liftIntOp f _            _          = IntVal 0
```

`liftIntOp` takes our `IntVal` types and extracts their values, applying them to the function as normal integers. We have added a second clause to return 0 if we get something that doesn't make sense. This is terrible language design but we will come back to it later. 

Our new eval in `i2`:
```haskell
eval (IntOpExp op e1 e2) env = 
	let v1 = eval e1 env -- evaluate the two branches of the node
	    v2 = eval e2 env 
	    Just f = lookup op intOps -- Get op out of lookup table
	in liftIntOp f v1 v2 -- Lift ints and apply them to looked-up haskell function
```

`i3` is `i2` with some extra operations and features added. 


# 3.1.2 Interpreters 2

We once again start with types.
```haskell

data Exp = IntExp Integer
	| IntOpExp String Exp Exp
	| RelOpExp String Exp Exp -- greater/less than
	| BoolOpExp String Exp Exp -- and/or
	| BoolExp Bool -- bool expressions themselves
   deriving (Show,Eq)

data Val = IntVal Integer
	| BoolVal Bool
    deriving(Show, Eq)
```

We similarly need a boolean operations table.
```haskell
boolOps = [ ("&&",(&&)),
	    ("||",(||))]

liftBoolOp f (BoolVal i1) (BoolVal i2) = BoolVal (f i1 i2)
liftBoolOp f _            _            = BoolVal False

eval (BoolExp b) _ = BoolVal b

eval (BoolOpExp op e1 e2) env = 
	let v1 = eval e1 env
	    v2 = eval e2 env
	    Just f = lookup op boolOps
	in liftBoolOp f v1 v2
```
