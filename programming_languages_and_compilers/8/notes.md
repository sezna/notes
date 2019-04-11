# 7.1.1
## Introduction to Grammars
A grammar is a formal notation used to define what a language looks like. Our goal is going to be to be able to convert a string of characters into an abstract syntax tree. This is usually called parsing.

The conversion from strings to trees is accomplished in two steps.
* First, convert the stream of characters into a stream of **tokens**. This is called **lexing**, or **scanning**. 
* Second, convert the stream of tokens into an abstract syntax tree. This is called **parsing**.

In order to parse a language, we need a formal definition of what the language should represent. A **grammar** is how we do this, and it also enables us to properly document our language and communicate about it.

A grammar G has four components:
* A set of terminal stmbols representing individual tokens
* A set of non terminal symbols representing syntax trees
* A set of productions, each mapping a non terminal symbol to a string of terminal and non terminal symbols
* A designated non-terminal **start symbol**.

Here is a sample grammar:

```haskell
S -> N verb P
N -> det noun
P -> prep N
``` 

Each of the above lines is called a **production**. The symbol on the left-hand side can be __produced__ by collecting the symbols on the right-hand side. The capital identifiers, in this convention at least, are non terminal symbols. The lower case identifiers are terminal symbols. Because the left-hand sides each contain only one symbol, the rules are **context free**, meaning each symbol can be interpreted independently and without knowledge of what is around it. 

### Epsilon Productions
Sometimesm we want to specify that a symbol can become nothing. To do this, we specify a production that takes non-terminal symbol X and produces the epsilon symbol. If we make another production for symbol X and it goes to something other than epsilon, then we have just specified that that component is optional, because the symbol could just as easily have produced epsilon or something of substance. 

```haskell
S -> epsilon
S -> A B c
```
Here, `S` is optional. 

### Right Linear Grammars
A **right linear** grammar is one in which all of the productions have the form `E -> x A` or `E -> x`. This corresponds to the **regular languages**. For example, the regular expression `(10)*23`  describes the same language as this grammar:
```haskell
A_0 -> 1A_1 | 2A_2
A_1 -> 0A_0
A_2 -> 3A_3
A_3 -> epsilon
```

The trick: each node in your NFA is a non terminal symbol ni the grammar. The terminal symbol represents ah input, and the following nonterminal is the destination state.

### Left-Recursion
A grammar is **recursive** if the symbol being produced (the one on the left-hand side) also appears in the right-hand side. A grammar is specifically **left-recursive** if the production symbol appears as the first symbol on the right-hand side, or if it is produced by a chain of left recursions (e.g. `A -> Bx; B -> Ay` becomes `A -> Ayx`).

An if expression is recursive, and has three recursions as it is an expression which has three expressions in it. It is not, however, left-recursive. 

### Ambiguous Grammars
A grammar is **ambiguous** if it can producem ore than one  parse tree for a single sentence. There are two common forms of ambiguity: 
* The "dangling else" form: allowing if expressions to omit the else can potentially lead to this: `if x then if y else z` -- to whom does the else belong?
* The "double-ended recursion" form: `E -> E + E; E -> E * E`, what is the order of operations in `3 + 4 * 10`? 

To fix the dangling else, languages often provide an explicit keyword that specifies the end of an if expression, like `fi` or something. 

Double-ended recursiuon usually reveals a lack of precedence and associativity information. A technique called **stratification** often fixes this. To stratify your grammar, use recursion on only one side. Left-recursive means "associates to the left", similarly with right-recursive to the right. Additionally, put your highest precedence rules "lower" in the grammar. You can create separate non-terminal symbols to code precedence, with the highest precedence coming last. 
```haskell
E -> F + E -- right associative
E -> F
F -> T * F -- right associative
F -> T
T -> (E)
T -> integer
```

# 7.1.2
## FIRST Sets
What is the first terminal symbol you could encounter given a non-terminal?

Given a grammar for a language L, how can we recognize a sentence in L? One tool we can use to address this problem is to construct a set of all of the potential first non-terminal symbols we would see from language L. That is, in the language generated/described by our grammar, by analyzing the grammar, what are the potential valid beginnings of "sentences"? In English, this would mostly limit us to capital, not lower-case, letters. 
Consider the following grammar:
```haskell
S -> xEy
E -> zE
E -> q
```
In English, this means a string of "x", any number of z's, followed by "yq". A string of 0 z's is acceptable, so the final string would just be a q. The FIRST set for the entire language (if such a concept is even valid) would be `x`, but the FIRST set for non-terminal symbol E would be `{z, q}`. 

