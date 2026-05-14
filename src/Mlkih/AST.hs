{-# LANGUAGE FlexibleContexts #-}

module Mlkih.AST
  ( mkLevelZero,
    mkLevelSucc,
    mkLevelMax,
    mkLevelIMax,
    mkLevelParam,
    AppSpine (..),
    ConstAppView (..),
    ProjView (..),
    ProjStructConstAppView (..),
    BinderView (..),
    LetView (..),
    mkBVar,
    -- mkFVar,
    mkSort,
    mkConst,
    mkApp,
    mkApps,
    mkLam,
    mkForall,
    mkLit,
    mkLet,
    mkProj,
    getAppFn,
    getAppArgs,
    getAppSpine,
    mkAppSpine,
    isApp,
    viewConstApp,
    viewProj,
    mkProjFromView,
    viewProjStructConstApp,
    viewLam,
    viewForall,
    viewLet,
    getLams,
    getForalls,
    mkLams,
    mkForalls,
    mkLetFromView,
    openBinderView,
    openLetView,
    instantiate1,
    instantiate,
    abstractFVar,
    abstractFVars,
    instantiateLevelParams,
    instantiateLevelParamsExpr,
    instantiateLevelParamsLevel,
  )
where

import Control.Monad (foldM)
import Control.Monad.State.Strict (MonadState)
import qualified Data.IntMap.Strict as IntMap
import Mlkih.Expr
import Mlkih.Intern
import Mlkih.Level
import Mlkih.Name

data AppSpine = AppSpine
  { appSpineFn :: HCExpr,
    appSpineArgs :: [HCExpr]
  }
  deriving (Show, Eq, Ord)

data ConstAppView = ConstAppView
  { constAppName :: HCName,
    constAppLevels :: [HCLevel],
    constAppArgs :: [HCExpr]
  }
  deriving (Show, Eq, Ord)

data ProjView = ProjView
  { projViewTypeName :: HCName,
    projViewIndex :: Int,
    projViewStruct :: HCExpr
  }
  deriving (Show, Eq, Ord)

data ProjStructConstAppView = ProjStructConstAppView
  { projStructTypeName :: HCName,
    projStructIndex :: Int,
    projStructConstName :: HCName,
    projStructConstLevels :: [HCLevel],
    projStructArgs :: [HCExpr]
  }
  deriving (Show, Eq, Ord)

data BinderView = BinderView
  { binderViewName :: HCName,
    binderViewType :: HCExpr,
    binderViewBody :: HCExpr,
    binderViewInfo :: BinderInfo
  }
  deriving (Show, Eq, Ord)

data LetView = LetView
  { letViewName :: HCName,
    letViewType :: HCExpr,
    letViewValue :: HCExpr,
    letViewBody :: HCExpr,
    letViewNondep :: Bool
  }
  deriving (Show, Eq, Ord)

mkLevelZero :: (MonadState s m, HasInternState s) => m HCLevel
mkLevelZero = withIntern $ internLevelVal LZero

mkLevelSucc :: (MonadState s m, HasInternState s) => HCLevel -> m HCLevel
mkLevelSucc level = withIntern $ internLevelVal (LSucc level)

mkLevelMax :: (MonadState s m, HasInternState s) => HCLevel -> HCLevel -> m HCLevel
mkLevelMax lhs rhs = withIntern $ internLevelVal (LMax lhs rhs)

mkLevelIMax :: (MonadState s m, HasInternState s) => HCLevel -> HCLevel -> m HCLevel
mkLevelIMax lhs rhs = withIntern $ internLevelVal (LIMax lhs rhs)

mkLevelParam :: (MonadState s m, HasInternState s) => HCName -> m HCLevel
mkLevelParam name = withIntern $ internLevelVal (LVar name)

mkBVar :: (MonadState s m, HasInternState s) => Int -> m HCExpr
mkBVar idx = withIntern $ internExprVal (BVar idx)

-- mkFVar :: (MonadState s m, HasInternState s) => FVarId HCName -> m HCExpr
-- mkFVar fvarId = withIntern $ internExprVal (FVar fvarId)

mkSort :: (MonadState s m, HasInternState s) => HCLevel -> m HCExpr
mkSort level = withIntern $ internExprVal (Sort level)

mkConst :: (MonadState s m, HasInternState s) => HCName -> [HCLevel] -> m HCExpr
mkConst name levels = withIntern $ internExprVal (Const name levels)

mkApp :: (MonadState s m, HasInternState s) => HCExpr -> HCExpr -> m HCExpr
mkApp fn arg = withIntern $ internExprVal (App fn arg)

mkApps :: (MonadState s m, HasInternState s) => HCExpr -> [HCExpr] -> m HCExpr
mkApps = foldM mkApp

mkLam :: (MonadState s m, HasInternState s) => HCName -> HCExpr -> HCExpr -> BinderInfo -> m HCExpr
mkLam name ty body binderInfo = withIntern $ internExprVal (Lam name ty body binderInfo)

mkForall :: (MonadState s m, HasInternState s) => HCName -> HCExpr -> HCExpr -> BinderInfo -> m HCExpr
mkForall name ty body binderInfo = withIntern $ internExprVal (ForallE name ty body binderInfo)

mkLit :: (MonadState s m, HasInternState s) => Literal -> m HCExpr
mkLit lit = withIntern $ internExprVal (Lit lit)

mkLet :: (MonadState s m, HasInternState s) => HCName -> HCExpr -> HCExpr -> HCExpr -> Bool -> m HCExpr
mkLet name ty value body nondep = withIntern $ internExprVal (Let name ty value body nondep)

mkProj :: (MonadState s m, HasInternState s) => HCName -> Int -> HCExpr -> m HCExpr
mkProj name idx struct = withIntern $ internExprVal (Proj name idx struct)

isApp :: HCExpr -> Bool
isApp expr =
  case hceVal expr of
    App _ _ -> True
    _ -> False

getAppFn :: HCExpr -> HCExpr
getAppFn expr =
  case hceVal expr of
    App fn _ -> getAppFn fn
    _ -> expr

getAppArgs :: HCExpr -> [HCExpr]
getAppArgs = go []
  where
    go acc expr =
      case hceVal expr of
        App fn arg -> go (arg : acc) fn
        _ -> acc

getAppSpine :: HCExpr -> AppSpine
getAppSpine expr = AppSpine {appSpineFn = getAppFn expr, appSpineArgs = getAppArgs expr}

mkAppSpine :: (MonadState s m, HasInternState s) => AppSpine -> m HCExpr
mkAppSpine (AppSpine fn args) = mkApps fn args

viewConstApp :: HCExpr -> Maybe ConstAppView
viewConstApp expr =
  case hceVal (getAppFn expr) of
    Const name levels ->
      Just
        ConstAppView
          { constAppName = name,
            constAppLevels = levels,
            constAppArgs = getAppArgs expr
          }
    _ -> Nothing

viewProj :: HCExpr -> Maybe ProjView
viewProj expr =
  case hceVal expr of
    Proj name idx struct ->
      Just
        ProjView
          { projViewTypeName = name,
            projViewIndex = idx,
            projViewStruct = struct
          }
    _ -> Nothing

mkProjFromView :: (MonadState s m, HasInternState s) => ProjView -> m HCExpr
mkProjFromView projView = mkProj (projViewTypeName projView) (projViewIndex projView) (projViewStruct projView)

viewProjStructConstApp :: Int -> HCExpr -> Maybe ProjStructConstAppView
viewProjStructConstApp minArgs expr = do
  projView <- viewProj expr
  constView <- viewConstApp (projViewStruct projView)
  if length (constAppArgs constView) < minArgs
    then Nothing
    else
      Just
        ProjStructConstAppView
          { projStructTypeName = projViewTypeName projView,
            projStructIndex = projViewIndex projView,
            projStructConstName = constAppName constView,
            projStructConstLevels = constAppLevels constView,
            projStructArgs = constAppArgs constView
          }

viewLam :: HCExpr -> Maybe BinderView
viewLam expr =
  case hceVal expr of
    Lam name ty body binderInfo ->
      Just
        BinderView
          { binderViewName = name,
            binderViewType = ty,
            binderViewBody = body,
            binderViewInfo = binderInfo
          }
    _ -> Nothing

viewForall :: HCExpr -> Maybe BinderView
viewForall expr =
  case hceVal expr of
    ForallE name ty body binderInfo ->
      Just
        BinderView
          { binderViewName = name,
            binderViewType = ty,
            binderViewBody = body,
            binderViewInfo = binderInfo
          }
    _ -> Nothing

viewLet :: HCExpr -> Maybe LetView
viewLet expr =
  case hceVal expr of
    Let name ty value body nondep ->
      Just
        LetView
          { letViewName = name,
            letViewType = ty,
            letViewValue = value,
            letViewBody = body,
            letViewNondep = nondep
          }
    _ -> Nothing

getLams :: HCExpr -> ([BinderView], HCExpr)
getLams = go []
  where
    go acc expr =
      case viewLam expr of
        Just binderView -> go (binderView : acc) (binderViewBody binderView)
        Nothing -> (reverse acc, expr)

getForalls :: HCExpr -> ([BinderView], HCExpr)
getForalls = go []
  where
    go acc expr =
      case viewForall expr of
        Just binderView -> go (binderView : acc) (binderViewBody binderView)
        Nothing -> (reverse acc, expr)

mkLams :: (MonadState s m, HasInternState s) => [BinderView] -> HCExpr -> m HCExpr
mkLams binderViews body = foldM mkLamStep body (reverse binderViews)
  where
    mkLamStep inner binderView = mkLam (binderViewName binderView) (binderViewType binderView) inner (binderViewInfo binderView)

mkForalls :: (MonadState s m, HasInternState s) => [BinderView] -> HCExpr -> m HCExpr
mkForalls binderViews body = foldM mkForallStep body (reverse binderViews)
  where
    mkForallStep inner binderView = mkForall (binderViewName binderView) (binderViewType binderView) inner (binderViewInfo binderView)

mkLetFromView :: (MonadState s m, HasInternState s) => LetView -> m HCExpr
mkLetFromView letView = mkLet (letViewName letView) (letViewType letView) (letViewValue letView) (letViewBody letView) (letViewNondep letView)

openBinderView :: (MonadState s m, HasInternState s) => BinderView -> HCExpr -> m HCExpr
openBinderView binderView arg = instantiate1 arg (binderViewBody binderView)

openLetView :: (MonadState s m, HasInternState s) => LetView -> m HCExpr
openLetView letView = instantiate1 (letViewValue letView) (letViewBody letView)

instantiate1 :: (MonadState s m, HasInternState s) => HCExpr -> HCExpr -> m HCExpr
instantiate1 arg body = instantiateList 0 [arg] body

abstractFVar :: (MonadState s m, HasInternState s) => FVarId HCName -> HCExpr -> m HCExpr
abstractFVar fvarId body = abstractList 0 [fvarId] body

instantiate :: (MonadState s m, HasInternState s) => [HCExpr] -> HCExpr -> m HCExpr
instantiate args body
  | null args = pure body
  | otherwise = instantiateList 0 args body

instantiateList :: (MonadState s m, HasInternState s) => Int -> [HCExpr] -> HCExpr -> m HCExpr
instantiateList depth args expr =
  case hceVal expr of
    BVar idx
      | idx < depth -> pure expr
      | idx >= depth && idx < depth + numArgs -> do
          let argToApply = args !! (numArgs - 1 - (idx - depth))
          liftLooseBVars 0 depth argToApply
      | otherwise -> mkBVar (idx - numArgs)
    -- FVar _ -> pure expr
    Sort _ -> pure expr
    Const _ _ -> pure expr
    App fn arg -> do
      fn' <- instantiateList depth args fn
      arg' <- instantiateList depth args arg
      if fn' == fn && arg' == arg then pure expr else mkApp fn' arg'
    Lam name ty bndr bodyInfo -> do
      ty' <- instantiateList depth args ty
      bndr' <- instantiateList (depth + 1) args bndr
      if ty' == ty && bndr' == bndr then pure expr else mkLam name ty' bndr' bodyInfo
    ForallE name ty bndr bodyInfo -> do
      ty' <- instantiateList depth args ty
      bndr' <- instantiateList (depth + 1) args bndr
      if ty' == ty && bndr' == bndr then pure expr else mkForall name ty' bndr' bodyInfo
    Lit _ -> pure expr
    Let name ty val bndr nondep -> do
      ty' <- instantiateList depth args ty
      val' <- instantiateList depth args val
      bndr' <- instantiateList (depth + 1) args bndr
      if ty' == ty && val' == val && bndr' == bndr then pure expr else mkLet name ty' val' bndr' nondep
    Proj name idx struct -> do
      struct' <- instantiateList depth args struct
      if struct' == struct then pure expr else mkProj name idx struct'
  where
    numArgs = length args

abstractFVars :: (MonadState s m, HasInternState s) => [FVarId HCName] -> HCExpr -> m HCExpr
abstractFVars fvarIds body
  | null fvarIds = pure body
  | otherwise = abstractList 0 fvarIds body

abstractList :: (MonadState s m, HasInternState s) => Int -> [FVarId HCName] -> HCExpr -> m HCExpr
abstractList depth fvarIds expr =
  case hceVal expr of
    BVar idx
      | idx < depth -> pure expr
      | otherwise -> mkBVar (idx + length fvarIds)
    -- FVar fv ->
    --   case elemIndex fv fvarIds of
    --     Just pos -> mkBVar (depth + pos)
    --     Nothing -> pure expr
    Sort _ -> pure expr
    Const _ _ -> pure expr
    App fn arg -> do
      fn' <- abstractList depth fvarIds fn
      arg' <- abstractList depth fvarIds arg
      if fn' == fn && arg' == arg
        then pure expr
        else mkApp fn' arg'
    Lam name ty body binderInfo -> do
      ty' <- abstractList depth fvarIds ty
      body' <- abstractList (depth + 1) fvarIds body
      if ty' == ty && body' == body
        then pure expr
        else mkLam name ty' body' binderInfo
    ForallE name ty body binderInfo -> do
      ty' <- abstractList depth fvarIds ty
      body' <- abstractList (depth + 1) fvarIds body
      if ty' == ty && body' == body
        then pure expr
        else mkForall name ty' body' binderInfo
    Lit _ -> pure expr
    Let name ty value body nondep -> do
      ty' <- abstractList depth fvarIds ty
      value' <- abstractList depth fvarIds value
      body' <- abstractList (depth + 1) fvarIds body
      if ty' == ty && value' == value && body' == body
        then pure expr
        else mkLet name ty' value' body' nondep
    Proj name idx struct -> do
      struct' <- abstractList depth fvarIds struct
      if struct' == struct
        then pure expr
        else mkProj name idx struct'

instantiateLevelParams :: (MonadState s m, HasInternState s) => [(HCName, HCLevel)] -> HCExpr -> m HCExpr
instantiateLevelParams subst = instantiateLevelParamsBy (lookupSubst subst)

instantiateLevelParamsExpr :: (MonadState s m, HasInternState s) => [(HCName, HCLevel)] -> Expr' HCExpr HCLevel HCName -> m HCExpr
instantiateLevelParamsExpr subst = instantiateLevelParamsExprBy (lookupSubst subst)

instantiateLevelParamsLevel :: (MonadState s m, HasInternState s) => [(HCName, HCLevel)] -> HCLevel -> m HCLevel
instantiateLevelParamsLevel subst = instantiateLevelParamsLevelBy (lookupSubst subst)

lookupSubst :: [(HCName, HCLevel)] -> HCName -> Maybe HCLevel
lookupSubst subst name = IntMap.lookup (hcnId name) substMap
  where
    substMap = IntMap.fromList [(hcnId key, value) | (key, value) <- subst]

instantiateLevelParamsBy :: (MonadState s m, HasInternState s) => (HCName -> Maybe HCLevel) -> HCExpr -> m HCExpr
instantiateLevelParamsBy subst expr =
  case hceVal expr of
    BVar _ -> pure expr
    -- FVar _ -> pure expr
    Sort level -> do
      level' <- instantiateLevelParamsLevelBy subst level
      if level' == level then pure expr else mkSort level'
    Const name levels -> do
      levels' <- traverse (instantiateLevelParamsLevelBy subst) levels
      if levels' == levels then pure expr else mkConst name levels'
    App fn arg -> do
      fn' <- instantiateLevelParamsBy subst fn
      arg' <- instantiateLevelParamsBy subst arg
      if fn' == fn && arg' == arg then pure expr else mkApp fn' arg'
    Lam name ty body binderInfo -> do
      ty' <- instantiateLevelParamsBy subst ty
      body' <- instantiateLevelParamsBy subst body
      if ty' == ty && body' == body then pure expr else mkLam name ty' body' binderInfo
    ForallE name ty body binderInfo -> do
      ty' <- instantiateLevelParamsBy subst ty
      body' <- instantiateLevelParamsBy subst body
      if ty' == ty && body' == body then pure expr else mkForall name ty' body' binderInfo
    Lit _ -> pure expr
    Let name ty value body nondep -> do
      ty' <- instantiateLevelParamsBy subst ty
      value' <- instantiateLevelParamsBy subst value
      body' <- instantiateLevelParamsBy subst body
      if ty' == ty && value' == value && body' == body then pure expr else mkLet name ty' value' body' nondep
    Proj name idx struct -> do
      struct' <- instantiateLevelParamsBy subst struct
      if struct' == struct then pure expr else mkProj name idx struct'

instantiateLevelParamsExprBy :: (MonadState s m, HasInternState s) => (HCName -> Maybe HCLevel) -> Expr' HCExpr HCLevel HCName -> m HCExpr
instantiateLevelParamsExprBy subst expr =
  case expr of
    BVar idx -> mkBVar idx
    -- FVar fvarId -> mkFVar fvarId
    Sort level -> mkSort =<< instantiateLevelParamsLevelBy subst level
    Const name levels -> mkConst name =<< traverse (instantiateLevelParamsLevelBy subst) levels
    App fn arg -> do
      fn' <- instantiateLevelParamsBy subst fn
      arg' <- instantiateLevelParamsBy subst arg
      mkApp fn' arg'
    Lam name ty body binderInfo -> do
      ty' <- instantiateLevelParamsBy subst ty
      body' <- instantiateLevelParamsBy subst body
      mkLam name ty' body' binderInfo
    ForallE name ty body binderInfo -> do
      ty' <- instantiateLevelParamsBy subst ty
      body' <- instantiateLevelParamsBy subst body
      mkForall name ty' body' binderInfo
    Lit lit -> mkLit lit
    Let name ty value body nondep -> do
      ty' <- instantiateLevelParamsBy subst ty
      value' <- instantiateLevelParamsBy subst value
      body' <- instantiateLevelParamsBy subst body
      mkLet name ty' value' body' nondep
    Proj name idx struct -> do
      struct' <- instantiateLevelParamsBy subst struct
      mkProj name idx struct'

instantiateLevelParamsLevelBy :: (MonadState s m, HasInternState s) => (HCName -> Maybe HCLevel) -> HCLevel -> m HCLevel
instantiateLevelParamsLevelBy subst level =
  case hclVal level of
    LZero -> mkLevelZero
    LSucc inner -> do
      inner' <- instantiateLevelParamsLevelBy subst inner
      if inner' == inner then pure level else mkLevelSucc inner'
    LMax lhs rhs -> do
      lhs' <- instantiateLevelParamsLevelBy subst lhs
      rhs' <- instantiateLevelParamsLevelBy subst rhs
      if lhs' == lhs && rhs' == rhs then pure level else mkLevelMax lhs' rhs'
    LIMax lhs rhs -> do
      lhs' <- instantiateLevelParamsLevelBy subst lhs
      rhs' <- instantiateLevelParamsLevelBy subst rhs
      if lhs' == lhs && rhs' == rhs then pure level else mkLevelIMax lhs' rhs'
    LVar name ->
      case subst name of
        Just replacement -> pure replacement
        Nothing -> pure level

liftLooseBVars :: (MonadState s m, HasInternState s) => Int -> Int -> HCExpr -> m HCExpr
liftLooseBVars cutoff delta expr
  | delta == 0 = pure expr
  | otherwise =
      case hceVal expr of
        BVar idx
          | idx < cutoff -> pure expr
          | otherwise -> mkBVar $ idx + delta
        -- FVar _ -> pure expr
        Sort _ -> pure expr
        Const _ _ -> pure expr
        App fn arg -> do
          fn' <- liftLooseBVars cutoff delta fn
          arg' <- liftLooseBVars cutoff delta arg
          if fn' == fn && arg' == arg
            then pure expr
            else mkApp fn' arg'
        Lam name ty body binderInfo -> do
          ty' <- liftLooseBVars cutoff delta ty
          body' <- liftLooseBVars (cutoff + 1) delta body
          if ty' == ty && body' == body
            then pure expr
            else mkLam name ty' body' binderInfo
        ForallE name ty body binderInfo -> do
          ty' <- liftLooseBVars cutoff delta ty
          body' <- liftLooseBVars (cutoff + 1) delta body
          if ty' == ty && body' == body
            then pure expr
            else mkForall name ty' body' binderInfo
        Lit _ -> pure expr
        Let name ty value body nondep -> do
          ty' <- liftLooseBVars cutoff delta ty
          value' <- liftLooseBVars cutoff delta value
          body' <- liftLooseBVars (cutoff + 1) delta body
          if ty' == ty && value' == value && body' == body
            then pure expr
            else mkLet name ty' value' body' nondep
        Proj name idx struct -> do
          struct' <- liftLooseBVars cutoff delta struct
          if struct' == struct
            then pure expr
            else mkProj name idx struct'
