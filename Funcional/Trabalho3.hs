import System.IO
import Data.List 
import Control.Monad 

-- Leitura dos numeros
readNumber :: IO Int
readNumber = do
  entrada <- getLine
  let number = read entrada :: Int
  return number

-- Criar lista de primos
isPrime :: Int -> Bool
isPrime i 
    | length divList == 2 = True
    | otherwise = False
    where divList = filter (\x -> mod i x == 0) [1..i]


-- Obtem maior intervalo entre os primos
highestPrimeInterval :: [Int] -> Int
highestPrimeInterval xs 
    | length primeList < 2 = 0
    | otherwise = maximum primeGapList 
    where 
        primeList = filter isPrime xs --Primos
        primeGapList = zipWith (-) (tail primeList) primeList --Intervalo entre primos

-- Funcionamento
main :: IO ()
main = do
    inputList <- replicateM 2 readNumber
    let numberList = [head inputList..last inputList]
    print $ highestPrimeInterval numberList