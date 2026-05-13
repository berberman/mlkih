# Lean Kernel Checker via NbE, Lazy Delta, and Head-Aware DefEq

## TL;DR
> **Summary**: Implement a Lean-kernel-style checker in Haskell that consumes exported NDJSON declarations, checks them sequentially, and uses a staged conversion subsystem: explicit declaration unfoldability, NbE-backed weak-head reduction, lazy delta driven by reducibility hints, and head-aware `isDefEq`.
> **Deliverables**:
> - Shared import/checker interning and a trusted import boundary
> - Kernel-faithful conversion core: unfoldability policy, conversion state, staged `whnf`, lazy delta, and head-aware `isDefEq`
> - Sequential declaration checker for axioms, defs, theorems, opaques, and atomic grouped inductive blocks
> - End-to-end NDJSON checker plus Cabal tests and arena-aligned regression fixtures
> **Effort**: XL
> **Parallel**: YES - 3 waves
> **Critical Path**: Task 1 → Task 3 → Task 6 → Task 7 → Task 8 → Task 9 → Task 11 → Task 12 → Task 13 → Task 14 → Task 15

## Context
### Original Request
Draft a kernel implementation plan for this Haskell project, using actual Lean kernel code, nanoda, and lean-mini-kernel as references.

### Interview Summary
- The checker must be implemented in Haskell and still use **NbE-oriented value/closure machinery** where appropriate.
- Input surface is exported **NDJSON**, including definitions.
- Declarations are checked **sequentially** from the export stream.
- Scope now targets the kernel-visible features actually needed to check exported Lean files and Kernel Arena-style cases, not only the previously narrowed subset.
- The previous plan’s simplifications were explicitly rejected.
- Delta reduction must consult declaration **reducibility hints**.
- `isDefEq` must include **head-aware heuristics**, including same-head argument comparison before unfolding when required.
- Grouped inductive blocks are **atomic environment units** during sequential checking.
- `iota` and projection behavior belong in the **first faithful conversion slice**, not as afterthought refactors.
- Recursion control for conversion must use **visited pairs + unfold stack**.
- Verification remains **tests-after** through the existing Cabal suite and in-repo fixtures.

### Metis Review (gaps addressed)
- Removed the invalid assumption that theorem bodies should delta-unfold like definitions.
- Split kernel declaration unfoldability from any future meta transparency system.
- Added explicit conversion-state work for recursion/cycle control beyond union-find.
- Locked grouped inductive handling to atomic block insertion/checking semantics.
- Added direct acceptance criteria for hint ordering, theorem/opaque non-unfolding, same-head heuristics, and recursion-loop prevention.

## Work Objectives
### Core Objective
Build a decision-complete implementation path for a Lean-faithful Haskell kernel checker whose conversion behavior is correct from the start: declaration-kind-sensitive unfoldability, reducibility-hint-aware lazy delta, same-head heuristics, and staged `whnf`/`isDefEq` rather than “normalize both and compare.”

### Deliverables
- Shared canonical interning across import and checking
- Trusted import boundary from NDJSON records to kernel input objects
- Explicit declaration unfoldability policy using `ReducibilityHints`
- NbE-backed runtime domain for closures/values used by reduction and checking
- Conversion state with visited-pair and unfold-stack recursion control
- Staged `whnf` with beta/zeta/projection/iota support and lazy delta
- Head-aware `isDefEq` with same-head regular-constant heuristics
- Sequential declaration checking for all parser-visible declaration kinds needed by exported Lean files, including `quot`
- Atomic grouped inductive block handling with constructor/recursor validation and execution-facing metadata
- End-to-end NDJSON checker API and deterministic Cabal regression tests

### Definition of Done (verifiable conditions with commands)
- `nix develop -c cabal build lib:mlkih test:mlkih-test` exits `0`
- `nix develop -c cabal test mlkih-test` exits `0`
- `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel unfolds abbrev before regular"'` exits `0`
- `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel orders regular delta by height"'` exits `0`
- `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel compares same-head regular args before unfolding"'` exits `0`
- `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel does not delta unfold theorem body"'` exits `0`
- `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel does not delta unfold opaque body"'` exits `0`
- `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel prevents infinite unfolding on recursive defs"'` exits `0`
- `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel checks generated export sequentially"'` exits `0`
- `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel checks atomic grouped inductive block"'` exits `0`

### Must Have
- Preserve `Mlkih.Level` as the universe-semantics source of truth
- Preserve imported canonical-id reuse invariants from `Mlkih.Intern`
- Keep parser/import logic outside the trusted kernel core
- Treat grouped inductives as **atomic block units** for env extension/checking
- Make unfoldability depend on **declaration kind + reducibility hints**, not just “body exists”
- Support projection/iota behavior in the first conversion architecture
- Aim to cover all declaration and expression forms required by exported Lean files in the target corpus, not just the current narrow fixture subset
- Keep kernel hint logic distinct from any future meta transparency modes
- Reject only malformed exports, inconsistent metadata, or truly out-of-contract future forms explicitly

### Must NOT Have (guardrails, AI slop patterns, scope boundaries)
- No source elaboration or parser work beyond export ingestion
- No reliance on `app/Main.hs` or `exe:mlkih`
- No monolithic “normalize and compare everything” conversion engine
- No use of `Ord ReducibilityHints` alone as the whole delta algorithm
- No eager unfolding of both sides by default
- No theorem/opaque delta unfolding
- No fuel-only recursion control as the primary design
- No manual-only verification criteria

