{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Mlkih.Kernel.Types where

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
  { localType :: Value,
    -- | For let-bindings
    localValue :: Maybe Value
  }
  deriving (Show)

type LocalCtx = [(FVarId HCName, LocalDecl)]

data KernelCtx = KernelCtx
  { checkEnv :: KernelEnv,
    checkLocalCtx :: LocalCtx,
    checkMetadata :: ValidatedKernelMetadata
  }

data KernelState = KernelState
  { checkInternState :: InternState,
    checkNextLocalId :: !Int,
    checkUnfoldStack :: ![HCName],
    checkVisited :: ![(HCId, HCId)],
    checkFailed :: ![(HCId, HCId)]
  }

instance HasInternState KernelState where
  getInternState = checkInternState
  setInternState s st = st {checkInternState = s}

type KernelError = String

newtype KernelM a = KernelM
  {unKernelM :: ReaderT KernelCtx (StateT KernelState (Either KernelError)) a}
  deriving (Functor, Applicative, Monad, MonadReader KernelCtx, MonadState KernelState, MonadError KernelError)

instance Show (KernelM a) where
  show _ = "<KernelM>"

emptyKernelState :: KernelState
emptyKernelState = KernelState {checkInternState = emptyInternState, checkNextLocalId = 0, checkUnfoldStack = [], checkVisited = [], checkFailed = []}

emptyKernelCtx :: KernelEnv -> KernelCtx
emptyKernelCtx env = KernelCtx {checkEnv = env, checkLocalCtx = [], checkMetadata = ValidatedKernelMetadata IntMap.empty IntMap.empty}

-- | Runs the kernel, returning both the result and the final state
runKernelM :: KernelEnv -> InternState -> KernelM a -> Either String (a, KernelState)
runKernelM env internSt action = runStateT (runReaderT (unKernelM action) (emptyKernelCtx env)) (emptyKernelState {checkInternState = internSt})

-- | Evaluates the kernel, discarding the final state
evalKernelM :: KernelEnv -> InternState -> KernelM a -> Either String a
evalKernelM env internSt action = fst <$> runKernelM env internSt action

-- | Executes the kernel, discarding the result and keeping the state
execKernelM :: KernelEnv -> InternState -> KernelM a -> Either String KernelState
execKernelM env internSt action = snd <$> runKernelM env internSt action

--------------------------------------------------------------------------------

freshFVar :: HCName -> KernelM (FVarId HCName)
freshFVar baseName = do
  idx <- gets checkNextLocalId
  modify $ \st -> st {checkNextLocalId = idx + 1}
  let freshShape = Num baseName idx
  freshHCName <- withIntern $ internNameVal freshShape
  pure $ FVarId freshHCName

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

lookupLocalType :: FVarId HCName -> KernelM Value
lookupLocalType fv = do
  ctx <- asks checkLocalCtx
  case lookup fv ctx of
    Just decl -> pure $ localType decl
    Nothing -> throwError "Unbound free variable in local context"

lookupLocalValue :: FVarId HCName -> KernelM (Maybe Value)
lookupLocalValue fv = do
  ctx <- asks checkLocalCtx
  case lookup fv ctx of
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

withLocalDecl :: FVarId HCName -> LocalDecl -> KernelM a -> KernelM a
withLocalDecl fvarId decl k = do
  KernelM $ local (\ctx -> ctx {checkLocalCtx = (fvarId, decl) : checkLocalCtx ctx}) (unKernelM k)

modifyGlobalEnv :: (KernelEnv -> KernelEnv) -> KernelM ()
modifyGlobalEnv f = do
  KernelM $ local (\ctx -> ctx {checkEnv = f (checkEnv ctx)}) (pure ())

--------------------------------------------------------------------------------

type Env = [Value]

data Closure = Closure
  { closureEnv :: Env,
    closureBody :: HCExpr
  }
  deriving (Show)

-- | Spines store arguments in _reverse_ order (innermost application is last).
type Spine = [Elim]

data Elim
  = EApp Value
  | EProj HCName Int
  deriving (Show)

data Head
  = HFVar (FVarId HCName)
  | HConst HCName [HCLevel]
  deriving (Show, Eq)

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
  ppr (Closure env body) = text "Closure" <> parens (text "env:" <+> brackets (hcatWithComma (map ppr env)) <+> text "body:" <+> ppr body)

instance PrettyPrint Elim where
  ppr elim =
    case elim of
      EApp arg -> text "EApp" <+> parens (ppr arg)
      EProj projName idx -> text "EProj" <+> parens (ppr projName <+> int idx)

instance PrettyPrint Head where
  ppr head =
    case head of
      HFVar fvarId -> text "HFVar" <+> parens (ppr fvarId)
      HConst name levels -> text "HConst" <+> parens (ppr name <+> brackets (hcatWithComma (map ppr levels)))

instance PrettyPrint Value where
  ppr val =
    case val of
      VSort lvl -> text "VSort" <+> parens (ppr lvl)
      VLit lit -> text "VLit" <+> parens (ppr lit)
      VLam name binderInfo ty body -> text "VLam" <+> parens (ppr name <+> ppr binderInfo <+> ppr ty <+> text "->" <+> ppr body)
      VPi name binderInfo ty body -> text "VPi" <+> parens (ppr name <+> ppr binderInfo <+> ppr ty <+> text "->" <+> ppr body)
      VNeutral head spine -> text "VNeutral" <+> parens (ppr head <+> brackets (hcatWithComma (map ppr spine)))
      VDef name levels spine _ -> text "VDef" <+> parens (ppr name <+> brackets (hcatWithComma (map ppr levels)) <+> brackets (hcatWithComma (map ppr spine)) <+> text "<thunk>")
