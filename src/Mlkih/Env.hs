module Mlkih.Env where

import Data.IntMap (IntMap)
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

--------------------------------------------------------------------------------

data ReducibilityHints
  = Opaque
  | Abbrev
  | -- | Height of this definition.
    -- If both two definitions are regular, the one with larger height will be unfolded first.
    Regular Int
  deriving (Show, Eq)

instance PrettyPrint ReducibilityHints where
  ppr hints =
    case hints of
      Opaque -> ppr "opaque"
      Abbrev -> ppr "abbrev"
      Regular n -> group (ppr "regular" <+> ppr n)

-- | Smaller hints (larger heights) are unfolded first.
instance Ord ReducibilityHints where
  compare Abbrev Abbrev = EQ
  compare Abbrev _ = LT
  compare (Regular _) Abbrev = GT
  compare (Regular n) (Regular m) = compare m n
  compare (Regular _) Opaque = LT
  compare Opaque Opaque = EQ
  compare Opaque _ = GT

--------------------------------------------------------------------------------

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
    -- | Number of parameters
    indParamsN :: Int,
    -- | Number of indices
    indIndicesN :: Int,
    -- | List the name of the constructors for this inductive type
    indCtors :: [HCName]
  }
  deriving (Show, Eq, Ord)

--------------------------------------------------------------------------------

data QuotKind
  = -- | @Quot@
    Quot
  | -- | @Quot.mk@
    QuotMk
  | -- | @Quot.lift@
    QuotLift
  | -- | @Quot.ind@
    QuotInd
  deriving (Show, Eq, Ord, Enum)

instance PrettyPrint QuotKind where
  ppr quotKind =
    case quotKind of
      Quot -> ppr "type"
      QuotMk -> ppr "ctor"
      QuotLift -> ppr "lift"
      QuotInd -> ppr "ind"

data QuotVal e l = QuotVal
  { quotConst :: ConstantVal e l,
    quotKind :: QuotKind
  }
  deriving (Show, Eq, Ord)

--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------

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
    recRules :: [RecursorRule e l]
  }
  deriving (Show, Eq, Ord)

recursorFirstMotiveIdx :: RecursorVal e l -> Int
recursorFirstMotiveIdx v =
  recParamsN v

recursorFirstMinorIdx :: RecursorVal e l -> Int
recursorFirstMinorIdx v =
  recParamsN v + recMotivesN v

recursorFirstIndexIdx :: RecursorVal e l -> Int
recursorFirstIndexIdx v =
  recParamsN v + recMotivesN v + recMinorsN v

recursorMajorIdx :: RecursorVal e l -> Int
recursorMajorIdx v =
  recParamsN v + recMotivesN v + recMinorsN v + recIndicesN v

recursorExpectedArgs :: RecursorVal e l -> Int
recursorExpectedArgs v =
  recursorMajorIdx v + 1

--------------------------------------------------------------------------------

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

constantInfoKindName :: ConstantInfo e l -> String
constantInfoKindName info =
  case info of
    AxiomInfo {} -> "axiom"
    DefnInfo {} -> "definition"
    ThmInfo {} -> "theorem"
    OpaqueInfo {} -> "opaque"
    QuotInfo {} -> "quot"
    CtorInfo {} -> "constructor"
    RecInfo {} -> "recursor"
    InductInfo {} -> "inductive"

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

--------------------------------------------------------------------------------

type KernelEnv = IntMap (ConstantInfo HCExpr HCLevel)

--------------------------------------------------------------------------------
instance (PrettyPrint e, PrettyPrint l) => PrettyPrint (ConstantVal e l) where
  ppr constantVal =
    ppConstSignature "constant" constantVal

instance (PrettyPrint e, PrettyPrint l) => PrettyPrint (DefinitionVal e l) where
  ppr defn =
    ppConstBody
      "def"
      (defConst defn)
      (defValue defn)
      [ppAttr [ppFieldDoc "hint" (ppr (defHints defn))]]

instance (PrettyPrint e, PrettyPrint l) => PrettyPrint (TheoremVal e l) where
  ppr thm =
    ppConstBody "theorem" (thmConst thm) (thmValue thm) []