## Verification Strategy
> ZERO HUMAN INTERVENTION - all verification is agent-executed.
- Test decision: tests-after + Cabal/Tasty (`mlkih-test`)
- QA policy: every task includes happy-path and failure/edge scenarios
- Evidence: `.sisyphus/evidence/task-{N}-{slug}.{ext}`

## Execution Strategy
### Parallel Execution Waves
> Target: 5 tasks per wave. Wave 1 fixes representation and trust-boundary issues. Wave 2 establishes the full conversion nucleus. Wave 3 attaches declaration and inductive checking to that nucleus.

Wave 1: representation + trust-boundary + helper/test foundation (Tasks 1-5)
Wave 2: full-fidelity conversion nucleus (Tasks 6-10)
Wave 3: declaration pipeline + inductives + end-to-end regressions (Tasks 11-15)

### Dependency Matrix (full, all tasks)
- 1 blocks 6, 11, 12, 14
- 2 blocks 11, 14, 15
- 3 blocks 7, 8, 9, 11, 15
- 4 blocks 7, 9, 13
- 5 blocks 10, 15 and supplies stable targeted test names
- 6 blocks 7, 8, 9, 13
- 7 blocks 8, 9, 13
- 8 blocks 9, 10, 11
- 9 blocks 10, 11, 13
- 10 is the Wave-2 checkpoint gate
- 11 blocks 12, 14
- 12 blocks 13, 14, 15
- 13 blocks 14, 15
- 14 blocks 15
- 15 feeds final verification only

### Agent Dispatch Summary (wave → task count → categories)
- Wave 1 → 5 tasks → `deep`, `ultrabrain`, `unspecified-high`
- Wave 2 → 5 tasks → `ultrabrain`, `deep`, `unspecified-high`
- Wave 3 → 5 tasks → `deep`, `ultrabrain`, `unspecified-high`

## TODOs
> Implementation + Test = ONE task. Never separate.
> EVERY task MUST have: Agent Profile + Parallelization + QA Scenarios.

