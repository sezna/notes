line -> (expression | comment):*

# Expressions 
# fn myfunc(firstnote:note secondnote: note) : note { funcBody }  
function -> "fn" _ identifier "(" argList ")" _ ":" identifier _ "{" funcBody "}" 
argList -> argument:* # TODO type names?
argument -> identifier _ ":" _ identifier # Make this type names?
funcBody -> expression:*

# medium things
expression -> declaration

# small things
declaration -> "let" identifier "=" valExp
identifier -> [a-z]* # matches any lower case letters
valExp  -> note | chord # or any other valid value
note -> [a-g](is|es|) {% data => data.join(""); %}
chord -> "<" note:* ">" 