We can compute the FIRST set by a simple iterative algorithm.
For each symbol X:
* If X is terminal, then `FIRST(X) = X`.
* If there is a production `X -> epsilon`, then add `epsilon` to the FIRST set.
* If there is a productoin `X -> Y_1 Y_2 ... Y_n`, then add `FIRST(Y_1 Y_2 ... Y_n)` to `FIRST(X)`.
 * If `FIRST(Y_1)` does not contain `epsilon`, then `FIRST(Y_1 Y_2 ... Y_n) == FIRST(Y_1)`.
 * Otherwise, `FIRST(Y_1 Y_2 ... Y_n) = (FIRST(Y_1) (excluding epsilon)) UNION FIRST(Y_2 ...Y_n)`.
 * If all of `Y_1, Y_2, ... Y_n` have `epsilon`, then add `epsilon` to `FIRST(X)`.

### Small Examples
* `S -> x A B` `FIRST(S) = {x}`
* `A -> epsilon; A -> y; A -> z q` `FIRST(A) = {y, z, epsilon}`
* `B -> A q; B -> r` `FIRST(B) = {y, z, q, r}`
* `C -> A A; C -> B` `FIRST(C) = {y, z, q, r, epsilon}`


### Calculating the FIRST set: an example

#### Step 1
Initialize grammar and result sets.
##### Grammar
```haskell
S -> if E then S;
S -> print E;
E -> E + E
E -> P id
P -> * P
P -> epsilon
```
##### Result Sets (initialization)
```haskell
S = {}
E = {}
P = {}
```

#### Step 2
Identify symbols that produce something starting with a terminal symbol. Add these to the first sets.
##### Result Sets (step 2)
```haskell
S={if,print}
E={}
P={epsilon, *}
```
We can now eliminate those productions from the grammar, as they start with a terminal and we will not be reading anything following that as part of the FIRST set.
##### Grammar (step 2 - ignoring productions that start with a terminal symbol)
```haskell
E -> E + E
E -> P id
```
#### Step 3
Now, we calculate the union of the FIRST sets of these remaining productions. We can't do `E -> E + E` yet because we haven't calculated the FIRST set of E. We can, however, add `FIRST(Pid)` to `FIRST(E)`. E will become P id, and then P can add as many stars as it wants until it terminates. Here is our updated results array:
##### Result Sets (step 3)
```haskell
S={if,print}
E={*, id}
P={epsilon, *}
```
Keep iterating these steps until nothing changes in the result sets.

For a more complicated example, see 7.1.2 at around six minutes.
# 7.1.3
## Follow Sets
__How do I know when I'm done with a symbol?__

A follow set is a list of symbols that occur __after__ you have completed parsing the non-terminal. This is __not__ a part of the parse tree for the given non-terminal. 

There is an algorithm for calculating a follow set. 
* Put `$` in `FOLLOW(S)`, where `S` is the start symbol. `$` represents the end of input.
* If there is a production `X -> alpha Y beta` then add `FIRST(beta)` (but not `epsilon`) to `FOLLOW(Y)`.
* If there is a production `X -> alpha Y`, or if there is a production `X -> alpha Y beta`, where `epsilon is in FIRST(beta)` then add `FOLLOW(X)` to `FOLLOW(Y)`.

For the second bullet point - whatever comes __after__ `Y`, or __follows__ `Y`, will be in `FIRST(beta)`, so we add it to the follow set of Y. For the third bullet point, if epsilon is in the first set of `beta`, or if nothing follows Y in general. See 2:34 in 7.1.3 for examples.

# 7.2.1
## Regular Languages
(lots omitted due to Alex's familiarity with regular languages)
Regular exp syntax options:

* A   -- match just A
* A\* -- any amount of copies of A
* A+  -- one or more copies of A 
* A|B -- A or B

Examples:
* ab\*a -- aa, aba, abbba
* (0|1)\* -- any binary number or epsilon
* (0|1)+ -- any binary number

Notational shortcuts:
* [Xa-z] -- matches X and then any letter from a to z

Regular expressions are greedy. They are well suited for individual words, but not more complicated operations. You cannot count very well, you need a state for every value to count, you cannot match an infinite number of primes, you cannot match things like nested comments in code.

# 7.2.2
## Thompsons Construction
A quick refresher: a right-linear grammar is one in which every production has the form `A -> x`, `A -> xB`, or `A -> B`. That means it is context free. It has at most one nonterminal symbol on the right-hand side. It has one nonterminal for each state, and one terminal for each production. 