- [x] 1. Unify import-time and checker-time interning

  **What to do**: Thread the import-time `InternState` into the checker entrypoint so every `Name`, `Level`, and `Expr` seen by the kernel shares one canonical id space. Extend the kernel bootstrap API so imported declarations install into the checked environment without re-interning into a disconnected state. Add explicit invariant checks proving constant lookup and later conversion operate on the same interned world.
  **Must NOT do**: Do not let logical equality depend on ids alone. Do not keep checker startup on a fresh empty interner for imported environments.

  **Recommended Agent Profile**:
  - Category: `deep` - Reason: this is the soundness boundary between import and checking.
  - Skills: `[]` - No special skill required.
  - Omitted: [`/playwright`] - No browser work.

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: 6, 11, 12, 14 | Blocked By: none

  **References**:
  - Pattern: `src/Mlkih/Intern.hs:30-40,92-173,194-227` - imported canonical ids must be reused; local nodes get fresh negative ids.
  - Pattern: `src/Mlkih/Kernel.hs:56-199` - existing checker scaffold to extend.
  - API/Type: `src/Mlkih/Env.hs:124-249` - env keying must match the shared interned world.
  - Test: `test/Main.hs:146-232,234-326` - current interning and kernel-helper invariants.

  **Acceptance Criteria**:
  - [ ] Imported declarations are available to the checker without re-interning mismatches.
  - [ ] A targeted test named `kernel shares imported canonical ids` passes.
  - [ ] A targeted test named `kernel rejects mismatched checker interner` passes.

  **QA Scenarios**:
  ```
  Scenario: Shared imported ids remain usable in checker
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel shares imported canonical ids"'`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-1-shared-interner.txt

  Scenario: Disconnected interner is rejected
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel rejects mismatched checker interner"'`
    Expected: exit code 0 with deterministic kernel error
    Evidence: .sisyphus/evidence/task-1-shared-interner-error.txt
  ```

  **Commit**: NO | Message: `feat(kernel): unify checker interner` | Files: `src/Mlkih/Kernel.hs`, `src/Mlkih/Intern.hs`, `src/Mlkih/Env.hs`, `test/Main.hs`

- [x] 2. Introduce the trusted import boundary and explicit support matrix

  **What to do**: Add an import-to-kernel translation layer that converts parsed NDJSON declarations into a narrower trusted kernel input model. Codify the implementation support matrix in code: every parser-visible declaration kind and every expression form required by exported Lean files in the target corpus must map to an intentional checker path. The matrix should still record malformed/inconsistent cases and any future out-of-contract forms as explicit failures.
  **Must NOT do**: Do not let `Mlkih.Export` record shapes flow directly into reduction/checking internals. Do not silently skip declarations or expression forms that appear in the target export corpus.

  **Recommended Agent Profile**:
  - Category: `deep` - Reason: this defines the checker trust boundary and scope.
  - Skills: `[]`
  - Omitted: [`/playwright`]

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: 11, 14, 15 | Blocked By: none

  **References**:
  - Pattern: `src/Mlkih/Export.hs:189-207,283-323,325-376,410-431,555-577` - parser/import shapes and reducibility-hint parsing.
  - API/Type: `src/Mlkih/Decl.hs:12-28,53-65` - declaration wrappers, including grouped inductives.
  - Pattern: `src/Mlkih/Env.hs:9-120` - trusted metadata target.

  **Acceptance Criteria**:
  - [ ] Supported/rejected mapping exists in code, not only comments.
  - [ ] A targeted test named `kernel imports all parser-visible declaration kinds needed by lean exports` passes.
  - [ ] A targeted test named `kernel rejects malformed or out-of-contract declaration forms` passes.

  **QA Scenarios**:
  ```
  Scenario: All required declaration kinds cross the trusted boundary cleanly
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel imports all parser-visible declaration kinds needed by lean exports"'`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-2-boundary.txt

  Scenario: Malformed or out-of-contract declarations fail explicitly
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel rejects malformed or out-of-contract declaration forms"'`
    Expected: exit code 0 with stable asserted errors
    Evidence: .sisyphus/evidence/task-2-boundary-error.txt
  ```

  **Commit**: NO | Message: `feat(kernel): define trusted import boundary` | Files: `src/Mlkih/Export.hs`, `src/Mlkih/Decl.hs`, `src/Mlkih/Env.hs`, `src/Mlkih/Kernel.hs`, `test/Main.hs`

- [x] 3. Encode kernel declaration unfoldability and reducibility-hint semantics

  **What to do**: Add explicit kernel-side predicates and helper types that decide whether a declaration is delta-unfoldable, how `Opaque | Abbrev | Regular Int` participate in lazy delta ordering, and which declaration kinds may carry bodies without being unfoldable. This task must encode the rule that theorem/opaque bodies can exist for checking but are not kernel-delta unfoldable.
  **Must NOT do**: Do not collapse kernel declaration hints into a future meta transparency enum. Do not use `Ord ReducibilityHints` alone as the whole delta algorithm.

  **Recommended Agent Profile**:
  - Category: `deep` - Reason: this is the core semantic contract for delta reduction.
  - Skills: `[]`
  - Omitted: [`/playwright`]

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: 7, 8, 9, 11, 15 | Blocked By: none

  **References**:
  - API/Type: `src/Mlkih/Env.hs:18-57` - reducibility hints plus definition/theorem/opaque payloads.
  - Pattern: `src/Mlkih/Export.hs:410-417` - parsed hint payloads.
  - External: `/Users/berberman/Desktop/lean4/src/Lean/Declaration.lean:16-49` - kernel hint semantics.
  - External: `/Users/berberman/Desktop/lean4/src/kernel/type_checker.cpp:884-939` - lazy delta ordering rules.

  **Acceptance Criteria**:
  - [ ] A targeted test named `kernel does not delta unfold theorem body` passes.
  - [ ] A targeted test named `kernel does not delta unfold opaque body` passes.
  - [ ] A targeted test named `kernel unfolds abbrev before regular` passes.

  **QA Scenarios**:
  ```
  Scenario: Body presence is distinguished from delta unfoldability
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options="--pattern '$0 ~ /kernel does not delta unfold theorem body|kernel does not delta unfold opaque body/'"`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-3-unfoldability.txt

  Scenario: Abbrev is preferred over regular in delta ordering
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel unfolds abbrev before regular"'`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-3-unfoldability-error.txt
  ```

  **Commit**: NO | Message: `feat(kernel): encode declaration unfoldability rules` | Files: `src/Mlkih/Env.hs`, `src/Mlkih/Kernel.hs`, `test/Main.hs`

- [x] 4. Add app-spine, projection, constructor, and binder helper views

  **What to do**: Extend `Mlkih.AST` and closely related syntax helpers with explicit app-spine splitting/rebuilding, projection views, constructor/recursor views, and binder helpers that reduction/checking can reuse without ad hoc traversal. These are support utilities for `whnf` and `isDefEq`, not a replacement AST.
  **Must NOT do**: Do not redesign the whole expression representation. Do not duplicate traversal code inside reduction and conversion.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` - Reason: helper-layer refactoring with strong downstream impact.
  - Skills: `[]`
  - Omitted: [`/playwright`]

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: 7, 9, 13 | Blocked By: none

  **References**:
  - Pattern: `src/Mlkih/AST.hs:86-105,112-320` - existing syntactic helper surface.
  - API/Type: `src/Mlkih/Expr.hs:36-61,124-163` - term constructors and helper wrappers.
  - Test: `test/Main.hs:328-452,495-537` - binder and local-context behavior to preserve.

  **Acceptance Criteria**:
  - [ ] App spines, projections, and binder helpers are reusable from reduction/conversion code.
  - [ ] A targeted test named `kernel syntax helper views preserve expression shape` passes.
  - [ ] A targeted test named `kernel projection view rejects malformed spine` passes.

  **QA Scenarios**:
  ```
  Scenario: Syntax helper views preserve shape
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel syntax helper views preserve expression shape"'`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-4-syntax-views.txt

  Scenario: Malformed projection/app views fail deterministically
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel projection view rejects malformed spine"'`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-4-syntax-views-error.txt
  ```

  **Commit**: NO | Message: `refactor(kernel): add syntax views for conversion` | Files: `src/Mlkih/AST.hs`, `src/Mlkih/Expr.hs`, `test/Main.hs`

- [x] 5. Create the conversion test harness and stable targeted fixtures

  **What to do**: Extend `test/Main.hs` so every conversion heuristic gets a stable Tasty test name and supporting fixture path. Add positive and negative checker fixtures for delta ordering, theorem/opaque non-unfolding, same-head comparisons, recursion loops, grouped-inductive atomicity, and end-to-end export checking.
  **Must NOT do**: Do not rely on non-Cabal entrypoints or future external arena runs as the only proof.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` - Reason: test and fixture architecture work.
  - Skills: `[]`
  - Omitted: [`/playwright`]

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: 10, 15 | Blocked By: none

  **References**:
  - Pattern: `mlkih.cabal:73-87` - existing `mlkih-test` target.
  - Pattern: `test/Main.hs:31-32,78-144,567-595` - current test entrypoint, export fixture flow, and generated Lean fixtures.
  - External: `AGENTS.md:9-11,17-24` - required Cabal and fixture workflow.

  **Acceptance Criteria**:
  - [ ] All new conversion tests are reachable through stable `--pattern` names.
  - [ ] A targeted test named `kernel fixture harness loads conversion fixtures` passes.
  - [ ] Negative conversion fixtures run entirely under Cabal.

  **QA Scenarios**:
  ```
  Scenario: Targeted conversion tests are discoverable
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel fixture harness loads conversion fixtures"'`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-5-test-harness.txt

  Scenario: Negative conversion fixtures are asserted under Cabal
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel fixture harness reports negative conversion fixtures"'`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-5-test-harness-error.txt
  ```

  **Commit**: NO | Message: `test(kernel): add conversion fixture harness` | Files: `test/Main.hs`, `test/fixtures/`, `mlkih.cabal`

- [x] 6. Add NbE-backed conversion state and recursion-control machinery

  **What to do**: Introduce the runtime state needed by conversion: NbE-oriented closures/values for local reduction, visited-pair tracking for pairwise defeq recursion, and unfold-stack tracking for recursive delta prevention. Keep this state separate from union-find so proven equalities do not double as recursion control.
  **Must NOT do**: Do not use union-find as the only cycle-prevention mechanism. Do not use fuel-only control as the primary design.

  **Recommended Agent Profile**:
  - Category: `ultrabrain` - Reason: this is the refactor-safe foundation for conversion.
  - Skills: `[]`
  - Omitted: [`/playwright`]

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: 7, 8, 9, 13 | Blocked By: 1

  **References**:
  - Pattern: `src/Mlkih/Kernel.hs:61-65,107-127` - current state and union-find surface to extend, not overload.
  - Pattern: `src/Mlkih/AST.hs:112-320` - binder operations for closure/value machinery.
  - External: `/Users/berberman/Desktop/lean4/src/kernel/type_checker.cpp:884-939` - recursive delta context.
  - External: `https://github.com/ammkrn/nanoda_lib/blob/master/src/tc.rs` - lazy delta and defeq decomposition reference.

  **Acceptance Criteria**:
  - [ ] Conversion state tracks visited pairs and unfold stack distinctly.
  - [ ] A targeted test named `kernel prevents infinite unfolding on recursive defs` passes.
  - [ ] A targeted test named `kernel does not confuse recursion control with expr classes` passes.

  **QA Scenarios**:
  ```
  Scenario: Recursive unfolding terminates by design
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel prevents infinite unfolding on recursive defs"'`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-6-conv-state.txt

  Scenario: Expr-class unioning does not replace cycle control
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel does not confuse recursion control with expr classes"'`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-6-conv-state-error.txt
  ```

  **Commit**: NO | Message: `feat(kernel): add conversion state and recursion guards` | Files: `src/Mlkih/Kernel.hs`, `src/Mlkih/AST.hs`, `src/Mlkih/Expr.hs`, `test/Main.hs`

- [x] 7. Implement staged weak-head reduction with NbE-backed local reduction hooks

  **What to do**: Implement `whnf` as a staged reducer, not a full normalizer. Cover beta, zeta, local closure application, projection and iota-aware stuck/reducible cases, and a no-unfolding/cheap phase before delta. Use NbE-style closures and value application where it clarifies binder-local reduction, but keep the overall API weak-head and conversion-driven.
  **Must NOT do**: Do not normalize both sides to full normal forms. Do not delay projection/iota architecture to a later refactor.

  **Recommended Agent Profile**:
  - Category: `ultrabrain` - Reason: weak-head semantics drive every later conversion rule.
  - Skills: `[]`
  - Omitted: [`/playwright`]

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: 8, 9, 13 | Blocked By: 3, 4, 6

  **References**:
  - Pattern: `src/Mlkih/AST.hs:112-320` - instantiation/abstraction semantics to preserve.
  - Pattern: `src/Mlkih/Expr.hs:36-61,124-163` - expression constructors.
  - External: `/Users/berberman/Desktop/lean4/src/Lean/Meta/WHNF.lean:650-717,1105-1122` - staged whnf concepts.
  - External: `/Users/berberman/Desktop/lean4/src/kernel/type_checker.cpp:401-482,1072-1112` - kernel weak-head structure.

  **Acceptance Criteria**:
  - [ ] A targeted test named `kernel whnf reduces beta and zeta` passes.
  - [ ] A targeted test named `kernel whnf handles stuck and reducible projection cases` passes.
  - [ ] A targeted test named `kernel whnf exposes iota redexes without full normalization` passes.

  **QA Scenarios**:
  ```
  Scenario: Weak-head reduction handles local reductions correctly
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel whnf reduces beta and zeta"'`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-7-whnf.txt

  Scenario: Projection/iota cases are staged, not ignored
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options="--pattern '$0 ~ /kernel whnf handles stuck and reducible projection cases|kernel whnf exposes iota redexes without full normalization/'"`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-7-whnf-error.txt
  ```

  **Commit**: NO | Message: `feat(kernel): implement staged weak-head reduction` | Files: `src/Mlkih/Kernel.hs`, `src/Mlkih/AST.hs`, `src/Mlkih/Expr.hs`, `test/Main.hs`

