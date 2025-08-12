import System.IO
import Data.List 
import Control.Monad 

-- Definicao de struct
data NumType
    = Perfect 
    | Abundant 
    | Deficient 

-- Leitura dos numeros
readNumber :: IO Int
readNumber = do
  entrada <- getLine
  let number = read entrada :: Int
  return number

-- Classificacao de acordo com struct
classifyNumber :: Int -> NumType
classifyNumber num
    | divSum > num = Abundant
    | divSum == num = Perfect
    | divSum < num = Deficient
    where divSum = sum $ filter (\x -> mod num x == 0) [1..num-1] --Soma dos divisores

-- Contagem de numeros perfeitos
perfectNum :: [Int] -> Int
perfectNum [] = 0
perfectNum (x:xs) =
    let f = classifyNumber x    
    in case f of 
        Perfect -> 1 + perfectNum xs
        _ -> perfectNum xs

-- Contagem de numeros abundantes
abundantNum :: [Int] -> Int
abundantNum [] = 0
abundantNum (x:xs) =
    let f = classifyNumber x    
    in case f of 
        Abundant -> 1 + abundantNum xs
        _ -> abundantNum xs

-- Contagem de numeros deficientes
deficientNum :: [Int] -> Int
deficientNum [] = 0
deficientNum (x:xs) =
    let f = classifyNumber x    
    in case f of 
        Deficient -> 1 + deficientNum xs
        _ -> deficientNum xs

-- Funcionamento
main :: IO ()
main = do
    inputList <- replicateM 2 readNumber
    let numberList = [head inputList..last inputList]
    print (deficientNum numberList)
    print (perfectNum numberList)    
    print (abundantNum numberList)