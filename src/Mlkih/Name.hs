{-# LANGUAGE DeriveFunctor #-}

module Mlkih.Name where

import Data.Hashable (Hashable (hashWithSalt))
import Data.Text (Text)
import qualified Data.Text as T
import Mlkih.Pretty
import Mlkih.Types

data Name' n
  = Anonymous
  | Str n Text
  | Num n Int
  deriving (Show, Eq, Ord, Functor)

instance (Hashable n) => Hashable (Name' n) where
  hashWithSalt salt Anonymous = hashWithSalt salt (0 :: Int)
  hashWithSalt salt (Str prefix segment) = hashWithSalt (hashWithSalt salt (1 :: Int)) (prefix, segment)
  hashWithSalt salt (Num prefix n) = hashWithSalt (hashWithSalt salt (2 :: Int)) (prefix, n)

instance (HasName n, PrettyPrint n) => PrettyPrint (Name' n) where
  ppr name =
    case name of
      Anonymous -> char '_'
      Str prefix segment ->
        case getName prefix of
          Anonymous -> text (T.unpack segment)
          _ -> ppr prefix <> char '.' <> text (T.unpack segment)
      Num prefix n ->
        case getName prefix of
          Anonymous -> int n
          _ -> ppr prefix <> char '.' <> int n

newtype Name = Name {unName :: Name' Name}
  deriving (Show, Eq, Ord)

simpleName :: Text -> Name
simpleName txt = Name (Str (Name Anonymous) txt)

data HCName = HCName
  { hcnId :: {-# UNPACK #-} !HCId,
    hcnVal :: Name' HCName
  }
  deriving (Show)

class HasName a where
  getName :: a -> Name' a

instance HasName Name where
  getName = unName

instance HasName HCName where
  getName = hcnVal

instance Eq HCName where
  lhs == rhs = hcnId lhs == hcnId rhs

instance Ord HCName where
  compare lhs rhs = compare (hcnId lhs) (hcnId rhs)

instance Hashable HCName where
  hashWithSalt salt = hashWithSalt salt . hcnId

instance PrettyPrint Name where
  ppr = ppr . getName

instance PrettyPrint HCName where
  ppr = ppr . getName
