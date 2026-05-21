module Mlkih.Kernel.Trace
  ( TraceConfig (..),
    TraceVerbosity (..),
    TracePhase (..),
    TraceKind (..),
    TraceOutcome (..),
    TraceFieldValue (..),
    TraceField,
    TraceEvent (..),
    TraceNode (..),
    withTraceConfig,
    withTraceVerbosity,
    withTracePhases,
    withTraceKinds,
    withTraceConstants,
    withFullTrace,
    printKernelTrace,
    traceEvent,
    traceOk,
    traceFail,
    traceStuck,
    traceProgress,
    traceNoProgress,
    traceBlock,
    defaultTraceConfig,
    maxTraceConfig,
    renderKernelTrace,
  )
where

import Control.Monad (when)
import Control.Monad.Error.Class
import Control.Monad.Reader.Class
import Control.Monad.State.Strict
import Mlkih.Kernel.Types
import Mlkih.Name
import Mlkih.Pretty
import System.IO

defaultTraceConfig :: TraceConfig
defaultTraceConfig =
  TraceConfig
    { traceVerbosity = TraceOff,
      tracePhases = Nothing,
      traceKinds = Nothing,
      traceOutcomes = Nothing,
      traceConstants = Nothing,
      traceStream = False
    }

maxTraceConfig :: TraceConfig
maxTraceConfig =
  TraceConfig
    { traceVerbosity = TraceDump,
      tracePhases = Nothing,
      traceKinds = Nothing,
      traceOutcomes = Nothing,
      traceConstants = Nothing,
      traceStream = False
    }

matchesMaybe :: (Eq a) => Maybe [a] -> a -> Bool
matchesMaybe Nothing _ = True
matchesMaybe (Just xs) x = x `elem` xs

matchesOutcome :: Maybe [TraceOutcome] -> Maybe TraceOutcome -> Bool
matchesOutcome Nothing _ = True
matchesOutcome (Just _) Nothing = True
matchesOutcome (Just xs) (Just x) = x `elem` xs

traceFieldNames :: TraceFieldValue -> [HCName]
traceFieldNames field =
  case field of
    TrName n -> [n]
    TrHead h -> traceHeadNames h
    TrValueHead v -> traceValueHeadNames v
    TrValue v -> traceValueHeadNames v
    TrElim e -> traceElimNames e
    TrSpine sp -> concatMap traceElimNames sp
    _ -> []

traceHeadNames :: Head -> [HCName]
traceHeadNames h =
  case h of
    HLvl n _ -> [n]
    HConst n _ -> [n]

traceElimNames :: Elim -> [HCName]
traceElimNames e =
  case e of
    EApp v -> traceValueHeadNames v
    EProj n _ -> [n]

traceValueHeadNames :: Value -> [HCName]
traceValueHeadNames v =
  case v of
    VSort {} -> []
    VLit {} -> []
    VLam n _ _ _ -> [n]
    VPi n _ _ _ -> [n]
    VNeutral h _ -> traceHeadNames h
    VDef n _ _ -> [n]

matchesConstants :: Maybe [HCName] -> TraceEvent -> Bool
matchesConstants Nothing _ = True
matchesConstants (Just wanted) ev =
  let present = concatMap (traceFieldNames . snd) (traceFields ev)
   in any (`elem` wanted) present

shouldTraceEvent :: TraceEvent -> KernelM Bool
shouldTraceEvent ev = do
  cfg <- asks checkTraceConfig
  pure $
    traceVerbosity cfg /= TraceOff
      && traceEventVerbosity ev /= TraceOff
      && traceEventVerbosity ev <= traceVerbosity cfg
      && matchesMaybe (tracePhases cfg) (tracePhase ev)
      && matchesMaybe (traceKinds cfg) (traceKind ev)
      && matchesOutcome (traceOutcomes cfg) (traceOutcome ev)
      && matchesConstants (traceConstants cfg) ev

mkTraceEvent ::
  TracePhase ->
  TraceKind ->
  TraceVerbosity ->
  String ->
  [TraceField] ->
  Maybe TraceOutcome ->
  TraceEvent
mkTraceEvent phase kind verb label fields outcome =
  TraceEvent
    { tracePhase = phase,
      traceKind = kind,
      traceEventVerbosity = verb,
      traceOutcome = outcome,
      traceLabel = label,
      traceFields = fields
    }

appendTraceNode :: TraceNode -> KernelM ()
appendTraceNode node =
  modify' $ \s ->
    case checkTraceStack s of
      current : rest ->
        s {checkTraceStack = (current ++ [node]) : rest}
      [] ->
        s {checkTraceStack = [[node]]}

pushTraceFrame :: KernelM ()
pushTraceFrame =
  modify' $ \s -> s {checkTraceStack = [] : checkTraceStack s}

popTraceBlock :: TraceEvent -> KernelM ()
popTraceBlock ev =
  modify' $ \s ->
    case checkTraceStack s of
      completed : parent : rest ->
        let block = TraceBlock ev completed
         in s {checkTraceStack = (parent ++ [block]) : rest}
      [completed] ->
        s {checkTraceStack = [[TraceBlock ev completed]]}
      [] ->
        s {checkTraceStack = [[TraceBlock ev []]]}

