module Mlkih.Env where

import Data.IntMap (IntMap)
import qualified Data.IntMap as IntMap
import Mlkih.Expr
import Mlkih.Level
import Mlkih.Name
import Mlkih.Pretty

data ConstantVal e l = ConstantVal
  { constName :: HCName,
    constLevelParameters :: [HCName],
    constType :: Expr' e l HCName
  }
  deriving (Show, Eq, Ord)

type AxiomVal = ConstantVal

data ReducibilityHints
  = Opaque
  | Abbrev
  | Regular Int
  deriving (Show, Eq)

data ReducibilityHintClass
  = OpaqueHint
  | AbbrevHint
  | RegularHint
  deriving (Show, Eq, Ord)

instance PrettyPrint ReducibilityHints where
  ppr hints =
    case hints of
      Opaque -> text "opaque"
      Abbrev -> text "abbrev"
      Regular n -> text "regular" <+> int n

instance Ord ReducibilityHints where
  compare Abbrev Abbrev = EQ
  compare Abbrev _ = LT
  compare (Regular _) Abbrev = GT
  compare (Regular n) (Regular m) = compare m n
  compare (Regular _) Opaque = LT
  compare Opaque Opaque = EQ
  compare Opaque _ = GT

reducibilityHintClass :: ReducibilityHints -> ReducibilityHintClass
reducibilityHintClass hints =
  case hints of
    Opaque -> OpaqueHint
    Abbrev -> AbbrevHint
    Regular _ -> RegularHint

reducibilityHintRegularHeight :: ReducibilityHints -> Maybe Int
reducibilityHintRegularHeight hints =
  case hints of
    Regular height -> Just height
    _ -> Nothing

compareReducibilityHintsForDelta :: ReducibilityHints -> ReducibilityHints -> Ordering
compareReducibilityHintsForDelta lhs rhs =
  case (lhs, rhs) of
    (Abbrev, Abbrev) -> EQ
    (Abbrev, _) -> LT
    (Regular _, Abbrev) -> GT
    (Regular lhsHeight, Regular rhsHeight) -> compare rhsHeight lhsHeight
    (Regular _, Opaque) -> LT
    (Opaque, Opaque) -> EQ
    (Opaque, _) -> GT

data DefinitionVal e l = DefinitionVal
  { defConst :: ConstantVal e l,
    defHints :: ReducibilityHints,
    defValue :: Expr' e l HCName
  }
  deriving (Show, Eq, Ord)

data TheoremVal e l = TheoremVal
  { thmConst :: ConstantVal e l,
    thmValue :: Expr' e l HCName
  }
  deriving (Show, Eq, Ord)

data OpaqueVal e l = OpaqueVal
  { opaqueConst :: ConstantVal e l,
    opaqueValue :: Expr' e l HCName
  }
  deriving (Show, Eq, Ord)

data InductiveVal e l = InductiveVal
  { indConst :: ConstantVal e l,
    indParamsN :: Int,
    indIndicesN :: Int,
    indCtors :: [HCName]
  }
  deriving (Show, Eq, Ord)

data QuotKind = Quot | QuotMk | QuotLift | QuotInd
  deriving (Show, Eq, Ord, Enum)

instance PrettyPrint QuotKind where
  ppr quotKind =
    case quotKind of
      Quot -> text "type"
      QuotMk -> text "ctor"
      QuotLift -> text "lift"
      QuotInd -> text "ind"

data QuotVal e l = QuotVal
  { quotConst :: ConstantVal e l,
    quotKind :: QuotKind
  }
  deriving (Show, Eq, Ord)

data ConstructorVal e l = ConstructorVal
  { ctorConst :: ConstantVal e l,
    -- | Inductive type that this constructor belongs to
    ctorInductive :: HCName,
    -- | Position in the constructor list of the inductive type
    ctorIndex :: Int,
    -- | Number of parameters of the inductive type
    ctorParamsN :: Int,
    -- | Number of fields of the constructor (arity - number of parameters)
    ctorFieldsN :: Int
  }
  deriving (Show, Eq, Ord)

data RecursorRule e l = RecursorRule
  { -- | Constructor that this rule corresponds to
    recCtor :: HCName,
    -- | Number of fields (without counting inductive type parameters)
    recFieldsN :: Int,
    -- | Right-hand side of the rule
    recRhs :: Expr' e l HCName
  }
  deriving (Show, Eq, Ord)

