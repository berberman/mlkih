{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Control.Exception (IOException, try)
import Control.Monad (replicateM)
import Control.Monad.Error.Class (throwError)
import Control.Monad.Reader (local)
import Control.Monad.State.Strict (gets, runState)
import Data.ByteString (ByteString)
import qualified Data.ByteString.Char8 as BSC
import qualified Data.IntMap.Strict as IntMap
import Data.List (isInfixOf)
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
import Paths_mlkih (getDataFileName)
import System.Directory (doesFileExist, getCurrentDirectory, getTemporaryDirectory, removeFile)
import System.Environment (getEnvironment)
import System.Exit (ExitCode (..))
import System.FilePath (takeDirectory, (</>))
import System.IO (hClose, openTempFile)
import System.Process (CreateProcess (cwd, env), proc, readCreateProcessWithExitCode)
import Test.Tasty (TestTree, defaultMain, testGroup)
import Test.Tasty.HUnit

main :: IO ()
main = defaultMain tests

tests :: TestTree
tests =
  testGroup
    "mlkih"
    [ -- testCase "Beta-Reduction" testNbESemanticBetaReduction,
      -- testCase "checkUnfoldStack" testRecursionGuardPreventsLoop,
      -- testCase "defEqCacheHits" testDefEqCacheHits,
      testCase "struct eta-equivalence" testSemanticStructEtaEquivalence
      -- testCase "K-rule index matching" testKRuleIndexMatching
    ]

testDefEqCacheHits :: IO ()
testDefEqCacheHits = do
  (result, failedCacheAfter) <- expectRight $ runKernelWithTraceIO IntMap.empty emptyInternState $ do
    -- Construct two definitively distinct expressions
    exprA <- mkLit (NatVal 1)
    exprB <- mkLit (NatVal 2)

    -- 1. Compare them (This will fail and cache the failure)
    _ <- isDefEq exprA exprB

    -- 2. Verify checkFailed populated
    failedPopulated <- isFailedExprPair exprA exprB

    -- 3. Run it again! It should instantly hit the failed cache.
    resultFail <- isDefEq exprA exprB

    pure (resultFail, failedPopulated)

  assertEq False result "expected distinct literals to fail"
  assertEq True failedCacheAfter "expected the negative cache to memoize the failure"

testRecursionGuardPreventsLoop :: IO ()
testRecursionGuardPreventsLoop = do
  let ((recName, sortExpr, recExpr, stuckExpr, recBody), internState) = runState build emptyInternState
      env = kernelEnvFromInfos [mkDefinitionInfo sortExpr recName [] (Regular 1) recBody]

  (result, stackAfter) <- expectRight $ runKernelWithTraceIO env internState $ do
    -- Try to prove `rec = 0`.
    -- The kernel will unfold `rec` to `rec`, hit the stack guard, and cleanly abort.
    res <- isDefEq recExpr stuckExpr

    -- Verify the stack cleaned up after itself
    finalStack <- gets checkUnfoldStack
    pure (res, null finalStack)

  assertEq False result "expected infinite recursion to be intercepted and fail gracefully"
  assertEq True stackAfter "expected the unfold stack to be completely empty after the attempt"
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
  let ((structName, ctorName, sortExpr, structTy, ctorTy), internState) = runState build emptyInternState
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

  result <- expectRight $ runKernelWithTraceIO env internState $ do
    structExpr <- mkConst structName []
    structTyVal <- evalM [] structExpr

    let pHint = hcName ["p"]
    pFVar <- freshFVar pHint
    pVar <- mkFVar pFVar
    withLocalDecl pFVar (LocalDecl structTyVal Nothing) $ do
      -- Create `Struct.mk p.0 p.1`
      ctorExpr <- mkConst ctorName []
      p0 <- mkProj structName 0 pVar
      p1 <- mkProj structName 1 pVar
      etaExpanded <- mkApps ctorExpr [p0, p1]

      -- Compare `p` to `Struct.mk p.0 p.1`
      isDefEq pVar etaExpanded

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
  let ((eqName, reflName, recName, sortExpr, eqTyExpr, recTyExpr, reflTyExpr), initialInternState) = runState build emptyInternState

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

  (reducedEq, stuckEq) <- expectRight
    $ runKernelWithTraceIO env initialInternState
    $ local
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
    $ do
      zero <- mkLevelZero
      sortZero <- mkSort zero
      sortZeroVal <- evalM [] sortZero

      alphaFv <- freshFVar (hcName ["alpha"])
      aFv <- freshFVar (hcName ["a"])
      bFv <- freshFVar (hcName ["b"])
      motiveFv <- freshFVar (hcName ["motive"])
      minorFv <- freshFVar (hcName ["minor"])

      alpha <- mkFVar alphaFv
      a <- mkFVar aFv
      b <- mkFVar bFv
      motive <- mkFVar motiveFv
      minor <- mkFVar minorFv

      -- SAFELY build the constants using their guaranteed unique IDs
      eqConst <- mkConst eqName []
      recConst <- mkConst recName []

      eqSameType <- mkApps eqConst [alpha, a, a]
      eqDiffType <- mkApps eqConst [alpha, a, b]

      eqSameTyVal <- evalM [] eqSameType
      eqDiffTyVal <- evalM [] eqDiffType

      hSameFv <- freshFVar (hcName ["h_same"])
      hDiffFv <- freshFVar (hcName ["h_diff"])

      withLocalDecl alphaFv (LocalDecl sortZeroVal Nothing) $
        withLocalDecl aFv (LocalDecl sortZeroVal Nothing) $
          withLocalDecl bFv (LocalDecl sortZeroVal Nothing) $
            withLocalDecl motiveFv (LocalDecl sortZeroVal Nothing) $
              withLocalDecl minorFv (LocalDecl sortZeroVal Nothing) $
                withLocalDecl hSameFv (LocalDecl eqSameTyVal Nothing) $
                  withLocalDecl hDiffFv (LocalDecl eqDiffTyVal Nothing) $ do
                    hSame <- mkFVar hSameFv
                    hDiff <- mkFVar hDiffFv

                    -- SAFELY apply the arguments to the true Eq.rec constant
                    recAppSame <- mkApps recConst [alpha, a, motive, minor, a, hSame]
                    recAppDiff <- mkApps recConst [alpha, a, motive, minor, b, hDiff]

                    reducedResult <- isDefEq recAppSame minor
                    stuckResult <- isDefEq recAppDiff minor

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
  result <- expectRight $ runKernelWithTraceIO IntMap.empty emptyInternState $ do
    zero <- mkLevelZero
    one <- mkLevelSucc zero
    sortOne <- mkSort one

    -- \x -> x
    bodyVar <- mkBVar 0
    idFunc <- mkLam (hcName ["x"]) sortOne bodyVar Default

    -- (\x -> x) 42
    arg <- mkLit (NatVal 42)
    applied <- mkApp idFunc arg

    -- isDefEq applied 42
    isDefEq applied arg

  assertEq True result "expected NbE to natively beta-reduce application to argument"

rawSortOneExpr :: Expr
rawSortOneExpr = Expr (Sort (Level $ LSucc $ Level LZero))

-- tests :: TestTree
-- tests =
--   testGroup
--     "mlkih"
--     [
--       testCase "generated Lean fixture exports theorem" testGeneratedLeanTheorem,
--       testCase "generated Lean export groups inductive keys" testGeneratedLeanInductiveKeys,
--       testCase "generated Lean export groups inductive declarations" testGeneratedLeanDeclAlignment,
--       testCase "kernel checks generated natAddSuccFixture theorem" testKernelChecksGeneratedNatAddSuccFixtureTheorem,
--       testCase "kernel checks generated export sequentially" testKernelChecksGeneratedExportSequentially,
--       testCase "kernel checks imported nat recursor iota theorem" testKernelChecksImportedNatRecursorIotaTheorem,
--       testCase "kernel checks atomic grouped inductive block" testKernelChecksAtomicGroupedInductiveBlock,
--       testCase "kernel rejects non-atomic grouped inductive insertion" testKernelRejectsNonAtomicGroupedInductiveInsertion,
--       testCase "kernel checks quotient-related declarations from lean export" testKernelChecksQuotientRelatedDeclarationsFromLeanExport,
--       testCase "kernel rejects declaration with body type mismatch" testKernelRejectsDeclarationWithBodyTypeMismatch,
--       testCase "kernel rejects arena fixture with type mismatch" testKernelRejectsArenaFixtureWithTypeMismatch,
--       testCase "kernel rejects export with unsupported declaration in stream" testKernelRejectsExportWithUnsupportedDeclarationInStream,
--       testCase "kernel imports all parser-visible declaration kinds needed by lean exports" testKernelImportsAllParserVisibleDeclarationKindsNeededByLeanExports,
--       testCase "kernel rejects malformed or out-of-contract declaration forms" testKernelRejectsMalformedOrOutOfContractDeclarationForms,
--       testCase "kernel fixture harness loads conversion fixtures" testKernelFixtureHarnessLoadsConversionFixtures,
--       testCase "kernel fixture harness reports negative conversion fixtures" testKernelFixtureHarnessReportsNegativeConversionFixtures,
--       testCase "decl pretty printing reaches semantic wrappers" testDeclPrettyPrinting,
--       testCase "inductive rejects missing constructor payloads" testInductiveMissingConstructor,
--       testCase "inductive rejects constructors from other inductives" testInductiveWrongConstructorOwner,
--       testCase "meta must be first record" testMetaMustBeFirst,
--       testCase "duplicate declarations are rejected" testDuplicateDeclarations,
--       testCase "extra top-level keys are rejected" testExtraTopLevelKeys,
--       testCase "internExpr reuses imported expr ids" testInternExprReusesImportedIds,
--       testCase "internExpr deduplicates local expressions" testInternExprDeduplicatesLocalExpressions,
--       testCase "internLevel reuses zero level" testInternLevelReusesZeroLevel,
--       testCase "level equivalence handles commutative max" testLevelEquivHandlesCommutativeMax,
--       testCase "level ordering uses offset checking" testLevelGeqUsesOffsetChecking,
--       testCase "level equivalence simplifies imax succ case" testLevelEquivSimplifiesIMaxSuccCase,
--       testCase "level equivalence handles nested imax" testLevelEquivHandlesNestedIMax,
--       testCase "duplicate imported expr payloads reuse canonical node" testDuplicateImportedExprPayloads,
--       testCase "duplicate imported level payloads reuse canonical node" testDuplicateImportedLevelPayloads,
--       testCase "runKernelM starts with empty interner state for empty env" testrunKernelMStartsWithEmptyInternerState,
--       testCase "kernel shares imported canonical ids" testKernelSharesImportedCanonicalIds,
--       testCase "kernel rejects mismatched checker interner" testKernelRejectsMismatchedCheckerInterner,
--       testCase "kernel does not delta unfold theorem body" testKernelDoesNotDeltaUnfoldTheoremBody,
--       testCase "kernel does not delta unfold opaque body" testKernelDoesNotDeltaUnfoldOpaqueBody,
--       testCase "kernel rejects same-head non-unfoldable universe mismatches" testKernelRejectsSameHeadNonUnfoldableUniverseMismatches,
--       testCase "kernel uses universe comparison before unnecessary unfolding" testKernelUsesUniverseComparisonBeforeUnnecessaryUnfolding,
--       testCase "kernel validates simple inductive recursor" testKernelValidatesSimpleInductiveRecursor,
--       testCase "kernel defeq handles projection and iota cases" testKernelDefeqHandlesProjectionAndIotaCases,
--       testCase "kernel rejects bad recursor payload" testKernelRejectsBadRecursorPayload,
--       testCase "kernel defeq handles binder alpha-equivalence and failures" testKernelDefeqHandlesBinderAlphaEquivalenceAndFailures,
--       testCase "kernel prevents infinite unfolding on recursive defs" testKernelPreventsInfiniteUnfoldingOnRecursiveDefs,
--       testCase "kernel terminates on mutual recursive conversion failures" testKernelTerminatesOnMutualRecursiveConversionFailures,
--       testCase "kernel does not confuse recursion control with expr classes" testKernelDoesNotConfuseRecursionControlWithExprClasses,
--       testCase "lookupConstInfo reads kernel env" testLookupConstInfoReadsKernelEnv,
--       testCase "findExprClassRoot starts as singleton representative" testFindExprClassRootStartsAsSingletonRepresentative,
--       testCase "sameExprClass starts false for distinct exprs" testSameExprClassStartsFalseForDistinctExprs,
--       testCase "unionExprClasses merges transitively" testUnionExprClassesMergesTransitively,
--       testCase "unionExprClasses is idempotent" testUnionExprClassesIsIdempotent,
--       testCase "mkSort reuses interned zero level" testMkSortReusesInternedZeroLevel,
--       testCase "mkApps builds left-associated apps" testMkAppsBuildsLeftAssociatedApps,
--       testCase "kernel syntax helper views preserve expression shape" testKernelSyntaxHelperViewsPreserveExpressionShape,
--       testCase "kernel projection view rejects malformed spine" testKernelProjectionViewRejectsMalformedSpine,
--       testCase "instantiateLevelParams rewrites sort and const levels" testInstantiateLevelParamsRewritesSortAndConstLevels,
--       testCase "instantiateLevelParams traverses forall and let payloads" testInstantiateLevelParamsTraversesForallAndLetPayloads,
--       testCase "instantiateLevelParams leaves unchanged expr identical" testInstantiateLevelParamsLeavesUnchangedExprIdentical,
--       testCase "instantiate1 replaces outermost binder" testInstantiate1ReplacesOutermostBinder,
--       testCase "instantiate1 preserves inner binders" testInstantiate1PreservesInnerBinders,
--       testCase "kernel whnf reduces beta and zeta" testKernelWhnfReducesBetaAndZeta,
--       testCase "kernel whnf handles stuck and reducible projection cases" testKernelWhnfHandlesStuckAndReducibleProjectionCases,
--       testCase "kernel whnf exposes iota redexes without full normalization" testKernelWhnfExposesIotaRedexesWithoutFullNormalization
--     ]

-- testGeneratedLeanTheorem :: IO ()
-- testGeneratedLeanTheorem = do
--   decls <- expectParseLeanFixture natAddSuccFixture
--   assertEq True (hasTheoremNamed "natAddSuccFixture" decls) "expected generated export to contain the fixture theorem"

-- testGeneratedLeanInductiveKeys :: IO ()
-- testGeneratedLeanInductiveKeys = do
--   decls <- expectParseLeanFixture natAddSuccFixture
--   case namedInductiveBlocks "Nat" decls of
--     [indDecl] -> do
--       case indTypes indDecl of
--         [indType] -> do
--           assertName "Nat" (constName (indConst indType))
--           assertEq ["Nat.zero", "Nat.succ"] (fmap toString (indCtors indType)) "expected grouped Nat constructor names"
--         _ -> failWith "expected exactly one Nat inductive type"
--       case indConstructors indDecl of
--         [zeroCtor, succCtor] -> do
--           assertName "Nat.zero" (constName (ctorConst zeroCtor))
--           assertName "Nat.succ" (constName (ctorConst succCtor))
--         _ -> failWith "expected two Nat constructors"
--       case indRecursors indDecl of
--         [rec] -> do
--           assertName "Nat.rec" (constName (recConst rec))
--           assertEq False (recKRule rec) "expected non-k Nat recursor"
--           assertEq 2 (length (recRules rec)) "expected Nat recursor rules for zero and succ"
--         _ -> failWith "expected exactly one Nat recursor"
--     _ -> failWith "expected exactly one grouped Nat inductive block"

-- testGeneratedLeanDeclAlignment :: IO ()
-- testGeneratedLeanDeclAlignment = do
--   decls <- expectParseLeanFixture natAddAddAddCommFixture
--   assertEq True (hasTheoremNamed "natAddAddAddCommFixture" decls) "expected generated export to contain the fixture theorem"
--   natBlocks <- pure $ namedInductiveBlocks "Nat" decls
--   assertEq 1 (length natBlocks) "expected exactly one grouped Nat inductive block"
--   assertEq False (hasStandaloneConstructor "Nat.zero" decls) "expected Nat.zero to stay inside grouped inductive export"
--   assertEq False (hasStandaloneConstructor "Nat.succ" decls) "expected Nat.succ to stay inside grouped inductive export"
--   assertEq False (hasStandaloneRecursor "Nat.rec" decls) "expected Nat.rec to stay inside grouped inductive export"

-- testKernelChecksGeneratedNatAddSuccFixtureTheorem :: IO ()
-- testKernelChecksGeneratedNatAddSuccFixtureTheorem = do
--   parsed <- loadParsedLeanFixture natAddSuccFixture
--   (env, checkedInternState) <- expectRight $ checkAndAddDecls IntMap.empty (parsedInternState parsed) (parsedDecls parsed)
--   theoremDecl <-
--     case findTheorem "natAddSuccFixture" (parsedDecls parsed) of
--       Just (ThmDecl thm) -> pure thm
--       _ -> failWith "expected natAddSuccFixture theorem declaration"
--   (lookedUp, hasBody, unfoldable) <-
--     expectRight . evalKernelM env checkedInternState $ do
--       let theoremName = constName (thmConst theoremDecl)
--       lookedUp <- lookupConstInfo theoremName
--       hasBody <- constHasBody theoremName
--       unfoldable <- constIsDeltaUnfoldable theoremName
--       pure (lookedUp, hasBody, unfoldable)
--   assertEq (Just (ThmInfo theoremDecl)) lookedUp "expected sequential checker to install the generated theorem after earlier declarations succeed"
--   assertEq True hasBody "expected theorem body to remain available after declaration checking"
--   assertEq False unfoldable "expected checked theorem declarations to remain non-delta-unfoldable"

-- testKernelChecksGeneratedExportSequentially :: IO ()
-- testKernelChecksGeneratedExportSequentially = do
--   (env, checkedInternState) <- loadCheckedLeanFixture natAddSuccFixture
--   lookedUpInfos <-
--     expectRight . evalKernelM env checkedInternState $ do
--       natName <- internNameM (rawName ["Nat"])
--       zeroName <- internNameM (rawName ["Nat", "zero"])
--       succName <- internNameM (rawName ["Nat", "succ"])
--       recName <- internNameM (rawName ["Nat", "rec"])
--       theoremName <- internNameM (rawName ["natAddSuccFixture"])
--       traverse lookupConstInfo [natName, zeroName, succName, recName, theoremName]
--   assertEq 5 (length lookedUpInfos) "expected end-to-end export checking to populate the grouped Nat block and later theorem"
--   assertEq True (all hasInfo lookedUpInfos) "expected end-to-end checker path to publish grouped inductives atomically and keep later declarations visible"
--   where
--     hasInfo = maybe False (const True)

-- testKernelChecksImportedNatRecursorIotaTheorem :: IO ()
-- testKernelChecksImportedNatRecursorIotaTheorem = do
--   (env, checkedInternState) <- loadCheckedLeanFixture natAddSuccFixture
--   lookedUp <-
--     expectRight . evalKernelM env checkedInternState $ do
--       theoremName <- internNameM (rawName ["natRecZeroFixture"])
--       lookupConstInfo theoremName
--   case lookedUp of
--     Just (ThmInfo _) -> pure ()
--     _ -> failWith "expected public checker path to admit the imported Nat.rec zero-case iota theorem"

-- testKernelChecksAtomicGroupedInductiveBlock :: IO ()
-- testKernelChecksAtomicGroupedInductiveBlock = do
--   parsed <- loadParsedLeanFixture natAddSuccFixture
--   natBlock <-
--     case namedInductiveBlocks "Nat" (parsedDecls parsed) of
--       [indDecl] -> pure indDecl
--       _ -> failWith "expected exactly one grouped Nat inductive block"
--   (env, checkedInternState) <- expectRight $ checkAndAddDecl IntMap.empty (parsedInternState parsed) (InductiveBlockDecl natBlock)
--   lookedUpInfos <-
--     expectRight . evalKernelM env checkedInternState $ do
--       natName <- internNameM (rawName ["Nat"])
--       zeroName <- internNameM (rawName ["Nat", "zero"])
--       succName <- internNameM (rawName ["Nat", "succ"])
--       recName <- internNameM (rawName ["Nat", "rec"])
--       traverse lookupConstInfo [natName, zeroName, succName, recName]
--   assertEq 4 (length lookedUpInfos) "expected grouped Nat block members to install together after successful checking"
--   assertEq True (all hasInfo lookedUpInfos) "expected grouped Nat block checking to publish the inductive, constructors, and recursor as one unit"
--   where
--     hasInfo = maybe False (const True)

-- testKernelRejectsNonAtomicGroupedInductiveInsertion :: IO ()
-- testKernelRejectsNonAtomicGroupedInductiveInsertion = do
--   let (decls, internState) = nonAtomicGroupedInsertionFixture
--   case checkAndAddDecls IntMap.empty internState decls of
--     Left err ->
--       assertEq True ("unknown constant: Kernel.AtomicBad.Missing" `isInfixOf` err) "expected grouped block checking to fail before any inner members become usable"
--     Right _ -> failWith "expected grouped block failure to reject incremental insertion semantics"

-- testKernelChecksQuotientRelatedDeclarationsFromLeanExport :: IO ()
-- testKernelChecksQuotientRelatedDeclarationsFromLeanExport = do
--   parsed <- loadParsedExportFixture conversionSupportFixture
--   let quotDecls = [decl | decl@(QuotDecl _) <- parsedDecls parsed]
--       quotKinds = [kind | QuotDecl quotVal <- quotDecls, let kind = quotKind quotVal]
--   assertEq [Quot, QuotMk, QuotLift, QuotInd] quotKinds "expected support export to expose the trusted quotient declaration surface"
--   (env, checkedInternState) <- expectRight $ checkAndAddDecls IntMap.empty (parsedInternState parsed) quotDecls
--   lookedUpKinds <-
--     expectRight . evalKernelM env checkedInternState $ do
--       traverse
--         ( \decl ->
--             case decl of
--               QuotDecl quotVal -> do
--                 lookedUp <- lookupConstInfo (constName (quotConst quotVal))
--                 pure $ case lookedUp of
--                   Just (QuotInfo info) -> Just (quotKind info)
--                   _ -> Nothing
--               _ -> pure Nothing
--         )
--         quotDecls
--   assertEq (fmap Just quotKinds) lookedUpKinds "expected quotient-related declarations to typecheck sequentially and enter the kernel env as QuotInfo entries"

-- testKernelRejectsDeclarationWithBodyTypeMismatch :: IO ()
-- testKernelRejectsDeclarationWithBodyTypeMismatch = do
--   let (badDecl, internState) = bodyTypeMismatchDecl
--       result = checkAndAddDecl IntMap.empty internState badDecl
--   case result of
--     Left err ->
--       assertEq True ("type mismatch: expected" `isInfixOf` err) "expected declaration checker to reject a body whose inferred type does not match the declared type"
--     Right _ -> failWith "expected declaration checker to reject body type mismatch"

-- testKernelRejectsArenaFixtureWithTypeMismatch :: IO ()
-- testKernelRejectsArenaFixtureWithTypeMismatch = do
--   path <- fixturePath arenaTypeMismatchFixture
--   result <- checkExportFile path
--   case result of
--     Left err ->
--       assertEq True ("type mismatch: expected" `isInfixOf` err) "expected repo-local arena-style checker fixture to reach kernel checking and fail on a real type mismatch"
--     Right _ -> failWith "expected repo-local arena-style checker fixture to fail during kernel checking"

-- testKernelRejectsExportWithUnsupportedDeclarationInStream :: IO ()
-- testKernelRejectsExportWithUnsupportedDeclarationInStream = do
--   fixtureBytes <- loadExportFixtureBytes conversionSupportFixture
--   let result = checkExport (extractFixtureLinesByPrefix supportStandaloneCtorPrefixes fixtureBytes)
--   case result of
--     Left err ->
--       assertEq True ("standalone constructor checking is not supported yet: StandaloneCtor" `isInfixOf` err) "expected end-to-end export checker to reject parsed standalone constructor declarations in-stream"
--     Right _ -> failWith "expected end-to-end export checker to reject unsupported declaration kinds in the export stream"

-- testKernelImportsAllParserVisibleDeclarationKindsNeededByLeanExports :: IO ()
-- testKernelImportsAllParserVisibleDeclarationKindsNeededByLeanExports = do
--   parsed <- loadParsedExportFixture conversionSupportFixture
--   let decls = parsedDecls parsed
--       internState = parsedInternState parsed
--       quotKinds = [kind | QuotDecl quotVal <- decls, let kind = quotKind quotVal]
--   assertEq 12 (length decls) "expected every support-matrix declaration wrapper to lower through the trusted boundary"
--   assertEq True (hasDefinitionNamed "DefOpaqueUnsafe" decls) "expected trusted boundary to import opaque-hint unsafe definitions"
--   assertEq True (hasDefinitionNamed "DefAbbrevPartial" decls) "expected trusted boundary to import partial abbrev definitions"
--   assertEq True (hasTheoremNamed "ThmSupport" decls) "expected theorem support path"
--   assertEq True (hasOpaqueNamed "OpaqueSupport" decls) "expected opaque support path"
--   assertEq [Quot, QuotMk, QuotLift, QuotInd] quotKinds "expected all quot declaration kinds to lower intentionally"
--   assertEq True (hasStandaloneConstructor "StandaloneCtor" decls) "expected standalone constructor support path"
--   assertEq True (hasStandaloneRecursor "StandaloneRec" decls) "expected standalone recursor support path"
--   assertEq 1 (length (namedInductiveBlocks "AliasInd" decls)) "expected grouped inductive alias keys to lower into one inductive block"
--   case findDefinition "DefOpaqueUnsafe" decls of
--     Just (DefnDecl defn) -> assertEq Opaque (defHints defn) "expected opaque reducibility hints to survive the boundary"
--     _ -> failWith "expected DefOpaqueUnsafe definition"
--   case lookupLevelId 4 internState of
--     Just levelVal ->
--       case hclVal levelVal of
--         LIMax _ _ -> pure ()
--         _ -> failWith "expected imported level id 4 to preserve imax structure"
--     Nothing -> failWith "expected imported imax level"
--   case lookupExprId 8 internState of
--     Just exprVal ->
--       case hceVal exprVal of
--         Lam _ _ _ StrictImplicit -> pure ()
--         _ -> failWith "expected imported lambda to preserve strictImplicit binder info"
--     Nothing -> failWith "expected imported strictImplicit lambda"
--   case lookupExprId 11 internState of
--     Just exprVal ->
--       case hceVal exprVal of
--         Proj _ 0 _ -> pure ()
--         _ -> failWith "expected imported projection expression"
--     Nothing -> failWith "expected imported projection expression"
--   case (lookupExprId 4 internState, lookupExprId 5 internState) of
--     (Just strExpr, Just mdataExpr) -> assertEq strExpr mdataExpr "expected mdata wrapper to lower to the underlying imported expression"
--     _ -> failWith "expected imported strVal and mdata expressions"

-- testKernelRejectsMalformedOrOutOfContractDeclarationForms :: IO ()
-- testKernelRejectsMalformedOrOutOfContractDeclarationForms = do
--   expectFixtureFailureContaining "missing field 'isUnsafe'" missingAxiomIsUnsafeFixture
--   expectFixtureFailureContaining "unexpected keys in field 'def' payload: extra" unexpectedDefinitionPayloadKeyFixture
--   expectFixtureFailureContaining "missing field 'all'" missingOpaqueAllFixture
--   expectFixtureFailureContaining "multiple aliases provided for inductive constructors" duplicateInductiveAliasFixture
--   expectFixtureFailureContaining "unexpected keys in field 'lam' payload: extra" unexpectedLamPayloadKeyFixture

-- testKernelFixtureHarnessLoadsConversionFixtures :: IO ()
-- testKernelFixtureHarnessLoadsConversionFixtures = do
--   parsed <- loadParsedExportFixture conversionSupportFixture
--   let decls = parsedDecls parsed
--       env = kernelEnvFromDecls (kernelBootstrapSupportedDecls decls)
--   assertEq True (hasDefinitionNamed "DefAbbrevPartial" decls) "expected path-based conversion fixture to expose defs needed by future delta tests"
--   assertEq True (hasTheoremNamed "ThmSupport" decls) "expected path-based conversion fixture to expose theorem declarations needed by future checker tests"
--   supportInfo <-
--     case findTheorem "ThmSupport" decls of
--       Just (ThmDecl thmVal) ->
--         expectRight $ evalKernelM env (parsedInternState parsed) (lookupConstInfo (constName (thmConst thmVal)))
--       _ -> failWith "expected theorem support fixture declaration"
--   case supportInfo of
--     Just (ThmInfo _) -> pure ()
--     _ -> failWith "expected fixture-backed checker lookup to see theorem support info"

-- testKernelFixtureHarnessReportsNegativeConversionFixtures :: IO ()
-- testKernelFixtureHarnessReportsNegativeConversionFixtures = do
--   expectFixtureFailureContaining "missing field 'isUnsafe'" missingAxiomIsUnsafeFixture
--   expectFixtureFailureContaining "unexpected keys in field 'def' payload: extra" unexpectedDefinitionPayloadKeyFixture
--   expectFixtureFailureContaining "missing field 'all'" missingOpaqueAllFixture
--   expectFixtureFailureContaining "multiple aliases provided for inductive constructors" duplicateInductiveAliasFixture
--   expectFixtureFailureContaining "unexpected keys in field 'lam' payload: extra" unexpectedLamPayloadKeyFixture

-- testDeclPrettyPrinting :: IO ()
-- testDeclPrettyPrinting = do
--   decls <- expectParseLeanFixture natAddAddAddCommFixture
--   case findTheorem "natAddAddAddCommFixture" decls of
--     Just thmDecl -> do
--       let rendered = toString thmDecl
--       assertEq True ("theorem natAddAddAddCommFixture" `isInfixOf` rendered) "expected theorem pretty printer to include theorem header"
--       assertEq True (":=" `isInfixOf` rendered) "expected theorem pretty printer to include proof assignment"
--     Nothing -> failWith "expected fixture theorem declaration"

-- testInductiveMissingConstructor :: IO ()
-- testInductiveMissingConstructor =
--   expectFixtureFailureContaining "inductive references missing constructors" "inductive-missing-constructor.ndjson"

-- testInductiveWrongConstructorOwner :: IO ()
-- testInductiveWrongConstructorOwner =
--   expectFixtureFailureContaining "constructors belong to unexpected inductive" "inductive-wrong-constructor-owner.ndjson"

-- testMetaMustBeFirst :: IO ()
-- testMetaMustBeFirst =
--   expectFixtureFailureContaining "meta object must be the first record" "meta-must-be-first.ndjson"

-- testDuplicateDeclarations :: IO ()
-- testDuplicateDeclarations =
--   expectFixtureFailureContaining "duplicate declaration" "duplicate-declarations.ndjson"

-- testExtraTopLevelKeys :: IO ()
-- testExtraTopLevelKeys =
--   expectFixtureFailureContaining "unexpected top-level keys" "extra-top-level-keys.ndjson"

-- testInternExprReusesImportedIds :: IO ()
-- testInternExprReusesImportedIds = do
--   let rawLevel = Level (LSucc (Level LZero))
--       rawExpr = Expr (Sort rawLevel)
--   (_, st1) <- expectRight (registerImportedLevel 1 (LSucc (HCLevel 0 LZero)) emptyInternState)
--   (importedExpr, st2) <- expectRight (registerImportedExpr 7 (Sort (HCLevel 1 (LSucc (HCLevel 0 LZero)))) st1)
--   let (internedExpr, _) = runState (internExpr rawExpr) st2
--   assertEq 7 (hceId importedExpr) "expected imported expr id"
--   assertEq 7 (hceId internedExpr) "expected raw interning to reuse imported expr id"
--   assertEq importedExpr internedExpr "expected imported and interned expr to be identical by id"

-- testInternExprDeduplicatesLocalExpressions :: IO ()
-- testInternExprDeduplicatesLocalExpressions = do
--   let rawExpr = Expr (App (Expr (BVar 0)) (Expr (BVar 1)))
--       (expr1, st1) = runState (internExpr rawExpr) emptyInternState
--       (expr2, _) = runState (internExpr rawExpr) st1
--   assertEq (hceId expr1) (hceId expr2) "expected repeated local interning to reuse the same expr id"
--   assertEq expr1 expr2 "expected repeated local interning to produce the same HCExpr"

-- testInternLevelReusesZeroLevel :: IO ()
-- testInternLevelReusesZeroLevel = do
--   let (level1, st1) = runState (internLevel (Level LZero)) emptyInternState
--       (level2, _) = runState (internLevel (Level LZero)) st1
--   assertEq 0 (hclId level1) "expected zero level id"
--   assertEq 0 (hclId level2) "expected zero level id on reuse"
--   assertEq level1 level2 "expected zero level reuse by id"

-- testLevelEquivHandlesCommutativeMax :: IO ()
-- testLevelEquivHandlesCommutativeMax = do
--   let u = rawName ["u"]
--       v = rawName ["v"]
--       lhs = internedLevel $ Level $ LMax (Level (LVar u)) (Level (LVar v))
--       rhs = internedLevel $ Level $ LMax (Level (LVar v)) (Level (LVar u))
--   assertEq True (levelEquiv lhs rhs) "expected max to compare commutatively"

-- testLevelGeqUsesOffsetChecking :: IO ()
-- testLevelGeqUsesOffsetChecking = do
--   let u = rawName ["u"]
--       lhs = internedLevel $ Level $ LSucc (Level (LVar u))
--       rhs = internedLevel $ Level (LVar u)
--   assertEq True (levelGeq lhs rhs) "expected succ(u) >= u by offset"

-- testLevelEquivSimplifiesIMaxSuccCase :: IO ()
-- testLevelEquivSimplifiesIMaxSuccCase = do
--   let u = rawName ["u"]
--       v = rawName ["v"]
--       lhs = internedLevel $ Level $ LIMax (Level (LVar u)) (Level $ LSucc (Level (LVar v)))
--       rhs = internedLevel $ Level $ LMax (Level (LVar u)) (Level $ LSucc (Level (LVar v)))
--   assertEq True (levelEquiv lhs rhs) "expected imax with succ rhs to simplify to max"

-- testLevelEquivHandlesNestedIMax :: IO ()
-- testLevelEquivHandlesNestedIMax = do
--   let u = rawName ["u"]
--       v = rawName ["v"]
--       w = rawName ["w"]
--       lhs = internedLevel $ Level $ LIMax (Level (LVar u)) (Level $ LIMax (Level (LVar v)) (Level (LVar w)))
--       rhs = internedLevel $ Level $ LIMax (Level $ LMax (Level (LVar u)) (Level (LVar v))) (Level (LVar w))
--   assertEq True (levelEquiv lhs rhs) "expected nested imax to reassociate through mkIMax"

-- testDuplicateImportedExprPayloads :: IO ()
-- testDuplicateImportedExprPayloads = do
--   let result = do
--         (_, st1) <- registerImportedLevelIn 1 (LSucc (HCLevel 0 LZero)) emptyInternState
--         (expr1, st2) <- registerImportedExprIn 7 (Sort (HCLevel 1 (LSucc (HCLevel 0 LZero)))) st1
--         registerImportedExprIn 8 (Sort (HCLevel 1 (LSucc (HCLevel 0 LZero)))) st2
--           >>= \(expr2, st3) -> pure (expr1, expr2, st3)
--   (expr1, expr2, st3) <- expectRight result
--   assertEq 7 (hceId expr1) "expected canonical imported expr id"
--   assertEq 7 (hceId expr2) "expected duplicate payload to reuse canonical expr id"
--   assertEq expr1 expr2 "expected duplicate imported expr payload to alias canonical node"
--   case lookupExprId 8 st3 of
--     Just aliased -> assertEq 7 (hceId aliased) "expected duplicate imported expr id lookup to alias canonical node"
--     Nothing -> failWith "expected duplicate imported expr id to be registered"

-- testDuplicateImportedLevelPayloads :: IO ()
-- testDuplicateImportedLevelPayloads = do
--   let result = do
--         (level1, st1) <- registerImportedLevelIn 1 (LSucc (HCLevel 0 LZero)) emptyInternState
--         registerImportedLevelIn 2 (LSucc (HCLevel 0 LZero)) st1
--           >>= \(level2, st2) -> pure (level1, level2, st2)
--   (level1, level2, st2) <- expectRight result
--   assertEq 1 (hclId level1) "expected canonical imported level id"
--   assertEq 1 (hclId level2) "expected duplicate payload to reuse canonical level id"
--   assertEq level1 level2 "expected duplicate imported level payload to alias canonical node"
--   case lookupLevelId 2 st2 of
--     Just aliased -> assertEq 1 (hclId aliased) "expected duplicate imported level id lookup to alias canonical node"
--     Nothing -> failWith "expected duplicate imported level id to be registered"

-- testrunKernelMStartsWithEmptyInternerState :: IO ()
-- testrunKernelMStartsWithEmptyInternerState = do
--   st <- expectRight $ execKernelM IntMap.empty emptyInternState (pure ())
--   case lookupNameId 0 (checkInternState st) of
--     Just anonymous -> assertEq "_" (toString anonymous) "expected anonymous name in empty check state"
--     Nothing -> failWith "expected anonymous name in empty check state"
--   case lookupLevelId 0 (checkInternState st) of
--     Just zero -> assertEq 0 (hclId zero) "expected zero level in empty check state"
--     Nothing -> failWith "expected zero level in empty check state"
--   assertEq Nothing (lookupExprId 0 (checkInternState st)) "expected no pre-seeded expressions"

-- testKernelSharesImportedCanonicalIds :: IO ()
-- testKernelSharesImportedCanonicalIds = do
--   parsed <- expectRight $ parseExportWithState sharedInternerFixtureExport
--   axiomVal <- expectSingleAxiom parsed
--   importedType <-
--     maybe
--       (failWith "expected imported expr id 1 in parsed interner")
--       pure
--       (lookupExprId 1 (parsedInternState parsed))
--   let env = kernelEnvFromDecls (parsedDecls parsed)
--       importedName = constName axiomVal
--   ((reinternedName, reinternedType, lookedUpByImported, lookedUpByReinterned), _) <-
--     expectRight . runKernelM env (parsedInternState parsed) $ do
--       reinternedName <- withIntern $ internName (rawName ["Foo"])
--       reinternedType <- withIntern $ internExpr (Expr (Sort (Level LZero)))
--       lookedUpByImported <- lookupConstInfo importedName
--       lookedUpByReinterned <- lookupConstInfo reinternedName
--       pure (reinternedName, reinternedType, lookedUpByImported, lookedUpByReinterned)
--   assertEq importedName reinternedName "expected checker interning to reuse imported constant name"
--   assertEq importedType reinternedType "expected checker interning to reuse imported expr node"
--   assertEq (Just (AxiomInfo axiomVal)) lookedUpByImported "expected imported canonical name lookup to succeed"
--   assertEq (Just (AxiomInfo axiomVal)) lookedUpByReinterned "expected checker-interned name lookup to hit the imported env entry"

-- testKernelRejectsMismatchedCheckerInterner :: IO ()
-- testKernelRejectsMismatchedCheckerInterner = do
--   parsed <- expectRight $ parseExportWithState sharedInternerFixtureExport
--   disconnectedInterner <- pure $ snd $ runState (internExpr (Expr (Sort (Level LZero)))) emptyInternState
--   let env = kernelEnvFromDecls (parsedDecls parsed)
--       result = runKernelM env disconnectedInterner (pure ())
--   case result of
--     Left err ->
--       assertEq True ("kernel bootstrap interner mismatch: axiom constant name missing canonical name id 1" `isInfixOf` err) "expected deterministic mismatched-interner rejection"
--     Right _ -> failWith "expected kernel startup to reject a disconnected checker interner"

-- testKernelDoesNotDeltaUnfoldTheoremBody :: IO ()
-- testKernelDoesNotDeltaUnfoldTheoremBody = do
--   parsed <- loadParsedExportFixture conversionSupportFixture
--   thm <-
--     case findTheorem "ThmSupport" (parsedDecls parsed) of
--       Just (ThmDecl thmVal) -> pure thmVal
--       _ -> failWith "expected theorem support fixture declaration"
--   abbrevName <-
--     case findDefinition "DefAbbrevPartial" (parsedDecls parsed) of
--       Just (DefnDecl defn) -> pure (constName (defConst defn))
--       _ -> failWith "expected abbrev definition support fixture declaration"
--   let env = kernelEnvFromDecls (kernelBootstrapSupportedDecls (parsedDecls parsed))
--       thmName = constName (thmConst thm)
--   (body, hasBody, unfoldable, hints, stepResult, theoremExpr) <-
--     expectRight . evalKernelM env (parsedInternState parsed) $ do
--       body <- lookupConstBody thmName
--       hasBody <- constHasBody thmName
--       unfoldable <- constIsDeltaUnfoldable thmName
--       hints <- lookupConstReducibilityHints thmName
--       theoremExpr <- mkConst thmName []
--       abbrevExpr <- mkConst abbrevName []
--       stepResult <- lazyDeltaReductionStep neverCompareArgs theoremExpr abbrevExpr
--       pure (body, hasBody, unfoldable, hints, stepResult, theoremExpr)
--   assertEq (Just (thmValue thm)) body "expected theorem body to remain available for checking"
--   assertEq True hasBody "expected theorem declaration to report body availability"
--   assertEq False unfoldable "expected theorem declaration to stay kernel-delta-non-unfoldable"
--   assertEq Nothing hints "expected theorem declaration to expose no delta hints"
--   assertEq LazyDeltaUnfoldRhs (lazyDeltaStepChoice stepResult) "expected lazy delta to prefer unfolding the delta-capable side when compared against a theorem"
--   assertEq theoremExpr (lazyDeltaStepLhs stepResult) "expected theorem side to remain unchanged in one-sided lazy delta"

-- testKernelDoesNotDeltaUnfoldOpaqueBody :: IO ()
-- testKernelDoesNotDeltaUnfoldOpaqueBody = do
--   parsed <- loadParsedExportFixture conversionSupportFixture
--   opaqueVal <-
--     case [decl | OpaqueDecl decl <- parsedDecls parsed, toString (constName (opaqueConst decl)) == "OpaqueSupport"] of
--       [decl] -> pure decl
--       _ -> failWith "expected opaque support fixture declaration"
--   opaqueHintDef <-
--     case findDefinition "DefOpaqueUnsafe" (parsedDecls parsed) of
--       Just (DefnDecl defn) -> pure defn
--       _ -> failWith "expected opaque-hint definition support fixture declaration"
--   let env = kernelEnvFromDecls (kernelBootstrapSupportedDecls (parsedDecls parsed))
--       opaqueName = constName (opaqueConst opaqueVal)
--       opaqueHintName = constName (defConst opaqueHintDef)
--   (body, hasBody, unfoldable, hints, stepResult, opaqueExpr) <-
--     expectRight . evalKernelM env (parsedInternState parsed) $ do
--       body <- lookupConstBody opaqueName
--       hasBody <- constHasBody opaqueName
--       unfoldable <- constIsDeltaUnfoldable opaqueName
--       hints <- lookupConstReducibilityHints opaqueName
--       opaqueExpr <- mkConst opaqueName []
--       opaqueHintLevels <- traverse mkLevelParam (constLevelParameters (defConst opaqueHintDef))
--       opaqueHintExpr <- mkConst opaqueHintName opaqueHintLevels
--       stepResult <- lazyDeltaReductionStep neverCompareArgs opaqueExpr opaqueHintExpr
--       pure (body, hasBody, unfoldable, hints, stepResult, opaqueExpr)
--   assertEq (Just (opaqueValue opaqueVal)) body "expected opaque body to remain available for checking"
--   assertEq True hasBody "expected opaque declaration to report body availability"
--   assertEq False unfoldable "expected opaque declaration to stay kernel-delta-non-unfoldable"
--   assertEq Nothing hints "expected opaque declaration to expose no delta hints"
--   assertEq LazyDeltaUnfoldRhs (lazyDeltaStepChoice stepResult) "expected lazy delta to distinguish opaque declarations from opaque-hint definitions"
--   assertEq opaqueExpr (lazyDeltaStepLhs stepResult) "expected opaque declaration side to remain unchanged in one-sided lazy delta"

-- testKernelRejectsSameHeadNonUnfoldableUniverseMismatches :: IO ()
-- testKernelRejectsSameHeadNonUnfoldableUniverseMismatches = do
--   let (env, internState, lhsExpr, rhsExpr) = sameHeadNonUnfoldableUniverseFixture
--   (result, failedPair, unfoldStack) <-
--     expectRight . evalKernelM env internState $ do
--       result <- isDefEq lhsExpr rhsExpr
--       failedPair <- isFailedExprPair lhsExpr rhsExpr
--       unfoldStack <- getUnfoldStack
--       pure (result, failedPair, unfoldStack)
--   assertEq False result "expected same-head non-unfoldable constants with non-equivalent universes to fail before lazy delta"
--   assertEq True failedPair "expected failed same-head non-unfoldable universe comparison to memoize the pair"
--   assertEq [] unfoldStack "expected failed same-head non-unfoldable universe comparison to avoid any unfolding"

-- testKernelUsesUniverseComparisonBeforeUnnecessaryUnfolding :: IO ()
-- testKernelUsesUniverseComparisonBeforeUnnecessaryUnfolding = do
--   let (env, internState, lhsExpr, rhsExpr) = universeDefEqFixture
--   (result, failedPair, unfoldStack, exactResult, exprClassResult, sortResult) <-
--     expectRight . evalKernelM env internState $ do
--       result <- isDefEq lhsExpr rhsExpr
--       failedPair <- isFailedExprPair lhsExpr rhsExpr
--       unfoldStack <- getUnfoldStack
--       exactResult <- isDefEq lhsExpr lhsExpr
--       lhsClassExpr <- mkBVar 0
--       rhsClassExpr <- mkBVar 1
--       _ <- unionExprClasses lhsClassExpr rhsClassExpr
--       exprClassResult <- isDefEq lhsClassExpr rhsClassExpr
--       quickLevelParam <- internNameM (rawName ["Quick", "u"])
--       quickLevel <- mkLevelParam quickLevelParam
--       equivalentLevel <- mkLevelMax quickLevel quickLevel
--       lhsSort <- mkSort quickLevel
--       rhsSort <- mkSort equivalentLevel
--       sortResult <- isDefEq lhsSort rhsSort
--       pure (result, failedPair, unfoldStack, exactResult, exprClassResult, sortResult)
--   assertEq True result "expected staged defeq to compare same-head constant universes before attempting unnecessary unfolding"
--   assertEq False failedPair "expected successful universe comparison not to memoize a failed pair"
--   assertEq [] unfoldStack "expected successful universe comparison to avoid pushing any unfold-stack entries"
--   assertEq True exactResult "expected exact canonical identity to short-circuit definitional equality"
--   assertEq True exprClassResult "expected proven expr-class equality to short-circuit definitional equality"
--   assertEq True sortResult "expected sort equality to use universe equivalence before unfolding"

-- testKernelDefeqHandlesProjectionAndIotaCases :: IO ()
-- testKernelDefeqHandlesProjectionAndIotaCases = do
--   let (projEnv, projInternState, reducibleProj, shortProj, wrongProj, expectedField) = projectionWhnfFixture
--       (iotaEnv, iotaInternState, reducibleRec, stuckRec, expectedWhnf) = iotaWhnfFixture
--   (reducedProjEq, shortProjEq, wrongProjEq) <-
--     expectRight . evalKernelM projEnv projInternState $ do
--       reducedProjEq <- isDefEq reducibleProj expectedField
--       shortProjEq <- isDefEq shortProj expectedField
--       wrongProjEq <- isDefEq wrongProj expectedField
--       pure (reducedProjEq, shortProjEq, wrongProjEq)
--   (reducedRecEq, stuckRecEq) <-
--     expectRight . evalKernelM iotaEnv iotaInternState $ do
--       reducedRecEq <- isDefEq reducibleRec expectedWhnf
--       stuckRecEq <- isDefEq stuckRec expectedWhnf
--       pure (reducedRecEq, stuckRecEq)
--   assertEq True reducedProjEq "expected staged defeq to use the projection-aware weak-head path on reducible projections"
--   assertEq False shortProjEq "expected staged defeq to leave undersaturated projection spines stuck"
--   assertEq False wrongProjEq "expected staged defeq to reject projections over constructors from another inductive"
--   assertEq True reducedRecEq "expected staged defeq to use the iota-aware weak-head path on reducible recursor applications"
--   assertEq False stuckRecEq "expected staged defeq to leave non-constructor recursor majors stuck"

-- testKernelValidatesSimpleInductiveRecursor :: IO ()
-- testKernelValidatesSimpleInductiveRecursor = do
--   let (indDecl, internState) = simpleInductiveRecursorFixture
--   (env, checkedInternState) <- expectRight $ checkAndAddDecl IntMap.empty internState (InductiveBlockDecl indDecl)
--   lookedUp <-
--     expectRight . evalKernelM env checkedInternState $ do
--       indName <- internNameM (rawName ["Kernel", "Simple"])
--       ctorName <- internNameM (rawName ["Kernel", "Simple", "mk"])
--       recName <- internNameM (rawName ["Kernel", "Simple", "rec"])
--       traverse lookupConstInfo [indName, ctorName, recName]
--   assertEq 3 (length lookedUp) "expected simple validated block to install inductive, constructor, and recursor"
--   assertEq True (all (maybe False (const True)) lookedUp) "expected simple validated recursor metadata to survive grouped admission"

-- testKernelRejectsBadRecursorPayload :: IO ()
-- testKernelRejectsBadRecursorPayload = do
--   let (badDecl, internState) = badRecursorPayloadFixture
--   case checkAndAddDecl IntMap.empty internState (InductiveBlockDecl badDecl) of
--     Left err ->
--       assertEq True ("recursor metadata validation failed" `isInfixOf` err) "expected grouped admission to reject unvalidated recursor metadata"
--     Right _ -> failWith "expected grouped admission to reject bad recursor payload"

-- testKernelDefeqHandlesBinderAlphaEquivalenceAndFailures :: IO ()
-- testKernelDefeqHandlesBinderAlphaEquivalenceAndFailures = do
--   (lamAlphaEq, lamTypeMismatch, forallAlphaEq, forallBodyMismatch) <-
--     expectRight . evalKernelM IntMap.empty emptyInternState $ do
--       zeroLevel <- mkLevelZero
--       succZero <- mkLevelSucc zeroLevel
--       sortZero <- mkSort zeroLevel
--       sortSucc <- mkSort succZero

--       lamBody <- mkBVar 0
--       forallBody <- mkBVar 0
--       forallMismatchBody <- mkLit (NatVal 3)

--       lamAlphaLhs <- mkLam (hcName ["x"]) sortZero lamBody Default
--       lamAlphaRhs <- mkLam (hcName ["y"]) sortZero lamBody Default
--       lamTypeMismatchRhs <- mkLam (hcName ["y"]) sortSucc lamBody Default

--       forallAlphaLhs <- mkForall (hcName ["a"]) sortZero forallBody Default
--       forallAlphaRhs <- mkForall (hcName ["b"]) sortZero forallBody Default
--       forallMismatchRhs <- mkForall (hcName ["b"]) sortZero forallMismatchBody Default

--       lamAlphaEq <- isDefEq lamAlphaLhs lamAlphaRhs
--       lamTypeMismatch <- isDefEq lamAlphaLhs lamTypeMismatchRhs
--       forallAlphaEq <- isDefEq forallAlphaLhs forallAlphaRhs
--       forallBodyMismatch <- isDefEq forallAlphaLhs forallMismatchRhs
--       pure (lamAlphaEq, lamTypeMismatch, forallAlphaEq, forallBodyMismatch)
--   assertEq True lamAlphaEq "expected lambda defeq to ignore binder names and compare opened bodies"
--   assertEq False lamTypeMismatch "expected lambda defeq to reject binder type mismatches before opening bodies"
--   assertEq True forallAlphaEq "expected forall defeq to ignore binder names and compare opened bodies"
--   assertEq False forallBodyMismatch "expected forall defeq to reject opened-body mismatches"

-- testKernelPreventsInfiniteUnfoldingOnRecursiveDefs :: IO ()
-- testKernelPreventsInfiniteUnfoldingOnRecursiveDefs = do
--   let (env, internState, recursiveName, recursiveExpr, stuckExpr) = recursiveLazyDeltaFixture
--   (outerSeen, insideStack, stepResult, stackAfter) <-
--     expectRight . evalKernelM env internState $ do
--       (outerSeen, (insideStack, stepResult)) <-
--         withUnfoldingConst recursiveName $ do
--           insideStack <- isConstOnUnfoldStack recursiveName
--           stepResult <- lazyDeltaReductionStep neverCompareArgs recursiveExpr stuckExpr
--           pure (insideStack, stepResult)
--       stackAfter <- isConstOnUnfoldStack recursiveName
--       pure (outerSeen, insideStack, stepResult, stackAfter)
--   assertEq False outerSeen "expected first unfold-stack entry for a recursive definition to start inactive"
--   assertEq True insideStack "expected recursive definition name to be present while unfolding is in progress"
--   assertEq LazyDeltaNone (lazyDeltaStepChoice stepResult) "expected lazy delta to skip unfolding while the same definition is already on the unfold stack"
--   assertEq recursiveExpr (lazyDeltaStepLhs stepResult) "expected recursion guard to leave the recursive side unchanged"
--   assertEq False stackAfter "expected unfold-stack helper to restore state after recursion guard exits"

-- testKernelTerminatesOnMutualRecursiveConversionFailures :: IO ()
-- testKernelTerminatesOnMutualRecursiveConversionFailures = do
--   let (env, internState, lhsExpr, rhsExpr, stuckExpr) = mutualRecursiveConversionFixture
--   (lhsVsStuck, lhsVsRhs, stuckFailed, mutualFailed, unfoldStack) <-
--     expectRight . evalKernelM env internState $ do
--       lhsVsStuck <- isDefEq lhsExpr stuckExpr
--       lhsVsRhs <- isDefEq lhsExpr rhsExpr
--       stuckFailed <- isFailedExprPair lhsExpr stuckExpr
--       mutualFailed <- isFailedExprPair lhsExpr rhsExpr
--       unfoldStack <- getUnfoldStack
--       pure (lhsVsStuck, lhsVsRhs, stuckFailed, mutualFailed, unfoldStack)
--   assertEq False lhsVsStuck "expected mutually recursive delta unfolding against a stuck term to terminate with failure"
--   assertEq False lhsVsRhs "expected mutually recursive definitions with no productive body to fail conversion instead of looping"
--   assertEq True stuckFailed "expected failed mutual-recursion-versus-stuck comparison to be memoized"
--   assertEq True mutualFailed "expected failed mutual-recursive comparison to be memoized"
--   assertEq [] unfoldStack "expected mutual-recursive conversion attempts to leave the unfold stack restored"

-- testKernelDoesNotConfuseRecursionControlWithExprClasses :: IO ()
-- testKernelDoesNotConfuseRecursionControlWithExprClasses = do
--   ( sameBefore,
--     visitedInside,
--     failedInside,
--     sameAfterUnion,
--     visitedAfterUnion,
--     visitedOutside,
--     failedOutside
--     ) <-
--     expectRight . evalKernelM IntMap.empty emptyInternState $ do
--       lhs <- mkBVar 0
--       rhs <- mkBVar 1
--       sameBefore <- sameExprClass lhs rhs
--       (_, (visitedInside, failedInside, sameAfterUnion, visitedAfterUnion)) <-
--         withVisitedExprPair lhs rhs $ do
--           visitedInside <- isVisitedExprPair lhs rhs
--           recordFailedExprPair lhs rhs
--           failedInside <- isFailedExprPair lhs rhs
--           _ <- unionExprClasses lhs rhs
--           sameAfterUnion <- sameExprClass lhs rhs
--           visitedAfterUnion <- isVisitedExprPair lhs rhs
--           pure (visitedInside, failedInside, sameAfterUnion, visitedAfterUnion)
--       visitedOutside <- isVisitedExprPair lhs rhs
--       failedOutside <- isFailedExprPair lhs rhs
--       pure (sameBefore, visitedInside, failedInside, sameAfterUnion, visitedAfterUnion, visitedOutside, failedOutside)
--   assertEq False sameBefore "expected distinct exprs to start outside the proven-equality union-find"
--   assertEq True visitedInside "expected active recursion tracking to mark the current defeq pair"
--   assertEq True failedInside "expected failure memoization to be independent from active recursion tracking"
--   assertEq True sameAfterUnion "expected union-find equality to change only after explicit class union"
--   assertEq True visitedAfterUnion "expected union-find updates not to erase active recursion tracking"
--   assertEq False visitedOutside "expected active recursion tracking to clear after the wrapper exits"
--   assertEq True failedOutside "expected failure memoization to persist after the active recursion frame ends"

-- testLookupConstInfoReadsKernelEnv :: IO ()
-- testLookupConstInfoReadsKernelEnv = do
--   let constNmVal = hcnVal (hcName ["Const"])
--   (constNm, internState) <- expectRight $ registerImportedName 42 constNmVal emptyInternState
--   let constTy = Sort (HCLevel 0 LZero)
--       constInfo = AxiomInfo ConstantVal {constName = constNm, constLevelParameters = [], constType = constTy}
--       env = IntMap.singleton 42 constInfo
--   actual <- expectRight $ evalKernelM env internState (lookupConstInfo constNm)
--   assertEq (Just constInfo) actual "expected lookupConstInfo to read from KernelEnv"

-- testFindExprClassRootStartsAsSingletonRepresentative :: IO ()
-- testFindExprClassRootStartsAsSingletonRepresentative = do
--   ((expr, root), _) <-
--     expectRight . runKernelM IntMap.empty emptyInternState $ do
--       expr <- mkBVar 0
--       root <- findExprClassRoot expr
--       pure (expr, root)
--   assertEq expr root "expected singleton expr class root to be the expr itself"

-- testSameExprClassStartsFalseForDistinctExprs :: IO ()
-- testSameExprClassStartsFalseForDistinctExprs = do
--   actual <-
--     expectRight . evalKernelM IntMap.empty emptyInternState $ do
--       lhs <- mkBVar 0
--       rhs <- mkBVar 1
--       sameExprClass lhs rhs
--   assertEq False actual "expected distinct exprs to start in different union-find classes"

-- testUnionExprClassesMergesTransitively :: IO ()
-- testUnionExprClassesMergesTransitively = do
--   actual <-
--     expectRight . evalKernelM IntMap.empty emptyInternState $ do
--       a <- mkBVar 0
--       b <- mkBVar 1
--       c <- mkBVar 2
--       _ <- unionExprClasses a b
--       _ <- unionExprClasses b c
--       sameExprClass a c
--   assertEq True actual "expected union-find classes to merge transitively"

-- testUnionExprClassesIsIdempotent :: IO ()
-- testUnionExprClassesIsIdempotent = do
--   ((firstRep, secondRep, same), _) <-
--     expectRight . runKernelM IntMap.empty emptyInternState $ do
--       lhs <- mkBVar 0
--       rhs <- mkBVar 1
--       firstRep <- unionExprClasses lhs rhs
--       secondRep <- unionExprClasses lhs rhs
--       same <- sameExprClass lhs rhs
--       pure (firstRep, secondRep, same)
--   assertEq True same "expected repeated union to preserve equivalence class"
--   assertEq firstRep secondRep "expected repeated union to keep the same representative"

-- testMkSortReusesInternedZeroLevel :: IO ()
-- testMkSortReusesInternedZeroLevel = do
--   ((level1, expr1, level2, expr2), _) <-
--     expectRight . runKernelM IntMap.empty emptyInternState $ do
--       level1 <- mkLevelZero
--       expr1 <- mkSort level1
--       level2 <- mkLevelZero
--       expr2 <- mkSort level2
--       pure (level1, expr1, level2, expr2)
--   assertEq 0 (hclId level1) "expected first zero level id"
--   assertEq 0 (hclId level2) "expected second zero level id"
--   assertEq level1 level2 "expected zero levels to reuse canonical node"
--   assertEq expr1 expr2 "expected repeated sort construction to reuse canonical expr"

-- testMkAppsBuildsLeftAssociatedApps :: IO ()
-- testMkAppsBuildsLeftAssociatedApps = do
--   built <-
--     expectRight . evalKernelM IntMap.empty emptyInternState $ do
--       fn <- mkBVar 0
--       arg1 <- mkBVar 1
--       arg2 <- mkBVar 2
--       mkApps fn [arg1, arg2]
--   expected <-
--     expectRight . evalKernelM IntMap.empty emptyInternState $ do
--       fn <- mkBVar 0
--       arg1 <- mkBVar 1
--       arg2 <- mkBVar 2
--       partial <- mkApp fn arg1
--       mkApp partial arg2
--   assertEq expected built "expected mkApps to associate to the left"

-- testKernelSyntaxHelperViewsPreserveExpressionShape :: IO ()
-- testKernelSyntaxHelperViewsPreserveExpressionShape = do
--   ( appExpr,
--     rebuiltApp,
--     appFn,
--     appArgs,
--     constAppView,
--     projExpr,
--     rebuiltProj,
--     projConstAppView,
--     lamExpr,
--     rebuiltLam,
--     openedLam,
--     expectedOpenedLam,
--     forallExpr,
--     rebuiltForall,
--     openedForall,
--     expectedOpenedForall,
--     letExpr,
--     rebuiltLet,
--     openedLet,
--     expectedOpenedLet
--     ) <-
--     expectRight . evalKernelM IntMap.empty emptyInternState $ do
--       zeroLevel <- mkLevelZero
--       ty <- mkSort zeroLevel
--       lit3 <- mkLit (NatVal 3)
--       lit4 <- mkLit (NatVal 4)
--       arg0 <- mkBVar 0
--       arg1 <- mkBVar 1
--       let ctorName = hcName ["MkStruct"]
--           structName = hcName ["Struct"]
--           xName = hcName ["x"]
--           yName = hcName ["y"]
--           zName = hcName ["z"]
--       ctorExpr <- mkConst ctorName [zeroLevel]
--       appExpr <- mkApps ctorExpr [arg1, lit3]
--       let appSpine = getAppSpine appExpr
--       rebuiltApp <- mkAppSpine appSpine
--       constAppView <-
--         maybe
--           (throwError "expected const-head app view")
--           pure
--           (viewConstApp appExpr)
--       projExpr <- mkProj structName 1 appExpr
--       projView <-
--         maybe
--           (throwError "expected raw projection view")
--           pure
--           (viewProj projExpr)
--       rebuiltProj <- mkProjFromView projView
--       projConstAppView <-
--         maybe
--           (throwError "expected projection-over-const-app view")
--           pure
--           (viewProjStructConstApp 2 projExpr)

--       lamBody <- mkApp arg1 arg0
--       innerLam <- mkLam yName ty lamBody Default
--       lamExpr <- mkLam xName ty innerLam Default
--       let (lamBinders, lamTail) = getLams lamExpr
--       rebuiltLam <- mkLams lamBinders lamTail
--       openedLam <-
--         case lamBinders of
--           outerBinder : _ ->
--             withLocalDecl (rawName ["openedX"]) ty Default $ \decl -> do
--               xExpr <- localDeclExpr decl
--               openBinderView outerBinder xExpr
--           [] -> throwError "expected lambda binders"
--       expectedOpenedLam <-
--         withLocalDecl (rawName ["openedX"]) ty Default $ \decl -> do
--           xExpr <- localDeclExpr decl
--           innerBody <- mkBVar 0
--           body <- mkApp xExpr innerBody
--           mkLam yName ty body Default

--       forallBody <- mkApp arg1 arg0
--       innerForall <- mkForall yName ty forallBody Implicit
--       forallExpr <- mkForall xName ty innerForall Default
--       let (forallBinders, forallTail) = getForalls forallExpr
--       rebuiltForall <- mkForalls forallBinders forallTail
--       openedForall <-
--         case forallBinders of
--           outerBinder : _ ->
--             withLocalDecl (rawName ["openedA"]) ty Default $ \decl -> do
--               xExpr <- localDeclExpr decl
--               openBinderView outerBinder xExpr
--           [] -> throwError "expected forall binders"
--       expectedOpenedForall <-
--         withLocalDecl (rawName ["openedA"]) ty Default $ \decl -> do
--           xExpr <- localDeclExpr decl
--           innerBody <- mkBVar 0
--           body <- mkApp xExpr innerBody
--           mkForall yName ty body Implicit

--       letBody <- mkApp arg0 arg0
--       letExpr <- mkLet zName ty lit4 letBody
--       letView <-
--         maybe
--           (throwError "expected let view")
--           pure
--           (viewLet letExpr)
--       rebuiltLet <- mkLetFromView letView
--       openedLet <- openLetView letView
--       expectedOpenedLet <- mkApp lit4 lit4

--       pure
--         ( appExpr,
--           rebuiltApp,
--           appSpineFn appSpine,
--           appSpineArgs appSpine,
--           constAppView,
--           projExpr,
--           rebuiltProj,
--           projConstAppView,
--           lamExpr,
--           rebuiltLam,
--           openedLam,
--           expectedOpenedLam,
--           forallExpr,
--           rebuiltForall,
--           openedForall,
--           expectedOpenedForall,
--           letExpr,
--           rebuiltLet,
--           openedLet,
--           expectedOpenedLet
--         )
--   assertExprStructEq appExpr rebuiltApp "expected app spine rebuild to preserve expression shape"
--   assertExprStructEq appFn (getAppFn appExpr) "expected app spine head view to preserve the original function"
--   assertEq "MkStruct" (toString (constAppName constAppView)) "expected const-head app view to expose the constant name"
--   assertEq (length appArgs) 2 "expected app spine to expose both arguments"
--   assertEq appArgs (constAppArgs constAppView) "expected app spine args to match const-head app args"
--   assertExprStructEq projExpr rebuiltProj "expected projection view rebuild to preserve expression shape"
--   assertEq "Struct" (toString (projStructTypeName projConstAppView)) "expected projection view to preserve structure type name"
--   assertEq 1 (projStructIndex projConstAppView) "expected projection view to preserve projection index"
--   assertEq "MkStruct" (toString (projStructConstName projConstAppView)) "expected strict projection view to expose constant head"
--   assertEq 2 (length (projStructArgs projConstAppView)) "expected strict projection view to expose the full struct spine"
--   assertExprStructEq lamExpr rebuiltLam "expected lambda telescope view rebuild to preserve expression shape"
--   assertExprStructEq openedLam expectedOpenedLam "expected lambda binder opening to instantiate the outer binder only"
--   assertExprStructEq forallExpr rebuiltForall "expected forall telescope view rebuild to preserve expression shape"
--   assertExprStructEq openedForall expectedOpenedForall "expected forall binder opening to instantiate the outer binder only"
--   assertExprStructEq letExpr rebuiltLet "expected let view rebuild to preserve expression shape"
--   assertExprStructEq openedLet expectedOpenedLet "expected let opening to substitute the let value into the body"

-- testKernelProjectionViewRejectsMalformedSpine :: IO ()
-- testKernelProjectionViewRejectsMalformedSpine = do
--   (nonConstProjView, shortProjView, extraAppProjView, nonAppConstView, goodProjView) <-
--     expectRight . evalKernelM IntMap.empty emptyInternState $ do
--       zeroLevel <- mkLevelZero
--       lit0 <- mkLit (NatVal 0)
--       lit1 <- mkLit (NatVal 1)
--       let ctorName = hcName ["MkStruct"]
--           structName = hcName ["Struct"]
--       ctorExpr <- mkConst ctorName [zeroLevel]
--       nonConstStruct <- mkApp lit0 lit1
--       shortStruct <- mkApps ctorExpr [lit0]
--       goodStruct <- mkApps ctorExpr [lit0, lit1]
--       nonConstProj <- mkProj structName 0 nonConstStruct
--       shortProj <- mkProj structName 0 shortStruct
--       goodProj <- mkProj structName 0 goodStruct
--       extraApp <- mkApp goodProj lit0
--       pure
--         ( viewProjStructConstApp 2 nonConstProj,
--           viewProjStructConstApp 2 shortProj,
--           viewProjStructConstApp 2 extraApp,
--           viewConstApp lit0,
--           viewProjStructConstApp 2 goodProj
--         )
--   assertEq Nothing nonConstProjView "expected strict projection view to reject non-const struct heads"
--   assertEq Nothing shortProjView "expected strict projection view to reject undersaturated struct spines"
--   assertEq Nothing extraAppProjView "expected strict projection view to reject extra applications around a projection"
--   assertEq Nothing nonAppConstView "expected const-head app view to reject non-application non-const shapes"
--   assertEq True (maybe False (const (True :: Bool)) goodProjView) "expected well-formed projection spine to be recognized"

-- testInstantiateLevelParamsRewritesSortAndConstLevels :: IO ()
-- testInstantiateLevelParamsRewritesSortAndConstLevels = do
--   actual <-
--     expectRight . evalKernelM IntMap.empty emptyInternState $ do
--       let (u, v, c) = hcNames3 ["u"] ["v"] ["C"]
--       uLevel <- mkLevelParam u
--       vLevel <- mkLevelParam v
--       zeroLevel <- mkLevelZero
--       succZero <- mkLevelSucc zeroLevel
--       constExpr <- mkConst c [uLevel, vLevel]
--       instantiateLevelParams [(u, zeroLevel), (v, succZero)] constExpr
--   expected <-
--     expectRight . evalKernelM IntMap.empty emptyInternState $ do
--       let c = hcName ["C"]
--       zeroLevel <- mkLevelZero
--       succZero <- mkLevelSucc zeroLevel
--       mkConst c [zeroLevel, succZero]
--   assertExprStructEq expected actual "expected universe instantiation to rewrite const level arguments"

-- testInstantiateLevelParamsTraversesForallAndLetPayloads :: IO ()
-- testInstantiateLevelParamsTraversesForallAndLetPayloads = do
--   actual <-
--     expectRight . evalKernelM IntMap.empty emptyInternState $ do
--       let (u, c, x, y) = hcNames4 ["u"] ["C"] ["x"] ["y"]
--       uLevel <- mkLevelParam u
--       zeroLevel <- mkLevelZero
--       sortU <- mkSort uLevel
--       constU <- mkConst c [uLevel]
--       letExpr <- mkLet y sortU constU constU False
--       forallExpr <- mkForall x sortU letExpr Default
--       instantiateLevelParams [(u, zeroLevel)] forallExpr
--   expected <-
--     expectRight . evalKernelM IntMap.empty emptyInternState $ do
--       let c = hcName ["C"]
--           x = hcName ["x"]
--           y = hcName ["y"]
--       zeroLevel <- mkLevelZero
--       sortZero <- mkSort zeroLevel
--       constZero <- mkConst c [zeroLevel]
--       letExpr <- mkLet y sortZero constZero constZero False
--       mkForall x sortZero letExpr Default
--   assertExprStructEq expected actual "expected universe instantiation to traverse forall and let payloads"

-- testInstantiateLevelParamsLeavesUnchangedExprIdentical :: IO ()
-- testInstantiateLevelParamsLeavesUnchangedExprIdentical = do
--   ((originalExpr, actualExpr), _) <-
--     expectRight . runKernelM IntMap.empty emptyInternState $ do
--       let (u, v, c) = hcNames3 ["u"] ["v"] ["C"]
--       uLevel <- mkLevelParam u
--       originalExpr <- mkConst c [uLevel]
--       actualExpr <- instantiateLevelParams [(v, uLevel)] originalExpr
--       pure (originalExpr, actualExpr)
--   assertEq originalExpr actualExpr "expected unused universe instantiation to preserve the original expr node"

-- testInstantiate1ReplacesOutermostBinder :: IO ()
-- testInstantiate1ReplacesOutermostBinder = do
--   actual <-
--     expectRight . evalKernelM IntMap.empty emptyInternState $ do
--       fn <- mkBVar 1
--       arg0 <- mkBVar 0
--       body <- mkApp fn arg0
--       arg <- mkLit (NatVal 7)
--       instantiate1 arg body
--   expected <-
--     expectRight . evalKernelM IntMap.empty emptyInternState $ do
--       arg <- mkLit (NatVal 7)
--       fn <- mkBVar 0
--       mkApp fn arg
--   assertExprStructEq expected actual "expected instantiate1 to substitute bvar 0 and decrement outer binders"

-- testInstantiate1PreservesInnerBinders :: IO ()
-- testInstantiate1PreservesInnerBinders = do
--   actual <-
--     expectRight . evalKernelM IntMap.empty emptyInternState $ do
--       ty <- mkSort =<< mkLevelZero
--       fn <- mkBVar 1
--       arg0 <- mkBVar 0
--       body <- mkApp fn arg0
--       lam <- mkLam (hcName ["y"]) ty body Default
--       arg <- mkLit (NatVal 9)
--       instantiate1 arg lam
--   expected <-
--     expectRight . evalKernelM IntMap.empty emptyInternState $ do
--       ty <- mkSort =<< mkLevelZero
--       arg <- mkLit (NatVal 9)
--       inner <- mkBVar 0
--       body <- mkApp arg inner
--       mkLam (hcName ["y"]) ty body Default
--   assertExprStructEq expected actual "expected instantiate1 to leave inner binder 0 alone under lambdas"

-- testKernelWhnfReducesBetaAndZeta :: IO ()
-- testKernelWhnfReducesBetaAndZeta = do
--   (betaActual, betaExpected, zetaActual, zetaExpected) <-
--     expectRight . evalKernelM IntMap.empty emptyInternState $ do
--       zeroLevel <- mkLevelZero
--       ty <- mkSort zeroLevel
--       lit7 <- mkLit (NatVal 7)
--       lit9 <- mkLit (NatVal 9)
--       outerVar <- mkBVar 1
--       innerVar <- mkBVar 0
--       betaBody <- mkApp outerVar innerVar
--       innerLam <- mkLam (hcName ["y"]) ty betaBody Default
--       outerLam <- mkLam (hcName ["x"]) ty innerLam Default
--       betaActual <- whnf =<< mkApp outerLam lit7
--       betaExpected <- do
--         bodyVar <- mkBVar 0
--         body <- mkApp lit7 bodyVar
--         mkLam (hcName ["y"]) ty body Default
--       zetaVar <- mkBVar 0
--       zetaBody <- mkApp zetaVar lit9
--       zetaActual <- whnf =<< mkLet (hcName ["z"]) ty lit7 zetaBody False
--       zetaExpected <- mkApp lit7 lit9
--       pure (betaActual, betaExpected, zetaActual, zetaExpected)
--   assertExprStructEq betaExpected betaActual "expected whnf to beta-reduce an app headed by a lambda"
--   assertExprStructEq zetaExpected zetaActual "expected whnf to zeta-reduce let expressions at the head"

-- testKernelWhnfHandlesStuckAndReducibleProjectionCases :: IO ()
-- testKernelWhnfHandlesStuckAndReducibleProjectionCases = do
--   let (env, internState, reducibleProj, shortProj, wrongProj, expectedField) = projectionWhnfFixture
--   (reducedProj, shortProjWhnf, wrongProjWhnf) <-
--     expectRight . evalKernelM env internState $ do
--       reducedProj <- whnf reducibleProj
--       shortProjWhnf <- whnf shortProj
--       wrongProjWhnf <- whnf wrongProj
--       pure (reducedProj, shortProjWhnf, wrongProjWhnf)
--   assertExprStructEq expectedField reducedProj "expected whnf to reduce projections over sufficiently applied constructors"
--   assertExprStructEq shortProj shortProjWhnf "expected undersaturated constructor projections to stay stuck"
--   assertExprStructEq wrongProj wrongProjWhnf "expected projections over constructors from another inductive to stay stuck"

-- testKernelWhnfExposesIotaRedexesWithoutFullNormalization :: IO ()
-- testKernelWhnfExposesIotaRedexesWithoutFullNormalization = do
--   let (env, internState, reducibleRec, stuckRec, expectedWhnf) = iotaWhnfFixture
--   (reducedRec, stuckRecWhnf) <-
--     expectRight . evalKernelM env internState $ do
--       reducedRec <- whnf reducibleRec
--       stuckRecWhnf <- whnf stuckRec
--       pure (reducedRec, stuckRecWhnf)
--   assertExprStructEq expectedWhnf reducedRec "expected whnf to expose recursor iota redexes without normalizing constructor arguments"
--   assertExprStructEq stuckRec stuckRecWhnf "expected recursors with non-constructor majors to remain stuck"

-- projectionWhnfFixture :: (KernelEnv, InternState, HCExpr, HCExpr, HCExpr, HCExpr)
-- projectionWhnfFixture =
--   let ((structName, structCtorName, otherName, otherCtorName, sortExpr, reducibleProj, shortProj, wrongProj, expectedField), internState) = runState build emptyInternState
--       constType = hceVal sortExpr
--       structCtor =
--         ConstructorVal
--           { ctorConst = ConstantVal {constName = structCtorName, constLevelParameters = [], constType = constType},
--             ctorInductive = structName,
--             ctorIndex = 0,
--             ctorParamsN = 1,
--             ctorFieldsN = 2
--           }
--       otherCtor =
--         ConstructorVal
--           { ctorConst = ConstantVal {constName = otherCtorName, constLevelParameters = [], constType = constType},
--             ctorInductive = otherName,
--             ctorIndex = 0,
--             ctorParamsN = 0,
--             ctorFieldsN = 1
--           }
--       structInd =
--         InductiveVal
--           { indConst = ConstantVal {constName = structName, constLevelParameters = [], constType = constType},
--             indParamsN = 1,
--             indIndicesN = 0,
--             indCtors = [structCtorName]
--           }
--       otherInd =
--         InductiveVal
--           { indConst = ConstantVal {constName = otherName, constLevelParameters = [], constType = constType},
--             indParamsN = 0,
--             indIndicesN = 0,
--             indCtors = [otherCtorName]
--           }
--       env =
--         IntMap.fromList
--           [ (hcnId structName, InductInfo structInd),
--             (hcnId structCtorName, CtorInfo structCtor),
--             (hcnId otherName, InductInfo otherInd),
--             (hcnId otherCtorName, CtorInfo otherCtor)
--           ]
--    in (env, internState, reducibleProj, shortProj, wrongProj, expectedField)
--   where
--     build = do
--       structName <- internName (rawName ["Struct"])
--       structCtorName <- internName (rawName ["Struct", "mk"])
--       otherName <- internName (rawName ["Other"])
--       otherCtorName <- internName (rawName ["Other", "mk"])
--       sortExpr <- internExpr rawSortZeroExpr
--       reducibleProj <- internExpr $ rawProjExpr ["Struct"] 1 (rawAppsExpr (rawConstExpr ["Struct", "mk"]) [rawNatExpr 5, rawNatExpr 7, rawNatExpr 9])
--       shortProj <- internExpr $ rawProjExpr ["Struct"] 1 (rawAppsExpr (rawConstExpr ["Struct", "mk"]) [rawNatExpr 5, rawNatExpr 7])
--       wrongProj <- internExpr $ rawProjExpr ["Struct"] 0 (rawAppsExpr (rawConstExpr ["Other", "mk"]) [rawNatExpr 7])
--       expectedField <- internExpr $ rawNatExpr 9
--       pure (structName, structCtorName, otherName, otherCtorName, sortExpr, reducibleProj, shortProj, wrongProj, expectedField)

-- iotaWhnfFixture :: (KernelEnv, InternState, HCExpr, HCExpr, HCExpr)
-- iotaWhnfFixture =
--   let ((boxName, boxCtorName, boxRecName, sortExpr, reducibleRec, stuckRec, expectedWhnf, ruleRhs), internState) = runState build emptyInternState
--       constType = hceVal sortExpr
--       boxCtor =
--         ConstructorVal
--           { ctorConst = ConstantVal {constName = boxCtorName, constLevelParameters = [], constType = constType},
--             ctorInductive = boxName,
--             ctorIndex = 0,
--             ctorParamsN = 0,
--             ctorFieldsN = 1
--           }
--       recRule = RecursorRule {recCtor = boxCtorName, recFieldsN = 1, recRhs = hceVal ruleRhs}
--       boxInd =
--         InductiveVal
--           { indConst = ConstantVal {constName = boxName, constLevelParameters = [], constType = constType},
--             indParamsN = 0,
--             indIndicesN = 0,
--             indCtors = [boxCtorName]
--           }
--       boxRec =
--         RecursorVal
--           { recConst = ConstantVal {constName = boxRecName, constLevelParameters = [], constType = constType},
--             recParamsN = 0,
--             recIndicesN = 0,
--             recMotivesN = 1,
--             recMinorsN = 1,
--             recKRule = False,
--             recRules = [recRule]
--           }
--       env =
--         IntMap.fromList
--           [ (hcnId boxName, InductInfo boxInd),
--             (hcnId boxCtorName, CtorInfo boxCtor),
--             (hcnId boxRecName, RecInfo boxRec)
--           ]
--    in (env, internState, reducibleRec, stuckRec, expectedWhnf)
--   where
--     build = do
--       boxName <- internName (rawName ["Box"])
--       boxCtorName <- internName (rawName ["Box", "mk"])
--       boxRecName <- internName (rawName ["Box", "rec"])
--       sortExpr <- internExpr rawSortZeroExpr
--       reducibleRec <- internExpr $ rawAppsExpr (rawConstExpr ["Box", "rec"]) [rawNatExpr 0, rawNatExpr 1, rawAppsExpr (rawConstExpr ["Box", "mk"]) [rawNatExpr 7]]
--       stuckRec <- internExpr $ rawAppsExpr (rawConstExpr ["Box", "rec"]) [rawNatExpr 0, rawNatExpr 1, rawNatExpr 9]
--       expectedWhnf <-
--         internExpr $ rawAppsExpr (rawConstExpr ["Wrap", "mk"]) [rawAppExpr (rawLamExpr ["z"] rawSortZeroExpr (rawBVarExpr 0) Default) (rawNatExpr 7)]
--       ruleRhs <-
--         internExpr $ rawLamExpr ["motive"] rawSortZeroExpr (rawLamExpr ["minor"] rawSortZeroExpr (rawLamExpr ["field"] rawSortZeroExpr wrappedField Default) Default) Default
--       pure (boxName, boxCtorName, boxRecName, sortExpr, reducibleRec, stuckRec, expectedWhnf, ruleRhs)
--     wrappedField = rawAppsExpr (rawConstExpr ["Wrap", "mk"]) [rawAppExpr (rawLamExpr ["z"] rawSortZeroExpr (rawBVarExpr 0) Default) (rawBVarExpr 0)]

-- sameHeadNonUnfoldableUniverseFixture :: (KernelEnv, InternState, HCExpr, HCExpr)
-- sameHeadNonUnfoldableUniverseFixture =
--   let ((constName', levelParam, sortExpr, lhsExpr, rhsExpr), internState) = runState build emptyInternState
--       env = kernelEnvFromInfos [AxiomInfo ConstantVal {constName = constName', constLevelParameters = [levelParam], constType = hceVal sortExpr}]
--    in (env, internState, lhsExpr, rhsExpr)
--   where
--     build = do
--       constName' <- internName (rawName ["Kernel", "nonUnfoldableUniverseMismatch"])
--       levelParam <- internName (rawName ["u"])
--       sortExpr <- internExpr rawSortZeroExpr
--       levelArg <- internLevelVal (LVar levelParam)
--       succLevelArg <- internLevelVal (LSucc levelArg)
--       lhsExpr <- internExprVal (Const constName' [levelArg])
--       rhsExpr <- internExprVal (Const constName' [succLevelArg])
--       pure (constName', levelParam, sortExpr, lhsExpr, rhsExpr)

-- universeDefEqFixture :: (KernelEnv, InternState, HCExpr, HCExpr)
-- universeDefEqFixture =
--   let ((sameName, levelParam, sortExpr, lhsExpr, rhsExpr, body), internState) = runState build emptyInternState
--       env = kernelEnvFromInfos [mkDefinitionInfo sortExpr sameName [levelParam] (Regular 4) body]
--    in (env, internState, lhsExpr, rhsExpr)
--   where
--     build = do
--       sameName <- internName (rawName ["LazyDelta", "universeEq"])
--       levelParam <- internName (rawName ["u"])
--       sortExpr <- internExpr rawSortZeroExpr
--       levelArg <- internLevelVal (LVar levelParam)
--       equivalentLevelArg <- internLevelVal (LMax levelArg levelArg)
--       lhsExpr <- internExprVal (Const sameName [levelArg])
--       rhsExpr <- internExprVal (Const sameName [equivalentLevelArg])
--       body <- internExprVal (Const sameName [levelArg])
--       pure (sameName, levelParam, sortExpr, lhsExpr, rhsExpr, body)

-- recursiveLazyDeltaFixture :: (KernelEnv, InternState, HCName, HCExpr, HCExpr)
-- recursiveLazyDeltaFixture =
--   let ((recursiveName, sortExpr, recursiveExpr, stuckExpr, recursiveBody), internState) = runState build emptyInternState
--       env = kernelEnvFromInfos [mkDefinitionInfo sortExpr recursiveName [] Abbrev recursiveBody]
--    in (env, internState, recursiveName, recursiveExpr, stuckExpr)
--   where
--     build = do
--       recursiveName <- internName (rawName ["LazyDelta", "recursive"])
--       sortExpr <- internExpr rawSortZeroExpr
--       recursiveExpr <- internExpr (rawConstExpr ["LazyDelta", "recursive"])
--       stuckExpr <- internExpr (rawNatExpr 0)
--       recursiveBody <- internExpr (rawConstExpr ["LazyDelta", "recursive"])
--       pure (recursiveName, sortExpr, recursiveExpr, stuckExpr, recursiveBody)

-- mutualRecursiveConversionFixture :: (KernelEnv, InternState, HCExpr, HCExpr, HCExpr)
-- mutualRecursiveConversionFixture =
--   let ((lhsName, rhsName, sortExpr, lhsExpr, rhsExpr, stuckExpr), internState) = runState build emptyInternState
--       env =
--         kernelEnvFromInfos
--           [ mkDefinitionInfo sortExpr lhsName [] Abbrev rhsExpr,
--             mkDefinitionInfo sortExpr rhsName [] Abbrev lhsExpr
--           ]
--    in (env, internState, lhsExpr, rhsExpr, stuckExpr)
--   where
--     build = do
--       lhsName <- internName (rawName ["LazyDelta", "mutualLeft"])
--       rhsName <- internName (rawName ["LazyDelta", "mutualRight"])
--       sortExpr <- internExpr rawSortZeroExpr
--       lhsExpr <- internExpr (rawConstExpr ["LazyDelta", "mutualLeft"])
--       rhsExpr <- internExpr (rawConstExpr ["LazyDelta", "mutualRight"])
--       stuckExpr <- internExpr (rawNatExpr 0)
--       pure (lhsName, rhsName, sortExpr, lhsExpr, rhsExpr, stuckExpr)

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

-- sharedInternerFixtureExport :: ByteString
-- sharedInternerFixtureExport =
--   BSC.unlines
--     [ "{\"meta\":{}}",
--       "{\"in\":1,\"str\":{\"pre\":0,\"str\":\"Foo\"}}",
--       "{\"ie\":1,\"sort\":0}",
--       "{\"axiom\":{\"name\":1,\"levelParams\":[],\"type\":1,\"isUnsafe\":false}}"
--     ]

-- expectSingleAxiom :: ParsedExport -> IO (AxiomVal HCExpr HCLevel)
-- expectSingleAxiom parsed =
--   case parsedDecls parsed of
--     [AxiomDecl axiomVal] -> pure axiomVal
--     other -> failWith ("expected exactly one parsed axiom, got: " <> show other)

-- kernelEnvFromDecls :: [Decl HCExpr HCLevel] -> KernelEnv
-- kernelEnvFromDecls = foldr insertDecl IntMap.empty
--   where
--     insertDecl decl env =
--       case decl of
--         AxiomDecl ax -> IntMap.insert (hcnId (constName ax)) (AxiomInfo ax) env
--         DefnDecl defn -> IntMap.insert (hcnId (constName (defConst defn))) (DefnInfo defn) env
--         ThmDecl thm -> IntMap.insert (hcnId (constName (thmConst thm))) (ThmInfo thm) env
--         OpaqueDecl opaqueVal -> IntMap.insert (hcnId (constName (opaqueConst opaqueVal))) (OpaqueInfo opaqueVal) env
--         QuotDecl quotVal -> IntMap.insert (hcnId (constName (quotConst quotVal))) (QuotInfo quotVal) env
--         CtorDecl ctor -> IntMap.insert (hcnId (constName (ctorConst ctor))) (CtorInfo ctor) env
--         RecDecl recVal -> IntMap.insert (hcnId (constName (recConst recVal))) (RecInfo recVal) env
--         InductiveBlockDecl indDecl ->
--           foldr
--             (uncurry IntMap.insert)
--             env
--             ( [(hcnId (constName (indConst indVal)), InductInfo indVal) | indVal <- indTypes indDecl]
--                 <> [(hcnId (constName (ctorConst ctor)), CtorInfo ctor) | ctor <- indConstructors indDecl]
--                 <> [(hcnId (constName (recConst recVal)), RecInfo recVal) | recVal <- indRecursors indDecl]
--             )

-- kernelBootstrapSupportedDecls :: [Decl HCExpr HCLevel] -> [Decl HCExpr HCLevel]
-- kernelBootstrapSupportedDecls = filter isSupported
--   where
--     isSupported (CtorDecl _) = False
--     isSupported (RecDecl _) = False
--     isSupported _ = True

-- data LeanFixture = LeanFixture
--   { fixtureModuleName :: String,
--     fixtureDeclNames :: [String]
--   }

-- natAddSuccFixture :: LeanFixture
-- natAddSuccFixture =
--   LeanFixture
--     { fixtureModuleName = "NatAddSuccFixture",
--       fixtureDeclNames = ["natAddSuccFixture", "natRecZeroFixture"]
--     }

-- natAddAddAddCommFixture :: LeanFixture
-- natAddAddAddCommFixture =
--   LeanFixture
--     { fixtureModuleName = "NatAddAddAddCommFixture",
--       fixtureDeclNames = ["natAddAddAddCommFixture"]
--     }

-- bodyTypeMismatchDecl :: (Decl HCExpr HCLevel, InternState)
-- bodyTypeMismatchDecl =
--   let ((badName, sortZero), internState) = runState build emptyInternState
--       badDecl =
--         DefnDecl
--           DefinitionVal
--             { defConst = ConstantVal {constName = badName, constLevelParameters = [], constType = hceVal sortZero},
--               defHints = Abbrev,
--               defValue = hceVal sortZero
--             }
--    in (badDecl, internState)
--   where
--     build = do
--       badName <- internName (rawName ["Kernel", "bodyTypeMismatch"])
--       sortZero <- internExpr rawSortZeroExpr
--       pure (badName, sortZero)

-- nonAtomicGroupedInsertionFixture :: ([Decl HCExpr HCLevel], InternState)
-- nonAtomicGroupedInsertionFixture =
--   let ((badIndName, badCtorName, missingName, badCtorType, badIndType, leakedAxiomType), internState) = runState build emptyInternState
--       badBlockDecl =
--         InductiveBlockDecl
--           InductiveDecl
--             { indTypes =
--                 [ InductiveVal
--                     { indConst = ConstantVal {constName = badIndName, constLevelParameters = [], constType = hceVal badIndType},
--                       indParamsN = 0,
--                       indIndicesN = 0,
--                       indCtors = [badCtorName]
--                     }
--                 ],
--               indConstructors =
--                 [ ConstructorVal
--                     { ctorConst = ConstantVal {constName = badCtorName, constLevelParameters = [], constType = hceVal badCtorType},
--                       ctorInductive = badIndName,
--                       ctorIndex = 0,
--                       ctorParamsN = 0,
--                       ctorFieldsN = 0
--                     }
--                 ],
--               indRecursors = []
--             }
--       leakedAxiomDecl =
--         AxiomDecl
--           ConstantVal
--             { constName = missingName,
--               constLevelParameters = [],
--               constType = hceVal leakedAxiomType
--             }
--    in ([badBlockDecl, leakedAxiomDecl], internState)
--   where
--     build = do
--       badIndName <- internName (rawName ["Kernel", "AtomicBad"])
--       badCtorName <- internName (rawName ["Kernel", "AtomicBad", "mk"])
--       missingName <- internName (rawName ["Kernel", "AtomicBad", "leaked"])
--       sortZero <- internExpr rawSortZeroExpr
--       badIndType <- pure sortZero
--       badCtorType <- internExpr (rawConstExpr ["Kernel", "AtomicBad", "Missing"])
--       leakedAxiomType <- internExpr (rawConstExpr ["Kernel", "AtomicBad"])
--       pure (badIndName, badCtorName, missingName, badCtorType, badIndType, leakedAxiomType)

-- simpleInductiveRecursorFixture :: (InductiveDecl HCExpr HCLevel, InternState)
-- simpleInductiveRecursorFixture =
--   let ((indName, ctorName, recName, sortZero, ruleRhs), internState) = runState build emptyInternState
--       indDecl =
--         InductiveDecl
--           { indTypes =
--               [ InductiveVal
--                   { indConst = ConstantVal {constName = indName, constLevelParameters = [], constType = hceVal sortZero},
--                     indParamsN = 0,
--                     indIndicesN = 0,
--                     indCtors = [ctorName]
--                   }
--               ],
--             indConstructors =
--               [ ConstructorVal
--                   { ctorConst = ConstantVal {constName = ctorName, constLevelParameters = [], constType = hceVal sortZero},
--                     ctorInductive = indName,
--                     ctorIndex = 0,
--                     ctorParamsN = 0,
--                     ctorFieldsN = 1
--                   }
--               ],
--             indRecursors =
--               [ RecursorVal
--                   { recConst = ConstantVal {constName = recName, constLevelParameters = [], constType = hceVal sortZero},
--                     recParamsN = 0,
--                     recIndicesN = 0,
--                     recMotivesN = 1,
--                     recMinorsN = 1,
--                     recKRule = False,
--                     recRules = [RecursorRule {recCtor = ctorName, recFieldsN = 1, recRhs = hceVal ruleRhs}]
--                   }
--               ]
--           }
--    in (indDecl, internState)
--   where
--     build = do
--       indName <- internName (rawName ["Kernel", "Simple"])
--       ctorName <- internName (rawName ["Kernel", "Simple", "mk"])
--       recName <- internName (rawName ["Kernel", "Simple", "rec"])
--       sortZero <- internExpr rawSortZeroExpr
--       ruleRhs <- internExpr $ rawLamExpr ["motive"] rawSortZeroExpr (rawLamExpr ["minor"] rawSortZeroExpr (rawLamExpr ["field"] rawSortZeroExpr (rawBVarExpr 0) Default) Default) Default
--       pure (indName, ctorName, recName, sortZero, ruleRhs)

-- badRecursorPayloadFixture :: (InductiveDecl HCExpr HCLevel, InternState)
-- badRecursorPayloadFixture =
--   let ((indName, ctorName, recName, sortZero, ruleRhs), internState) = runState build emptyInternState
--       badDecl =
--         InductiveDecl
--           { indTypes =
--               [ InductiveVal
--                   { indConst = ConstantVal {constName = indName, constLevelParameters = [], constType = hceVal sortZero},
--                     indParamsN = 0,
--                     indIndicesN = 0,
--                     indCtors = [ctorName]
--                   }
--               ],
--             indConstructors =
--               [ ConstructorVal
--                   { ctorConst = ConstantVal {constName = ctorName, constLevelParameters = [], constType = hceVal sortZero},
--                     ctorInductive = indName,
--                     ctorIndex = 0,
--                     ctorParamsN = 0,
--                     ctorFieldsN = 1
--                   }
--               ],
--             indRecursors =
--               [ RecursorVal
--                   { recConst = ConstantVal {constName = recName, constLevelParameters = [], constType = hceVal sortZero},
--                     recParamsN = 0,
--                     recIndicesN = 0,
--                     recMotivesN = 1,
--                     recMinorsN = 1,
--                     recKRule = False,
--                     recRules = [RecursorRule {recCtor = ctorName, recFieldsN = 0, recRhs = hceVal ruleRhs}]
--                   }
--               ]
--           }
--    in (badDecl, internState)
--   where
--     build = do
--       indName <- internName (rawName ["Kernel", "BadRec"])
--       ctorName <- internName (rawName ["Kernel", "BadRec", "mk"])
--       recName <- internName (rawName ["Kernel", "BadRec", "rec"])
--       sortZero <- internExpr rawSortZeroExpr
--       ruleRhs <- internExpr $ rawLamExpr ["motive"] rawSortZeroExpr (rawLamExpr ["minor"] rawSortZeroExpr (rawLamExpr ["field"] rawSortZeroExpr (rawBVarExpr 0) Default) Default) Default
--       pure (indName, ctorName, recName, sortZero, ruleRhs)

-- expectParseLeanFixture :: LeanFixture -> IO [Decl HCExpr HCLevel]
-- expectParseLeanFixture fixture = do
--   exportPath <- generateLeanExport fixture
--   result <- parseExportFile exportPath
--   removeFile exportPath
--   case result of
--     Left err -> failWith err
--     Right decls -> pure decls

-- loadParsedLeanFixture :: LeanFixture -> IO ParsedExport
-- loadParsedLeanFixture fixture = do
--   exportPath <- generateLeanExport fixture
--   result <- parseExportFileWithState exportPath
--   removeFile exportPath
--   case result of
--     Left err -> failWith err
--     Right parsed -> pure parsed

-- loadCheckedLeanFixture :: LeanFixture -> IO (KernelEnv, InternState)
-- loadCheckedLeanFixture fixture = do
--   exportPath <- generateLeanExport fixture
--   result <- checkExportFile exportPath
--   removeFile exportPath
--   expectRight result

-- generateLeanExport :: LeanFixture -> IO FilePath
-- generateLeanExport fixture = do
--   projectDir <- leanFixtureProjectDir
--   _ <- runCheckedProcess projectDir "lake" ["build", fixtureModuleName fixture]
--   _ <- runCheckedProcess projectDir "lake" ["build", "@lean4export/lean4export"]
--   lean4exportDir <- pure (projectDir </> ".lake" </> "packages" </> "lean4export")
--   let lean4exportBinaryPath = lean4exportDir </> ".lake" </> "build" </> "bin" </> "lean4export"
--   tmpRoot <- getTemporaryDirectory
--   (exportPath, exportHandle) <- openTempFile tmpRoot (fixtureModuleName fixture <> "-")
--   hClose exportHandle
--   let exportCommand = unwords (fmap shellQuote (["lake", "env", lean4exportBinaryPath, fixtureModuleName fixture, "--"] <> fixtureDeclNames fixture)) <> " > " <> shellQuote exportPath
--   _ <- runShellCommand projectDir exportCommand
--   pure exportPath

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

conversionSupportFixture :: FilePath
conversionSupportFixture = "kernel-conversion-support.ndjson"

missingAxiomIsUnsafeFixture :: FilePath
missingAxiomIsUnsafeFixture = "kernel-negative-missing-axiom-isUnsafe.ndjson"

unexpectedDefinitionPayloadKeyFixture :: FilePath
unexpectedDefinitionPayloadKeyFixture = "kernel-negative-unexpected-definition-payload-key.ndjson"

missingOpaqueAllFixture :: FilePath
missingOpaqueAllFixture = "kernel-negative-missing-opaque-all.ndjson"

duplicateInductiveAliasFixture :: FilePath
duplicateInductiveAliasFixture = "kernel-negative-duplicate-inductive-alias.ndjson"

unexpectedLamPayloadKeyFixture :: FilePath
unexpectedLamPayloadKeyFixture = "kernel-negative-unexpected-lam-payload-key.ndjson"

arenaTypeMismatchFixture :: FilePath
arenaTypeMismatchFixture = "kernel-negative-arena-type-mismatch.ndjson"

supportStandaloneCtorPrefixes :: [ByteString]
supportStandaloneCtorPrefixes =
  [ "{\"meta\"",
    "{\"in\":10,",
    "{\"in\":11,",
    "{\"in\":16,",
    "{\"in\":17,",
    "{\"il\":1,",
    "{\"il\":2,",
    "{\"il\":4,",
    "{\"ie\":1,",
    "{\"ie\":3,",
    "{\"ie\":6,",
    "{\"ie\":7,",
    "{\"ie\":9,",
    "{\"constructor\":"
  ]

-- loadParsedExportFixture :: FilePath -> IO ParsedExport
-- loadParsedExportFixture fixtureName = do
--   path <- fixturePath fixtureName
--   expectRight =<< parseExportFileWithState path

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

expectRight :: IO (Either String a, InternState) -> IO a
expectRight result =
  fst <$> result >>= \case
    Left err -> assertFailure err
    Right value -> pure value

neverCompareArgs :: HCExpr -> HCExpr -> KernelM Bool
neverCompareArgs _ _ = throwError "unexpected same-head regular pre-unfold comparison"

whnf :: HCExpr -> KernelM HCExpr
whnf expr = do
  val <- evalM [] expr
  quote val

assertEq :: (Eq a, Show a) => a -> a -> String -> IO ()
assertEq expected actual message =
  if expected == actual
    then pure ()
    else assertFailure (message <> ": expected " <> show expected <> ", got " <> show actual)

assertName :: String -> HCName -> IO ()
assertName expected actual =
  assertEq expected (toString actual) "unexpected name"

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

rawNatExpr :: Int -> Expr
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
