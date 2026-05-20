module Mlkih.Kernel.Monad
  ( KernelM,
    KernelCtx,
    KernelState,
    KernelEnv,
    KernelError,
    runKernelM,
    evalKernelM,
    execKernelM,
    execKernelM',
    finallyM,
    bracketM,
    emptyKernelEnv,
    emptyKernelCtx,
    emptyKernelState,
    runKernelWithTraceIO,
    lookupConstInfo,
    lookupLocalType,
    lookupLocalValue,
    lookupInducVal,
    lookupStructureConstructor,
    constHasBody,
    constIsDeltaUnfoldable,
    getDefHints,
    withLocalDecl,
    lookupValidatedConstructor,
    lookupValidatedRecursorRule,
    lookupValidatedRecursorTargetInductive,
    modifyMetadata,
    modifyGlobalEnv,
  )
where

import Control.Monad.Error.Class
import Control.Monad.Reader.Class
import Control.Monad.State.Strict
import qualified Data.IntMap.Strict as IntMap
import qualified Data.Map.Strict as Map
import Mlkih.Env
import Mlkih.Expr
import Mlkih.Intern
import Mlkih.Kernel.Trace
import Mlkih.Kernel.Types
import Mlkih.Level
import Mlkih.Name
import Mlkih.Pretty

------------------------------------------------------------

emptyKernelState :: KernelEnv -> KernelState
emptyKernelState env =
  KernelState
    { checkEnv = env,
      checkMetadata = ValidatedKernelMetadata IntMap.empty IntMap.empty,
      checkInternState = emptyInternState,
      checkClosedDefEqActive = [],
      checkClosedDefEqCache = Map.empty,
      checkTraceStack = []
    }

emptyKernelCtx :: KernelCtx
emptyKernelCtx =
  KernelCtx
    { checkLocalCtx = IntMap.empty,
      checkTraceConfig = defaultTraceConfig
    }

emptyKernelEnv :: KernelEnv
emptyKernelEnv = IntMap.empty

-- | Runs the kernel, returning both the result and the final state
runKernelM :: KernelEnv -> InternState -> KernelM a -> (Either KernelError a, KernelState)
runKernelM env internSt action = (unKernelM action) emptyKernelCtx ((emptyKernelState env) {checkInternState = internSt})

-- | Evaluates the kernel, discarding the final state
evalKernelM :: KernelEnv -> InternState -> KernelM a -> Either KernelError a
evalKernelM env internSt action = fst $ runKernelM env internSt action

-- | Executes the kernel, discarding the result and keeping the state
execKernelM :: KernelEnv -> InternState -> KernelM a -> Either KernelError KernelState
execKernelM env internSt action = case runKernelM env internSt action of
  (Left err, _) -> Left err
  (Right _, st) -> Right st

execKernelM' :: KernelM a -> Either KernelError KernelState
execKernelM' action = execKernelM emptyKernelEnv emptyInternState action

runKernelWithTraceIO :: KernelEnv -> InternState -> KernelM a -> IO (Either KernelError a, InternState)
runKernelWithTraceIO env internSt action = do
  let (result, finalState) = runKernelM env internSt action
  printKernelTrace finalState
  case result of
    Left err -> putStrLn $ "❌ Kernel Error: " ++ err
    Right _ -> putStrLn "✅ Kernel Execution Succeeded."
  pure (result, checkInternState finalState)

------------------------------------------------------------

finallyM :: KernelM a -> KernelM b -> KernelM a
finallyM action cleanup =
  catchError
    ( do
        r <- action
        _ <- cleanup
        pure r
    )
    ( \err -> do
        _ <- cleanup
        throwError err
    )

bracketM :: KernelM a -> (a -> KernelM b) -> (a -> KernelM c) -> KernelM c
bracketM acquire release use = do
  x <- acquire
  use x `finallyM` release x

--------------------------------------------------------------------------------

lookupConstInfo :: HCName -> KernelM (Maybe (ConstantInfo HCExpr HCLevel))
lookupConstInfo name = gets (IntMap.lookup (hcnId name) . checkEnv)

lookupLocalType :: Int -> KernelM Value
lookupLocalType lvl = do
  ctx <- asks checkLocalCtx
  case IntMap.lookup lvl ctx of
    Just decl -> pure $ localType decl
    Nothing ->
      throwError $
        "Unbound free variable in local context: level "
          <> toString lvl
          <> ", available levels = "
          <> toString (IntMap.keys ctx)

