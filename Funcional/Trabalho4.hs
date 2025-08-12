{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Use <$>" #-}
{-# HLINT ignore "Use list literal" #-}
import Data.List (intersperse)

-- Definicoes
-- Definir struct
data Frame 
  =  Strike              
  | Spare Int Int       
  | Normal Int Int      
  | LastFrame Int Int Int
  | ERROR
  deriving (Show)

-- Definir tipo 
type Game = [Frame]

------------------------------------------------------------------
-- Funcoes de parsing
-- Quebra a linha em dados unicos
splitOn :: Eq a => a -> [a] -> [[a]]
splitOn delim [] = [[]]
splitOn delim xs =
  case break (== delim) xs of
    (y, [])   -> [y]
    (y, _:ys) -> y : splitOn delim ys

------------------------------------------------------------------
-- Funcoes de interpretacao de input
-- Leitura dos frames
readFrame :: Int -> [Int] -> [Frame] 
readFrame _ [] = [] -- Fim
readFrame round (10:xs) --Strike 
    | round == 10 = LastFrame 10 (head xs) (last xs) : []
    | otherwise = Strike : readFrame (round +1) xs

readFrame round (j1:j2:xs) --Resto
    | j1 + j2 == 10 =  -- Spare
        if round == 10 then 
            LastFrame j1 j2 (head xs) : []
        else
            Spare j1 j2  : readFrame (round + 1) xs
    | j1 + j2 < 10 = Normal j1 j2 : readFrame (round + 1) xs
    | otherwise = [ERROR]

readFrame _ _ = [ERROR]          

------------------------------------------------------------------
-- Funcao score + auxiliares
-- Contador do score final
countScore :: Game -> Int --Funcao calcular score
countScore [] = 0
countScore (f:fs) =
  case f of
    Strike -> 10 + bonusStrike fs + countScore fs
    Spare _ _ -> 10 + bonusSpare fs + countScore fs
    Normal x y -> x + y + countScore fs
    LastFrame x y z -> x + y + z

-- Contador de pontos bonus para strike
bonusStrike :: Game -> Int
bonusStrike (Strike : Strike : _) = 20
bonusStrike (Strike : Spare x _ : _) = 10 + x
bonusStrike (Strike : Normal x _ : _) = 10 + x
bonusStrike (Strike : LastFrame x _ _: _) = 10 + x
bonusStrike (Spare x y : _) = 10
bonusStrike (Normal x y : _) = x + y
bonusStrike (LastFrame x y _ : _) = x + y
bonusStrike _ = 0

-- Contador de pontos bonus para spare
bonusSpare :: Game -> Int
bonusSpare (Strike : _) = 10
bonusSpare (Spare x _ : _) = x
bonusSpare (Normal x _ : _) = x
bonusSpare (LastFrame x y _ : _) = x + y
bonusSpare _ = 0

------------------------------------------------------------------
-- Conversao da pontuacao final para o formato exigido
-- Funcao geral da conversao
frameToString :: Frame -> String
frameToString Strike = "X _"
frameToString (Spare x y) = show x ++ " /"
frameToString (Normal x y) = show x ++ " " ++ show y
frameToString (LastFrame x y z) = showFirst x ++ " " ++ showSecond x y ++ " " ++ showThird y z
frameToString ERROR = "ERROR"

-- Converte pontuacao da primeira bola para o formato de boliche
showFirst :: Int -> String
showFirst 10 = "X"
showFirst x = show x

-- Converte pontuacao da segunda bola para o formato de boliche
showSecond :: Int -> Int -> String
showSecond 10 10 = "X"            -- Strike + Strike
showSecond x y
  | x + y == 10 = "/"             -- Spare
  | otherwise   = show y

-- Converte pontuacao da terceira bola para o formato de boliche
showThird :: Int -> Int -> String
showThird 10 10 = "X"             -- Strike + Strike
showThird x y
  | x + y == 10 = "/"             -- Spare
  | y == 10     = "X"
  | otherwise   = show y

------------------------------------------------------------------
-- Faz print do game
printGame :: Game -> IO ()
printGame game = do
  let frameStrings = map frameToString game
      formattedLine = unwords (intersperse "|" frameStrings)
      totalScore = countScore game
  putStrLn $ formattedLine ++ " | " ++ show totalScore

------------------------------------------------------------------
-- Main
main :: IO ()
main = do
    input <- getLine
    let 
        pontos = map (read :: [Char] -> Int) (splitOn ' ' input) 
        frameList = readFrame 1 pontos 
        
    printGame frameList