instance (PrettyPrint e, PrettyPrint l) => PrettyPrint (OpaqueVal e l) where
  ppr opaqueVal =
    ppConstBody "opaque" (opaqueConst opaqueVal) (opaqueValue opaqueVal) []

instance (PrettyPrint e, PrettyPrint l) => PrettyPrint (InductiveVal e l) where
  ppr indVal =
    ppConstSignature "inductive" (indConst indVal)
      <+> ppAttr
        [ ppFieldDoc "params" (ppr (indParamsN indVal)),
          ppFieldDoc "indices" (ppr (indIndicesN indVal)),
          ppFieldDoc "ctors" (ppr (indCtors indVal))
        ]

instance (PrettyPrint e, PrettyPrint l) => PrettyPrint (QuotVal e l) where
  ppr quotVal =
    ppConstSignature "quot" (quotConst quotVal)
      <+> ppAttr [ppFieldDoc "kind" (ppr (quotKind quotVal))]

instance (PrettyPrint e, PrettyPrint l) => PrettyPrint (ConstructorVal e l) where
  ppr ctor =
    ppConstSignature "ctor" (ctorConst ctor)
      <+> ppAttr
        [ ppFieldDoc "inductive" (ppr (ctorInductive ctor)),
          ppFieldDoc "idx" (ppr (ctorIndex ctor)),
          ppFieldDoc "params" (ppr (ctorParamsN ctor)),
          ppFieldDoc "fields" (ppr (ctorFieldsN ctor))
        ]

instance (PrettyPrint e, PrettyPrint l) => PrettyPrint (RecursorRule e l) where
  ppr rule =
    group $
      hang 2 $
        sep
          [ ppr "rule" <+> ppr (recCtor rule),
            ppAttr [ppFieldDoc "fields" (ppr (recFieldsN rule))] <+> magenta (ppr ":="),
            ppr (recRhs rule)
          ]

instance (PrettyPrint e, PrettyPrint l) => PrettyPrint (RecursorVal e l) where
  ppr recVal =
    ppConstSignature "recursor" (recConst recVal)
      <+> ppAttr
        [ ppFieldDoc "params" (ppr (recParamsN recVal)),
          ppFieldDoc "indices" (ppr (recIndicesN recVal)),
          ppFieldDoc "motives" (ppr (recMotivesN recVal)),
          ppFieldDoc "minors" (ppr (recMinorsN recVal)),
          ppFieldDoc "k" (ppr (show (recKRule recVal))),
          ppFieldDoc "rules" (brackets (hcatWithComma (fmap ppr (recRules recVal))))
        ]

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

ppConstSignature :: (PrettyPrint e, PrettyPrint l) => String -> ConstantVal e l -> Doc
ppConstSignature keyword constantVal =
  group $
    hang 2 $
      sep
        [ ppConstHead keyword constantVal <+> dim (ppr ':'),
          ppr (constType constantVal)
        ]

ppConstBody :: (PrettyPrint e, PrettyPrint l) => String -> ConstantVal e l -> Expr' e l HCName -> [Doc] -> Doc
ppConstBody keyword constantVal rhs suffix =
  group $
    hang 2 $
      sep $
        [ ppConstHead keyword constantVal <+> dim (ppr ':'),
          ppr (constType constantVal),
          magenta (ppr ":="),
          ppr rhs
        ]
          ++ suffix

ppConstHead :: String -> ConstantVal e l -> Doc
ppConstHead keyword constantVal =
  ppr keyword
    <+> ppNameWithLevels
      (constName constantVal)
      (constLevelParameters constantVal)

ppNameWithLevels :: HCName -> [HCName] -> Doc
ppNameWithLevels name [] = ppr name
ppNameWithLevels name levelParams = ppr name <+> ppLevelParams levelParams

ppAttr :: [Doc] -> Doc
ppAttr fields =
  group $ brackets (align (hcatWithComma fields))

ppFieldDoc :: String -> Doc -> Doc
ppFieldDoc key value =
  group $ ppr key <> dim (ppr '=') <> align value

ppLevelParams :: [HCName] -> Doc
ppLevelParams [] = mempty
ppLevelParams levelParams = brackets (hcatWithComma (fmap ppr levelParams))
