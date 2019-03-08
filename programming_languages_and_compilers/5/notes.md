# 5.1.1
## Continuations
**Continuations** are a functional representation of what comes next in a computer program or computation. We can pass these into functions, just like any HOF.

Objective: Define **CPS**, or **Continual Passing Style**. 

Consider the following code:
```haskell
inc x = x + 1
double x = x * 2
half x = x `div` 2
result = inc (double (half 10))
```

In the execution of `result`, `half` will first calculate half of 5. Then, `double` will continue the calculation where `half` left off and take `half`'s output. Lastly, `inc` will continue the computation by processing `double`'s output.
We can take this idea of continuing very explicit. Imagine we take a subexpression and "punch" it out of the containing expression. In this example, let's punch out `half 10` from the expression. The result is a computation with a __hole__ in it. 
```haskell
result = inc (double <hole> )
```

__footnote__ <hole> is typically surrounded in __semantic brackets__ which are like double [brackets], but I can't type those.

This expression with a hole in it is called a **context**. After we run `half 10`, it will be put into this context. This context can also be called a **continuation**. 

We can make continuations explicit:

```haskell
continuation = \ v -> inc (double v)
```
__footnote__ it is convention to call a continuation's argument `v`. `v` here corresponds to the "hole" above. 

The __continuation argument__ is usually given the name `k`. 

```haskell
half x k = k (x `div` 2)
result = half 10 cont
``` 

Here, we are parameterizing the __return__ keyword. `cont` can be seen as __return__ in other non-Haskell languages. 

### Properties of CPS
* A function is in **direct style** when it returns its result back to the caller.
* A **tail call** occurs when a function returns the result of another function call without processing it first. This is used in accumulator recursion.
* A function is in **Continuation Passing Style** when it passes its result to another function. Instead of returning the result to the caller, we pass it forward to another function. Functions in CPS "never return".

### Examples
Here are the initial functions  modified to use CPS:
```haskell
inc x k = k (x + 1)
double x k = k (x * 2)
half x k = k (x `div` 2)
id x = x
result = half 10 (\v1 ->
         double v1 (\v2 ->
         inc v2 id))
```
`half` takes two arguments: an number and a continuation. What do we give it to continue on to? Well, it needs to continue on to `double`. So, in `double`, we give it the result of `half` in `v1`, and the give `double` itself a continuation on to `inc`. Etc. etc.

Eventually, `inc` wants a continuation, so we pass it the identity function `id` to get the result back. CPS can look imperative if you do it correctly:

```haskell
	v1 := half 10
	v2 := double v1
    result := inc v2
```

What would CPS be useful for?

Problem: Compute the GCD of two numbers.

```haskell
gcd a b | b == 0 = a
        | a < b = gcd b a
        | otherwise gcd b (a `mod` b)
-- this uses recursion. gcd 44 12 => gcd 12 8 => gcd 8 4 -> gcd 4 0 => gcd 4 0 => 4
```
GCD of a list?
```haskell
gcdstar [] = 0
gcdstar (x:xs) = gcd x (gcd star xx)

gcdstar [12, 14, 6, 10]
gcdstar [1, 8, 6, 24] -- a lot of unnecessary work
```
A basic folding recursion to apply `gcd` to a list. If there was a 1 near the beginning of a sequence here, a lot of unnecessary multiplications happen. 
In the following example, we use CPS to optimize this.

```haskell
gcdstar xx k = aux xx k
	where aux [] newk     = newk 0
	      aux (1:xs) newk = k 1
	      aux (x:xs) newk = aux xs(\res -> newk (gcd x res))
id x = x
-- gcdstar [20, 6, 1, 34] id = 1
```

Here, `aux` has access to both the original continuation `k`, which continues on to after the gcd calculation, and the new continuation `newk` which is powering through the list of numbers. If `aux` sees a 1 in the list, it aborts `newk` and just continues on to whatever was after `gcdstar` with value 1, without calculating the rest of the list. This can be perceived as an exception. We broke out of a loop/recursion. Using continuations in a more advanced way, you can simulate cooperative  multitasking (co-routines) or other advanced routines (call/cc, shift, reset).

# 5.1.2
## The CPS Transform
We want to convert direct style to CPS. There are a lot of CPS transforms, if we look around, we will likely find many versions. Some algorithms convert all subexpressions, even if they don't need to be, and this can result in a complicated result. Ours discriminates and doesn't convert subexpressions that don't need to be converted.
### CPS Transform Algorithm Rules
#### Expression Basics
**Top Level Declaration:** To convert a declaration, add a continuation argument to it and then convert the body.
```
C <hole f arg = e /> => f arg l = C <hole e />_k
```

Here, we have added a continuation `k` to `f` and returned continuation `k` with value `e`.

**Simple Expressions**: A simple expression in tail position should be passed to a continuation instead of returned.
```
C <hole a />_k => k a
```
Simple here means no functions are executed in the expression. 
```haskell
func f a = 3 + f a -- not simple, f a is available/going to be executed
func f a = \x -> 3 + f a  -- simple, as we are not executing f a yet, it is not available.
```

Try converting the following functions...
```haskell
f x = x
pi1 a b = a
const x = 10

-- converted to CPS by me:

f x k = k x
pi1 a b k = k a
const x k = k 10

```
yay, I got them right!

