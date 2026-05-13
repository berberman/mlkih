module Mlkih.Decl
  ( Decl (..),
    InductiveDecl (..),
    declNames,
  )
where

import Mlkih.Env
import Mlkih.Name
import Mlkih.Pretty

data InductiveDecl e l = InductiveDecl
  { indTypes :: [InductiveVal e l],
    indConstructors :: [ConstructorVal e l],
    indRecursors :: [RecursorVal e l]
  }
  deriving (Show, Eq, Ord)

data Decl e l
  = AxiomDecl (AxiomVal e l)
  | DefnDecl (DefinitionVal e l)
  | ThmDecl (TheoremVal e l)
  | OpaqueDecl (OpaqueVal e l)
  | QuotDecl (QuotVal e l)
  | CtorDecl (ConstructorVal e l)
  | RecDecl (RecursorVal e l)
  | InductiveBlockDecl (InductiveDecl e l)
  deriving (Show, Eq, Ord)

instance (PrettyPrint e, PrettyPrint l) => PrettyPrint (InductiveDecl e l) where
  ppr indDecl =
    text "inductive-block"
      <+> braces
        ( (text "types =" <+> brackets (hcatWithComma (fmap ppr (indTypes indDecl))))
            <> text ", ctors = "
            <> brackets (hcatWithComma (fmap ppr (indConstructors indDecl)))
            <> text ", recs = "
            <> brackets (hcatWithComma (fmap ppr (indRecursors indDecl)))
        )

instance (PrettyPrint e, PrettyPrint l) => PrettyPrint (Decl e l) where
  ppr decl =
    case decl of
      AxiomDecl ax -> ppr ax
      DefnDecl defn -> ppr defn
      ThmDecl thm -> ppr thm
      OpaqueDecl opaqueVal -> ppr opaqueVal
      QuotDecl quotVal -> ppr quotVal
      CtorDecl ctor -> ppr ctor
      RecDecl recVal -> ppr recVal
      InductiveBlockDecl indDecl -> ppr indDecl

declNames :: Decl e l -> [HCName]
declNames decl = case decl of
  AxiomDecl ax -> [constName ax]
  DefnDecl defn -> [constName $ defConst defn]
  ThmDecl thm -> [constName $ thmConst thm]
  OpaqueDecl opaque -> [constName $ opaqueConst opaque]
  QuotDecl quotVal -> [constName $ quotConst quotVal]
  CtorDecl ctor -> [constName $ ctorConst ctor]
  RecDecl recursor -> [constName $ recConst recursor]
  InductiveBlockDecl indDecl ->
    fmap (constName . indConst) (indTypes indDecl)
      <> fmap (constName . ctorConst) (indConstructors indDecl)
      <> fmap (constName . recConst) (indRecursors indDecl)