- [x] 8. Implement lazy delta with hint ordering and same-head pre-unfold checks

  **What to do**: Implement the kernel lazy-delta chooser that decides which side to unfold based on declaration kind, `Abbrev` vs `Regular`, regular heights, and one-sided unfoldability. Include the equal-height same-head regular-constant case that compares universes/arguments before unfolding either side.
  **Must NOT do**: Do not treat theorem/opaque bodies as unfoldable. Do not eager-unfold both sides before trying same-head comparison.

  **Recommended Agent Profile**:
  - Category: `ultrabrain` - Reason: this is the most Lean-specific conversion rule in scope.
  - Skills: `[]`
  - Omitted: [`/playwright`]

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: 9, 10, 11 | Blocked By: 3, 6, 7

  **References**:
  - API/Type: `src/Mlkih/Env.hs:18-57` - reducibility hints and declaration kinds.
  - External: `/Users/berberman/Desktop/lean4/src/kernel/type_checker.cpp:884-939,917-933` - lazy delta and same-head equal-height regular rule.
  - External: `https://github.com/ammkrn/nanoda_lib/blob/master/src/env.rs` - hint ordering helpers.
  - External: `https://github.com/ammkrn/nanoda_lib/blob/master/src/tc.rs` - lazy delta step and same-head comparison decomposition.

  **Acceptance Criteria**:
  - [ ] A targeted test named `kernel unfolds abbrev before regular` passes.
  - [ ] A targeted test named `kernel orders regular delta by height` passes.
  - [ ] A targeted test named `kernel compares same-head regular args before unfolding` passes.

  **QA Scenarios**:
  ```
  Scenario: Delta ordering follows kernel hint semantics
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options="--pattern '$0 ~ /kernel unfolds abbrev before regular|kernel orders regular delta by height/'"`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-8-lazy-delta.txt

  Scenario: Same-head regular defs try args before unfolding
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel compares same-head regular args before unfolding"'`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-8-lazy-delta-error.txt
  ```

  **Commit**: NO | Message: `feat(kernel): implement lazy delta with hint ordering` | Files: `src/Mlkih/Kernel.hs`, `src/Mlkih/Env.hs`, `test/Main.hs`

- [x] 9. Implement staged head-aware `isDefEq`

  **What to do**: Implement `isDefEq` as a dispatcher over fast syntactic/easy cases, universe comparison, same-head const/app comparison, projection/iota-aware paths, lazy delta fallback, and remaining structural hooks. Keep `isDefEq` distinct from `whnf`, but let it call defeq-specific weak-head steps when needed. Use the visited-pair/unfold-stack machinery from Task 6.
  **Must NOT do**: Do not merge `isDefEq` into `whnf`. Do not reduce conversion to “normalize both terms and compare quoted syntax.”

  **Recommended Agent Profile**:
  - Category: `ultrabrain` - Reason: this is the central correctness and architecture pivot.
  - Skills: `[]`
  - Omitted: [`/playwright`]

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: 10, 11, 13 | Blocked By: 3, 4, 6, 7, 8

  **References**:
  - Pattern: `src/Mlkih/Level.hs:116-231` - universe equivalence/ordering used inside conversion.
  - External: `/Users/berberman/Desktop/lean4/src/kernel/type_checker.cpp:1094-1116` - same-head checks after reduction.
  - External: `/Users/berberman/Desktop/lean4/src/Lean/Meta/ExprDefEq.lean:1453-1513,1539-1566,1652-1685,2192-2219,2271-2339` - staged heuristic shape.
  - External: `https://github.com/ammkrn/nanoda_lib/blob/master/src/tc.rs` - decomposition reference.

  **Acceptance Criteria**:
  - [ ] A targeted test named `kernel compares same-head regular args before unfolding` passes.
  - [ ] A targeted test named `kernel uses universe comparison before unnecessary unfolding` passes.
  - [ ] A targeted test named `kernel defeq handles projection and iota cases` passes.

  **QA Scenarios**:
  ```
  Scenario: Head-aware defeq succeeds without unnecessary unfolding
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options="--pattern '$0 ~ /kernel compares same-head regular args before unfolding|kernel uses universe comparison before unnecessary unfolding/'"`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-9-defeq.txt

  Scenario: Projection/iota-aware defeq path works and stays terminating
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options="--pattern '$0 ~ /kernel defeq handles projection and iota cases|kernel prevents infinite unfolding on recursive defs/'"`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-9-defeq-error.txt
  ```

  **Commit**: NO | Message: `feat(kernel): implement staged head-aware defeq` | Files: `src/Mlkih/Kernel.hs`, `src/Mlkih/Level.hs`, `test/Main.hs`