#### Function Calls
**Function call on a simple argument**: To a function call in tail position where `arg` is simple, pass the current continuation:
```
C <hole f arg />_k => f arg k
```

**Function call on non-simple arguments**: If `arg` was not simple, we first convert it. 
```
C <hole f arg />_k => C <hole arg />_new continuation (\v -> f v k), where v is fresh
```

Try converting these:
```haskell
foo 0 = 0
foo n | n < 0 = foo n
      | otherwise = inc (foo n)

-- converted to CPS by me:
foo 0 k = k 0
foo n k | n < 0 = k (foo n)
        | otherwise = k (inc (foo n))
```

I was __wrong__!

It should be:
```haskell
foo n k | n < 0     = foo n k
        | otherwise = foo n (\v -> inc v k)
```

I should have created a new continuation to go on to `inc`.

#### Operators
**Operator with Two Simple Arguments**: If both arguments are simple, then the whole thing is smple. 
```
C <hole e_1 + e_2 />_k => k(e_1 + e_2)
```
~I think `+` is concatenation of arguments here.~ Nope, it is the operator. Duh, Alex. Duh. 
**Operator with One Simple Argument**: If only `e_2` is simple, we transform `e_1`.
```
C<hole e_1 + e_2 />_k => C<hole e_1 />_ new continuation (\v -> k (v + e_2) )
```

The new continuation passes the evaluated `e_1` into a continuation where both arguments are simple, so we can use the first rule of this section.

**Operator with Two Simple Arguments**: Both operators need to be transformed.
```
C<hole e_1 + e_2 />_k => C<hole e_1 />_new continuation \v -> C<hole e_2 />_ new continuation \v2 -> k(v + v2)
```
We create a new continuation which calls the second rule of this section which calls the first rule of this section, I think (?).

Try to convert these:
```haskell
foo a b = a + b
bar a b = inc a + b
baz a b = a + inc b
quux a b = inc a + inc b

-- converted to CPS by me:

foo a b k  = k (a + b) --everthing is simple, so hopefully this is rule one
bar a b k  = \v -> k (v + b) -- inc a must be evaluated, this is rule 2
baz a b k  = \v -> k (a + v) -- rule 2?
quux a b k = \v1 -> \v2 -> k (v1 + v2) -- rule 3?
```

I was wrong again! I needed to actually include the `inc` which I forgot.

```haskell
bar a b k = inc a (\v -> k (v +  b))
baz a b k = inc b (\v -> k (a + v))
quux a b k = inc a (\v1 -> inc b (\v2 -> k (v1 + v2)))
```
i
# 5.2.1 
## Polymorphism and Basic Classes
There are many ways to implement polymorphism. Templates, overloading, inheritance, and more. Haskell has **type classes**. 
```haskell
class Eq a where
	(==), (/=) :: a -> a -> Bool
	-- For something to be Eq, it must implement (==) or (/=), because the default ones
	will cover the other case.

	
	-- default definitions:
	x /= y  = not (x == y)
	x == y  = not (x /= y)
```
In order to make a type a member of a type class, we use use the **instance** keyword.
```haskell
instance Eq Foo where
	(==) (Foo i) (Foo j) = i == j
```
We don't define `(/=)` and implicitly use the default definition for it. Now `Foo` is a member of `Eq`. 
There are a lot of basic type classes that can be derived, or inferred:
```haskell
data Foo = Foo Int
	deriving Eq
```

Other typeclasses:
* Ord: `<`, `<=`, `>`, `>=`
* Show: `show :: a -> String`
* Read: `string :: String -> Foo` (needs to know return type)
* many more exist
# 5.2.2
## Functors and Applicatives
__(we will leave monad for another video)__
For example, we want to write `map` for `Tree`:
```haskell
data Tree a = Node a [Tree a]
data Maybe a = Just a | Nothing
```

### The Functor Type Class
```haskell
class Functor f where
	fmap :: (a -> b) -> f a -> f b
```
Takes a function from `a` to `b`, a container containing `a`s, and returns a container containing `b`s, where `f` is the container. 

Let's practice making things functors and using fmap (functor map) on them.
```haskell
let incAnything x = fmap (+1) x
incAnything [10, 20] -- evals to [11, 21]
incAnything (Foo 30) -- we want to be able to get Foo 31 back, but we must first make Foo a functor.

-- Done by me, I think this will work?
instance Functor Foo where
	fmap f [] = []
	fmap f (Foo x):xs = (f x):(fmap f xs)

```
We can take this up one level. 
### The Applicative Functor
```haskell
class (Functor f) -> Applicative f where
	pure a :: a -> f a
	f (a -> b) <*> f a :: f b
```
The `<*>` operator takes two containers, one containing a function from `a` to `b` and one containing an `a`. It returns a container with a `b`. This is called a lifted function application. Contrast this with `fmap`, which is on the "ground level", because the function input is not in a container. This operator takes its second argument and applies it, lifted to the level of the container `f`. `pure` appears to take a regular value and put it in the container. This is the opposite of my intuition for pure, but whatevs.

`<$>` is often used as an alias for `fmap`. 
