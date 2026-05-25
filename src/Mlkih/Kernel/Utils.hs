{-# LANGUAGE OverloadedStrings #-}

module Mlkih.Kernel.Utils where

import Control.Monad (when)
import Control.Monad.Error.Class
import Mlkih.Env
import Mlkih.Expr
import Mlkih.Intern
import Mlkih.Kernel.Monad
import Mlkih.Kernel.Trace
import Mlkih.Kernel.Types
import Mlkih.Level
import Mlkih.Name

--------------------------------------------------------------------------------

expectApp :: String -> Elim -> KernelM Value
expectApp label elim =
  case elim of
    EApp v ->
      pure v
    EProj _ _ ->
      throwError $ label <> ": expected application elimination"

expectSingleApp :: String -> Spine -> KernelM Value
expectSingleApp label spine =
  case spine of
    [elim] ->
      expectApp label elim
    _ ->
      throwError $
        label
          <> ": expected singleton application spine, got "
          <> show (length spine)

-- | Index into a stored reversed spine and require an application elimination.
-- For @f a b c@, the stored spine is @[c, b, a]@, so index 0 corresponds to the argument @c@.
indexRevSpineApp :: String -> Int -> Spine -> KernelM Value
indexRevSpineApp label idx spine
  | idx < 0 =
      throwError $ label <> ": negative reversed-spine index"
  | otherwise =
      case drop idx spine of
        elim : _ ->
          expectApp label elim
        [] ->
          throwError $
            label
              <> ": reversed-spine index out of bounds: "
              <> show idx

-- | Convert a reversed spine segment of application eliminations into values in forward application order.
-- For example, @[EApp c, EApp b, EApp a]@ becomes @[a, b, c]@.
-- Useful for instantiating telescopes, as binders are consumed in forward order.
appValuesForward :: String -> Spine -> KernelM [Value]
appValuesForward label spineRev = mapM (expectApp label) (reverse spineRev)

--------------------------------------------------------------------------------

-- | A parsed recursor application spine.
-- Recursor applications are written in forward order as: @rec params motives minors indices major extra...@.
-- Since stored spines are reversed, after pushing the new elim, the spine is built up as
--  @extraRev ++ [major] ++ indicesRev ++ minorsRev ++ motivesRev ++ paramsRev@.
data RecursorAppSpine = RecursorAppSpine
  { recExtraRev :: Spine,
    recMajor :: Value,
    recIndicesRev :: Spine,
    recMinorsRev :: Spine,
    recMotivesRev :: Spine,
    recParamsRev :: Spine
  }
  deriving (Show)

-- | Arguments applied to a recursor rule RHS before constructor fields.
-- The spine returned is in reverse order.
recRuleArgsRev :: RecursorAppSpine -> Spine
recRuleArgsRev args =
  recMinorsRev args <> recMotivesRev args <> recParamsRev args

-- | Split a stored recursor spine into named layout pieces.
splitRecursorAppSpine ::
  RecursorVal HCExpr HCLevel ->
  Spine ->
  KernelM RecursorAppSpine
splitRecursorAppSpine recVal spineRev =
  traceBlock
    PhReduce
    TkSpine
    TraceDetail
    "spine.split.recursor"
    [ ("expected", TrInt expected),
      ("actual", TrInt (length spineRev)),
      ("params", TrInt (recParamsN recVal)),
      ("motives", TrInt (recMotivesN recVal)),
      ("minors", TrInt (recMinorsN recVal)),
      ("indices", TrInt (recIndicesN recVal))
    ]
    $ do
      when (length spineRev < expected) $
        throwError "splitRecursorAppSpine: not enough arguments"

      let extraN = length spineRev - expected
          (extraRev, exactRev0) = splitAt extraN spineRev

          -- exactRev0 = [major] ++ indicesRev ++ minorsRev ++ motivesRev ++ paramsRev
          (majorRev, rest1) = splitAt 1 exactRev0
          (indicesRev, rest2) = splitAt (recIndicesN recVal) rest1
          (minorsRev, rest3) = splitAt (recMinorsN recVal) rest2
          (motivesRev, paramsRev) = splitAt (recMotivesN recVal) rest3

      when (length paramsRev /= recParamsN recVal) $
        throwError "splitRecursorAppSpine: malformed parameter segment"

      major <- expectSingleApp "recursor.major" majorRev

      pure
        RecursorAppSpine
          { recExtraRev = extraRev,
            recMajor = major,
            recIndicesRev = indicesRev,
            recMinorsRev = minorsRev,
            recMotivesRev = motivesRev,
            recParamsRev = paramsRev
          }
  where
    expected = recursorExpectedArgs recVal

-- | Extract the unique minor premise expected by a K-rule recursor.
recursorSingleMinor ::
  RecursorVal HCExpr HCLevel ->
  RecursorAppSpine ->
  KernelM Value
recursorSingleMinor recVal args =
  case recMinorsRev args of
    [minor]
      | recMinorsN recVal == 1 ->
          expectApp "recursor.singleMinor" minor
    _ ->
      throwError "recursorSingleMinor: expected exactly one minor"

--------------------------------------------------------------------------------

-- | A parsed inductive type application spine.
-- Inductive type application in forward order is as: @I params indices@,
-- so the stored spine is: @indicesRev ++ paramsRev@.
--
-- Projection typing must feed only params to the constructor telescope, excluding indices.
data InductiveAppSpine = InductiveAppSpine
  { indIndicesRevPart :: Spine,
    indParamsRevPart :: Spine
  }
  deriving (Show)

-- | Split the stored spine of an inductive type application.
splitInductiveAppSpine ::
  InductiveVal HCExpr HCLevel ->
  Spine ->
  KernelM InductiveAppSpine
splitInductiveAppSpine indVal spineRev =
  traceBlock
    PhReduce
    TkSpine
    TraceDetail
    "spine.split.inductive"
    [ ("params", TrInt (indParamsN indVal)),
      ("indices", TrInt (indIndicesN indVal)),
      ("actual", TrInt (length spineRev))
    ]
    $ do
      let expected = indParamsN indVal + indIndicesN indVal

      when (length spineRev /= expected) $
        throwError $
          "splitInductiveAppSpine: expected "
            <> show expected
            <> " arguments, got "
            <> show (length spineRev)

      let (indicesRev, paramsRev) =
            splitAt (indIndicesN indVal) spineRev

      pure
        InductiveAppSpine
          { indIndicesRevPart = indicesRev,
            indParamsRevPart = paramsRev
          }

-- | Return inductive parameters in forward order.
-- Useful in instantiating constructor telescopes.
inductiveParamValuesForward ::
  InductiveVal HCExpr HCLevel ->
  Spine ->
  KernelM [Value]
inductiveParamValuesForward indVal spineRev = do
  parts <- splitInductiveAppSpine indVal spineRev
  appValuesForward "inductive.params" (indParamsRevPart parts)

-- | Return inductive indices in forward order.
-- Useful for K-rule index comparison.
inductiveIndexValuesForward ::
  InductiveVal HCExpr HCLevel ->
  Spine ->
  KernelM [Value]
inductiveIndexValuesForward indVal spineRev = do
  parts <- splitInductiveAppSpine indVal spineRev
  appValuesForward "inductive.indices" (indIndicesRevPart parts)

--------------------------------------------------------------------------------

-- | A parsed constructor application spine.
-- Constructor application in forward order is as: @C params fields@,
-- so the stored spine is: @fieldsRev ++ paramsRev@.
data ConstructorAppSpine = ConstructorAppSpine
  { ctorFieldsRevPart :: Spine,
    ctorParamsRevPart :: Spine
  }
  deriving (Show)

-- | Split off the first @fieldsN@ entries from a constructor spine.
-- Useful for recursor rules because the recursor rule says how many fields it consumes.
splitConstructorFieldsRev ::
  String ->
  Int ->
  Spine ->
  KernelM (Spine, Spine)
splitConstructorFieldsRev label fieldsN spineRev = do
  when (length spineRev < fieldsN) $
    throwError $
      label <> ": constructor spine has fewer fields than expected"
  pure (splitAt fieldsN spineRev)

-- | Split a constructor application spine using constructor metadata.
splitConstructorAppSpine ::
  ConstructorVal HCExpr HCLevel ->
  Spine ->
  KernelM ConstructorAppSpine
splitConstructorAppSpine ctorVal spineRev =
  traceBlock
    PhReduce
    TkSpine
    TraceDetail
    "spine.split.constructor"
    [ ("fields", TrInt (ctorFieldsN ctorVal)),
      ("params", TrInt (ctorParamsN ctorVal)),
      ("actual", TrInt (length spineRev))
    ]
    $ do
      let expected = ctorFieldsN ctorVal + ctorParamsN ctorVal

      when (length spineRev /= expected) $
        throwError $
          "splitConstructorAppSpine: expected "
            <> show expected
            <> " arguments, got "
            <> show (length spineRev)

      let (fieldsRev, paramsRev) = splitAt (ctorFieldsN ctorVal) spineRev

      pure
        ConstructorAppSpine
          { ctorFieldsRevPart = fieldsRev,
            ctorParamsRevPart = paramsRev
          }

-- | Extract a constructor field by forward field index.
-- Projection indices are forward field indices: @field 0, field 1, ..., field n-1@,
-- but constructor fields are stored in reverse order: @field n-1, field n-2, ..., field 1, field 0@.
-- So field @i@ corresponds to index @fieldsN - 1 - i@ in the stored spine.
constructorFieldValue ::
  Int ->
  ConstructorAppSpine ->
  KernelM Value
constructorFieldValue fieldIdx parts = do
  let fieldsRev = ctorFieldsRevPart parts
      fieldsN = length fieldsRev
      targetRevIdx = fieldsN - 1 - fieldIdx

  when (fieldIdx < 0 || fieldIdx >= fieldsN) $
    throwError $
      "constructorFieldValue: field index out of bounds: "
        <> show fieldIdx

  indexRevSpineApp "constructor.field" targetRevIdx fieldsRev

-- | Extract the constructor fields consumed by a recursor rule.
constructorFieldsForRecursor ::
  RecursorRule HCExpr HCLevel ->
  Spine ->
  KernelM Spine
constructorFieldsForRecursor rule ctorSpineRev = do
  let fieldsN = recFieldsN rule
  (fieldsRev, _) <-
    splitConstructorFieldsRev "recursor.constructorFields" fieldsN ctorSpineRev
  pure fieldsRev

matchBinRev :: Spine -> Maybe (Value, Value, Spine)
matchBinRev spineRev =
  case spineRev of
    EApp y : EApp x : extraRev -> Just (x, y, extraRev)
    _ -> Nothing

mkBoolValue :: Bool -> KernelM Value
mkBoolValue b = do
  boolName <-
    withIntern $
      internName $
        Name $
          (Str (simpleName "Bool"))
            (if b then "true" else "false")
  pure (VNeutral (HConst boolName []) [])
