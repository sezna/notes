# 2.1.1
## First Class Functions
An _entity_ is said to be **first class** when it can be:
* assigned to a variable
* passed as a parameter. or
* returned as a result

The kind of data a program can manipulate changes the expressive ability of a language. Haskell, Lisp, and OCaml have decided that functions can be first class.

Consider the following function...

```haskell
compose :: (t1 -> t2) -> (t -> t1) -> t -> t2
compose f g x = f (g x)

inc x = x + 1
double x = x * 2

compose inc double 10 -- evaluates to 21, (10 * 2) + 1
```

In the type declaration of compose, `(t1 -> t2)` is the type of `f`, `(t -> t1)` is the type of g, and `t` is the type of `x`. `g` must return a `t1` so it can be passed into `f`. 

Another example is...
```haskell
twice f x = f (f x)
```

## Lambda Functions
the `\` is used in Haskell to denote a lambda function.

```haskell
\x -> x + 1

(\x -> x + 1) 41 -- evaluates to 42
```

The following expressions are equivalent via _eta equivalence_.
```haskell
plus a b = (+) a b
plus a = (+) a
plus = (+)

----
inc x = x + 1
inc = (+) 1
inc = (+1)

---- And some useful functions to think about...
f = \x -> f x

----
f z = (\x -> f x) z
```

The function `curry :: (a,b) -> c -> a -> b -> c` that will convert something that takes its arguments in as a tuple and split it apart to be a "normal" Haskell curried function.

# 2.1.2
## Mapping and Folding
### map
I defer to my familiarity with `map` as an excuse to not write up this section on mapping.
### foldr
The two arguments to `foldr` are the function and the base case. It applies the function and the base case to the first value in a list and then uses the result to "fold" into the next value in the list, repeating and "folding" the list into one value. 
```haskell
sumList xs = foldr (+) 0
-- sumList [1..10] = (0 (base case) + 1 + 2 + 3 + 4 ...)

productList xs = foldr (*) 1
-- productList [1..10] = (1 (base case) * 1 * 2 * 3 * 4 * 5...)
```
Other common higher order functions include:
* `all`
* `any`
* `zipWith`
* `takeWhile`
* `dropWhile`
* `flip`

Flip takes a function and flips its first two arguments, returning the resulting function.
```haskell
flip :: (a -> b -> c) -> (b -> a -> c)
flip f x y = f y x
```
```
takeWhile (< 3) [1,2,3,4,1,2,3,4] == [1,2]
takeWhile (< 9) [1,2,3] == [1,2,3]
takeWhile (< 0) [1,2,3] == []
```
# 2.2.1
## Product Types
**Product Types** are like tuples or records. How can we use _pairs_ and _records_ to represent product types?
Two functions built into Haskell are `fst` and `snd` which get the first and second values out of pairs (only pairs).


