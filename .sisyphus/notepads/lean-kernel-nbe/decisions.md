## 2026-05-09T23:02:33Z Task: session-start
- Work session started from `.sisyphus/plans/lean-kernel-nbe.md`.
- Execution begins at Task 1: unify import-time and checker-time interning.

## 2026-05-09T23:35:00Z Task: unify-import-checker-interner
- Kept `parseExport` / `parseExportFile` backward-compatible by projecting declarations, and added `ParsedExport` plus `parseExportWithState` / `parseExportFileWithState` so checker startup can consume the parser-built `InternState` without forcing unrelated callers to change.
- Changed `runKernelM`, `evalKernelM`, and `execKernelM` to accept an explicit `InternState` and reject env/interner mismatches at bootstrap, instead of allowing imported environments to start from `emptyInternState`.
- Narrowed the old kernel-startup test to the empty-env case and added focused tests for the shared imported-id path and deterministic mismatched-interner rejection.

## 2026-05-09T23:59:00Z Task: trusted-import-boundary-support-matrix
- Kept the trusted import boundary inside `src/Mlkih/Export.hs` by introducing raw declaration records plus explicit lowering functions, avoiding churn in `Mlkih.Decl`/`Mlkih.Env` while still separating parser-facing shapes from kernel-facing declarations.
- Chose exact field validation for declaration and nested expression payloads, with targeted allowances only where the current Lean exporter contract actually needs them (notably grouped inductive alias keys and `letE.nondep`).

- 2026-05-09 Task 3 decision: model declaration unfoldability separately from raw `ReducibilityHints`. Add kernel helpers that expose (a) body-for-checking access and (b) delta-unfoldability/ordering for defs only; defer actual lazy-delta execution and same-head argument comparison to later conversion tasks.

## 2026-05-09T23:59:00Z Task: kernel-declaration-unfoldability
- Kept Task 3 classification-only by adding pure declaration helpers in  and thin lookup-based kernel wrappers in ; no unfolding, whnf, or  behavior was introduced here.
- Used the existing  payload as the stored kernel hint representation, but exposed later-consumable helper seams (, regular-height extraction, dedicated delta comparison) so future lazy-delta logic does not need to redesign declaration metadata.

## 2026-05-10T00:10:00Z Task: kernel-declaration-unfoldability-followup
- Kept Task 3 classification-only by adding pure declaration helpers in `src/Mlkih/Env.hs` and thin lookup-based kernel wrappers in `src/Mlkih/Kernel.hs`; no unfolding, whnf, or `isDefEq` behavior was introduced here.
- Used the existing `ReducibilityHints` payload as the stored kernel hint representation, but exposed later-consumable helper seams (`ReducibilityHintClass`, regular-height extraction, dedicated delta comparison) so future lazy-delta logic does not need to redesign declaration metadata.


## 2026-05-10T00:25:00Z Task: task-4-syntax-view-research
- For Task 4, prefer adding narrow reusable syntax-view helpers in `src/Mlkih/AST.hs` (app-spine split/rebuild, projection view, binder telescope helpers) over introducing a new expression datatype or pushing ad hoc decomposition into `whnf`/`isDefEq`.
- Keep projection helpers shape-oriented: return parsed views only when the head/arity/index checks succeed, and reuse existing `mkApp`/`mkApps`/`mkProj` constructors for rebuilding so interning behavior stays unchanged.

## 2026-05-10T00:40:00Z Task: task-4-syntax-helper-views
- Kept all new view types in Mlkih.AST rather than Mlkih.Expr because they are helper-layer decompositions over HCExpr, not representation changes; this preserved the existing expression constructors and kept the task scoped to structural reuse only.

- Task 5 harness guidance: use a thin Cabal-only harness with direct fixture-path helpers and stable target names instead of a meta-runner; generated positives should stay under Lean fixture generation, while malformed/negative cases stay as small checked-in fixtures.

## 2026-05-11 Task: task-5-conversion-fixture-harness
- Kept the harness deliberately thin: file-name constants plus `loadParsedExportFixture`/`expectFixtureFailureContaining`, rather than adding a fixture registry, DSL, or runtime discovery layer.
- Stored the reusable positive conversion support export and malformed negative declaration cases as flat `test/fixtures/export/*.ndjson` files so the existing Cabal `data-files` glob continues to package them without churn.

- Task 6 guidance basis: model conversion state after Lean4/nanoda decomposition: keep equality cache/union-find separate from recursion-control state; use dedicated visited-pair / congruence-failure memo and a distinct unfold-stack for recursive delta.

## 2026-05-11 Task: task-6-conversion-state-scaffolding
- Kept recursion-control state in `KernelState`, not `KernelCtx`, because visited pairs, failure memoization, and unfold stacks are operational mutable state rather than read-only environment data.
- Used dedicated helper accessors (`withVisitedExprPair`, `recordFailedExprPair`, `withUnfoldingConst`) instead of extending union-find so future defeq code can distinguish proven equality from in-progress recursion and from remembered failure.
- Limited the NbE addition to preparatory `Closure` / `Value` / `NbEState` scaffolding and avoided any whnf, lazy-delta, or `isDefEq` behavior in this task.

## 2026-05-11 Task: task-7-staged-whnf
- Kept whnf strictly no-delta for Task 7: theorem, opaque, and definition bodies are still not unfolded here, and the unfold-stack/lazy-delta machinery remains reserved for Task 8.
- Used a small NbE-flavored hook only for local lambda application via LamValue plus captured Closure rather than broadening LocalDecl with let-values or attempting full value semantics before they are needed.
- Treated projection and iota failures as explicit stuck cases by rebuilding the weak-head term only when the structure or major premise changed; malformed or undersaturated constructor shapes do not silently reduce.

