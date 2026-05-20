{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeFamilies #-}

-- | Universe level normalization and comparison.
--
-- Idea: normalize enough structure to expose @max@/@imax@
-- behavior, then define equivalence as antisymmetry of a signed-offset @<=@
-- check, similar to Lean kernel.
--
-- * Implementation inspired by [@nanoda_lib/src/level.rs@](https://github.com/ammkrn/nanoda_lib/blob/master/src/level.rs).
-- * Here we also canonicalize @max@ more aggressively than nanoda by deduplicating and ordering operands.
module Mlkih.Level where

import Data.Hashable (Hashable (hashWithSalt))
import Mlkih.Name
import Mlkih.Pretty
import Mlkih.Types

data Level' l n
  = LZero
  | LSucc l
  | LMax l l
  | LIMax l l
  | LVar n
  deriving (Show, Eq, Ord)

instance (Hashable l, Hashable n) => Hashable (Level' l n) where
  hashWithSalt salt LZero = hashWithSalt salt (0 :: Int)
  hashWithSalt salt (LSucc inner) = hashWithSalt (hashWithSalt salt (1 :: Int)) inner
  hashWithSalt salt (LMax lhs rhs) = hashWithSalt (hashWithSalt (hashWithSalt salt (2 :: Int)) lhs) rhs
  hashWithSalt salt (LIMax lhs rhs) = hashWithSalt (hashWithSalt (hashWithSalt salt (3 :: Int)) lhs) rhs
  hashWithSalt salt (LVar name) = hashWithSalt (hashWithSalt salt (4 :: Int)) name

instance (PrettyPrint l, PrettyPrint n) => PrettyPrint (Level' l n) where
  ppr level =
    case level of
      LZero -> ppr '0'
      LSucc inner -> parens (ppr inner <+> ppr '+' <+> ppr (1 :: Int))
      LMax lhs rhs -> group (ppr "max" <> parens (hcatWithComma [ppr lhs, ppr rhs]))
      LIMax lhs rhs -> group (ppr "imax" <> parens (hcatWithComma [ppr lhs, ppr rhs]))
      LVar name -> ppr name

newtype Level = Level {unLevel :: Level' Level Name}
  deriving (Show, Eq, Ord)

data HCLevel = HCLevel
  { hclId :: {-# UNPACK #-} !HCId,
    hclVal :: Level' HCLevel HCName
  }
  deriving (Show)

instance Eq HCLevel where
  lhs == rhs = hclId lhs == hclId rhs

instance Ord HCLevel where
  compare lhs rhs = compare (hclId lhs) (hclId rhs)

instance Hashable HCLevel where
  hashWithSalt salt = hashWithSalt salt . hclId

class HasLevel a where
  getLevel :: a -> Level' a (NameOf a)

type instance NameOf Level = Name

instance HasLevel Level where
  getLevel = unLevel

type instance NameOf HCLevel = HCName

instance HasLevel HCLevel where
  getLevel = hclVal

instance PrettyPrint Level where
  ppr = ppr . getLevel

instance PrettyPrint HCLevel where
  ppr = ppr . getLevel

-- | Structural comparison domain for normalized levels.
-- Make sure that we are not using 'Eq'/'Ord'/'Hashable' instances from 'HCLevel'.
newtype NormalLevel = NormalLevel {unNormalLevel :: Level' NormalLevel HCName}
  deriving (Show, Eq, Ord)

instance Hashable NormalLevel where
  hashWithSalt salt = hashWithSalt salt . unNormalLevel

simplifyHCLevel :: HCLevel -> NormalLevel
simplifyHCLevel = simplifyLevelVal . hclVal

simpleZero :: NormalLevel
simpleZero = NormalLevel LZero

simpleSucc :: NormalLevel -> NormalLevel
simpleSucc inner = NormalLevel (LSucc inner)

simpleMax :: NormalLevel -> NormalLevel -> NormalLevel
simpleMax lhs rhs = NormalLevel (LMax lhs rhs)

simpleIMax :: NormalLevel -> NormalLevel -> NormalLevel
simpleIMax lhs rhs = NormalLevel (LIMax lhs rhs)

simpleParam :: HCName -> NormalLevel
simpleParam name = NormalLevel (LVar name)

simplifyLevelVal :: Level' HCLevel HCName -> NormalLevel
simplifyLevelVal level =
  case level of
    LZero -> simpleZero
    LSucc inner -> simpleSucc (simplifyHCLevel inner)
    LMax lhs rhs -> mkMax (simplifyHCLevel lhs) (simplifyHCLevel rhs)
    LIMax lhs rhs -> mkIMax (simplifyHCLevel lhs) (simplifyHCLevel rhs)
    LVar name -> simpleParam name

-- | Semantic universe equivalence
levelEquiv :: HCLevel -> HCLevel -> Bool
levelEquiv lhs rhs =
  let lhs' = simplifyHCLevel lhs
      rhs' = simplifyHCLevel rhs
   in levelLeq lhs' rhs' 0 && levelLeq rhs' lhs' 0

levelsEquiv :: [HCLevel] -> [HCLevel] -> Bool
levelsEquiv lvls1 lvls2 =
  length lvls1 == length lvls2
    && and (zipWith (\l1 l2 -> l1 == l2 || levelEquiv l1 l2) lvls1 lvls2)

levelGeq :: HCLevel -> HCLevel -> Bool
levelGeq lhs rhs = levelLeq (simplifyHCLevel rhs) (simplifyHCLevel lhs) 0

-- | Canonical @max@ constructor for normalized levels.
--
-- Here we sort and deduplicate here so commutative @max@ expressions
-- normalize to the same tree. Current tests rely on this stronger invariant.
--
-- Note: @==@ and @<=@ are structural comparisons only for picking a stable operand orders.
mkMax :: NormalLevel -> NormalLevel -> NormalLevel
mkMax lhs rhs
  | lhs == rhs = lhs
  | lhs <= rhs = simpleMax lhs rhs
  | otherwise = simpleMax rhs lhs

-- | Smart constructor for normalized @imax@.
--
-- Make sure:
--
-- * @imax a 0 = 0@
-- * @imax a (succ b) = max a (succ b)@
-- * @imax a (max b c) = max (imax a b) (imax a c)@
-- * @imax a (imax b c) = imax (max a b) c@
--
-- INVARIANT：Any surviving normalized @imax@ has a parameter-like right-hand side.
mkIMax :: NormalLevel -> NormalLevel -> NormalLevel
mkIMax lhs rhs =
  case unNormalLevel rhs of
    LZero -> simpleZero
    LSucc _ -> mkMax lhs rhs
    LMax rhs1 rhs2 -> mkMax (mkIMax lhs rhs1) (mkIMax lhs rhs2)
    LIMax rhs1 rhs2 -> mkIMax (mkMax lhs rhs1) rhs2
    LVar _ -> simpleIMax lhs rhs

substLevel :: NormalLevel -> (HCName -> NormalLevel) -> NormalLevel
substLevel level f =
  case unNormalLevel level of
    LZero -> simpleZero
    LSucc inner -> simpleSucc (substLevel inner f)
    LMax lhs rhs -> mkMax (substLevel lhs f) (substLevel rhs f)
    LIMax lhs rhs -> mkIMax (substLevel lhs f) (substLevel rhs f)
    LVar name -> f name

substOneLevel :: NormalLevel -> HCName -> NormalLevel -> NormalLevel
substOneLevel level name replacement =
  substLevel level $ \name' ->
    if name' == name
      then replacement
      else simpleParam name'

-- | Eliminate the easy @imax@ cases after substituting a parameter.
--
-- Similar to nanoda's approach, we substitute the parameter with @0@ and @succ param@, normalize the
-- resulting @imax@ structure, and compare both branches.
elimIMax :: NormalLevel -> NormalLevel
elimIMax level =
  case unNormalLevel level of
    LZero -> simpleZero
    LSucc inner -> simpleSucc (elimIMax inner)
    LMax lhs rhs -> mkMax (elimIMax lhs) (elimIMax rhs)
    LIMax _ rhs
      | rhs == simpleZero -> simpleZero
    LIMax lhs (NormalLevel (LSucc rhsInner)) -> mkMax (elimIMax lhs) (simpleSucc (elimIMax rhsInner))
    LIMax lhs rhs -> simpleIMax (elimIMax lhs) (elimIMax rhs)
    LVar name -> simpleParam name

-- | Compare parameterized @imax@ expressions by cases.
--
-- This is the key nontrivial step in the algorithm. For a parameter @u@, we
-- compare both:
--
-- * @u := 0@
-- * @u := succ u@
--
-- after 'elimIMax'.
byCases :: HCName -> NormalLevel -> NormalLevel -> (NormalLevel -> NormalLevel -> Bool) -> Bool
byCases name lhs rhs k =
  k zeroLhs zeroRhs && k succLhs succRhs
  where
    zeroLhs = elimIMax $ substOneLevel lhs name simpleZero
    zeroRhs = elimIMax $ substOneLevel rhs name simpleZero
    succValue = simpleSucc (simpleParam name)
    succLhs = elimIMax $ substOneLevel lhs name succValue
    succRhs = elimIMax $ substOneLevel rhs name succValue

-- | Signed-offset level comparison on normalized levels.
--
-- The @balance@ parameter tracks how many @succ@s have been peeled from the two
-- sides. This is the analogue of nanoda's @diff@ argument in @leq_core@.
--
-- A few important choices here are deliberate:
--
-- * left @max@ is conjunctive
-- * right @max@ is disjunctive only for the @0@/@param@ cases we currently need
-- * any remaining non-parameterized @imax@ is treated as incomparable
levelLeq :: NormalLevel -> NormalLevel -> Int -> Bool
levelLeq lhs rhs balance =
  case (unNormalLevel lhs, unNormalLevel rhs) of
    (LSucc lhs', _) -> levelLeq lhs' rhs (balance - 1)
    (_, LSucc rhs') -> levelLeq lhs rhs' (balance + 1)
    (LMax lhs1 lhs2, _) -> levelLeq lhs1 rhs balance && levelLeq lhs2 rhs balance
    (LVar name1, LVar name2) -> name1 == name2 && balance >= 0
    (LIMax _ (NormalLevel (LVar name)), _) -> byCases name lhs rhs $ \lhs' rhs' -> levelLeq lhs' rhs' balance
    (_, LIMax _ (NormalLevel (LVar name))) -> byCases name lhs rhs $ \lhs' rhs' -> levelLeq lhs' rhs' balance
    (LIMax _ _, _) -> False
    (_, LIMax _ _) -> False
    (LVar _, LMax rhs1 rhs2) -> levelLeq lhs rhs1 balance || levelLeq lhs rhs2 balance
    (LZero, LMax rhs1 rhs2) -> levelLeq lhs rhs1 balance || levelLeq lhs rhs2 balance
    (LZero, _) -> balance >= 0
    (_, LZero) -> False
