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

--------------------------------------------------------------------------------

evalM :: Env -> HCExpr -> KernelM Value
evalM env expr = case hceVal expr of
  BVar idx -> pure $ env !! idx
  FVar fv -> pure $ VNeutral (HFVar fv) []
  Sort lvl -> pure $ VSort lvl
  Lit lit -> pure $ VLit lit
  Lam name ty body bi -> do
    tyVal <- evalM env ty
    pure $ VLam name bi tyVal (Closure env body)
  ForallE name ty body bi -> do
    tyVal <- evalM env ty
    pure $ VPi name bi tyVal (Closure env body)
  Let _ _ val body _nondep -> do
    valVal <- evalM env val
    evalM (valVal : env) body
  App fn arg -> do
    fnVal <- evalM env fn
    argVal <- evalM env arg
    applyElimM fnVal (EApp argVal)
  Proj name idx struct -> do
    structVal <- evalM env struct
    applyElimM structVal (EProj name idx)
  Const name levels -> do
    mInfo <- lookupConstInfo name
    case mInfo of
      Just (DefnInfo def) -> do
        let subst = zip (constLevelParameters (defConst def)) levels
        -- Eagerly substitute universes
        instantiatedBody <- instantiateLevelParamsExpr subst (defValue def)
        -- Suspend the evaluation of the body
        let lazyThunk = evalM [] instantiatedBody
        pure $ VDef name levels [] lazyThunk
      _ -> pure $ VNeutral (HConst name levels) []

-- | Push an elimination onto a WHNF Value
applyElimM :: Value -> Elim -> KernelM Value
applyElimM (VLam _ _ _ (Closure env body)) (EApp argVal) = evalM (argVal : env) body -- Beta Reduction
applyElimM (VNeutral (HConst recName recLvls) spine) elim = do
  -- Iota
  let newSpine = elim : spine
      fallback :: KernelM Value = pure $ VNeutral (HConst recName recLvls) newSpine -- keep stuck
  mInfo <- lookupConstInfo recName
  case mInfo of
    Just (QuotInfo quotVal) | quotKind quotVal == QuotLift -> do
      -- hardcode quotient lifting reduction: Quot.lift f h (Quot.mk a) = f a
      -- newSpine = reverse [alpha, r, beta, f, h, major]
      if length newSpine < 6
        then fallback
        else do
          let numExtra = length newSpine - 6
              extraArgs = take numExtra newSpine
              exactArgs = drop numExtra newSpine
          majorVal <- extractAppArgM 0 exactArgs
          forcedMajor <- force majorVal
          case forcedMajor of
            VNeutral (HConst mkName _) mkSpine -> do
              mMkInfo <- lookupConstInfo mkName
              case mMkInfo of
                Just (QuotInfo mkVal) | quotKind mkVal == QuotMk -> do
                  -- Quot.mk takes [alpha, r, a]
                  aVal <- extractAppArgM 0 mkSpine
                  fVal <- extractAppArgM 2 exactArgs
                  reduced <- applyElimM fVal (EApp aVal)
                  applyElimsM reduced extraArgs
                _ -> fallback
            _ -> fallback
    Just (RecInfo recVal) -> do
      let expectedArgs = recParamsN recVal + recMotivesN recVal + recMinorsN recVal + recIndicesN recVal + 1
      if length newSpine < expectedArgs
        then fallback
        else do
          let numExtra = length newSpine - expectedArgs
          let extraArgs = take numExtra newSpine
          let exactArgs = drop numExtra newSpine
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
              mRule <- (Just <$> lookupValidatedRecursorRule recName ctorName) `catchError` \_ -> pure Nothing
              case mRule of
                Just rule -> do
                  -- Extract the params, motives, and minors
                  -- exactArgs (reversed AST order): [major, indices..., minors..., motives..., params...]
                  let paramsMotivesMinors = drop (1 + recIndicesN recVal) exactArgs
                  -- Extract the constructor's fields
                  -- ctorSpine (reversed): [fields..., ctorParams...]
                  let fields = take (recFieldsN rule) ctorSpine
                  -- Evaluate RHS
                  let subst = zip (constLevelParameters (recConst recVal)) recLvls
                  rhsExpr <- instantiateLevelParamsExpr subst (recRhs rule)
                  rhsVal <- evalM [] rhsExpr
                  val1 <- applyElimsM rhsVal paramsMotivesMinors
                  val2 <- applyElimsM val1 fields
                  applyElimsM val2 extraArgs
                _ -> fallback
            _ ->
              -- Try k-rule
              if recKRule recVal
                then do
                  majorType <- inferValue normalizedMajor
                  forcedMajorType <- force majorType
                  targetInductive <- lookupValidatedRecursorTargetInductive recName
                  case forcedMajorType of
                    VNeutral (HConst indName _) indSpine
                      | indName == targetInductive -> do
                          -- indSpine (reversed): [indices..., params...]
                          let actualIndices = take (recIndicesN recVal) indSpine
                          actualIndexVals <- mapM extractArgM actualIndices
                          let targetIndices = take (recIndicesN recVal) (drop 1 exactArgs) -- remove major premise
                          targetIndexVals <- mapM extractArgM targetIndices
                          indicesMatch <- and <$> zipWithM isDefEqValue actualIndexVals targetIndexVals
                          if indicesMatch
                            then do
                              -- K-rule applies, return minor premise
                              let minorPremise = exactArgs !! (1 + recIndicesN recVal)
                              case minorPremise of
                                EApp v -> applyElimsM v extraArgs
                                _ -> fallback
                            else fallback
                    _ -> fallback
                else fallback
    _ -> fallback
