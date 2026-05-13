## 2026-05-09T23:02:33Z Task: session-start
- Initial notepad created for lean-kernel-nbe work session.
- Current plan requires full-fidelity kernel conversion architecture: declaration unfoldability, reducibility-hint-aware lazy delta, same-head heuristics, atomic grouped inductives, and immediate projection/iota support.

## 2026-05-09T23:35:00Z Task: unify-import-checker-interner
- `Mlkih.Export` already carried the authoritative import-time `InternState` in `ExportState`; the missing piece was exposing that state at the public parse boundary instead of discarding it during finalization.
- `KernelEnv` startup must now be paired with an explicit `InternState`; otherwise canonical-id-based env lookup can silently drift even when payloads are structurally identical.
- Declaration payload roots like `constType`, `defValue`, and `recRhs` are `Expr' HCExpr HCLevel HCName`, not top-level `HCExpr` nodes, so bootstrap validation needs separate handling for raw payload roots versus referenced interned child nodes.

## 2026-05-09T23:59:00Z Task: trusted-import-boundary-support-matrix
- `Mlkih.Export` now has an explicit raw-declaration parsing phase before any kernel-facing `Decl` is constructed, which keeps JSON/export-contract quirks at the import boundary instead of leaking them into later kernel code.
- Current `lean4export` output requires contract-only declaration metadata such as `all`, `isUnsafe`, grouped inductive alias keys, and the `letE.nondep` flag; the trusted boundary can validate and intentionally ignore those fields when they are not kernel-relevant yet.
- Full-suite regression testing was necessary after tightening the contract because real fixture exports exercised `letE.nondep`, and an older local shared-interner fixture had to be updated to include the now-explicit `axiom.isUnsafe` field.

- 2026-05-09 Task 3 research: Lean4 kernel delta-unfoldability is declaration-kind-sensitive. `Lean.Meta.getUnfoldableConst?` only returns `.defn` constants; `.thm` and `.opaque` bodies may exist for checking but are not meta/kernel delta-unfoldable.
- 2026-05-09 Task 3 research: `ReducibilityHints` affect lazy-delta ordering only for definitions. Hint ordering is abbrev < regular < opaque, with regular heights compared in reverse and equal-regular same-head apps getting a pre-unfold argument defeq fast path in the lazy-delta step.

## 2026-05-09T23:59:00Z Task: kernel-declaration-unfoldability
-  now separates / from /, so theorem and opaque declarations can keep stored bodies for checking without being treated as delta-unfoldable.
- Kernel-facing classification stays narrow in : , , , and  all route through  instead of reinterpreting declaration payloads elsewhere.
- Lazy-delta hint ordering support is now explicit helper logic instead of relying on  alone: class tagging, optional regular height extraction, and a dedicated  helper preserve abbrev/regular/opaque semantics for later tasks.

## 2026-05-10T00:10:00Z Task: kernel-declaration-unfoldability-followup
- `Mlkih.Env` now separates `constantInfoBody` / `constantInfoHasBody` from `constantInfoDeltaUnfoldability` / `constantInfoIsDeltaUnfoldable`, so theorem and opaque declarations can keep stored bodies for checking without being treated as delta-unfoldable.
- Kernel-facing classification stays narrow in `Mlkih.Kernel`: `lookupConstBody`, `constHasBody`, `constIsDeltaUnfoldable`, and `lookupConstReducibilityHints` all route through `lookupConstInfo` instead of reinterpreting declaration payloads elsewhere.
- Lazy-delta hint ordering support is now explicit helper logic instead of relying on `Ord ReducibilityHints` alone: class tagging, optional regular height extraction, and a dedicated `compareReducibilityHintsForDelta` helper preserve abbrev/regular/opaque semantics for later tasks.

## 2026-05-10T00:25:00Z Task: task-4-syntax-view-research
- Lean4 keeps expression decomposition as helper views on top of the existing `Expr` constructors: `consumeMData`, `getAppFn`, `getAppArgs`, `withApp`, and `withAppRev` provide reusable app-spine access without changing representation.
- Lean4 and lean4lean both centralize binder traversal in telescope/local-context helpers (`lambdaTelescope`, `forallTelescope`, `withLocalDecl`, `withLetDecl`) so reduction and defeq logic do not each reimplement instantiate/reabstract loops.
- Projection support is split into two layers: a cheap primitive kernel projection reducer (`reduceProj?` / `reduceProj`) plus a stricter projection-shape recognizer (`getProjectedExpr`/`etaStruct?`) for structure/eta-style reasoning.