traceEmit :: TraceEvent -> KernelM ()
traceEmit ev = do
  active <- shouldTraceEvent ev
  when active $ do
    appendTraceNode (TraceLeaf ev)
    stream <- asks (traceStream . checkTraceConfig)
    liftIO $ when stream $ do
      hPutStrLn stderr (renderPlain . ppr $ TraceLeaf ev)
      hFlush stderr

traceEvent ::
  TracePhase ->
  TraceKind ->
  TraceVerbosity ->
  String ->
  [TraceField] ->
  KernelM ()
traceEvent phase kind verb label fields =
  traceEmit (mkTraceEvent phase kind verb label fields Nothing)

traceOk ::
  TracePhase ->
  TraceKind ->
  TraceVerbosity ->
  String ->
  [TraceField] ->
  KernelM ()
traceOk phase kind verb label fields =
  traceEmit (mkTraceEvent phase kind verb label fields (Just OutOk))

traceFail ::
  TracePhase ->
  TraceKind ->
  TraceVerbosity ->
  String ->
  [TraceField] ->
  KernelM ()
traceFail phase kind verb label fields =
  traceEmit (mkTraceEvent phase kind verb label fields (Just OutFail))

traceStuck ::
  TracePhase ->
  TraceKind ->
  TraceVerbosity ->
  String ->
  [TraceField] ->
  KernelM ()
traceStuck phase kind verb label fields =
  traceEmit (mkTraceEvent phase kind verb label fields (Just OutStuck))

traceProgress ::
  TracePhase ->
  TraceKind ->
  TraceVerbosity ->
  String ->
  [TraceField] ->
  KernelM ()
traceProgress phase kind verb label fields =
  traceEmit (mkTraceEvent phase kind verb label fields (Just OutProgress))

traceNoProgress ::
  TracePhase ->
  TraceKind ->
  TraceVerbosity ->
  String ->
  [TraceField] ->
  KernelM ()
traceNoProgress phase kind verb label fields =
  traceEmit (mkTraceEvent phase kind verb label fields (Just OutNoProgress))

traceBlock ::
  TracePhase ->
  TraceKind ->
  TraceVerbosity ->
  String ->
  [TraceField] ->
  KernelM a ->
  KernelM a
traceBlock phase kind verb label fields action = do
  let ev0 = mkTraceEvent phase kind verb label fields Nothing
  active <- shouldTraceEvent ev0
  if not active
    then action
    else do
      pushTraceFrame
      catchError
        ( do
            r <- action
            let evOk = ev0 {traceOutcome = Just OutOk}
            popTraceBlock evOk
            pure r
        )
        ( \err -> do
            let errEv =
                  mkTraceEvent
                    phase
                    TkError
                    TraceSummary
                    "error"
                    [("message", TrString err)]
                    (Just OutFail)
            appendTraceNode (TraceLeaf errEv)
            let evFail = ev0 {traceOutcome = Just OutFail}
            popTraceBlock evFail
            throwError err
        )

renderKernelTrace :: KernelState -> Doc
renderKernelTrace st =
  case checkTraceStack st of
    [] -> ppr "No trace generated."
    [topLevel] -> vsep (map ppr topLevel)
    malformedStack ->
      ppr "Warning: Malformed trace stack."
        <> line
        <> vsep (map ppr (concat (reverse malformedStack)))

withTraceConfig :: TraceConfig -> KernelM a -> KernelM a
withTraceConfig cfg =
  local (\ctx -> ctx {checkTraceConfig = cfg})

withTraceVerbosity :: TraceVerbosity -> KernelM a -> KernelM a
withTraceVerbosity verb =
  local
    ( \ctx ->
        let cfg = checkTraceConfig ctx
         in ctx {checkTraceConfig = cfg {traceVerbosity = verb}}
    )

withTracePhases :: [TracePhase] -> KernelM a -> KernelM a
withTracePhases phases =
  local
    ( \ctx ->
        let cfg = checkTraceConfig ctx
         in ctx {checkTraceConfig = cfg {tracePhases = Just phases}}
    )

withTraceKinds :: [TraceKind] -> KernelM a -> KernelM a
withTraceKinds kinds =
  local
    ( \ctx ->
        let cfg = checkTraceConfig ctx
         in ctx {checkTraceConfig = cfg {traceKinds = Just kinds}}
    )

withTraceConstants :: [HCName] -> KernelM a -> KernelM a
withTraceConstants names =
  local
    ( \ctx ->
        let cfg = checkTraceConfig ctx
         in ctx {checkTraceConfig = cfg {traceConstants = Just names}}
    )

withFullTrace :: KernelM a -> KernelM a
withFullTrace = withTraceConfig maxTraceConfig

printKernelTrace :: KernelState -> IO ()
printKernelTrace st = do
  putStrLn "\n================ KERNEL TRACE ================"
  putStrLn $ toString (renderKernelTrace st)
  putStrLn "==============================================\n"