applyElimM (VNeutral head spine) elim =
  -- Iota Reduction (Projections & Recursors)
  -- TODO: Iota reduction logic (including K-rule which calls isDefEq)
  pure $ VNeutral head (elim : spine)
applyElimM (VDef name levels spine thunk) elim = do
  -- We push the elimination to the spine, and also to the lazy thunk
  let newSpine = elim : spine
  -- To prevent forcing the thunk immediately, we wrap the application in a new thunk
  let newThunk = do
        forcedBody <- thunk
        applyElimM forcedBody elim
  pure $ VDef name levels newSpine newThunk
applyElimM _ _ = throwError "Ill-typed application"

applyElimsM :: Value -> Spine -> KernelM Value
applyElimsM = foldM applyElimM

-- | Force a VDef thunk
force :: Value -> KernelM Value
force (VDef _ _ _ thunk) = thunk >>= force
force v = pure v

isDefEqValue :: Value -> Value -> KernelM Bool
isDefEqValue val1 val2 = case (val1, val2) of
  (VSort l1, VSort l2) -> pure (l1 == l2 || levelEquiv l1 l2)
  (VLit lit1, VLit lit2) -> pure (lit1 == lit2)
  _ -> do
    valType <- inferValue val1
    typeOfValType <- inferValue valType
    let isProp = case typeOfValType of
          VSort lvl -> getLevel lvl == LZero
          _ -> False
    if isProp
      then pure True -- Proof irrelevance
      else case (val1, val2) of
        (VLam n1 _ ty1 clo1, VLam _ _ ty2 clo2) -> do
          typesEq <- isDefEqValue ty1 ty2
          if not typesEq
            then pure False
            else do
              fv <- freshFVar n1
              let fvVal = VNeutral (HFVar fv) []
              body1 <- evalM (fvVal : closureEnv clo1) (closureBody clo1)
              body2 <- evalM (fvVal : closureEnv clo2) (closureBody clo2)
              isDefEqValue body1 body2
        (VPi n1 _ ty1 clo1, VPi _ _ ty2 clo2) -> do
          typesEq <- isDefEqValue ty1 ty2
          if not typesEq
            then pure False
            else do
              fv <- freshFVar n1
              let fvVal = VNeutral (HFVar fv) []
              body1 <- evalM (fvVal : closureEnv clo1) (closureBody clo1)
              body2 <- evalM (fvVal : closureEnv clo2) (closureBody clo2)
              isDefEqValue body1 body2
        (VNeutral (HFVar f1) s1, s2) -> do
          mDecl <- lookupLocalValue f1
          case mDecl of
            Just letVal -> do
              -- Unfold the let-binding and apply the spine
              unfolded1 <- applyElimsM letVal s1
              isDefEqValue unfolded1 val2
            Nothing ->
              -- It is a nondep let or a lambda binder
              -- It remains opaque. Fall through to failure
              case s2 of
                VNeutral (HFVar f2) s2' | f1 == f2 -> isDefEqSpine s1 s2'
                _ -> pure False
        (s1, (VNeutral (HFVar f2) s2)) -> do
          mDecl <- lookupLocalValue f2
          case mDecl of
            Just letVal -> do
              unfolded2 <- applyElimsM letVal s2
              isDefEqValue val1 unfolded2
            Nothing ->
              case s1 of
                VNeutral (HFVar f1) s1' | f1 == f2 -> isDefEqSpine s1' s2
                _ -> pure False
        (VNeutral h1 s1, VNeutral h2 s2)
          | h1 == h2 -> isDefEqSpine s1 s2
        (VDef n1 _ s1 _, VDef n2 _ s2 _) | n1 == n2 -> do
          -- Try fast path
          match <- isDefEqSpine s1 s2 `catchError` \_ -> pure False
          if match
            then pure True
            else do
              -- Fallback to forcing
              v1 <- force val1
              v2 <- force val2
              isDefEqValue v1 v2
        (VDef n1 _ _ thunk1, VDef n2 _ _ thunk2) -> do
          hint1 <- getDefHints n1
          hint2 <- getDefHints n2
          case compare hint1 hint2 of
            LT -> do
              -- Left is more reducible
              v1 <- thunk1
              isDefEqValue v1 val2
            GT -> do
              -- Right is more reducible
              v2 <- thunk2
              isDefEqValue val1 v2
            EQ -> do
              -- Heights are equal.
              -- If both are Opaque, we fail immediately because n1 != n2.
              if hint1 == Opaque
                then pure False
                else do
                  withUnfoldingConst n1 $ do
                    v1 <- thunk1
                    withUnfoldingConst n2 $ do
                      v2 <- thunk2
                      isDefEqValue v1 v2
        -- Left side is a Definition, Right side is something else
        (VDef n1 _ _ thunk1, _) -> do
          hint1 <- getDefHints n1
          if hint1 == Opaque
            then pure False -- Never unfold opaque definitions!
            else do
              withUnfoldingConst n1 $ do
                v1 <- thunk1
                isDefEqValue v1 val2
        -- Right side is a Definition, Left side is something else
        (_, VDef n2 _ _ thunk2) -> do
          hint2 <- getDefHints n2
          if hint2 == Opaque
            then pure False
            else do
              withUnfoldingConst n2 $ do
                v2 <- thunk2
                isDefEqValue val1 v2
        -- Functional Eta Expansion
        (VLam n _ _ clo, other) -> checkEta n clo other
        (other, VLam n _ _ clo) -> checkEta n clo other
        -- Structural Eta Expansion
        (VNeutral (HConst c1 _) s1, other) ->
          checkStructEta c1 s1 other `catchError` \_ -> pure False
        (other, VNeutral (HConst c2 _) s2) ->
          checkStructEta c2 s2 other `catchError` \_ -> pure False
        _ -> pure False

