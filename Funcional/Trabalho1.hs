import System.IO
import Data.List 
import Control.Monad 

-- Le numero
readNumber :: IO Double
readNumber = do
  entrada <- getLine
  let number = read entrada :: Double
  return number

-- Verifica se o triangulo existe
verifyExistance :: [Double] -> Bool
verifyExistance [a, b, c] 
  | a + b >= c && a + c >= b && b + c >= a = True
  | otherwise                           = False

-- Calcula area por Heron
calculateArea :: [Double] -> Double
calculateArea [a,b,c]= 
  let s = (a+b+c)/2
  in sqrt $ s *(s-a)*(s-b)*(s-c)

-- Funcionamento
main :: IO ()
main = do
  numberList <-  replicateM 3 readNumber
  if verifyExistance numberList
    then 
      print (calculateArea numberList)
    else 
     putStrLn "-"