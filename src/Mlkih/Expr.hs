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
import Numeric.Natural

data Literal = NatVal Natural | StrVal String
  deriving (Show, Eq, Ord)

instance PrettyPrint Literal where
  ppr literal =
    case literal of
      NatVal n -> cyan (ppr n)
      StrVal s -> yellow (viaShow s)

instance Hashable Literal where
  hashWithSalt salt (NatVal n) = hashWithSalt (hashWithSalt salt (0 :: Int)) n
  hashWithSalt salt (StrVal s) = hashWithSalt (hashWithSalt salt (1 :: Int)) s

data BinderInfo = Default | Implicit | StrictImplicit | InstImplicit
  deriving (Show, Eq, Ord, Enum)

instance PrettyPrint BinderInfo where
  ppr binderInfo =
    case binderInfo of
      Default -> ppr "default"
      Implicit -> ppr "implicit"
      StrictImplicit -> ppr "strictImplicit"
      InstImplicit -> ppr "instImplicit"

instance Hashable BinderInfo where
  hashWithSalt salt binderInfo = hashWithSalt salt (fromEnum binderInfo :: Int)

data Expr' e l n
  = BVar Int
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
      BVar idx -> cyan (ppr '#' <> ppr idx)
      Sort level -> bold (yellow (ppr "Sort")) <> dim (parens (ppr level))
      Const name levels ->
        green (ppr name)
          <> if null levels
            then ppr ""
            else dim (brackets (hcatWithComma (fmap ppr levels)))
      App fn arg ->
        ppParens (sep [ppr fn, ppr arg])
      Lam name ty body binderInfo ->
        ppParens
          ( sep
              [ magenta (ppr "λ") <+> ppBinder binderInfo name ty,
                magenta (ppr "=>") <+> ppr body
              ]
          )
      ForallE name ty body binderInfo ->
        ppParens
          ( sep
              [ magenta (ppr "∀") <+> ppBinder binderInfo name ty <> magenta (ppr ","),
                ppr body
              ]
          )
      Lit lit -> ppr lit
      Let name ty value body nondep ->
        ppParens
          ( sep
              [ ( if nondep
                    then magenta (ppr "have")
                    else magenta (ppr "let")
                )
                  <+> ppr name
                  <+> dim (ppr ':')
                  <+> ppr ty,
                magenta (ppr ":=") <+> ppr value <> magenta (ppr ";"),
                ppr body
              ]
          )
      Proj name idx struct ->
        group (green (ppr name) <> dim (ppr '.') <> cyan (ppr idx) <> dim (parens (ppr struct)))
    where
      ppParens doc = group (dim (ppr '(') <> align doc <> dim (ppr ')'))

ppBinder :: (PrettyPrint ty, PrettyPrint name) => BinderInfo -> name -> ty -> Doc
ppBinder binderInfo name ty =
  let n = ppr name
      colon = dim (ppr ':')
      t = ppr ty
      inner = (n <+> colon <+> t)
   in case binderInfo of
        Default -> dim (ppr '(') <> inner <> dim (ppr ')')
        Implicit -> dim (ppr '{') <> inner <> dim (ppr '}')
        StrictImplicit -> dim (ppr "{{") <> inner <> dim (ppr "}}")
        InstImplicit -> dim (ppr '[') <> inner <> dim (ppr ']')

instance (Hashable e, Hashable l, Hashable n) => Hashable (Expr' e l n) where
  hashWithSalt salt expr =
    case expr of
      BVar idx -> hashWithSalt (hashWithSalt salt (0 :: Int)) idx
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
