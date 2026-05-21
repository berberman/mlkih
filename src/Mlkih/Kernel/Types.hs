{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeSynonymInstances #-}

module Mlkih.Kernel.Types where

import Control.Monad.Except
import Control.Monad.Reader
import Control.Monad.State.Strict
import Data.IntMap (IntMap)
import Data.Map.Strict (Map)
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

--------------------------------------------------------------------------------

data LocalDecl = LocalDecl
  { localName :: HCName,
    localType :: Value,
    -- | For let-bindings
    localValue :: Maybe Value
  }
  deriving (Show)

type LocalCtx = IntMap LocalDecl

--------------------------------------------------------------------------------
data ProgressSubject
  = ProgressConstant !HCName
  | ProgressInductiveBlock !InductiveBlockProgress

data InductiveBlockProgress = InductiveBlockProgress
  { ibTypes :: ![HCName],
    ibConstructorCount :: !Int,
    ibRecursorCount :: !Int
  }

data ProgressState = ProgressState
  { progressDone :: !Int,
    progressTotal :: !Int,
    progressCurrent :: !(Maybe ProgressSubject)
  }

data ProgressEvent
  = ProgressCheckingDecl !Int !Int !ProgressSubject
  | ProgressCheckedDecl !Int !Int !ProgressSubject
  | ProgressMessage !Doc

instance PrettyPrint ProgressSubject where
  ppr subj =
    case subj of
      ProgressConstant name ->
        ppr name
      ProgressInductiveBlock block ->
        ppr "inductive block"
          <+> ppr (ibTypes block)
          <+> dim
            ( parens $
                ppr (ibConstructorCount block)
                  <+> ppr "ctors,"
                  <+> ppr (ibRecursorCount block)
                  <+> ppr "recs"
            )

--------------------------------------------------------------------------------

data KernelCtx = KernelCtx
  { checkLocalCtx :: !LocalCtx,
    checkTraceConfig :: !TraceConfig,
    checkProgress :: !(ProgressEvent -> IO ())
  }

data KernelState = KernelState
  { checkEnv :: !KernelEnv,
    checkMetadata :: !ValidatedKernelMetadata,
    checkInternState :: !InternState,
    checkClosedDefEqActive :: ![ClosedDefEqKey],
    checkClosedDefEqCache :: !(Map ClosedDefEqKey Bool),
    checkTraceStack :: ![[TraceNode]]
  }

instance HasInternState KernelState where
  getInternState = checkInternState
  setInternState s st = st {checkInternState = s}

type KernelError = String

--------------------------------------------------------------------------------

newtype KernelM a = KernelM {unKernelM :: KernelCtx -> KernelState -> IO (Either KernelError a, KernelState)}

instance Functor KernelM where
  fmap f (KernelM m) = KernelM $ \ctx st ->
    m ctx st >>= \case
      (Right a, st') -> pure (Right (f a), st')
      (Left err, st') -> pure (Left err, st')
  {-# INLINE fmap #-}

instance Applicative KernelM where
  pure a = KernelM $ \_ st -> pure (Right a, st)
  {-# INLINE pure #-}
  KernelM mf <*> KernelM ma = KernelM $ \ctx st ->
    mf ctx st >>= \case
      (Left err, st') -> pure (Left err, st')
      (Right f, st') ->
        ma ctx st' >>= \case
          (Left err, st'') -> pure (Left err, st'')
          (Right a, st'') -> pure (Right (f a), st'')
  {-# INLINE (<*>) #-}

instance Monad KernelM where
  return = pure
  KernelM m >>= f = KernelM $ \ctx st ->
    m ctx st >>= \case
      (Left err, st') -> pure (Left err, st')
      (Right a, st') -> unKernelM (f a) ctx st'
  {-# INLINE (>>=) #-}

instance MonadReader KernelCtx KernelM where
  ask = KernelM $ \ctx st -> pure (Right ctx, st)
  {-# INLINE ask #-}
  local f (KernelM m) = KernelM $ \ctx st -> m (f ctx) st
  {-# INLINE local #-}

instance MonadState KernelState KernelM where
  get = KernelM $ \_ st -> pure (Right st, st)
  {-# INLINE get #-}
  put !newSt = KernelM $ \_ _ -> pure (Right (), newSt)
  {-# INLINE put #-}

instance MonadError KernelError KernelM where
  throwError err = KernelM $ \_ st -> pure (Left err, st)
  {-# INLINE throwError #-}
  catchError (KernelM m) handler = KernelM $ \ctx st ->
    m ctx st >>= \case
      (Left err, st') -> unKernelM (handler err) ctx st'
      success -> pure success
  {-# INLINE catchError #-}

instance MonadFail KernelM where
  fail = throwError
  {-# INLINE fail #-}

instance MonadIO KernelM where
  liftIO io = KernelM $ \_ st -> do
    r <- io
    pure (Right r, st)
  {-# INLINE liftIO #-}

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
  | TkWHNF
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

instance PrettyPrint TraceNode where
  ppr (TraceLeaf ev) =
    group (ppTracePrefix False ev <+> ppTraceEventBody ev)
  ppr (TraceBlock ev children) =
    vsep $ group (ppTraceBlockHeader ev) : map (nest 2 . ppr) children

ppTraceBlockHeader :: TraceEvent -> Doc
ppTraceBlockHeader ev = ppTracePrefix True ev <+> ppTraceEventBody ev

ppTracePrefix :: Bool -> TraceEvent -> Doc
ppTracePrefix isBlock ev =
  case traceOutcome ev of
    Just OutOk ->
      green (ppr (if isBlock then "▼" else "✓"))
    Just OutFail ->
      bold (red (ppr (if isBlock then "▼" else "✗")))
    Just OutStuck ->
      yellow (ppr (if isBlock then "▼" else "⊣"))
    Just OutProgress ->
      cyan (ppr (if isBlock then "▼" else "↦"))
    Just OutNoProgress ->
      dim (ppr (if isBlock then "▼" else "·"))
    Nothing ->
      if isBlock
        then bold (blue (ppr "▼"))
        else green (ppr "⊢")

ppTraceEventBody :: TraceEvent -> Doc
ppTraceEventBody ev =
  group $
    align $
      sep $
        [ ppTraceMeta ev,
          ppr (traceLabel ev)
        ]
          ++ ppTraceFields (traceFields ev)

ppTraceFields :: [TraceField] -> [Doc]
ppTraceFields [] = []
ppTraceFields fields = [ppTraceFieldList fields]

ppTraceMeta :: TraceEvent -> Doc
ppTraceMeta event =
  dim $
    brackets $
      ppr (tracePhase event)
        <> ppr '/'
        <> ppr (traceKind event)
        <> ppr '/'
        <> ppr (traceEventVerbosity event)
        <> ppOutcomeSuffix (traceOutcome event)

ppOutcomeSuffix :: Maybe TraceOutcome -> Doc
ppOutcomeSuffix Nothing = mempty
ppOutcomeSuffix (Just out) =
  ppr '/'
    <> case out of
      OutOk -> ppr "ok"
      OutFail -> ppr "fail"
      OutStuck -> ppr "stuck"
      OutProgress -> ppr "progress"
      OutNoProgress -> ppr "no-progress"

ppTraceFieldList :: [TraceField] -> Doc
ppTraceFieldList fields =
  group $
    dim (ppr '{')
      <> align (hcatWithComma (map ppr fields))
      <> dim (ppr '}')

instance PrettyPrint TraceField where
  ppr (key, val) =
    group $
      cyan (ppr key)
        <> dim (ppr '=')
        <> align (ppTraceFieldValue [] val)

type ValueBinderCtx = [Maybe HCName]

ppTraceFieldValue :: ValueBinderCtx -> TraceFieldValue -> Doc
ppTraceFieldValue ctx fieldVal =
  case fieldVal of
    TrString str -> ppr str
    TrDoc doc -> doc
    TrInt n -> ppr n
    TrBool b -> ppr b
    TrName n -> ppr n
    TrLevel lvl -> ppr lvl
    TrExpr expr -> pprNamedExpr ctx expr
    TrValue value -> pprNamedValue ctx value
    TrValueHead value -> ppValueHead ctx value
    TrHead h -> ppr h
    TrElim elim -> pprNamedElim ctx elim
    TrSpine sp -> pprNamedSpine ctx sp
    TrSpineLen sp -> ppr (length sp)

ppValueHead :: ValueBinderCtx -> Value -> Doc
ppValueHead ctx value =
  case value of
    VSort lvl ->
      yellow (ppr "Sort") <+> ppr lvl
    VLit lit ->
      cyan (ppr "Lit") <+> ppr lit
    VLam n _ _ _ ->
      magenta (ppr "Lam") <+> ppr n
    VPi n _ _ _ ->
      magenta (ppr "Pi") <+> ppr n
    VNeutral h sp ->
      group $
        red (ppr "Neutral")
          <+> align
            ( sep
                [ ppr h,
                  dim (ppr "spineLen=" <> ppr (length sp)),
                  dim (ppr "spine=") <> pprNamedSpine ctx sp
                ]
            )
    VDef n lvls sp ->
      group $
        blue (ppr "Def")
          <+> align
            ( sep
                [ ppr n,
                  dim (brackets (hcatWithComma (map ppr lvls))),
                  dim (ppr "spineLen=" <> ppr (length sp)),
                  dim (ppr "spine=") <> pprNamedSpine ctx sp
                ]
            )

instance PrettyPrint TraceVerbosity where
  ppr v = case v of
    TraceOff -> ppr "off"
    TraceSummary -> ppr "summary"
    TraceDetail -> ppr "detail"
    TraceDump -> ppr "dump"

instance PrettyPrint TracePhase where
  ppr p =
    case p of
      PhDecl -> ppr "decl"
      PhInfer -> ppr "infer"
      PhEval -> ppr "eval"
      PhDefEq -> ppr "defeq"
      PhReduce -> ppr "reduce"
      PhQuote -> ppr "quote"
      PhEta -> ppr "eta"
      PhLookup -> ppr "lookup"
      PhLocalCtx -> ppr "local"
      PhMisc -> ppr "misc"

instance PrettyPrint TraceKind where
  ppr k =
    case k of
      TkEnter -> ppr "enter"
      TkEvent -> ppr "event"
      TkDecision -> ppr "decision"
      TkSuccess -> ppr "success"
      TkFailure -> ppr "failure"
      TkStuck -> ppr "stuck"
      TkFallback -> ppr "fallback"
      TkReduction -> ppr "reduction"
      TkCompare -> ppr "compare"
      TkLookup -> ppr "lookup"
      TkSpine -> ppr "spine"
      TkUnfold -> ppr "unfold"
      TkWHNF -> ppr "whnf"
      TkError -> ppr "error"

--------------------------------------------------------------------------------

newtype ClosedDefEqKey = ClosedDefEqKey (HCId, HCId)
  deriving (Eq, Ord, Show)

--------------------------------------------------------------------------------

-- | env = [level depth-1, level depth-2, ..., level 0]
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

-- | INVARIANT:
-- 1. @VDef name lvls spineRev@ is a delayed transparent global constant
--    application. It may reduce when exposed by whnf.
-- 2. All other Value constructors are considered head-exposed values.
-- 3. @VNeutral head spineRev@ must only be produced after reduction has tried
--    to make progress and determined that the head/spine is stuck, or for
--    irreducible constants/locals with no pending reducible head.
data Value
  = VSort !HCLevel
  | VLit !Literal
  | VLam !HCName !BinderInfo !Value !Closure
  | VPi !HCName !BinderInfo !Value !Closure
  | -- | A stuck term (e.g., Free Variable applied to arguments)
    VNeutral !Head !Spine
  | -- | Lazy Delta Reduction
    VDef !HCName ![HCLevel] !Spine
  deriving (Show)

instance PrettyPrint Closure where
  ppr = pprNamedClosure []

pprNamedClosure :: ValueBinderCtx -> Closure -> Doc
pprNamedClosure ctx (Closure env body) =
  group $
    dim (ppr "Closure")
      <+> dim
        ( braces $
            align $
              sep
                [ ppr "env:" <+> brackets (hcatWithComma (map (pprNamedValue ctx) env)),
                  ppr "body:" <+> pprNamedExpr ctx body
                ]
        )

instance PrettyPrint Elim where
  ppr = pprNamedElim []

pprNamedElim :: ValueBinderCtx -> Elim -> Doc
pprNamedElim ctx elim =
  case elim of
    EApp arg ->
      group $ bold (magenta (ppr "EApp")) <+> dim (parens (align (pprNamedValue ctx arg)))
    EProj projName idx ->
      group $
        bold (magenta (ppr "EProj"))
          <+> dim
            ( parens $
                green (ppr projName) <> dim (ppr '.') <> cyan (ppr idx)
            )

pprNamedSpine :: ValueBinderCtx -> Spine -> Doc
pprNamedSpine ctx spine =
  brackets (hcatWithComma (map (pprNamedElim ctx) spine))

instance PrettyPrint Head where
  ppr head =
    case head of
      HLvl name lvl -> cyan $ ppr name <> ppr "^" <> ppr lvl
      HConst name levels ->
        green (ppr name)
          <> if null levels
            then mempty
            else dim (brackets (hcatWithComma (map ppr levels)))

instance PrettyPrint Value where
  ppr = pprNamedValue []

pprNamedValue :: ValueBinderCtx -> Value -> Doc
pprNamedValue ctx val =
  case val of
    VSort lvl ->
      yellow (ppr "VSort") <+> parens (ppr lvl)
    VLit lit ->
      cyan (ppr "VLit") <+> parens (ppr lit)
    VLam name binderInfo ty body ->
      ppValueBinder ctx (magenta (ppr "VLam")) name binderInfo ty body
    VPi name binderInfo ty body ->
      ppValueBinder ctx (bold (magenta (ppr "VPi"))) name binderInfo ty body
    VNeutral head spine ->
      ppValueApp (red (ppr "VNeutral")) [ppr head, pprNamedSpine ctx spine]
    VDef name levels spine ->
      ppValueApp (blue (ppr "VDef")) [ppr name, ppr levels, pprNamedSpine ctx spine]

ppValueBinder :: ValueBinderCtx -> Doc -> HCName -> BinderInfo -> Value -> Closure -> Doc
ppValueBinder ctx keyword name binderInfo ty body =
  group $
    keyword
      <+> parens
        ( align $
            sep
              [ ppBinder binderInfo name (pprNamedValue ctx ty),
                magenta (ppr "=>"),
                pprNamedClosure (Just name : ctx) body
              ]
        )

ppValueApp :: Doc -> [Doc] -> Doc
ppValueApp keyword args =
  group $
    keyword
      <+> parens (align (sep args))
