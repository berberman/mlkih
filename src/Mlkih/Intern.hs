{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE RankNTypes #-}

module Mlkih.Intern
  ( HasInternState (..),
    withIntern,
    evalIntern,
    InternState,
    emptyInternState,
    lookupNameId,
    lookupLevelId,
    lookupExprId,
    registerImportedName,
    registerImportedNameIn,
    registerImportedLevel,
    registerImportedLevelIn,
    registerImportedExpr,
    registerImportedExprIn,
    internName,
    internExpr,
    internLevel,
    internNameVal,
    internLevelVal,
    internExprVal,
  )
where

import Control.Monad.State.Strict (MonadState, State, evalState, get, gets, put, runState, state)
import Data.Hashable (hash)
import Data.IntMap.Strict (IntMap)
import qualified Data.IntMap.Strict as IntMap
import Mlkih.Expr
import Mlkih.Level
import Mlkih.Name
import Mlkih.Types

-- | Interner state for hash-consed syntax.
--
-- * /by id/ is the source of truth for imported nodes and direct lookup.
--   Exported Lean terms already come with canonical ids, and locally created
--   nodes get fresh negative ids so the two spaces never collide.
-- * /by fingerprint/ is only an acceleration structure for the interning
--   functions. It stores candidate ids, not whole nodes, so ownership of the
--   actual nodes stays in the primary IntMaps above.
--
-- Interning never mutates an existing node. If a payload already exists, we
-- reuse its canonical node; otherwise we allocate a fresh local id.
class HasInternState s where
  getInternState :: s -> InternState
  setInternState :: InternState -> s -> s

instance HasInternState InternState where
  getInternState = id
  setInternState = const

withIntern ::
  (MonadState s m, HasInternState s) =>
  (forall n. (MonadState InternState n) => n a) ->
  m a
withIntern action = do
  st <- get
  let (result, internState') = runState action (getInternState st)
  put (setInternState internState' st)
  pure result

evalIntern :: State InternState a -> InternState -> a
evalIntern action st = evalState action st

data InternState = InternState
  { internNextNameId :: !HCId,
    internNextLevelId :: !HCId,
    internNextExprId :: !HCId,
    internNamesById :: HCMap HCName,
    internLevelsById :: HCMap HCLevel,
    internExprsById :: HCMap HCExpr,
    internNamesByFingerprint :: IntMap [HCId],
    internLevelsByFingerprint :: IntMap [HCId],
    internExprsByFingerprint :: IntMap [HCId]
  }

emptyInternState :: InternState
emptyInternState =
  InternState
    { internNextNameId = -1,
      internNextLevelId = -1,
      internNextExprId = -1,
      internNamesById = IntMap.singleton 0 anonymousName,
      internLevelsById = IntMap.singleton 0 zeroLevel,
      internExprsById = IntMap.empty,
      internNamesByFingerprint = insertNameFingerprint anonymousName IntMap.empty,
      internLevelsByFingerprint = insertLevelFingerprint zeroLevel IntMap.empty,
      internExprsByFingerprint = IntMap.empty
    }
  where
    anonymousName = HCName 0 Anonymous
    zeroLevel = HCLevel 0 LZero

lookupNameId :: (MonadState InternState m) => HCId -> m (Maybe HCName)
lookupNameId ident = gets $ IntMap.lookup ident . internNamesById

lookupLevelId :: (MonadState InternState m) => HCId -> m (Maybe HCLevel)
lookupLevelId ident = gets $ IntMap.lookup ident . internLevelsById

lookupExprId :: (MonadState InternState m) => HCId -> m (Maybe HCExpr)
lookupExprId ident = gets $ IntMap.lookup ident . internExprsById

registerImportedName :: (MonadState InternState m) => HCId -> Name' HCName -> m (Either String HCName)
registerImportedName ident val = state $ \st ->
  case registerImportedNameIn ident val st of
    Left err -> (Left err, st)
    Right (node, st') -> (Right node, st')

registerImportedLevel :: (MonadState InternState m) => HCId -> Level' HCLevel HCName -> m (Either String HCLevel)
registerImportedLevel ident val = state $ \st ->
  case registerImportedLevelIn ident val st of
    Left err -> (Left err, st)
    Right (node, st') -> (Right node, st')

registerImportedExpr :: (MonadState InternState m) => HCId -> Expr' HCExpr HCLevel HCName -> m (Either String HCExpr)
registerImportedExpr ident val = state $ \st ->
  case registerImportedExprIn ident val st of
    Left err -> (Left err, st)
    Right (node, st') -> (Right node, st')

internNameVal :: (MonadState InternState m) => Name' HCName -> m HCName
internNameVal Anonymous = do
  gets $ maybe (HCName 0 Anonymous) id . IntMap.lookup 0 . internNamesById
internNameVal val = state $ \st ->
  case lookupNameByVal val st of
    Just existing -> (existing, st)
    Nothing ->
      let ident = internNextNameId st
          node = HCName ident val
          st' =
            st
              { internNextNameId = ident - 1,
                internNamesById = IntMap.insert ident node $ internNamesById st,
                internNamesByFingerprint = insertNameFingerprint node $ internNamesByFingerprint st
              }
       in (node, st')

internLevelVal :: (MonadState InternState m) => Level' HCLevel HCName -> m HCLevel
internLevelVal LZero = do
  gets $ maybe (HCLevel 0 LZero) id . IntMap.lookup 0 . internLevelsById
internLevelVal val = state $ \st ->
  case lookupLevelByVal val st of
    Just existing -> (existing, st)
    Nothing ->
      let ident = internNextLevelId st
          node = HCLevel ident val
          st' =
            st
              { internNextLevelId = ident - 1,
                internLevelsById = IntMap.insert ident node $ internLevelsById st,
                internLevelsByFingerprint = insertLevelFingerprint node $ internLevelsByFingerprint st
              }
       in (node, st')

internExprVal :: (MonadState InternState m) => Expr' HCExpr HCLevel HCName -> m HCExpr
internExprVal val = state $ \st ->
  case lookupExprByVal val st of
    Just existing -> (existing, st)
    Nothing ->
      let ident = internNextExprId st
          node = HCExpr ident val
          st' =
            st
              { internNextExprId = ident - 1,
                internExprsById = IntMap.insert ident node $ internExprsById st,
                internExprsByFingerprint = insertExprFingerprint node $ internExprsByFingerprint st
              }
       in (node, st')

internName :: (MonadState InternState m) => Name -> m HCName
internName (Name val) =
  case val of
    Anonymous -> internNameVal Anonymous
    Str prefix segment -> do
      prefix' <- internName prefix
      internNameVal $ Str prefix' segment
    Num prefix n -> do
      prefix' <- internName prefix
      internNameVal $ Num prefix' n

internLevel :: (MonadState InternState m) => Level -> m HCLevel
internLevel (Level val) =
  case val of
    LZero -> internLevelVal LZero
    LSucc level -> do
      level' <- internLevel level
      internLevelVal $ LSucc level'
    LMax lhs rhs -> do
      lhs' <- internLevel lhs
      rhs' <- internLevel rhs
      internLevelVal $ LMax lhs' rhs'
    LIMax lhs rhs -> do
      lhs' <- internLevel lhs
      rhs' <- internLevel rhs
      internLevelVal $ LIMax lhs' rhs'
    LVar name -> do
      name' <- internName name
      internLevelVal $ LVar name'

internExpr :: (MonadState InternState m) => Expr -> m HCExpr
internExpr (Expr val) =
  case val of
    BVar idx -> internExprVal $ BVar idx
    FVar (FVarId name) -> do
      name' <- internName name
      internExprVal $ FVar (FVarId name')
    Sort level -> do
      level' <- internLevel level
      internExprVal $ Sort level'
    Const name levels -> do
      name' <- internName name
      levels' <- traverse internLevel levels
      internExprVal $ Const name' levels'
    App fn arg -> do
      fn' <- internExpr fn
      arg' <- internExpr arg
      internExprVal $ App fn' arg'
    Lam name ty body binderInfo -> do
      name' <- internName name
      ty' <- internExpr ty
      body' <- internExpr body
      internExprVal $ Lam name' ty' body' binderInfo
    ForallE name ty body binderInfo -> do
      name' <- internName name
      ty' <- internExpr ty
      body' <- internExpr body
      internExprVal $ ForallE name' ty' body' binderInfo
    Lit lit -> internExprVal $ Lit lit
    Let name ty value body nondep -> do
      name' <- internName name
      ty' <- internExpr ty
      value' <- internExpr value
      body' <- internExpr body
      internExprVal $ Let name' ty' value' body' nondep
    Proj name idx struct -> do
      name' <- internName name
      struct' <- internExpr struct
      internExprVal $ Proj name' idx struct'

registerImportedNameIn :: HCId -> Name' HCName -> InternState -> Either String (HCName, InternState)
registerImportedNameIn ident val st
  | ident == 0 =
      if val == Anonymous
        then Right (anonymousName, st)
        else Left "name id 0 is reserved for anonymous"
  | otherwise =
      case (IntMap.lookup ident (internNamesById st), lookupNameByVal val st) of
        (Just existing, _)
          | hcnVal existing == val -> Right (existing, st)
          | otherwise -> Left $ "conflicting imported name id " <> show ident
        (Nothing, Just existingByVal) ->
          Right
            ( existingByVal,
              st
                { internNamesById = IntMap.insert ident existingByVal $ internNamesById st
                }
            )
        (Nothing, Nothing) ->
          let node = HCName ident val
           in Right
                ( node,
                  st
                    { internNamesById = IntMap.insert ident node $ internNamesById st,
                      internNamesByFingerprint = insertNameFingerprint node $ internNamesByFingerprint st
                    }
                )
  where
    anonymousName = HCName 0 Anonymous

registerImportedLevelIn :: HCId -> Level' HCLevel HCName -> InternState -> Either String (HCLevel, InternState)
registerImportedLevelIn ident val st
  | ident == 0 =
      if val == LZero
        then Right (zeroLevel, st)
        else Left "level id 0 is reserved for zero"
  | otherwise =
      case (IntMap.lookup ident (internLevelsById st), lookupLevelByVal val st) of
        (Just existing, _)
          | hclVal existing == val -> Right (existing, st)
          | otherwise -> Left $ "conflicting imported level id " <> show ident
        (Nothing, Just existingByVal) ->
          Right
            ( existingByVal,
              st
                { internLevelsById = IntMap.insert ident existingByVal $ internLevelsById st
                }
            )
        (Nothing, Nothing) ->
          let node = HCLevel ident val
           in Right
                ( node,
                  st
                    { internLevelsById = IntMap.insert ident node $ internLevelsById st,
                      internLevelsByFingerprint = insertLevelFingerprint node $ internLevelsByFingerprint st
                    }
                )
  where
    zeroLevel = HCLevel 0 LZero

registerImportedExprIn :: HCId -> Expr' HCExpr HCLevel HCName -> InternState -> Either String (HCExpr, InternState)
registerImportedExprIn ident val st =
  case (IntMap.lookup ident (internExprsById st), lookupExprByVal val st) of
    (Just existing, _)
      | hceVal existing == val -> Right (existing, st)
      | otherwise -> Left $ "conflicting imported expr id " <> show ident
    (Nothing, Just existingByVal) ->
      Right
        ( existingByVal,
          st
            { internExprsById = IntMap.insert ident existingByVal $ internExprsById st
            }
        )
    (Nothing, Nothing) ->
      let node = HCExpr ident val
       in Right
            ( node,
              st
                { internExprsById = IntMap.insert ident node $ internExprsById st,
                  internExprsByFingerprint = insertExprFingerprint node $ internExprsByFingerprint st
                }
            )

lookupNameByVal :: Name' HCName -> InternState -> Maybe HCName
lookupNameByVal val st = do
  bucket <- IntMap.lookup (hash val) (internNamesByFingerprint st)
  findNameInBucket val st bucket

lookupLevelByVal :: Level' HCLevel HCName -> InternState -> Maybe HCLevel
lookupLevelByVal val st = do
  bucket <- IntMap.lookup (hash val) (internLevelsByFingerprint st)
  findLevelInBucket val st bucket

lookupExprByVal :: Expr' HCExpr HCLevel HCName -> InternState -> Maybe HCExpr
lookupExprByVal val st = do
  bucket <- IntMap.lookup (hash val) (internExprsByFingerprint st)
  findExprInBucket val st bucket

findNameInBucket :: Name' HCName -> InternState -> [HCId] -> Maybe HCName
findNameInBucket _ _ [] = Nothing
findNameInBucket val st (ident : rest) =
  case IntMap.lookup ident (internNamesById st) of
    Just node
      | hcnVal node == val -> Just node
      | otherwise -> findNameInBucket val st rest
    Nothing -> findNameInBucket val st rest

findLevelInBucket :: Level' HCLevel HCName -> InternState -> [HCId] -> Maybe HCLevel
findLevelInBucket _ _ [] = Nothing
findLevelInBucket val st (ident : rest) =
  case IntMap.lookup ident (internLevelsById st) of
    Just node
      | hclVal node == val -> Just node
      | otherwise -> findLevelInBucket val st rest
    Nothing -> findLevelInBucket val st rest

findExprInBucket :: Expr' HCExpr HCLevel HCName -> InternState -> [HCId] -> Maybe HCExpr
findExprInBucket _ _ [] = Nothing
findExprInBucket val st (ident : rest) =
  case IntMap.lookup ident (internExprsById st) of
    Just node
      | hceVal node == val -> Just node
      | otherwise -> findExprInBucket val st rest
    Nothing -> findExprInBucket val st rest

insertNameFingerprint :: HCName -> IntMap [HCId] -> IntMap [HCId]
insertNameFingerprint node = IntMap.insertWith (++) (hash (hcnVal node)) [hcnId node]

insertLevelFingerprint :: HCLevel -> IntMap [HCId] -> IntMap [HCId]
insertLevelFingerprint node = IntMap.insertWith (++) (hash (hclVal node)) [hclId node]

insertExprFingerprint :: HCExpr -> IntMap [HCId] -> IntMap [HCId]
insertExprFingerprint node = IntMap.insertWith (++) (hash (hceVal node)) [hceId node]
