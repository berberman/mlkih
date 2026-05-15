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
  { checkLocalCtx :: !LocalCtx,
    checkTraceConfig :: !TraceConfig
  }

data KernelState = KernelState
  { checkEnv :: !KernelEnv,
    checkMetadata :: !ValidatedKernelMetadata,
    checkInternState :: !InternState,
    checkVisited :: ![(HCId, HCId)],
    checkFailed :: ![(HCId, HCId)],
    checkTraceStack :: ![[TraceNode]]
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

emptyKernelState :: KernelEnv -> KernelState
emptyKernelState env =
  KernelState
    { checkEnv = env,
      checkMetadata = ValidatedKernelMetadata IntMap.empty IntMap.empty,
      checkInternState = emptyInternState,
      checkVisited = [],
      checkFailed = [],
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

--------------------------------------------------------------------------------

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

type TraceField = (String, TraceFieldValue)

data TraceFieldValue
  = TrString String
  | TrDoc Doc
  | TrInt Int
  | TrBool Bool
  | TrName HCName
  | TrLevel HCLevel
  | TrExpr HCExpr
  | TrValue Value
  | TrValueHead Value
  | TrHead Head
  | TrElim Elim
  | TrSpine Spine
  | TrSpineLen Spine

data TraceConfig = TraceConfig
  { traceVerbosity :: !TraceVerbosity,
    tracePhases :: !(Maybe [TracePhase]),
    traceKinds :: !(Maybe [TraceKind]),
    traceOutcomes :: !(Maybe [TraceOutcome]),
    traceConstants :: !(Maybe [HCName])
  }

defaultTraceConfig :: TraceConfig
defaultTraceConfig =
  TraceConfig
    { traceVerbosity = TraceOff,
      tracePhases = Nothing,
      traceKinds = Nothing,
      traceOutcomes = Nothing,
      traceConstants = Nothing
    }

maxTraceConfig :: TraceConfig
maxTraceConfig =
  TraceConfig
    { traceVerbosity = TraceDump,
      tracePhases = Nothing,
      traceKinds = Nothing,
      traceOutcomes = Nothing,
      traceConstants = Nothing
    }

data TraceNode
  = TraceLeaf TraceEvent
  | TraceBlock TraceEvent [TraceNode]

data TraceEvent = TraceEvent
  { tracePhase :: !TracePhase,
    traceKind :: !TraceKind,
    traceEventVerbosity :: !TraceVerbosity,
    traceOutcome :: !(Maybe TraceOutcome),
    traceLabel :: !String,
    traceFields :: ![TraceField]
  }

data TracePhase
  = PhDecl
  | PhInfer
  | PhEval
  | PhDefEq
  | PhReduce
  | PhQuote
  | PhEta
  | PhLookup
  | PhLocalCtx
  | PhMisc
  deriving (Eq, Ord, Show)

data TraceKind
  = TkEnter
  | TkEvent
  | TkDecision
  | TkSuccess
  | TkFailure
  | TkStuck
  | TkFallback
  | TkReduction
  | TkCompare
  | TkLookup
  | TkSpine
  | TkUnfold
  | TkForce
  | TkError
  deriving (Eq, Ord, Show)

data TraceVerbosity
  = TraceOff
  | -- | one-line skeleton
    TraceSummary
  | -- | branch decisions
    TraceDetail
  | -- | dump large terms/envs/spines
    TraceDump
  deriving (Eq, Ord, Show)

data TraceOutcome
  = OutOk
  | OutFail
  | OutStuck
  | OutProgress
  | OutNoProgress
  deriving (Eq, Ord, Show)

matchesMaybe :: (Eq a) => Maybe [a] -> a -> Bool
matchesMaybe Nothing _ = True
matchesMaybe (Just xs) x = x `elem` xs

matchesOutcome :: Maybe [TraceOutcome] -> Maybe TraceOutcome -> Bool
matchesOutcome Nothing _ = True
matchesOutcome (Just _) Nothing = True
matchesOutcome (Just xs) (Just x) = x `elem` xs

traceFieldNames :: TraceFieldValue -> [HCName]
traceFieldNames field =
  case field of
    TrName n -> [n]
    TrHead h -> traceHeadNames h
    TrValueHead v -> traceValueHeadNames v
    TrValue v -> traceValueHeadNames v
    TrElim e -> traceElimNames e
    TrSpine sp -> concatMap traceElimNames sp
    _ -> []

traceHeadNames :: Head -> [HCName]
traceHeadNames h =
  case h of
    HLvl n _ -> [n]
    HConst n _ -> [n]

traceElimNames :: Elim -> [HCName]
traceElimNames e =
  case e of
    EApp v -> traceValueHeadNames v
    EProj n _ -> [n]

traceValueHeadNames :: Value -> [HCName]
traceValueHeadNames v =
  case v of
    VSort {} -> []
    VLit {} -> []
    VLam n _ _ _ -> [n]
    VPi n _ _ _ -> [n]
    VNeutral h _ -> traceHeadNames h
    VDef n _ _ _ -> [n]

matchesConstants :: Maybe [HCName] -> TraceEvent -> Bool
matchesConstants Nothing _ = True
matchesConstants (Just wanted) ev =
  let present = concatMap (traceFieldNames . snd) (traceFields ev)
   in any (`elem` wanted) present

shouldTraceEvent :: TraceEvent -> KernelM Bool
shouldTraceEvent ev = do
  cfg <- asks checkTraceConfig
  pure $
    traceVerbosity cfg /= TraceOff
      && traceEventVerbosity ev /= TraceOff
      && traceEventVerbosity ev <= traceVerbosity cfg
      && matchesMaybe (tracePhases cfg) (tracePhase ev)
      && matchesMaybe (traceKinds cfg) (traceKind ev)
      && matchesOutcome (traceOutcomes cfg) (traceOutcome ev)
      && matchesConstants (traceConstants cfg) ev

mkTraceEvent ::
  TracePhase ->
  TraceKind ->
  TraceVerbosity ->
  String ->
  [TraceField] ->
  Maybe TraceOutcome ->
  TraceEvent
mkTraceEvent phase kind verb label fields outcome =
  TraceEvent
    { tracePhase = phase,
      traceKind = kind,
      traceEventVerbosity = verb,
      traceOutcome = outcome,
      traceLabel = label,
      traceFields = fields
    }

appendTraceNode :: TraceNode -> KernelM ()
appendTraceNode node =
  modify' $ \s ->
    case checkTraceStack s of
      current : rest ->
        s {checkTraceStack = (current ++ [node]) : rest}
      [] ->
        s {checkTraceStack = [[node]]}

pushTraceFrame :: KernelM ()
pushTraceFrame =
  modify' $ \s -> s {checkTraceStack = [] : checkTraceStack s}

popTraceBlock :: TraceEvent -> KernelM ()
popTraceBlock ev =
  modify' $ \s ->
    case checkTraceStack s of
      completed : parent : rest ->
        let block = TraceBlock ev completed
         in s {checkTraceStack = (parent ++ [block]) : rest}
      [completed] ->
        s {checkTraceStack = [[TraceBlock ev completed]]}
      [] ->
        s {checkTraceStack = [[TraceBlock ev []]]}

traceEmit :: TraceEvent -> KernelM ()
traceEmit ev = do
  active <- shouldTraceEvent ev
  when active $
    appendTraceNode (TraceLeaf ev)

traceEvent ::
  TracePhase ->
  TraceKind ->
  TraceVerbosity ->
  String ->
  [TraceField] ->
  KernelM ()
traceEvent phase kind verb label fields =
  traceEmit (mkTraceEvent phase kind verb label fields Nothing)

traceOk ::
  TracePhase ->
  TraceKind ->
  TraceVerbosity ->
  String ->
  [TraceField] ->
  KernelM ()
traceOk phase kind verb label fields =
  traceEmit (mkTraceEvent phase kind verb label fields (Just OutOk))

traceFail ::
  TracePhase ->
  TraceKind ->
  TraceVerbosity ->
  String ->
  [TraceField] ->
  KernelM ()
traceFail phase kind verb label fields =
  traceEmit (mkTraceEvent phase kind verb label fields (Just OutFail))

traceStuck ::
  TracePhase ->
  TraceKind ->
  TraceVerbosity ->
  String ->
  [TraceField] ->
  KernelM ()
traceStuck phase kind verb label fields =
  traceEmit (mkTraceEvent phase kind verb label fields (Just OutStuck))

traceProgress ::
  TracePhase ->
  TraceKind ->
  TraceVerbosity ->
  String ->
  [TraceField] ->
  KernelM ()
traceProgress phase kind verb label fields =
  traceEmit (mkTraceEvent phase kind verb label fields (Just OutProgress))

traceNoProgress ::
  TracePhase ->
  TraceKind ->
  TraceVerbosity ->
  String ->
  [TraceField] ->
  KernelM ()
traceNoProgress phase kind verb label fields =
  traceEmit (mkTraceEvent phase kind verb label fields (Just OutNoProgress))

traceBlock ::
  TracePhase ->
  TraceKind ->
  TraceVerbosity ->
  String ->
  [TraceField] ->
  KernelM a ->
  KernelM a
traceBlock phase kind verb label fields action = do
  let ev0 = mkTraceEvent phase kind verb label fields Nothing
  active <- shouldTraceEvent ev0
  if not active
    then action
    else do
      pushTraceFrame
      catchError
        ( do
            r <- action
            let evOk = ev0 {traceOutcome = Just OutOk}
            popTraceBlock evOk
            pure r
        )
        ( \err -> do
            let errEv =
                  mkTraceEvent
                    phase
                    TkError
                    TraceSummary
                    "error"
                    [("message", TrString err)]
                    (Just OutFail)
            appendTraceNode (TraceLeaf errEv)
            let evFail = ev0 {traceOutcome = Just OutFail}
            popTraceBlock evFail
            throwError err
        )

instance PrettyPrint TraceNode where
  ppr (TraceLeaf ev) = ppTraceLeaf ev
  ppr (TraceBlock ev children) =
    vcat $
      ppTraceBlockHeader ev
        : map (nest 2 . ppr) children

ppTraceLeaf :: TraceEvent -> Doc
ppTraceLeaf ev =
  ppTracePrefix False ev <+> ppTraceEventBody ev

ppTraceBlockHeader :: TraceEvent -> Doc
ppTraceBlockHeader ev =
  ppTracePrefix True ev <+> ppTraceEventBody ev

ppTracePrefix :: Bool -> TraceEvent -> Doc
ppTracePrefix isBlock ev =
  case traceOutcome ev of
    Just OutOk ->
      green (text (if isBlock then "▼" else "✓"))
    Just OutFail ->
      bold (red (text (if isBlock then "▼" else "✗")))
    Just OutStuck ->
      yellow (text (if isBlock then "▼" else "⊣"))
    Just OutProgress ->
      cyan (text (if isBlock then "▼" else "↦"))
    Just OutNoProgress ->
      dim (text (if isBlock then "▼" else "·"))
    Nothing ->
      if isBlock
        then bold (blue (text "▼"))
        else green (text "⊢")

ppTraceEventBody :: TraceEvent -> Doc
ppTraceEventBody ev =
  ppTraceMeta ev
    <+> text (traceLabel ev)
    <+> ppTraceFields (traceFields ev)

ppTraceMeta :: TraceEvent -> Doc
ppTraceMeta ev =
  dim $
    brackets $
      ppr (tracePhase ev)
        <> char '/'
        <> ppr (traceKind ev)
        <> char '/'
        <> ppr (traceEventVerbosity ev)
        <> ppOutcomeSuffix (traceOutcome ev)

ppOutcomeSuffix :: Maybe TraceOutcome -> Doc
ppOutcomeSuffix Nothing = text ""
ppOutcomeSuffix (Just out) =
  char '/'
    <> case out of
      OutOk -> text "ok"
      OutFail -> text "fail"
      OutStuck -> text "stuck"
      OutProgress -> text "progress"
      OutNoProgress -> text "no-progress"

ppTraceFields :: [TraceField] -> Doc
ppTraceFields [] = text ""
ppTraceFields fields =
  dim (char '{')
    <> hcatWithComma (map ppr fields)
    <> dim (char '}')

instance PrettyPrint TraceField where
  ppr (key, val) = cyan (text key) <> dim (char '=') <> ppTraceFieldValue val
    where
      ppTraceFieldValue val =
        case val of
          TrString s -> text s
          TrDoc d -> d
          TrInt n -> int n
          TrBool b -> text (show b)
          TrName n -> ppr n
          TrLevel l -> ppr l
          TrExpr e -> ppr e
          TrValue v -> ppr v
          TrValueHead v -> ppValueHead v
          TrHead h -> ppr h
          TrElim e -> ppr e
          TrSpine sp -> brackets (hcatWithComma (map ppr sp))
          TrSpineLen sp -> int (length sp)

ppValueHead :: Value -> Doc
ppValueHead v =
  case v of
    VSort lvl ->
      yellow (text "Sort") <+> ppr lvl
    VLit lit ->
      cyan (text "Lit") <+> ppr lit
    VLam n _ _ _ ->
      magenta (text "Lam") <+> ppr n
    VPi n _ _ _ ->
      magenta (text "Pi") <+> ppr n
    VNeutral h sp ->
      red (text "Neutral")
        <+> ppr h
        <+> dim (text "spineLen=" <> int (length sp))
    VDef n lvls sp _ ->
      blue (text "Def")
        <+> ppr n
        <+> dim (brackets (hcatWithComma (map ppr lvls)))
        <+> dim (text "spineLen=" <> int (length sp))

instance PrettyPrint TraceVerbosity where
  ppr v = case v of
    TraceOff -> text "off"
    TraceSummary -> text "summary"
    TraceDetail -> text "detail"
    TraceDump -> text "dump"

instance PrettyPrint TracePhase where
  ppr p =
    case p of
      PhDecl -> text "decl"
      PhInfer -> text "infer"
      PhEval -> text "eval"
      PhDefEq -> text "defeq"
      PhReduce -> text "reduce"
      PhQuote -> text "quote"
      PhEta -> text "eta"
      PhLookup -> text "lookup"
      PhLocalCtx -> text "local"
      PhMisc -> text "misc"

instance PrettyPrint TraceKind where
  ppr k =
    case k of
      TkEnter -> text "enter"
      TkEvent -> text "event"
      TkDecision -> text "decision"
      TkSuccess -> text "success"
      TkFailure -> text "failure"
      TkStuck -> text "stuck"
      TkFallback -> text "fallback"
      TkReduction -> text "reduction"
      TkCompare -> text "compare"
      TkLookup -> text "lookup"
      TkSpine -> text "spine"
      TkUnfold -> text "unfold"
      TkForce -> text "force"
      TkError -> text "error"

renderKernelTrace :: KernelState -> Doc
renderKernelTrace st =
  case checkTraceStack st of
    [] ->
      text "No trace generated."
    [topLevel] ->
      vcat (map ppr topLevel)
    malformedStack ->
      text "Warning: Malformed trace stack."
        <> text "\n"
        <> vcat (map ppr (concat (reverse malformedStack)))

withTraceConfig :: TraceConfig -> KernelM a -> KernelM a
withTraceConfig cfg =
  local (\ctx -> ctx {checkTraceConfig = cfg})

withTraceVerbosity :: TraceVerbosity -> KernelM a -> KernelM a
withTraceVerbosity verb =
  local
    ( \ctx ->
        let cfg = checkTraceConfig ctx
         in ctx {checkTraceConfig = cfg {traceVerbosity = verb}}
    )

withTracePhases :: [TracePhase] -> KernelM a -> KernelM a
withTracePhases phases =
  local
    ( \ctx ->
        let cfg = checkTraceConfig ctx
         in ctx {checkTraceConfig = cfg {tracePhases = Just phases}}
    )

withTraceKinds :: [TraceKind] -> KernelM a -> KernelM a
withTraceKinds kinds =
  local
    ( \ctx ->
        let cfg = checkTraceConfig ctx
         in ctx {checkTraceConfig = cfg {traceKinds = Just kinds}}
    )

withTraceConstants :: [HCName] -> KernelM a -> KernelM a
withTraceConstants names =
  local
    ( \ctx ->
        let cfg = checkTraceConfig ctx
         in ctx {checkTraceConfig = cfg {traceConstants = Just names}}
    )

withFullTrace :: KernelM a -> KernelM a
withFullTrace = withTraceConfig maxTraceConfig

runKernelWithTraceIO :: KernelEnv -> InternState -> KernelM a -> IO (Either KernelError a, InternState)
runKernelWithTraceIO env internSt action = do
  let (result, finalState) = runKernelM env internSt action
  printKernelTrace finalState
  case result of
    Left err -> putStrLn $ "❌ Kernel Error: " ++ err
    Right _ -> putStrLn "✅ Kernel Execution Succeeded."
  pure (result, checkInternState finalState)

printKernelTrace :: KernelState -> IO ()
printKernelTrace st = do
  putStrLn "\n================ KERNEL TRACE ================"
  putStrLn $ toString (renderKernelTrace st)
  putStrLn "==============================================\n"

--------------------------------------------------------------------------------

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
lookupConstInfo name = gets (IntMap.lookup (hcnId name) . checkEnv)

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

constHasBody :: HCName -> KernelM Bool
constHasBody name = maybe False constantInfoHasBody <$> lookupConstInfo name

constIsDeltaUnfoldable :: HCName -> KernelM Bool
constIsDeltaUnfoldable name = maybe False constantInfoIsDeltaUnfoldable <$> lookupConstInfo name

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
    Nothing -> throwError $ "Constructor not validated: " <> show ctorName

lookupValidatedRecursorRule :: HCName -> HCName -> KernelM (RecursorRule HCExpr HCLevel)
lookupValidatedRecursorRule recName majorCtorName = do
  metadata <- gets checkMetadata
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
  metadata <- gets checkMetadata
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
  mInfo <- gets (IntMap.lookup (hcnId name) . checkEnv)
  case mInfo >>= constantInfoDeltaUnfoldability of
    Just hints -> pure hints
    Nothing -> pure Opaque

withLocalDecl :: Int -> LocalDecl -> KernelM a -> KernelM a
withLocalDecl depth decl k = local (\ctx -> ctx {checkLocalCtx = IntMap.insert depth decl (checkLocalCtx ctx)}) k

modifyGlobalEnv :: (KernelEnv -> KernelEnv) -> KernelM ()
modifyGlobalEnv f = modify' $ \s -> s {checkEnv = f (checkEnv s)}

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
      HLvl name lvl -> cyan $ ppr name <> text "^" <> int lvl
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
