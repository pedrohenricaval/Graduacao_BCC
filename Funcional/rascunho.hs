{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Eta reduce" #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Eta reduce" #-}
import System.IO
import Data.List 

data CountryData = CountryData {
  country   :: String,
  confirmed :: Int,
  deaths    :: Int,
  recovery  :: Int,
  active    :: Int
}deriving (Show)

splitOn :: Eq a => a -> [a] -> [[a]]
splitOn delim [] = [[]]
splitOn delim xs =
  let (before, rest) = break (== delim) xs
  in before : case rest of
       [] -> []
       (_:after) -> splitOn delim after

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

parseFile :: String -> [CountryData]
parseFile [] = []
parseFile xs = map parseLine (lines xs)


main :: IO ()
main = do
  contents <- readFile "rascunho.csv"
  let countryDataList = parseFile contents :: [CountryData]
  print $ parseFile contents