- [x] 10. Freeze the conversion nucleus with universe-sensitive regressions and checkpoint commit

  **What to do**: Add focused regression coverage for theorem/opaque non-unfolding, hint ordering, same-head heuristics, recursion control, projection/iota cases, and universe-sensitive conversion behavior. Run the full build/test suite and create the Wave-2 checkpoint commit only after the conversion nucleus is green.
  **Must NOT do**: Do not defer conversion failure-path tests to later declaration tasks. Do not commit on a partially green suite.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` - Reason: hardening and release-gating of the conversion core.
  - Skills: [`git-master`] - Helpful for the checkpoint commit once green.
  - Omitted: [`/playwright`]

  **Parallelization**: Can Parallel: YES | Wave 2 | Blocks: none | Blocked By: 5, 8, 9

  **References**:
  - Test: `test/Main.hs` - same Tasty suite, no parallel test system.
  - Pattern: `mlkih.cabal:73-87` - existing `mlkih-test` target only.
  - External: `AGENTS.md:9-11` - Cabal build/test command shape.

  **Acceptance Criteria**:
  - [ ] `nix develop -c cabal build lib:mlkih test:mlkih-test` exits `0`.
  - [ ] `nix develop -c cabal test mlkih-test` exits `0`.
  - [ ] The Wave-2 checkpoint commit contains only the green conversion nucleus.

  **QA Scenarios**:
  ```
  Scenario: Full build and test pass after conversion nucleus
    Tool: Bash
    Steps: run `nix develop -c cabal build lib:mlkih test:mlkih-test` and `nix develop -c cabal test mlkih-test`
    Expected: both commands exit 0
    Evidence: .sisyphus/evidence/task-10-conversion-regressions.txt

  Scenario: Targeted conversion regressions remain green
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options="--pattern '$0 ~ /kernel unfolds abbrev before regular|kernel orders regular delta by height|kernel compares same-head regular args before unfolding|kernel does not delta unfold/'"`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-10-conversion-regressions-error.txt
  ```

  **Commit**: YES | Message: `feat(kernel): add faithful conversion nucleus` | Files: `src/Mlkih/Kernel.hs`, `src/Mlkih/Env.hs`, `src/Mlkih/AST.hs`, `src/Mlkih/Level.hs`, `test/Main.hs`

