incList [] = []
incList (x:xs) = (x+1) : (incList xs)
sumList [] = 0
sumList (x:xs) = x + sumList xs

--power :: Integer -> Integer -> Integer
--power x 1 = x 
--power x y = x * (power x (y - 1))
power x 0 = 1
power x y
    | even y = power (x * x) (div y 2)
    | odd y = x * power x (y-1)
--tailPower x y = aux x x y
--          where aux x z 0 = x
--                aux x z y | even y = aux (x * x) z (div y 2)
--                          | odd y = aux (z * z) x (y - 1)
    
tailPower x y = aux x y 1
  where
    aux x 0 z = z
    aux x y z
        | even y = aux (x * x) (div y 2) z
        | odd y = aux  x (y - 1) (z * x)

--power x y = aux x x y 
--          where aux x y 1 = x   
--                aux x y z = aux (x * y) y (z - 1) 



main = do
  print (incList [2..10]) 
  print (sum [2..5])
  print (power 4 5)
  print (tailPower 4 5)
