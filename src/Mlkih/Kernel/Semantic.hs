module Mlkih.Kernel.Semantic where

import Mlkih.AST
import Mlkih.Expr
import Mlkih.Level
import Mlkih.Name

type Env = [Value]

data Closure = Closure
  { closureEnv :: Env,
    closureBody :: HCExpr
  }
  deriving (Show, Eq)

-- | Spines store arguments in REVERSE order (innermost application is last).
type Spine = [Elim]

data Elim
  = EApp Value
  | EProj HCName Int
  deriving (Show, Eq)

data Head
  = HFVar (FVarId HCName)
  | HConst HCName [HCLevel]
  deriving (Show, Eq)

data Value
  = VSort HCLevel
  | VLit Literal
  | VLam HCName BinderInfo Value Closure
  | VPi HCName BinderInfo Value Closure
  | -- | A stuck term (e.g., Free Variable applied to arguments)
    VNeutral Head Spine
  | -- | Lazy Delta Reduction
    -- We store the structural data for fast head-checks, PLUS a lazy
    -- Haskell thunk of the unfolded definition.
    VDef HCName [HCLevel] Spine Value
  deriving (Show, Eq)