## 2026-05-10T00:40:00Z Task: task-4-syntax-helper-views
- Mlkih.AST now exposes structural views over existing HCExpr nodes instead of adding a parallel AST: app-spine split/rebuild, const-head app recognition, raw projection views, and a stricter projection-over-const-app recognizer for later reduction code.
- Binder helpers stay purely syntactic: lambda/forall telescope splitting and rebuilding reuse the existing binder fields, while openBinderView and openLetView delegate opening to instantiate1 so later kernel code can combine them with local-context helpers without reimplementing substitution.

- Task 5 research: prefer stable per-case test identifiers (Tasty names or file names), keep positive generated-export fixtures separate from tiny handwritten negative NDJSON fixtures, and avoid a generic fixture DSL; references: Lean4 tests README/test piles, Lean Kernel Arena test YAML good-vs-bad split, nanoda_lib path-based test_resources.

## 2026-05-11 Task: task-5-conversion-fixture-harness
- Conversion/checker support fixtures now load through a thin `loadParsedExportFixture` helper in `test/Main.hs`, using `fixturePath` plus `parseExportFileWithState` so future targeted kernel tests can stay Cabal-only and path-based.
- Stable targeted Tasty names `kernel fixture harness loads conversion fixtures` and `kernel fixture harness reports negative conversion fixtures` now anchor future `--pattern` runs without requiring ad hoc harness logic.
- The old inline support-matrix and malformed boundary ByteStrings were replaced by flat packaged `.ndjson` fixtures under `test/fixtures/export/`, keeping generated Lean positives separate from handwritten negative cases.

- Task 6 research: Lean4 separates proven-equality state (`m_eqv_manager`) from lazy-delta failure memo (`m_failure`) and unfold cache (`m_unfold`); Task 6 should add distinct visited-pair and unfold-stack state instead of overloading union-find. References: lean4 `src/kernel/type_checker.h` / `type_checker.cpp`, lean4lean `Lean4Lean/TypeChecker.lean`, nanoda_lib `src/tc.rs` / `src/util.rs`.

## 2026-05-11 Task: task-6-conversion-state-scaffolding
- `Mlkih.Kernel` now keeps conversion recursion-control separate from proven expr equality: union-find remains in `checkExprUnionFind`, while `checkVisitedExprPairs`, `checkFailedExprPairs`, and `checkUnfoldStack` each track a distinct concern.
- The new pair-tracking helpers canonicalize `(HCExpr, HCExpr)` by expr id order, so future symmetric defeq checks can memoize or guard recursion without depending on argument ordering.
- Minimal NbE-facing placeholder types (`Closure`, `Value`, `NbEState`) now exist in the kernel layer without committing to whnf or lazy-delta semantics yet, which keeps Task 6 scoped to infrastructure.

- Task 7 research: stage weak-head reduction as no-delta core (beta/zeta/fvar/proj/iota) plus outer unfold loop; preserve binder opening via instantiate/openBinderView/openLetView helpers; stage cheap projection before full projection to avoid premature delta. Refs: lean4 src/kernel/type_checker.cpp 401-482, 521-533, 1072-1112; Lean/Meta/WHNF.lean 650-717, 1105-1122; lean4lean Lean4Lean/TypeChecker.lean 280-340, 425-448; nanoda_lib src/tc.rs 417-428, 736-818.

## 2026-05-11 Task: task-7-staged-whnf
- Mlkih.Kernel.whnf now runs as a no-delta weak-head loop: app-lambda beta, let-zeta, projection-over-constructor reduction, and recursor iota staging all happen at the head without recursing into arbitrary subterms.
- Reusing the Task 4 AST views kept reduction structural instead of ad hoc: getAppSpine, viewLam/openBinderView, viewLet/openLetView, viewProjStructConstApp, and viewConstApp were enough to stage every Task 7 case.
- The Task 7 iota test is easiest to express with a tiny hand-built RecursorVal rule whose RHS is a lambda tower; the reducer can then build the staged application and weak-head reduce only until the RHS head is exposed, leaving inner constructor arguments untouched.

## 2026-05-11 Task: task-8-lazy-delta
- `Mlkih.Kernel` can keep lazy delta separate from `whnf` by treating delta candidates as const-head `DefnInfo` applications, choosing a side from reducibility hints, and weak-head reducing only the unfolded result.
- The equal-height same-head regular shortcut fits naturally as a callback-based precheck: compare constant universe arguments with `levelEquiv`, delegate argument defeq to the caller, and memoize failed pairs before falling back to unfolding both sides.