inferValue :: Value -> KernelM Value
inferValue val = case val of
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
    domTy <- inferValue dom
    fv <- freshFVar name
    let fvVal = VNeutral (HFVar fv) []
    bodyVal <- evalM (fvVal : closureEnv clo) (closureBody clo)
    bodyTy <- inferValue bodyVal
    case (domTy, bodyTy) of
      (VSort l1, VSort l2) -> VSort <$> (mkLevelIMax l1 l2)
      _ -> throwError "Pi type domain or codomain is not a Sort"
  VLam name bi dom clo -> do
    fv <- freshFVar name
    let fvVal = VNeutral (HFVar fv) []
    bodyVal <- evalM (fvVal : closureEnv clo) (closureBody clo)
    bodyTy <- inferValue bodyVal
    bodyTyExpr <- quote bodyTy
    bodyTyAbs <- abstractFVar fv bodyTyExpr
    pure $ VPi name bi dom (Closure (fvVal : closureEnv clo) bodyTyAbs)
  VNeutral head spine -> inferHeadApp head spine
  VDef name lvls spine _ -> inferHeadApp (HConst name lvls) spine

ensureSort :: Value -> KernelM HCLevel
ensureSort val = do
  forced <- force val
  case forced of
    VSort lvl -> pure lvl
    _ -> throwError "Expected a Sort"

ensurePi :: Value -> KernelM (HCName, BinderInfo, Value, Closure)
ensurePi val = do
  forced <- force val
  case forced of
    VPi n bi ty clo -> pure (n, bi, ty, clo)
    _ -> throwError "Expected a Pi (Forall) type"

