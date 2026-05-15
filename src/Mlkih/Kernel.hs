module Mlkih.Kernel
  ( module Mlkih.Kernel.Eval,
    module Mlkih.Kernel.Types,
    addDecls,
    processDecl,
    insertAndCheck,
  )
where

import Control.Monad (forM)
import Control.Monad.Except
import Control.Monad.State.Strict (modify')
import qualified Data.IntMap.Strict as IntMap
import Mlkih.Decl
import Mlkih.Env
import Mlkih.Expr
import Mlkih.Intern
import Mlkih.Kernel.Eval
import Mlkih.Kernel.Types
import Mlkih.Level
import Mlkih.Name
import Mlkih.Pretty

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

    let newValidatedInductives =
          IntMap.fromList
            [ (hcnId (constName $ ctorConst ctor), ctorInductive ctor)
            | ctor <- indConstructors block
            ]
    newValidatedRecursorsList <- forM (indRecursors block) $ \recVal -> do
      -- Calculate the major premise index
      let majorIdx = recParamsN recVal + recMotivesN recVal + recMinorsN recVal + recIndicesN recVal
      recTy <- withIntern $ internExprVal $ constType $ recConst recVal
      targetIndName <- getMajorInduct recTy majorIdx
      let expectedFields =
            IntMap.fromList
              [ (hcnId (recCtor rule), recFieldsN rule)
              | rule <- recRules recVal
              ]
      let meta =
            RecursorMeta
              { recTargetInductive = targetIndName,
                recExpectedFields = expectedFields
              }
      pure (hcnId (constName $ recConst recVal), meta)

    let newValidatedRecursors = IntMap.fromList newValidatedRecursorsList
    modify' $ \st ->
      let oldMeta = checkMetadata st
          mergedInductives = IntMap.union newValidatedInductives (validatedInductives oldMeta)
          mergedRecursors = IntMap.union newValidatedRecursors (validatedRecursors oldMeta)
          newMeta =
            oldMeta
              { validatedInductives = mergedInductives,
                validatedRecursors = mergedRecursors
              }
       in st {checkMetadata = newMeta}

insertAndCheck :: ConstantInfo HCExpr HCLevel -> KernelM ()
insertAndCheck info = do
  typecheckInfo info
  insertRaw info

insertRaw :: ConstantInfo HCExpr HCLevel -> KernelM ()
insertRaw info = do
  traceEvent PhDecl TkEvent TraceDetail "insert.declaration" [("decl", TrName $ constantInfoName info)]
  modifyGlobalEnv $ IntMap.insert (hcnId (constantInfoName info)) info

typecheckInfo :: ConstantInfo HCExpr HCLevel -> KernelM ()
typecheckInfo info = traceBlock PhDecl TkEnter TraceSummary "typecheckInfo" [("decl", TrName $ constantInfoName info)] $ do
  tyExpr <- withIntern $ internExprVal $ constType $ constantInfoConst info
  traceEvent PhDecl TkEvent TraceDetail "typecheck.declType" [("decl", TrName $ constantInfoName info), ("type", TrExpr tyExpr)]
  tyTypeVal <- inferExpr 0 [] tyExpr
  traceEvent PhDecl TkEvent TraceDetail "typecheck.declType.inferred" [("decl", TrName $ constantInfoName info), ("typeVal", TrValue tyTypeVal)]
  _ <- ensureSort tyTypeVal
  case constantInfoBody info of
    Just valExpr -> do
      valExpr' <- withIntern $ internExprVal valExpr
      traceEvent PhDecl TkEvent TraceDetail "typecheck.declBody" [("decl", TrName $ constantInfoName info), ("body", TrExpr valExpr')]
      valTypeVal <- inferExpr 0 [] valExpr'
      expectedTyVal <- evalM [] tyExpr
      traceEvent PhDecl TkEvent TraceDetail "typecheck.declBody.inferred" [("decl", TrName $ constantInfoName info), ("bodyType", TrValue valTypeVal)]
      traceEvent PhDecl TkEvent TraceDetail "typecheck.declBody.expected" [("decl", TrName $ constantInfoName info), ("expectedType", TrValue expectedTyVal)]
      isTypeOk <- isDefEqValue 0 valTypeVal expectedTyVal
      if not isTypeOk
        then do
          traceFail PhDecl TkFailure TraceSummary "typecheck.declBody.mismatch" [("decl", TrName $ constantInfoName info), ("bodyType", TrValue valTypeVal), ("expectedType", TrValue expectedTyVal)]
          throwError $ "Type of constant body does not match declared type: " <> show valTypeVal <> " vs " <> show expectedTyVal
        else pure ()
    Nothing -> pure ()
