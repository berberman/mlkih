module Mlkih.Kernel
  ( module Mlkih.Kernel.Eval,
    module Mlkih.Kernel.Types,
    module Mlkih.Kernel.Monad,
    module Mlkih.Kernel.Trace,
    module Mlkih.Kernel.Cache,
    addDecls,
    processDecl,
  )
where

import Control.Monad (forM, unless)
import Control.Monad.Except
import Control.Monad.State.Strict
import qualified Data.IntMap.Strict as IntMap
import Mlkih.AST
import Mlkih.Decl
import Mlkih.Env
import Mlkih.Expr
import Mlkih.Intern
import Mlkih.Kernel.Cache
import Mlkih.Kernel.Eval
import Mlkih.Kernel.Monad
import Mlkih.Kernel.Trace
import Mlkih.Kernel.Types
import Mlkih.Level
import Mlkih.Name
import Mlkih.Pretty

--------------------------------------------------------------------------------

addDecls :: [Decl HCExpr HCLevel] -> KernelM ()
addDecls = mapM_ processDecl

processDecl :: Decl HCExpr HCLevel -> KernelM ()
processDecl decl =
  traceBlock
    PhDecl
    TkEnter
    TraceSummary
    "decl.process"
    [("names", TrDoc (ppr (declNames decl)))]
    $ withKernelTransaction
    $ case decl of
      InductiveBlockDecl block ->
        processInductiveBlock block
      _ ->
        processConstantInfo (declToConstantInfo decl)

--------------------------------------------------------------------------------

withKernelTransaction :: KernelM a -> KernelM a
withKernelTransaction action = do
  snapshot <- get
  action `catchError` \err -> do
    rollbackKernelState snapshot
    traceFail
      PhDecl
      TkFailure
      TraceSummary
      "decl.transaction.rollback"
      [("reason", TrString err)]
    throwError err

-- | Rollback kernel state except for trace stack for diagnostic trace and intern state for avoid reusing interned values across transactions
rollbackKernelState :: KernelState -> KernelM ()
rollbackKernelState snapshot = do
  current <- get
  put $
    snapshot
      { checkInternState = checkInternState current,
        checkTraceStack = checkTraceStack current
      }

--------------------------------------------------------------------------------

declToConstantInfo :: Decl HCExpr HCLevel -> ConstantInfo HCExpr HCLevel
declToConstantInfo decl =
  case decl of
    AxiomDecl v -> AxiomInfo v
    DefnDecl v -> DefnInfo v
    ThmDecl v -> ThmInfo v
    OpaqueDecl v -> OpaqueInfo v
    QuotDecl v -> QuotInfo v
    CtorDecl v -> CtorInfo v
    RecDecl v -> RecInfo v
    InductiveBlockDecl {} -> error "declToConstantInfo: inductive block"

inductiveBlockInfos :: InductiveDecl HCExpr HCLevel -> [ConstantInfo HCExpr HCLevel]
inductiveBlockInfos block =
  fmap InductInfo (indTypes block)
    <> fmap CtorInfo (indConstructors block)
    <> fmap RecInfo (indRecursors block)

--------------------------------------------------------------------------------

processConstantInfo :: ConstantInfo HCExpr HCLevel -> KernelM ()
processConstantInfo info = do
  typecheckInfo info
  insertRaw info

--------------------------------------------------------------------------------

processInductiveBlock :: InductiveDecl HCExpr HCLevel -> KernelM ()
processInductiveBlock block = do
  let infos = inductiveBlockInfos block
  traceEvent
    PhDecl
    TkEvent
    TraceDetail
    "decl.inductiveBlock.insertRaw"
    [("count", TrInt (length infos))]
  -- Mutually visible while typechecking the block.
  insertRawMany infos
  traceEvent
    PhDecl
    TkEvent
    TraceDetail
    "decl.inductiveBlock.typecheck"
    [("count", TrInt (length infos))]
  typecheckMany infos
  metadata <- buildInductiveBlockMetadata block
  traceEvent
    PhDecl
    TkEvent
    TraceDetail
    "decl.inductiveBlock.metadata"
    [ ("ctors", TrInt (length (indConstructors block))),
      ("recursors", TrInt (length (indRecursors block)))
    ]
  mergeValidatedMetadata metadata

typecheckMany :: [ConstantInfo HCExpr HCLevel] -> KernelM ()
typecheckMany = mapM_ typecheckInfo

insertRawMany :: [ConstantInfo HCExpr HCLevel] -> KernelM ()
insertRawMany = mapM_ insertRaw

buildInductiveBlockMetadata ::
  InductiveDecl HCExpr HCLevel ->
  KernelM ValidatedKernelMetadata
