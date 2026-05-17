{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Mlkih.Kernel.Eval where

import Control.Monad (foldM, zipWithM)
import Control.Monad.Except
import Control.Monad.Reader (asks)
import qualified Data.IntMap.Strict as IntMap
import Mlkih.AST
import Mlkih.Env
import Mlkih.Expr
import Mlkih.Intern
import Mlkih.Kernel.Cache
import Mlkih.Kernel.Monad
import Mlkih.Kernel.Trace
import Mlkih.Kernel.Types
import Mlkih.Level
import Mlkih.Name
import Mlkih.Pretty

--------------------------------------------------------------------------------

evalM :: LocalEnv -> HCExpr -> KernelM Value
evalM env expr = traceBlock PhEval TkEnter TraceDetail "eval.expr" [("expr", TrExpr expr), ("envLen", TrInt (length env))] $ do
  traceEvent PhEval TkEvent TraceDump "local.env" [("env", TrDoc (ppr env))]
  case hceVal expr of
    BVar idx -> do
      traceEvent PhEval TkLookup TraceDetail "eval.bvar" [("index", TrInt idx)]
      pure $ env !! idx
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
        Just (DefnInfo def) -> do
          traceEvent PhEval TkUnfold TraceDetail "const.def.lazy" [("const", TrName name), ("levels", TrDoc (ppr levels))]
          let subst = zip (constLevelParameters (defConst def)) levels
          -- Eagerly substitute universes
          instantiatedBody <- instantiateLevelParamsExpr subst (defValue def)
          -- Suspend the evaluation of the body
          let lazyThunk = evalM [] instantiatedBody
          pure $ VDef name levels [] lazyThunk
        _ -> do
          traceStuck PhEval TkStuck TraceSummary "const.neutral" [("const", TrName name), ("levels", TrDoc (ppr levels))]
          pure $ VNeutral (HConst name levels) []

-- | Push an elimination onto a WHNF Value
applyElimM :: Int -> Value -> Elim -> KernelM Value
applyElimM depth val elim = traceBlock PhReduce TkReduction TraceSummary "apply.elim" [("depth", TrInt depth), ("value", TrValueHead val), ("elim", TrElim elim)] $
  case (val, elim) of
    (VLam _ _ _ (Closure env body), EApp argVal) -> do
      traceProgress PhReduce TkReduction TraceDetail "beta.reduce" [("arg", TrValueHead argVal)]
      evalM (argVal : env) body
    (VNeutral (HConst ctorName ctorLvls) spine, EProj structName projIdx) -> do
      let newSpine = EProj structName projIdx : spine
          fallback reason = do
            traceStuck PhReduce TkStuck TraceSummary "proj.stuck" [("ctor", TrName ctorName), ("proj", TrName structName), ("field", TrInt projIdx), ("reason", TrString reason)]
            pure $ VNeutral (HConst ctorName ctorLvls) newSpine
      mIndInfo <- lookupConstInfo structName
      case mIndInfo of
        Just (InductInfo indVal) -> do
          if not (null (indCtors indVal)) && head (indCtors indVal) == ctorName
            then do
              let numParams = indParamsN indVal
                  numFields = length spine - numParams
                  targetIdx = numFields - 1 - projIdx

              if targetIdx >= 0 && targetIdx < numFields
                then case spine !! targetIdx of
                  EApp fieldVal -> do
                    traceProgress PhReduce TkReduction TraceDetail "proj.reduce" [("ctor", TrName ctorName), ("proj", TrName structName), ("field", TrInt projIdx)]
                    pure fieldVal
                  _ -> fallback "constructor argument is not an EApp"
                else
                  fallback "projection index out of bounds"
            else
              fallback "head is not the target structure's constructor"
        _ -> fallback "projection structure inductive not found"
    ((VNeutral (HConst recName recLvls) spine), elim) -> do
      -- Iota
      let newSpine = elim : spine
          fallback reason = do
            traceStuck PhReduce TkStuck TraceSummary "neutral.stuck" [("head", TrName recName), ("reason", TrString reason), ("spineLen", TrInt (length newSpine))]
            pure $ VNeutral (HConst recName recLvls) newSpine
      mInfo <- lookupConstInfo recName
      case mInfo of
        Just (QuotInfo quotVal) | quotKind quotVal == QuotLift -> do
          traceEvent PhReduce TkDecision TraceDetail "quot.lift.try" [("const", TrName recName), ("args", TrInt (length newSpine))]
          -- hardcode quotient lifting reduction: Quot.lift f h (Quot.mk a) = f a
          -- newSpine = reverse [alpha, r, beta, f, h, major]
          if length newSpine < 6
            then fallback "not enough arguments for Quot.lift"
            else do
              let numExtra = length newSpine - 6
                  extraArgs = take numExtra newSpine
                  exactArgs = drop numExtra newSpine
              traceEvent PhReduce TkSpine TraceDetail "quot.lift.major" [("exactArgs", TrInt (length exactArgs)), ("extraArgs", TrInt (length extraArgs))]
              majorVal <- extractAppArgM 0 exactArgs
              forcedMajor <- force majorVal
              case forcedMajor of
                VNeutral (HConst mkName _) mkSpine -> do
                  mMkInfo <- lookupConstInfo mkName
                  case mMkInfo of
                    Just (QuotInfo mkVal) | quotKind mkVal == QuotMk -> do
                      traceProgress PhReduce TkReduction TraceDetail "quot.lift.reduce" [("lift", TrName recName), ("mk", TrName mkName)]
                      -- Quot.mk takes [alpha, r, a]
                      aVal <- extractAppArgM 0 mkSpine
                      fVal <- extractAppArgM 2 exactArgs
                      reduced <- applyElimM depth fVal (EApp aVal)
                      applyElimsM depth reduced extraArgs
                    _ -> fallback "major premise is not Quot.mk"
                _ -> fallback "major premise is not a stuck application"
        Just (RecInfo recVal) -> do
          let expectedArgs = recParamsN recVal + recMotivesN recVal + recMinorsN recVal + recIndicesN recVal + 1
          traceEvent PhReduce TkSpine TraceDetail "recursor.args" [("recursor", TrName recName), ("expected", TrInt expectedArgs), ("actual", TrInt (length newSpine)), ("params", TrInt (recParamsN recVal)), ("motives", TrInt (recMotivesN recVal)), ("minors", TrInt (recMinorsN recVal)), ("indices", TrInt (recIndicesN recVal))]
          if length newSpine < expectedArgs
            then fallback "not enough arguments for recursor"
            else do
              let numExtra = length newSpine - expectedArgs
              let extraArgs = take numExtra newSpine
              let exactArgs = drop numExtra newSpine
              traceEvent PhReduce TkForce TraceDetail "recursor.major.force" [("recursor", TrName recName)]
              -- Extract the major premise
              majorVal <- extractAppArgM 0 exactArgs
              forcedMajor <- force majorVal
              normalizedMajor <- expandLiteralCtor forcedMajor
              case normalizedMajor of
                VNeutral (HConst ctorName _) ctorSpine -> do
                  -- major premise is ctor
                  traceEvent PhReduce TkDecision TraceDetail "recursor.major.constructor" [("recursor", TrName recName), ("ctor", TrName ctorName), ("ctorSpineLen", TrInt (length ctorSpine))]
                  mRule <-
                    (Just <$> lookupValidatedRecursorRule recName ctorName) `catchError` \err -> do
                      traceFail PhReduce TkLookup TraceDetail "recursor.rule.missing" [("recursor", TrName recName), ("ctor", TrName ctorName), ("error", TrString err)]
                      pure Nothing
                  case mRule of
                    Just rule -> do
                      traceProgress PhReduce TkReduction TraceDetail "recursor.iota" [("recursor", TrName recName), ("ctor", TrName ctorName)]
                      -- Extract the params, motives, and minors
                      -- exactArgs (reversed AST order): [major, indices..., minors..., motives..., params...]
                      let paramsMotivesMinors = drop (1 + recIndicesN recVal) exactArgs
                      -- Extract the constructor's fields
                      -- ctorSpine (reversed): [fields..., ctorParams...]
                      let fields = take (recFieldsN rule) ctorSpine
                      -- Evaluate RHS
                      let subst = zip (constLevelParameters (recConst recVal)) recLvls
                      traceEvent PhReduce TkEvent TraceDetail "recursor.rhs.eval" [("recursor", TrName recName), ("ctor", TrName ctorName)]
                      rhsExpr <- instantiateLevelParamsExpr subst (recRhs rule)
                      rhsVal <- evalM [] rhsExpr
                      traceEvent PhReduce TkSpine TraceDetail "recursor.rhs.apply" [("paramsMotivesMinors", TrInt (length paramsMotivesMinors)), ("fields", TrInt (length fields)), ("extra", TrInt (length extraArgs))]
                      val1 <- applyElimsM depth rhsVal paramsMotivesMinors
                      val2 <- applyElimsM depth val1 fields
                      applyElimsM depth val2 extraArgs
                    _ -> fallback "no matching constructor rule for recursor"
                _ ->
                  if recKRule recVal
                    then traceBlock PhReduce TkReduction TraceDetail "recursor.k" [("recursor", TrName recName)] $ do
                      traceEvent PhReduce TkDecision TraceDetail "k.try" [("recursor", TrName recName)]
                      majorType <- inferValue depth normalizedMajor
                      forcedMajorType <- force majorType
                      targetInductive <- lookupValidatedRecursorTargetInductive recName
                      case forcedMajorType of
                        VNeutral (HConst indName indLvls) indSpine
                          | indName == targetInductive -> do
                              traceEvent PhReduce TkDecision TraceDetail "k.major.type.match" [("target", TrName targetInductive), ("indices", TrInt (recIndicesN recVal))]
                              -- indSpine (reversed): [indices..., params...]
                              let numIndices = recIndicesN recVal
                                  actualIndices = take numIndices indSpine
                                  params = drop numIndices indSpine
                              mInfo <- lookupConstInfo indName
                              case mInfo of
                                Just (InductInfo indVal) -> do
                                  let ctorName = head (indCtors indVal) -- K-like types have 1 constructor
                                  mCtorInfo <- lookupConstInfo ctorName
                                  case mCtorInfo of
                                    Just (CtorInfo ctorVal) -> do
                                      traceEvent PhReduce TkEvent TraceDetail "k.ctor.instantiate" [("ctor", TrName ctorName), ("levels", TrDoc (ppr indLvls))]
                                      let subst = zip (constLevelParameters (ctorConst ctorVal)) indLvls
                                      ctorTypeExpr <- instantiateLevelParamsExpr subst (constType (ctorConst ctorVal))
                                      ctorTypeVal <- evalM [] ctorTypeExpr
                                      traceEvent PhReduce TkSpine TraceDetail "k.ctor.params" [("params", TrInt (length params))]
                                      paramVals <- mapM extractArgM (reverse params)
                                      ctorTyAfterParams <- foldM instantiatePi ctorTypeVal paramVals
                                      forcedCtorTy <- force ctorTyAfterParams
                                      case forcedCtorTy of
                                        VNeutral (HConst indName2 _) cSpine | indName2 == targetInductive -> do
                                          traceEvent PhReduce TkSpine TraceDetail "k.ctor.indices" [("indices", TrInt numIndices)]
                                          let cIndices = take numIndices cSpine
                                          cIndexVals <- mapM extractArgM cIndices
                                          actualIndexVals <- mapM extractArgM actualIndices
                                          traceEvent PhDefEq TkCompare TraceDetail "k.indices.compare" [("indices", TrInt numIndices)]
                                          indicesMatch <- and <$> zipWithM (isDefEqValue depth) actualIndexVals cIndexVals
                                          if indicesMatch
                                            then do
                                              traceProgress PhReduce TkReduction TraceDetail "k.reduce" [("recursor", TrName recName)]
                                              let minorPremise = exactArgs !! (1 + recIndicesN recVal)
                                              case minorPremise of
                                                EApp v -> applyElimsM depth v extraArgs
                                                _ -> fallback "minor premise is not an application"
                                            else fallback "constructor indices did not match major premise indices"
                                        _ -> fallback "constructor type did not reduce to expected form"
                                    _ -> fallback "failed to lookup constructor"
                                _ -> fallback "failed to lookup inductive"
                        _ -> fallback "K-rule reduction not applicable: major premise type is not a neutral with the target inductive as head"
                    else fallback "K-rule not enabled for this recursor"
        _ -> fallback "head is not a recursor or quotient lifting constant"
    ((VNeutral head spine), elim) -> do
      traceEvent PhReduce TkSpine TraceDetail "neutral.spine.push" [("head", TrHead head), ("oldLen", TrInt (length spine)), ("newLen", TrInt (length spine + 1))]
      pure $ VNeutral head (elim : spine)
    ((VDef name levels spine thunk), elim) -> do
      traceEvent PhReduce TkSpine TraceDetail "vdef.spine.push" [("const", TrName name), ("oldLen", TrInt (length spine)), ("newLen", TrInt (length spine + 1))]
      let newSpine = elim : spine
      -- To prevent forcing the thunk immediately, we wrap the application in a new thunk
      let newThunk = do
            forcedBody <- thunk
            applyElimM depth forcedBody elim
      pure $ VDef name levels newSpine newThunk
    _ -> do
      traceFail PhReduce TkFailure TraceSummary "apply.illtyped" [("value", TrValueHead val), ("elim", TrElim elim)]
      throwError "Ill-typed application"

applyElimsM :: Int -> Value -> Spine -> KernelM Value
applyElimsM depth baseVal spine =
  traceBlock PhReduce TkSpine TraceDetail "spine.apply.rev" [("depth", TrInt depth), ("base", TrValueHead baseVal), ("spineLen", TrInt (length spine))] $
    foldM (applyElimM depth) baseVal (reverse spine)

-- | Force a VDef thunk
force :: Value -> KernelM Value
force v = case v of
  VDef n lvls spine thunk -> traceBlock PhReduce TkForce TraceSummary "force.vdef" [("const", TrName n), ("levels", TrDoc (ppr lvls)), ("spineLen", TrInt (length spine))] $ thunk >>= force
  _ -> pure v

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
      valType <- inferValue depth val1
      typeOfValType <- inferValue depth valType
      let isProp = case typeOfValType of
            VSort lvl -> getLevel lvl == LZero
            _ -> False
      if isProp
        then do
          traceOk PhDefEq TkCompare TraceSummary "defeq.proofIrrelevance" [("type", TrValueHead valType)]
          pure True
        else do
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
              isDefEqValue (depth + 1) body1 body2
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
              isDefEqValue (depth + 1) body1 body2
      (VNeutral h1 s1, VNeutral h2 s2)
        | h1 == h2 -> do
            traceEvent PhDefEq TkSpine TraceDetail "defeq.neutral.sameHead" [("head", TrHead h1), ("lhsLen", TrInt (length s1)), ("rhsLen", TrInt (length s2))]
            isDefEqSpine depth s1 s2
      (VDef n1 _ s1 _, VDef n2 _ s2 _) | n1 == n2 -> do
        match <- isDefEqSpine depth s1 s2 `catchError` \_ -> pure False
        if match
          then do
            traceOk PhDefEq TkCompare TraceSummary "defeq.vdef.sameHeadSpine" [("const", TrName n1), ("spineLen", TrInt (length s1))]
            pure True
          else do
            traceEvent PhDefEq TkForce TraceDetail "defeq.vdef.sameHead.diffSpine" [("const", TrName n1)]
            v1' <- force v1
            v2' <- force v2
            isDefEqValue depth v1' v2'
      (VDef n1 _ _ thunk1, VDef n2 _ _ thunk2) -> do
        hint1 <- getDefHints n1
        hint2 <- getDefHints n2
        case compare hint1 hint2 of
          LT -> do
            traceEvent PhDefEq TkUnfold TraceDetail "defeq.vdef.unfold.lhs" [("const", TrName n1), ("hint", TrDoc (ppr hint1))]
            v1' <- thunk1
            isDefEqValue depth v1' v2
          GT -> do
            traceEvent PhDefEq TkUnfold TraceDetail "defeq.vdef.unfold.rhs" [("const", TrName n2), ("hint", TrDoc (ppr hint2))]
            v2' <- thunk2
            isDefEqValue depth v1 v2'
          EQ -> do
            if hint1 == Opaque
              then do
                traceFail PhDefEq TkUnfold TraceSummary "defeq.vdef.opaque.both" [("lhs", TrName n1), ("rhs", TrName n2)]
                pure False
              else do
                traceEvent PhDefEq TkUnfold TraceDetail "defeq.vdef.unfold.both" [("lhs", TrName n1), ("rhs", TrName n2), ("hint", TrDoc (ppr hint1))]
                v1' <- thunk1
                v2' <- thunk2
                isDefEqValue depth v1' v2'
      (VDef n1 _ _ thunk1, _) -> do
        hint1 <- getDefHints n1
        if hint1 == Opaque
          then do
            traceFail PhDefEq TkUnfold TraceSummary "defeq.vdef.opaque.lhs" [("const", TrName n1)]
            pure False
          else do
            v1' <- thunk1
            isDefEqValue depth v1' v2
      (_, VDef n2 _ _ thunk2) -> do
        hint2 <- getDefHints n2
        if hint2 == Opaque
          then do
            traceFail PhDefEq TkUnfold TraceSummary "defeq.vdef.opaque.rhs" [("const", TrName n2)]
            pure False
          else do
            v2' <- thunk2
            isDefEqValue depth v1 v2'
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

-- | Reconstructs the semantic environment for a given depth.
-- This guarantees that when a synthesized Closure is evaluated,
-- quoted BVars map back to their correct levels.
reconstructEnv :: Int -> KernelM LocalEnv
reconstructEnv d = do
  ctx <- asks checkLocalCtx
  -- Create a VNeutral for every level from 0 to d-1
  let mkVal lvl = case IntMap.lookup lvl ctx of
        Just decl -> pure $ VNeutral (HLvl (localName decl) lvl) []
        Nothing -> throwError $ "reconstructEnv: no local declaration found for level " ++ toString lvl
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
  VDef name lvls spine _ -> inferHeadApp depth (HConst name lvls) spine

ensureSort :: Value -> KernelM HCLevel
ensureSort val = traceBlock PhInfer TkDecision TraceSummary "ensure.sort" [("value", TrValueHead val)] $ do
  forced <- force val
  case forced of
    VSort lvl -> do
      traceOk PhInfer TkDecision TraceSummary "ensure.sort.ok" [("level", TrLevel lvl)]
      pure lvl
    _ -> do
      traceFail PhInfer TkDecision TraceSummary "ensure.sort.fail" [("value", TrValueHead forced)]
      throwError "Expected a Sort"

ensurePi :: Value -> KernelM (HCName, BinderInfo, Value, Closure)
ensurePi val = traceBlock PhInfer TkDecision TraceSummary "ensure.pi" [("value", TrValueHead val)] $ do
  forced <- force val
  case forced of
    VPi n bi ty clo -> do
      traceOk PhInfer TkDecision TraceSummary "ensure.pi.ok" [("binder", TrName n)]
      pure (n, bi, ty, clo)
    _ -> do
      traceFail PhInfer TkDecision TraceSummary "ensure.pi.fail" [("value", TrValueHead forced)]
      throwError "Expected a Pi (Forall) type"

expandLiteralCtor :: Value -> KernelM Value
expandLiteralCtor v = case v of
  VLit (NatVal n) -> expandNatLitCtor n
  _ -> pure v

expandNatLitCtor :: Int -> KernelM Value
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
    (_, _, domTypeVal, clo) <- ensurePi fnTypeVal
    traceEvent PhInfer TkEvent TraceDetail "infer.app.arg" []
    argVal <- evalM env arg
    argTypeVal <- inferValue depth argVal
    traceEvent PhDefEq TkCompare TraceDetail "infer.app.checkArg" [("argType", TrValueHead argTypeVal), ("domain", TrValueHead domTypeVal)]
    isArgTypeOk <- isDefEqValue depth argTypeVal domTypeVal
    if not isArgTypeOk
      then do
        traceFail PhInfer TkFailure TraceSummary "infer.app.argMismatch" [("argType", TrValueHead argTypeVal), ("domain", TrValueHead domTypeVal)]
        traceEvent PhInfer TkEvent TraceDump "infer.app.argMismatch.full" [("argType", TrValue argTypeVal), ("domain", TrValue domTypeVal)]
        throwError "Argument type mismatch"
      else do
        traceOk PhInfer TkDecision TraceSummary "infer.app.ok" [("domain", TrValueHead domTypeVal)]
        evalM (argVal : closureEnv clo) (closureBody clo)
  Lam name dom body bi -> do
    traceEvent PhInfer TkEvent TraceDetail "infer.lam.domain" [("binder", TrName name)]
    -- Infer the type of the domain type, and ensure it's a sort
    domTypeSort <- inferExpr depth env dom
    _ <- ensureSort domTypeSort
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
    forcedDomTypeSort <- force domTypeSort
    lvl1 <- ensureSort forcedDomTypeSort
    domTypeVal <- evalM env dom
    let decl = LocalDecl name domTypeVal Nothing
    let levelVal = VNeutral (HLvl name depth) []
    traceEvent PhLocalCtx TkEnter TraceDetail "infer.pi.codomain" [("binder", TrName name), ("level", TrInt depth)]
    bodyTypeVal <- withLocalDecl depth decl $ inferExpr (depth + 1) (levelVal : env) body
    lvl2 <- ensureSort bodyTypeVal
    traceEvent PhInfer TkEvent TraceDetail "infer.pi.imax" [("domainLevel", TrLevel lvl1), ("codomainLevel", TrLevel lvl2)]
    imaxLvl <- mkLevelIMax lvl1 lvl2
    pure $ VSort imaxLvl
  Let name dom value body nondep -> do
    traceEvent PhInfer TkEvent TraceDetail "infer.let.type" [("name", TrName name)]
    domTypeSort <- inferExpr depth env dom
    _ <- ensureSort domTypeSort
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
    traceEvent PhInfer TkEvent TraceDetail "infer.proj.struct" [("proj", TrName projName), ("field", TrInt fieldIdx)]
    structTyVal <- inferExpr depth env structExpr
    forcedStructTy <- force structTyVal
    case forcedStructTy of
      VNeutral (HConst indName indLvls) indSpine -> do
        traceEvent PhInfer TkDecision TraceDetail "infer.proj.inductive" [("inductive", TrName indName), ("field", TrInt fieldIdx)]
        mInfo <- lookupConstInfo indName
        case mInfo of
          Just (InductInfo indVal) -> do
            ctor <- case indCtors indVal of
              [ctor] ->
                lookupConstInfo ctor >>= \c -> case c of
                  Just (CtorInfo ctorVal) -> pure ctorVal
                  _ -> throwError "Constructor not found in environment"
              _ -> throwError "Expected exactly one constructor for projection"
            if (fieldIdx < 0 || fieldIdx >= ctorFieldsN ctor)
              then throwError "Field index out of bounds for constructor projection"
              else do
                traceEvent PhInfer TkSpine TraceDetail "infer.proj.fieldType" [("ctor", TrName (constName (ctorConst ctor))), ("field", TrInt fieldIdx), ("indSpineLen", TrInt (length indSpine))]
                -- Evaluate the constructor's base type
                let subst = zip (constLevelParameters (ctorConst ctor)) indLvls
                ctorTypeExpr <- instantiateLevelParamsExpr subst (constType $ ctorConst ctor)
                ctorTypeVal <- evalM [] ctorTypeExpr
                -- Feed the inductive parameters to the constructor type
                paramVals <- mapM extractArgM $ reverse indSpine
                tyAfterParams <- foldM instantiatePi ctorTypeVal paramVals
                structVal <- evalM env structExpr
                let prevProjs = [0 .. fieldIdx - 1]
                prevProjVals <- mapM (applyElimM depth structVal . EProj projName) prevProjs
                tyAfterProjs <- foldM instantiatePi tyAfterParams prevProjVals
                (finalFieldTy, _) <- extractPiDomain tyAfterProjs
                pure finalFieldTy
          _ -> throwError "Inductive not found in environment for projection"
      _ -> throwError "Expected an inductive type for projection"

extractArgM :: Elim -> KernelM Value
extractArgM (EApp v) = pure v
extractArgM _ = throwError "Expected an application elimination to extract argument"

extractAppArgM :: Int -> Spine -> KernelM Value
extractAppArgM idx spine = case drop idx spine of
  (EApp v : _) -> pure v
  _ -> throwError "Expected an application elimination at the given index in the spine"

-- | Infer the type of a Head, then apply the spine
inferHeadApp :: Int -> Head -> Spine -> KernelM Value
inferHeadApp depth head spine = do
  traceBlock PhInfer TkEnter TraceSummary "infer.headApp" [("depth", TrInt depth), ("head", TrHead head), ("spineLen", TrInt (length spine))] $ do
    -- Get the base type of the Head
    baseType <- case head of
      HLvl _ lvl -> do
        ty <- lookupLocalType lvl
        traceOk PhLookup TkLookup TraceDetail "infer.headApp.local" [("level", TrInt lvl)]
        pure ty
      HConst name lvls -> do
        mInfo <- lookupConstInfo name
        case mInfo of
          Just info -> do
            -- Instantiate the levels in the constant's type, and evaluate it
            let subst = zip (constLevelParameters (constantInfoConst info)) lvls
            instTypeExpr <- instantiateLevelParamsExpr subst (constType (constantInfoConst info))
            tyVal <- evalM [] instTypeExpr
            traceOk PhLookup TkLookup TraceDetail "infer.headApp.const" [("const", TrName name), ("levels", TrDoc (ppr lvls))]
            pure tyVal
          Nothing -> throwError "Unknown constant"
    let baseVal = VNeutral head []
    -- Fold over the spine in reverse order (since innermost arg is last in the list)
    (finalType, _) <- foldM (applyTypeElimAndVal depth) (baseType, baseVal) (reverse spine)
    traceOk PhInfer TkSpine TraceSummary "infer.headApp.spine.ok" [("spineLen", TrInt (length spine))]
    pure finalType

-- | Step through the type by applying eliminations
applyTypeElimAndVal :: Int -> (Value, Value) -> Elim -> KernelM (Value, Value)
applyTypeElimAndVal depth (currentType, currentVal) elim = do
  typeWhnf <- force currentType
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
      indVal <- lookupInducVal indName
      ctor <- case indCtors indVal of
        [ctor] ->
          lookupConstInfo ctor >>= \c -> case c of
            Just (CtorInfo ctorVal) -> pure ctorVal
            _ -> throwError "Constructor not found in environment"
        _ -> throwError "Expected exactly one constructor for projection"
      if (fieldIdx < 0 || fieldIdx >= ctorFieldsN ctor)
        then
          throwError "Field index out of bounds for constructor projection"
        else do
          -- Evaluate the constructor's base type
          let subst = zip (constLevelParameters (ctorConst ctor)) indLvls
          ctorTypeExpr <- instantiateLevelParamsExpr subst (constType $ ctorConst ctor)
          ctorTypeVal <- evalM [] ctorTypeExpr
          -- Feed the inductive parameters to the constructor type
          -- indSpine is reversed
          paramVals <- mapM extractArgM $ reverse indSpine
          tyAfterParams <- foldM instantiatePi ctorTypeVal paramVals
          let prevProjs = [0 .. fieldIdx - 1]
          prevProjVals <- mapM (applyElimM depth currentVal . EProj projName) prevProjs
          tyAfterProjs <- foldM instantiatePi tyAfterParams prevProjVals
          (finalFieldTy, _) <- extractPiDomain tyAfterProjs
          nextVal <- applyElimM depth currentVal elim
          pure (finalFieldTy, nextVal)
    _ -> do
      traceFail PhInfer TkFailure TraceSummary "infer.typeElim.invalid" [("type", TrValueHead currentType), ("elim", TrElim elim)]
      throwError "Type Error: Applied argument to non-function, or projected non-struct"

instantiatePi :: Value -> Value -> KernelM Value
instantiatePi piVal argVal = do
  forced <- force piVal
  case forced of
    VPi _ _ _ clo -> evalM (argVal : closureEnv clo) (closureBody clo)
    _ -> throwError "Expected Pi type in constructor"

extractPiDomain :: Value -> KernelM (Value, Closure)
extractPiDomain piVal = do
  forced <- force piVal
  case forced of
    VPi _ _ dom clo -> pure (dom, clo)
    _ -> throwError "Expected Pi type to extract domain"

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
        n1 == n2,
        length lvls1 == length lvls2 ->
          if and (zipWith (\l1 l2 -> l1 == l2 || levelEquiv l1 l2) lvls1 lvls2)
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

isDefEqSpine :: Int -> Spine -> Spine -> KernelM Bool
isDefEqSpine depth s1 s2 = traceBlock PhDefEq TkSpine TraceDetail "defeq.spine" [("depth", TrInt depth), ("lhsLen", TrInt (length s1)), ("rhsLen", TrInt (length s2))] $ do
  if length s1 /= length s2 then pure False else and <$> zipWithM (isDefEqElim depth) s1 s2

isDefEqElim :: Int -> Elim -> Elim -> KernelM Bool
isDefEqElim depth (EApp v1) (EApp v2) = isDefEqValue depth v1 v2
isDefEqElim _ (EProj _ i1) (EProj _ i2) = pure (i1 == i2)
isDefEqElim _ _ _ = pure False

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
              -- Extract the constructor's field from spine
              -- spine is reversed: [f_n-1, ..., f0, ctorParams...]
              let fieldsN = ctorFieldsN ctorVal
                  ctorFieldsReversed = take fieldsN spine
                  ctorFields = reverse ctorFieldsReversed
              traceEvent PhEta TkSpine TraceDetail "eta.structure.fields" [("fields", TrInt fieldsN), ("spineLen", TrInt (length spine))]
              ctorFieldVals <- mapM extractArgM ctorFields
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

-- | Converts a WHNF Value back into a fully normalized AST
quote :: Int -> Value -> KernelM HCExpr
quote depth val = traceBlock PhQuote TkEnter TraceSummary "quote.value" [("depth", TrInt depth), ("value", TrValueHead val)] $ do
  v <- force val
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
    VDef _ _ _ _ -> throwError "Unreachable: VDef remaining after force"

quoteElim :: Int -> HCExpr -> Elim -> KernelM HCExpr
quoteElim depth headExpr (EApp argVal) = do
  argExpr <- quote depth argVal
  mkApp headExpr argExpr
quoteElim _ headExpr (EProj name idx) =
  mkProj name idx headExpr
