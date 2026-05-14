{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeFamilies #-}

module Mlkih.Expr where

import Data.Hashable (Hashable (hashWithSalt))
import Mlkih.Level
import Mlkih.Name
import Mlkih.Pretty
import Mlkih.Types

data Literal = NatVal Int | StrVal String
  deriving (Show, Eq, Ord)

instance PrettyPrint Literal where
  ppr literal =
    case literal of
      NatVal n -> cyan (int n)
      StrVal s -> yellow (text (show s))

instance Hashable Literal where
  hashWithSalt salt (NatVal n) = hashWithSalt (hashWithSalt salt (0 :: Int)) n
  hashWithSalt salt (StrVal s) = hashWithSalt (hashWithSalt salt (1 :: Int)) s

newtype FVarId n = FVarId n
  deriving (Show, Eq, Ord)

instance (Hashable n) => Hashable (FVarId n) where
  hashWithSalt salt (FVarId name) = hashWithSalt salt name

instance (PrettyPrint n) => PrettyPrint (FVarId n) where
  ppr (FVarId name) = char '@' <> ppr name

data BinderInfo = Default | Implicit | StrictImplicit | InstImplicit
  deriving (Show, Eq, Ord, Enum)

instance PrettyPrint BinderInfo where
  ppr binderInfo =
    case binderInfo of
      Default -> text "default"
      Implicit -> text "implicit"
      StrictImplicit -> text "strictImplicit"
      InstImplicit -> text "instImplicit"

instance Hashable BinderInfo where
  hashWithSalt salt binderInfo = hashWithSalt salt (fromEnum binderInfo :: Int)

data Expr' e l n
  = BVar Int
  | FVar (FVarId n)
  | Sort l
  | Const n [l]
  | App e e
  | Lam n e e BinderInfo
  | ForallE n e e BinderInfo
  | Lit Literal
  | Let n e e e Bool
  | Proj n Int e
  deriving (Show, Eq, Ord)

instance (PrettyPrint e, PrettyPrint l, PrettyPrint n) => PrettyPrint (Expr' e l n) where
  ppr expr =
    case expr of
      BVar idx -> cyan (char '#' <> int idx)
      FVar fvarId -> ppr fvarId
      Sort level -> bold (yellow (text "Sort")) <> dim (parens (ppr level))
      Const name levels ->
        green (ppr name)
          <> if null levels
            then text ""
            else dim (brackets (hcatWithComma (fmap ppr levels)))
      App fn arg ->
        dim (char '(') <> (ppr fn <+> ppr arg) <> dim (char ')')
      Lam name ty body binderInfo ->
        dim (char '(')
          <> ( magenta (text "λ")
                 <+> ppBinder binderInfo name ty
                 <+> magenta (text "=>")
                 <+> ppr body
             )
          <> dim (char ')')
      ForallE name ty body binderInfo ->
        dim (char '(')
          <> ( magenta (text "∀")
                 <+> ppBinder binderInfo name ty
                 <+> magenta (char ',')
                 <+> ppr body
             )
          <> dim (char ')')
      Lit lit -> ppr lit
      Let name ty value body nondep ->
        dim (char '(')
          <> ( ( if nondep
                   then magenta (text "have")
                   else magenta (text "let")
               )
                 <+> ppr name
                 <+> dim (char ':')
                 <+> ppr ty
                 <+> magenta (text ":=")
                 <+> ppr value
                 <+> magenta (char ';')
                 <+> ppr body
             )
          <> dim (char ')')
      Proj name idx struct ->
        green (ppr name) <> dim (char '.') <> cyan (int idx) <> dim (parens (ppr struct))
    where

ppBinder :: (PrettyPrint ty, PrettyPrint name) => BinderInfo -> name -> ty -> Doc
ppBinder binderInfo name ty =
  let n = ppr name
      colon = dim (char ':')
      t = ppr ty
      inner = (n <+> colon <+> t)
   in case binderInfo of
        Default -> dim (char '(') <> inner <> dim (char ')')
        Implicit -> dim (char '{') <> inner <> dim (char '}')
        StrictImplicit -> dim (text "{{") <> inner <> dim (text "}}")
        InstImplicit -> dim (char '[') <> inner <> dim (char ']')

instance (Hashable e, Hashable l, Hashable n) => Hashable (Expr' e l n) where
  hashWithSalt salt expr =
    case expr of
      BVar idx -> hashWithSalt (hashWithSalt salt (0 :: Int)) idx
      FVar fvarId -> hashWithSalt (hashWithSalt salt (1 :: Int)) fvarId
      Sort level -> hashWithSalt (hashWithSalt salt (2 :: Int)) level
      Const name levels -> hashWithSalt (hashWithSalt (hashWithSalt salt (3 :: Int)) name) levels
      App fn arg -> hashWithSalt (hashWithSalt (hashWithSalt salt (4 :: Int)) fn) arg
      Lam name ty body binderInfo -> hashWithSalt (hashWithSalt (hashWithSalt (hashWithSalt salt (5 :: Int)) name) ty) (body, binderInfo)
      ForallE name ty body binderInfo -> hashWithSalt (hashWithSalt (hashWithSalt (hashWithSalt salt (6 :: Int)) name) ty) (body, binderInfo)
      Lit lit -> hashWithSalt (hashWithSalt salt (7 :: Int)) lit
      Let name ty value body nondep -> hashWithSalt (hashWithSalt (hashWithSalt (hashWithSalt salt (8 :: Int)) name) ty) (value, body, nondep)
      Proj name idx struct -> hashWithSalt (hashWithSalt (hashWithSalt (hashWithSalt salt (9 :: Int)) name) idx) struct

newtype Expr = Expr {unExpr :: Expr' Expr Level Name}
  deriving (Show, Eq, Ord)

data HCExpr = HCExpr
  { hceId :: {-# UNPACK #-} !HCId,
    hceVal :: Expr' HCExpr HCLevel HCName
  }
  deriving (Show)

instance Eq HCExpr where
  lhs == rhs = hceId lhs == hceId rhs

instance Ord HCExpr where
  compare lhs rhs = compare (hceId lhs) (hceId rhs)

instance Hashable HCExpr where
  hashWithSalt salt = hashWithSalt salt . hceId

class HasExpr a where
  getExpr :: a -> Expr' a (LevelOf a) (NameOf a)

type instance NameOf Expr = Name

type instance LevelOf Expr = Level

instance HasExpr Expr where
  getExpr = unExpr

type instance NameOf HCExpr = HCName

type instance LevelOf HCExpr = HCLevel

instance HasExpr HCExpr where
  getExpr = hceVal

instance PrettyPrint Expr where
  ppr = ppr . getExpr

instance PrettyPrint HCExpr where
  ppr = ppr . getExpr
