# 6.1.1
## Monads
* What problems do monads attempt to solve?
* What are the three "monad laws"?
* What is the syntax for declaring monadic operations?
* How do monads work for the list and maybe types?

A **monad** is a container type `m` with two functions: `bind` and `return`. 
```haskell
return :: a -> m a -- like `pure` from the applicative type class. this puts a value inside of a monad.
bind :: m a -> (a -> m b) -> m b -- 
```
In Haskell, `bind` is written as `>>=`. 

These two functions must obey three rules:
* Left identity: `return a >>= f` must be the same as `f a`
* Right identity: m >>= return` is the same as `m`
* Associativity `(m >>= f) >>= g` is the same as `m >>= (\x -> f x >>= g)`

`bind`'s job is to unpack a monad, feed its contents into a function, and collect whatever monadic results come out of that function. It will then package that up into a single monad. 

Bind for `Maybe`:
```haskell
Nothing >>= f = Nothing
(Just a) ==> f = f a
	-- f must return a monad here
```
Then what is the difference between monads and applicatives? With an applicative, the function we would have given it would have returned a ground level function, and then the applicative operator would have lifted it into a just. With monads, the function itself gets to decide whether to return `just` or `nothing`.

Applicatives take the values out of containers, run them, and then repackage them into containers as it sees fit. Monads let the functions themselves return an already-contained value however it sees fit. 

```haskell
monadInc x = x >>= (\y -> return (y+1))
monadAdd x y = x >>= (\xx -> 
               y >>= \yy -> return (x + y))
```

In order to make things easier, there is a package called `Control.Monad`. It contains these functions:
```haskell
liftM f a = a >>= (\aa -> return (f aa))
liftM2 f a b = a >>= (\aa -> 
               b >>= \bb -> return (f a b))
```

These take a function and return a monadified version of it. With this new lifting ability, we can simplify things:
```haskell
monadInc x = liftM inc
monadAdd x y = liftM2 add
monadSub x y = liftM2 sub
monadDiv x y = x >>= (\xx ->
               y >>= (\yy ->
		if yy == 0 then fail "/0"
			else return (aa `div` bb)))
```
`div` is rough because we must check out if we are diving by zero.

The `fail` function is not mathematically a necessary part of a monad, but because monads are often used to handle errors, it is included in the typeclass `MonadFail` for convenience. Not all monads can use it.

### The Maybe Monad
```haskell
instance Monad Maybe where
	return = Just

	(>>=) Nothing = Nothing
	(>>=) (Just a) f = f a -- gives the function a chance to determine what to return

	fail s = Nothing
```


### The List Monad

```haskell
instance Monad [] where
	return a = [a]

	(>>=) [] f = []
	(>>=) xs f = concatMap f xs -- concatMap takes [[]] and turns it into [], since f xs will be [[]]

	fail s = []
```

We don't need to change anything about our monad functions and they will work here:
```haskell
monadInc [2,3,4] -- evaluates to [3,4,5]
```


# 6.2.1
## The State Monad
Monads were first invented to model stateful computations in a purely functional setting. 

How do we represent a stateful computation? A stateful computation starts with an input state, and returns some kind of result, possibly modifying that state. We can represent that as a function of type:
```haskell
-- informally, a -> (s, a) where a is the state and s is the result type
ex1 :: Integer -> (Integer, Integer)
ex1 s = (s*2, s+1) -- increments the state by one, gives a doubled input as the result
```

### Record Syntax and Encapsulation
```haskell
newtype State s a = State { runState :: s -> (a, s) }
```
The `newtype` keyword causes the types to be synonyms, so we don't have to use pattern matching to extract.

```haskell
ex2a :: State Integer Integer
ex2a = State {runState = ex1}
-- or, more tersely
ex2a :: State Integer Integer
ex2a = State ex1

-- The following two examples both evaluate to (20, 11):
runState ex2a 10
runState ex2b 10
```

#### Functor State
Ok, so now we can define State as a functor. We contain the last element, the result of the computation, in the container with the state `State s`. `State` takes two arugments, so `State s` takes one. Remember that the State constructor can choose to utilize a runState function from s -> a, s as a shortcut for this construction. Not really a shortcut, it is the correct way. 
```haskell
newtype State s a = ...

instance Functor (State s) where
	fmap :: (a -> b) -> (State s a) -> (State s b)
	fmap f g = State (\s1 -> let (x,s2) = runState g s1
				 in (f x, s2)) / apply f to the result, get back state2, which is calculated by running the state compuation on it.
```

#### Applicative State

```haskell
instance Applicative (State s) where
	pure x = State (\s -> (x,s))
	-- We don't even consult the state. This is where the term "pure" comes from, the result is not contaminated by the state at all.

	f1 <*> x1 = State (\s -> let (f, s2) = runState f1 s
				     (x, s3) = runState x1 s2
				  in (f x, s3))
```

#### Monad State
```haskell 
instance Monad (State s) where
	return = pure
	-- same as Applicative, this is common
	-- x :: State s a 
	-- f :: a -> State s b
	-- output :: State s b
x >>= f = State (\s -> let (y, s2) = runState x s
			   (z, s3) = runState (f y) s2
			in (x, s3))
```
Bind is going to take a value and a function that will chunk it into a monad. We have to define how it gets chunked into a monad via `>>=`. The x passed in will give us the runstate we want, and then f applied to y will give us a second runstate that we can use on the first state, and then we can return that state.
Come back to this (?)

# 6.2.2
## State Monad Examples
Say we  need to write a function that increments the state. 
```haskell
incState (State f) = State (\s -> 
-- I am stuck, shouldn't State have two variables given to it?
incState (State f) = State (\s -> let (x, s0) = f s 
                                      in (x, s0+1))
-- um ok, so I can use a function that returns two variables instead. you can pattern match to get runState out I guess
```
## Two Common Functions, `get` and `put`
Two common functions used in states are `get` and `put`.

```haskell
get :: State s s
get = State (\s -> (s, s))

put :: a -> State a ()
put x = State (\s -> ((),x))
```

`get` says that its input will be put in the value part of the tuple (and the state part). `put` takes a value and replaces the incoming state variable with it.


## Using Do Notation
Bind notation is cumbersome. `do` takes each line and binds it to the next line. 
```haskell
monadMult a b = do
	x <- a -- == a >>= \x -> (
	y <- b --    b >>= \y ->
	return (x * y)  -- return (x * y))
```