## 2026-05-11 Task: task-8-lazy-delta
- Exported `LazyDeltaChoice`, `LazyDeltaStepResult`, and `lazyDeltaReductionStep` so future `isDefEq` work can consume a dedicated chooser/unfolder layer without folding delta behavior into `whnf`.
- Kept actual `OpaqueInfo` declarations non-unfoldable while still treating `DefnInfo` values with `Opaque` reducibility hints as orderable lazy-delta candidates; focused tests now cover that distinction at runtime.

## 2026-05-11 Task: task-9-staged-head-aware-isdefeq
- Inserted a same-head const-app comparison stage inside `isDefEqStaged`, after `whnf` but before lazy delta and generic structural comparison, so Task 9 stays syntax-first and head-aware without broadening `whnf` itself.
- Chose a split verdict for same-head constant mismatches: non-delta-unfoldable heads fail immediately after universe/argument comparison, while delta-unfoldable definitions return control to lazy delta instead of rejecting too early.

## 2026-05-11 Task: task-9-staged-head-aware-isDefEq
- Kept `isDefEq` as a dedicated exported dispatcher in `src/Mlkih/Kernel.hs` rather than folding any defeq-specific behavior into `whnf`, preserving the Task 7/8 layering of no-delta weak-head reduction plus separate lazy delta.
- Used the existing Task 6 state helpers (`isFailedExprPair`, `withVisitedExprPair`, `unionExprClasses`, `clearFailedExprPair`) as the only recursion/equality bookkeeping, instead of inventing a new cache or custom recursion guard for Task 9.
- Scoped the structural fallthrough to the requested conversion core only: same projection head compares structures, lambda/forall compare binder types and opened bodies under one fresh local, and generic application comparison stays args-first before function heads.

## 2026-05-11 Task: task-10-freeze-conversion-nucleus
- Kept Task 10 scoped to regression hardening by adding four focused Tasty cases in `test/Main.hs` instead of introducing new fixtures or changing `src/Mlkih/Kernel.hs`.
- Split same-head non-unfoldable negatives into separate arg-mismatch and universe-mismatch tests so each path stays easy to target with `--pattern` during later checkpoint/debug runs.
- Covered binder behavior with one compact success/failure test that exercises both lambda and forall binder opening, and covered mutual recursion with a failure-oriented `isDefEq` regression to guard conversion termination.

## 2026-05-12 Task: task-11-sequential-noninductive-checking
- Kept Task 11 scoped to non-inductive declaration checking by adding real checking for axioms/defs/theorems/opaques/quotients, while treating grouped inductive blocks as explicit trusted env-extension passthroughs instead of starting Task 12 atomic inductive handling.
- Reused the existing conversion nucleus rather than inventing a separate typechecker: declaration body validation now relies on inferExpr, checkExprHasType, isDefEq, and lazy delta helpers, preserving theorem/opaque checked-but-non-delta-unfoldable behavior.
- Left standalone top-level CtorDecl / RecDecl outside the Task 11 checked surface with explicit errors, keeping scope aligned with the plan non-inductive target instead of silently trusting extra declaration kinds.

- Task 12 reference decision: mirror Lean4 block staging rather than stream-order insertion: scratch/predeclared block env -> validate constructors under type-header visibility -> add constructors -> derive/add recursors -> commit validated block atomically to the checked env.

## 2026-05-12 Task: task-12-atomic-grouped-inductive-blocks
- Chose a scratch-env predeclaration strategy in `Mlkih.Kernel` instead of mutating the real env incrementally, matching the plan's atomic grouped-block publication requirement.
- Kept grouped-block validation intentionally shallow for Task 12: validate inductive, constructor, and recursor constant types under the predeclared env, and defer deeper constructor/recursor semantic checks to Task 13.
- Reused the generated `Nat` grouped block for the positive regression and added one hand-built malformed block only for the atomic failure case, minimizing fixture churn while covering the new env semantics directly.

## 2026-05-12 Task: task-13-validated-inductive-runtime-metadata
- Kept metadata validation concentrated at kernel bootstrap/grouped admission instead of duplicating checks inside every projection/iota reduction branch. Runtime now uses a `ValidatedKernelMetadata` cache derived from the env once per `runKernelM`.
- Did not broaden recursor validation into full semantic regeneration. For Task 13, the admitted trust boundary is: constructor ownership, exact block coverage/uniqueness, and rule field-count agreement with validated constructors.

## 2026-05-12 Task: task-14-end-to-end-ndjson-checker
- Chose  as the only production glue point instead of adding a new kernel wrapper, because the task is boundary composition rather than new checker behavior and  already owns the sequential env/state evolution.
- Exposed both bytestring and file-path entrypoints (, ) so callers can reuse the same preserved-interner checker path for generated exports and packaged fixtures without duplicating parse/check orchestration in tests or downstream code.

## 2026-05-12 Task: task-14-end-to-end-ndjson-checker
- Chose Mlkih.Export as the only production glue point instead of adding a new kernel wrapper, because the task is boundary composition rather than new checker behavior and checkAndAddDecls already owns the sequential env/state evolution.
- Exposed both bytestring and file-path entrypoints (checkExport, checkExportFile) so callers can reuse the same preserved-interner checker path for generated exports and packaged fixtures without duplicating parse/check orchestration in tests or downstream code.
