{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Mlkih.Kernel.Eval where

import Control.Monad (foldM, unless, zipWithM)
import Control.Monad.Except
import Mlkih.AST
import Mlkih.Env
import Mlkih.Expr
import Mlkih.Intern
import Mlkih.Kernel.Types
import Mlkih.Level
import Mlkih.Name
import Mlkih.Pretty

--------------------------------------------------------------------------------

evalM :: LocalEnv -> HCExpr -> KernelM Value
evalM env expr = withTraceNode VLow TEval (text "evalM:" <+> ppr expr) $ do
  traceMsgM VHigh TEval $ text "LocalEnv is" <+> ppr env
  case hceVal expr of
    BVar idx -> do
      traceMsgM VMid TEval $ text "Looking up bound variable"
      pure $ env !! idx
    Sort lvl -> do
      traceMsgM VMid TEval $ text "Returning Sort:" <+> ppr lvl
      pure $ VSort lvl
    Lit lit -> do
      traceMsgM VMid TEval $ text "Returning literal:" <+> ppr lit
      pure $ VLit lit
    Lam name ty body bi -> do
      traceMsgM VMid TEval $ text "Evaluating Lam domain type" <+> ppr name
      tyVal <- evalM env ty
      traceMsgM VMid TEval $ text "Building closure for Lam body with environment"
      pure $ VLam name bi tyVal (Closure env body)
    ForallE name ty body bi -> do
      traceMsgM VMid TEval $ text "Evaluating Pi domain type:" <+> ppr name
      tyVal <- evalM env ty
      traceMsgM VMid TEval $ text "Building closure for Pi body with environment"
      pure $ VPi name bi tyVal (Closure env body)
    Let name _ val body _nondep -> do
      traceMsgM VMid TEval $ text "Evaluating Let value:" <+> ppr name
      valVal <- evalM env val
      traceMsgM VMid TEval $ text "Evaluating Let body with value in environment"
      evalM (valVal : env) body
    App fn arg -> do
      traceMsgM VMid TEval $ text "Evaluating App function"
      fnVal <- evalM env fn
      traceMsgM VMid TEval $ text "Evaluating App argument"
      argVal <- evalM env arg
      traceMsgM VMid TEval $ text "Applying argument to function"
      applyElimM (length env) fnVal (EApp argVal)
    Proj name idx struct -> do
      traceMsgM VMid TEval $ text "Evaluating Proj structure:" <+> (ppr name <> "." <> (int idx))
      structVal <- evalM env struct
      applyElimM (length env) structVal (EProj name idx)
    Const name levels -> do
      traceMsgM VMid TEval $ text "Looking up Const:" <+> ppr name
      mInfo <- lookupConstInfo name
      case mInfo of
        Just (DefnInfo def) -> do
          traceMsgM VMid TEval $ text "Const is Defn. Instantiating levels and creating lazy thunk"
          let subst = zip (constLevelParameters (defConst def)) levels
          -- Eagerly substitute universes
          instantiatedBody <- instantiateLevelParamsExpr subst (defValue def)
          -- Suspend the evaluation of the body
          let lazyThunk = evalM [] instantiatedBody
          pure $ VDef name levels [] lazyThunk
        _ -> do
          traceMsgM VLow TEval $ text "Const is not a Defn, returning stuck Neutral."
          pure $ VNeutral (HConst name levels) []

-- | Push an elimination onto a WHNF Value
applyElimM :: Int -> Value -> Elim -> KernelM Value
applyElimM depth val elim = withTraceNode VLow TEval (text "applyElimM" <+> "@" <+> int depth <+> ":" <+> ppr val <+> text "∘" <+> ppr elim) $
  case (val, elim) of
    (VLam _ _ _ (Closure env body), EApp argVal) -> do
      traceMsgM VMid TEval $ text "Beta Reduction: evaluating body with new environment"
      evalM (argVal : env) body
    ((VNeutral (HConst recName recLvls) spine), elim) -> do
      -- Iota
      let newSpine = elim : spine
          fallback reason = do
            traceMsgM VLow TEval $ text "Returning stuck Neutral:" <+> text reason
            pure $ VNeutral (HConst recName recLvls) newSpine
      mInfo <- lookupConstInfo recName
      case mInfo of
        Just (QuotInfo quotVal) | quotKind quotVal == QuotLift -> do
          traceMsgM VMid TEval $ text "Checking QuotLift reduction. Args:" <+> int (length newSpine)
          -- hardcode quotient lifting reduction: Quot.lift f h (Quot.mk a) = f a
          -- newSpine = reverse [alpha, r, beta, f, h, major]
          if length newSpine < 6
            then fallback "not enough arguments for Quot.lift"
            else do
              let numExtra = length newSpine - 6
                  extraArgs = take numExtra newSpine
                  exactArgs = drop numExtra newSpine
              traceMsgM VMid TEval $ text "Extracting major premise"
              majorVal <- extractAppArgM 0 exactArgs
              forcedMajor <- force majorVal
              case forcedMajor of
                VNeutral (HConst mkName _) mkSpine -> do
                  mMkInfo <- lookupConstInfo mkName
                  case mMkInfo of
                    Just (QuotInfo mkVal) | quotKind mkVal == QuotMk -> do
                      traceMsgM VMid TEval $ text "Applying Quot.lift to Quot.mk"
                      -- Quot.mk takes [alpha, r, a]
                      aVal <- extractAppArgM 0 mkSpine
                      fVal <- extractAppArgM 2 exactArgs
                      reduced <- applyElimM depth fVal (EApp aVal)
                      applyElimsM depth reduced extraArgs
                    _ -> fallback "major premise is not Quot.mk"
                _ -> fallback "major premise is not a stuck application"
        Just (RecInfo recVal) -> do
          let expectedArgs = recParamsN recVal + recMotivesN recVal + recMinorsN recVal + recIndicesN recVal + 1
          traceMsgM VMid TEval $ text "Checking Recursor application. Expected args:" <+> int expectedArgs <+> text "Got:" <+> int (length newSpine)
          if length newSpine < expectedArgs
            then fallback "not enough arguments for recursor"
            else do
              let numExtra = length newSpine - expectedArgs
              let extraArgs = take numExtra newSpine
              let exactArgs = drop numExtra newSpine
              traceMsgM VMid TEval $ text "Extracting and forcing major premise"
              -- Extract the major premise
              majorVal <- extractAppArgM 0 exactArgs
              forcedMajor <- force majorVal
              zero <- withIntern $ internName $ Name (Str (simpleName "Nat") "zero")
              succ <- withIntern $ internName $ Name (Str (simpleName "Nat") "succ")
              -- Convert literal naturals to their constructor
              let normalizedMajor = case forcedMajor of
                    VLit (NatVal 0) ->
                      VNeutral (HConst zero []) []
                    VLit (NatVal n)
                      | n > 0 ->
                          let predVal = VLit (NatVal (n - 1))
                           in VNeutral (HConst succ []) [EApp predVal]
                    _ -> forcedMajor
              case normalizedMajor of
                VNeutral (HConst ctorName _) ctorSpine -> do
                  -- major premise is ctor
                  traceMsgM VMid TEval $ text "Recursor major premise is constructor:" <+> ppr ctorName
                  mRule <-
                    (Just <$> lookupValidatedRecursorRule recName ctorName) `catchError` \err -> do
                      traceMsgM VMid TEval $ text "Failed to find validated recursor rule:" <+> text err
                      pure Nothing
                  case mRule of
                    Just rule -> do
                      traceMsgM VMid TEval $ text "Found rule. Applying iota reduction."
                      -- Extract the params, motives, and minors
                      -- exactArgs (reversed AST order): [major, indices..., minors..., motives..., params...]
                      let paramsMotivesMinors = drop (1 + recIndicesN recVal) exactArgs
                      -- Extract the constructor's fields
                      -- ctorSpine (reversed): [fields..., ctorParams...]
                      let fields = take (recFieldsN rule) ctorSpine
                      -- Evaluate RHS
                      let subst = zip (constLevelParameters (recConst recVal)) recLvls
                      traceMsgM VMid TEval $ text "Evaluating rule RHS"
                      rhsExpr <- instantiateLevelParamsExpr subst (recRhs rule)
                      rhsVal <- evalM [] rhsExpr
                      traceMsgM VMid TEval $ text "Applying params, motives, minors, and fields to RHS"
                      val1 <- applyElimsM depth rhsVal paramsMotivesMinors
                      val2 <- applyElimsM depth val1 fields
                      applyElimsM depth val2 extraArgs
                    _ -> fallback "no matching constructor rule for recursor"
                _ ->
                  if recKRule recVal
                    then withTraceNode VLow TDefEq (text "K-rule recursor") $ do
                      traceMsgM VMid TEval $ text "Attempting K-rule reduction"
                      majorType <- inferValue depth normalizedMajor
                      forcedMajorType <- force majorType
                      targetInductive <- lookupValidatedRecursorTargetInductive recName
                      case forcedMajorType of
                        VNeutral (HConst indName indLvls) indSpine
                          | indName == targetInductive -> do
                              traceMsgM VMid TEval $ text "Major premise type matches target inductive. Checking indices."
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
                                      traceMsgM VMid TEval $ text "Instantiating constructor using major premise's levels"
                                      let subst = zip (constLevelParameters (ctorConst ctorVal)) indLvls
                                      ctorTypeExpr <- instantiateLevelParamsExpr subst (constType (ctorConst ctorVal))
                                      ctorTypeVal <- evalM [] ctorTypeExpr
                                      traceMsgM VMid TEval $ text "Applying parameters to the constructor's type"
                                      paramVals <- mapM extractArgM (reverse params)
                                      ctorTyAfterParams <- foldM instantiatePi ctorTypeVal paramVals
                                      forcedCtorTy <- force ctorTyAfterParams
                                      case forcedCtorTy of
                                        VNeutral (HConst indName2 _) cSpine | indName2 == targetInductive -> do
                                          traceMsgM VMid TEval $ text "Extracting constructor's generated indices"
                                          let cIndices = take numIndices cSpine
                                          cIndexVals <- mapM extractArgM cIndices
                                          actualIndexVals <- mapM extractArgM actualIndices
                                          traceMsgM VMid TEval $ text "Checking if constructor's generated indices match major premise indices"
                                          indicesMatch <- and <$> zipWithM (isDefEqValue depth) actualIndexVals cIndexVals
                                          if indicesMatch
                                            then do
                                              traceMsgM VMid TEval $ text "Indices match. K-rule applies, returning minor premise"
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
      traceMsgM VMid TEval $ text "Appending elim to neutral spine"
      pure $ VNeutral head (elim : spine)
    ((VDef name levels spine thunk), elim) -> do
      traceMsgM VMid TEval $ text "Pushing elim to lazy VDef thunk:" <+> ppr name
      let newSpine = elim : spine
      -- To prevent forcing the thunk immediately, we wrap the application in a new thunk
      let newThunk = do
            forcedBody <- thunk
            applyElimM depth forcedBody elim
      pure $ VDef name levels newSpine newThunk
    _ -> do
      traceMsgM VMid TEval $ text "Ill-typed application detected."
      throwError "Ill-typed application"

applyElimsM :: Int -> Value -> Spine -> KernelM Value
applyElimsM depth baseVal spine =
  withTraceNode VLow TEval (text "applyElimsM:" <+> ppr baseVal <+> text "spine length:" <+> text (show $ length spine)) $
    foldM (applyElimM depth) baseVal (reverse spine)

-- | Force a VDef thunk
force :: Value -> KernelM Value
force v = case v of
  VDef n _ _ thunk -> withTraceNode VLow TEval (text "force VDef:" <+> ppr n) $ thunk >>= force
  _ -> pure v

isDefEqValue :: Int -> Value -> Value -> KernelM Bool
isDefEqValue depth val1 val2 = withTraceNode VLow TDefEq ("isDefEqValue" <+> "@" <+> ppr depth <+> ":" <+> ppr val1 <+> text "=?=" <+> ppr val2) $ do
  case (val1, val2) of
    (VSort l1, VSort l2) -> do
      let eq = l1 == l2 || levelEquiv l1 l2
      if eq
        then traceMsgM VLow TDefEq $ green (text "Matched via level equivalence")
        else traceMsgM VLow TDefEq $ text "Level mismatch:" <+> ppr l1 <+> text "vs" <+> ppr l2
      pure eq
    (VLit lit1, VLit lit2) -> do
      let eq = lit1 == lit2
      if eq
        then traceMsgM VLow TDefEq $ green (text "Matched via literal equality")
        else traceMsgM VLow TDefEq $ text "Literal mismatch:" <+> ppr lit1 <+> text "vs" <+> ppr lit2
      pure eq
    _ -> do
      valType <- inferValue depth val1
      typeOfValType <- inferValue depth valType
      let isProp = case typeOfValType of
            VSort lvl -> getLevel lvl == LZero
            _ -> False
      if isProp
        then do
          traceMsgM VLow TDefEq $ green (text "Matched via Proof Irrelevance")
          pure True
        else do
          z1 <- tryZeta val1
          case z1 of
            Just u1 -> do
              traceMsgM VMid TDefEq $ text "Zeta reduced LHS"
              isDefEqValue depth u1 val2
            Nothing -> do
              z2 <- tryZeta val2
              case z2 of
                Just u2 -> do
                  traceMsgM VMid TDefEq $ text "Zeta reduced RHS"
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
        traceMsgM VMid TDefEq $ text "Comparing two lambdas. Checking domain types for:" <+> ppr n1
        typesEq <- isDefEqValue depth ty1 ty2
        if not typesEq
          then do
            traceMsgM VLow TDefEq $ text "Lambda domain types do not match."
            pure False
          else do
            let levelVal = VNeutral (HLvl n1 depth) []
            let decl = LocalDecl n1 ty1 Nothing
            withLocalDecl depth decl $ do
              body1 <- evalM (levelVal : closureEnv clo1) (closureBody clo1)
              body2 <- evalM (levelVal : closureEnv clo2) (closureBody clo2)
              isDefEqValue (depth + 1) body1 body2
      (VPi n1 _ ty1 clo1, VPi _ _ ty2 clo2) -> do
        traceMsgM VMid TDefEq $ text "Comparing two Pis. Checking domain types for:" <+> ppr n1
        typesEq <- isDefEqValue depth ty1 ty2
        if not typesEq
          then do
            traceMsgM VLow TDefEq $ text "Pi domain types do not match."
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
            traceMsgM VMid TDefEq $ text "Comparing spines with because heads match."
            isDefEqSpine depth s1 s2
      (VDef n1 _ s1 _, VDef n2 _ s2 _) | n1 == n2 -> do
        match <- isDefEqSpine depth s1 s2 `catchError` \_ -> pure False
        if match
          then do
            traceMsgM VLow TDefEq $ green (text "Matched VDefs by head and spine")
            pure True
          else do
            traceMsgM VMid TDefEq $ text "VDefs have same head but different spines. Forcing bodies to compare."
            v1' <- force v1
            v2' <- force v2
            isDefEqValue depth v1' v2'
      (VDef n1 _ _ thunk1, VDef n2 _ _ thunk2) -> do
        hint1 <- getDefHints n1
        hint2 <- getDefHints n2
        case compare hint1 hint2 of
          LT -> do
            traceMsgM VMid TDefEq $ text "Forcing LHS VDef first based on hints."
            v1' <- thunk1
            isDefEqValue depth v1' v2
          GT -> do
            traceMsgM VMid TDefEq $ text "Forcing RHS VDef first based on hints."
            v2' <- thunk2
            isDefEqValue depth v1 v2'
          EQ -> do
            if hint1 == Opaque
              then do
                traceMsgM VLow TDefEq $ red $ text "Both VDefs are opaque. Not unfolding and returning False."
                pure False
              else do
                traceMsgM VMid TDefEq $ text "Forcing both VDefs simultaneously based on equal hints."
                withUnfoldingConst n1 $ do
                  v1' <- thunk1
                  withUnfoldingConst n2 $ do
                    v2' <- thunk2
                    isDefEqValue depth v1' v2'
      (VDef n1 _ _ thunk1, _) -> do
        hint1 <- getDefHints n1
        if hint1 == Opaque
          then do
            traceMsgM VLow TDefEq $ red $ text "LHS VDef is opaque. Not unfolding and returning False."
            pure False
          else do
            withUnfoldingConst n1 $ do
              v1' <- thunk1
              isDefEqValue depth v1' v2
      (_, VDef n2 _ _ thunk2) -> do
        hint2 <- getDefHints n2
        if hint2 == Opaque
          then do
            traceMsgM VLow TDefEq $ red $ text "RHS VDef is opaque. Not unfolding and returning False."
            pure False
          else do
            withUnfoldingConst n2 $ do
              v2' <- thunk2
              isDefEqValue depth v1 v2'
      (VLam n _ ty clo, other) -> checkEta depth n ty clo other
      (other, VLam n _ ty clo) -> checkEta depth n ty clo other
      (VNeutral (HConst c1 _) s1, other) -> do
        traceMsgM VMid TDefEq $ "Checking structural eta on LHS const:" <+> ppr c1
        checkStructEta depth c1 s1 other `catchError` \e -> do
          traceMsgM VLow TDefEq $ red $ text "LHS checkStructEta threw:" <+> text e
          pure False
      (other, VNeutral (HConst c2 _) s2) -> do
        traceMsgM VMid TDefEq $ "Checking structural eta on RHS const:" <+> ppr c2
        checkStructEta depth c2 s2 other `catchError` \e -> do
          traceMsgM VLow TDefEq $ red $ text "RHS checkStructEta threw:" <+> text e
          pure False
      _ -> do
        traceMsgM VLow TDefEq $ red $ text "matchCore fallback reached False."
        pure False

inferValue :: Int -> Value -> KernelM Value
inferValue depth val = withTraceNode VLow TInfer (text "inferValue" <+> "@" <+> int depth <+> ":" <+> ppr val) $ case val of
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
      pure $ VPi name bi dom (Closure (closureEnv clo) bodyTyExpr)
  VNeutral head spine -> inferHeadApp depth head spine
  VDef name lvls spine _ -> inferHeadApp depth (HConst name lvls) spine

ensureSort :: Value -> KernelM HCLevel
ensureSort val = withTraceNode VLow TInfer (text "ensureSort:" <+> ppr val) $ do
  forced <- force val
  case forced of
    VSort lvl -> do
      traceMsgM VLow TInfer $ green $ text "Successfully extracted Sort:" <+> ppr lvl
      pure lvl
    _ -> do
      traceMsgM VLow TInfer $ text "Failed: Value is not a Sort"
      throwError "Expected a Sort"

ensurePi :: Value -> KernelM (HCName, BinderInfo, Value, Closure)
ensurePi val = withTraceNode VLow TInfer (text "ensurePi:" <+> ppr val) $ do
  forced <- force val
  case forced of
    VPi n bi ty clo -> do
      traceMsgM VLow TInfer $ green $ text "Successfully extracted Pi for:" <+> ppr n
      pure (n, bi, ty, clo)
    _ -> do
      traceMsgM VLow TInfer $ text "Failed: Value is not a Pi (Forall) type"
      throwError "Expected a Pi (Forall) type"

inferExpr :: Int -> LocalEnv -> HCExpr -> KernelM Value
inferExpr depth env expr = withTraceNode VLow TInfer (text "inferExpr" <+> "@" <+> int depth <+> ":" <+> ppr expr) $ case hceVal expr of
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
        traceMsgM VMid TInfer $ text "Looking up type in local context for BVar index:" <+> int idx <+> text "which corresponds to level:" <+> int lvl
        lookupLocalType lvl
  Const name levels -> do
    traceMsgM VMid TInfer $ text "Looking up Const type:" <+> ppr name
    mInfo <- lookupConstInfo name
    case mInfo of
      Just info -> do
        let subst = zip (constLevelParameters (constantInfoConst info)) levels
        instTypeExpr <- instantiateLevelParamsExpr subst (constType (constantInfoConst info))
        evalM [] instTypeExpr
      Nothing -> throwError "Unknown constant"
  App fn arg -> do
    traceMsgM VMid TInfer $ text "Inferring function type"
    fnTypeVal <- inferExpr depth env fn
    (_, _, domTypeVal, clo) <- ensurePi fnTypeVal
    traceMsgM VMid TInfer $ text "Evaluating argument and inferring its type"
    argVal <- evalM env arg
    argTypeVal <- inferValue depth argVal
    traceMsgM VMid TInfer $ text "Checking argument type against domain type"
    isArgTypeOk <- isDefEqValue depth argTypeVal domTypeVal
    if not isArgTypeOk
      then do
        traceMsgM VLow TInfer $ text "Type mismatch: Arg type" <+> ppr argTypeVal <+> text "!= Domain type" <+> ppr domTypeVal
        throwError "Argument type mismatch"
      else do
        traceMsgM VLow TInfer $ text "Type check passed. Instantiating codomain."
        evalM (argVal : closureEnv clo) (closureBody clo)
  Lam name ty body bi -> do
    traceMsgM VMid TInfer $ text "Inferring Lam domain type"
    tySort <- inferExpr depth env ty
    _ <- ensureSort tySort
    domTypeVal <- evalM env ty
    let decl = LocalDecl name domTypeVal Nothing
    let levelVal = VNeutral (HLvl name depth) []
    traceMsgM VMid TInfer $ text "Inferring Lam body type with HLvl pushed to context"
    bodyTypeVal <- withLocalDecl depth decl $ inferExpr (depth + 1) (levelVal : env) body
    bodyTypeExpr <- quote (depth + 1) bodyTypeVal
    pure $ VPi name bi domTypeVal (Closure env bodyTypeExpr)
  ForallE name ty body _ -> do
    traceMsgM VMid TInfer $ text "Inferring Pi domain sort"
    tySort <- inferExpr depth env ty
    forcedTySort <- force tySort
    lvl1 <- ensureSort forcedTySort
    domTypeVal <- evalM env ty
    let decl = LocalDecl name domTypeVal Nothing
    let levelVal = VNeutral (HLvl name depth) []
    traceMsgM VMid TInfer $ text "Inferring Pi codomain sort with HLvl pushed to context"
    bodyTypeVal <- withLocalDecl depth decl $ inferExpr (depth + 1) (levelVal : env) body
    lvl2 <- ensureSort bodyTypeVal
    traceMsgM VMid TInfer $ text "Calculating IMax for Pi universe level"
    imaxLvl <- mkLevelIMax lvl1 lvl2
    pure $ VSort imaxLvl
  Let name ty value body nondep -> do
    traceMsgM VMid TInfer $ text "Inferring Let binding type"
    tyVal <- inferExpr depth env ty
    _ <- ensureSort tyVal
    valueVal <- evalM env value
    valueTypeVal <- inferValue depth valueVal
    traceMsgM VMid TInfer $ text "Checking value type matches annotated type"
    isValueTypeOk <- isDefEqValue depth valueTypeVal tyVal
    if not isValueTypeOk
      then do
        traceMsgM VLow TInfer $ text "Type mismatch in Let binding"
        throwError "Let-binding type mismatch"
      else do
        traceMsgM VLow TInfer $ text "Inferring Let body type"
        let decl = LocalDecl name tyVal (if nondep then Nothing else Just valueVal)
        let levelVal = VNeutral (HLvl name depth) []
        withLocalDecl depth decl $ inferExpr (depth + 1) (levelVal : env) body
  Proj projName fieldIdx structExpr -> do
    traceMsgM VMid TInfer $ text "Inferring Proj structure type"
    structTyVal <- inferExpr depth env structExpr
    forcedStructTy <- force structTyVal
    case forcedStructTy of
      VNeutral (HConst indName indLvls) indSpine -> do
        traceMsgM VMid TInfer $ text "Structure is inductive:" <+> ppr indName
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
                traceMsgM VMid TInfer $ text "Instantiating constructor parameters and previous fields"
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
  withTraceNode VLow TInfer (text "inferHeadApp:" <+> ppr head) $ do
    -- Get the base type of the Head
    baseType <- case head of
      HLvl _ lvl -> do
        ty <- lookupLocalType lvl
        traceMsgM VMid TInfer $ text "HLvl base type successfully fetched from context."
        pure ty
      HConst name lvls -> do
        mInfo <- lookupConstInfo name
        case mInfo of
          Just info -> do
            -- Instantiate the levels in the constant's type, and evaluate it
            let subst = zip (constLevelParameters (constantInfoConst info)) lvls
            instTypeExpr <- instantiateLevelParamsExpr subst (constType (constantInfoConst info))
            tyVal <- evalM [] instTypeExpr
            traceMsgM VMid TInfer $ text "HConst base type successfully evaluated."
            pure tyVal
          Nothing -> throwError "Unknown constant"
    let baseVal = VNeutral head []
    -- Fold over the spine in reverse order (since innermost arg is last in the list)
    (finalType, _) <- foldM (applyTypeElimAndVal depth) (baseType, baseVal) (reverse spine)
    traceMsgM VLow TInfer $ text "Successfully applied spine."
    pure finalType

-- | Step through the type by applying eliminations
applyTypeElimAndVal :: Int -> (Value, Value) -> Elim -> KernelM (Value, Value)
applyTypeElimAndVal depth (currentType, currentVal) elim = do
  typeWhnf <- force currentType
  traceMsgM VMid TInfer $ text "applyTypeElim:" <+> ppr currentType <+> ppr elim
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
      traceMsgM VLow TInfer $ text "Tried to apply" <+> ppr elim <+> text "to a term of type" <+> ppr currentType
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
isDefEq' depth env e1 e2 = withTraceNode VLow TDefEq (text "isDefEq'" <+> "@" <+> ppr depth <+> ppr e1 <+> text "=?=" <+> ppr e2) $ do
  failed <- isFailedExprPair e1 e2
  if failed
    then do
      traceMsgM VLow TDefEq $ red $ text "Previously failed comparison hit, returning False."
      pure False
    else do
      visited <- isVisitedExprPair e1 e2
      if visited
        then do
          traceMsgM VLow TDefEq $ green $ text "Already visited pair, returning True."
          pure True
        else do
          success <- withVisitedExprPair e1 e2 (isDefEqExprCore depth env e1 e2)
          unless success $ recordFailedExprPair e1 e2
          pure success

isDefEqExprCore :: Int -> LocalEnv -> HCExpr -> HCExpr -> KernelM Bool
isDefEqExprCore depth env expr1 expr2 = withTraceNode VLow TDefEq (text "isDefEqExprCore" <+> "@" <+> ppr depth <+> ppr expr1 <+> text "=?=" <+> ppr expr2) $ do
  traceMsgM VHigh TDefEq $ text "LocalEnv is" <+> ppr env
  case () of
    () | expr1 == expr2 -> do
      traceMsgM VLow TDefEq $ green $ text "Pointer/structural equality hit"
      pure True
    ()
      | Sort l1 <- hceVal expr1,
        Sort l2 <- hceVal expr2 -> do
          traceMsgM VMid TDefEq $ text "Checking Sort levels"
          pure (l1 == l2 || levelEquiv l1 l2)
    ()
      | Const n1 lvls1 <- hceVal expr1,
        Const n2 lvls2 <- hceVal expr2,
        n1 == n2,
        length lvls1 == length lvls2 ->
          if and (zipWith (\l1 l2 -> l1 == l2 || levelEquiv l1 l2) lvls1 lvls2)
            then do
              traceMsgM VLow TDefEq $ green $ text "Constants match exactly."
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
      traceMsgM VMid TDefEq $ text "Falling back to WHNF comparison:" <+> text reason
      val1 <- evalM env expr1
      val2 <- evalM env expr2
      isDefEqValue depth val1 val2

isDefEqSpine :: Int -> Spine -> Spine -> KernelM Bool
isDefEqSpine depth s1 s2 = withTraceNode VLow TDefEq (text "isDefEqSpine" <+> "@" <+> ppr depth <+> ":" <+> ppr s1 <+> "=?=" <+> ppr s2) $ do
  if length s1 /= length s2 then pure False else and <$> zipWithM (isDefEqElim depth) s1 s2

isDefEqElim :: Int -> Elim -> Elim -> KernelM Bool
isDefEqElim depth (EApp v1) (EApp v2) = isDefEqValue depth v1 v2
isDefEqElim _ (EProj _ i1) (EProj _ i2) = pure (i1 == i2)
isDefEqElim _ _ _ = pure False

checkEta :: Int -> HCName -> Value -> Closure -> Value -> KernelM Bool
checkEta depth name ty clo otherVal = withTraceNode VLow TEta (text "checkEta" <+> "@" <+> ppr depth) $ do
  let levelVal = VNeutral (HLvl name depth) []
  let decl = LocalDecl name ty Nothing
  withLocalDecl depth decl $ do
    body1 <- evalM (levelVal : closureEnv clo) (closureBody clo)
    body2 <- applyElimM depth otherVal (EApp levelVal)
    isDefEqValue (depth + 1) body1 body2

checkStructEta :: Int -> HCName -> Spine -> Value -> KernelM Bool
checkStructEta depth ctorName spine otherVal = withTraceNode VLow TEta (text "checkStructEta" <+> "@" <+> ppr depth <+> ":" <+> ppr ctorName) $ do
  mInfo <- lookupConstInfo ctorName
  case mInfo of
    Just (CtorInfo ctorVal) -> do
      let indName = ctorInductive ctorVal
      traceMsgM VMid TEta $ text "Found Inductive:" <+> ppr indName
      mIndInfo <- lookupConstInfo indName
      case mIndInfo of
        Just (InductInfo indVal)
          | length (indCtors indVal) == 1
              && indIndicesN indVal
                == 0 -> do
              traceMsgM VMid TEta $ text "Structure verified."
              -- Extract the constructor's field from spine
              -- spine is reversed: [f_n-1, ..., f0, ctorParams...]
              let fieldsN = ctorFieldsN ctorVal
                  ctorFieldsReversed = take fieldsN spine
                  ctorFields = reverse ctorFieldsReversed
              traceMsgM VMid TEta $ text "Number of fields:" <+> ppr fieldsN
              ctorFieldVals <- mapM extractArgM ctorFields
              let projIndices = [0 .. fieldsN - 1]
                  checkField i expectedVal = do
                    traceMsgM VMid TEta $ text "Checking projection field" <+> ppr i
                    projVal <- applyElimM depth otherVal (EProj indName i)
                    isDefEqValue depth expectedVal projVal
              and <$> zipWithM checkField projIndices ctorFieldVals
        _ -> do
          traceMsgM VLow TEta $ text "Not a structure (indices != 0 or ctors != 1)."
          pure False
    _ -> do
      traceMsgM VLow TEta $ text "Not a constructor."
      pure False

-- | Converts a WHNF Value back into a fully normalized AST
quote :: Int -> Value -> KernelM HCExpr
quote depth val = withTraceNode VLow TQuote (text "quote" <+> "@" <+> ppr depth <+> ":" <+> ppr val) $ do
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
      traceMsgM VMid TQuote $ text "Constructed head expression:" <+> ppr head
      foldM (quoteElim depth) headExpr (reverse spine)
    VDef _ _ _ _ -> throwError "Unreachable: VDef remaining after force"

quoteElim :: Int -> HCExpr -> Elim -> KernelM HCExpr
quoteElim depth headExpr (EApp argVal) = do
  argExpr <- quote depth argVal
  mkApp headExpr argExpr
quoteElim _ headExpr (EProj name idx) =
  mkProj name idx headExpr
