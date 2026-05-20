{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Control.Exception (IOException, try)
import Control.Monad.Error.Class (throwError)
import Control.Monad.State.Strict (gets, modify', runState)
import Data.ByteString (ByteString)
import qualified Data.ByteString.Char8 as BSC
import qualified Data.IntMap.Strict as IntMap
import Data.List (elemIndex, isInfixOf)
import qualified Data.Map.Strict as Map
import Data.Maybe (fromJust)
import qualified Data.Text as Text
import Mlkih.AST
import Mlkih.Decl
import Mlkih.Env
import Mlkih.Export
import Mlkih.Expr
import Mlkih.Intern
import Mlkih.Kernel
import Mlkih.Level
import Mlkih.Name
import Mlkih.Pretty
import Numeric.Natural
import Paths_mlkih (getDataFileName)
import System.Directory (doesFileExist, getCurrentDirectory, getTemporaryDirectory, makeAbsolute, removeFile)
import System.Environment (getEnvironment)
import System.Exit (ExitCode (..))
import System.FilePath (takeDirectory, (</>))
import System.IO (IOMode (WriteMode), hClose, openFile)
import System.Process (CreateProcess (cwd, env), proc, readCreateProcessWithExitCode)
import Test.Tasty (TestTree, defaultMain, testGroup)
import Test.Tasty.HUnit

main :: IO ()
main = do
  -- defaultMain tests

  parsed <- loadParsedLeanFixture tutorialFixture
  state <- expectRightKernel $ withTraceVerbosity TraceSummary  $ checkParsedExport parsed
  printKernelTrace state
  -- result <- parseExportFileWithState "export.exported.ndjson"
  -- case result of
  -- Left err -> failWith err
  -- Right parsed -> pure ()
  pure ()

expectRightKernel :: KernelM a -> IO KernelState
expectRightKernel k = expectRight $ execKernelM' k

testDefEqCacheHits :: IO ()
testDefEqCacheHits = do
  (result, failedCacheAfter) <- runKernelExpectRight IntMap.empty $ do
    exprA <- mkLit (NatVal 1)
    exprB <- mkLit (NatVal 2)
    _ <- isDefEq exprA exprB
    failedPopulated <- Map.member (fromJust $ mkClosedDefEqKey exprA exprB) <$> gets checkClosedDefEqCache
    resultFail <- isDefEq exprA exprB
    pure (resultFail, failedPopulated)

  assertEq False result "expected distinct literals to fail"
  assertEq True failedCacheAfter "expected the negative cache to memoize the failure"

testRecursionGuardPreventsLoop :: IO ()
testRecursionGuardPreventsLoop = do
  let ((recName, sortExpr, recExpr, stuckExpr, recBody), _internState) = runState build emptyInternState
      env = kernelEnvFromInfos [mkDefinitionInfo sortExpr recName [] (Regular 1) recBody]

  result <- runKernelExpectRight env $ do isDefEq recExpr stuckExpr

  assertEq False result "expected infinite recursion to be intercepted and fail gracefully"
  where
    build = do
      recName <- internName (rawName ["Loop", "forever"])
      sortExpr <- internExpr rawSortOneExpr
      recExpr <- internExpr (rawConstExpr ["Loop", "forever"])
      stuckExpr <- internExpr (rawNatExpr 0)
      recBody <- internExpr (rawConstExpr ["Loop", "forever"])
      pure (recName, sortExpr, recExpr, stuckExpr, recBody)

testSemanticStructEtaEquivalence :: IO ()
testSemanticStructEtaEquivalence = do
  let ((structName, ctorName, sortExpr, _structTy, ctorTy), _internState) = runState build emptyInternState
      -- Mock a Structure (1 constructor, 0 indices, 2 fields)
      ctorVal =
        ConstructorVal
          { ctorConst = ConstantVal {constName = ctorName, constLevelParameters = [], constType = hceVal ctorTy},
            ctorInductive = structName,
            ctorIndex = 0,
            ctorParamsN = 0,
            ctorFieldsN = 2
          }
      indVal =
        InductiveVal
          { indConst = ConstantVal {constName = structName, constLevelParameters = [], constType = hceVal sortExpr},
            indParamsN = 0,
            indIndicesN = 0,
            indCtors = [ctorName]
          }
      env = IntMap.fromList [(hcnId structName, InductInfo indVal), (hcnId ctorName, CtorInfo ctorVal)]

  result <- runKernelExpectRight env $ do
    structExpr <- mkConst structName []
    structTyVal <- evalM [] structExpr

    let nP = hcName ["p"]
    let vP = VNeutral (HLvl nP 0) []
    pVar <- mkBVar 0
    withLocalDecl 0 (LocalDecl nP structTyVal Nothing) $ do
      -- Create `Struct.mk p.0 p.1`
      ctorExpr <- mkConst ctorName []
      p0 <- mkProj structName 0 pVar
      p1 <- mkProj structName 1 pVar
      etaExpanded <- mkApps ctorExpr [p0, p1]

      -- Compare `p` to `Struct.mk p.0 p.1`
      isDefEq' 1 [vP] pVar etaExpanded

  assertEq True result "expected structural eta to prove a variable equals its reconstructed projections"
  where
    build = do
      structName <- internName (rawName ["MyStruct"])
      ctorName <- internName (rawName ["MyStruct", "mk"])
      sortExpr <- internExpr rawSortOneExpr
      structTy <- internExpr (rawConstExpr ["MyStruct"])

      let ty1 = Expr (ForallE (rawName ["y"]) rawSortOneExpr (rawConstExpr ["MyStruct"]) Default)
      let ty2 = Expr (ForallE (rawName ["x"]) rawSortOneExpr ty1 Default)
      ctorTy <- internExpr ty2

      pure (structName, ctorName, sortExpr, structTy, ctorTy)

testKRuleIndexMatching :: IO ()
testKRuleIndexMatching = do
  let ((eqName, reflName, recName, _sortExpr, eqTyExpr, recTyExpr, reflTyExpr), _initialInternState) = runState build emptyInternState

      eqInd =
        InductiveVal
          { indConst = ConstantVal {constName = eqName, constLevelParameters = [], constType = hceVal eqTyExpr},
            indParamsN = 2,
            indIndicesN = 1,
            indCtors = [reflName]
          }
      eqRefl =
        ConstructorVal
          { ctorConst = ConstantVal {constName = reflName, constLevelParameters = [], constType = hceVal reflTyExpr},
            ctorInductive = eqName,
            ctorIndex = 0,
            ctorParamsN = 2,
            ctorFieldsN = 0
          }
      eqRec =
        RecursorVal
          { recConst = ConstantVal {constName = recName, constLevelParameters = [], constType = hceVal recTyExpr},
            recParamsN = 2,
            recIndicesN = 1,
            recMotivesN = 1,
            recMinorsN = 1,
            recKRule = True,
            recRules = []
          }

      env =
        IntMap.fromList
          [ (hcnId eqName, InductInfo eqInd),
            (hcnId reflName, CtorInfo eqRefl),
            (hcnId recName, RecInfo eqRec)
          ]

  (reducedEq, stuckEq) <- runKernelExpectRight env $ do
    modify'
      ( \ctx ->
          ctx
            { checkMetadata =
                ValidatedKernelMetadata
                  { validatedInductives = IntMap.singleton (hcnId reflName) eqName,
                    validatedRecursors =
                      IntMap.singleton
                        (hcnId recName)
                        RecursorMeta
                          { recTargetInductive = eqName,
                            recExpectedFields = IntMap.singleton (hcnId reflName) 0 -- Eq.refl takes 0 fields
                          }
                  }
            }
      )

    zero <- mkLevelZero
    sortZero <- mkSort zero

    eqConst <- mkConst eqName []
    recConst <- mkConst recName []

    let ctxNames = ["alpha", "a", "b", "motive", "minor", "h_same", "h_diff"]

    withTestContext
      ctxNames
      ( \var -> do
          alpha <- var "alpha"
          a <- var "a"
          b <- var "b"
          eqSameType <- mkApps eqConst [alpha, a, a]
          eqDiffType <- mkApps eqConst [alpha, a, b]
          pure
            [ ("alpha", sortZero),
              ("a", sortZero),
              ("b", sortZero),
              ("motive", sortZero),
              ("minor", sortZero),
              ("h_same", eqSameType),
              ("h_diff", eqDiffType)
            ]
      )
      $ \depth finalEnv var -> do
        alpha <- var "alpha"
        a <- var "a"
        b <- var "b"
        motive <- var "motive"
        minor <- var "minor"
        hSame <- var "h_same"
        hDiff <- var "h_diff"

        recAppSame <- mkApps recConst [alpha, a, motive, minor, a, hSame]
        recAppDiff <- mkApps recConst [alpha, a, motive, minor, b, hDiff]
        reducedResult <- isDefEq' depth finalEnv recAppSame minor
        stuckResult <- isDefEq' depth finalEnv recAppDiff minor

        pure (reducedResult, stuckResult)

  assertEq True reducedEq "expected K-rule to reduce to the minor premise when indices match"
  assertEq False stuckEq "expected K-rule to remain stuck when actual and target indices differ"
  where
    build = do
      eqName <- internName (rawName ["Eq"])
      reflName <- internName (rawName ["Eq", "refl"])
      recName <- internName (rawName ["Eq", "rec"])
      sortExpr <- internExpr rawSortZeroExpr

      let rawArrow n = foldr (\_ res -> Expr (ForallE (rawName ["_"]) rawSortZeroExpr res Default)) rawSortZeroExpr [1 .. n]
      eqTyExpr <- internExpr (rawArrow 3)
      recTyExpr <- internExpr (rawArrow 6)

      -- Eq.refl:
      -- Forall alpha, Forall a, Eq alpha a a
      -- BVar 1 = alpha, BVar 0 = a
      let eqApp = rawAppsExpr (rawConstExpr ["Eq"]) [rawBVarExpr 1, rawBVarExpr 0, rawBVarExpr 0]
      let reflTyRaw = Expr (ForallE (rawName ["alpha"]) rawSortZeroExpr (Expr (ForallE (rawName ["a"]) rawSortZeroExpr eqApp Default)) Default)
      reflTyExpr <- internExpr reflTyRaw

      pure (eqName, reflName, recName, sortExpr, eqTyExpr, recTyExpr, reflTyExpr)

testNbESemanticBetaReduction :: IO ()
testNbESemanticBetaReduction = do
  result <- runKernelExpectRight IntMap.empty $ do
    natType <- mkConst (hcName ["Nat"]) []
    -- \x : Nat -> x
    bodyVar <- mkBVar 0
    idFunc <- mkLam (hcName ["x"]) natType bodyVar Default
    -- (\x : Nat -> x) 42
    arg <- mkLit (NatVal 42)
    applied <- mkApp idFunc arg
    -- isDefEq applied 42
    isDefEq applied arg

  assertEq True result "expected NbE to natively beta-reduce application to argument"

rawSortOneExpr :: Expr
rawSortOneExpr = Expr (Sort (Level $ LSucc $ Level LZero))

withTestContext ::
  [String] ->
  ((String -> KernelM HCExpr) -> KernelM [(String, HCExpr)]) ->
  (Int -> LocalEnv -> (String -> KernelM HCExpr) -> KernelM a) ->
  KernelM a
withTestContext names buildTypes action = do
  let totalDepth = length names

  -- e.g., ["alpha", "a"] -> [vA^1, vAlpha^0]
  let finalEnv = reverse [VNeutral (HLvl (hcName [n]) lvl) [] | (n, lvl) <- zip names [0 ..]]

  let var nameStr = case elemIndex nameStr names of
        Just lvl -> mkBVar (totalDepth - 1 - lvl)
        Nothing -> throwError $ "Test variable typo: " ++ nameStr
  typesList <- buildTypes var

  let go [] _ env = action totalDepth env var
      go ((nameStr, tyExpr) : rest) currentDepth env = do
        tyVal <- evalM finalEnv tyExpr
        let name = hcName [nameStr]
        let decl = LocalDecl name tyVal Nothing
        withLocalDecl currentDepth decl $
          let levelVal = VNeutral (HLvl name currentDepth) []
           in go rest (currentDepth + 1) (levelVal : env)

  go typesList 0 []

tests :: TestTree
tests =
  testGroup
    "mlkih"
    [ testCase "simple beta reduction" testNbESemanticBetaReduction,
      -- testCase "checkUnfoldStack" testRecursionGuardPreventsLoop,
      testCase "defEqCacheHits" testDefEqCacheHits,
      testCase "struct eta-equivalence" testSemanticStructEtaEquivalence,
      testCase "K-rule index matching" testKRuleIndexMatching,
      testCase "generated Lean fixture exports theorem" testGeneratedLeanTheorem,
      testCase "generated Lean export groups inductive keys" testGeneratedLeanInductiveKeys,
      testCase "generated Lean export groups inductive declarations" testGeneratedLeanDeclAlignment,
      testCase "kernel checks generated natAddSuccFixture theorem" testKernelChecksGeneratedNatAddSuccFixtureTheorem,
      testCase "kernel checks imported nat recursor iota theorem" testKernelChecksImportedNatRecursorIotaTheorem,
      testCase "internExpr reuses imported expr ids" testInternExprReusesImportedIds,
      testCase "internExpr deduplicates local expressions" testInternExprDeduplicatesLocalExpressions,
      testCase "internLevel reuses zero level" testInternLevelReusesZeroLevel,
      testCase "level equivalence handles commutative max" testLevelEquivHandlesCommutativeMax,
      testCase "level ordering uses offset checking" testLevelGeqUsesOffsetChecking,
      testCase "level equivalence simplifies imax succ case" testLevelEquivSimplifiesIMaxSuccCase,
      testCase "level equivalence handles nested imax" testLevelEquivHandlesNestedIMax
    ]

testGeneratedLeanTheorem :: IO ()
testGeneratedLeanTheorem = do
  decls <- expectParseLeanFixture natAddSuccFixture
  assertEq True (hasTheoremNamed "natAddSuccFixture" decls) "expected generated export to contain the fixture theorem"

testGeneratedLeanInductiveKeys :: IO ()
testGeneratedLeanInductiveKeys = do
  decls <- expectParseLeanFixture natAddSuccFixture
  case namedInductiveBlocks "Nat" decls of
    [indDecl] -> do
      case indTypes indDecl of
        [indType] -> do
          assertName "Nat" (constName (indConst indType))
          assertEq ["Nat.zero", "Nat.succ"] (fmap nameToString (indCtors indType)) "expected grouped Nat constructor names"
        _ -> failWith "expected exactly one Nat inductive type"
      case indConstructors indDecl of
        [zeroCtor, succCtor] -> do
          assertName "Nat.zero" (constName (ctorConst zeroCtor))
          assertName "Nat.succ" (constName (ctorConst succCtor))
        _ -> failWith "expected two Nat constructors"
      case indRecursors indDecl of
        [rec] -> do
          assertName "Nat.rec" (constName (recConst rec))
          assertEq False (recKRule rec) "expected non-k Nat recursor"
          assertEq 2 (length (recRules rec)) "expected Nat recursor rules for zero and succ"
        _ -> failWith "expected exactly one Nat recursor"
    _ -> failWith "expected exactly one grouped Nat inductive block"

testGeneratedLeanDeclAlignment :: IO ()
testGeneratedLeanDeclAlignment = do
  decls <- expectParseLeanFixture natAddAddAddCommFixture
  assertEq True (hasTheoremNamed "natAddAddAddCommFixture" decls) "expected generated export to contain the fixture theorem"
  natBlocks <- pure $ namedInductiveBlocks "Nat" decls
  assertEq 1 (length natBlocks) "expected exactly one grouped Nat inductive block"
  assertEq False (hasStandaloneConstructor "Nat.zero" decls) "expected Nat.zero to stay inside grouped inductive export"
  assertEq False (hasStandaloneConstructor "Nat.succ" decls) "expected Nat.succ to stay inside grouped inductive export"
  assertEq False (hasStandaloneRecursor "Nat.rec" decls) "expected Nat.rec to stay inside grouped inductive export"

testKernelChecksGeneratedNatAddSuccFixtureTheorem :: IO ()
testKernelChecksGeneratedNatAddSuccFixtureTheorem = do
  parsed <- loadParsedLeanFixture natAddSuccFixture
  state <- expectRightKernel $ checkParsedExport parsed
  let env = checkEnv state
      checkedInternState = checkInternState state
  theoremDecl <-
    case findTheorem "natAddSuccFixture" (parsedDecls parsed) of
      Just (ThmDecl thm) -> pure thm
      _ -> failWith "expected natAddSuccFixture theorem declaration"
  (lookedUp, hasBody, unfoldable) <-
    expectRight . evalKernelM env checkedInternState $ do
      let theoremName = constName (thmConst theoremDecl)
      lookedUp <- lookupConstInfo theoremName
      hasBody <- constHasBody theoremName
      unfoldable <- constIsDeltaUnfoldable theoremName
      pure (lookedUp, hasBody, unfoldable)
  assertEq (Just (ThmInfo theoremDecl)) lookedUp "expected sequential checker to install the generated theorem after earlier declarations succeed"
  assertEq True hasBody "expected theorem body to remain available after declaration checking"
  assertEq False unfoldable "expected checked theorem declarations to remain non-delta-unfoldable"

testKernelChecksImportedNatRecursorIotaTheorem :: IO ()
testKernelChecksImportedNatRecursorIotaTheorem = do
  (env, checkedInternState) <- loadCheckedLeanFixture natAddSuccFixture
  lookedUp <-
    expectRight . evalKernelM env checkedInternState $ do
      theoremName <- withIntern $ internName (rawName ["natRecZeroFixture"])
      lookupConstInfo theoremName
  case lookedUp of
    Just (ThmInfo _) -> pure ()
    _ -> failWith "expected public checker path to admit the imported Nat.rec zero-case iota theorem"

testInternExprReusesImportedIds :: IO ()
testInternExprReusesImportedIds = do
  let rawLevel = Level (LSucc (Level LZero))
      rawExpr = Expr (Sort rawLevel)
  (_, st1) <- expectRight (registerImportedLevelIn 1 (LSucc (HCLevel 0 LZero)) emptyInternState)
  (importedExpr, st2) <- expectRight (registerImportedExprIn 7 (Sort (HCLevel 1 (LSucc (HCLevel 0 LZero)))) st1)
  let (internedExpr, _) = runState (internExpr rawExpr) st2
  assertEq 7 (hceId importedExpr) "expected imported expr id"
  assertEq 7 (hceId internedExpr) "expected raw interning to reuse imported expr id"
  assertEq importedExpr internedExpr "expected imported and interned expr to be identical by id"

testInternExprDeduplicatesLocalExpressions :: IO ()
testInternExprDeduplicatesLocalExpressions = do
  let rawExpr = Expr (App (Expr (BVar 0)) (Expr (BVar 1)))
      (expr1, st1) = runState (internExpr rawExpr) emptyInternState
      (expr2, _) = runState (internExpr rawExpr) st1
  assertEq (hceId expr1) (hceId expr2) "expected repeated local interning to reuse the same expr id"
  assertEq expr1 expr2 "expected repeated local interning to produce the same HCExpr"

testInternLevelReusesZeroLevel :: IO ()
testInternLevelReusesZeroLevel = do
  let (level1, st1) = runState (internLevel (Level LZero)) emptyInternState
      (level2, _) = runState (internLevel (Level LZero)) st1
  assertEq 0 (hclId level1) "expected zero level id"
  assertEq 0 (hclId level2) "expected zero level id on reuse"
  assertEq level1 level2 "expected zero level reuse by id"

testLevelEquivHandlesCommutativeMax :: IO ()
testLevelEquivHandlesCommutativeMax = do
  let u = rawName ["u"]
      v = rawName ["v"]
      lhs = internedLevel $ Level $ LMax (Level (LVar u)) (Level (LVar v))
      rhs = internedLevel $ Level $ LMax (Level (LVar v)) (Level (LVar u))
  assertEq True (levelEquiv lhs rhs) "expected max to compare commutatively"

testLevelGeqUsesOffsetChecking :: IO ()
testLevelGeqUsesOffsetChecking = do
  let u = rawName ["u"]
      lhs = internedLevel $ Level $ LSucc (Level (LVar u))
      rhs = internedLevel $ Level (LVar u)
  assertEq True (levelGeq lhs rhs) "expected succ(u) >= u by offset"

testLevelEquivSimplifiesIMaxSuccCase :: IO ()
testLevelEquivSimplifiesIMaxSuccCase = do
  let u = rawName ["u"]
      v = rawName ["v"]
      lhs = internedLevel $ Level $ LIMax (Level (LVar u)) (Level $ LSucc (Level (LVar v)))
      rhs = internedLevel $ Level $ LMax (Level (LVar u)) (Level $ LSucc (Level (LVar v)))
  assertEq True (levelEquiv lhs rhs) "expected imax with succ rhs to simplify to max"

testLevelEquivHandlesNestedIMax :: IO ()
testLevelEquivHandlesNestedIMax = do
  let u = rawName ["u"]
      v = rawName ["v"]
      w = rawName ["w"]
      lhs = internedLevel $ Level $ LIMax (Level (LVar u)) (Level $ LIMax (Level (LVar v)) (Level (LVar w)))
      rhs = internedLevel $ Level $ LIMax (Level $ LMax (Level (LVar u)) (Level (LVar v))) (Level (LVar w))
  assertEq True (levelEquiv lhs rhs) "expected nested imax to reassociate through mkIMax"

kernelEnvFromInfos :: [ConstantInfo HCExpr HCLevel] -> KernelEnv
kernelEnvFromInfos infos = IntMap.fromList [(hcnId (constantInfoName info), info) | info <- infos]

mkDefinitionInfo :: HCExpr -> HCName -> [HCName] -> ReducibilityHints -> HCExpr -> ConstantInfo HCExpr HCLevel
mkDefinitionInfo sortExpr name levelParams hints body =
  DefnInfo
    DefinitionVal
      { defConst = ConstantVal {constName = name, constLevelParameters = levelParams, constType = hceVal sortExpr},
        defHints = hints,
        defValue = hceVal body
      }

expectSingleAxiom :: ParsedExport -> IO (AxiomVal HCExpr HCLevel)
expectSingleAxiom parsed =
  case parsedDecls parsed of
    [AxiomDecl axiomVal] -> pure axiomVal
    other -> failWith ("expected exactly one parsed axiom, got: " <> show other)

data LeanFixture = LeanFixture
  { fixtureModuleName :: String,
    fixtureDeclNames :: [String]
  }

natAddSuccFixture :: LeanFixture
natAddSuccFixture =
  LeanFixture
    { fixtureModuleName = "NatAddSuccFixture",
      fixtureDeclNames = ["natAddSuccFixture", "natRecZeroFixture"]
    }

tutorialFixture :: LeanFixture
tutorialFixture =
  LeanFixture
    { fixtureModuleName = "TutorialFixture",
      fixtureDeclNames =
        ("TutorialFixture." <>)
          <$> [ "basicDef",
                "arrowType",
                "dependentType",
                "constType",
                "betaReduction",
                "betaReduction2",
                "id",
                "forallSortWhnf",
                "levelComp1",
                "levelComp2",
                "levelComp3",
                "levelParamF",
                "levelComp5",
                "imax1",
                "imax2",
                "inferVar",
                "defEqLambda",
                "PN",
                "PN.succ",
                "PN.zero",
                "PN.lit0",
                "PN.lit1",
                "PN.lit2",
                "peano1",
                "peano2",
                "peano3",
                "letType",
                "aDepProp",
                "mkADepProp",
                "aProp",
                "letRed",
                "Empty",
                "empty",
                "Bool",
                "boolType",
                "TwoBool",
                "TwoBool.mk",
                "twoBool",
                "And",
                "And.mk",
                "andType",
                "Prod",
                "Prod.mk",
                "prodType",
                "Eq",
                "Eq.refl",
                "eqType",
                "N",
                "N.zero",
                "N.succ",
                "natDef",
                "Color",
                "Color.r",
                "Color.b",
                "RBTree",
                "RBTree.leaf",
                "RBTree.red",
                "RBTree.black",
                "rbTreeDef"
              ]
    }

natAddAddAddCommFixture :: LeanFixture
natAddAddAddCommFixture =
  LeanFixture
    { fixtureModuleName = "NatAddAddAddCommFixture",
      fixtureDeclNames = ["natAddAddAddCommFixture"]
    }

expectParseLeanFixture :: LeanFixture -> IO [Decl HCExpr HCLevel]
expectParseLeanFixture fixture = do
  exportPath <- generateLeanExport fixture
  result <- parseExportFile exportPath
  -- removeFile exportPath
  case result of
    Left err -> failWith err
    Right decls -> pure decls

loadParsedLeanFixture :: LeanFixture -> IO ParsedExport
loadParsedLeanFixture fixture = do
  exportPath <- generateLeanExport fixture
  result <- parseExportFileWithState exportPath
  -- removeFile exportPath
  case result of
    Left err -> failWith err
    Right parsed -> pure parsed

loadCheckedLeanFixture :: LeanFixture -> IO (KernelEnv, InternState)
loadCheckedLeanFixture fixture = do
  exportPath <- generateLeanExport fixture
  -- removeFile exportPath
  state <- expectRightKernel =<< checkExportFile exportPath
  pure (checkEnv state, checkInternState state)

generateLeanExport :: LeanFixture -> IO FilePath
generateLeanExport fixture = do
  projectDir <- leanFixtureProjectDir
  _ <- runCheckedProcess projectDir "lake" ["build", fixtureModuleName fixture]
  _ <- runCheckedProcess projectDir "lake" ["build", "@lean4export/lean4export"]
  lean4exportDir <- pure (projectDir </> ".lake" </> "packages" </> "lean4export")
  let lean4exportBinaryPath = lean4exportDir </> ".lake" </> "build" </> "bin" </> "lean4export"
  exportPath <- makeAbsolute $ fixtureModuleName fixture <> ".exported.ndjson"
  exportHandle <- openFile exportPath WriteMode
  hClose exportHandle
  let exportCommand = unwords (fmap shellQuote (["lake", "env", lean4exportBinaryPath, fixtureModuleName fixture, "--"] <> fixtureDeclNames fixture)) <> " > " <> shellQuote exportPath
  _ <- runShellCommand projectDir exportCommand
  pure exportPath

leanFixtureProjectDir :: IO FilePath
leanFixtureProjectDir = do
  cwd <- getCurrentDirectory
  findProjectDir cwd
  where
    findProjectDir dir = do
      let marker = dir </> "test" </> "fixtures" </> "lean" </> "lakefile.toml"
      exists <- doesFileExist marker
      if exists
        then pure (takeDirectory marker)
        else do
          let parent = takeDirectory dir
          if parent == dir
            then failWith "could not locate test/fixtures/lean/lakefile.toml from current working directory"
            else findProjectDir parent

runCheckedProcess :: FilePath -> FilePath -> [String] -> IO String
runCheckedProcess workingDir cmd args = do
  baseEnv <- getEnvironment
  let processSpec =
        if cmd == "lake"
          then proc "/bin/sh" ["-lc", unwords ("lake" : fmap shellQuote args)]
          else proc cmd args
  spawnResult <- try (readCreateProcessWithExitCode (processSpec {cwd = Just workingDir, env = Just baseEnv}) "") :: IO (Either IOException (ExitCode, String, String))
  case spawnResult of
    Left ioErr ->
      failWith
        ( unlines
            [ "command spawn failed: " <> unwords (cmd : args),
              "working directory: " <> workingDir,
              "exception: " <> show ioErr
            ]
        )
    Right (exitCode, stdoutText, stderrText) ->
      case exitCode of
        ExitSuccess -> pure stdoutText
        ExitFailure code ->
          failWith
            ( unlines
                [ "command failed: " <> unwords (cmd : args),
                  "working directory: " <> workingDir,
                  "exit code: " <> show code,
                  "stderr:",
                  stderrText,
                  "stdout:",
                  stdoutText
                ]
            )

runShellCommand :: FilePath -> String -> IO String
runShellCommand workingDir commandText = do
  baseEnv <- getEnvironment
  let processSpec = proc "/bin/sh" ["-lc", commandText]
  spawnResult <- try (readCreateProcessWithExitCode (processSpec {cwd = Just workingDir, env = Just baseEnv}) "") :: IO (Either IOException (ExitCode, String, String))
  case spawnResult of
    Left ioErr ->
      failWith
        ( unlines
            [ "command spawn failed: " <> commandText,
              "working directory: " <> workingDir,
              "exception: " <> show ioErr
            ]
        )
    Right (exitCode, stdoutText, stderrText) ->
      case exitCode of
        ExitSuccess -> pure stdoutText
        ExitFailure code ->
          failWith
            ( unlines
                [ "command failed: " <> commandText,
                  "working directory: " <> workingDir,
                  "exit code: " <> show code,
                  "stderr:",
                  stderrText,
                  "stdout:",
                  stdoutText
                ]
            )

shellQuote :: String -> String
shellQuote text = "'" <> concatMap escapeChar text <> "'"
  where
    escapeChar '\'' = "'\\''"
    escapeChar ch = [ch]

hasTheoremNamed :: String -> [Decl HCExpr HCLevel] -> Bool
hasTheoremNamed target = any isTargetTheorem
  where
    isTargetTheorem (ThmDecl thm) = toString (constName (thmConst thm)) == target
    isTargetTheorem _ = False

findTheorem :: String -> [Decl HCExpr HCLevel] -> Maybe (Decl HCExpr HCLevel)
findTheorem target = go
  where
    go [] = Nothing
    go (decl : rest) =
      case decl of
        ThmDecl thm
          | toString (constName (thmConst thm)) == target -> Just decl
        _ -> go rest

findDefinition :: String -> [Decl HCExpr HCLevel] -> Maybe (Decl HCExpr HCLevel)
findDefinition target = go
  where
    go [] = Nothing
    go (decl : rest) =
      case decl of
        DefnDecl defn
          | toString (constName (defConst defn)) == target -> Just decl
        _ -> go rest

hasDefinitionNamed :: String -> [Decl HCExpr HCLevel] -> Bool
hasDefinitionNamed target = any isTargetDefinition
  where
    isTargetDefinition (DefnDecl defn) = toString (constName (defConst defn)) == target
    isTargetDefinition _ = False

hasOpaqueNamed :: String -> [Decl HCExpr HCLevel] -> Bool
hasOpaqueNamed target = any isTargetOpaque
  where
    isTargetOpaque (OpaqueDecl opaqueVal) = toString (constName (opaqueConst opaqueVal)) == target
    isTargetOpaque _ = False

namedInductiveBlocks :: String -> [Decl HCExpr HCLevel] -> [InductiveDecl HCExpr HCLevel]
namedInductiveBlocks target = foldr collect []
  where
    collect (InductiveBlockDecl indDecl) acc
      | any ((== target) . toString . constName . indConst) (indTypes indDecl) = indDecl : acc
      | otherwise = acc
    collect _ acc = acc

hasStandaloneConstructor :: String -> [Decl HCExpr HCLevel] -> Bool
hasStandaloneConstructor target = any isTargetCtor
  where
    isTargetCtor (CtorDecl ctor) = toString (constName (ctorConst ctor)) == target
    isTargetCtor _ = False

hasStandaloneRecursor :: String -> [Decl HCExpr HCLevel] -> Bool
hasStandaloneRecursor target = any isTargetRec
  where
    isTargetRec (RecDecl rec) = toString (constName (recConst rec)) == target
    isTargetRec _ = False

loadParsedExportFixture :: FilePath -> IO ParsedExport
loadParsedExportFixture fixtureName = do
  path <- fixturePath fixtureName
  expectRight =<< parseExportFileWithState path

loadExportFixtureBytes :: FilePath -> IO ByteString
loadExportFixtureBytes fixtureName = do
  path <- fixturePath fixtureName
  BSC.readFile path

extractFixtureLinesByPrefix :: [ByteString] -> ByteString -> ByteString
extractFixtureLinesByPrefix prefixes =
  BSC.unlines . filter matchesPrefix . BSC.lines
  where
    matchesPrefix line = any (`BSC.isPrefixOf` line) prefixes

expectFixtureFailureContaining :: String -> FilePath -> IO ()
expectFixtureFailureContaining needle fixtureName = do
  path <- fixturePath fixtureName
  result <- parseExportFile path
  case result of
    Left err ->
      if needle `isInfixOf` err
        then pure ()
        else assertFailure ("expected parse failure containing " <> show needle <> ", got: " <> err)
    Right _ -> assertFailure ("expected parse failure containing " <> show needle <> ", but parse succeeded")

expectRight :: Either KernelError a -> IO a
expectRight result = case result of
  Left err -> assertFailure err
  Right value -> pure value

runKernelExpectRight :: KernelEnv -> KernelM a -> IO a
runKernelExpectRight env action = expectRight =<< fst <$> runKernelWithTraceIO env emptyInternState action

neverCompareArgs :: HCExpr -> HCExpr -> KernelM Bool
neverCompareArgs _ _ = throwError "unexpected same-head regular pre-unfold comparison"

assertEq :: (Eq a, Show a) => a -> a -> String -> IO ()
assertEq expected actual message =
  if expected == actual
    then pure ()
    else assertFailure (message <> ": expected " <> show expected <> ", got " <> show actual)

assertName :: String -> HCName -> IO ()
assertName expected actual =
  assertEq expected (nameToString actual) "unexpected name"

assertExprStructEq :: HCExpr -> HCExpr -> String -> IO ()
assertExprStructEq expected actual message =
  assertEq (toString expected) (toString actual) message

assertNeq :: (Eq a, Show a) => a -> a -> String -> IO ()
assertNeq lhs rhs message =
  if lhs /= rhs
    then pure ()
    else assertFailure (message <> ": both values were " <> show lhs)

fixturePath :: FilePath -> IO FilePath
fixturePath fixtureName =
  getDataFileName ("test/fixtures/export/" <> fixtureName)

failWith :: String -> IO a
failWith = assertFailure

internedLevel :: Level -> HCLevel
internedLevel level = fst $ runState (internLevel level) emptyInternState

rawName :: [String] -> Name
rawName = foldl appendSegment (Name Anonymous)
  where
    appendSegment prefix segment = Name (Str prefix (Text.pack segment))

rawSortZeroExpr :: Expr
rawSortZeroExpr = Expr (Sort (Level LZero))

rawBVarExpr :: Int -> Expr
rawBVarExpr idx = Expr (BVar idx)

rawNatExpr :: Natural -> Expr
rawNatExpr n = Expr (Lit (NatVal n))

rawConstExpr :: [String] -> Expr
rawConstExpr segments = Expr (Const (rawName segments) [])

rawAppExpr :: Expr -> Expr -> Expr
rawAppExpr fn arg = Expr (App fn arg)

rawAppsExpr :: Expr -> [Expr] -> Expr
rawAppsExpr = foldl rawAppExpr

rawLamExpr :: [String] -> Expr -> Expr -> BinderInfo -> Expr
rawLamExpr nameSegments ty body binderInfo = Expr (Lam (rawName nameSegments) ty body binderInfo)

rawProjExpr :: [String] -> Int -> Expr -> Expr
rawProjExpr typeNameSegments idx struct = Expr (Proj (rawName typeNameSegments) idx struct)

hcName :: [String] -> HCName
hcName segments = fst $ runState (internName (rawName segments)) emptyInternState

hcNames :: [[String]] -> [HCName]
hcNames segmentsList = fst $ runState (traverse (internName . rawName) segmentsList) emptyInternState

hcNames3 :: [String] -> [String] -> [String] -> (HCName, HCName, HCName)
hcNames3 a b c =
  case hcNames [a, b, c] of
    [x, y, z] -> (x, y, z)
    _ -> error "unreachable hcNames3"

hcNames4 :: [String] -> [String] -> [String] -> [String] -> (HCName, HCName, HCName, HCName)
hcNames4 a b c d =
  case hcNames [a, b, c, d] of
    [w, x, y, z] -> (w, x, y, z)
    _ -> error "unreachable hcNames4"