inferExpr :: Env -> HCExpr -> KernelM Value
inferExpr env expr = case hceVal expr of
  Sort lvl -> pure $ VSort lvl
  Lit (NatVal _) -> do
    name <- withIntern $ internName $ simpleName "Nat"
    con <- mkConst name []
    evalM [] con
  Lit (StrVal _) -> do
    name <- withIntern $ internName $ simpleName "String"
    con <- mkConst name []
    evalM [] con
  FVar fv -> lookupLocalType fv
  BVar _idx -> throwError "Unexpected de Bruijn variable during inference"
  Const name levels -> do
    mInfo <- lookupConstInfo name
    case mInfo of
      Just info -> do
        let subst = zip (constLevelParameters (constantInfoConst info)) levels
        instTypeExpr <- instantiateLevelParamsExpr subst (constType (constantInfoConst info))
        evalM [] instTypeExpr
      Nothing -> throwError "Unknown constant"
  App fn arg -> do
    fnTypeVal <- inferExpr env fn
    (_, _, domTypeVal, clo) <- ensurePi fnTypeVal
    argVal <- evalM env arg
    argTypeVal <- inferValue argVal
    isArgTypeOk <- isDefEqValue argTypeVal domTypeVal
    if not isArgTypeOk
      then throwError $ "Argument type mismatch: " <> show argTypeVal <> " vs " <> show domTypeVal
      else evalM (argVal : closureEnv clo) (closureBody clo)
  Lam name ty body bi -> do
    domTypeVal <- inferExpr env ty
    _ <- ensureSort domTypeVal
    fv <- freshFVar name
    let decl = LocalDecl domTypeVal Nothing
    bodyTypeVal <- withLocalDecl fv decl $ inferExpr ((VNeutral (HFVar fv) []) : env) body
    -- Reconstruct the VPi closure
    bodyTypeExpr <- quote bodyTypeVal
    bodyTypeAbs <- abstractFVar fv bodyTypeExpr
    pure $ VPi name bi domTypeVal (Closure env bodyTypeAbs)
  ForallE name ty body _ -> do
    domTypeVal <- inferExpr env ty
    lvl1 <- ensureSort domTypeVal
    fv <- freshFVar name
    let fvVal = VNeutral (HFVar fv) []
    let decl = LocalDecl domTypeVal Nothing
    bodyTypeVal <- withLocalDecl fv decl $ inferExpr (fvVal : env) body
    lvl2 <- ensureSort bodyTypeVal
    imaxLvl <- mkLevelIMax lvl1 lvl2
    pure $ VSort imaxLvl
  Let name ty value body nondep -> do
    tyVal <- inferExpr env ty
    _ <- ensureSort tyVal
    valueVal <- evalM env value
    valueTypeVal <- inferValue valueVal
    isValueTypeOk <- isDefEqValue valueTypeVal tyVal
    if not isValueTypeOk
      then throwError $ "Let-binding type mismatch: " <> show valueTypeVal <> " vs " <> show tyVal
      else do
        fv <- freshFVar name
        let decl = LocalDecl tyVal (if nondep then Nothing else Just valueVal)
        withLocalDecl fv decl $ inferExpr ((VNeutral (HFVar fv) []) : env) body
  Proj projName fieldIdx structExpr -> do
    structTyVal <- inferExpr env structExpr
    forcedStructTy <- force structTyVal
    case forcedStructTy of
      VNeutral (HConst indName indLvls) indSpine -> do
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
                -- Evaluate the constructor's base type
                let subst = zip (constLevelParameters (ctorConst ctor)) indLvls
                ctorTypeExpr <- instantiateLevelParamsExpr subst (constType $ ctorConst ctor)
                ctorTypeVal <- evalM [] ctorTypeExpr
                -- Feed the inductive parameters to the constructor type
                paramVals <- mapM extractArgM $ reverse indSpine
                tyAfterParams <- foldM instantiatePi ctorTypeVal paramVals
                structVal <- evalM env structExpr
                let prevProjs = [0 .. fieldIdx - 1]
                prevProjVals <- mapM (applyElimM structVal . EProj projName) prevProjs
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
inferHeadApp :: Head -> Spine -> KernelM Value
inferHeadApp head spine = do
  -- Get the base type of the Head
  baseType <- case head of
    HFVar fv -> lookupLocalType fv
    HConst name lvls -> do
      mInfo <- lookupConstInfo name
      case mInfo of
        Just info -> do
          -- Instantiate the levels in the constant's type, and evaluate it
          let subst = zip (constLevelParameters (constantInfoConst info)) lvls
          instTypeExpr <- instantiateLevelParamsExpr subst (constType (constantInfoConst info))
          evalM [] instTypeExpr
        Nothing -> throwError "Unknown constant"
  let baseVal = VNeutral head []
  -- Fold over the spine in reverse order (since innermost arg is last in the list)
  (finalType, _) <- foldM applyTypeElimAndVal (baseType, baseVal) (reverse spine)
  pure finalType

