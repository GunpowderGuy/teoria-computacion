module PersistentSegTree

-- ---------------------------------------------------------------------------
-- Persistent segment tree over a Monoid.
--
-- Persistence comes from immutability + path copying: `update` rebuilds
-- only the nodes on the root-to-leaf path and shares all untouched
-- subtrees with the old version. Cost: O(log n) time and O(log n) fresh
-- nodes per update; queries stay O(log n). Any number of versions stays
-- readable forever (full persistence).
-- ---------------------------------------------------------------------------

-- idris2 PersistentSegTree.idr -o main && ./build/exec/main

data PSTree : (a : Type) -> Type where
  Leaf   : (lo, hi : Nat) -> (v : a) -> PSTree a
  Branch : (lo, hi : Nat) -> (v : a) -> PSTree a -> PSTree a -> PSTree a

value : PSTree a -> a
value (Leaf _ _ v)       = v
value (Branch _ _ v _ _) = v

rangeLo : PSTree a -> Nat
rangeLo (Leaf l _ _)       = l
rangeLo (Branch l _ _ _ _) = l

rangeHi : PSTree a -> Nat
rangeHi (Leaf _ h _)       = h
rangeHi (Branch _ h _ _ _) = h

-- Total halving (avoids relying on Nat's div).
total
half : Nat -> Nat
half Z         = Z
half (S Z)     = Z
half (S (S k)) = S (half k)

total
splitAt' : Nat -> List a -> (List a, List a)
splitAt' Z     xs        = ([], xs)
splitAt' (S k) []        = ([], [])
splitAt' (S k) (x :: xs) =
  let (l, r) = splitAt' k xs in (x :: l, r)

covering
build : Monoid a => List a -> PSTree a
build xs = go 0 xs
  where
    go : Nat -> List a -> PSTree a
    go n []        = Leaf (S n) n neutral        -- empty range: hi < lo
    go n [x]       = Leaf n n x                  -- leaf gets its true index
    go n xs =
      let k      = half (length xs)
          (l, r) = splitAt' k xs
          lt     = go n l
          rt     = go (n + k) r
      in Branch n (rangeHi rt) (value lt <+> value rt) lt rt

total
query : Monoid a => (ql, qr : Nat) -> PSTree a -> a
query ql qr t =
  if qr < rangeLo t || ql > rangeHi t
    then neutral                                  -- disjoint
    else if ql <= rangeLo t && rangeHi t <= qr
      then value t                                -- fully covered: O(1) here
      else case t of
        Leaf _ _ v         => v
        Branch _ _ _ lt rt => query ql qr lt <+> query ql qr rt

total
update : Monoid a => (i : Nat) -> (a -> a) -> PSTree a -> PSTree a
update i f t =
  if i < rangeLo t || i > rangeHi t
    then t                                        -- outside: share, no copy
    else case t of
      Leaf lo hi v =>
        Leaf lo hi (f v)                          -- copy the leaf
      Branch lo hi _ lt rt =>
        let lt' = update i f lt                   -- one side really changes;
            rt' = update i f rt                   -- the other is returned as-is
        in Branch lo hi (value lt' <+> value rt') lt' rt'

-- Version history: every commit pushes the previous root onto `past`.
record History a where
  constructor MkHistory
  current : PSTree a
  past    : List (PSTree a)

init : Monoid a => List a -> History a
init xs = MkHistory (build xs) []

commit : Monoid a => Nat -> (a -> a) -> History a -> History a
commit i f (MkHistory cur older) =
  MkHistory (update i f cur) (cur :: older)

-- Demo ----------------------------------------------------------------------

record Sum a where
  constructor MkSum
  getSum : a

Num a => Semigroup (Sum a) where
  MkSum x <+> MkSum y = MkSum (x + y)

Num a => Monoid (Sum a) where
  neutral = MkSum 0

Show a => Show (Sum a) where
  show (MkSum x) = show x

bump : Integer -> Sum Integer -> Sum Integer
bump n (MkSum x) = MkSum (x + n)

main : IO ()
main = do
  let h0 = init (map MkSum [1, 3, 5, 7])
      h1 = commit 2 (bump 10)  h0
      h2 = commit 0 (bump 100) h1
  printLn (query 0 3 (current h0))  -- 16  (original untouched)
  printLn (query 0 3 (current h1))  -- 26
  printLn (query 0 3 (current h2))  -- 126
  case past h2 of                   -- walk back to the h1 snapshot
    (prev :: _) => printLn (query 0 3 prev)  -- 26
    []          => pure ()
