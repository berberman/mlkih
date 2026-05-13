{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Mlkih.Kernel.Monad where

import Control.Monad.Except
import Control.Monad.Reader
import Control.Monad.State.Strict
import Data.IntMap (IntMap)
import Mlkih.Env
import Mlkih.Expr
import Mlkih.Intern
import Mlkih.Kernel.Semantic
import Mlkih.Name

data ValidatedKernelMetadata = ValidatedKernelMetadata
  { -- | Inductive ID -> Name
    validatedInductives :: IntMap HCName,
    -- | Recursor ID -> Meta
    validatedRecursors :: IntMap RecursorMeta
  }

data RecursorMeta = RecursorMeta
  { recTargetInductive :: HCName,
    -- | Ctor ID -> Expected Fields
    recExpectedFields :: IntMap Int
  }

-- | Local Context only tracks the TYPES of free variables during typechecking.
-- Evaluation does NOT use this.
type LocalCtx = [(FVarId HCName, Value)]

data KernelCtx = KernelCtx
  { checkEnv :: KernelEnv,
    checkLocalCtx :: LocalCtx,
    checkMetadata :: ValidatedKernelMetadata
  }

data KernelState = KernelState
  { checkInternState :: InternState,
    checkNextLocalId :: !Int
  }

type KernelError = String

newtype KernelM a = KernelM
  {unKernelM :: ReaderT KernelCtx (StateT KernelState (Either KernelError)) a}
  deriving (Functor, Applicative, Monad, MonadReader KernelCtx, MonadState KernelState, MonadError KernelError)

freshFVar :: HCName -> KernelM (FVarId HCName)
freshFVar baseName = do
  -- 1. Grab a globally unique integer from the kernel state
  idx <- gets checkNextLocalId
  modify $ \st -> st { checkNextLocalId = idx + 1 }
  
  -- 2. Create the hygienic name shape using the Num constructor
  -- This essentially creates `baseName.idx`
  let freshShape = Num baseName idx
  
  -- 3. Run it through your interner to get a proper HCName
  -- (Assuming you have an internNameVal helper similar to internExprVal)
  freshHCName <- withIntern $ internNameVal freshShape
  
  -- 4. Wrap and return
  pure $ FVarId freshHCName
