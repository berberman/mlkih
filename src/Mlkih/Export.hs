{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module Mlkih.Export
  ( ParsedExport (..),
    parseExport,
    parseExportWithState,
    parseExportFile,
    parseExportFileWithState,
    checkExportFile,
    checkParsedExport,
  )
where

import Control.Monad (foldM, unless, when)
import Data.Aeson (Object, Value (..), eitherDecodeStrict')
import Data.Aeson.Key (Key, fromText, toText)
import qualified Data.Aeson.KeyMap as KeyMap
import Data.Bifunctor (first)
import Data.ByteString (ByteString)
import qualified Data.ByteString.Char8 as BSC
import qualified Data.IntMap.Strict as IntMap
import Data.List (sortOn)
import Data.Maybe (mapMaybe)
import Data.Scientific (toBoundedInteger)
import Data.Set (Set)
import qualified Data.Set as Set
import Data.Text (Text)
import qualified Data.Text as Text
import qualified Data.Vector as Vector
import Mlkih.Decl
import Mlkih.Env
import Mlkih.Expr
import Mlkih.Intern
import Mlkih.Kernel (KernelError, KernelState (..), addDecls, runKernelM, printKernelTrace, withMaxVerbosity)
import Mlkih.Level
import Mlkih.Name
import Mlkih.Types
import System.IO (IOMode (ReadMode), hIsEOF, withFile)

-- | Parser monad for export decoding.
--
-- This stays as plain 'Either String' because the parser is still a simple
-- single-pass decoder, but naming it makes the intent clearer and centralizes
-- error construction in 'parserFail'.
type Parser = Either String

data ParsedExport = ParsedExport
  { parsedDecls :: [Decl HCExpr HCLevel],
    parsedInternState :: InternState
  }

data ExportState = ExportState
  { stMetaSeen :: Bool,
    stInternState :: InternState,
    stDeclNames :: Set HCName,
    stDeclsRev :: [Decl HCExpr HCLevel]
  }

data NameRecord
  = NameStr Int Text
  | NameNum Int Int

data LevelRecord
  = LevelSucc Int
  | LevelMax Int Int
  | LevelIMax Int Int
  | LevelParam Int

data ExprRecord
  = ExprBVar Int
  | ExprSort Int
  | ExprConst Int [Int]
  | ExprApp Int Int
  | ExprLam Int Int Int BinderInfo
  | ExprForallE Int Int Int BinderInfo
  | ExprLetE Int Int Int Int Bool
  | ExprProj Int Int Int
  | ExprNatVal Int
  | ExprStrVal Text
  | ExprMData Int

data SupportedSafety
  = SafeSafety
  | UnsafeSafety
  | PartialSafety

data RawConstant = RawConstant
  { rawConstNameId :: HCId,
    rawConstLevelParamIds :: [HCId],
    rawConstTypeId :: HCId
  }

data RawAxiomVal = RawAxiomVal
  { rawAxiomConst :: RawConstant,
    rawAxiomIsUnsafe :: Bool
  }

data RawDefinitionVal = RawDefinitionVal
  { rawDefinitionConst :: RawConstant,
    rawDefinitionHints :: ReducibilityHints,
    rawDefinitionValueId :: HCId,
    rawDefinitionSafety :: SupportedSafety,
    rawDefinitionAllIds :: [HCId]
  }

data RawTheoremVal = RawTheoremVal
  { rawTheoremConst :: RawConstant,
    rawTheoremValueId :: HCId,
    rawTheoremAllIds :: [HCId]
  }

data RawOpaqueVal = RawOpaqueVal
  { rawOpaqueConst :: RawConstant,
    rawOpaqueValueId :: HCId,
    rawOpaqueAllIds :: [HCId],
    rawOpaqueIsUnsafe :: Bool
  }

data RawQuotVal = RawQuotVal
  { rawQuotConst :: RawConstant,
    rawQuotKind :: QuotKind
  }

data RawConstructorVal = RawConstructorVal
  { rawCtorConst :: RawConstant,
    rawCtorInductiveId :: HCId,
    rawCtorIndex :: Int,
    rawCtorParamsN :: Int,
    rawCtorFieldsN :: Int,
    rawCtorIsUnsafe :: Bool
  }

data RawRecursorRule = RawRecursorRule
  { rawRecRuleCtorId :: HCId,
    rawRecRuleFieldsN :: Int,
    rawRecRuleRhsId :: HCId
  }

data RawRecursorVal = RawRecursorVal
  { rawRecConst :: RawConstant,
    rawRecAllIds :: [HCId],
    rawRecParamsN :: Int,
    rawRecIndicesN :: Int,
    rawRecMotivesN :: Int,
    rawRecMinorsN :: Int,
    rawRecKRule :: Bool,
    rawRecRules :: [RawRecursorRule],
    rawRecIsUnsafe :: Bool
  }

data RawInductiveVal = RawInductiveVal
  { rawIndConst :: RawConstant,
    rawIndAllIds :: [HCId],
    rawIndCtorIds :: [HCId],
    rawIndParamsN :: Int,
    rawIndIndicesN :: Int,
    rawIndNumNested :: Int,
    rawIndIsRec :: Bool,
    rawIndIsUnsafe :: Bool,
    rawIndIsReflexive :: Bool
  }

data RawInductiveGroup = RawInductiveGroup
  { rawGroupTypes :: [RawInductiveVal],
    rawGroupCtors :: [RawConstructorVal],
    rawGroupRecs :: [RawRecursorVal]
  }

data RawDecl
  = RawAxiomDecl RawAxiomVal
  | RawDefinitionDecl RawDefinitionVal
  | RawTheoremDecl RawTheoremVal
  | RawOpaqueDecl RawOpaqueVal
  | RawQuotDecl RawQuotVal
  | RawConstructorDecl RawConstructorVal
  | RawRecursorDecl RawRecursorVal
  | RawInductiveBlockDecl RawInductiveGroup

parseExport :: ByteString -> Either String [Decl HCExpr HCLevel]
parseExport input = parsedDecls <$> parseExportWithState input

parseExportWithState :: ByteString -> Either String ParsedExport
parseExportWithState input = do
  finalizeState =<< parseLines (BSC.lines input)

parseExportFile :: FilePath -> IO (Either String [Decl HCExpr HCLevel])
parseExportFile path = fmap (fmap parsedDecls) (parseExportFileWithState path)

checkExportFile :: FilePath -> IO (Either KernelError (KernelEnv, InternState))
checkExportFile exportPath = do
  parseResult <- parseExportFileWithState exportPath
  case parseResult of
    Left err -> pure $ Left err
    Right parsedExport -> checkParsedExport parsedExport

checkParsedExport :: ParsedExport -> IO (Either KernelError (KernelEnv, InternState))
checkParsedExport export = do
  let (result, state) = runKernelM IntMap.empty (parsedInternState export) $ withMaxVerbosity $ addDecls (parsedDecls export)
  printKernelTrace state
  case result of
    Left kernelErr -> pure $ Left kernelErr
    Right _ -> pure $ Right (checkEnv state, checkInternState state)

parseExportFileWithState :: FilePath -> IO (Either String ParsedExport)
parseExportFileWithState path = withFile path ReadMode loop
  where
    loop handle = go 1 initialState False
      where
        go lineNo st sawAnyLine = do
          eof <- hIsEOF handle
          if eof
            then pure $ finalizeStateIf sawAnyLine st
            else do
              line <- BSC.hGetLine handle
              if isBlankLine line
                then pure $ finalizeStateIf True st
                else case step st (lineNo, line) of
                  Left err -> pure $ Left err
                  Right st' -> do
                    let sawAnyLine' = True
                    if lineNo == 1 && not (stMetaSeen st')
                      then pure $ Left "meta object must be the first record"
                      else go (lineNo + 1) st' sawAnyLine'

parseLines :: [ByteString] -> Parser ExportState
parseLines linesToParse = case takeWhile (not . isBlankLine) linesToParse of
  [] -> parserFail "missing initial meta object"
  (firstLine : restLines) -> do
    initialWithMeta <- step initialState (1, firstLine)
    unless (stMetaSeen initialWithMeta) $ parserFail "meta object must be the first record"
    foldM step initialWithMeta (zip [2 ..] restLines)

finalizeState :: ExportState -> Parser ParsedExport
finalizeState st = do
  unless (stMetaSeen st) $ parserFail "missing initial meta object"
  pure
    ParsedExport
      { parsedDecls = reverse (stDeclsRev st),
        parsedInternState = stInternState st
      }

finalizeStateIf :: Bool -> ExportState -> Parser ParsedExport
finalizeStateIf sawAnyLine st
  | sawAnyLine = finalizeState st
  | otherwise = parserFail "missing initial meta object"

initialState :: ExportState
initialState = ExportState False emptyInternState Set.empty []

isBlankLine :: ByteString -> Bool
isBlankLine = BSC.all (`elem` [' ', '\t', '\r'])

step :: ExportState -> (Int, ByteString) -> Parser ExportState
step st (lineNo, rawLine) = do
  value <- first (decorate lineNo . ("invalid JSON: " <>)) (eitherDecodeStrict' rawLine)
  obj <- expectObject (context lineNo) value
  processObject lineNo st obj

processObject :: Int -> ExportState -> Object -> Parser ExportState
processObject lineNo st obj
  | hasKey "meta" obj = processMeta lineNo st obj
  | hasKey "in" obj = processName lineNo st obj
  | hasKey "il" obj = processLevel lineNo st obj
  | hasKey "ie" obj = processExpr lineNo st obj
  | otherwise = processDeclarations lineNo st obj

processMeta :: Int -> ExportState -> Object -> Parser ExportState
processMeta lineNo st obj = do
  ensureExactTopLevelKeys lineNo ["meta"] obj
  _ <- expectObject (fieldContext lineNo "meta") =<< requiredField obj "meta"
  when (lineNo /= 1) $ parserFail (decorate lineNo "meta object must be the first record")
  when (stMetaSeen st) $ parserFail (decorate lineNo "duplicate meta object")
  pure st {stMetaSeen = True}

processName :: Int -> ExportState -> Object -> Parser ExportState
processName lineNo st obj = do
  ensureExactTopLevelKeys lineNo ["in", "str", "num"] obj
  ident <- requiredInt lineNo "in" obj
  when (ident <= 0) $ parserFail (decorate lineNo "name id must be positive")
  record <- parseNameRecord lineNo obj
  nameVal <- case record of
    NameStr pre segment -> Str <$> resolveName lineNo st pre <*> pure segment
    NameNum pre n -> Num <$> resolveName lineNo st pre <*> pure n
  (_, stInternState') <- first (decorate lineNo . (<> "")) $ registerImportedNameIn ident nameVal (stInternState st)
  pure st {stInternState = stInternState'}

processLevel :: Int -> ExportState -> Object -> Parser ExportState
processLevel lineNo st obj = do
  ensureExactTopLevelKeys lineNo ["il", "succ", "max", "imax", "param"] obj
  ident <- requiredInt lineNo "il" obj
  when (ident <= 0) $ parserFail (decorate lineNo "level id must be positive")
  record <- parseLevelRecord lineNo obj
  levelVal <- case record of
    LevelSucc inner -> LSucc <$> resolveLevel lineNo st inner
    LevelMax lhs rhs -> LMax <$> resolveLevel lineNo st lhs <*> resolveLevel lineNo st rhs
    LevelIMax lhs rhs -> LIMax <$> resolveLevel lineNo st lhs <*> resolveLevel lineNo st rhs
    LevelParam nameId -> LVar <$> resolveName lineNo st nameId
  (_, stInternState') <- first (decorate lineNo . (<> "")) $ registerImportedLevelIn ident levelVal (stInternState st)
  pure st {stInternState = stInternState'}

processExpr :: Int -> ExportState -> Object -> Parser ExportState
processExpr lineNo st obj = do
  ensureExactTopLevelKeys lineNo ["ie", "bvar", "sort", "const", "app", "lam", "forallE", "letE", "proj", "natVal", "strVal", "mdata"] obj
  ident <- requiredInt lineNo "ie" obj
  when (ident < 0) $ parserFail (decorate lineNo "expression id must be non-negative")
  record <- parseExprRecord lineNo obj
  exprVal <- case record of
    ExprBVar idx -> pure (BVar idx)
    ExprSort levelId -> Sort <$> resolveLevel lineNo st levelId
    ExprConst nameId levelIds -> Const <$> resolveName lineNo st nameId <*> traverse (resolveLevel lineNo st) levelIds
    ExprApp fnId argId -> App <$> resolveExpr lineNo st fnId <*> resolveExpr lineNo st argId
    ExprLam nameId typeId bodyId binderInfo -> Lam <$> resolveName lineNo st nameId <*> resolveExpr lineNo st typeId <*> resolveExpr lineNo st bodyId <*> pure binderInfo
    ExprForallE nameId typeId bodyId binderInfo -> ForallE <$> resolveName lineNo st nameId <*> resolveExpr lineNo st typeId <*> resolveExpr lineNo st bodyId <*> pure binderInfo
    ExprLetE nameId typeId valueId bodyId nondep -> Let <$> resolveName lineNo st nameId <*> resolveExpr lineNo st typeId <*> resolveExpr lineNo st valueId <*> resolveExpr lineNo st bodyId <*> pure nondep
    ExprProj typeNameId idx structId -> Proj <$> resolveName lineNo st typeNameId <*> pure idx <*> resolveExpr lineNo st structId
    ExprNatVal n -> pure $ Lit (NatVal n)
    ExprStrVal txt -> pure $ Lit $ StrVal $ Text.unpack txt
    ExprMData exprId -> hceVal <$> resolveExpr lineNo st exprId
  (_, stInternState') <- first (decorate lineNo . (<> "")) $ registerImportedExprIn ident exprVal (stInternState st)
  pure st {stInternState = stInternState'}

processDeclarations :: Int -> ExportState -> Object -> Parser ExportState
processDeclarations lineNo st obj = do
  ensureDeclarationTopLevelKeys lineNo obj
  rawDecls <-
    fmap concat . sequence $
      [ parseWrappedDecl "axiom" (parseRawAxiom lineNo) obj,
        parseWrappedDecl "def" (parseRawDefinition lineNo) obj,
        parseWrappedDecl "thm" (parseRawTheorem lineNo) obj,
        parseWrappedDecl "opaque" (parseRawOpaque lineNo) obj,
        parseWrappedDecl "quot" (parseRawQuot lineNo) obj,
        parseWrappedDecl "constructor" (parseRawConstructor lineNo) obj,
        parseWrappedDecl "recursor" (parseRawRecursor lineNo) obj,
        parseWrappedDecl "inductive" (parseRawInductiveGroup lineNo) obj
      ]
  if null rawDecls
    then parserFail (decorate lineNo "unknown export record")
    else do
      decls <- traverse (lowerRawDecl lineNo st) rawDecls
      st' <- foldM (registerDeclaration lineNo) st decls
      pure st' {stDeclsRev = foldl' (flip (:)) (stDeclsRev st') decls}

parseWrappedDecl :: Text -> (Value -> Parser a) -> Object -> Parser [a]
parseWrappedDecl tag parseFn obj =
  case optionalField obj tag of
    Nothing -> pure []
    Just payload -> do
      values <- unwrapPayload tag payload
      traverse parseFn values

unwrapPayload :: Text -> Value -> Parser [Value]
unwrapPayload tag = \case
  Array values -> pure (Vector.toList values)
  Object obj -> pure [Object obj]
  other -> parserFail ("field '" <> Text.unpack tag <> "' must be an object or array, found " <> valueType other)

parserFail :: String -> Parser a
parserFail = Left

parseNameRecord :: Int -> Object -> Either String NameRecord
parseNameRecord lineNo obj
  | hasKey "str" obj = do
      payload <- expectObject (fieldContext lineNo "str") =<< requiredField obj "str"
      ensureExactObjectFields lineNo "field 'str' payload" ["pre", "str"] payload
      NameStr <$> requiredNatObj lineNo "str.pre" "pre" payload <*> requiredTextObj lineNo "str.str" "str" payload
  | hasKey "num" obj = do
      payload <- expectObject (fieldContext lineNo "num") =<< requiredField obj "num"
      ensureExactObjectFields lineNo "field 'num' payload" ["pre", "i"] payload
      NameNum <$> requiredNatObj lineNo "num.pre" "pre" payload <*> requiredNatObj lineNo "num.i" "i" payload
  | otherwise = Left (decorate lineNo "name record missing 'str' or 'num'")

parseLevelRecord :: Int -> Object -> Either String LevelRecord
parseLevelRecord lineNo obj
  | hasKey "succ" obj = LevelSucc <$> requiredInt lineNo "succ" obj
  | hasKey "max" obj = do
      (lhs, rhs) <- requiredIntPair lineNo "max" obj
      pure (LevelMax lhs rhs)
  | hasKey "imax" obj = do
      (lhs, rhs) <- requiredIntPair lineNo "imax" obj
      pure (LevelIMax lhs rhs)
  | hasKey "param" obj = LevelParam <$> requiredInt lineNo "param" obj
  | otherwise = Left (decorate lineNo "level record missing constructor tag")

parseExprRecord :: Int -> Object -> Either String ExprRecord
parseExprRecord lineNo obj
  | hasKey "bvar" obj = ExprBVar <$> requiredNat lineNo "bvar" obj
  | hasKey "sort" obj = ExprSort <$> requiredInt lineNo "sort" obj
  | hasKey "const" obj = do
      payload <- expectObject (fieldContext lineNo "const") =<< requiredField obj "const"
      ensureExactObjectFields lineNo "field 'const' payload" ["name", "us"] payload
      ExprConst <$> requiredIntObj lineNo "const.name" "name" payload <*> requiredIntArrayObj lineNo "const.us" "us" payload
  | hasKey "app" obj = do
      payload <- expectObject (fieldContext lineNo "app") =<< requiredField obj "app"
      ensureExactObjectFields lineNo "field 'app' payload" ["fn", "arg"] payload
      ExprApp <$> requiredIntObj lineNo "app.fn" "fn" payload <*> requiredIntObj lineNo "app.arg" "arg" payload
  | hasKey "lam" obj = do
      payload <- expectObject (fieldContext lineNo "lam") =<< requiredField obj "lam"
      ensureExactObjectFields lineNo "field 'lam' payload" ["name", "type", "body", "binderInfo"] payload
      ExprLam <$> requiredIntObj lineNo "lam.name" "name" payload <*> requiredIntObj lineNo "lam.type" "type" payload <*> requiredIntObj lineNo "lam.body" "body" payload <*> requiredBinderInfo lineNo "lam.binderInfo" payload
  | hasKey "forallE" obj = do
      payload <- expectObject (fieldContext lineNo "forallE") =<< requiredField obj "forallE"
      ensureExactObjectFields lineNo "field 'forallE' payload" ["name", "type", "body", "binderInfo"] payload
      ExprForallE <$> requiredIntObj lineNo "forallE.name" "name" payload <*> requiredIntObj lineNo "forallE.type" "type" payload <*> requiredIntObj lineNo "forallE.body" "body" payload <*> requiredBinderInfo lineNo "forallE.binderInfo" payload
  | hasKey "letE" obj = do
      payload <- expectObject (fieldContext lineNo "letE") =<< requiredField obj "letE"
      ensureExactObjectFields lineNo "field 'letE' payload" ["name", "type", "value", "body", "nondep"] payload
      ExprLetE <$> requiredIntObj lineNo "letE.name" "name" payload <*> requiredIntObj lineNo "letE.type" "type" payload <*> requiredIntObj lineNo "letE.value" "value" payload <*> requiredIntObj lineNo "letE.body" "body" payload <*> requiredBool lineNo "nondep" payload
  | hasKey "proj" obj = do
      payload <- expectObject (fieldContext lineNo "proj") =<< requiredField obj "proj"
      ensureExactObjectFields lineNo "field 'proj' payload" ["typeName", "idx", "struct"] payload
      ExprProj <$> requiredIntObj lineNo "proj.typeName" "typeName" payload <*> requiredNatObj lineNo "proj.idx" "idx" payload <*> requiredIntObj lineNo "proj.struct" "struct" payload
  | hasKey "natVal" obj = ExprNatVal <$> requiredNatLikeInt lineNo "natVal" obj
  | hasKey "strVal" obj = ExprStrVal <$> requiredText lineNo "strVal" obj
  | hasKey "mdata" obj = do
      payload <- expectObject (fieldContext lineNo "mdata") =<< requiredField obj "mdata"
      ensureExactObjectFields lineNo "field 'mdata' payload" ["expr"] payload
      ExprMData <$> requiredIntObj lineNo "mdata.expr" "expr" payload
  | otherwise = Left $ decorate lineNo "expression record missing constructor tag"

parseRawAxiom :: Int -> Value -> Either String RawDecl
parseRawAxiom lineNo value = do
  obj <- expectObject (context lineNo) value
  ensureExactObjectFields lineNo "field 'axiom' payload" ["name", "levelParams", "type", "isUnsafe"] obj
  rawAxiomConst <- parseRawConstant lineNo obj
  rawAxiomIsUnsafe <- requiredBool lineNo "isUnsafe" obj
  pure (RawAxiomDecl RawAxiomVal {rawAxiomConst = rawAxiomConst, rawAxiomIsUnsafe = rawAxiomIsUnsafe})

parseRawDefinition :: Int -> Value -> Either String RawDecl
parseRawDefinition lineNo value = do
  obj <- expectObject (context lineNo) value
  ensureExactObjectFields lineNo "field 'def' payload" ["name", "levelParams", "type", "value", "hints", "safety", "all"] obj
  rawDefinitionConst <- parseRawConstant lineNo obj
  rawDefinitionHints <- requiredHints lineNo obj
  rawDefinitionValueId <- requiredInt lineNo "value" obj
  rawDefinitionSafety <- requiredSafety lineNo obj
  rawDefinitionAllIds <- requiredIntArray lineNo "all" obj
  pure (RawDefinitionDecl RawDefinitionVal {rawDefinitionConst = rawDefinitionConst, rawDefinitionHints = rawDefinitionHints, rawDefinitionValueId = rawDefinitionValueId, rawDefinitionSafety = rawDefinitionSafety, rawDefinitionAllIds = rawDefinitionAllIds})

parseRawTheorem :: Int -> Value -> Either String RawDecl
parseRawTheorem lineNo value = do
  obj <- expectObject (context lineNo) value
  ensureExactObjectFields lineNo "field 'thm' payload" ["name", "levelParams", "type", "value", "all"] obj
  rawTheoremConst <- parseRawConstant lineNo obj
  rawTheoremValueId <- requiredInt lineNo "value" obj
  rawTheoremAllIds <- requiredIntArray lineNo "all" obj
  pure (RawTheoremDecl RawTheoremVal {rawTheoremConst = rawTheoremConst, rawTheoremValueId = rawTheoremValueId, rawTheoremAllIds = rawTheoremAllIds})

parseRawOpaque :: Int -> Value -> Either String RawDecl
parseRawOpaque lineNo value = do
  obj <- expectObject (context lineNo) value
  ensureExactObjectFields lineNo "field 'opaque' payload" ["name", "levelParams", "type", "value", "all", "isUnsafe"] obj
  rawOpaqueConst <- parseRawConstant lineNo obj
  rawOpaqueValueId <- requiredInt lineNo "value" obj
  rawOpaqueAllIds <- requiredIntArray lineNo "all" obj
  rawOpaqueIsUnsafe <- requiredBool lineNo "isUnsafe" obj
  pure (RawOpaqueDecl RawOpaqueVal {rawOpaqueConst = rawOpaqueConst, rawOpaqueValueId = rawOpaqueValueId, rawOpaqueAllIds = rawOpaqueAllIds, rawOpaqueIsUnsafe = rawOpaqueIsUnsafe})

parseRawQuot :: Int -> Value -> Either String RawDecl
parseRawQuot lineNo value = do
  obj <- expectObject (context lineNo) value
  ensureExactObjectFields lineNo "field 'quot' payload" ["name", "levelParams", "type", "kind"] obj
  rawQuotConst <- parseRawConstant lineNo obj
  rawQuotKind <- requiredQuotKind lineNo obj
  pure (RawQuotDecl RawQuotVal {rawQuotConst = rawQuotConst, rawQuotKind = rawQuotKind})

parseRawInductiveGroup :: Int -> Value -> Either String RawDecl
parseRawInductiveGroup lineNo value = do
  obj <- expectObject (context lineNo) value
  ensureAllowedObjectKeys lineNo "field 'inductive' payload" ["types", "inductiveVals", "ctors", "constructorVals", "recs", "recursorVals"] obj
  indPayloads <- selectAliasArray lineNo "inductive types" ["types", "inductiveVals"] obj
  ctorPayloads <- selectAliasArray lineNo "inductive constructors" ["ctors", "constructorVals"] obj
  recPayloads <- selectAliasArray lineNo "inductive recursors" ["recs", "recursorVals"] obj
  rawGroupTypes <- traverse (parseRawInductive lineNo) indPayloads
  rawGroupCtors <- traverse (parseRawConstructorVal lineNo) ctorPayloads
  rawGroupRecs <- traverse (parseRawRecursorVal lineNo) recPayloads
  pure (RawInductiveBlockDecl RawInductiveGroup {rawGroupTypes = rawGroupTypes, rawGroupCtors = rawGroupCtors, rawGroupRecs = rawGroupRecs})

parseRawInductive :: Int -> Value -> Either String RawInductiveVal
parseRawInductive lineNo value = do
  obj <- expectObject (context lineNo) value
  ensureExactObjectFields lineNo "inductive member payload" ["name", "levelParams", "type", "numParams", "numIndices", "all", "ctors", "numNested", "isRec", "isUnsafe", "isReflexive"] obj
  rawIndConst <- parseRawConstant lineNo obj
  rawIndParamsN <- requiredNat lineNo "numParams" obj
  rawIndIndicesN <- requiredNat lineNo "numIndices" obj
  rawIndAllIds <- requiredIntArray lineNo "all" obj
  rawIndCtorIds <- requiredIntArray lineNo "ctors" obj
  rawIndNumNested <- requiredNat lineNo "numNested" obj
  rawIndIsRec <- requiredBool lineNo "isRec" obj
  rawIndIsUnsafe <- requiredBool lineNo "isUnsafe" obj
  rawIndIsReflexive <- requiredBool lineNo "isReflexive" obj
  pure RawInductiveVal {rawIndConst = rawIndConst, rawIndAllIds = rawIndAllIds, rawIndCtorIds = rawIndCtorIds, rawIndParamsN = rawIndParamsN, rawIndIndicesN = rawIndIndicesN, rawIndNumNested = rawIndNumNested, rawIndIsRec = rawIndIsRec, rawIndIsUnsafe = rawIndIsUnsafe, rawIndIsReflexive = rawIndIsReflexive}

parseRawConstructor :: Int -> Value -> Either String RawDecl
parseRawConstructor lineNo value = RawConstructorDecl <$> parseRawConstructorVal lineNo value

parseRawConstructorVal :: Int -> Value -> Either String RawConstructorVal
parseRawConstructorVal lineNo value = do
  obj <- expectObject (context lineNo) value
  ensureExactObjectFields lineNo "field 'constructor' payload" ["name", "levelParams", "type", "induct", "cidx", "numParams", "numFields", "isUnsafe"] obj
  rawCtorConst <- parseRawConstant lineNo obj
  rawCtorInductiveId <- requiredInt lineNo "induct" obj
  rawCtorIndex <- requiredNat lineNo "cidx" obj
  rawCtorParamsN <- requiredNat lineNo "numParams" obj
  rawCtorFieldsN <- requiredNat lineNo "numFields" obj
  rawCtorIsUnsafe <- requiredBool lineNo "isUnsafe" obj
  pure RawConstructorVal {rawCtorConst = rawCtorConst, rawCtorInductiveId = rawCtorInductiveId, rawCtorIndex = rawCtorIndex, rawCtorParamsN = rawCtorParamsN, rawCtorFieldsN = rawCtorFieldsN, rawCtorIsUnsafe = rawCtorIsUnsafe}

parseRawRecursor :: Int -> Value -> Either String RawDecl
parseRawRecursor lineNo value = RawRecursorDecl <$> parseRawRecursorVal lineNo value

parseRawRecursorVal :: Int -> Value -> Either String RawRecursorVal
parseRawRecursorVal lineNo value = do
  obj <- expectObject (context lineNo) value
  ensureExactObjectFields lineNo "field 'recursor' payload" ["name", "levelParams", "type", "all", "numParams", "numIndices", "numMotives", "numMinors", "rules", "k", "isUnsafe"] obj
  rawRecConst <- parseRawConstant lineNo obj
  rawRecAllIds <- requiredIntArray lineNo "all" obj
  rawRecParamsN <- requiredNat lineNo "numParams" obj
  rawRecIndicesN <- requiredNat lineNo "numIndices" obj
  rawRecMotivesN <- requiredNat lineNo "numMotives" obj
  rawRecMinorsN <- requiredNat lineNo "numMinors" obj
  rawRecKRule <- requiredBool lineNo "k" obj
  rawRecRules <- traverse (parseRawRecursorRule lineNo) =<< requiredValueArray lineNo "rules" obj
  rawRecIsUnsafe <- requiredBool lineNo "isUnsafe" obj
  pure RawRecursorVal {rawRecConst = rawRecConst, rawRecAllIds = rawRecAllIds, rawRecParamsN = rawRecParamsN, rawRecIndicesN = rawRecIndicesN, rawRecMotivesN = rawRecMotivesN, rawRecMinorsN = rawRecMinorsN, rawRecKRule = rawRecKRule, rawRecRules = rawRecRules, rawRecIsUnsafe = rawRecIsUnsafe}

parseRawRecursorRule :: Int -> Value -> Either String RawRecursorRule
parseRawRecursorRule lineNo value = do
  obj <- expectObject (context lineNo) value
  ensureExactObjectFields lineNo "recursor rule payload" ["ctor", "nfields", "rhs"] obj
  rawRecRuleCtorId <- requiredInt lineNo "ctor" obj
  rawRecRuleFieldsN <- requiredNat lineNo "nfields" obj
  rawRecRuleRhsId <- requiredInt lineNo "rhs" obj
  pure RawRecursorRule {rawRecRuleCtorId = rawRecRuleCtorId, rawRecRuleFieldsN = rawRecRuleFieldsN, rawRecRuleRhsId = rawRecRuleRhsId}

parseRawConstant :: Int -> Object -> Either String RawConstant
parseRawConstant lineNo obj = do
  rawConstNameId <- requiredInt lineNo "name" obj
  rawConstLevelParamIds <- requiredIntArray lineNo "levelParams" obj
  rawConstTypeId <- requiredInt lineNo "type" obj
  pure RawConstant {rawConstNameId = rawConstNameId, rawConstLevelParamIds = rawConstLevelParamIds, rawConstTypeId = rawConstTypeId}

lowerRawDecl :: Int -> ExportState -> RawDecl -> Either String (Decl HCExpr HCLevel)
lowerRawDecl lineNo st rawDecl =
  case rawDecl of
    RawAxiomDecl rawAxiom -> AxiomDecl <$> lowerRawAxiom lineNo st rawAxiom
    RawDefinitionDecl rawDefinition -> DefnDecl <$> lowerRawDefinition lineNo st rawDefinition
    RawTheoremDecl rawTheorem -> ThmDecl <$> lowerRawTheorem lineNo st rawTheorem
    RawOpaqueDecl rawOpaque -> OpaqueDecl <$> lowerRawOpaque lineNo st rawOpaque
    RawQuotDecl rawQuot -> QuotDecl <$> lowerRawQuot lineNo st rawQuot
    RawConstructorDecl rawCtor -> CtorDecl <$> lowerRawConstructor lineNo st rawCtor
    RawRecursorDecl rawRec -> RecDecl <$> lowerRawRecursor lineNo st rawRec
    RawInductiveBlockDecl rawGroup -> InductiveBlockDecl <$> lowerRawInductiveGroup lineNo st rawGroup

lowerRawAxiom :: Int -> ExportState -> RawAxiomVal -> Either String (AxiomVal HCExpr HCLevel)
lowerRawAxiom lineNo st rawAxiom = do
  _ <- pure (rawAxiomIsUnsafe rawAxiom)
  lowerRawConstant lineNo st (rawAxiomConst rawAxiom)

lowerRawDefinition :: Int -> ExportState -> RawDefinitionVal -> Either String (DefinitionVal HCExpr HCLevel)
lowerRawDefinition lineNo st rawDefinition = do
  defConst <- lowerRawConstant lineNo st (rawDefinitionConst rawDefinition)
  _ <- validateRelatedNames lineNo st "def.all" (rawDefinitionAllIds rawDefinition)
  _ <- pure (rawDefinitionSafety rawDefinition)
  defValue <- requiredExprPayloadRefById lineNo st (rawDefinitionValueId rawDefinition)
  pure DefinitionVal {defConst = defConst, defHints = rawDefinitionHints rawDefinition, defValue = defValue}

lowerRawTheorem :: Int -> ExportState -> RawTheoremVal -> Either String (TheoremVal HCExpr HCLevel)
lowerRawTheorem lineNo st rawTheorem = do
  thmConst <- lowerRawConstant lineNo st (rawTheoremConst rawTheorem)
  _ <- validateRelatedNames lineNo st "thm.all" (rawTheoremAllIds rawTheorem)
  thmValue <- requiredExprPayloadRefById lineNo st (rawTheoremValueId rawTheorem)
  pure TheoremVal {thmConst = thmConst, thmValue = thmValue}

lowerRawOpaque :: Int -> ExportState -> RawOpaqueVal -> Either String (OpaqueVal HCExpr HCLevel)
lowerRawOpaque lineNo st rawOpaque = do
  opaqueConst <- lowerRawConstant lineNo st (rawOpaqueConst rawOpaque)
  _ <- validateRelatedNames lineNo st "opaque.all" (rawOpaqueAllIds rawOpaque)
  _ <- pure (rawOpaqueIsUnsafe rawOpaque)
  opaqueValue <- requiredExprPayloadRefById lineNo st (rawOpaqueValueId rawOpaque)
  pure OpaqueVal {opaqueConst = opaqueConst, opaqueValue = opaqueValue}

lowerRawQuot :: Int -> ExportState -> RawQuotVal -> Either String (QuotVal HCExpr HCLevel)
lowerRawQuot lineNo st rawQuot = do
  quotConst <- lowerRawConstant lineNo st (rawQuotConst rawQuot)
  pure QuotVal {quotConst = quotConst, quotKind = rawQuotKind rawQuot}

lowerRawInductiveGroup :: Int -> ExportState -> RawInductiveGroup -> Either String (InductiveDecl HCExpr HCLevel)
lowerRawInductiveGroup lineNo st rawGroup = do
  ctorVals <- traverse (lowerRawConstructor lineNo st) (rawGroupCtors rawGroup)
  recVals <- traverse (lowerRawRecursor lineNo st) (rawGroupRecs rawGroup)
  indVals <- traverse (lowerRawInductive lineNo st ctorVals) (rawGroupTypes rawGroup)
  validateInductiveBlock lineNo indVals ctorVals
  pure InductiveDecl {indTypes = indVals, indConstructors = ctorVals, indRecursors = recVals}

lowerRawInductive :: Int -> ExportState -> [ConstructorVal HCExpr HCLevel] -> RawInductiveVal -> Either String (InductiveVal HCExpr HCLevel)
lowerRawInductive lineNo st ctorVals rawInd = do
  indConst <- lowerRawConstant lineNo st (rawIndConst rawInd)
  _ <- validateRelatedNames lineNo st "inductive.all" (rawIndAllIds rawInd)
  _ <- pure (rawIndNumNested rawInd, rawIndIsRec rawInd, rawIndIsUnsafe rawInd, rawIndIsReflexive rawInd)
  ctorNames <- traverse (resolveName lineNo st) (rawIndCtorIds rawInd)
  let indexedCtors = sortOn ctorIndex (filter ((`elem` ctorNames) . constName . ctorConst) ctorVals)
      matchedCtorNames = fmap (constName . ctorConst) indexedCtors
      missingCtorNames = filter (`notElem` matchedCtorNames) ctorNames
      wrongInductiveCtors = mapMaybe (constructorInductiveMismatch (constName indConst)) indexedCtors
  unless (null missingCtorNames) $ Left $ decorate lineNo $ "inductive references missing constructors: " <> show missingCtorNames
  unless (null wrongInductiveCtors) $ Left $ decorate lineNo $ "constructors belong to unexpected inductive: " <> show wrongInductiveCtors
  let indCtors = fmap (constName . ctorConst) indexedCtors
  pure InductiveVal {indConst = indConst, indParamsN = rawIndParamsN rawInd, indIndicesN = rawIndIndicesN rawInd, indCtors = indCtors}

lowerRawConstructor :: Int -> ExportState -> RawConstructorVal -> Either String (ConstructorVal HCExpr HCLevel)
lowerRawConstructor lineNo st rawCtor = do
  ctorConst <- lowerRawConstant lineNo st (rawCtorConst rawCtor)
  ctorInductive <- resolveName lineNo st (rawCtorInductiveId rawCtor)
  _ <- pure (rawCtorIsUnsafe rawCtor)
  pure ConstructorVal {ctorConst = ctorConst, ctorInductive = ctorInductive, ctorIndex = rawCtorIndex rawCtor, ctorParamsN = rawCtorParamsN rawCtor, ctorFieldsN = rawCtorFieldsN rawCtor}

lowerRawRecursor :: Int -> ExportState -> RawRecursorVal -> Either String (RecursorVal HCExpr HCLevel)
lowerRawRecursor lineNo st rawRec = do
  recConst <- lowerRawConstant lineNo st (rawRecConst rawRec)
  _ <- validateRelatedNames lineNo st "recursor.all" (rawRecAllIds rawRec)
  _ <- pure (rawRecIsUnsafe rawRec)
  recRules <- traverse (lowerRawRecursorRule lineNo st) (rawRecRules rawRec)
  pure RecursorVal {recConst = recConst, recParamsN = rawRecParamsN rawRec, recIndicesN = rawRecIndicesN rawRec, recMotivesN = rawRecMotivesN rawRec, recMinorsN = rawRecMinorsN rawRec, recKRule = rawRecKRule rawRec, recRules = recRules}

lowerRawRecursorRule :: Int -> ExportState -> RawRecursorRule -> Either String (RecursorRule HCExpr HCLevel)
lowerRawRecursorRule lineNo st rawRule = do
  recCtor <- resolveName lineNo st (rawRecRuleCtorId rawRule)
  recRhs <- requiredExprPayloadRefById lineNo st (rawRecRuleRhsId rawRule)
  pure RecursorRule {recCtor = recCtor, recFieldsN = rawRecRuleFieldsN rawRule, recRhs = recRhs}

lowerRawConstant :: Int -> ExportState -> RawConstant -> Either String (ConstantVal HCExpr HCLevel)
lowerRawConstant lineNo st rawConst = do
  constName <- resolveName lineNo st (rawConstNameId rawConst)
  constLevelParameters <- traverse (resolveName lineNo st) (rawConstLevelParamIds rawConst)
  constType <- requiredExprPayloadRefById lineNo st (rawConstTypeId rawConst)
  pure ConstantVal {constName = constName, constLevelParameters = constLevelParameters, constType = constType}

validateRelatedNames :: Int -> ExportState -> String -> [HCId] -> Either String [HCName]
validateRelatedNames lineNo st _ = traverse (resolveName lineNo st)

requiredExprPayloadRefById :: Int -> ExportState -> HCId -> Either String (Expr' HCExpr HCLevel HCName)
requiredExprPayloadRefById lineNo st exprId = hceVal <$> resolveExpr lineNo st exprId

registerDeclaration :: Int -> ExportState -> Decl HCExpr HCLevel -> Either String ExportState
registerDeclaration lineNo st decl =
  foldM registerOne st (declNames decl)
  where
    registerOne acc name =
      if Set.member name (stDeclNames acc)
        then Left $ decorate lineNo ("duplicate declaration: " <> show name)
        else pure acc {stDeclNames = Set.insert name (stDeclNames acc)}

validateInductiveBlock :: Int -> [InductiveVal HCExpr HCLevel] -> [ConstructorVal HCExpr HCLevel] -> Either String ()
validateInductiveBlock lineNo indVals ctorVals = do
  let indNames = fmap (constName . indConst) indVals
      strayCtors = [constName (ctorConst ctor) | ctor <- ctorVals, ctorInductive ctor `notElem` indNames]
  unless (null strayCtors) $ Left (decorate lineNo ("inductive block contains constructors for unknown inductives: " <> show strayCtors))

constructorInductiveMismatch :: HCName -> ConstructorVal HCExpr HCLevel -> Maybe HCName
constructorInductiveMismatch expected ctor
  | ctorInductive ctor == expected = Nothing
  | otherwise = Just (constName (ctorConst ctor))

requiredHints :: Int -> Object -> Either String ReducibilityHints
requiredHints lineNo obj = do
  value <- requiredField obj "hints"
  case value of
    String "opaque" -> pure Opaque
    String "abbrev" -> pure Abbrev
    Object payload -> case optionalField payload "regular" of
      Just regularValue -> Regular <$> parseInt (fieldContext lineNo "hints.regular") regularValue
      Nothing -> Left (decorate lineNo "unsupported hints object")
    _ -> Left (decorate lineNo "invalid definition hints")

requiredSafety :: Int -> Object -> Either String SupportedSafety
requiredSafety lineNo obj = do
  txt <- requiredText lineNo "safety" obj
  case txt of
    "safe" -> pure SafeSafety
    "unsafe" -> pure UnsafeSafety
    "partial" -> pure PartialSafety
    _ -> Left (decorate lineNo ("unsupported safety value '" <> Text.unpack txt <> "'"))

requiredQuotKind :: Int -> Object -> Either String QuotKind
requiredQuotKind lineNo obj = do
  txt <- requiredText lineNo "kind" obj
  case txt of
    "type" -> pure Quot
    "ctor" -> pure QuotMk
    "lift" -> pure QuotLift
    "ind" -> pure QuotInd
    _ -> Left (decorate lineNo ("unsupported quot kind '" <> Text.unpack txt <> "'"))

requiredBinderInfo :: Int -> String -> Object -> Either String BinderInfo
requiredBinderInfo lineNo label obj = do
  txt <- requiredTextObj lineNo label "binderInfo" obj
  case txt of
    "default" -> pure Default
    "implicit" -> pure Implicit
    "strictImplicit" -> pure StrictImplicit
    "instImplicit" -> pure InstImplicit
    _ -> Left (decorate lineNo ("unsupported binder info '" <> Text.unpack txt <> "'"))

requiredIntPair :: Int -> Text -> Object -> Either String (Int, Int)
requiredIntPair lineNo field obj = do
  values <- requiredIntArray lineNo field obj
  case values of
    [lhs, rhs] -> pure (lhs, rhs)
    _ -> Left (decorate lineNo ("field '" <> Text.unpack field <> "' must contain exactly two integers"))

requiredNatLikeInt :: Int -> Text -> Object -> Either String Int
requiredNatLikeInt lineNo field obj = do
  value <- requiredField obj field
  natValue <- case value of
    String txt ->
      case reads (Text.unpack txt) of
        [(n, "")] -> pure n
        _ -> Left (decorate lineNo ("field '" <> Text.unpack field <> "' must be an integer string"))
    _ -> parseInt (fieldContext lineNo field) value
  if natValue < 0
    then Left (decorate lineNo ("field '" <> Text.unpack field <> "' must be non-negative"))
    else pure natValue

requiredInt :: Int -> Text -> Object -> Either String Int
requiredInt lineNo field obj = parseInt (fieldContext lineNo field) =<< requiredField obj field

requiredIntObj :: Int -> String -> Text -> Object -> Either String Int
requiredIntObj lineNo label field obj = parseInt (decorate lineNo ("field '" <> label <> "'")) =<< requiredField obj field

requiredNat :: Int -> Text -> Object -> Either String Int
requiredNat lineNo field obj = do
  value <- requiredInt lineNo field obj
  if value < 0
    then Left (decorate lineNo ("field '" <> Text.unpack field <> "' must be non-negative"))
    else pure value

requiredNatObj :: Int -> String -> Text -> Object -> Either String Int
requiredNatObj lineNo label field obj = do
  value <- requiredIntObj lineNo label field obj
  if value < 0
    then Left (decorate lineNo ("field '" <> label <> "' must be non-negative"))
    else pure value

requiredText :: Int -> Text -> Object -> Either String Text
requiredText lineNo field obj = parseText (fieldContext lineNo field) =<< requiredField obj field

requiredBool :: Int -> Text -> Object -> Either String Bool
requiredBool lineNo field obj = parseBool (fieldContext lineNo field) =<< requiredField obj field

requiredTextObj :: Int -> String -> Text -> Object -> Either String Text
requiredTextObj lineNo label field obj = parseText (decorate lineNo ("field '" <> label <> "'")) =<< requiredField obj field

requiredIntArray :: Int -> Text -> Object -> Either String [Int]
requiredIntArray lineNo field obj = requiredIntArrayObj lineNo (fieldContextLabel field) field obj

requiredIntArrayObj :: Int -> String -> Text -> Object -> Either String [Int]
requiredIntArrayObj lineNo label field obj = do
  values <- expectValueArray (decorate lineNo ("field '" <> label <> "' must be an array")) =<< requiredField obj field
  traverse (parseInt (decorate lineNo ("field '" <> label <> "' element"))) values

requiredValueArray :: Int -> Text -> Object -> Either String [Value]
requiredValueArray lineNo field obj = expectValueArray (fieldContext lineNo field <> " must be an array") =<< requiredField obj field

requiredField :: Object -> Text -> Either String Value
requiredField obj field =
  maybe (Left ("missing field '" <> Text.unpack field <> "'")) Right (optionalField obj field)

optionalField :: Object -> Text -> Maybe Value
optionalField obj field = KeyMap.lookup (fromText field) obj

hasKey :: Text -> Object -> Bool
hasKey field = KeyMap.member (fromText field)

selectAliasArray :: Int -> String -> [Text] -> Object -> Either String [Value]
selectAliasArray lineNo label aliases obj =
  case filter (\field -> hasKey field obj) aliases of
    [] -> Left (decorate lineNo ("missing one of fields: " <> commaList aliases))
    [field] -> expectValueArray (decorate lineNo ("field '" <> Text.unpack field <> "' must be an array")) =<< requiredField obj field
    present -> Left (decorate lineNo ("multiple aliases provided for " <> label <> ": " <> commaList present))

expectObject :: String -> Value -> Either String Object
expectObject label = \case
  Object obj -> pure obj
  other -> Left (label <> " must be an object, found " <> valueType other)

expectValueArray :: String -> Value -> Either String [Value]
expectValueArray label = \case
  Array values -> pure (Vector.toList values)
  other -> Left (label <> ", found " <> valueType other)

parseInt :: String -> Value -> Either String Int
parseInt label = \case
  Number n -> maybe (Left (label <> " must be a bounded integer")) Right (toBoundedInteger n)
  other -> Left (label <> " must be a number, found " <> valueType other)

parseText :: String -> Value -> Either String Text
parseText label = \case
  String txt -> pure txt
  other -> Left (label <> " must be a string, found " <> valueType other)

parseBool :: String -> Value -> Either String Bool
parseBool label = \case
  Bool b -> pure b
  other -> Left (label <> " must be a boolean, found " <> valueType other)

valueType :: Value -> String
valueType = \case
  Object _ -> "object"
  Array _ -> "array"
  String _ -> "string"
  Number _ -> "number"
  Bool _ -> "boolean"
  Null -> "null"

topLevelKeys :: Object -> [Text]
topLevelKeys = fmap keyToText . KeyMap.keys

keyToText :: Key -> Text
keyToText = toText

ensureExactTopLevelKeys :: Int -> [Text] -> Object -> Either String ()
ensureExactTopLevelKeys lineNo requiredUniverse obj = do
  let keys = topLevelKeys obj
      matchingKeys = filter (`elem` requiredUniverse) keys
  case requiredIndexKey requiredUniverse of
    Just indexKey -> do
      unless (indexKey `elem` keys) $ Left (decorate lineNo ("missing field '" <> Text.unpack indexKey <> "'"))
      when (length matchingKeys /= 2 || length keys /= 2) $ Left (decorate lineNo ("unexpected top-level keys: " <> commaList keys))
    Nothing ->
      when (keys /= ["meta"]) $ Left (decorate lineNo ("unexpected top-level keys: " <> commaList keys))

requiredIndexKey :: [Text] -> Maybe Text
requiredIndexKey fields
  | "in" `elem` fields = Just "in"
  | "il" `elem` fields = Just "il"
  | "ie" `elem` fields = Just "ie"
  | otherwise = Nothing

ensureDeclarationTopLevelKeys :: Int -> Object -> Either String ()
ensureDeclarationTopLevelKeys lineNo obj = do
  let keys = topLevelKeys obj
      declKeys = filter (`elem` ["axiom", "def", "thm", "opaque", "quot", "constructor", "recursor", "inductive"]) keys
  when (length declKeys /= 1 || length keys /= 1) $ Left (decorate lineNo ("unexpected top-level keys: " <> commaList keys))

ensureExactObjectFields :: Int -> String -> [Text] -> Object -> Either String ()
ensureExactObjectFields lineNo label requiredFields obj = do
  let keys = topLevelKeys obj
      missingFields = filter (`notElem` keys) requiredFields
      extraFields = filter (`notElem` requiredFields) keys
  case missingFields of
    missingField : _ -> Left (decorate lineNo ("missing field '" <> Text.unpack missingField <> "'"))
    [] -> pure ()
  unless (null extraFields) $ Left (decorate lineNo ("unexpected keys in " <> label <> ": " <> commaList extraFields))

ensureAllowedObjectKeys :: Int -> String -> [Text] -> Object -> Either String ()
ensureAllowedObjectKeys lineNo label allowedFields obj = do
  let extraFields = filter (`notElem` allowedFields) (topLevelKeys obj)
  unless (null extraFields) $ Left (decorate lineNo ("unexpected keys in " <> label <> ": " <> commaList extraFields))

resolveName :: Int -> ExportState -> HCId -> Either String HCName
resolveName _ st 0 =
  maybe (Left "missing anonymous name") Right (evalIntern (lookupNameId 0) (stInternState st))
resolveName lineNo st ident =
  maybe (Left (decorate lineNo ("unknown name id " <> show ident))) Right (evalIntern (lookupNameId ident) (stInternState st))

resolveLevel :: Int -> ExportState -> HCId -> Either String HCLevel
resolveLevel lineNo st ident =
  maybe (Left (decorate lineNo ("unknown level id " <> show ident))) Right (evalIntern (lookupLevelId ident) (stInternState st))

resolveExpr :: Int -> ExportState -> HCId -> Either String HCExpr
resolveExpr lineNo st ident =
  maybe (Left (decorate lineNo ("unknown expr id " <> show ident))) Right (evalIntern (lookupExprId ident) (stInternState st))

context :: Int -> String
context lineNo = decorate lineNo "record"

fieldContext :: Int -> Text -> String
fieldContext lineNo field = decorate lineNo ("field '" <> Text.unpack field <> "'")

fieldContextLabel :: Text -> String
fieldContextLabel = Text.unpack

decorate :: Int -> String -> String
decorate lineNo message = "line " <> show lineNo <> ": " <> message

commaList :: [Text] -> String
commaList = Text.unpack . Text.intercalate ", "
