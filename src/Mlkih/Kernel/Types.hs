{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
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

data KernelCtx = KernelCtx
  { checkLocalCtx :: !LocalCtx,
    checkTraceConfig :: !TraceConfig
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
  ppr (TraceLeaf ev) = ppTracePrefix False ev <+> ppTraceEventBody ev
  ppr (TraceBlock ev children) =
    vcat $ ppTraceBlockHeader : map (nest 2 . ppr) children
    where
      ppTraceBlockHeader = ppTracePrefix True ev <+> ppTraceEventBody ev

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
  where
    ppTraceFields [] = text ""
    ppTraceFields fields =
      dim (char '{')
        <> hcatWithComma (map ppr fields)
        <> dim (char '}')
    ppTraceMeta ev =
      dim $
        brackets $
          ppr (tracePhase ev)
            <> char '/'
            <> ppr (traceKind ev)
            <> char '/'
            <> ppr (traceEventVerbosity ev)
            <> ppOutcomeSuffix (traceOutcome ev)
    ppOutcomeSuffix Nothing = text ""
    ppOutcomeSuffix (Just out) =
      char '/'
        <> case out of
          OutOk -> text "ok"
          OutFail -> text "fail"
          OutStuck -> text "stuck"
          OutProgress -> text "progress"
          OutNoProgress -> text "no-progress"

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
          VDef n lvls sp ->
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
      TkWHNF -> text "whnf"
      TkError -> text "error"

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
      VDef name levels spine -> blue (text "VDef") <+> parens (ppr name <+> ppr levels <+> ppr spine)