data RecursorVal e l = RecursorVal
  { recConst :: ConstantVal e l,
    -- | Number of parameters
    recParamsN :: Int,
    -- | Number of indices
    recIndicesN :: Int,
    -- | Number of motives
    recMotivesN :: Int,
    -- | Number of minor premises
    recMinorsN :: Int,
    -- | Whether it supports k-reduction
    -- One constructor, zero constructor arguments, and inductive predicate.
    -- Examples: @Eq@, @Acc@, and @And.intro@
    recKRule :: Bool,
    -- |
    recRules :: [RecursorRule e l]
  }
  deriving (Show, Eq, Ord)

data ConstantInfo e l
  = AxiomInfo (AxiomVal e l)
  | DefnInfo (DefinitionVal e l)
  | ThmInfo (TheoremVal e l)
  | OpaqueInfo (OpaqueVal e l)
  | QuotInfo (QuotVal e l)
  | InductInfo (InductiveVal e l)
  | CtorInfo (ConstructorVal e l)
  | RecInfo (RecursorVal e l)
  deriving (Show, Eq, Ord)

constantInfoName :: ConstantInfo e l -> HCName
constantInfoName constantInfo =
  case constantInfo of
    AxiomInfo ax -> constName ax
    DefnInfo defn -> constName (defConst defn)
    ThmInfo thm -> constName (thmConst thm)
    OpaqueInfo opaqueVal -> constName (opaqueConst opaqueVal)
    QuotInfo quotVal -> constName (quotConst quotVal)
    InductInfo indVal -> constName (indConst indVal)
    CtorInfo ctor -> constName (ctorConst ctor)
    RecInfo recVal -> constName (recConst recVal)

constantInfoConst :: ConstantInfo e l -> ConstantVal e l
constantInfoConst constantInfo =
  case constantInfo of
    AxiomInfo ax -> ax
    DefnInfo defn -> defConst defn
    ThmInfo thm -> thmConst thm
    OpaqueInfo opaqueVal -> opaqueConst opaqueVal
    QuotInfo quotVal -> quotConst quotVal
    InductInfo indVal -> indConst indVal
    CtorInfo ctor -> ctorConst ctor
    RecInfo recVal -> recConst recVal

