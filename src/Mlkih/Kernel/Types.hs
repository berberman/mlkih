{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeSynonymInstances #-}

module Mlkih.Kernel.Types where

import Control.Monad (when)
import Control.Monad.Except
import Control.Monad.Reader
import Control.Monad.State.Strict
import Data.IntMap (IntMap)
import qualified Data.IntMap.Strict as IntMap
import Mlkih.AST (getAppFn)
import Mlkih.Env
import Mlkih.Expr
import Mlkih.Intern
import Mlkih.Level
import Mlkih.Name
import Mlkih.Pretty
import Mlkih.Types
import Text.PrettyPrint (nest, vcat)

--------------------------------------------------------------------------------

data ValidatedKernelMetadata = ValidatedKernelMetadata
  { -- | Inductive ID -> Name
    validatedInductives :: IntMap HCName,
    -- | Recursor ID -> Meta
    validatedRecursors :: IntMap RecursorMeta
  }

data RecursorMeta = RecursorMeta
  { recTargetInductive :: HCName,
    -- | Ctor ID -> Expected Fields
    recExpectedFields :: IntMap Int
  }

data LocalDecl = LocalDecl
  { localName :: HCName,
    localType :: Value,
    -- | For let-bindings
    localValue :: Maybe Value
  }
  deriving (Show)

type LocalCtx = IntMap LocalDecl

data KernelCtx = KernelCtx
  { checkEnv :: KernelEnv,
    checkLocalCtx :: LocalCtx,
    checkMetadata :: ValidatedKernelMetadata
  }

data KernelState = KernelState
  { checkInternState :: InternState,
    checkUnfoldStack :: ![HCName],
    checkVisited :: ![(HCId, HCId)],
    checkFailed :: ![(HCId, HCId)],
    checkTraceStack :: ![[TraceNode]],
    checkMaxVerb :: !Verbosity,
    checkActiveTags :: ![TraceTag]
  }

instance HasInternState KernelState where
  getInternState = checkInternState
  setInternState s st = st {checkInternState = s}

type KernelError = String

newtype KernelM a = KernelM {unKernelM :: KernelCtx -> KernelState -> (Either KernelError a, KernelState)}

instance Functor KernelM where
  fmap f (KernelM m) = KernelM $ \ctx st ->
    case m ctx st of
      (Right a, st') -> (Right (f a), st')
      (Left err, st') -> (Left err, st')
  {-# INLINE fmap #-}

instance Applicative KernelM where
  pure a = KernelM $ \_ st -> (Right a, st)
  {-# INLINE pure #-}
  KernelM mf <*> KernelM ma = KernelM $ \ctx st ->
    case mf ctx st of
      (Left err, st') -> (Left err, st')
      (Right f, st') -> case ma ctx st' of
        (Left err, st'') -> (Left err, st'')
        (Right a, st'') -> (Right (f a), st'')
  {-# INLINE (<*>) #-}

instance Monad KernelM where
  return = pure
  KernelM m >>= f = KernelM $ \ctx st ->
    case m ctx st of
      (Left err, st') -> (Left err, st')
      (Right a, st') -> unKernelM (f a) ctx st'
  {-# INLINE (>>=) #-}

instance MonadReader KernelCtx KernelM where
  ask = KernelM $ \ctx st -> (Right ctx, st)
  {-# INLINE ask #-}
  local f (KernelM m) = KernelM $ \ctx st -> m (f ctx) st
  {-# INLINE local #-}

instance MonadState KernelState KernelM where
  get = KernelM $ \_ st -> (Right st, st)
  {-# INLINE get #-}
  put !newSt = KernelM $ \_ _ -> (Right (), newSt)
  {-# INLINE put #-}

instance MonadError KernelError KernelM where
  throwError err = KernelM $ \_ st -> (Left err, st)
  {-# INLINE throwError #-}
  catchError (KernelM m) handler = KernelM $ \ctx st ->
    case m ctx st of
      (Left err, st') -> unKernelM (handler err) ctx st'
      success -> success
  {-# INLINE catchError #-}

instance MonadFail KernelM where
  fail = throwError
  {-# INLINE fail #-}

instance Show (KernelM a) where
  show _ = "<thunk>"

emptyKernelState :: KernelState
emptyKernelState =
  KernelState
    { checkInternState = emptyInternState,
      checkUnfoldStack = [],
      checkVisited = [],
      checkFailed = [],
      checkTraceStack = [],
      checkMaxVerb = VSilent,
      checkActiveTags = []
    }

emptyKernelCtx :: KernelEnv -> KernelCtx
emptyKernelCtx env = KernelCtx {checkEnv = env, checkLocalCtx = IntMap.empty, checkMetadata = ValidatedKernelMetadata IntMap.empty IntMap.empty}

-- | Runs the kernel, returning both the result and the final state
runKernelM :: KernelEnv -> InternState -> KernelM a -> (Either KernelError a, KernelState)
runKernelM env internSt action = (unKernelM action) (emptyKernelCtx env) (emptyKernelState {checkInternState = internSt})

-- | Evaluates the kernel, discarding the final state
evalKernelM :: KernelEnv -> InternState -> KernelM a -> Either KernelError a
evalKernelM env internSt action = fst $ runKernelM env internSt action

-- | Executes the kernel, discarding the result and keeping the state
execKernelM :: KernelEnv -> InternState -> KernelM a -> Either KernelError KernelState
execKernelM env internSt action = case runKernelM env internSt action of
  (Left err, _) -> Left err
  (Right _, st) -> Right st

--------------------------------------------------------------------------------

data TraceNode
  = TraceMessage Doc
  | TraceBlock Doc [TraceNode]
  | TraceError Doc

data Verbosity
  = VSilent
  | VLow
  | VMid
  | VHigh
  deriving (Show, Eq, Ord, Enum, Bounded)

data TraceTag
  = TEval
  | TInfer
  | TDefEq
  | TEta
  | TQuote
  | TMisc
  deriving (Show, Eq, Ord, Enum, Bounded)

instance PrettyPrint TraceNode where
  ppr (TraceMessage d) = green (text "⊢") <+> d
  ppr (TraceError d) = bold (red (text "✗" <+> d))
  ppr (TraceBlock name children) =
    vcat ((bold (blue (text "▼" <+> name))) : map (nest 2 . ppr) children)

shouldTrace :: Verbosity -> TraceTag -> KernelM Bool
shouldTrace v tag = do
  state <- get
  pure $ (v <= checkMaxVerb state) && (tag `elem` checkActiveTags state)

traceMsgM :: (PrettyPrint a) => Verbosity -> TraceTag -> a -> KernelM ()
traceMsgM v tag item = do
  active <- shouldTrace v tag
  when active $ modify' $ \s ->
    case checkTraceStack s of
      (currentLevel : rest) -> s {checkTraceStack = (currentLevel ++ [TraceMessage (ppr item)]) : rest}
      [] -> s {checkTraceStack = [[TraceMessage (ppr item)]]}

withTraceNode :: Verbosity -> TraceTag -> Doc -> KernelM a -> KernelM a
withTraceNode v tag blockDoc action = do
  active <- shouldTrace v tag
  if not active
    then action
    else do
      -- Push empty level
      modify' $ \s -> s {checkTraceStack = [] : checkTraceStack s}

      -- Run action catching errors
      res <-
        catchError
          action
          ( \err -> do
              modify' $ \s -> case checkTraceStack s of
                (lvl : rest) -> s {checkTraceStack = (lvl ++ [TraceError (text err)]) : rest}
                [] -> s
              throwError err
          )

      -- Pop level and wrap in Block
      modify' $ \s ->
        case checkTraceStack s of
          (completedLevel : parentLevel : rest) ->
            let block = TraceBlock blockDoc completedLevel
             in s {checkTraceStack = (parentLevel ++ [block]) : rest}
          _ -> s

      pure res

renderKernelTrace :: KernelState -> Doc
renderKernelTrace st = case checkTraceStack st of
  [] -> text "No trace generated."
  [topLevel] -> vcat (map ppr topLevel)
  malformedStack ->
    text "Warning: Malformed trace stack (unclosed blocks)."
      <> text "\n"
      <> vcat (map ppr (concat (reverse malformedStack)))

withVerbosity :: Verbosity -> [TraceTag] -> KernelM a -> KernelM a
withVerbosity v tags action = do
  oldVerb <- gets checkMaxVerb
  oldTags <- gets checkActiveTags
  modify' $ \s -> s {checkMaxVerb = v, checkActiveTags = tags}
  res <- action
  modify' $ \s -> s {checkMaxVerb = oldVerb, checkActiveTags = oldTags}
  pure res

withMaxVerbosity :: KernelM a -> KernelM a
withMaxVerbosity = withVerbosity maxBound [minBound .. maxBound]

runKernelWithTraceIO :: KernelEnv -> InternState -> KernelM a -> IO (Either KernelError a, InternState)
runKernelWithTraceIO env internSt action = do
  let initialCtx = emptyKernelCtx env
      initialSt = emptyKernelState {checkInternState = internSt}
      (res, finalState) = unKernelM action initialCtx initialSt
  putStrLn "\n================ KERNEL TRACE ================"
  putStrLn $ toString (renderKernelTrace finalState)
  putStrLn "==============================================\n"
  case res of
    Left err -> putStrLn $ "❌ Kernel Error: " ++ err
    Right _ -> putStrLn "✅ Kernel Execution Succeeded."
  pure (res, checkInternState finalState)

--------------------------------------------------------------------------------

isConstOnUnfoldStack :: HCName -> KernelM Bool
isConstOnUnfoldStack name = elem name <$> gets checkUnfoldStack

withUnfoldingConst :: HCName -> KernelM Bool -> KernelM Bool
withUnfoldingConst name action = do
  seen <- isConstOnUnfoldStack name
  if seen
    then pure False
    else do
      modify' (\s -> s {checkUnfoldStack = name : checkUnfoldStack s})
      res <- action
      modify' (\s -> s {checkUnfoldStack = filter (/= name) (checkUnfoldStack s)})
      pure res

orderedPair :: HCExpr -> HCExpr -> (HCId, HCId)
orderedPair e1 e2 =
  let id1 = hceId e1
      id2 = hceId e2
   in if id1 <= id2 then (id1, id2) else (id2, id1)

isVisitedExprPair :: HCExpr -> HCExpr -> KernelM Bool
isVisitedExprPair e1 e2 = elem (orderedPair e1 e2) <$> gets checkVisited

withVisitedExprPair :: HCExpr -> HCExpr -> KernelM a -> KernelM a
withVisitedExprPair e1 e2 action = do
  let pair = orderedPair e1 e2
  modify' (\s -> s {checkVisited = pair : checkVisited s})
  res <- action
  modify' (\s -> s {checkVisited = filter (/= pair) (checkVisited s)})
  pure res

recordFailedExprPair :: HCExpr -> HCExpr -> KernelM ()
recordFailedExprPair e1 e2 =
  modify' (\s -> s {checkFailed = orderedPair e1 e2 : checkFailed s})

isFailedExprPair :: HCExpr -> HCExpr -> KernelM Bool
isFailedExprPair e1 e2 = elem (orderedPair e1 e2) <$> gets checkFailed

--------------------------------------------------------------------------------

lookupConstInfo :: HCName -> KernelM (Maybe (ConstantInfo HCExpr HCLevel))
lookupConstInfo name = asks (IntMap.lookup (hcnId name) . checkEnv)

lookupLocalType :: Int -> KernelM Value
lookupLocalType lvl = do
  ctx <- asks checkLocalCtx
  case IntMap.lookup lvl ctx of
    Just decl -> pure $ localType decl
    Nothing -> throwError "Unbound free variable in local context"

lookupLocalValue :: Int -> KernelM (Maybe Value)
lookupLocalValue lvl = do
  ctx <- asks checkLocalCtx
  case IntMap.lookup lvl ctx of
    Just decl -> pure $ localValue decl
    Nothing -> throwError "Unbound free variable in local context"

--------------------------------------------------------------------------------

lookupValidatedConstructor :: HCName -> KernelM (ConstructorVal HCExpr HCLevel)
lookupValidatedConstructor ctorName = do
  metadata <- asks checkMetadata
  case IntMap.lookup (hcnId ctorName) (validatedInductives metadata) of
    Just indName -> do
      mInfo <- lookupConstInfo indName
      case mInfo of
        Just (CtorInfo val) -> pure val
        _ -> throwError "Validated inductive not found in environment"
    Nothing -> throwError $ "Constructor not validated: " <> show ctorName

lookupValidatedRecursorRule :: HCName -> HCName -> KernelM (RecursorRule HCExpr HCLevel)
lookupValidatedRecursorRule recName majorCtorName = do
  metadata <- asks checkMetadata
  recMeta <- case IntMap.lookup (hcnId recName) (validatedRecursors metadata) of
    Just meta -> pure meta
    Nothing -> throwError $ "Recursor not validated: " <> show recName
  expectedFields <- case IntMap.lookup (hcnId majorCtorName) (recExpectedFields recMeta) of
    Just n -> pure n
    Nothing -> throwError $ "Major constructor " <> show majorCtorName <> " not validated for recursor: " <> show recName
  mInfo <- lookupConstInfo recName
  case mInfo of
    Just (RecInfo recVal) -> case filter (\r -> recCtor r == majorCtorName) (recRules recVal) of
      [rule] ->
        if recFieldsN rule == expectedFields
          then pure rule
          else throwError "Payload rule arity differs from validated metadata"
      _ -> throwError "Rule missing or duplicated in RecursorVal payload"
    _ -> throwError "Validated recursor ID does not point to a RecInfo"

lookupValidatedRecursorTargetInductive :: HCName -> KernelM HCName
lookupValidatedRecursorTargetInductive recName = do
  metadata <- asks checkMetadata
  recMeta <- case IntMap.lookup (hcnId recName) (validatedRecursors metadata) of
    Just meta -> pure meta
    Nothing -> throwError $ "Recursor not validated: " <> show recName
  pure $ recTargetInductive recMeta

--------------------------------------------------------------------------------

lookupInducVal :: HCName -> KernelM (InductiveVal HCExpr HCLevel)
lookupInducVal indName = do
  mInfo <- lookupConstInfo indName
  case mInfo of
    Just (InductInfo val) -> pure val
    _ -> throwError "Inductive not found in environment"

-- | Traverses the Pi binders to find the major premise's inductive name
getMajorInduct :: HCExpr -> Int -> KernelM HCName
getMajorInduct typeExpr majorIdx = go majorIdx typeExpr
  where
    go :: Int -> HCExpr -> KernelM HCName
    go 0 expr = case hceVal expr of
      ForallE _ domain _ _ ->
        case hceVal (getAppFn domain) of
          Const indName _ -> pure indName
          _ -> throwError "Major domain head is not a Const"
      Lam _ domain _ _ ->
        case hceVal (getAppFn domain) of
          Const indName _ -> pure indName
          _ -> throwError "Major domain head is not a Const"
      _ -> throwError "Binding expected for major premise"
    go n expr = case hceVal expr of
      ForallE _ _ body _ -> go (n - 1) body
      Lam _ _ body _ -> go (n - 1) body
      _ -> throwError "Binding expected before reaching major index"

getDefHints :: HCName -> KernelM ReducibilityHints
getDefHints name = do
  mInfo <- asks (IntMap.lookup (hcnId name) . checkEnv)
  case mInfo >>= constantInfoDeltaUnfoldability of
    Just hints -> pure hints
    Nothing -> pure Opaque

withLocalDecl :: Int -> LocalDecl -> KernelM a -> KernelM a
withLocalDecl depth decl k = local (\ctx -> ctx {checkLocalCtx = IntMap.insert depth decl (checkLocalCtx ctx)}) k

modifyGlobalEnv :: (KernelEnv -> KernelEnv) -> KernelM ()
modifyGlobalEnv f = local (\ctx -> ctx {checkEnv = f (checkEnv ctx)}) (pure ())

--------------------------------------------------------------------------------

type LocalEnv = [Value]

data Closure = Closure
  { closureEnv :: LocalEnv,
    closureBody :: HCExpr
  }
  deriving (Show)

-- | Spines store arguments in _reverse_ order (innermost application is last).
type Spine = [Elim]

data Elim
  = EApp !Value
  | EProj !HCName !Int
  deriving (Show)

data Head
  = -- | De Bruijn level of a local variable. We store the name for pretty-printing and error messages
    HLvl !HCName !Int
  | HConst !HCName ![HCLevel]
  deriving (Show)

instance Eq Head where
  HLvl _ i1 == HLvl _ i2 = i1 == i2
  HConst n1 ls1 == HConst n2 ls2 = n1 == n2 && ls1 == ls2
  _ == _ = False

data Value
  = VSort HCLevel
  | VLit Literal
  | VLam HCName BinderInfo Value Closure
  | VPi HCName BinderInfo Value Closure
  | -- | A stuck term (e.g., Free Variable applied to arguments)
    VNeutral Head Spine
  | -- | Lazy Delta Reduction
    -- We store the structural data for fast head-checks, and a lazy
    -- Haskell thunk of the unfolded definition.
    VDef HCName [HCLevel] Spine (KernelM Value)
  deriving (Show)

instance PrettyPrint Closure where
  ppr (Closure env body) =
    dim (text "Closure")
      <> ( dim (char '{')
             <+> dim (text "env:")
             <+> brackets (hcatWithComma (map ppr env))
             <+> dim (text "body:")
             <+> ppr body
             <+> dim (char '}')
         )

instance PrettyPrint Elim where
  ppr elim =
    case elim of
      EApp arg ->
        bold (magenta (text "EApp")) <+> dim (parens (ppr arg))
      EProj projName idx ->
        bold (magenta (text "EProj")) <+> dim (parens (green (ppr projName) <> dim (char '.') <> cyan (int idx)))

instance PrettyPrint Head where
  ppr head =
    case head of
      HLvl name lvl -> ppr name <> text "^" <> int lvl
      HConst name levels ->
        green (ppr name)
          <> if null levels
            then text ""
            else dim (brackets (hcatWithComma (map ppr levels)))

instance PrettyPrint Value where
  ppr val =
    case val of
      VSort lvl -> yellow (text "VSort") <+> parens (ppr lvl)
      VLit lit -> cyan (text "VLit") <+> parens (ppr lit)
      VLam name binderInfo ty body -> magenta (text "VLam") <+> parens (ppBinder binderInfo name ty <+> text "=>" <+> ppr body)
      VPi name binderInfo ty body -> bold (magenta (text "VPi")) <+> parens (ppBinder binderInfo name ty <+> text "=>" <+> ppr body)
      VNeutral head spine -> red (text "VNeutral") <+> parens (ppr head <+> ppr spine)
      VDef name levels spine _ -> blue (text "VDef") <+> parens (ppr name <+> ppr levels <+> ppr spine <+> (dim (text "<thunk>")))
