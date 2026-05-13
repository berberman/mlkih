{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Mlkih.Kernel
  ( KernelError,
    LocalCtx,
    LocalDecl (..),
    Closure (..),
    Value (..),
    NbEState (..),
    LazyDeltaChoice (..),
    LazyDeltaStepResult (..),
    KernelCtx (..),
    KernelState (..),
    KernelM,
    emptyKernelState,
    runKernelM,
    evalKernelM,
    execKernelM,
    getLocalCtx,
    lookupLocalDecl,
    lookupConstInfo,
    lookupConstBody,
    constHasBody,
    constIsDeltaUnfoldable,
    lookupConstReducibilityHints,
    findExprClassRoot,
    sameExprClass,
    unionExprClasses,
    getNbEState,
    isVisitedExprPair,
    markVisitedExprPair,
    unmarkVisitedExprPair,
    withVisitedExprPair,
    isFailedExprPair,
    recordFailedExprPair,
    clearFailedExprPair,
    getUnfoldStack,
    isConstOnUnfoldStack,
    pushUnfoldConst,
    popUnfoldConst,
    withUnfoldingConst,
    instantiateConstType,
    internNameM,
    internLevelM,
    internExprM,
    localDeclExpr,
    withLocalDecl,
    withLocalDecls,
    inferExpr,
    checkExprHasType,
    checkAndAddDecl,
    checkAndAddDecls,
    lazyDeltaReductionStep,
    whnf,
    isDefEq,
  )
where

import Control.Monad.Error.Class (MonadError, throwError)
import Control.Monad.Except (catchError)
import Control.Monad.Reader (MonadReader, ReaderT (..), asks, local)
import Control.Monad.State.Strict (MonadState, State, StateT (..), get, gets, modify, put, runState)
import Data.Foldable (foldlM)
import qualified Data.IntMap.Strict as IntMap
import qualified Data.Set as Set
import qualified Data.Text as Text
import Mlkih.AST
import Mlkih.Decl
import Mlkih.Env
import Mlkih.Expr
import Mlkih.Intern
import Mlkih.Level
import Mlkih.Name
import Mlkih.Pretty
import Mlkih.UnionFind (UnionFind)
import qualified Mlkih.UnionFind as UnionFind

type KernelError = String

type LocalCtx = [LocalDecl]

data LocalDecl = LocalDecl
  { localFVarId :: FVarId HCName,
    localName :: HCName,
    localType :: HCExpr,
    localBinderInfo :: BinderInfo
  }
  deriving (Show, Eq, Ord)

data Closure = Closure
  { closureLocalCtx :: LocalCtx,
    closureBody :: HCExpr
  }
  deriving (Show, Eq, Ord)

data Value
  = NeutralValue HCExpr
  | SortValue HCLevel
  | LamValue BinderView Closure
  | ForallValue HCName HCExpr Closure BinderInfo
  deriving (Show, Eq, Ord)

data NbEState = NbEState
  { checkValueStack :: [Value]
  }
  deriving (Show, Eq, Ord)

data LazyDeltaChoice
  = LazyDeltaNone
  | LazyDeltaUnfoldLhs
  | LazyDeltaUnfoldRhs
  | LazyDeltaUnfoldBoth
  | LazyDeltaSameHeadEq
  deriving (Show, Eq, Ord)

data LazyDeltaStepResult = LazyDeltaStepResult
  { lazyDeltaStepChoice :: LazyDeltaChoice,
    lazyDeltaStepLhs :: HCExpr,
    lazyDeltaStepRhs :: HCExpr
  }
  deriving (Show, Eq, Ord)

data ExprPair = ExprPair !Int !Int
  deriving (Show, Eq, Ord)

data LazyDeltaCandidate = LazyDeltaCandidate
  { lazyDeltaCandidateExpr :: HCExpr,
    lazyDeltaCandidateView :: ConstAppView,
    lazyDeltaCandidateDefn :: DefinitionVal HCExpr HCLevel
  }

data KernelCtx = KernelCtx
  { checkEnv :: KernelEnv,
    checkLocalCtx :: LocalCtx,
    checkValidatedMetadata :: ValidatedKernelMetadata
  }

data ValidatedKernelMetadata = ValidatedKernelMetadata
  { validatedInductives :: IntMap.IntMap ValidatedInductiveMeta,
    validatedConstructors :: IntMap.IntMap ValidatedConstructorMeta,
    validatedRecursors :: IntMap.IntMap ValidatedRecursorMeta
  }

data ValidatedInductiveMeta = ValidatedInductiveMeta
  { validatedInductiveInfo :: InductiveVal HCExpr HCLevel,
    validatedInductiveConstructors :: [ValidatedConstructorMeta]
  }

data ValidatedConstructorMeta = ValidatedConstructorMeta
  { validatedConstructorInfo :: ConstructorVal HCExpr HCLevel
  }

data ValidatedRecursorRuleMeta = ValidatedRecursorRuleMeta
  { validatedRecursorRuleInfo :: RecursorRule HCExpr HCLevel,
    validatedRecursorRuleConstructor :: ValidatedConstructorMeta
  }

data ValidatedRecursorMeta = ValidatedRecursorMeta
  { validatedRecursorInfo :: RecursorVal HCExpr HCLevel,
    validatedRecursorInductive :: ValidatedInductiveMeta,
    validatedRecursorRules :: IntMap.IntMap ValidatedRecursorRuleMeta
  }

data KernelState = KernelState
  { checkInternState :: InternState,
    checkNextLocalId :: !Int,
    checkExprUnionFind :: UnionFind,
    checkNbEState :: NbEState,
    checkVisitedExprPairs :: Set.Set ExprPair,
    checkFailedExprPairs :: Set.Set ExprPair,
    checkUnfoldStack :: [HCName]
  }

newtype KernelM a = KernelM (ReaderT KernelCtx (StateT KernelState (Either KernelError)) a)
  deriving (Functor, Applicative, Monad, MonadReader KernelCtx, MonadState KernelState, MonadError KernelError)

instance HasInternState KernelState where
  getStoredInternState = checkInternState
  setStoredInternState internState st = st {checkInternState = internState}

emptyKernelState :: KernelState
emptyKernelState =
  KernelState
    { checkInternState = emptyInternState,
      checkNextLocalId = minBound,
      checkExprUnionFind = UnionFind.emptyUnionFind,
      checkNbEState = NbEState {checkValueStack = []},
      checkVisitedExprPairs = Set.empty,
      checkFailedExprPairs = Set.empty,
      checkUnfoldStack = []
    }

runKernelM :: KernelEnv -> InternState -> KernelM a -> Either KernelError (a, KernelState)
runKernelM env internState (KernelM action) = do
  validatedMetadata <- validateKernelBootstrap env internState
  let initialCtx = KernelCtx {checkEnv = env, checkLocalCtx = [], checkValidatedMetadata = validatedMetadata}
  runStateT (runReaderT action initialCtx) (kernelStateWithInternState internState)

evalKernelM :: KernelEnv -> InternState -> KernelM a -> Either KernelError a
evalKernelM env internState action = fst <$> runKernelM env internState action

execKernelM :: KernelEnv -> InternState -> KernelM a -> Either KernelError KernelState
execKernelM env internState action = snd <$> runKernelM env internState action

getLocalCtx :: KernelM LocalCtx
getLocalCtx = asks checkLocalCtx

lookupLocalDecl :: FVarId HCName -> KernelM (Maybe LocalDecl)
lookupLocalDecl fvarId = do
  locals <- getLocalCtx
  pure $ go locals
  where
    go [] = Nothing
    go (decl : rest)
      | localFVarId decl == fvarId = Just decl
      | otherwise = go rest

lookupConstInfo :: HCName -> KernelM (Maybe (ConstantInfo HCExpr HCLevel))
lookupConstInfo name = asks (IntMap.lookup (hcnId name) . checkEnv)

lookupConstBody :: HCName -> KernelM (Maybe (Expr' HCExpr HCLevel HCName))
lookupConstBody name = maybe Nothing constantInfoBody <$> lookupConstInfo name

constHasBody :: HCName -> KernelM Bool
constHasBody name = maybe False constantInfoHasBody <$> lookupConstInfo name

constIsDeltaUnfoldable :: HCName -> KernelM Bool
constIsDeltaUnfoldable name = maybe False constantInfoIsDeltaUnfoldable <$> lookupConstInfo name

lookupConstReducibilityHints :: HCName -> KernelM (Maybe ReducibilityHints)
lookupConstReducibilityHints name = maybe Nothing constantInfoDeltaUnfoldability <$> lookupConstInfo name

lookupValidatedInductiveMeta :: HCName -> KernelM ValidatedInductiveMeta
lookupValidatedInductiveMeta typeName = do
  metadata <- asks checkValidatedMetadata
  case IntMap.lookup (hcnId typeName) (validatedInductives metadata) of
    Just indMeta -> pure indMeta
    Nothing -> throwError ("projection type is not a validated inductive: " <> toString typeName)

lookupValidatedConstructorMeta :: HCName -> KernelM ValidatedConstructorMeta
lookupValidatedConstructorMeta ctorName = do
  metadata <- asks checkValidatedMetadata
  case IntMap.lookup (hcnId ctorName) (validatedConstructors metadata) of
    Just ctorMeta -> pure ctorMeta
    Nothing -> throwError ("constructor is not validated: " <> toString ctorName)

lookupValidatedRecursorMeta :: HCName -> KernelM ValidatedRecursorMeta
lookupValidatedRecursorMeta recName = do
  metadata <- asks checkValidatedMetadata
  case IntMap.lookup (hcnId recName) (validatedRecursors metadata) of
    Just recMeta -> pure recMeta
    Nothing -> throwError ("recursor is not validated: " <> toString recName)

findExprClassRoot :: HCExpr -> KernelM HCExpr
findExprClassRoot expr = do
  rootId <- withExprUnionFind (UnionFind.findRoot (hceId expr))
  st <- get
  case lookupExprId rootId (checkInternState st) of
    Just rootExpr -> pure rootExpr
    Nothing -> throwError ("missing expr representative id " <> show rootId)

sameExprClass :: HCExpr -> HCExpr -> KernelM Bool
sameExprClass lhs rhs = withExprUnionFind (UnionFind.sameClass (hceId lhs) (hceId rhs))

unionExprClasses :: HCExpr -> HCExpr -> KernelM HCExpr
unionExprClasses lhs rhs = do
  representativeId <- withExprUnionFind (UnionFind.unionIds (hceId lhs) (hceId rhs))
  st <- get
  case lookupExprId representativeId (checkInternState st) of
    Just representative -> pure representative
    Nothing -> throwError ("missing expr representative id " <> show representativeId)

getNbEState :: KernelM NbEState
getNbEState = withNbEState get

isVisitedExprPair :: HCExpr -> HCExpr -> KernelM Bool
isVisitedExprPair lhs rhs = gets (Set.member (mkExprPair lhs rhs) . checkVisitedExprPairs)

markVisitedExprPair :: HCExpr -> HCExpr -> KernelM ()
markVisitedExprPair lhs rhs =
  withVisitedExprPairs $ modify (Set.insert (mkExprPair lhs rhs))

unmarkVisitedExprPair :: HCExpr -> HCExpr -> KernelM ()
unmarkVisitedExprPair lhs rhs =
  withVisitedExprPairs $ modify (Set.delete (mkExprPair lhs rhs))

withVisitedExprPair :: HCExpr -> HCExpr -> KernelM a -> KernelM (Bool, a)
withVisitedExprPair lhs rhs action = do
  alreadyVisited <- isVisitedExprPair lhs rhs
  markVisitedExprPair lhs rhs
  result <-
    action `catchError` \err -> do
      unmarkVisitedExprPair lhs rhs
      throwError err
  unmarkVisitedExprPair lhs rhs
  pure (alreadyVisited, result)

isFailedExprPair :: HCExpr -> HCExpr -> KernelM Bool
isFailedExprPair lhs rhs = gets (Set.member (mkExprPair lhs rhs) . checkFailedExprPairs)

recordFailedExprPair :: HCExpr -> HCExpr -> KernelM ()
recordFailedExprPair lhs rhs =
  withFailedExprPairs $ modify (Set.insert (mkExprPair lhs rhs))

clearFailedExprPair :: HCExpr -> HCExpr -> KernelM ()
clearFailedExprPair lhs rhs =
  withFailedExprPairs $ modify (Set.delete (mkExprPair lhs rhs))

getUnfoldStack :: KernelM [HCName]
getUnfoldStack = gets checkUnfoldStack

isConstOnUnfoldStack :: HCName -> KernelM Bool
isConstOnUnfoldStack name = gets (elem name . checkUnfoldStack)

pushUnfoldConst :: HCName -> KernelM ()
pushUnfoldConst name =
  withUnfoldStackState $ modify (name :)

popUnfoldConst :: KernelM (Maybe HCName)
popUnfoldConst =
  withUnfoldStackState $ do
    stack <- get
    case stack of
      top : rest -> put rest >> pure (Just top)
      [] -> pure Nothing

withUnfoldingConst :: HCName -> KernelM a -> KernelM (Bool, a)
withUnfoldingConst name action = do
  alreadyOnStack <- isConstOnUnfoldStack name
  pushUnfoldConst name
  result <-
    action `catchError` \err -> do
      _ <- popUnfoldConst
      throwError err
  _ <- popUnfoldConst
  pure (alreadyOnStack, result)

instantiateConstType :: ConstantVal HCExpr HCLevel -> [HCLevel] -> KernelM HCExpr
instantiateConstType constantVal levels
  | expectedCount /= actualCount =
      throwError
        ( "expected "
            <> show expectedCount
            <> " universe arguments for "
            <> toString (constName constantVal)
            <> ", got "
            <> show actualCount
        )
  | otherwise = instantiateLevelParamsExpr (zip (constLevelParameters constantVal) levels) (constType constantVal)
  where
    expectedCount = length (constLevelParameters constantVal)
    actualCount = length levels

internNameM :: Name -> KernelM HCName
internNameM name = withIntern $ internName name

internLevelM :: Level -> KernelM HCLevel
internLevelM level = withIntern $ internLevel level

internExprM :: Expr -> KernelM HCExpr
internExprM expr = withIntern $ internExpr expr

localDeclExpr :: LocalDecl -> KernelM HCExpr
localDeclExpr decl = withIntern $ internExprVal (FVar (localFVarId decl))

withLocalDecl :: Name -> HCExpr -> BinderInfo -> (LocalDecl -> KernelM a) -> KernelM a
withLocalDecl rawName ty binderInfo k = do
  displayName <- internNameM rawName
  fvarId <- freshLocalFVarId displayName
  let decl =
        LocalDecl
          { localFVarId = fvarId,
            localName = displayName,
            localType = ty,
            localBinderInfo = binderInfo
          }
  withExtendedLocalCtx decl (k decl)

withLocalDecls :: [(Name, HCExpr, BinderInfo)] -> ([LocalDecl] -> KernelM a) -> KernelM a
withLocalDecls [] k = k []
withLocalDecls ((name, ty, binderInfo) : rest) k =
  withLocalDecl name ty binderInfo $ \decl ->
    withLocalDecls rest $ \decls ->
      k (decl : decls)

lazyDeltaReductionStep :: (HCExpr -> HCExpr -> KernelM Bool) -> HCExpr -> HCExpr -> KernelM LazyDeltaStepResult
lazyDeltaReductionStep compareArgs lhs rhs = do
  lhsCandidate <- lookupLazyDeltaCandidate lhs
  rhsCandidate <- lookupLazyDeltaCandidate rhs
  case (lhsCandidate, rhsCandidate) of
    (Nothing, Nothing) -> pure (mkLazyDeltaStepResult lhs rhs lhs rhs)
    (Just lhsDelta, Nothing) -> do
      lhs' <- unfoldLazyDeltaCandidate lhsDelta
      pure (mkLazyDeltaStepResult lhs rhs lhs' rhs)
    (Nothing, Just rhsDelta) -> do
      rhs' <- unfoldLazyDeltaCandidate rhsDelta
      pure (mkLazyDeltaStepResult lhs rhs lhs rhs')
    (Just lhsDelta, Just rhsDelta) ->
      case compareReducibilityHintsForDelta (lazyDeltaCandidateHints lhsDelta) (lazyDeltaCandidateHints rhsDelta) of
        LT -> do
          lhs' <- unfoldLazyDeltaCandidate lhsDelta
          pure (mkLazyDeltaStepResult lhs rhs lhs' rhs)
        GT -> do
          rhs' <- unfoldLazyDeltaCandidate rhsDelta
          pure (mkLazyDeltaStepResult lhs rhs lhs rhs')
        EQ -> do
          sameHeadEq <- trySameHeadRegularPrecheck compareArgs lhs rhs lhsDelta rhsDelta
          if sameHeadEq
            then pure LazyDeltaStepResult {lazyDeltaStepChoice = LazyDeltaSameHeadEq, lazyDeltaStepLhs = lhs, lazyDeltaStepRhs = rhs}
            else do
              lhs' <- unfoldLazyDeltaCandidate lhsDelta
              rhs' <- unfoldLazyDeltaCandidate rhsDelta
              pure (mkLazyDeltaStepResult lhs rhs lhs' rhs')

lookupLazyDeltaCandidate :: HCExpr -> KernelM (Maybe LazyDeltaCandidate)
lookupLazyDeltaCandidate expr =
  case viewConstApp expr of
    Nothing -> pure Nothing
    Just constView -> do
      constInfo <- lookupConstInfo (constAppName constView)
      pure $ do
        DefnInfo defn <- constInfo
        pure
          LazyDeltaCandidate
            { lazyDeltaCandidateExpr = expr,
              lazyDeltaCandidateView = constView,
              lazyDeltaCandidateDefn = defn
            }

lazyDeltaCandidateHints :: LazyDeltaCandidate -> ReducibilityHints
lazyDeltaCandidateHints = defHints . lazyDeltaCandidateDefn

lazyDeltaCandidateName :: LazyDeltaCandidate -> HCName
lazyDeltaCandidateName = constName . defConst . lazyDeltaCandidateDefn

unfoldLazyDeltaCandidate :: LazyDeltaCandidate -> KernelM HCExpr
unfoldLazyDeltaCandidate candidate = do
  alreadyUnfolding <- isConstOnUnfoldStack (lazyDeltaCandidateName candidate)
  if alreadyUnfolding
    then pure (lazyDeltaCandidateExpr candidate)
    else do
      (_, unfolded) <- withUnfoldingConst (lazyDeltaCandidateName candidate) $ do
        let defn = lazyDeltaCandidateDefn candidate
            constView = lazyDeltaCandidateView candidate
            levelSubst = zip (constLevelParameters (defConst defn)) (constAppLevels constView)
        body <- instantiateLevelParamsExpr levelSubst (defValue defn)
        applied <- mkApps body (constAppArgs constView)
        whnf applied
      pure unfolded

trySameHeadRegularPrecheck :: (HCExpr -> HCExpr -> KernelM Bool) -> HCExpr -> HCExpr -> LazyDeltaCandidate -> LazyDeltaCandidate -> KernelM Bool
trySameHeadRegularPrecheck compareArgs lhs rhs lhsDelta rhsDelta
  | not (sameRegularHead lhsDelta rhsDelta) = pure False
  | otherwise = do
      failedBefore <- isFailedExprPair lhs rhs
      if failedBefore
        then pure False
        else do
          let lhsView = lazyDeltaCandidateView lhsDelta
              rhsView = lazyDeltaCandidateView rhsDelta
          levelsEq <- compareLevelArgs (constAppLevels lhsView) (constAppLevels rhsView)
          argsEq <-
            if levelsEq
              then compareExprArgs compareArgs (constAppArgs lhsView) (constAppArgs rhsView)
              else pure False
          if levelsEq && argsEq
            then pure True
            else do
              recordFailedExprPair lhs rhs
              pure False

sameRegularHead :: LazyDeltaCandidate -> LazyDeltaCandidate -> Bool
sameRegularHead lhs rhs =
  case (lazyDeltaCandidateHints lhs, lazyDeltaCandidateHints rhs) of
    (Regular _, Regular _) -> constAppName (lazyDeltaCandidateView lhs) == constAppName (lazyDeltaCandidateView rhs)
    _ -> False

compareLevelArgs :: [HCLevel] -> [HCLevel] -> KernelM Bool
compareLevelArgs [] [] = pure True
compareLevelArgs (lhs : lhsRest) (rhs : rhsRest)
  | levelEquiv lhs rhs = compareLevelArgs lhsRest rhsRest
  | otherwise = pure False
compareLevelArgs _ _ = pure False

compareExprArgs :: (HCExpr -> HCExpr -> KernelM Bool) -> [HCExpr] -> [HCExpr] -> KernelM Bool
compareExprArgs _ [] [] = pure True
compareExprArgs compareArgs (lhs : lhsRest) (rhs : rhsRest) = do
  headsEq <- compareArgs lhs rhs
  if headsEq
    then compareExprArgs compareArgs lhsRest rhsRest
    else pure False
compareExprArgs _ _ _ = pure False

mkLazyDeltaStepResult :: HCExpr -> HCExpr -> HCExpr -> HCExpr -> LazyDeltaStepResult
mkLazyDeltaStepResult lhs rhs lhs' rhs' =
  LazyDeltaStepResult
    { lazyDeltaStepChoice =
        case (lhs' /= lhs, rhs' /= rhs) of
          (False, False) -> LazyDeltaNone
          (True, False) -> LazyDeltaUnfoldLhs
          (False, True) -> LazyDeltaUnfoldRhs
          (True, True) -> LazyDeltaUnfoldBoth,
      lazyDeltaStepLhs = lhs',
      lazyDeltaStepRhs = rhs'
    }

whnf :: HCExpr -> KernelM HCExpr
whnf expr =
  case hceVal expr of
    BVar _ -> pure expr
    FVar _ -> pure expr
    Sort _ -> pure expr
    Const _ _ -> pure expr
    Lam _ _ _ _ -> pure expr
    ForallE _ _ _ _ -> pure expr
    Lit _ -> pure expr
    App _ _ -> whnfLoop expr
    Let _ _ _ _ -> whnfLoop expr
    Proj _ _ _ -> whnfLoop expr

inferExpr :: HCExpr -> KernelM HCExpr
inferExpr expr =
  case hceVal expr of
    BVar idx -> inferLooseBVar idx
    FVar fvarId -> inferFVar fvarId
    Sort level -> mkSort =<< mkLevelSucc level
    Const name levels -> inferConst name levels
    App fn arg -> inferApp fn arg
    Lam name ty body binderInfo -> inferLam name ty body binderInfo
    ForallE name ty body binderInfo -> inferForall name ty body binderInfo
    Lit literal -> inferLiteral literal
    Let name ty value body -> inferLet name ty value body
    Proj typeName idx struct -> inferProj typeName idx struct

checkExprHasType :: Expr' HCExpr HCLevel HCName -> Expr' HCExpr HCLevel HCName -> KernelM ()
checkExprHasType expr expectedType = do
  exprRoot <- internExprPayload expr
  expectedTypeRoot <- internExprPayload expectedType
  checkExprHasTypeRoot exprRoot expectedTypeRoot

checkExprHasTypeRoot :: HCExpr -> HCExpr -> KernelM ()
checkExprHasTypeRoot exprRoot expectedTypeRoot = do
  inferredType <- inferExpr exprRoot
  ok <- isDefEq inferredType expectedTypeRoot
  if ok
    then pure ()
    else
      throwError
        ( "type mismatch: expected "
            <> toString expectedTypeRoot
            <> " but inferred "
            <> toString inferredType
            <> " for "
            <> toString exprRoot
        )

checkAndAddDecl :: KernelEnv -> InternState -> Decl HCExpr HCLevel -> Either KernelError (KernelEnv, InternState)
checkAndAddDecl env internState decl =
  case decl of
    InductiveBlockDecl indDecl -> do
      let blockInfos = inductiveBlockInfos indDecl
      predeclaredEnv <- insertConstantInfos blockInfos env
      st <- execKernelM predeclaredEnv internState (checkInductiveBlockDecl indDecl)
      env' <- insertConstantInfos blockInfos env
      pure (env', checkInternState st)
    CtorDecl ctor ->
      Left ("standalone constructor checking is not supported yet: " <> toString (constName (ctorConst ctor)))
    RecDecl recVal ->
      Left ("standalone recursor checking is not supported yet: " <> toString (constName (recConst recVal)))
    _ -> do
      st <- execKernelM env internState (checkTopLevelDecl decl)
      env' <- insertConstantInfos (declInfos decl) env
      pure (env', checkInternState st)

checkAndAddDecls :: KernelEnv -> InternState -> [Decl HCExpr HCLevel] -> Either KernelError (KernelEnv, InternState)
checkAndAddDecls env internState decls = foldlM step (env, internState) decls
  where
    step (env', internState') decl = checkAndAddDecl env' internState' decl

isDefEq :: HCExpr -> HCExpr -> KernelM Bool
isDefEq lhs rhs = do
  quickResult <- isDefEqQuick lhs rhs
  case quickResult of
    Just result -> finalizeDefEqResult lhs rhs result
    Nothing -> do
      failedBefore <- isFailedExprPair lhs rhs
      if failedBefore
        then pure False
        else do
          alreadyVisited <- isVisitedExprPair lhs rhs
          if alreadyVisited
            then pure False
            else do
              (_, result) <- withVisitedExprPair lhs rhs (isDefEqStaged lhs rhs)
              finalizeDefEqResult lhs rhs result

isDefEqQuick :: HCExpr -> HCExpr -> KernelM (Maybe Bool)
isDefEqQuick lhs rhs
  | lhs == rhs = pure (Just True)
  | otherwise = do
      sameClass <- sameExprClass lhs rhs
      if sameClass
        then pure (Just True)
        else case (hceVal lhs, hceVal rhs) of
          (BVar lhsIdx, BVar rhsIdx) -> pure (Just (lhsIdx == rhsIdx))
          (FVar lhsId, FVar rhsId) -> pure (Just (lhsId == rhsId))
          (Sort lhsLevel, Sort rhsLevel) -> pure (Just (levelEquiv lhsLevel rhsLevel))
          (Const lhsName lhsLevels, Const rhsName rhsLevels)
            | lhsName == rhsName -> Just <$> compareLevelArgs lhsLevels rhsLevels
          (Lit lhsLit, Lit rhsLit) -> pure (Just (lhsLit == rhsLit))
          _ -> pure Nothing

isDefEqStaged :: HCExpr -> HCExpr -> KernelM Bool
isDefEqStaged lhs rhs = do
  lhsWhnf <- whnf lhs
  rhsWhnf <- whnf rhs
  if lhsWhnf /= lhs || rhsWhnf /= rhs
    then isDefEq lhsWhnf rhsWhnf
    else do
      sameHeadConstResult <- isDefEqSameHeadConstApps lhsWhnf rhsWhnf
      case sameHeadConstResult of
        Just result -> pure result
        Nothing -> do
          deltaStep <- lazyDeltaReductionStep isDefEq lhsWhnf rhsWhnf
          case lazyDeltaStepChoice deltaStep of
            LazyDeltaSameHeadEq -> pure True
            LazyDeltaNone -> isDefEqStructural lhsWhnf rhsWhnf
            _ -> isDefEq (lazyDeltaStepLhs deltaStep) (lazyDeltaStepRhs deltaStep)

isDefEqSameHeadConstApps :: HCExpr -> HCExpr -> KernelM (Maybe Bool)
isDefEqSameHeadConstApps lhs rhs =
  case (viewConstApp lhs, viewConstApp rhs) of
    (Just lhsConstApp, Just rhsConstApp)
      | constAppName lhsConstApp == constAppName rhsConstApp -> do
          let lhsArgs = constAppArgs lhsConstApp
              rhsArgs = constAppArgs rhsConstApp
          unfoldable <- constIsDeltaUnfoldable (constAppName lhsConstApp)
          levelsEq <- compareLevelArgs (constAppLevels lhsConstApp) (constAppLevels rhsConstApp)
          if not levelsEq
            then pure (sameHeadConstMismatch unfoldable)
            else
              if length lhsArgs /= length rhsArgs
                then pure (sameHeadConstMismatch unfoldable)
                else do
                  argsEq <- compareExprArgs isDefEq lhsArgs rhsArgs
                  pure $
                    if argsEq
                      then Just True
                      else sameHeadConstMismatch unfoldable
    _ -> pure Nothing
  where
    sameHeadConstMismatch unfoldable
      | unfoldable = Nothing
      | otherwise = Just False

isDefEqStructural :: HCExpr -> HCExpr -> KernelM Bool
isDefEqStructural lhs rhs =
  case (viewProj lhs, viewProj rhs) of
    (Just lhsProj, Just rhsProj)
      | projViewTypeName lhsProj == projViewTypeName rhsProj,
        projViewIndex lhsProj == projViewIndex rhsProj ->
          isDefEq (projViewStruct lhsProj) (projViewStruct rhsProj)
    _ ->
      case (viewLam lhs, viewLam rhs) of
        (Just lhsLam, Just rhsLam) -> isDefEqBinderViews lhsLam rhsLam
        _ ->
          case (viewForall lhs, viewForall rhs) of
            (Just lhsForall, Just rhsForall) -> isDefEqBinderViews lhsForall rhsForall
            _ -> isDefEqApp lhs rhs

isDefEqBinderViews :: BinderView -> BinderView -> KernelM Bool
isDefEqBinderViews lhsBinder rhsBinder = do
  typesEq <- isDefEq (binderViewType lhsBinder) (binderViewType rhsBinder)
  if not typesEq
    then pure False
    else withLocalDecl (rawNameFromHCName (binderViewName lhsBinder)) (binderViewType lhsBinder) (binderViewInfo lhsBinder) $ \decl -> do
      localExpr <- localDeclExpr decl
      lhsBody <- openBinderView lhsBinder localExpr
      rhsBody <- openBinderView rhsBinder localExpr
      isDefEq lhsBody rhsBody

isDefEqApp :: HCExpr -> HCExpr -> KernelM Bool
isDefEqApp lhs rhs =
  case (hceVal lhs, hceVal rhs) of
    (App _ _, App _ _) -> do
      let lhsSpine = getAppSpine lhs
          rhsSpine = getAppSpine rhs
      if length (appSpineArgs lhsSpine) /= length (appSpineArgs rhsSpine)
        then pure False
        else do
          argsEq <- compareExprArgs isDefEq (appSpineArgs lhsSpine) (appSpineArgs rhsSpine)
          if argsEq
            then isDefEq (appSpineFn lhsSpine) (appSpineFn rhsSpine)
            else pure False
    _ -> pure False

finalizeDefEqResult :: HCExpr -> HCExpr -> Bool -> KernelM Bool
finalizeDefEqResult lhs rhs result =
  if result
    then do
      _ <- unionExprClasses lhs rhs
      clearFailedExprPair lhs rhs
      pure True
    else do
      recordFailedExprPair lhs rhs
      pure False

rawNameFromHCName :: HCName -> Name
rawNameFromHCName name =
  Name $ case hcnVal name of
    Anonymous -> Anonymous
    Str prefix segment -> Str (rawNameFromHCName prefix) segment
    Num prefix value -> Num (rawNameFromHCName prefix) value

rawNameFromSegments :: [String] -> Name
rawNameFromSegments = foldl step (Name Anonymous)
  where
    step prefix segment = Name (Str prefix (Text.pack segment))

checkTopLevelDecl :: Decl HCExpr HCLevel -> KernelM ()
checkTopLevelDecl decl =
  case decl of
    AxiomDecl ax -> checkConstantType "axiom" (constName ax) (constType ax)
    DefnDecl defn -> do
      checkConstantType "definition" (constName (defConst defn)) (constType (defConst defn))
      checkExprHasType (defValue defn) (constType (defConst defn))
    ThmDecl thm -> do
      checkConstantType "theorem" (constName (thmConst thm)) (constType (thmConst thm))
      checkExprHasType (thmValue thm) (constType (thmConst thm))
    OpaqueDecl opaqueVal -> do
      checkConstantType "opaque" (constName (opaqueConst opaqueVal)) (constType (opaqueConst opaqueVal))
      checkExprHasType (opaqueValue opaqueVal) (constType (opaqueConst opaqueVal))
    QuotDecl quotVal ->
      checkConstantType ("quot " <> toString (quotKind quotVal)) (constName (quotConst quotVal)) (constType (quotConst quotVal))
    CtorDecl ctor -> throwError ("standalone constructor checking is not supported yet: " <> toString (constName (ctorConst ctor)))
    RecDecl recVal -> throwError ("standalone recursor checking is not supported yet: " <> toString (constName (recConst recVal)))
    InductiveBlockDecl indDecl -> checkInductiveBlockDecl indDecl

checkInductiveBlockDecl :: InductiveDecl HCExpr HCLevel -> KernelM ()
checkInductiveBlockDecl indDecl = do
  mapM_ checkInductiveType (indTypes indDecl)
  mapM_ checkInductiveConstructor (indConstructors indDecl)
  mapM_ checkInductiveRecursor (indRecursors indDecl)

checkInductiveType :: InductiveVal HCExpr HCLevel -> KernelM ()
checkInductiveType indVal =
  checkConstantType "inductive" (constName (indConst indVal)) (constType (indConst indVal))

checkInductiveConstructor :: ConstructorVal HCExpr HCLevel -> KernelM ()
checkInductiveConstructor ctor =
  checkConstantType "constructor" (constName (ctorConst ctor)) (constType (ctorConst ctor))

checkInductiveRecursor :: RecursorVal HCExpr HCLevel -> KernelM ()
checkInductiveRecursor recVal =
  checkConstantType "recursor" (constName (recConst recVal)) (constType (recConst recVal))

checkConstantType :: String -> HCName -> Expr' HCExpr HCLevel HCName -> KernelM ()
checkConstantType label name ty = do
  tyExpr <- internExprPayload ty
  tyType <- inferExpr tyExpr
  _ <- ensureSort (label <> " type for " <> toString name) tyType
  pure ()

internExprPayload :: Expr' HCExpr HCLevel HCName -> KernelM HCExpr
internExprPayload = withIntern . internExprVal

ensureSort :: String -> HCExpr -> KernelM HCLevel
ensureSort label expr = do
  exprWhnf <- whnf expr
  case hceVal exprWhnf of
    Sort level -> pure level
    _ -> do
      maybeCandidate <- lookupLazyDeltaCandidate exprWhnf
      case maybeCandidate of
        Just candidate -> do
          unfolded <- unfoldLazyDeltaCandidate candidate
          if unfolded == exprWhnf
            then throwError (label <> " is not a sort: " <> toString exprWhnf)
            else ensureSort label unfolded
        Nothing -> throwError (label <> " is not a sort: " <> toString exprWhnf)

ensureForallType :: String -> HCExpr -> KernelM BinderView
ensureForallType label expr = do
  exprWhnf <- whnf expr
  case viewForall exprWhnf of
    Just binderView -> pure binderView
    Nothing -> do
      maybeCandidate <- lookupLazyDeltaCandidate exprWhnf
      case maybeCandidate of
        Just candidate -> do
          unfolded <- unfoldLazyDeltaCandidate candidate
          if unfolded == exprWhnf
            then throwError (label <> " is not a forall: " <> toString exprWhnf)
            else ensureForallType label unfolded
        Nothing -> throwError (label <> " is not a forall: " <> toString exprWhnf)

inferLooseBVar :: Int -> KernelM HCExpr
inferLooseBVar idx = do
  locals <- getLocalCtx
  case drop idx locals of
    decl : _ -> pure (localType decl)
    [] -> throwError ("unbound de Bruijn index: " <> show idx)

inferFVar :: FVarId HCName -> KernelM HCExpr
inferFVar fvarId = do
  maybeDecl <- lookupLocalDecl fvarId
  case maybeDecl of
    Just decl -> pure (localType decl)
    Nothing -> throwError ("unknown local free variable: " <> toString (case fvarId of FVarId name -> name))

inferConst :: HCName -> [HCLevel] -> KernelM HCExpr
inferConst name levels = do
  maybeInfo <- lookupConstInfo name
  case maybeInfo of
    Just constantInfo -> instantiateConstType (constantInfoConst constantInfo) levels
    Nothing -> throwError ("unknown constant: " <> toString name)

inferProj :: HCName -> Int -> HCExpr -> KernelM HCExpr
inferProj typeName fieldIdx struct = do
  structType <- inferExpr struct
  structTypeView <- ensureConstAppType ("projection struct type for " <> toString typeName) typeName structType
  indMeta <- lookupValidatedInductiveMeta typeName
  ctorMeta <- lookupProjectionConstructorInfo typeName indMeta
  let ctorInfo = validatedConstructorInfo ctorMeta
  if fieldIdx < 0 || fieldIdx >= ctorFieldsN ctorInfo
    then throwError ("projection index out of bounds for " <> toString typeName <> ": " <> show fieldIdx)
    else do
      ctorType0 <- instantiateConstType (ctorConst ctorInfo) (constAppLevels structTypeView)
      let paramArgs = take (ctorParamsN ctorInfo) (constAppArgs structTypeView)
      if length paramArgs /= ctorParamsN ctorInfo
        then throwError ("projection struct type has too few parameters for " <> toString typeName)
        else do
          previousFields <- traverse (\idx -> mkProj typeName idx struct) [0 .. fieldIdx - 1]
          projectFieldType (toString typeName) ctorType0 (paramArgs <> previousFields)

lookupProjectionConstructorInfo :: HCName -> ValidatedInductiveMeta -> KernelM ValidatedConstructorMeta
lookupProjectionConstructorInfo typeName indMeta =
  case validatedInductiveConstructors indMeta of
    [ctorMeta] -> pure ctorMeta
    _ -> throwError ("projection inference requires exactly one constructor for " <> toString typeName)

ensureConstAppType :: String -> HCName -> HCExpr -> KernelM ConstAppView
ensureConstAppType label expectedName expr = do
  exprWhnf <- whnf expr
  case viewConstApp exprWhnf of
    Just constAppView
      | constAppName constAppView == expectedName -> pure constAppView
    _ -> do
      maybeCandidate <- lookupLazyDeltaCandidate exprWhnf
      case maybeCandidate of
        Just candidate -> do
          unfolded <- unfoldLazyDeltaCandidate candidate
          if unfolded == exprWhnf
            then throwError (label <> " is not a " <> toString expectedName <> " application: " <> toString exprWhnf)
            else ensureConstAppType label expectedName unfolded
        Nothing -> throwError (label <> " is not a " <> toString expectedName <> " application: " <> toString exprWhnf)

projectFieldType :: String -> HCExpr -> [HCExpr] -> KernelM HCExpr
projectFieldType label ctorType appliedArgs = do
  remainingType <- foldlM step ctorType appliedArgs
  binderView <- ensureForallType ("projection field type for " <> label) remainingType
  pure (binderViewType binderView)
  where
    step currentType arg = do
      binderView <- ensureForallType ("constructor telescope for " <> label) currentType
      openBinderView binderView arg

inferApp :: HCExpr -> HCExpr -> KernelM HCExpr
inferApp fn arg = do
  fnType <- inferExpr fn
  binderView <- ensureForallType ("application function type for " <> toString fn) fnType
  checkExprHasTypeRoot arg (binderViewType binderView)
  openBinderView binderView arg

inferLam :: HCName -> HCExpr -> HCExpr -> BinderInfo -> KernelM HCExpr
inferLam name ty body binderInfo = do
  _ <- ensureSort ("lambda binder type for " <> toString name) =<< inferExpr ty
  withLocalDecl (rawNameFromHCName name) ty binderInfo $ \decl -> do
    localExpr <- localDeclExpr decl
    body' <- openBinderView BinderView {binderViewName = name, binderViewType = ty, binderViewBody = body, binderViewInfo = binderInfo} localExpr
    bodyType <- inferExpr body'
    closedBodyType <- abstractFVar (localFVarId decl) bodyType
    mkForall name ty closedBodyType binderInfo

inferForall :: HCName -> HCExpr -> HCExpr -> BinderInfo -> KernelM HCExpr
inferForall name ty body binderInfo = do
  domainSort <- ensureSort ("forall binder type for " <> toString name) =<< inferExpr ty
  withLocalDecl (rawNameFromHCName name) ty binderInfo $ \decl -> do
    localExpr <- localDeclExpr decl
    body' <- openBinderView BinderView {binderViewName = name, binderViewType = ty, binderViewBody = body, binderViewInfo = binderInfo} localExpr
    codomainType <- inferExpr body'
    codomainSort <- ensureSort ("forall codomain for " <> toString name) codomainType
    resultLevel <- mkLevelIMax domainSort codomainSort
    mkSort resultLevel

inferLiteral :: Literal -> KernelM HCExpr
inferLiteral literal = do
  literalTypeName <-
    case literal of
      NatVal _ -> internNameM (rawNameFromSegments ["Nat"])
      StrVal _ -> internNameM (rawNameFromSegments ["String"])
  inferConst literalTypeName []

inferLet :: HCName -> HCExpr -> HCExpr -> HCExpr -> KernelM HCExpr
inferLet name ty value body = do
  _ <- ensureSort ("let binder type for " <> toString name) =<< inferExpr ty
  checkExprHasTypeRoot value ty
  body' <- openLetView LetView {letViewName = name, letViewType = ty, letViewValue = value, letViewBody = body}
  inferExpr body'

declInfos :: Decl HCExpr HCLevel -> [ConstantInfo HCExpr HCLevel]
declInfos decl =
  case decl of
    AxiomDecl ax -> [AxiomInfo ax]
    DefnDecl defn -> [DefnInfo defn]
    ThmDecl thm -> [ThmInfo thm]
    OpaqueDecl opaqueVal -> [OpaqueInfo opaqueVal]
    QuotDecl quotVal -> [QuotInfo quotVal]
    CtorDecl ctor -> [CtorInfo ctor]
    RecDecl recVal -> [RecInfo recVal]
    InductiveBlockDecl indDecl -> inductiveBlockInfos indDecl

inductiveBlockInfos :: InductiveDecl HCExpr HCLevel -> [ConstantInfo HCExpr HCLevel]
inductiveBlockInfos indDecl =
  fmap InductInfo (indTypes indDecl)
    <> fmap CtorInfo (indConstructors indDecl)
    <> fmap RecInfo (indRecursors indDecl)

whnfLoop :: HCExpr -> KernelM HCExpr
whnfLoop expr = do
  step <- whnfStep expr
  case step of
    Nothing -> pure expr
    Just expr'
      | expr' == expr -> pure expr
      | otherwise -> whnf expr'

whnfStep :: HCExpr -> KernelM (Maybe HCExpr)
whnfStep expr =
  case viewLet expr of
    Just letView -> Just <$> openLetView letView
    Nothing ->
      case viewProj expr of
        Just _ -> whnfProjStep expr
        Nothing ->
          case hceVal expr of
            App _ _ -> whnfAppStep expr
            _ -> pure Nothing

whnfAppStep :: HCExpr -> KernelM (Maybe HCExpr)
whnfAppStep expr = do
  let appSpine = getAppSpine expr
      fn = appSpineFn appSpine
      args = appSpineArgs appSpine
  fnWhnf <- whnf fn
  headValue <- exprToValue fnWhnf
  case (headValue, args) of
    (LamValue binderView closure, arg : restArgs) -> do
      reducedHead <- withClosureLocalCtx closure (openBinderView binderView arg)
      Just <$> mkAppSpine AppSpine {appSpineFn = reducedHead, appSpineArgs = restArgs}
    _
      | fnWhnf /= fn ->
          Just <$> mkAppSpine AppSpine {appSpineFn = fnWhnf, appSpineArgs = args}
      | otherwise -> whnfIotaStep expr

whnfProjStep :: HCExpr -> KernelM (Maybe HCExpr)
whnfProjStep expr =
  case viewProj expr of
    Nothing -> pure Nothing
    Just projView -> do
      let originalStruct = projViewStruct projView
      structWhnf <- whnf originalStruct
      let projView' = projView {projViewStruct = structWhnf}
          stuckResult updatedProj =
            if structWhnf == originalStruct
              then pure Nothing
              else pure (Just updatedProj)
      updatedProj <- mkProjFromView projView'
      case viewConstApp structWhnf of
        Just constView -> do
          maybeCtorMeta <- catchError (Just <$> lookupValidatedConstructorMeta (constAppName constView)) (const (pure Nothing))
          case maybeCtorMeta of
            Just ctorMeta
              | ctorInductive (validatedConstructorInfo ctorMeta) == projViewTypeName projView -> do
                  let ctor = validatedConstructorInfo ctorMeta
                      minArgs = ctorParamsN ctor + projViewIndex projView + 1
                      fullCtorArgs = ctorParamsN ctor + ctorFieldsN ctor
                  case viewProjStructConstApp minArgs updatedProj of
                    Just strictView
                      | projViewIndex projView < ctorFieldsN ctor,
                        length (projStructArgs strictView) >= fullCtorArgs ->
                          pure $ Just (projStructArgs strictView !! (ctorParamsN ctor + projViewIndex projView))
                    _ -> stuckResult updatedProj
            _ -> tryUnfoldProjectedStruct updatedProj structWhnf
        Nothing -> tryUnfoldProjectedStruct updatedProj structWhnf

tryUnfoldProjectedStruct :: HCExpr -> HCExpr -> KernelM (Maybe HCExpr)
tryUnfoldProjectedStruct updatedProj structExpr = do
  maybeCandidate <- lookupLazyDeltaCandidate structExpr
  case maybeCandidate of
    Just candidate -> do
      unfoldedStruct <- unfoldLazyDeltaCandidate candidate
      if unfoldedStruct == structExpr
        then pure (Just updatedProj)
        else do
          case viewProj updatedProj of
            Just projView -> do
              updatedProj' <- mkProjFromView projView {projViewStruct = unfoldedStruct}
              pure (Just updatedProj')
            Nothing -> pure (Just updatedProj)
    Nothing -> pure (Just updatedProj)

whnfIotaStep :: HCExpr -> KernelM (Maybe HCExpr)
whnfIotaStep expr =
  case viewConstApp expr of
    Just constAppView -> do
      constInfo <- lookupConstInfo (constAppName constAppView)
      case constInfo of
        Just (RecInfo recVal) -> do
          recMeta <- lookupValidatedRecursorMeta (constName (recConst recVal))
          reduceRecursorApp constAppView recMeta
        _ -> pure Nothing
    Nothing -> pure Nothing

reduceRecursorApp :: ConstAppView -> ValidatedRecursorMeta -> KernelM (Maybe HCExpr)
reduceRecursorApp recAppView recMeta = do
  let recVal = validatedRecursorInfo recMeta
  let recArgs = constAppArgs recAppView
      majorIdx = recursorMajorIndex recVal
  case splitAt majorIdx recArgs of
    (_, []) -> pure Nothing
    (beforeMajor, major : afterMajor) -> do
      majorWhnf <- whnf major
      let recArgs' = beforeMajor <> (majorWhnf : afterMajor)
          majorChanged = majorWhnf /= major
      rebuiltRecApp <- rebuildConstApp (constAppName recAppView) (constAppLevels recAppView) recArgs'
      case findRecursorRule recMeta majorWhnf of
        Just (majorCtorView, ruleMeta)
          | length (constAppLevels recAppView) == length (constLevelParameters (recConst recVal)),
            length (constAppArgs majorCtorView) >= recFieldsN (validatedRecursorRuleInfo ruleMeta) -> do
              reduced <- applyRecursorRule recVal (validatedRecursorRuleInfo ruleMeta) (constAppLevels recAppView) recArgs' majorCtorView
              pure $ Just reduced
        _ ->
          if majorChanged
            then pure (Just rebuiltRecApp)
            else pure Nothing

applyRecursorRule :: RecursorVal HCExpr HCLevel -> RecursorRule HCExpr HCLevel -> [HCLevel] -> [HCExpr] -> ConstAppView -> KernelM HCExpr
applyRecursorRule recVal rule recLvls recArgs majorCtorView = do
  rhs0 <- instantiateLevelParamsExpr (zip (constLevelParameters (recConst recVal)) recLvls) (recRhs rule)
  rhs1 <- mkApps rhs0 (take (recParamsN recVal + recMotivesN recVal + recMinorsN recVal) recArgs)
  let majorArgs = constAppArgs majorCtorView
      nparams = length majorArgs - recFieldsN rule
  rhs2 <- mkApps rhs1 (drop nparams majorArgs)
  mkApps rhs2 (drop (recursorMajorIndex recVal + 1) recArgs)

exprToValue :: HCExpr -> KernelM Value
exprToValue expr =
  case hceVal expr of
    Sort level -> pure (SortValue level)
    ForallE name ty body binderInfo -> do
      closure <- mkClosure body
      pure (ForallValue name ty closure binderInfo)
    _ ->
      case viewLam expr of
        Just binderView -> do
          closure <- mkClosure (binderViewBody binderView)
          pure (LamValue binderView closure)
        Nothing -> pure (NeutralValue expr)

mkClosure :: HCExpr -> KernelM Closure
mkClosure body = do
  localCtx <- getLocalCtx
  pure Closure {closureLocalCtx = localCtx, closureBody = body}

withClosureLocalCtx :: Closure -> KernelM a -> KernelM a
withClosureLocalCtx closure (KernelM action) =
  KernelM $ local (\ctx -> ctx {checkLocalCtx = closureLocalCtx closure}) action

rebuildConstApp :: HCName -> [HCLevel] -> [HCExpr] -> KernelM HCExpr
rebuildConstApp name levels args = do
  fn <- mkConst name levels
  mkApps fn args

recursorMajorIndex :: RecursorVal HCExpr HCLevel -> Int
recursorMajorIndex recVal = recParamsN recVal + recMotivesN recVal + recMinorsN recVal + recIndicesN recVal

findRecursorRule :: ValidatedRecursorMeta -> HCExpr -> Maybe (ConstAppView, ValidatedRecursorRuleMeta)
findRecursorRule recMeta major = do
  majorCtorView <- viewConstApp major
  rule <- IntMap.lookup (hcnId (constAppName majorCtorView)) (validatedRecursorRules recMeta)
  pure (majorCtorView, rule)

withIntern :: State InternState a -> KernelM a
withIntern action = do
  st <- get
  let (result, internState') = runState action (checkInternState st)
  put st {checkInternState = internState'}
  pure result

withExprUnionFind :: State UnionFind a -> KernelM a
withExprUnionFind action = do
  st <- get
  let (result, unionFind') = runState action (checkExprUnionFind st)
  put st {checkExprUnionFind = unionFind'}
  pure result

withNbEState :: State NbEState a -> KernelM a
withNbEState action = do
  st <- get
  let (result, nbeState') = runState action (checkNbEState st)
  put st {checkNbEState = nbeState'}
  pure result

withVisitedExprPairs :: State (Set.Set ExprPair) a -> KernelM a
withVisitedExprPairs action = do
  st <- get
  let (result, visitedPairs') = runState action (checkVisitedExprPairs st)
  put st {checkVisitedExprPairs = visitedPairs'}
  pure result

withFailedExprPairs :: State (Set.Set ExprPair) a -> KernelM a
withFailedExprPairs action = do
  st <- get
  let (result, failedPairs') = runState action (checkFailedExprPairs st)
  put st {checkFailedExprPairs = failedPairs'}
  pure result

withUnfoldStackState :: State [HCName] a -> KernelM a
withUnfoldStackState action = do
  st <- get
  let (result, unfoldStack') = runState action (checkUnfoldStack st)
  put st {checkUnfoldStack = unfoldStack'}
  pure result

freshLocalFVarId :: HCName -> KernelM (FVarId HCName)
freshLocalFVarId displayName = do
  nextId <- gets checkNextLocalId
  modify $ \st -> st {checkNextLocalId = nextId + 1}
  pure $ FVarId (HCName nextId (hcnVal displayName))

withExtendedLocalCtx :: LocalDecl -> KernelM a -> KernelM a
withExtendedLocalCtx decl (KernelM action) =
  KernelM $ local extendCtx action
  where
    extendCtx ctx = ctx {checkLocalCtx = decl : checkLocalCtx ctx}

kernelStateWithInternState :: InternState -> KernelState
kernelStateWithInternState internState =
  emptyKernelState
    { checkInternState = internState
    }

mkExprPair :: HCExpr -> HCExpr -> ExprPair
mkExprPair lhs rhs
  | lhsId <= rhsId = ExprPair lhsId rhsId
  | otherwise = ExprPair rhsId lhsId
  where
    lhsId = hceId lhs
    rhsId = hceId rhs

validateKernelBootstrap :: KernelEnv -> InternState -> Either KernelError ValidatedKernelMetadata
validateKernelBootstrap env internState =
  mapM_ (uncurry validateEnvEntry) (IntMap.toList env) >> buildValidatedKernelMetadata env
  where
    validateEnvEntry key constantInfo = do
      let constantName = constantInfoName constantInfo
      if key == hcnId constantName
        then pure ()
        else throwBootstrapError ("env key " <> show key <> " does not match constant id " <> show (hcnId constantName))
      validateConstantInfo constantInfo

    validateConstantInfo constantInfo =
      case constantInfo of
        AxiomInfo ax -> validateConstantVal "axiom" ax
        DefnInfo defn -> do
          validateConstantVal "definition" (defConst defn)
          validateExprPayload "definition value" (defValue defn)
        ThmInfo thm -> do
          validateConstantVal "theorem" (thmConst thm)
          validateExprPayload "theorem value" (thmValue thm)
        OpaqueInfo opaqueVal -> do
          validateConstantVal "opaque" (opaqueConst opaqueVal)
          validateExprPayload "opaque value" (opaqueValue opaqueVal)
        QuotInfo quotVal -> validateConstantVal "quot" (quotConst quotVal)
        InductInfo indVal -> do
          validateConstantVal "inductive" (indConst indVal)
          mapM_ (validateName "inductive constructor") (indCtors indVal)
        CtorInfo ctor -> do
          validateConstantVal "constructor" (ctorConst ctor)
          validateName "constructor inductive" (ctorInductive ctor)
        RecInfo recVal -> do
          validateConstantVal "recursor" (recConst recVal)
          mapM_ validateRecursorRule (recRules recVal)

    validateRecursorRule rule = do
      validateName "recursor rule constructor" (recCtor rule)
      validateExprPayload "recursor rule rhs" (recRhs rule)

    validateConstantVal label constantVal = do
      validateName (label <> " constant name") (constName constantVal)
      mapM_ (validateName (label <> " level parameter")) (constLevelParameters constantVal)
      validateExprPayload (label <> " constant type") (constType constantVal)

    validateName label name = do
      stored <-
        maybe
          (throwBootstrapError (label <> " missing canonical name id " <> show (hcnId name)))
          pure
          (lookupNameId (hcnId name) internState)
      if hcnVal stored == hcnVal name
        then case hcnVal name of
          Anonymous -> pure ()
          Str prefix _ -> validateName (label <> " prefix") prefix
          Num prefix _ -> validateName (label <> " prefix") prefix
        else throwBootstrapError (label <> " payload mismatch at name id " <> show (hcnId name))

    validateLevel label level = do
      stored <-
        maybe
          (throwBootstrapError (label <> " missing canonical level id " <> show (hclId level)))
          pure
          (lookupLevelId (hclId level) internState)
      if hclVal stored == hclVal level
        then case hclVal level of
          LZero -> pure ()
          LSucc inner -> validateLevel (label <> " succ") inner
          LMax lhs rhs -> do
            validateLevel (label <> " max lhs") lhs
            validateLevel (label <> " max rhs") rhs
          LIMax lhs rhs -> do
            validateLevel (label <> " imax lhs") lhs
            validateLevel (label <> " imax rhs") rhs
          LVar name -> validateName (label <> " parameter") name
        else throwBootstrapError (label <> " payload mismatch at level id " <> show (hclId level))

    validateExpr label expr = do
      stored <-
        maybe
          (throwBootstrapError (label <> " missing canonical expr id " <> show (hceId expr)))
          pure
          (lookupExprId (hceId expr) internState)
      if hceVal stored == hceVal expr
        then validateExprPayload label (hceVal expr)
        else throwBootstrapError (label <> " payload mismatch at expr id " <> show (hceId expr))

    validateExprPayload label expr =
      case expr of
        BVar _ -> pure ()
        FVar (FVarId name) -> validateName (label <> " free variable") name
        Sort level -> validateLevel (label <> " sort level") level
        Const name levels -> do
          validateName (label <> " constant") name
          mapM_ (validateLevel (label <> " universe argument")) levels
        App fn arg -> do
          validateExpr (label <> " app fn") fn
          validateExpr (label <> " app arg") arg
        Lam name ty body _ -> do
          validateName (label <> " lambda binder") name
          validateExpr (label <> " lambda type") ty
          validateExpr (label <> " lambda body") body
        ForallE name ty body _ -> do
          validateName (label <> " forall binder") name
          validateExpr (label <> " forall type") ty
          validateExpr (label <> " forall body") body
        Lit _ -> pure ()
        Let name ty value body -> do
          validateName (label <> " let binder") name
          validateExpr (label <> " let type") ty
          validateExpr (label <> " let value") value
          validateExpr (label <> " let body") body
        Proj name _ struct -> do
          validateName (label <> " projection type") name
          validateExpr (label <> " projection struct") struct

    constantInfoName constantInfo =
      case constantInfo of
        AxiomInfo ax -> constName ax
        DefnInfo defn -> constName (defConst defn)
        ThmInfo thm -> constName (thmConst thm)
        OpaqueInfo opaqueVal -> constName (opaqueConst opaqueVal)
        QuotInfo quotVal -> constName (quotConst quotVal)
        InductInfo indVal -> constName (indConst indVal)
        CtorInfo ctor -> constName (ctorConst ctor)
        RecInfo recVal -> constName (recConst recVal)

    throwBootstrapError message = Left ("kernel bootstrap interner mismatch: " <> message)

buildValidatedKernelMetadata :: KernelEnv -> Either KernelError ValidatedKernelMetadata
buildValidatedKernelMetadata env = do
  validatedInds <- traverse validateInductiveMeta indsById
  validatedRecs <- traverse (validateRecursorMeta validatedInds) recsById
  pure
    ValidatedKernelMetadata
      { validatedInductives = validatedInds,
        validatedConstructors = validatedCtors,
        validatedRecursors = validatedRecs
      }
  where
    indsById = IntMap.fromList [(hcnId (constName (indConst indVal)), indVal) | InductInfo indVal <- IntMap.elems env]
    ctorsById = IntMap.fromList [(hcnId (constName (ctorConst ctorVal)), ctorVal) | CtorInfo ctorVal <- IntMap.elems env]
    recsById = IntMap.fromList [(hcnId (constName (recConst recVal)), recVal) | RecInfo recVal <- IntMap.elems env]

    validatedCtors = fmap ValidatedConstructorMeta ctorsById

    validateInductiveMeta indVal = do
      validatedCtorMetas <- traverse validateCtorForInductive (indCtors indVal)
      pure
        ValidatedInductiveMeta
          { validatedInductiveInfo = indVal,
            validatedInductiveConstructors = validatedCtorMetas
          }
      where
        indName = constName (indConst indVal)
        validateCtorForInductive ctorName = do
          ctorVal <-
            maybe
              (Left ("inductive metadata validation failed for " <> toString indName <> ": missing constructor " <> toString ctorName))
              pure
              (IntMap.lookup (hcnId ctorName) ctorsById)
          if ctorInductive ctorVal /= indName
            then Left ("inductive metadata validation failed for " <> toString indName <> ": constructor " <> toString ctorName <> " belongs to " <> toString (ctorInductive ctorVal))
            else pure (ValidatedConstructorMeta ctorVal)

    validateRecursorMeta validatedInds recVal = do
      firstRule <-
        case recRules recVal of
          rule : _ -> pure rule
          [] -> Left ("recursor metadata validation failed for " <> toString (constName (recConst recVal)) <> ": missing rules")
      firstCtor <- lookupValidatedRuleConstructor recVal firstRule
      indMeta <-
        maybe
          (Left ("recursor metadata validation failed for " <> toString (constName (recConst recVal)) <> ": missing inductive " <> toString (ctorInductive (validatedConstructorInfo firstCtor))))
          pure
          (IntMap.lookup (hcnId (ctorInductive (validatedConstructorInfo firstCtor))) validatedInds)
      ruleMetas <- traverse (validateRecursorRuleMeta recVal indMeta) (recRules recVal)
      let ruleMap = IntMap.fromList [(hcnId (recCtor (validatedRecursorRuleInfo ruleMeta)), ruleMeta) | ruleMeta <- ruleMetas]
          expectedCtorIds = fmap (hcnId . constName . ctorConst . validatedConstructorInfo) (validatedInductiveConstructors indMeta)
          actualCtorIds = IntMap.keys ruleMap
      if length ruleMetas /= length ruleMap
        then Left ("recursor metadata validation failed for " <> toString (constName (recConst recVal)) <> ": duplicate constructor rules")
        else
          if Set.fromList actualCtorIds /= Set.fromList expectedCtorIds
            then Left ("recursor metadata validation failed for " <> toString (constName (recConst recVal)) <> ": constructor coverage does not match admitted inductive block")
            else
              pure
                ValidatedRecursorMeta
                  { validatedRecursorInfo = recVal,
                    validatedRecursorInductive = indMeta,
                    validatedRecursorRules = ruleMap
                  }

    validateRecursorRuleMeta recVal indMeta rule = do
      ctorMeta <- lookupValidatedRuleConstructor recVal rule
      let ctorInfo = validatedConstructorInfo ctorMeta
          indName = constName (indConst (validatedInductiveInfo indMeta))
      if ctorInductive ctorInfo /= indName
        then Left ("recursor metadata validation failed for " <> toString (constName (recConst recVal)) <> ": rule constructor " <> toString (recCtor rule) <> " is outside admitted inductive block")
        else
          if recFieldsN rule /= ctorFieldsN ctorInfo
            then Left ("recursor metadata validation failed for " <> toString (constName (recConst recVal)) <> ": rule field count for " <> toString (recCtor rule) <> " does not match constructor field count")
            else pure ValidatedRecursorRuleMeta {validatedRecursorRuleInfo = rule, validatedRecursorRuleConstructor = ctorMeta}

    lookupValidatedRuleConstructor recVal rule = do
      ctorVal <-
        maybe
          (Left ("recursor metadata validation failed for " <> toString (constName (recConst recVal)) <> ": unknown constructor " <> toString (recCtor rule)))
          pure
          (IntMap.lookup (hcnId (recCtor rule)) ctorsById)
      pure (ValidatedConstructorMeta ctorVal)
