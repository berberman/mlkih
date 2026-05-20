{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Mlkih.Kernel.Eval where

import Control.Monad (foldM, unless, when, zipWithM)
import Control.Monad.Except
import Control.Monad.Reader (asks)
import Control.Monad.Trans (lift)
import qualified Data.IntMap.Strict as IntMap
import Data.List ((!?))
import Mlkih.AST
import Mlkih.Env
import Mlkih.Expr
import Mlkih.Intern
import Mlkih.Kernel.Cache
import Mlkih.Kernel.Monad
import Mlkih.Kernel.Trace
import Mlkih.Kernel.Types
import Mlkih.Kernel.Utils
import Mlkih.Level
import Mlkih.Name
import Mlkih.Pretty
import Numeric.Natural

--------------------------------------------------------------------------------

evalM :: LocalEnv -> HCExpr -> KernelM Value
evalM env expr = traceBlock PhEval TkEnter TraceDetail "eval.expr" [("expr", TrExpr expr), ("envLen", TrInt (length env))] $ do
  traceEvent PhEval TkEvent TraceDump "local.env" [("env", TrDoc (ppr env))]
  case hceVal expr of
    BVar idx -> do
      traceEvent PhEval TkLookup TraceDetail "eval.bvar" [("index", TrInt idx)]
      case env !? idx of
        Just val -> pure val
        _ -> do
          traceFail PhEval TkLookup TraceSummary "eval.bvar.outOfBounds" [("index", TrInt idx), ("envLen", TrInt (length env))]
          throwError $ "Local variable index out of bounds: " <> show idx
    Sort lvl -> do
      traceOk PhEval TkEvent TraceDetail "eval.sort" [("level", TrLevel lvl)]
      pure $ VSort lvl
    Lit lit -> do
      traceOk PhEval TkEvent TraceDetail "eval.literal" [("literal", TrDoc (ppr lit))]
      pure $ VLit lit
    Lam name ty body bi -> do
      traceEvent PhEval TkEvent TraceDetail "eval.lam.domain" [("binder", TrName name)]
      tyVal <- evalM env ty
      traceEvent PhEval TkEvent TraceDump "eval.lam.closure" [("envLen", TrInt (length env))]
      pure $ VLam name bi tyVal (Closure env body)
    ForallE name ty body bi -> do
      traceEvent PhEval TkEvent TraceDetail "eval.pi.domain" [("binder", TrName name)]
      tyVal <- evalM env ty
      traceEvent PhEval TkEvent TraceDump "eval.pi.closure" [("envLen", TrInt (length env))]
      pure $ VPi name bi tyVal (Closure env body)
    Let name _ val body _nondep -> do
      traceEvent PhEval TkEvent TraceDetail "eval.let.value" [("name", TrName name)]
      valVal <- evalM env val
      traceEvent PhEval TkEvent TraceDetail "eval.let.body" [("newEnvLen", TrInt (length env + 1))]
      evalM (valVal : env) body
    App fn arg -> do
      traceEvent PhEval TkEvent TraceDetail "eval.app.fn" []
      fnVal <- evalM env fn
      traceEvent PhEval TkEvent TraceDetail "eval.app.arg" []
      argVal <- evalM env arg
      traceEvent PhEval TkReduction TraceDetail "eval.app.apply" []
      applyElimM (length env) fnVal (EApp argVal)
    Proj name idx struct -> do
      traceEvent PhEval TkEvent TraceDetail "eval.proj.struct" [("proj", TrName name), ("field", TrInt idx)]
      structVal <- evalM env struct
      applyElimM (length env) structVal (EProj name idx)
    Const name levels -> do
      traceEvent PhLookup TkLookup TraceDetail "const.lookup" [("const", TrName name)]
      mInfo <- lookupConstInfo name
      case mInfo of
        Just (DefnInfo _) -> do
          traceEvent
            PhEval
            TkUnfold
            TraceDetail
            "const.def.delay"
            [ ("const", TrName name),
              ("levels", TrDoc (ppr levels))
            ]
          pure $ VDef name levels []
        _ -> do
          traceStuck PhEval TkStuck TraceSummary "const.neutral" [("const", TrName name), ("levels", TrDoc (ppr levels))]
          pure $ VNeutral (HConst name levels) []

--------------------------------------------------------------------------------

newtype StuckReason = StuckReason String
  deriving (Show, Eq)

type ReduceM = ExceptT StuckReason KernelM

stuck :: String -> ReduceM a
stuck = throwError . StuckReason

unlessStuck :: Bool -> String -> ReduceM ()
unlessStuck cond msg = unless cond (stuck msg)

fromMaybeStuck :: String -> Maybe a -> ReduceM a
fromMaybeStuck msg = maybe (stuck msg) pure

catchEKernelAsStuck :: KernelM a -> String -> ReduceM a
catchEKernelAsStuck action reason =
  ExceptT $ do
    result <-
      (Right <$> action) `catchError` \_ ->
        pure (Left (StuckReason reason))
    pure result

runReduction ::
  HCName ->
  [HCLevel] ->
  Spine ->
  ReduceM Value ->
  KernelM Value
runReduction headName lvls newSpine attempt = do
  result <- runExceptT attempt
  case result of
    Right v ->
      pure v
    Left (StuckReason reason) -> do
      traceStuck
        PhReduce
        TkStuck
        TraceSummary
        "neutral.stuck"
        [ ("head", TrName headName),
          ("reason", TrString reason),
          ("spineLen", TrInt (length newSpine))
        ]
      pure $ VNeutral (HConst headName lvls) newSpine

--------------------------------------------------------------------------------

reduceNeutralConst ::
  Int ->
  HCName ->
  [HCLevel] ->
  Spine ->
  ReduceM Value
reduceNeutralConst depth headName lvls newSpine = do
  mInfo <- lift $ lookupConstInfo headName
  case mInfo of
    Just (QuotInfo quotVal)
      | quotKind quotVal == QuotLift ->
          reduceQuotLift depth headName newSpine
    Just (RecInfo recVal) ->
      reduceRecursor depth headName lvls recVal newSpine
    _ ->
      stuck "head is not a recursor or quotient lifting constant"

--------------------------------------------------------------------------------

-- | Quotient lifting reduction: @Quot.lift f h (Quot.mk a) = f a@
--   @newSpine = reverse [alpha, r, beta, f, h, major]@
reduceQuotLift ::
  Int ->
  HCName ->
  Spine ->
  ReduceM Value
reduceQuotLift depth liftName newSpine = do
  lift $
    traceEvent
      PhReduce
      TkDecision
      TraceDetail
      "quot.lift.try"
      [ ("const", TrName liftName),
        ("args", TrInt (length newSpine))
      ]

  unlessStuck
    (length newSpine >= 6)
    "not enough arguments for Quot.lift"

  let numExtra = length newSpine - 6
      extraRev = take numExtra newSpine
      exactRev = drop numExtra newSpine

  lift $
    traceEvent
      PhReduce
      TkSpine
      TraceDetail
      "quot.lift.major"
      [ ("exactArgs", TrInt (length exactRev)),
        ("extraArgs", TrInt (length extraRev))
      ]

  majorVal <- lift $ indexRevSpineApp "quot.lift.major" 0 exactRev
  whnfMajor <- lift $ whnf depth majorVal

  (mkName, mkSpine) <-
    case whnfMajor of
      VNeutral (HConst mkName _) mkSpine -> pure (mkName, mkSpine)
      _ -> stuck "major premise is not a stuck application"

  mMkInfo <- lift $ lookupConstInfo mkName
  case mMkInfo of
    Just (QuotInfo mkVal) | quotKind mkVal == QuotMk -> do
      lift $
        traceProgress
          PhReduce
          TkReduction
          TraceDetail
          "quot.lift.reduce"
          [ ("lift", TrName liftName),
            ("mk", TrName mkName)
          ]

      aVal <- lift $ indexRevSpineApp "quot.mk.arg" 0 mkSpine
      fVal <- lift $ indexRevSpineApp "quot.lift.f" 2 exactRev

      reduced <- lift $ applyElimM depth fVal (EApp aVal)
      lift $ applyElimsM depth reduced extraRev
    _ -> stuck "major premise is not Quot.mk"

--------------------------------------------------------------------------------

reduceRecursor ::
  Int ->
  HCName ->
  [HCLevel] ->
  RecursorVal HCExpr HCLevel ->
  Spine ->
  ReduceM Value
reduceRecursor depth recName recLvls recVal newSpine = do
  let expected = recursorExpectedArgs recVal

  lift $
    traceEvent
      PhReduce
      TkSpine
      TraceDetail
      "recursor.args"
      [ ("recursor", TrName recName),
        ("expected", TrInt expected),
        ("actual", TrInt (length newSpine)),
        ("params", TrInt (recParamsN recVal)),
        ("motives", TrInt (recMotivesN recVal)),
        ("minors", TrInt (recMinorsN recVal)),
        ("indices", TrInt (recIndicesN recVal))
      ]

  unlessStuck
    (length newSpine >= expected)
    "not enough arguments for recursor"

  recArgs <- lift $ splitRecursorAppSpine recVal newSpine

  lift $
    traceEvent
      PhReduce
      TkWHNF
      TraceDetail
      "recursor.major.whnf"
      [("recursor", TrName recName)]

  whnfMajor <- lift $ whnf depth (recMajor recArgs)
  normalizedMajor <- lift $ expandLiteralCtor whnfMajor

  case normalizedMajor of
    VNeutral (HConst ctorName _) ctorSpine ->
      reduceRecursorCtor depth recName recLvls recVal recArgs ctorName ctorSpine
    _
      | recKRule recVal ->
          reduceRecursorK depth recName recVal recArgs normalizedMajor
      | otherwise ->
          stuck "K-rule not enabled for this recursor"

reduceRecursorCtor ::
  Int ->
  HCName ->
  [HCLevel] ->
  RecursorVal HCExpr HCLevel ->
  RecursorAppSpine ->
  HCName ->
  Spine ->
  ReduceM Value
reduceRecursorCtor depth recName recLvls recVal recArgs ctorName ctorSpine = do
  lift $
    traceEvent
      PhReduce
      TkDecision
      TraceDetail
      "recursor.major.constructor"
      [ ("recursor", TrName recName),
        ("ctor", TrName ctorName),
        ("ctorSpineLen", TrInt (length ctorSpine))
      ]

  mRule <-
    lift $
      (Just <$> lookupValidatedRecursorRule recName ctorName)
        `catchError` \err -> do
          traceFail
            PhReduce
            TkLookup
            TraceDetail
            "recursor.rule.missing"
            [ ("recursor", TrName recName),
              ("ctor", TrName ctorName),
              ("error", TrString err)
            ]
          pure Nothing

  rule <- fromMaybeStuck "no matching constructor rule for recursor" mRule

  lift $
    traceProgress
      PhReduce
      TkReduction
      TraceDetail
      "recursor.iota"
      [ ("recursor", TrName recName),
        ("ctor", TrName ctorName)
      ]

  fieldsRev <- lift $ constructorFieldsForRecursor rule ctorSpine

  let subst = zip (constLevelParameters (recConst recVal)) recLvls

  rhsExpr <- lift $ instantiateLevelParamsExpr subst (recRhs rule)
  rhsVal <- lift $ evalM [] rhsExpr

  lift $
    traceEvent
      PhReduce
      TkSpine
      TraceDetail
      "recursor.rhs.apply"
      [ ("ruleArgs", TrInt (length (recRuleArgsRev recArgs))),
        ("fields", TrInt (length fieldsRev)),
        ("extra", TrInt (length (recExtraRev recArgs)))
      ]

  val1 <- lift $ applyElimsM depth rhsVal (recRuleArgsRev recArgs)
  val2 <- lift $ applyElimsM depth val1 fieldsRev
  lift $ applyElimsM depth val2 (recExtraRev recArgs)

reduceRecursorK ::
  Int ->
  HCName ->
  RecursorVal HCExpr HCLevel ->
  RecursorAppSpine ->
  Value ->
  ReduceM Value
reduceRecursorK depth recName recVal recArgs major =
  ExceptT
    $ traceBlock
      PhReduce
      TkReduction
      TraceDetail
      "recursor.k"
      [("recursor", TrName recName)]
    $ runExceptT
    $ do
      majorType <- lift $ inferValue depth major
      whnfMajorType <- lift $ whnf depth majorType
      targetInductive <- lift $ lookupValidatedRecursorTargetInductive recName

      case whnfMajorType of
        VNeutral (HConst indName indLvls) indSpine
          | indName == targetInductive -> do
              mInfo <- lift $ lookupConstInfo indName
              indVal <- case mInfo of
                Just (InductInfo indVal) -> pure indVal
                _ -> stuck "failed to lookup inductive"

              reduceKForInductive
                depth
                targetInductive
                indVal
                indLvls
                indSpine
                recVal
                recArgs
        _ -> stuck "K-rule reduction not applicable: major premise type is not target inductive"

reduceKForInductive ::
  Int ->
  HCName ->
  InductiveVal HCExpr HCLevel ->
  [HCLevel] ->
  Spine ->
  RecursorVal HCExpr HCLevel ->
  RecursorAppSpine ->
  ReduceM Value
reduceKForInductive depth targetInductive indVal indLvls indSpine recVal recArgs = do
  indParts <- lift $ splitInductiveAppSpine indVal indSpine

  paramVals <- lift $ appValuesForward "k.params" (indParamsRevPart indParts)

  actualIndexVals <- lift $ appValuesForward "k.actualIndices" (indIndicesRevPart indParts)

  ctorName <- case indCtors indVal of
    [ctorName] -> pure ctorName
    _ -> stuck "K-rule expected exactly one constructor"

  mCtorInfo <- lift $ lookupConstInfo ctorName
  ctorVal <- case mCtorInfo of
    Just (CtorInfo ctorVal) ->
      pure ctorVal
    _ -> stuck "failed to lookup constructor"

  let subst = zip (constLevelParameters (ctorConst ctorVal)) indLvls

  ctorTypeExpr <- lift $ instantiateLevelParamsExpr subst (constType (ctorConst ctorVal))
  ctorTypeVal <- lift $ evalM [] ctorTypeExpr

  ctorTyAfterParams <- lift $ foldM (instantiatePi depth) ctorTypeVal paramVals
  whnfCtorTy <- lift $ whnf depth ctorTyAfterParams

  cSpine <-
    case whnfCtorTy of
      VNeutral (HConst indName2 _) cSpine
        | indName2 == targetInductive -> pure cSpine
      _ -> stuck "constructor type did not reduce to expected form"

  ctorIndParts <- lift $ splitInductiveAppSpine indVal cSpine

  ctorIndexVals <- lift $ appValuesForward "k.ctorIndices" (indIndicesRevPart ctorIndParts)

  when (length actualIndexVals /= length ctorIndexVals) $
    lift $
      throwError "K-rule index arity mismatch"

  indicesMatch <- lift $ and <$> zipWithM (isDefEqValue depth) actualIndexVals ctorIndexVals

  unlessStuck indicesMatch "constructor indices did not match major premise indices"

  minor <- lift $ recursorSingleMinor recVal recArgs

  lift $ applyElimsM depth minor (recExtraRev recArgs)

--------------------------------------------------------------------------------

reduceProjection ::
  HCName ->
  Int ->
  HCName ->
  Spine ->
  ReduceM Value
reduceProjection structName fieldIdx headName ctorSpineRev = do
  (indVal, ctorVal) <- lookupStructureConstructor structName `catchEKernelAsStuck` "projection structure constructor not found"

  let expectedCtor = constName (ctorConst ctorVal)

  when (headName /= expectedCtor) $
    stuck "head is not the structure constructor"

  when (indIndicesN indVal /= 0) $
    stuck "projection iota expected a structure with no indices"

  parts <- splitConstructorAppSpine ctorVal ctorSpineRev `catchEKernelAsStuck` "malformed constructor spine for projection"

  lift $ constructorFieldValue fieldIdx parts

--------------------------------------------------------------------------------

-- | Push an elimination onto a WHNF Value
applyElimM :: Int -> Value -> Elim -> KernelM Value
applyElimM depth val elim = traceBlock PhReduce TkReduction TraceSummary "apply.elim" [("depth", TrInt depth), ("value", TrValueHead val), ("elim", TrElim elim)] $
  case (val, elim) of
    -- Beta reduction
    (VLam _ _ _ (Closure env body), EApp argVal) -> do
      traceProgress PhReduce TkReduction TraceDetail "beta.reduce" [("arg", TrValueHead argVal)]
      evalM (argVal : env) body
    -- Projection reduction
    (VNeutral (HConst ctorName ctorLvls) spine, EProj structName projIdx) -> do
      let newSpine = EProj structName projIdx : spine
      runReduction ctorName ctorLvls newSpine $
        reduceProjection structName projIdx ctorName spine
    -- Iota reduction
    (VNeutral (HConst headName lvls) spine, _) -> do
      let newSpine = elim : spine
      runReduction headName lvls newSpine $
        reduceNeutralConst depth headName lvls newSpine
    ((VNeutral head spine), elim) -> do
      traceEvent PhReduce TkSpine TraceDetail "neutral.spine.push" [("head", TrHead head), ("oldLen", TrInt (length spine)), ("newLen", TrInt (length spine + 1))]
      pure $ VNeutral head (elim : spine)
    ((VDef name levels spine), elim) -> do
      traceEvent PhReduce TkSpine TraceDetail "vdef.spine.push" [("const", TrName name), ("oldLen", TrInt (length spine)), ("newLen", TrInt (length spine + 1))]
      let newSpine = elim : spine
      pure $ VDef name levels newSpine
    _ -> do
      traceFail PhReduce TkFailure TraceSummary "apply.illtyped" [("value", TrValueHead val), ("elim", TrElim elim)]
      throwError "Ill-typed application"

applyElimsM :: Int -> Value -> Spine -> KernelM Value
applyElimsM depth baseVal spine =
  traceBlock PhReduce TkSpine TraceDetail "spine.apply.rev" [("depth", TrInt depth), ("base", TrValueHead baseVal), ("spineLen", TrInt (length spine))] $
    foldM (applyElimM depth) baseVal (reverse spine)

unfoldVDefOne :: Int -> HCName -> [HCLevel] -> Spine -> KernelM Value
unfoldVDefOne depth name levels spineRev =
  traceBlock
    PhDefEq
    TkUnfold
    TraceDetail
    "defeq.vdef.unfold.one"
    [ ("const", TrName name),
      ("levels", TrDoc (ppr levels)),
      ("spineLen", TrInt (length spineRev))
    ]
    $ do
      mInfo <- lookupConstInfo name
      case mInfo of
        Just (DefnInfo def) -> do
          let subst = zip (constLevelParameters (defConst def)) levels
          bodyExpr <- instantiateLevelParamsExpr subst (defValue def)
          traceEvent
            PhDefEq
            TkUnfold
            TraceDump
            "defeq.vdef.unfold.bodyExpr"
            [("body", TrExpr bodyExpr)]
          bodyVal <- evalM [] bodyExpr
          traceEvent
            PhDefEq
            TkUnfold
            TraceDetail
            "defeq.vdef.unfold.bodyVal"
            [("body", TrValueHead bodyVal)]
          result <- applyElimsM depth bodyVal spineRev
          traceEvent
            PhDefEq
            TkUnfold
            TraceDetail
            "defeq.vdef.unfold.result"
            [("result", TrValueHead result)]
          traceEvent
            PhDefEq
            TkUnfold
            TraceDump
            "defeq.vdef.unfold.result.full"
            [("result", TrValue result)]
          pure result
        _ ->
          throwError $ "unfoldVDefOne: VDef head is not a transparent definition: " <> toString name

unfoldVDefsByHint :: Int -> Value -> Value -> KernelM Bool
unfoldVDefsByHint depth lhs rhs =
  case (lhs, rhs) of
    (VDef n1 lvls1 s1, VDef n2 lvls2 s2) -> do
      hint1 <- getDefHints n1
      hint2 <- getDefHints n2
      case hint1 `compare` hint2 of
        LT -> do
          if hint1 == Opaque
            then do
              traceFail
                PhDefEq
                TkUnfold
                TraceSummary
                "defeq.vdef.opaque.lhs"
                [("const", TrName n1)]
              pure False
            else do
              traceEvent
                PhDefEq
                TkUnfold
                TraceDetail
                "defeq.vdef.unfold.lhs"
                [ ("const", TrName n1),
                  ("hint", TrDoc (ppr hint1))
                ]
              lhs' <- unfoldVDefOne depth n1 lvls1 s1
              isDefEqValue depth lhs' rhs
        GT -> do
          if hint2 == Opaque
            then do
              traceFail
                PhDefEq
                TkUnfold
                TraceSummary
                "defeq.vdef.opaque.rhs"
                [("const", TrName n2)]
              pure False
            else do
              traceEvent
                PhDefEq
                TkUnfold
                TraceDetail
                "defeq.vdef.unfold.rhs"
                [ ("const", TrName n2),
                  ("hint", TrDoc (ppr hint2))
                ]
              rhs' <- unfoldVDefOne depth n2 lvls2 s2
              isDefEqValue depth lhs rhs'
        EQ -> do
          if hint1 == Opaque
            then do
              traceFail
                PhDefEq
                TkUnfold
                TraceSummary
                "defeq.vdef.opaque.both"
                [ ("lhs", TrName n1),
                  ("rhs", TrName n2)
                ]
              pure False
            else do
              traceEvent
                PhDefEq
                TkUnfold
                TraceDetail
                "defeq.vdef.unfold.both"
                [ ("lhs", TrName n1),
                  ("rhs", TrName n2),
                  ("hint", TrDoc (ppr hint1))
                ]
              lhs' <- unfoldVDefOne depth n1 lvls1 s1
              rhs' <- unfoldVDefOne depth n2 lvls2 s2
              isDefEqValue depth lhs' rhs'
    (VDef n lvls s, _) -> do
      hint <- getDefHints n
      if hint == Opaque
        then do
          traceFail
            PhDefEq
            TkUnfold
            TraceSummary
            "defeq.vdef.opaque.lhs"
            [("const", TrName n)]
          pure False
        else do
          traceEvent
            PhDefEq
            TkUnfold
            TraceDetail
            "defeq.vdef.unfold.lhs"
            [ ("const", TrName n),
              ("hint", TrDoc (ppr hint))
            ]
          lhs' <- unfoldVDefOne depth n lvls s
          isDefEqValue depth lhs' rhs
    (_, VDef n lvls s) -> do
      hint <- getDefHints n
      if hint == Opaque
        then do
          traceFail
            PhDefEq
            TkUnfold
            TraceSummary
            "defeq.vdef.opaque.rhs"
            [("const", TrName n)]
          pure False
        else do
          traceEvent
            PhDefEq
            TkUnfold
            TraceDetail
            "defeq.vdef.unfold.rhs"
            [ ("const", TrName n),
              ("hint", TrDoc (ppr hint))
            ]
          rhs' <- unfoldVDefOne depth n lvls s
          isDefEqValue depth lhs rhs'
    _ -> error "unfoldVDefsByHint called without VDef"

-- | Expose the weak-head form of a semantic value.
--
-- This only has work to do for 'VDef'. Other 'Value' constructors are treated
-- as already head-exposed by kernel convention.
--
-- This convention relies on applications/projections being built through
-- 'applyElimM', which attempts beta/iota/projection reductions before
-- constructing stuck neutrals.
whnf :: Int -> Value -> KernelM Value
whnf depth v = case v of
  VDef name lvls spineRev -> do
    traceBlock
      PhReduce
      TkWHNF
      TraceSummary
      "whnf.vdef"
      [ ("const", TrName name),
        ("spineLen", TrInt (length spineRev))
      ]
      $ do
        v' <- unfoldVDefOne depth name lvls spineRev
        whnf depth v'
  _ -> pure v

--------------------------------------------------------------------------------

isPropType :: Int -> Value -> KernelM Bool
isPropType depth ty = do
  tySort <- inferValue depth ty
  whnfTySort <- whnf depth tySort
  zero <- mkLevelZero
  case whnfTySort of
    VSort lvl -> pure (lvl == zero || levelEquiv lvl zero)
    _ -> pure False

-- | Compare two values at a known expected type.
isDefEqValueAt :: Int -> Value -> Value -> Value -> KernelM Bool
isDefEqValueAt depth expectedTy v1 v2 = do
  same <- isDefEqValue depth v1 v2
  if same
    then pure True
    else do
      isProp <- isPropType depth expectedTy
      if isProp
        then do
          traceOk
            PhDefEq
            TkCompare
            TraceSummary
            "defeq.proofIrrelevance"
            [("expectedType", TrValueHead expectedTy)]
          pure True
        else
          pure False

--------------------------------------------------------------------------------

isDefEqValue :: Int -> Value -> Value -> KernelM Bool
isDefEqValue depth val1 val2 = traceBlock PhDefEq TkCompare TraceSummary "defeq.value" [("depth", TrInt depth), ("lhs", TrValueHead val1), ("rhs", TrValueHead val2)] $ do
  traceEvent PhDefEq TkCompare TraceDump "defeq.value.full" [("lhs", TrValue val1), ("rhs", TrValue val2)]
  case (val1, val2) of
    (VSort l1, VSort l2) -> do
      let eq = l1 == l2 || levelEquiv l1 l2
      if eq
        then traceOk PhDefEq TkCompare TraceSummary "defeq.levels" [("lhs", TrLevel l1), ("rhs", TrLevel l2)]
        else traceFail PhDefEq TkCompare TraceSummary "defeq.levels" [("lhs", TrLevel l1), ("rhs", TrLevel l2)]
      pure eq
    (VLit lit1, VLit lit2) -> do
      let eq = lit1 == lit2
      if eq
        then traceOk PhDefEq TkCompare TraceSummary "defeq.literals" [("lhs", TrDoc (ppr lit1)), ("rhs", TrDoc (ppr lit2))]
        else traceFail PhDefEq TkCompare TraceSummary "defeq.literals" [("lhs", TrDoc (ppr lit1)), ("rhs", TrDoc (ppr lit2))]
      pure eq
    _ -> do
      val1 <- expandLiteralCtor val1
      val2 <- expandLiteralCtor val2
      z1 <- tryZeta val1
      case z1 of
        Just u1 -> do
          traceProgress PhDefEq TkReduction TraceDetail "zeta.lhs" [("level", TrValueHead val1)]
          isDefEqValue depth u1 val2
        Nothing -> do
          z2 <- tryZeta val2
          case z2 of
            Just u2 -> do
              traceProgress PhDefEq TkReduction TraceDetail "zeta.rhs" [("level", TrValueHead val2)]
              isDefEqValue depth val1 u2
            Nothing -> matchCore val1 val2
  where
    tryZeta :: Value -> KernelM (Maybe Value)
    tryZeta (VNeutral (HLvl _ lvl) s) = do
      mDecl <- lookupLocalValue lvl
      case mDecl of
        Just letVal -> Just <$> applyElimsM depth letVal s
        Nothing -> pure Nothing
    tryZeta _ = pure Nothing

    matchCore :: Value -> Value -> KernelM Bool
    matchCore v1 v2 = case (v1, v2) of
      (VLam n1 _ ty1 clo1, VLam _ _ ty2 clo2) -> do
        traceEvent PhDefEq TkCompare TraceDetail "defeq.lam.domains" [("binder", TrName n1)]
        typesEq <- isDefEqValue depth ty1 ty2
        if not typesEq
          then do
            traceFail PhDefEq TkCompare TraceSummary "defeq.lam.domainMismatch" [("binder", TrName n1)]
            pure False
          else do
            let levelVal = VNeutral (HLvl n1 depth) []
            let decl = LocalDecl n1 ty1 Nothing
            withLocalDecl depth decl $ do
              body1 <- evalM (levelVal : closureEnv clo1) (closureBody clo1)
              body2 <- evalM (levelVal : closureEnv clo2) (closureBody clo2)
              traceEvent
                PhDefEq
                TkCompare
                TraceDetail
                "defeq.lam.body"
                [ ("binder", TrName n1),
                  ("nextDepth", TrInt (depth + 1)),
                  ("lhsBody", TrValueHead body1),
                  ("rhsBody", TrValueHead body2)
                ]
              bodyEq <- isDefEqValue (depth + 1) body1 body2
              if bodyEq
                then pure True
                else do
                  traceFail
                    PhDefEq
                    TkCompare
                    TraceSummary
                    "defeq.lam.bodyMismatch"
                    [ ("binder", TrName n1),
                      ("nextDepth", TrInt (depth + 1)),
                      ("lhsBody", TrValueHead body1),
                      ("rhsBody", TrValueHead body2)
                    ]
                  traceEvent
                    PhDefEq
                    TkCompare
                    TraceDump
                    "defeq.lam.bodyMismatch.full"
                    [ ("lhsBody", TrValue body1),
                      ("rhsBody", TrValue body2)
                    ]
                  pure False
      (VPi n1 _ ty1 clo1, VPi _ _ ty2 clo2) -> do
        traceEvent PhDefEq TkCompare TraceDetail "defeq.pi.domains" [("binder", TrName n1)]
        typesEq <- isDefEqValue depth ty1 ty2
        if not typesEq
          then do
            traceFail PhDefEq TkCompare TraceSummary "defeq.pi.domainMismatch" [("binder", TrName n1)]
            pure False
          else do
            let levelVal = VNeutral (HLvl n1 depth) []
            let decl = LocalDecl n1 ty1 Nothing
            withLocalDecl depth decl $ do
              body1 <- evalM (levelVal : closureEnv clo1) (closureBody clo1)
              body2 <- evalM (levelVal : closureEnv clo2) (closureBody clo2)
              traceEvent
                PhDefEq
                TkCompare
                TraceDetail
                "defeq.pi.body"
                [ ("binder", TrName n1),
                  ("nextDepth", TrInt (depth + 1)),
                  ("lhsBody", TrValueHead body1),
                  ("rhsBody", TrValueHead body2)
                ]
              bodyEq <- isDefEqValue (depth + 1) body1 body2
              if bodyEq
                then pure True
                else do
                  traceFail
                    PhDefEq
                    TkCompare
                    TraceSummary
                    "defeq.pi.bodyMismatch"
                    [ ("binder", TrName n1),
                      ("nextDepth", TrInt (depth + 1)),
                      ("lhsBody", TrValueHead body1),
                      ("rhsBody", TrValueHead body2)
                    ]
                  traceEvent
                    PhDefEq
                    TkCompare
                    TraceDump
                    "defeq.pi.bodyMismatch.full"
                    [ ("lhsBody", TrValue body1),
                      ("rhsBody", TrValue body2)
                    ]
                  pure False
      (VNeutral h1 s1, VNeutral h2 s2)
        | isDefEqHead h1 h2 -> do
            traceEvent
              PhDefEq
              TkSpine
              TraceDetail
              "defeq.neutral.sameHead"
              [ ("head", TrHead h1),
                ("lhsLen", TrInt (length s1)),
                ("rhsLen", TrInt (length s2))
              ]
            isDefEqHeadSpine depth h1 s1 s2
      (VDef n1 lvls1 s1, VDef n2 lvls2 s2) -> do
        sameHeadAndSpine <-
          if n1 == n2 && levelsEquiv lvls1 lvls2
            then isDefEqHeadSpine depth (HConst n1 lvls1) s1 s2 `catchError` \_ -> pure False
            else pure False
        if sameHeadAndSpine
          then do
            traceOk
              PhDefEq
              TkCompare
              TraceSummary
              "defeq.vdef.sameHeadSpine"
              [ ("const", TrName n1),
                ("spineLen", TrInt (length s1))
              ]
            pure True
          else
            unfoldVDefsByHint depth v1 v2
      (VDef {}, _) -> unfoldVDefsByHint depth v1 v2
      (_, VDef {}) -> unfoldVDefsByHint depth v1 v2
      (VLam n _ ty clo, other) -> checkEta depth n ty clo other
      (other, VLam n _ ty clo) -> checkEta depth n ty clo other
      (VNeutral (HConst c1 _) s1, other) -> do
        traceEvent PhEta TkDecision TraceDetail "eta.struct.lhs" [("ctor", TrName c1), ("spineLen", TrInt (length s1))]
        checkStructEta depth c1 s1 other `catchError` \e -> do
          traceFail PhEta TkError TraceSummary "eta.struct.lhs.error" [("ctor", TrName c1), ("error", TrString e)]
          pure False
      (other, VNeutral (HConst c2 _) s2) -> do
        traceEvent PhEta TkDecision TraceDetail "eta.struct.rhs" [("ctor", TrName c2), ("spineLen", TrInt (length s2))]
        checkStructEta depth c2 s2 other `catchError` \e -> do
          traceFail PhEta TkError TraceSummary "eta.struct.rhs.error" [("ctor", TrName c2), ("error", TrString e)]
          pure False
      _ -> do
        traceFail PhDefEq TkFallback TraceSummary "defeq.noRule" [("lhs", TrValueHead v1), ("rhs", TrValueHead v2)]
        pure False

--------------------------------------------------------------------------------

-- | Reconstructs the semantic environment for a given depth.
-- This guarantees that when a synthesized Closure is evaluated,
-- quoted BVars map back to their correct levels.
reconstructEnv :: Int -> KernelM LocalEnv
reconstructEnv d = do
  ctx <- asks checkLocalCtx
  -- Create a VNeutral for every level from 0 to d-1
  let mkVal lvl = case IntMap.lookup lvl ctx of
        Just decl -> pure $ VNeutral (HLvl (localName decl) lvl) []
        Nothing -> throwError $ "reconstructEnv: no local declaration found for level " ++ show lvl
  mapM mkVal $ reverse [0 .. d - 1]

inferValue :: Int -> Value -> KernelM Value
inferValue depth val = traceBlock PhInfer TkEnter TraceSummary "infer.value" [("depth", TrInt depth), ("value", TrValueHead val)] $ case val of
  VSort lvl -> VSort <$> mkLevelSucc lvl
  VLit (NatVal _) -> do
    name <- withIntern $ internName $ simpleName "Nat"
    con <- mkConst name []
    evalM [] con
  VLit (StrVal _) -> do
    name <- withIntern $ internName $ simpleName "String"
    con <- mkConst name []
    evalM [] con
  VPi name _ dom clo -> do
    domTy <- inferValue depth dom
    let levelVal = VNeutral (HLvl name depth) []
    let decl = LocalDecl name dom Nothing
    withLocalDecl depth decl $ do
      bodyVal <- evalM (levelVal : closureEnv clo) (closureBody clo)
      bodyTy <- inferValue (depth + 1) bodyVal
      case (domTy, bodyTy) of
        (VSort l1, VSort l2) -> VSort <$> (mkLevelIMax l1 l2)
        _ -> throwError "Pi type domain or codomain is not a Sort"
  VLam name bi dom clo -> do
    let levelVal = VNeutral (HLvl name depth) []
    let decl = LocalDecl name dom Nothing
    withLocalDecl depth decl $ do
      bodyVal <- evalM (levelVal : closureEnv clo) (closureBody clo)
      bodyTy <- inferValue (depth + 1) bodyVal
      bodyTyExpr <- quote (depth + 1) bodyTy
      --
      qenv <- reconstructEnv depth
      pure $ VPi name bi dom (Closure qenv bodyTyExpr)
  VNeutral head spine -> inferHeadApp depth head spine
  VDef name lvls spine -> inferHeadApp depth (HConst name lvls) spine

ensureSort :: Int -> Value -> KernelM HCLevel
ensureSort depth val = traceBlock PhInfer TkDecision TraceSummary "ensure.sort" [("value", TrValueHead val)] $ do
  whnfVal <- whnf depth val
  case whnfVal of
    VSort lvl -> do
      traceOk PhInfer TkDecision TraceSummary "ensure.sort.ok" [("level", TrLevel lvl)]
      pure lvl
    _ -> do
      traceFail PhInfer TkDecision TraceSummary "ensure.sort.fail" [("value", TrValueHead whnfVal)]
      throwError "Expected a Sort"

ensurePi :: Int -> Value -> KernelM (HCName, BinderInfo, Value, Closure)
ensurePi depth val = traceBlock PhInfer TkDecision TraceSummary "ensure.pi" [("value", TrValueHead val)] $ do
  whnfVal <- whnf depth val
  case whnfVal of
    VPi n bi ty clo -> do
      traceOk PhInfer TkDecision TraceSummary "ensure.pi.ok" [("binder", TrName n)]
      pure (n, bi, ty, clo)
    _ -> do
      traceFail PhInfer TkDecision TraceSummary "ensure.pi.fail" [("value", TrValueHead whnfVal)]
      throwError "Expected a Pi (Forall) type"

expandLiteralCtor :: Value -> KernelM Value
expandLiteralCtor v = case v of
  VLit (NatVal n) -> expandNatLitCtor n
  _ -> pure v

expandNatLitCtor :: Natural -> KernelM Value
expandNatLitCtor n
  | n < 0 = throwError "expandNatLitCtor: negative Nat literal"
  | n == 0 = do
      zero <- withIntern $ internName $ Name (Str (simpleName "Nat") "zero")
      pure $ VNeutral (HConst zero []) []
  | otherwise = do
      succ <- withIntern $ internName $ Name (Str (simpleName "Nat") "succ")
      pure $ VNeutral (HConst succ []) [EApp (VLit (NatVal (n - 1)))]

inferExpr :: Int -> LocalEnv -> HCExpr -> KernelM Value
inferExpr depth env expr = traceBlock PhInfer TkEnter TraceSummary "infer.expr" [("depth", TrInt depth), ("expr", TrExpr expr), ("envLen", TrInt (length env))] $ case hceVal expr of
  Sort lvl -> VSort <$> mkLevelSucc lvl
  Lit (NatVal _) -> do
    name <- withIntern $ internName $ simpleName "Nat"
    con <- mkConst name []
    evalM [] con
  Lit (StrVal _) -> do
    name <- withIntern $ internName $ simpleName "String"
    con <- mkConst name []
    evalM [] con
  BVar idx -> do
    if idx < 0 || idx >= depth
      then throwError $ "De Bruijn index out of bounds: " ++ show idx
      else do
        let lvl = depth - 1 - idx
        traceEvent PhInfer TkLookup TraceDetail "infer.bvar" [("index", TrInt idx), ("level", TrInt lvl)]
        lookupLocalType lvl
  Const name levels -> do
    traceEvent PhLookup TkLookup TraceDetail "infer.const.lookup" [("const", TrName name), ("levels", TrDoc (ppr levels))]
    mInfo <- lookupConstInfo name
    case mInfo of
      Just info -> do
        let subst = zip (constLevelParameters (constantInfoConst info)) levels
        instTypeExpr <- instantiateLevelParamsExpr subst (constType (constantInfoConst info))
        evalM [] instTypeExpr
      Nothing -> throwError "Unknown constant"
  App fn arg -> do
    traceEvent PhInfer TkEvent TraceDetail "infer.app.fnType" []
    fnTypeVal <- inferExpr depth env fn
    (_, _, domTypeVal, clo) <- ensurePi depth fnTypeVal
    traceEvent PhInfer TkEvent TraceDetail "infer.app.arg" []
    argVal <- evalM env arg
    argTypeVal <- inferValue depth argVal
    traceEvent PhDefEq TkCompare TraceDetail "infer.app.checkArg" [("argType", TrValueHead argTypeVal), ("domain", TrValueHead domTypeVal)]
    isArgTypeOk <- traceBlock
      PhInfer
      TkCompare
      TraceSummary
      "infer.app.argDefEq"
      [ ("depth", TrInt depth),
        ("argType", TrValueHead argTypeVal),
        ("domain", TrValueHead domTypeVal)
      ]
      $ do
        traceEvent
          PhInfer
          TkCompare
          TraceDump
          "infer.app.argDefEq.full"
          [ ("argType", TrValue argTypeVal),
            ("domain", TrValue domTypeVal)
          ]
        isDefEqValue depth argTypeVal domTypeVal
    if not isArgTypeOk
      then do
        traceFail PhInfer TkFailure TraceSummary "infer.app.argMismatch" [("argType", TrValueHead argTypeVal), ("domain", TrValueHead domTypeVal)]
        traceEvent PhInfer TkEvent TraceDump "infer.app.argMismatch.full" [("argType", TrValue argTypeVal), ("domain", TrValue domTypeVal)]
        debugQuoteValue depth "infer.app.argMismatch.argType.normalized" argTypeVal
        debugQuoteValue depth "infer.app.argMismatch.domain.normalized" domTypeVal
        throwError "Argument type mismatch"
      else do
        traceOk PhInfer TkDecision TraceSummary "infer.app.ok" [("domain", TrValueHead domTypeVal)]
        evalM (argVal : closureEnv clo) (closureBody clo)
  Lam name dom body bi -> do
    traceEvent PhInfer TkEvent TraceDetail "infer.lam.domain" [("binder", TrName name)]
    -- Infer the type of the domain type, and ensure it's a sort
    domTypeSort <- inferExpr depth env dom
    _ <- ensureSort depth domTypeSort
    -- Evaluate the domain type
    domTypeVal <- evalM env dom
    let decl = LocalDecl name domTypeVal Nothing
    let levelVal = VNeutral (HLvl name depth) []
    traceEvent PhLocalCtx TkEnter TraceDetail "infer.lam.body" [("binder", TrName name), ("level", TrInt depth)]
    -- Infer the body at depth + 1 (as the number of in-scope locals increases by one) with new local decl at level = depth
    bodyTypeVal <- withLocalDecl depth decl $ inferExpr (depth + 1) (levelVal : env) body
    -- Quote the body type to get a syntax-level expression that we can put in the closure
    bodyTypeExpr <- quote (depth + 1) bodyTypeVal
    pure $ VPi name bi domTypeVal (Closure env bodyTypeExpr)
  ForallE name dom body _ -> do
    traceEvent PhInfer TkEvent TraceDetail "infer.pi.domain" [("binder", TrName name)]
    domTypeSort <- inferExpr depth env dom
    whnfDomTypeSort <- whnf depth domTypeSort
    lvl1 <- ensureSort depth whnfDomTypeSort
    domTypeVal <- evalM env dom
    let decl = LocalDecl name domTypeVal Nothing
    let levelVal = VNeutral (HLvl name depth) []
    traceEvent PhLocalCtx TkEnter TraceDetail "infer.pi.codomain" [("binder", TrName name), ("level", TrInt depth)]
    bodyTypeVal <- withLocalDecl depth decl $ inferExpr (depth + 1) (levelVal : env) body
    lvl2 <- ensureSort depth bodyTypeVal
    traceEvent PhInfer TkEvent TraceDetail "infer.pi.imax" [("domainLevel", TrLevel lvl1), ("codomainLevel", TrLevel lvl2)]
    imaxLvl <- mkLevelIMax lvl1 lvl2
    pure $ VSort imaxLvl
  Let name dom value body nondep -> do
    traceEvent PhInfer TkEvent TraceDetail "infer.let.type" [("name", TrName name)]
    domTypeSort <- inferExpr depth env dom
    _ <- ensureSort depth domTypeSort
    domTypeVal <- evalM env dom
    valueVal <- evalM env value
    valueTypeVal <- inferValue depth valueVal
    traceEvent PhDefEq TkCompare TraceDetail "infer.let.checkValue" [("valueType", TrValueHead valueTypeVal), ("annotated", TrValueHead domTypeVal)]
    isValueTypeOk <- isDefEqValue depth valueTypeVal domTypeVal
    if not isValueTypeOk
      then do
        traceFail PhInfer TkFailure TraceSummary "infer.let.mismatch" [("name", TrName name), ("valueType", TrValueHead valueTypeVal), ("annotated", TrValueHead domTypeVal)]
        throwError "Let-binding type mismatch"
      else do
        traceEvent PhInfer TkEvent TraceDetail "infer.let.body" [("name", TrName name)]
        let decl = LocalDecl name domTypeVal (if nondep then Nothing else Just valueVal)
        let levelVal = VNeutral (HLvl name depth) []
        withLocalDecl depth decl $ inferExpr (depth + 1) (levelVal : env) body
  Proj projName fieldIdx structExpr -> do
    traceEvent
      PhInfer
      TkEvent
      TraceDetail
      "infer.proj.struct"
      [("proj", TrName projName), ("field", TrInt fieldIdx)]

    structTyVal <- inferExpr depth env structExpr
    whnfStructTy <- whnf depth structTyVal

    case whnfStructTy of
      VNeutral (HConst indName indLvls) indSpine -> do
        structVal <- evalM env structExpr
        inferProjectionFieldTypeFromInductive
          depth
          projName
          fieldIdx
          indName
          indLvls
          indSpine
          structVal
      _ ->
        throwError "Expected an inductive type for projection"

inferProjectionFieldTypeFromInductive ::
  Int ->
  HCName ->
  Int ->
  HCName ->
  [HCLevel] ->
  Spine ->
  Value ->
  KernelM Value
inferProjectionFieldTypeFromInductive depth projName fieldIdx indName indLvls indSpine structVal = do
  (indVal, ctorVal) <- lookupStructureConstructor indName

  when (fieldIdx < 0 || fieldIdx >= ctorFieldsN ctorVal) $
    throwError "inferProjectionFieldTypeFromInductive: field index out of bounds"

  traceEvent
    PhInfer
    TkSpine
    TraceDetail
    "infer.proj.fieldType"
    [ ("inductive", TrName indName),
      ("ctor", TrName (constName (ctorConst ctorVal))),
      ("field", TrInt fieldIdx),
      ("indSpineLen", TrInt (length indSpine))
    ]

  let subst = zip (constLevelParameters (ctorConst ctorVal)) indLvls

  ctorTypeExpr <- instantiateLevelParamsExpr subst (constType (ctorConst ctorVal))
  ctorTypeVal <- evalM [] ctorTypeExpr

  paramVals <- inductiveParamValuesForward indVal indSpine
  tyAfterParams <- foldM (instantiatePi depth) ctorTypeVal paramVals

  let prevProjs = [0 .. fieldIdx - 1]
  prevProjVals <- mapM (applyElimM depth structVal . EProj projName) prevProjs

  tyAfterProjs <- foldM (instantiatePi depth) tyAfterParams prevProjVals
  (finalFieldTy, _) <- extractPiDomain depth tyAfterProjs

  pure finalFieldTy

-- | Infer the type of a Head
inferHeadType :: Int -> Head -> KernelM Value
inferHeadType depth head =
  traceBlock
    PhInfer
    TkEnter
    TraceDetail
    "infer.head.type"
    [ ("depth", TrInt depth),
      ("head", TrHead head)
    ]
    $ case head of
      HLvl _ lvl -> do
        ty <- lookupLocalType lvl
        traceOk
          PhLookup
          TkLookup
          TraceDetail
          "infer.head.type.local"
          [("level", TrInt lvl)]
        pure ty
      HConst name lvls -> do
        mInfo <- lookupConstInfo name
        case mInfo of
          Just info -> do
            let c = constantInfoConst info
                subst = zip (constLevelParameters c) lvls
            instTypeExpr <- instantiateLevelParamsExpr subst (constType c)
            tyVal <- evalM [] instTypeExpr
            traceOk
              PhLookup
              TkLookup
              TraceDetail
              "infer.head.type.const"
              [ ("const", TrName name),
                ("levels", TrDoc (ppr lvls))
              ]
            pure tyVal
          Nothing ->
            throwError "inferHeadType: unknown constant"

-- | Infer the final type of a head applied to a stored reversed spine.
inferHeadApp :: Int -> Head -> Spine -> KernelM Value
inferHeadApp depth head spine = do
  traceBlock PhInfer TkEnter TraceSummary "infer.headApp" [("depth", TrInt depth), ("head", TrHead head), ("spineLen", TrInt (length spine))] $ do
    -- Get the base type of the Head
    baseType <- inferHeadType depth head
    let baseVal = VNeutral head []
    -- Fold over the spine in reverse order (since innermost arg is last in the list)
    (finalType, _) <- foldM (applyTypeElimAndVal depth) (baseType, baseVal) (reverse spine)
    traceOk PhInfer TkSpine TraceSummary "infer.headApp.spine.ok" [("spineLen", TrInt (length spine))]
    pure finalType

isDefEqHead :: Head -> Head -> Bool
isDefEqHead h1 h2 =
  case (h1, h2) of
    (HLvl _ lvl1, HLvl _ lvl2) ->
      lvl1 == lvl2
    (HConst n1 lvls1, HConst n2 lvls2) ->
      n1 == n2 && levelsEquiv lvls1 lvls2
    _ -> False

-- | Compare two stored reversed spines under the same neutral head.
-- This walks the head type while comparing arguments,
-- so application arguments can be compared at their expected domain type.
isDefEqHeadSpine :: Int -> Head -> Spine -> Spine -> KernelM Bool
isDefEqHeadSpine depth head s1 s2 =
  traceBlock
    PhDefEq
    TkSpine
    TraceDetail
    "defeq.spine.typed"
    [ ("depth", TrInt depth),
      ("lhsLen", TrInt (length s1)),
      ("rhsLen", TrInt (length s2))
    ]
    $ do
      if length s1 /= length s2
        then pure False
        else do
          headTy <- inferHeadType depth head
          let headVal = VNeutral head []
          isDefEqSpineAt depth headTy headVal (reverse s1) (reverse s2)

-- | Pairwise typed comparison of two forward-order elimination lists.
-- For each application, this compares arguments at the current Pi domain, then advances
-- the type and value. For projections, it advances using projection typing.
isDefEqSpineAt :: Int -> Value -> Value -> [Elim] -> [Elim] -> KernelM Bool
isDefEqSpineAt depth currentTy currentVal lhs rhs =
  -- here lhs and rhs are in forward order
  case (lhs, rhs) of
    ([], []) -> pure True
    (EApp a1 : xs, EApp a2 : ys) -> do
      traceEvent
        PhDefEq
        TkSpine
        TraceDetail
        "defeq.spine.app"
        [ ("depth", TrInt depth),
          ("currentTy", TrValueHead currentTy),
          ("lhsArg", TrValueHead a1),
          ("rhsArg", TrValueHead a2)
        ]
      tyWhnf <- whnf depth currentTy
      case tyWhnf of
        VPi _ _ dom clo -> do
          traceEvent
            PhDefEq
            TkSpine
            TraceDetail
            "defeq.spine.app.domain"
            [("domain", TrValueHead dom)]
          argOk <- isDefEqValueAt depth dom a1 a2
          if not argOk
            then do
              traceFail
                PhDefEq
                TkSpine
                TraceSummary
                "defeq.spine.app.argMismatch"
                [ ("domain", TrValueHead dom),
                  ("lhsArg", TrValueHead a1),
                  ("rhsArg", TrValueHead a2)
                ]
              traceEvent
                PhDefEq
                TkSpine
                TraceDump
                "defeq.spine.app.argMismatch.full"
                [ ("domain", TrValue dom),
                  ("lhsArg", TrValue a1),
                  ("rhsArg", TrValue a2)
                ]
              pure False
            else do
              nextTy <- evalM (a1 : closureEnv clo) (closureBody clo)
              nextVal <- applyElimM depth currentVal (EApp a1)
              isDefEqSpineAt depth nextTy nextVal xs ys
        _ -> pure False
    (EProj n1 i1 : xs, EProj n2 i2 : ys)
      | n1 == n2 && i1 == i2 -> do
          r <-
            (Just <$> applyTypeElimAndVal depth (currentTy, currentVal) (EProj n1 i1))
              `catchError` \_ -> pure Nothing
          case r of
            Nothing ->
              pure False
            Just (nextTy, nextVal) ->
              isDefEqSpineAt depth nextTy nextVal xs ys
    _ -> do
      traceFail
        PhDefEq
        TkSpine
        TraceSummary
        "defeq.spine.app.nonPi"
        [("currentTy", TrValueHead currentTy)]
      pure False

-- | Step through the type by applying eliminations
applyTypeElimAndVal :: Int -> (Value, Value) -> Elim -> KernelM (Value, Value)
applyTypeElimAndVal depth (currentType, currentVal) elim = do
  typeWhnf <- whnf depth currentType
  traceEvent PhInfer TkSpine TraceDetail "infer.typeElim" [("type", TrValueHead currentType), ("elim", TrElim elim)]
  traceEvent PhInfer TkSpine TraceDump "infer.typeElim.full" [("type", TrValue currentType), ("elim", TrElim elim)]
  case (typeWhnf, elim) of
    -- When the term is applied to an argument, its type must be a Pi.
    -- We evaluate the Pi's closure using the argument.
    (VPi _ _ _ clo, EApp argVal) -> do
      nextType <- evalM (argVal : closureEnv clo) (closureBody clo)
      bextVal <- applyElimM depth currentVal elim
      pure (nextType, bextVal)
    -- When the term is projected, its type must be the Inductive Type.
    -- We look up the constructor field types.
    (VNeutral (HConst indName indLvls) indSpine, EProj projName fieldIdx) -> do
      finalFieldTy <-
        inferProjectionFieldTypeFromInductive
          depth
          projName
          fieldIdx
          indName
          indLvls
          indSpine
          currentVal
      nextVal <- applyElimM depth currentVal elim
      pure (finalFieldTy, nextVal)
    _ -> do
      traceFail PhInfer TkFailure TraceSummary "infer.typeElim.invalid" [("type", TrValueHead currentType), ("elim", TrElim elim)]
      throwError "Type Error: Applied argument to non-function, or projected non-struct"

--------------------------------------------------------------------------------

instantiatePi :: Int -> Value -> Value -> KernelM Value
instantiatePi depth piVal argVal = do
  whnfVal <- whnf depth piVal
  case whnfVal of
    VPi _ _ _ clo -> evalM (argVal : closureEnv clo) (closureBody clo)
    _ -> throwError "Expected Pi type in constructor"

extractPiDomain :: Int -> Value -> KernelM (Value, Closure)
extractPiDomain depth piVal = do
  whnfVal <- whnf depth piVal
  case whnfVal of
    VPi _ _ dom clo -> pure (dom, clo)
    _ -> throwError "Expected Pi type to extract domain"

--------------------------------------------------------------------------------

isDefEq :: HCExpr -> HCExpr -> KernelM Bool
isDefEq = isDefEq' 0 []

isDefEq' :: Int -> LocalEnv -> HCExpr -> HCExpr -> KernelM Bool
isDefEq' depth env e1 e2 =
  traceBlock
    PhDefEq
    TkCompare
    TraceSummary
    "defeq.expr"
    [ ("depth", TrInt depth),
      ("lhs", TrExpr e1),
      ("rhs", TrExpr e2)
    ]
    $ withClosedDefEqCache e1 e2
    $ isDefEqExprCore depth env e1 e2

isDefEqExprCore :: Int -> LocalEnv -> HCExpr -> HCExpr -> KernelM Bool
isDefEqExprCore depth env expr1 expr2 = traceBlock PhDefEq TkCompare TraceDetail "defeq.expr.core" [("depth", TrInt depth), ("lhs", TrExpr expr1), ("rhs", TrExpr expr2), ("envLen", TrInt (length env))] $ do
  traceEvent PhDefEq TkCompare TraceDump "defeq.expr.env" [("env", TrDoc (ppr env))]
  case () of
    () | expr1 == expr2 -> do
      traceOk PhDefEq TkCompare TraceSummary "defeq.expr.pointer" []
      pure True
    ()
      | Sort l1 <- hceVal expr1,
        Sort l2 <- hceVal expr2 -> do
          traceEvent PhDefEq TkCompare TraceDetail "defeq.expr.sorts" [("lhs", TrLevel l1), ("rhs", TrLevel l2)]
          if (l1 == l2 || levelEquiv l1 l2)
            then do
              traceOk PhDefEq TkCompare TraceSummary "defeq.expr.sorts.equiv" [("lhs", TrLevel l1), ("rhs", TrLevel l2)]
              pure True
            else do
              traceFail PhDefEq TkCompare TraceSummary "defeq.expr.sorts.notEquiv" [("lhs", TrLevel l1), ("rhs", TrLevel l2)]
              pure False
    ()
      | Const n1 lvls1 <- hceVal expr1,
        Const n2 lvls2 <- hceVal expr2,
        n1 == n2 ->
          if levelsEquiv lvls1 lvls2
            then do
              traceOk PhDefEq TkCompare TraceSummary "defeq.expr.consts" [("const", TrName n1), ("levels", TrDoc (ppr lvls1))]
              pure True
            else fallbackToWHNF "constant levels do not match."
    ()
      | Just (LetView n1 ty1 v1 b1 nd1) <- viewLet expr1,
        Just (LetView _n2 ty2 v2 b2 nd2) <- viewLet expr2 ->
          -- If nondep flags differ, do zeta
          -- lean kernel actually omits the nondep flag
          if nd1 /= nd2
            then fallbackToWHNF "Nondep flags differ."
            else do
              fastSuccess <-
                ( do
                    tEq <- isDefEq' depth env ty1 ty2
                    if not tEq
                      then pure False
                      else do
                        vEq <- isDefEq' depth env v1 v2
                        if not vEq
                          then pure False
                          else do
                            -- Everything matches
                            tyVal <- evalM env ty1
                            valVal <- evalM env v1
                            let decl = LocalDecl n1 tyVal (if nd1 then Nothing else Just valVal)
                            let levelVal = VNeutral (HLvl n1 depth) []
                            withLocalDecl depth decl $ isDefEq' (depth + 1) (levelVal : env) b1 b2
                )
                  `catchError` \_ -> pure False
              if fastSuccess then pure True else fallbackToWHNF "Let bindings differ."
    ()
      | isApp expr1 && isApp expr2,
        AppSpine fn1 args1 <- getAppSpine expr1,
        AppSpine fn2 args2 <- getAppSpine expr2,
        length args1 == length args2 -> do
          -- Try structural equality without forcing WHNF
          fastPathSuccess <-
            ( do
                fnEq <- isDefEq' depth env fn1 fn2
                if not fnEq
                  then pure False
                  else
                    and <$> zipWithM (isDefEq' depth env) args1 args2
            )
              `catchError` \_ -> pure False
          if fastPathSuccess then pure True else fallbackToWHNF "App spine differs."
    ()
      | Lam n1 ty1 b1 bi1 <- hceVal expr1,
        Lam _ ty2 b2 bi2 <- hceVal expr2,
        bi1 == bi2 -> do
          fastSuccess <-
            ( do
                tyEq <- isDefEq' depth env ty1 ty2
                if not tyEq
                  then pure False
                  else do
                    tyVal <- evalM env ty1
                    let decl = LocalDecl n1 tyVal Nothing
                    let levelVal = VNeutral (HLvl n1 depth) []
                    withLocalDecl depth decl $ isDefEq' (depth + 1) (levelVal : env) b1 b2
            )
              `catchError` \_ -> pure False
          if fastSuccess then pure True else fallbackToWHNF "Lambda bodies differ."
    ()
      | ForallE n1 ty1 b1 bi1 <- hceVal expr1,
        ForallE _ ty2 b2 bi2 <- hceVal expr2,
        bi1 == bi2 -> do
          fastSuccess <-
            ( do
                tyEq <- isDefEq' depth env ty1 ty2
                if not tyEq
                  then pure False
                  else do
                    tyVal <- evalM env ty1
                    let decl = LocalDecl n1 tyVal Nothing
                    let levelVal = VNeutral (HLvl n1 depth) []
                    withLocalDecl depth decl $ isDefEq' (depth + 1) (levelVal : env) b1 b2
            )
              `catchError` \_ -> pure False
          if fastSuccess then pure True else fallbackToWHNF "Forall bodies differ."
    () | otherwise -> fallbackToWHNF "all structural checks failed."
  where
    fallbackToWHNF reason = do
      traceEvent PhDefEq TkFallback TraceDetail "defeq.expr.fallback.whnf" [("reason", TrString reason)]
      val1 <- evalM env expr1
      val2 <- evalM env expr2
      isDefEqValue depth val1 val2

isDefEqElim :: Int -> Elim -> Elim -> KernelM Bool
isDefEqElim depth (EApp v1) (EApp v2) = isDefEqValue depth v1 v2
isDefEqElim _ (EProj n1 i1) (EProj n2 i2) = pure (n1 == n2 && i1 == i2)
isDefEqElim _ _ _ = pure False

--------------------------------------------------------------------------------

checkEta :: Int -> HCName -> Value -> Closure -> Value -> KernelM Bool
checkEta depth name ty clo otherVal = traceBlock PhEta TkCompare TraceDetail "eta.function" [("depth", TrInt depth), ("binder", TrName name), ("other", TrValueHead otherVal)] $ do
  let levelVal = VNeutral (HLvl name depth) []
  let decl = LocalDecl name ty Nothing
  withLocalDecl depth decl $ do
    body1 <- evalM (levelVal : closureEnv clo) (closureBody clo)
    body2 <- applyElimM depth otherVal (EApp levelVal)
    isDefEqValue (depth + 1) body1 body2

checkStructEta :: Int -> HCName -> Spine -> Value -> KernelM Bool
checkStructEta depth ctorName spine otherVal = traceBlock PhEta TkCompare TraceDetail "eta.structure" [("depth", TrInt depth), ("ctor", TrName ctorName), ("spineLen", TrInt (length spine)), ("other", TrValueHead otherVal)] $ do
  mInfo <- lookupConstInfo ctorName
  case mInfo of
    Just (CtorInfo ctorVal) -> do
      let indName = ctorInductive ctorVal
      traceEvent PhEta TkLookup TraceDetail "eta.structure.inductive" [("ctor", TrName ctorName), ("inductive", TrName indName)]
      mIndInfo <- lookupConstInfo indName
      case mIndInfo of
        Just (InductInfo indVal)
          | length (indCtors indVal) == 1
              && indIndicesN indVal
                == 0 -> do
              traceOk PhEta TkDecision TraceDetail "eta.structure.verified" [("inductive", TrName indName)]
              let fieldsN = ctorFieldsN ctorVal
              (fieldsRev, _) <- splitConstructorFieldsRev "eta.structure.fields" fieldsN spine
              let ctorFields = reverse fieldsRev
              traceEvent PhEta TkSpine TraceDetail "eta.structure.fields" [("fields", TrInt fieldsN), ("spineLen", TrInt (length spine))]
              ctorFieldVals <- mapM (expectApp "eta.structure.field") ctorFields
              when (length ctorFieldVals /= fieldsN) $
                throwError "eta.structure: field arity mismatch"
              let projIndices = [0 .. fieldsN - 1]
                  checkField i expectedVal = do
                    traceEvent PhEta TkCompare TraceDetail "eta.structure.field" [("field", TrInt i)]
                    projVal <- applyElimM depth otherVal (EProj indName i)
                    isDefEqValue depth expectedVal projVal
              and <$> zipWithM checkField projIndices ctorFieldVals
        _ -> do
          traceStuck PhEta TkStuck TraceSummary "eta.structure.notStructure" [("ctor", TrName ctorName), ("inductive", TrName indName)]
          pure False
    _ -> do
      traceStuck PhEta TkStuck TraceSummary "eta.structure.notCtor" [("head", TrName ctorName)]
      pure False

--------------------------------------------------------------------------------

-- | Converts a WHNF Value back into a fully normalized AST
quote :: Int -> Value -> KernelM HCExpr
quote depth val = traceBlock PhQuote TkEnter TraceSummary "quote.value" [("depth", TrInt depth), ("value", TrValueHead val)] $ do
  v <- whnf depth val
  case v of
    VSort lvl -> mkSort lvl
    VLit lit -> mkLit lit
    VLam name bi ty clo -> do
      tyExpr <- quote depth ty
      let decl = LocalDecl name ty Nothing
      let levelVal = VNeutral (HLvl name depth) []
      withLocalDecl depth decl $ do
        bodyVal <- evalM (levelVal : closureEnv clo) (closureBody clo)
        bodyExpr <- quote (depth + 1) bodyVal
        mkLam name tyExpr bodyExpr bi
    VPi name bi ty clo -> do
      tyExpr <- quote depth ty
      let decl = LocalDecl name ty Nothing
      let levelVal = VNeutral (HLvl name depth) []
      withLocalDecl depth decl $ do
        bodyVal <- evalM (levelVal : closureEnv clo) (closureBody clo)
        bodyExpr <- quote (depth + 1) bodyVal
        mkForall name tyExpr bodyExpr bi
    VNeutral head spine -> do
      headExpr <- case head of
        HLvl _ fv -> mkBVar (depth - 1 - fv)
        HConst name levels -> mkConst name levels
      traceEvent PhQuote TkEvent TraceDetail "quote.neutral.head" [("head", TrHead head), ("spineLen", TrInt (length spine))]
      foldM (quoteElim depth) headExpr (reverse spine)
    VDef _ _ _ -> throwError "Unreachable: VDef remaining after whnf"

quoteElim :: Int -> HCExpr -> Elim -> KernelM HCExpr
quoteElim depth headExpr (EApp argVal) = do
  argExpr <- quote depth argVal
  mkApp headExpr argExpr
quoteElim _ headExpr (EProj name idx) =
  mkProj name idx headExpr

--------------------------------------------------------------------------------

debugQuoteValue :: Int -> String -> Value -> KernelM ()
debugQuoteValue depth label v = do
  r <-
    (Right <$> (quote depth =<< whnf depth v))
      `catchError` \err -> pure (Left err)

  case r of
    Right e ->
      traceEvent
        PhInfer
        TkEvent
        TraceDump
        label
        [("expr", TrExpr e)]
    Left err ->
      traceEvent
        PhInfer
        TkEvent
        TraceDump
        (label <> ".failed")
        [("error", TrString err)]
