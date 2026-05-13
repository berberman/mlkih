module Mlkih.UnionFind
  ( UnionFind,
    emptyUnionFind,
    findRoot,
    unionIds,
    sameClass,
  )
where

import Control.Monad.State.Strict (State, get, modify)
import qualified Data.IntMap.Strict as IntMap
import Mlkih.Types

data UnionFind = UnionFind
  { ufParents :: !(IntMap.IntMap HCId),
    ufRanks :: !(IntMap.IntMap Int)
  }

emptyUnionFind :: UnionFind
emptyUnionFind = UnionFind IntMap.empty IntMap.empty

findRoot :: HCId -> State UnionFind HCId
findRoot ident = do
  ensureSingleton ident
  UnionFind parents _ <- get
  case IntMap.lookup ident parents of
    Just parent
      | parent == ident -> pure ident
      | otherwise -> do
          root <- findRoot parent
          compressParent ident root
          pure root
    Nothing -> pure ident

unionIds :: HCId -> HCId -> State UnionFind HCId
unionIds lhs rhs = do
  lhsRoot <- findRoot lhs
  rhsRoot <- findRoot rhs
  if lhsRoot == rhsRoot
    then pure lhsRoot
    else linkRoots lhsRoot rhsRoot

sameClass :: HCId -> HCId -> State UnionFind Bool
sameClass lhs rhs = (==) <$> findRoot lhs <*> findRoot rhs

ensureSingleton :: HCId -> State UnionFind ()
ensureSingleton ident =
  modify $ \uf ->
    uf
      { ufParents = IntMap.insertWith keepExisting ident ident (ufParents uf),
        ufRanks = IntMap.insertWith keepExisting ident 0 (ufRanks uf)
      }
  where
    keepExisting _ existing = existing

compressParent :: HCId -> HCId -> State UnionFind ()
compressParent ident root =
  modify $ \uf -> uf {ufParents = IntMap.insert ident root (ufParents uf)}

linkRoots :: HCId -> HCId -> State UnionFind HCId
linkRoots lhsRoot rhsRoot = do
  UnionFind _ ranks <- get
  let lhsRank = IntMap.findWithDefault 0 lhsRoot ranks
      rhsRank = IntMap.findWithDefault 0 rhsRoot ranks
  case compare lhsRank rhsRank of
    LT -> attachRoot lhsRoot rhsRoot rhsRoot
    GT -> attachRoot rhsRoot lhsRoot lhsRoot
    EQ
      | lhsRoot <= rhsRoot -> attachAndBump rhsRoot lhsRoot lhsRoot
      | otherwise -> attachAndBump lhsRoot rhsRoot rhsRoot

attachRoot :: HCId -> HCId -> HCId -> State UnionFind HCId
attachRoot childRoot parentRoot representative = do
  modify $ \uf -> uf {ufParents = IntMap.insert childRoot parentRoot (ufParents uf)}
  pure representative

attachAndBump :: HCId -> HCId -> HCId -> State UnionFind HCId
attachAndBump childRoot parentRoot representative = do
  modify $ \uf ->
    uf
      { ufParents = IntMap.insert childRoot parentRoot (ufParents uf),
        ufRanks = IntMap.insert parentRoot (IntMap.findWithDefault 0 parentRoot (ufRanks uf) + 1) (ufRanks uf)
      }
  pure representative
