import System.IO
import Data.List 

-- Construcao do tipo 
data CountryData = CountryData {
  country   :: String,
  confirmed :: Int,
  deaths    :: Int,
  recovery  :: Int,
  active    :: Int
}deriving (Show, Read)

-- Funcoes de parsing
-- Quebra a linha em dados unicos
splitOn :: Eq a => a -> [a] -> [[a]]
splitOn delim [] = [[]]
splitOn delim xs =
  case break (== delim) xs of
    (y, [])   -> [y]
    (y, _:ys) -> y : splitOn delim ys

-- Associa os dados da linha a CountryData
parseLine :: String -> CountryData
parseLine xs =
  case splitOn ',' xs of
    [country, confirmed, deaths, recovery, active] 
      -> CountryData country 
        (read confirmed)
        (read deaths)
        (read recovery)
        (read active)
    _ -> error "ERROR"

-- Quebra a string do arquivo em linhas
parseFile :: String -> [CountryData]
parseFile [] = []
parseFile xs = map parseLine (lines xs)

-- Funcoes auxiliares dos calculos  
-- Obtem lista dos maiores ativos
topActive :: Int -> [CountryData] -> [CountryData]
topActive n2 countries =
  take n2 (sortBy (flip(\p1 p2 -> compare (active p1) (active p2))) countries)

-- Obtem a lista dos menores confirmados
bottomConfirmed :: Int -> [CountryData] -> [CountryData]
bottomConfirmed n3 countries =
  take n3 (sortBy (\p1 p2 -> compare (confirmed p1) (confirmed p2)) countries)

-- Funcoes dos calculos requeridos
-- Obtem a soma dos ativos de acordo com a condicao estipulada
sumActiveConfirmed :: Int -> [CountryData] -> Int
sumActiveConfirmed n1 countries = 
  sum [active a | a <- countries, confirmed a >= n1]

-- Obtem a soma das mortes de acordo com as condicoes estipuladas
sumDeathConfirmed :: Int -> Int -> [CountryData] -> Int
sumDeathConfirmed n2 n3 countries =
  sum [deaths a | a <- bottomConfirmed n3 (topActive n2 countries)]

-- Obtem a lista de paises de acordo com as condicoes estipuladas
topConfirmed :: Int -> [CountryData] -> [CountryData]
topConfirmed n4 countries =
  sortBy 
    (\p1 p2 -> compare (country p1) (country p2))
    (take n4 (sortBy (flip(\p1 p2 -> compare (confirmed p1) (confirmed p2))) countries))

main :: IO ()
main = do
  -- Obtem lista formatada dos paises
  contents <- readFile "dados.csv"
  let countryDataList = parseFile contents :: [CountryData]

  -- Obtem numeros de controle
  input <- getLine
  let controlNumbers = map read (words input) :: [Int]

  -- Prints de saida
  print $ sumActiveConfirmed (head controlNumbers) countryDataList
  print $ sumDeathConfirmed (controlNumbers !! 1) (controlNumbers !! 2) countryDataList
  mapM_ putStrLn  (map country (topConfirmed (controlNumbers !! 3) countryDataList))