buildInductiveBlockMetadata block = do
  let newValidatedInductives =
        IntMap.fromList
          [ (hcnId (constName (ctorConst ctor)), ctorInductive ctor)
          | ctor <- indConstructors block
          ]

  newValidatedRecursorsList <- forM (indRecursors block) $ \recVal -> do
    meta <- buildRecursorMeta recVal
    pure (hcnId (constName (recConst recVal)), meta)

  pure
    ValidatedKernelMetadata
      { validatedInductives = newValidatedInductives,
        validatedRecursors = IntMap.fromList newValidatedRecursorsList
      }

buildRecursorMeta :: RecursorVal HCExpr HCLevel -> KernelM RecursorMeta
buildRecursorMeta recVal = do
  let majorIdx =
        recParamsN recVal
          + recMotivesN recVal
          + recMinorsN recVal
          + recIndicesN recVal
  recTy <- withIntern $ internExprVal $ constType $ recConst recVal
  targetIndName <- case getMajorInduct recTy majorIdx of
    Just name -> pure name
    _ -> throwError $ "Failed to determine target inductive for recursor."
  let expectedFields =
        IntMap.fromList
          [ (hcnId (recCtor rule), recFieldsN rule)
          | rule <- recRules recVal
          ]
  pure
    RecursorMeta
      { recTargetInductive = targetIndName,
        recExpectedFields = expectedFields
      }

mergeValidatedMetadata :: ValidatedKernelMetadata -> KernelM ()
mergeValidatedMetadata newMeta =
  modify' $ \st ->
    let oldMeta = checkMetadata st
        merged =
          oldMeta
            { validatedInductives =
                IntMap.union
                  (validatedInductives newMeta)
                  (validatedInductives oldMeta),
              validatedRecursors =
                IntMap.union
                  (validatedRecursors newMeta)
                  (validatedRecursors oldMeta)
            }
     in st {checkMetadata = merged}

--------------------------------------------------------------------------------

insertRaw :: ConstantInfo HCExpr HCLevel -> KernelM ()
insertRaw info = do
  traceEvent
    PhDecl
    TkEvent
    TraceDetail
    "decl.insert"
    [("decl", TrName (constantInfoName info))]
  modifyGlobalEnv $
    IntMap.insert (hcnId (constantInfoName info)) info

typecheckInfo :: ConstantInfo HCExpr HCLevel -> KernelM ()
typecheckInfo info =
  traceBlock
    PhDecl
    TkEnter
    TraceSummary
    "typecheckInfo"
    [("decl", TrName (constantInfoName info))]
    $ do
      tyExpr <- withIntern $ internExprVal $ constType $ constantInfoConst info
      traceEvent
        PhDecl
        TkEvent
        TraceDetail
        "typecheck.declType"
        [ ("decl", TrName (constantInfoName info)),
          ("type", TrExpr tyExpr)
        ]
      tyTypeVal <- inferExpr 0 [] tyExpr
      traceEvent
        PhDecl
        TkEvent
        TraceDetail
        "typecheck.declType.inferred"
        [ ("decl", TrName (constantInfoName info)),
          ("typeVal", TrValueHead tyTypeVal)
        ]
      _ <- ensureSort 0 tyTypeVal
      checkBodyIfPresent info tyExpr

checkBodyIfPresent ::
  ConstantInfo HCExpr HCLevel ->
  HCExpr ->
  KernelM ()
checkBodyIfPresent info tyExpr =
  case constantInfoBody info of
    Nothing ->
      pure ()
    Just valExpr -> do
      valExpr' <- withIntern $ internExprVal valExpr
      traceEvent
        PhDecl
        TkEvent
        TraceDetail
        "typecheck.declBody"
        [ ("decl", TrName (constantInfoName info)),
          ("body", TrExpr valExpr')
        ]
      valTypeVal <- inferExpr 0 [] valExpr'
      expectedTyVal <- evalM [] tyExpr
      traceEvent
        PhDefEq
        TkCompare
        TraceDetail
        "typecheck.body.check"
        [ ("decl", TrName (constantInfoName info)),
          ("inferred", TrValueHead valTypeVal),
          ("expected", TrValueHead expectedTyVal)
        ]
      isTypeOk <- isDefEqValue 0 valTypeVal expectedTyVal
      unless isTypeOk $ do
        traceFail
          PhDecl
          TkFailure
          TraceSummary
          "typecheck.body.mismatch"
          [ ("decl", TrName (constantInfoName info)),
            ("inferred", TrValueHead valTypeVal),
            ("expected", TrValueHead expectedTyVal)
          ]
        throwError $
          "Type of constant body does not match declared type: "
            <> toString valTypeVal
            <> " vs "
            <> toString expectedTyVal