-- | Step through the type by applying eliminations
applyTypeElimAndVal :: (Value, Value) -> Elim -> KernelM (Value, Value)
applyTypeElimAndVal (currentType, currentVal) elim = do
  typeWhnf <- force currentType
  case (typeWhnf, elim) of
    -- When the term is applied to an argument, its type must be a Pi.
    -- We evaluate the Pi's closure using the argument.
    (VPi _ _ _ clo, EApp argVal) -> do
      nextType <- evalM (argVal : closureEnv clo) (closureBody clo)
      bextVal <- applyElimM currentVal elim
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
          prevProjVals <- mapM (applyElimM currentVal . EProj projName) prevProjs
          tyAfterProjs <- foldM instantiatePi tyAfterParams prevProjVals
          (finalFieldTy, _) <- extractPiDomain tyAfterProjs
          nextVal <- applyElimM currentVal elim
          pure (finalFieldTy, nextVal)
    _ -> throwError "Type Error: Applied argument to non-function, or projected non-struct"

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
isDefEq = isDefEq' []

isDefEq' :: Env -> HCExpr -> HCExpr -> KernelM Bool
isDefEq' env e1 e2 = do
  failed <- isFailedExprPair e1 e2
  if failed
    then pure False
    else do
      visited <- isVisitedExprPair e1 e2
      if visited
        then pure True
        else do
          success <- withVisitedExprPair e1 e2 (isDefEqExprCore env e1 e2)
          unless success $ recordFailedExprPair e1 e2
          pure success

