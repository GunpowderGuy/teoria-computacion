module CYK

import Data.SortedMap
import Data.SortedSet
import Data.Vect

-- ══════════════ Tipos ══════════════

NonTerminal : Type
NonTerminal = String

Terminal : Type
Terminal = String

data Production = One Terminal | Pair NonTerminal NonTerminal

-- Eq debe cubrir TODOS los casos (los constructores mixtos dan False)
Eq Production where
  One x    == One y    = x == y
  Pair a b == Pair c d = a == c && b == d
  One _    == Pair _ _ = False
  Pair _ _ == One _    = False

-- SortedSet necesita un orden total
Ord Production where
  compare (One x)    (One y)    = compare x y
  compare (One _)    (Pair _ _) = LT
  compare (Pair _ _) (One _)    = GT
  compare (Pair a b) (Pair c d) = case compare a c of
                                    EQ => compare b d
                                    o  => o

Grammar : Type
Grammar = SortedMap NonTerminal (SortedSet Production)

Table : Type
Table = SortedMap (Nat, Nat) (SortedSet NonTerminal)

-- ══════════════ Utilidades ══════════════

range : Nat -> Nat -> List Nat
range i j = if i > j then [] else i :: range (S i) j

-- zip propio: la zip del Prelude requiere Zippable, y no siempre está
-- disponible para List según la versión
zip' : List a -> List b -> List (a, b)
zip' [] _ = []
zip' _ [] = []
zip' (x :: xs) (y :: ys) = (x, y) :: zip' xs ys

cell : Table -> Nat -> Nat -> SortedSet NonTerminal
cell t i j = maybe SortedSet.empty id (SortedMap.lookup (i, j) t)

producersOf : Grammar -> Terminal -> SortedSet NonTerminal
producersOf g x =
  foldl (\acc, (nt, prods) =>
           if any (== One x) (SortedSet.toList prods)
             then SortedSet.insert nt acc
             else acc)
        SortedSet.empty (SortedMap.toList g)

candidates : Grammar -> Table -> Nat -> Nat -> SortedSet NonTerminal
candidates g t i j = SortedSet.fromList $ concat
  [ case p of
      Pair b c =>
        if contains b (cell t i k)
           && contains c (cell t (S k) j)
          then [nt] else []
      One _ => []
  | (nt, prods) <- SortedMap.toList g
  , p <- SortedSet.toList prods
  , k <- range i (pred j)
  ]

-- ══════════════ CYK ══════════════

init : Grammar -> List Terminal -> Table
init g xs = SortedMap.fromList
  [ ((j, j), producersOf g x)
  | (j, x) <- zip' (range 0 (pred (length xs))) xs ]

fill : Grammar -> Nat -> Table -> Nat -> Table
fill g n t len =
  if len > n then t
  else
    let t' = foldl
               (\acc, i =>
                  let j = i + pred len
                  in SortedMap.insert (i, j) (candidates g acc i j) acc)
               t (range 0 (n `minus` len))
    in fill g n t' (S len)

cykList : Grammar -> NonTerminal -> List Terminal -> Bool
cykList g start xs =
  let n = length xs
      t = fill g n (init g xs) 2
  in contains start (cell t 0 (pred n))

cyk : Grammar -> NonTerminal -> Vect n Terminal -> Bool
cyk g start = cykList g start . toList

-- ══════════════ Gramática de ejemplo ══════════════

example : Grammar
example = SortedMap.fromList
  [ ("S", SortedSet.fromList [ One "id", Pair "S" "X", Pair "S" "Y", Pair "L" "Z" ])
  , ("X", SortedSet.fromList [ Pair "A" "S" ])
  , ("Y", SortedSet.fromList [ Pair "M" "S" ])
  , ("Z", SortedSet.fromList [ Pair "S" "R" ])
  , ("A", SortedSet.fromList [ One "+" ])
  , ("M", SortedSet.fromList [ One "*" ])
  , ("L", SortedSet.fromList [ One "(" ])
  , ("R", SortedSet.fromList [ One ")" ])
  ]

-- ══════════════ Pruebas ══════════════

tests : List (List Terminal, Bool)
tests =
  [ (["id", "+", "id"],                          True)
  , (["id", "+", "id", "*", "id"],               True)
  , (["(", "id", "+", "id", ")", "*", "id"],     True)
  , (["id", "+", "+"],                           False)
  , (["(", "id", "+"],                           False)
  , (["id"],                                     True)
  ]

runTests : IO ()
runTests = traverse_ (\(w, expected) =>
             let got = cykList example "S" w
             in putStrLn (show w ++ "  ->  " ++ show got
                          ++ (if got == expected then "  OK" else "  FALLO")))
             tests

main : IO ()
main = runTests
