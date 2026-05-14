module Mlkih.Kernel
  ( module Mlkih.Kernel.Eval,
    module Mlkih.Kernel.Types,
    addDecls,
    processDecl,
    insertAndCheck,
  )
where

import Control.Monad.Except
import qualified Data.IntMap.Strict as IntMap
import Mlkih.Decl
import Mlkih.Env
import Mlkih.Expr
import Mlkih.Intern
import Mlkih.Kernel.Eval
import Mlkih.Kernel.Types
import Mlkih.Level
import Mlkih.Name

addDecls :: [Decl HCExpr HCLevel] -> KernelM ()
addDecls = mapM_ processDecl

processDecl :: Decl HCExpr HCLevel -> KernelM ()
processDecl decl = case decl of
  AxiomDecl v -> insertAndCheck (AxiomInfo v)
  DefnDecl v -> insertAndCheck (DefnInfo v)
  ThmDecl v -> insertAndCheck (ThmInfo v)
  OpaqueDecl v -> insertAndCheck (OpaqueInfo v)
  QuotDecl v -> insertAndCheck (QuotInfo v)
  CtorDecl v -> insertAndCheck (CtorInfo v)
  RecDecl v -> insertAndCheck (RecInfo v)
  InductiveBlockDecl block -> do
    let indInfos = map InductInfo (indTypes block)
    let ctorInfos = map CtorInfo (indConstructors block)
    let recInfos = map RecInfo (indRecursors block)
    let allInfos = indInfos ++ ctorInfos ++ recInfos
    -- Blindly insert all of them into the environment first
    mapM_ insertRaw allInfos
    -- Typecheck the block safely
    mapM_ typecheckInfo allInfos

insertAndCheck :: ConstantInfo HCExpr HCLevel -> KernelM ()
insertAndCheck info = do
  typecheckInfo info
  insertRaw info

insertRaw :: ConstantInfo HCExpr HCLevel -> KernelM ()
insertRaw info = modifyGlobalEnv $ IntMap.insert (hcnId (constantInfoName info)) info

typecheckInfo :: ConstantInfo HCExpr HCLevel -> KernelM ()
typecheckInfo info = do
  tyExpr <- withIntern $ internExprVal $ constType $ constantInfoConst info
  tyTypeVal <- inferExpr [] tyExpr
  _ <- ensureSort tyTypeVal
  case constantInfoBody info of
    Just valExpr -> do
      valExpr' <- withIntern $ internExprVal valExpr
      valTypeVal <- inferExpr [] valExpr'
      expectedTyVal <- evalM [] tyExpr
      isTypeOk <- isDefEqValue valTypeVal expectedTyVal
      if not isTypeOk
        then throwError $ "Type of constant body does not match declared type: " <> show valTypeVal <> " vs " <> show expectedTyVal
        else pure ()
    Nothing -> pure ()