isDefEqExprCore :: Env -> HCExpr -> HCExpr -> KernelM Bool
isDefEqExprCore env expr1 expr2
  | expr1 == expr2 = pure True
  | Sort l1 <- hceVal expr1,
    Sort l2 <- hceVal expr2 =
      pure (l1 == l2 || levelEquiv l1 l2)
  | Const n1 lvls1 <- hceVal expr1,
    Const n2 lvls2 <- hceVal expr2,
    n1 == n2,
    length lvls1 == length lvls2 =
      if and (zipWith (\l1 l2 -> l1 == l2 || levelEquiv l1 l2) lvls1 lvls2)
        then pure True
        else fallbackToWHNF
  | Just (LetView n1 ty1 v1 b1 nd1) <- viewLet expr1,
    Just (LetView _n2 ty2 v2 b2 nd2) <- viewLet expr2 =
      -- If nondep flags differ, do zeta
      -- lean kernel actually omits the nondep flag
      if nd1 /= nd2
        then fallbackToWHNF
        else do
          fastSuccess <-
            ( do
                tEq <- isDefEq' env ty1 ty2
                if not tEq
                  then pure False
                  else do
                    vEq <- isDefEq' env v1 v2
                    if not vEq
                      then pure False
                      else do
                        -- Everything matches
                        -- Push a fresh variable to check the bodies.
                        fv <- freshFVar n1
                        fvExpr <- mkFVar fv
                        b1' <- instantiate1 fvExpr b1
                        b2' <- instantiate1 fvExpr b2
                        isDefEq' env b1' b2'
            )
              `catchError` \_ -> pure False
          if fastSuccess then pure True else fallbackToWHNF
  | isApp expr1 && isApp expr2,
    AppSpine fn1 args1 <- getAppSpine expr1,
    AppSpine fn2 args2 <- getAppSpine expr2,
    length args1 == length args2 = do
      -- Try structural equality without forcing WHNF
      fastPathSuccess <-
        ( do
            fnEq <- isDefEq' env fn1 fn2
            if not fnEq
              then pure False
              else
                and <$> zipWithM (isDefEq' env) args1 args2
        )
          `catchError` \_ -> pure False
      if fastPathSuccess then pure True else fallbackToWHNF
  | Lam n1 ty1 b1 bi1 <- hceVal expr1,
    Lam _ ty2 b2 bi2 <- hceVal expr2,
    bi1 == bi2 = do
      fastSuccess <-
        ( do
            tyEq <- isDefEq' env ty1 ty2
            if not tyEq
              then pure False
              else do
                fv <- freshFVar n1
                fvExpr <- mkFVar fv
                b1' <- instantiate1 fvExpr b1
                b2' <- instantiate1 fvExpr b2
                isDefEq' env b1' b2'
        )
          `catchError` \_ -> pure False
      if fastSuccess then pure True else fallbackToWHNF
  | ForallE n1 ty1 b1 bi1 <- hceVal expr1,
    ForallE _ ty2 b2 bi2 <- hceVal expr2,
    bi1 == bi2 = do
      fastSuccess <-
        ( do
            tyEq <- isDefEq' env ty1 ty2
            if not tyEq
              then pure False
              else do
                fv <- freshFVar n1
                fvExpr <- mkFVar fv
                b1' <- instantiate1 fvExpr b1
                b2' <- instantiate1 fvExpr b2
                isDefEq' env b1' b2'
        )
          `catchError` \_ -> pure False
      if fastSuccess then pure True else fallbackToWHNF
  | otherwise = fallbackToWHNF
  where
    fallbackToWHNF = do
      val1 <- evalM env expr1
      val2 <- evalM env expr2
      isDefEqValue val1 val2

isDefEqSpine :: Spine -> Spine -> KernelM Bool
isDefEqSpine s1 s2
  | length s1 /= length s2 = pure False
  | otherwise = and <$> zipWithM isDefEqElim s1 s2

isDefEqElim :: Elim -> Elim -> KernelM Bool
isDefEqElim (EApp v1) (EApp v2) = isDefEqValue v1 v2
isDefEqElim (EProj _ i1) (EProj _ i2) = pure (i1 == i2)
isDefEqElim _ _ = pure False

checkEta :: HCName -> Closure -> Value -> KernelM Bool
checkEta name clo otherVal = do
  fv <- freshFVar name
  let fvVal = VNeutral (HFVar fv) []
  body1 <- evalM (fvVal : closureEnv clo) (closureBody clo)
  body2 <- applyElimM otherVal (EApp fvVal)
  isDefEqValue body1 body2

checkStructEta :: HCName -> Spine -> Value -> KernelM Bool
checkStructEta ctorName spine otherVal = do
  mInfo <- lookupConstInfo ctorName
  case mInfo of
    Just (CtorInfo ctorVal) -> do
      let indName = ctorInductive ctorVal
      mIndInfo <- lookupConstInfo indName
      case mIndInfo of
        Just (InductInfo indVal)
          | length (indCtors indVal) == 1
              && indIndicesN indVal
                == 0 -> do
              -- Extract the constructor's field from spine
              -- spine is reversed: [f_n-1, ..., f0, ctorParams...]
              let fieldsN = ctorFieldsN ctorVal
                  ctorFieldsReversed = take fieldsN spine
                  ctorFields = reverse ctorFieldsReversed
              ctorFieldVals <- mapM extractArgM ctorFields
              let projIndices = [0 .. fieldsN - 1]
                  checkField i expectedVal = do
                    projVal <- applyElimM otherVal (EProj indName i)
                    isDefEqValue expectedVal projVal
              and <$> zipWithM checkField projIndices ctorFieldVals
        _ -> pure False
    _ -> pure False

-- | Converts a WHNF Value back into a fully normalized AST
quote :: Value -> KernelM HCExpr
quote val = do
  v <- force val
  case v of
    VSort lvl -> mkSort lvl
    VLit lit -> mkLit lit
    VLam name bi ty clo -> do
      tyExpr <- quote ty
      fv <- freshFVar name
      let fvVal = VNeutral (HFVar fv) []
      bodyVal <- evalM (fvVal : closureEnv clo) (closureBody clo)
      bodyExpr <- quote bodyVal
      body' <- abstractFVar fv bodyExpr
      mkLam name tyExpr body' bi
    VPi name bi ty clo -> do
      tyExpr <- quote ty
      fv <- freshFVar name
      let fvVal = VNeutral (HFVar fv) []
      bodyVal <- evalM (fvVal : closureEnv clo) (closureBody clo)
      bodyExpr <- quote bodyVal
      body' <- abstractFVar fv bodyExpr
      mkForall name tyExpr body' bi
    VNeutral head spine -> do
      headExpr <- case head of
        HFVar fv -> mkFVar fv
        HConst name levels -> mkConst name levels
      foldM quoteElim headExpr (reverse spine)
    VDef _ _ _ _ -> throwError "Unreachable: VDef remaining after force"

quoteElim :: HCExpr -> Elim -> KernelM HCExpr
quoteElim headExpr (EApp argVal) = do
  argExpr <- quote argVal
  mkApp headExpr argExpr
quoteElim headExpr (EProj name idx) =
  mkProj name idx headExpr
