module Mlkih.Kernel.Cache
  ( mkClosedDefEqKey,
    withClosedDefEqCache,
  )
where

import Control.Monad.Error.Class
import Control.Monad.State.Strict
import qualified Data.Map.Strict as Map
import Mlkih.AST
import Mlkih.Expr
import Mlkih.Kernel.Monad (finallyM)
import Mlkih.Kernel.Trace
import Mlkih.Kernel.Types

orderedClosedDefEqKey :: HCExpr -> HCExpr -> ClosedDefEqKey
orderedClosedDefEqKey e1 e2 =
  let id1 = hceId e1
      id2 = hceId e2
   in if id1 <= id2
        then ClosedDefEqKey (id1, id2)
        else ClosedDefEqKey (id2, id1)

mkClosedDefEqKey :: HCExpr -> HCExpr -> Maybe ClosedDefEqKey
mkClosedDefEqKey e1 e2
  | hasLooseBVar e1 = Nothing
  | hasLooseBVar e2 = Nothing
  | otherwise = Just (orderedClosedDefEqKey e1 e2)

withClosedDefEqCache ::
  HCExpr ->
  HCExpr ->
  KernelM Bool ->
  KernelM Bool
withClosedDefEqCache e1 e2 compute =
  case mkClosedDefEqKey e1 e2 of
    Nothing -> do
      traceNoProgress
        PhDefEq
        TkLookup
        TraceDetail
        "defeq.cache.skip"
        [ ("reason", TrString "open-expression"),
          ("lhs", TrExpr e1),
          ("rhs", TrExpr e2)
        ]
      compute
    Just key -> do
      cached <- gets (Map.lookup key . checkClosedDefEqCache)
      case cached of
        Just result -> do
          traceOk
            PhDefEq
            TkLookup
            TraceDetail
            "defeq.cache.hit"
            [ ("result", TrBool result),
              ("lhs", TrExpr e1),
              ("rhs", TrExpr e2)
            ]
          pure result
        Nothing -> do
          active <- elem key <$> gets checkClosedDefEqActive
          if active
            then do
              traceFail
                PhDefEq
                TkLookup
                TraceSummary
                "defeq.cache.cycle"
                [ ("lhs", TrExpr e1),
                  ("rhs", TrExpr e2)
                ]
              throwError "cyclic closed defeq comparison"
            else do
              let push =
                    modify' $ \s ->
                      s {checkClosedDefEqActive = key : checkClosedDefEqActive s}

                  pop =
                    modify' $ \s ->
                      s
                        { checkClosedDefEqActive =
                            filter (/= key) (checkClosedDefEqActive s)
                        }

              push
              result <- compute `finallyM` pop

              modify' $ \s ->
                s
                  { checkClosedDefEqCache =
                      Map.insert key result (checkClosedDefEqCache s)
                  }

              traceEvent
                PhDefEq
                TkLookup
                TraceDetail
                "defeq.cache.store"
                [ ("result", TrBool result),
                  ("lhs", TrExpr e1),
                  ("rhs", TrExpr e2)
                ]

              pure result