## 2026-05-11 Task: task-9-staged-head-aware-isdefeq
- `isDefEq` now benefits from a dedicated same-head const-app stage on weak-head forms: matching constant names check universe arguments first, then arguments, so non-unfoldable heads can short-circuit before lazy delta or generic app congruence.
- Reducible same-head definitions must not turn every argument mismatch into immediate failure: when universes or arguments do not settle equality, the const-app stage should yield back to Task 8 lazy delta so unfolding can still prove bodies equal.
- The most valuable Task 9 regression is the “ignored argument” definition shape (`def f := fun _ => ...`): it catches staged defeq implementations that over-eagerly reject same-head reducible applications instead of preserving the unfold fallback.

## 2026-05-11 Task: task-10-hardening-review
- Full `nix develop -c cabal test mlkih-test` is currently green (58 tests), so the remaining Task 10 risk is mostly missing regression coverage rather than an obvious live failure.
- The highest-value untested conversion seams are: negative same-head universe mismatches on non-unfoldable constants, the actual `isDefEqBinderViews` lambda/forall path, and mutual-recursive delta loops that require visited-pair and failed-pair interaction beyond the current self-recursive unfold-stack test.
- Projection/iota coverage is good on the happy path, but brittle stuck-shape cases such as out-of-range projections or malformed recursor saturation still lack direct checkpoint regressions.

## 2026-05-11 Task: task-9-staged-head-aware-isDefEq
- `Mlkih.Kernel.isDefEq` now stays distinct from `whnf` and stages comparison as: cheap syntactic/class checks, no-delta weak-head reduction, lazy-delta interplay, then projection/binder/app structural fallthrough.
- Reusing `lazyDeltaReductionStep isDefEq` keeps the Task 8 same-head regular shortcut alive at the real defeq entrypoint, so equal regular applications can succeed without unfolding and failed ones reuse the existing failed-pair memo.
- Same-name constant equality can short-circuit on universe arguments alone via `levelEquiv`, which avoids unnecessary unfolding in cases like `u` versus `max u u` while staying within the existing conversion helpers.

## 2026-05-11 Task: task-10-freeze-conversion-nucleus
- The highest-value remaining conversion regressions fit directly in `test/Main.hs`: same-head non-unfoldable negative checks, binder-view defeq coverage, and mutual-recursive delta termination all needed no new harness or fixtures.
- Non-unfoldable same-head failures are worth pinning in two forms: argument mismatches and universe mismatches. Both should fail without touching the unfold stack, which protects the Task 9 same-head const-app stage from silently regressing into lazy-delta work.
- Mutual-recursive abbrev loops are currently contained by the interaction between visited-pair tracking and failed-pair memoization rather than the single-const unfold stack alone, so a direct `isDefEq` regression is the right checkpoint guard.

## 2026-05-12 Task: task-11-sequential-noninductive-checking
- Mlkih.Kernel now has a production checkAndAddDecl / checkAndAddDecls path that checks declarations against the current env and only extends KernelEnv after success, while still trusting grouped inductive blocks as pass-through inputs for Task 12.
- The first declaration checker needed a small expression-inference layer on top of the conversion nucleus: constant instantiation, Pi/lambda/let inference, defeq-based body checking, and reducible-definition-aware ensureSort / ensureForallType helpers were enough to validate the generated natAddSuccFixture theorem.
- Projection-heavy theorem checking depended on reducing projections over reducible structure-instance defs, not just raw constructor apps, so whnf now unfolds a delta-capable projected struct just enough to expose the constructor before projection reduction.

- Task 12 research: Lean4 kernel handles mutual inductives as one `Declaration.inductDecl`; `Declaration.getNames` expands the block to type + ctor + rec names, but kernel checking enters via the single block declaration first (`src/Lean/Declaration.lean`, `src/Lean/AddDecl.lean`, `src/Lean/Replay.lean`).
- Task 12 research: `src/kernel/inductive.cpp` predeclares inductive type constants with `declare_inductive_types`, then checks all constructors before declaring any constructor, and only declares recursors after constructor declaration. This is the concrete model for atomic grouped-block staging.

## 2026-05-12 Task: task-12-atomic-grouped-inductive-blocks
- `checkAndAddDecl` now treats `InductiveBlockDecl` like a staged publication step: it first predeclares all type/ctor/recursor `ConstantInfo`s into a scratch env, checks the whole block there, and only then inserts the block into the real env.
- Keeping grouped-block checking limited to `checkConstantType` for inductive types, constructors, and recursors preserves Task 12 scope while still forcing sibling-name resolution through the scratch env instead of the main env.
- The strongest regression shape for atomicity is a two-declaration sequence where a malformed grouped block is followed by a consumer of one leaked name: the old pass-through path would have accepted it, while the new atomic path fails before publication.