- [x] 11. Check sequential non-inductive declarations, including quotients, with actual unfoldability rules

  **What to do**: Implement the top-level sequential declaration checker for axioms, definitions, theorems, opaques, and quotient-related declarations present in exported Lean files. Each declaration must be typechecked before insertion; only definitions participate in kernel delta according to `ReducibilityHints`. Theorem and opaque bodies are checked but remain non-delta-unfoldable.
  **Must NOT do**: Do not treat “value present in export” as “unfoldable in kernel.” Do not install failing declarations into the checked environment.

  **Recommended Agent Profile**:
  - Category: `deep` - Reason: this is the first full integration of conversion with declaration checking.
  - Skills: `[]`
  - Omitted: [`/playwright`]

  **Parallelization**: Can Parallel: YES | Wave 3 | Blocks: 12, 14 | Blocked By: 1, 2, 3, 8, 9

  **References**:
  - API/Type: `src/Mlkih/Env.hs:40-120` - declaration metadata and kinds.
  - Pattern: `src/Mlkih/Export.hs:189-207,410-417` - imported decl shapes and hints.
  - External: `/Users/berberman/Desktop/lean4/src/Lean/Declaration.lean` - declaration intent and reducibility data.

  **Acceptance Criteria**:
  - [ ] A targeted test named `kernel checks generated natAddSuccFixture theorem` passes.
  - [ ] A targeted test named `kernel checks quotient-related declarations from lean export` passes.
  - [ ] A targeted test named `kernel does not delta unfold theorem body` passes.
  - [ ] A targeted test named `kernel rejects declaration with body type mismatch` passes.

  **QA Scenarios**:
  ```
  Scenario: Sequential non-inductive declaration checking succeeds
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options="--pattern '$0 ~ /kernel checks generated natAddSuccFixture theorem|kernel checks quotient-related declarations from lean export/'"`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-11-decls.txt

  Scenario: Type-mismatched declaration body is rejected
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel rejects declaration with body type mismatch"'`
    Expected: exit code 0 with asserted checker failure
    Evidence: .sisyphus/evidence/task-11-decls-error.txt
  ```

  **Commit**: NO | Message: `feat(kernel): check sequential non-inductive declarations` | Files: `src/Mlkih/Kernel.hs`, `src/Mlkih/Env.hs`, `src/Mlkih/Export.hs`, `test/Main.hs`

- [x] 12. Predeclare, check, and install grouped inductive blocks atomically

  **What to do**: Treat each `InductiveBlockDecl` as one atomic environment unit: predeclare headers, check the block under that predeclared context, then install the full validated block in one logical step. This task defines the exact env-extension granularity for grouped inductives and must reject partial/sequential inner insertion semantics.
  **Must NOT do**: Do not check/install the inner pieces one by one in stream order. Do not silently accept unsupported grouped shapes.

  **Recommended Agent Profile**:
  - Category: `deep` - Reason: environment atomicity is a structural invariant with downstream impact on recursors and projections.
  - Skills: `[]`
  - Omitted: [`/playwright`]

  **Parallelization**: Can Parallel: YES | Wave 3 | Blocks: 13, 14, 15 | Blocked By: 1, 11

  **References**:
  - API/Type: `src/Mlkih/Decl.hs:12-27,53-65` - grouped inductive block wrappers.
  - Pattern: `src/Mlkih/Export.hs:313-323,390-403` - grouped inductive export shape.
  - Test: `test/Main.hs:83-115` - grouped inductive export parsing expectations.

  **Acceptance Criteria**:
  - [ ] A targeted test named `kernel checks atomic grouped inductive block` passes.
  - [ ] A targeted test named `kernel rejects non-atomic grouped inductive insertion` passes.
  - [ ] Environment extension semantics for grouped blocks are asserted by tests.

  **QA Scenarios**:
  ```
  Scenario: Grouped inductive block is handled atomically
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel checks atomic grouped inductive block"'`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-12-inductive-atomicity.txt

  Scenario: Partial inner insertion semantics are rejected
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel rejects non-atomic grouped inductive insertion"'`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-12-inductive-atomicity-error.txt
  ```

  **Commit**: NO | Message: `feat(kernel): add atomic grouped inductive checking` | Files: `src/Mlkih/Kernel.hs`, `src/Mlkih/Decl.hs`, `src/Mlkih/Env.hs`, `src/Mlkih/Export.hs`, `test/Main.hs`

- [x] 13. Validate constructors and recursors, then realize projection/iota behavior on validated metadata

  **What to do**: Validate constructor and recursor metadata for the admitted grouped inductive shapes, then connect that validated metadata to the projection/iota-aware reduction paths already designed in Tasks 7 and 9. Projection and iota behavior must become real execution, not just placeholders, as soon as inductive metadata is available.
  **Must NOT do**: Do not trust recursor payloads blindly because parsing succeeded. Do not postpone projection/iota execution to a future architectural rewrite.

  **Recommended Agent Profile**:
  - Category: `ultrabrain` - Reason: this joins the hardest inductive metadata checks to conversion semantics.
  - Skills: `[]`
  - Omitted: [`/playwright`]

  **Parallelization**: Can Parallel: YES | Wave 3 | Blocks: 14, 15 | Blocked By: 4, 6, 7, 9, 12

  **References**:
  - API/Type: `src/Mlkih/Env.hs:67-120` - constructor, recursor, and rule metadata.
  - Pattern: `src/Mlkih/Export.hs:325-376` - recursor rule import shape.
  - External: `/Users/berberman/Desktop/lean4/src/kernel/type_checker.cpp` - kernel reduction behavior reference.
  - External: `https://github.com/ammkrn/nanoda_lib/blob/master/src/tc.rs` - recursor and defeq decomposition reference.

  **Acceptance Criteria**:
  - [ ] A targeted test named `kernel validates simple inductive recursor` passes.
  - [ ] A targeted test named `kernel defeq handles projection and iota cases` passes.
  - [ ] A targeted test named `kernel rejects bad recursor payload` passes.

  **QA Scenarios**:
  ```
  Scenario: Validated recursor metadata drives projection/iota behavior
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options="--pattern '$0 ~ /kernel validates simple inductive recursor|kernel defeq handles projection and iota cases/'"`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-13-recursors-iota-proj.txt

  Scenario: Invalid recursor payload is rejected
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel rejects bad recursor payload"'`
    Expected: exit code 0 with asserted checker failure
    Evidence: .sisyphus/evidence/task-13-recursors-iota-proj-error.txt
  ```

  **Commit**: NO | Message: `feat(kernel): validate recursors and enable iota projection behavior` | Files: `src/Mlkih/Kernel.hs`, `src/Mlkih/Env.hs`, `test/Main.hs`

- [x] 14. Wire the end-to-end NDJSON checker pipeline

  **What to do**: Connect NDJSON parsing/import, the shared interner, the trusted boundary, the full conversion nucleus, and sequential declaration/block checking into one public checker entrypoint. A full export stream must be checked deterministically declaration by declaration, with grouped inductives handled atomically.
  **Must NOT do**: Do not check raw parsed records directly. Do not bypass the trusted boundary for convenience.

  **Recommended Agent Profile**:
  - Category: `deep` - Reason: this is the full-system integration point.
  - Skills: `[]`
  - Omitted: [`/playwright`]

  **Parallelization**: Can Parallel: YES | Wave 3 | Blocks: 15 | Blocked By: 1, 2, 11, 12, 13

  **References**:
  - Pattern: `src/Mlkih/Export.hs:189-207,313-323,325-376,390-403,410-431,555-577` - complete import surface.
  - Pattern: `src/Mlkih/Kernel.hs:56-199` - stable façade to keep while extending internals.
  - Test: `test/Main.hs:78-124,567-595` - generated Lean export fixtures and current loading flow.

  **Acceptance Criteria**:
  - [ ] A targeted test named `kernel checks generated export sequentially` passes.
  - [ ] A targeted test named `kernel rejects export with unsupported declaration in stream` passes.
  - [ ] Grouped inductive atomicity is preserved in end-to-end checking.

  **QA Scenarios**:
  ```
  Scenario: End-to-end sequential NDJSON checking succeeds
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel checks generated export sequentially"'`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-14-end-to-end.txt

  Scenario: Unsupported declaration in stream fails deterministically
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options='--pattern "kernel rejects export with unsupported declaration in stream"'`
    Expected: exit code 0 with asserted checker failure
    Evidence: .sisyphus/evidence/task-14-end-to-end-error.txt
  ```

  **Commit**: NO | Message: `feat(kernel): wire end-to-end export checker` | Files: `src/Mlkih/Export.hs`, `src/Mlkih/Kernel.hs`, `src/Mlkih/Env.hs`, `src/Mlkih/Decl.hs`, `test/Main.hs`