constantInfoBody :: ConstantInfo e l -> Maybe (Expr' e l HCName)
constantInfoBody constantInfo =
  case constantInfo of
    DefnInfo defn -> Just (defValue defn)
    ThmInfo thm -> Just (thmValue thm)
    OpaqueInfo opaqueVal -> Just (opaqueValue opaqueVal)
    _ -> Nothing

constantInfoHasBody :: ConstantInfo e l -> Bool
constantInfoHasBody = maybe False (const True) . constantInfoBody

constantInfoDeltaUnfoldability :: ConstantInfo e l -> Maybe ReducibilityHints
constantInfoDeltaUnfoldability constantInfo =
  case constantInfo of
    DefnInfo defn -> Just (defHints defn)
    _ -> Nothing

constantInfoIsDeltaUnfoldable :: ConstantInfo e l -> Bool
constantInfoIsDeltaUnfoldable = maybe False (const True) . constantInfoDeltaUnfoldability

type KernelEnv = IntMap (ConstantInfo HCExpr HCLevel)

insertConstantInfo :: ConstantInfo HCExpr HCLevel -> KernelEnv -> Either String KernelEnv
insertConstantInfo constantInfo env =
  let name = constantInfoName constantInfo
      key = hcnId name
   in case IntMap.lookup key env of
        Just _ -> Left ("duplicate constant in kernel env: " <> toString name)
        Nothing -> Right (IntMap.insert key constantInfo env)

insertConstantInfos :: [ConstantInfo HCExpr HCLevel] -> KernelEnv -> Either String KernelEnv
insertConstantInfos infos env = foldl step (Right env) infos
  where
    step acc info = acc >>= insertConstantInfo info

instance (PrettyPrint e, PrettyPrint l) => PrettyPrint (ConstantVal e l) where
  ppr constantVal =
    text "constant"
      <+> ppr (constName constantVal)
      <+> ppLevelParams (constLevelParameters constantVal)
      <+> char ':'
      <+> ppr (constType constantVal)

instance (PrettyPrint e, PrettyPrint l) => PrettyPrint (DefinitionVal e l) where
  ppr defn =
    ( text "def"
        <+> ppr (constName (defConst defn))
        <+> ppLevelParams (constLevelParameters (defConst defn))
        <+> char ':'
        <+> ppr (constType (defConst defn))
        <+> text ":="
        <+> ppr (defValue defn)
    )
      <+> (text "[" <> ppr (defHints defn) <> text "]")

instance (PrettyPrint e, PrettyPrint l) => PrettyPrint (TheoremVal e l) where
  ppr thm =
    text "theorem"
      <+> ppr (constName (thmConst thm))
      <+> ppLevelParams (constLevelParameters (thmConst thm))
      <+> char ':'
      <+> ppr (constType (thmConst thm))
      <+> text ":="
      <+> ppr (thmValue thm)

instance (PrettyPrint e, PrettyPrint l) => PrettyPrint (OpaqueVal e l) where
  ppr opaqueVal =
    text "opaque"
      <+> ppr (constName (opaqueConst opaqueVal))
      <+> ppLevelParams (constLevelParameters (opaqueConst opaqueVal))
      <+> char ':'
      <+> ppr (constType (opaqueConst opaqueVal))
      <+> text ":="
      <+> ppr (opaqueValue opaqueVal)

instance (PrettyPrint e, PrettyPrint l) => PrettyPrint (InductiveVal e l) where
  ppr indVal =
    ( text "inductive"
        <+> ppr (constName (indConst indVal))
        <+> ppLevelParams (constLevelParameters (indConst indVal))
        <+> char ':'
        <+> ppr (constType (indConst indVal))
    )
      <+> ( text "[params="
              <> int (indParamsN indVal)
              <> text ", indices="
              <> int (indIndicesN indVal)
              <> text ", ctors="
              <> brackets (hcatWithComma (fmap ppr (indCtors indVal)))
              <> text "]"
          )

instance (PrettyPrint e, PrettyPrint l) => PrettyPrint (QuotVal e l) where
  ppr quotVal =
    ( text "quot"
        <+> ppr (constName (quotConst quotVal))
        <+> ppLevelParams (constLevelParameters (quotConst quotVal))
        <+> char ':'
        <+> ppr (constType (quotConst quotVal))
    )
      <+> (text "[kind=" <> ppr (quotKind quotVal) <> text "]")

instance (PrettyPrint e, PrettyPrint l) => PrettyPrint (ConstructorVal e l) where
  ppr ctor =
    ( text "ctor"
        <+> ppr (constName (ctorConst ctor))
        <+> ppLevelParams (constLevelParameters (ctorConst ctor))
        <+> char ':'
        <+> ppr (constType (ctorConst ctor))
    )
      <+> ( text "[inductive="
              <> ppr (ctorInductive ctor)
              <> text ", idx="
              <> int (ctorIndex ctor)
              <> text ", params="
              <> int (ctorParamsN ctor)
              <> text ", fields="
              <> int (ctorFieldsN ctor)
              <> text "]"
          )

instance (PrettyPrint e, PrettyPrint l) => PrettyPrint (RecursorRule e l) where
  ppr rule =
    (text "rule" <+> ppr (recCtor rule))
      <+> (text "[fields=" <> int (recFieldsN rule) <> text "] :=")
      <+> ppr (recRhs rule)

instance (PrettyPrint e, PrettyPrint l) => PrettyPrint (RecursorVal e l) where
  ppr recVal =
    ( text "recursor"
        <+> ppr (constName (recConst recVal))
        <+> ppLevelParams (constLevelParameters (recConst recVal))
        <+> char ':'
        <+> ppr (constType (recConst recVal))
    )
      <+> ( text "[params="
              <> int (recParamsN recVal)
              <> text ", indices="
              <> int (recIndicesN recVal)
              <> text ", motives="
              <> int (recMotivesN recVal)
              <> text ", minors="
              <> int (recMinorsN recVal)
              <> text ", k="
              <> text (show (recKRule recVal))
              <> text ", rules="
              <> brackets (hcatWithComma (fmap ppr (recRules recVal)))
              <> text "]"
          )

instance (PrettyPrint e, PrettyPrint l) => PrettyPrint (ConstantInfo e l) where
  ppr constantInfo =
    case constantInfo of
      AxiomInfo ax -> ppr ax
      DefnInfo defn -> ppr defn
      ThmInfo thm -> ppr thm
      OpaqueInfo opaqueVal -> ppr opaqueVal
      QuotInfo quotVal -> ppr quotVal
      InductInfo indVal -> ppr indVal
      CtorInfo ctor -> ppr ctor
      RecInfo recVal -> ppr recVal

ppLevelParams :: [HCName] -> Doc
ppLevelParams [] = text ""
ppLevelParams levelParams = brackets (hcatWithComma (fmap ppr levelParams))