- Task 13 research: validate recursor/constructor metadata against admitted inductive block before trusting projection/iota reduction. Lean4 references: type_checker.cpp reduce_proj/reduce_recursor and inductive.cpp constructor/recursor generation checks; lean4lean mirrors this by comparing postponed ctor/recursor payloads against regenerated ones.

## 2026-05-12 Task: task-13-validated-inductive-runtime-metadata
- `Mlkih.Kernel` now builds a validated inductive metadata cache during kernel bootstrap, so projection inference, projection reduction, and recursor iota reduction only consult constructor/recursor facts that already passed grouped-block validation.
- The focused recursor checks stay intentionally structural for this repo scope: rule constructors must belong to one admitted inductive block, cover that block coherently without duplicates, and each rule `recFieldsN` must match the referenced constructor `ctorFieldsN`.
- Existing projection/iota happy-path fixtures needed explicit `InductInfo` entries once runtime stopped trusting bare `CtorInfo`/`RecInfo`; that keeps tests aligned with the new trust boundary instead of silently bypassing it.

## 2026-05-12 Task: task-14-end-to-end-ndjson-checker
-  now exposes production checker glue at the import boundary:  and  preserve 's imported  and forward  directly into .
- Keeping the wrapper in  preserves the intended seam  without rebuilding env insertion logic or weakening Task 12 grouped-inductive atomicity, because grouped blocks still flow through the existing  checker path unchanged.
- The strongest end-to-end positive regression is the generated Lean  export, because it proves the public path carries both the grouped  block and a later theorem through one sequential checker run.

## 2026-05-12 Task: task-14-end-to-end-ndjson-checker
- Mlkih.Export now exposes production checker glue at the import boundary: checkExport and checkExportFile preserve the parsed export's imported InternState and forward parsedDecls directly into checkAndAddDecls IntMap.empty.
- Keeping the wrapper in Export.hs preserves the intended seam parse -> ParsedExport -> checkAndAddDecls without rebuilding env insertion logic or weakening Task 12 grouped-inductive atomicity, because grouped blocks still flow through the existing InductiveBlockDecl checker path unchanged.
- The strongest end-to-end positive regression is the generated Lean natAddSuccFixture export, because it proves the public path carries both the grouped Nat block and a later theorem through one sequential checker run.

## 2026-05-12 Task: task-15-arena-negative-fixture-slice
- A minimal repo-local checker regression can use a single theorem export with `type = Sort 0` and `value = Sort 0`: NDJSON parsing succeeds, but `checkExportFile` reaches kernel checking and reports the existing body/type mismatch path.
- Positive arena-aligned end-to-end coverage remains best anchored on the generated `natAddSuccFixture`; the new repo-local fixture only adds the missing negative checker path instead of duplicating a broad positive export set.

## 2026-05-12 Task: task-15-positive-iota-fixture-slice
- The smallest positive arena-aligned public-checker regression reused the existing generated `NatAddSuccFixture` pipeline: adding one explicit `Nat.rec` zero-case theorem let `checkExportFile` prove imported grouped-inductive iota semantics without introducing a new handwritten NDJSON matrix.
- Keeping the new test at the public seam (`loadCheckedLeanFixture` -> `checkExportFile` -> `lookupConstInfo`) avoids duplicating the broader sequential-export assertion while still pinning a named theorem whose admission depends on imported recursor metadata surviving NDJSON lowering.

## 2026-05-12 Task: task-15-conversion-support-bootstrap-fix
- `conversionSupportFixture` still works as a mixed trusted-boundary/support-matrix fixture, but tests that call `evalKernelM` on `kernelEnvFromDecls` must filter out unsupported standalone `CtorDecl`/`RecDecl` entries before bootstrap metadata validation.
- Keeping the full parsed fixture for boundary assertions and only narrowing the env-building subset preserves theorem/opaque non-unfoldability coverage without weakening Task 13 validated-metadata semantics.

## 2026-05-12 Task: task-15-final-wave-status
- Task 15 code/test work is complete and review-ready; final-wave F1/F2/F3/F4 review verdicts are all APPROVE.
- Remaining state is workflow-gated only: create the final feature commit, then wait for the user's explicit `okay` before marking F1-F4 complete.
- The plan itself forbids marking F1-F4 complete before that user `okay`, so no further code changes are required.
