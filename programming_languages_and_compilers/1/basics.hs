
fib :: Integer -> Integer
fib 0 = 1
fib 1 = 1
fib x = fib (x - 1) + fib (x - 2)

sumList :: [Integer] -> Integer
sumList [] = 0
sumList (x:xs) = x + (sumList xs)

incList :: Integer -> [Integer] -> [Integer]
incList n xs = map (+n) xs

main = do
  print (fib 10)
  print (sumList [1, 3..200])
  print (incList 10 [1..10])