- [ ] 15. Add arena-aligned regressions and create the final feature commit

  **What to do**: Finalize the full regression suite with arena-aligned positive and negative fixtures kept entirely in-repo. Cover a theorem check, hint-sensitive delta behavior, same-head heuristics, theorem/opaque non-unfolding, recursive-unfold termination, atomic grouped inductives, and projection/iota cases. Create the final feature commit only after the full Cabal suite is green.
  **Must NOT do**: Do not make external Kernel Arena access a prerequisite for green tests. Do not leave any “kernel-faithful” heuristic unasserted.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` - Reason: integration hardening and release-quality regression coverage.
  - Skills: [`git-master`] - Helpful for the final feature commit.
  - Omitted: [`/playwright`]

  **Parallelization**: Can Parallel: YES | Wave 3 | Blocks: none | Blocked By: 2, 5, 12, 13, 14

  **References**:
  - Test: `test/Main.hs:78-144,567-595` - current fixture style and Lean fixture pipeline.
  - Pattern: `mlkih.cabal:73-87` - existing test target only.
  - External: `AGENTS.md:17-24` - fixture/export workflow details.

  **Acceptance Criteria**:
  - [ ] `nix develop -c cabal build lib:mlkih test:mlkih-test` exits `0`.
  - [ ] `nix develop -c cabal test mlkih-test` exits `0`.
  - [ ] A targeted test named `kernel rejects arena fixture with type mismatch` passes.
  - [ ] The final feature commit is created only after all targeted conversion and checker tests are green.

  **QA Scenarios**:
  ```
  Scenario: Arena-aligned happy and failure fixtures pass under Cabal
    Tool: Bash
    Steps: run `nix develop -c cabal test mlkih-test --test-options="--pattern '$0 ~ /kernel checks generated export sequentially|kernel rejects arena fixture with type mismatch|kernel compares same-head regular args before unfolding|kernel defeq handles projection and iota cases/'"`
    Expected: exit code 0
    Evidence: .sisyphus/evidence/task-15-arena-regressions.txt

  Scenario: Full suite stays green after regression expansion
    Tool: Bash
    Steps: run `nix develop -c cabal build lib:mlkih test:mlkih-test` and `nix develop -c cabal test mlkih-test`
    Expected: both commands exit 0
    Evidence: .sisyphus/evidence/task-15-arena-regressions-error.txt
  ```

  **Commit**: YES | Message: `feat(kernel): validate faithful export checking` | Files: `src/Mlkih/Kernel.hs`, `src/Mlkih/Env.hs`, `src/Mlkih/Decl.hs`, `src/Mlkih/Export.hs`, `test/Main.hs`, `test/fixtures/`

## Final Verification Wave (MANDATORY — after ALL implementation tasks)
> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.
> **Do NOT auto-proceed after verification. Wait for user's explicit approval before marking work complete.**
> **Never mark F1-F4 as checked before getting user's okay.** Rejection or user feedback -> fix -> re-run -> present again -> wait for okay.
- [ ] F1. Plan Compliance Audit — oracle

  **Tool**: `task(subagent_type="oracle")`
  **Steps**: Review `.sisyphus/plans/lean-kernel-nbe.md` against the implementation diff and changed files. Verify that declaration unfoldability, reducibility-hint-aware lazy delta, same-head heuristics, grouped-inductive atomicity, quotient handling, and regression coverage all match the plan.
  **Expected**: Explicit approval with no critical plan deviations.
  **Evidence**: `.sisyphus/evidence/f1-plan-compliance.md`

- [ ] F2. Code Quality Review — unspecified-high

  **Tool**: `task(category="unspecified-high")`
  **Steps**: Inspect changed Haskell files for maintainability, duplicated reduction logic, incorrect helper layering, accidental meta-transparency conflation, and shortcuts that would force later defeq/reflection refactors.
  **Expected**: Explicit approval with no critical quality or architecture issues.
  **Evidence**: `.sisyphus/evidence/f2-code-quality.md`

- [ ] F3. Real Manual QA — unspecified-high

  **Tool**: `task(category="unspecified-high")`
  **Steps**: Run `nix develop -c cabal build lib:mlkih test:mlkih-test`, `nix develop -c cabal test mlkih-test`, and the targeted Definition-of-Done commands for delta ordering, theorem/opaque non-unfolding, recursion control, end-to-end export checking, and grouped inductive atomicity.
  **Expected**: All commands exit `0`; targeted Tasty tests pass by name.
  **Evidence**: `.sisyphus/evidence/f3-real-qa.md`

- [ ] F4. Scope Fidelity Check — deep

  **Tool**: `task(category="deep")`
  **Steps**: Verify the implementation stayed within scope: exported-NDJSON checker only, no elaborator/parser expansion, no simplified defeq architecture, and no omission of kernel-visible features required for target Lean exports and Arena-style cases.
  **Expected**: Explicit approval with no hidden scope drift or omitted required feature paths.
  **Evidence**: `.sisyphus/evidence/f4-scope-fidelity.md`

## Commit Strategy
- Do not commit after each task.
- Create one checkpoint commit after Wave 2 when the conversion nucleus and tests are green.
- Create the main feature commit after Wave 3 and before the final verification wave.
- Use conventional messages such as `feat(kernel): add faithful conversion nucleus` and `feat(kernel): validate faithful export checking`.

## Success Criteria
- The repo can parse an NDJSON export, translate it into one shared interned environment, and check declarations sequentially.
- Kernel conversion uses explicit declaration unfoldability, reducibility-hint-aware lazy delta, and head-aware `isDefEq`.
- Theorem and opaque bodies are checked but never kernel-delta unfolded.
- Grouped inductive blocks are checked and installed atomically.
- Projection and iota behavior are present in the first conversion architecture and become real on validated metadata.
- All verification commands above pass under Cabal.