lookupLocalValue :: Int -> KernelM (Maybe Value)
lookupLocalValue lvl = do
  ctx <- asks checkLocalCtx
  case IntMap.lookup lvl ctx of
    Just decl -> pure $ localValue decl
    Nothing ->
      throwError $
        "Unbound free variable in local context: level "
          <> toString lvl
          <> ", available levels = "
          <> toString (IntMap.keys ctx)

lookupInducVal :: HCName -> KernelM (InductiveVal HCExpr HCLevel)
lookupInducVal indName = do
  mInfo <- lookupConstInfo indName
  case mInfo of
    Just (InductInfo val) -> pure val
    _ -> throwError "Inductive not found in environment"

lookupStructureConstructor :: HCName -> KernelM (InductiveVal HCExpr HCLevel, ConstructorVal HCExpr HCLevel)
lookupStructureConstructor indName = do
  mInfo <- lookupConstInfo indName
  case mInfo of
    Just (InductInfo indVal) ->
      case indCtors indVal of
        [ctorName] -> do
          mCtorInfo <- lookupConstInfo ctorName
          case mCtorInfo of
            Just (CtorInfo ctorVal) ->
              pure (indVal, ctorVal)
            _ ->
              throwError "Constructor not found"
        _ ->
          throwError "Expected exactly one constructor"
    _ ->
      throwError "Inductive not found"

constHasBody :: HCName -> KernelM Bool
constHasBody name = maybe False constantInfoHasBody <$> lookupConstInfo name

constIsDeltaUnfoldable :: HCName -> KernelM Bool
constIsDeltaUnfoldable name = maybe False constantInfoIsDeltaUnfoldable <$> lookupConstInfo name

getDefHints :: HCName -> KernelM ReducibilityHints
getDefHints name = do
  mInfo <- gets (IntMap.lookup (hcnId name) . checkEnv)
  case mInfo >>= constantInfoDeltaUnfoldability of
    Just hints -> pure hints
    Nothing -> pure Opaque

------------------------------------------------------------

withLocalDecl :: Int -> LocalDecl -> KernelM a -> KernelM a
withLocalDecl depth decl k = local (\ctx -> ctx {checkLocalCtx = IntMap.insert depth decl (checkLocalCtx ctx)}) k

--------------------------------------------------------------------------------

lookupValidatedConstructor :: HCName -> KernelM (ConstructorVal HCExpr HCLevel)
lookupValidatedConstructor ctorName = do
  metadata <- gets checkMetadata
  case IntMap.lookup (hcnId ctorName) (validatedInductives metadata) of
    Just indName -> do
      mInfo <- lookupConstInfo indName
      case mInfo of
        Just (CtorInfo val) -> pure val
        _ -> throwError "Validated inductive not found in environment"
    Nothing -> throwError $ "Constructor not validated: " <> toString ctorName

lookupValidatedRecursorRule :: HCName -> HCName -> KernelM (RecursorRule HCExpr HCLevel)
lookupValidatedRecursorRule recName majorCtorName = do
  metadata <- gets checkMetadata
  recMeta <- case IntMap.lookup (hcnId recName) (validatedRecursors metadata) of
    Just meta -> pure meta
    Nothing -> throwError $ "Recursor not validated: " <> toString recName
  expectedFields <- case IntMap.lookup (hcnId majorCtorName) (recExpectedFields recMeta) of
    Just n -> pure n
    Nothing -> throwError $ "Major constructor " <> toString majorCtorName <> " not validated for recursor: " <> toString recName
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
  metadata <- gets checkMetadata
  recMeta <- case IntMap.lookup (hcnId recName) (validatedRecursors metadata) of
    Just meta -> pure meta
    Nothing -> throwError $ "Recursor not validated: " <> toString recName
  pure $ recTargetInductive recMeta

------------------------------------------------------------

modifyMetadata :: (ValidatedKernelMetadata -> ValidatedKernelMetadata) -> KernelM ()
modifyMetadata f =
  modify' $ \s ->
    s
      { checkMetadata = f (checkMetadata s),
        checkClosedDefEqActive = [],
        checkClosedDefEqCache = Map.empty
      }

modifyGlobalEnv :: (KernelEnv -> KernelEnv) -> KernelM ()
modifyGlobalEnv f = modify' $ \s ->
  s
    { checkEnv = f (checkEnv s),
      checkClosedDefEqActive = [],
      checkClosedDefEqCache = Map.empty
    }
