# AGENTS.md

## Scope
- This repo is a small Cabal Haskell package. Start from `./mlkih.cabal`, not from `app/` or `CHANGELOG.md`.
- The real behavior lives in `./src/Mlkih/Export.hs`, `./src/Mlkih/Intern.hs`, `./src/Mlkih/Level.hs`, and `./test/Main.hs`.

## Toolchain and commands
- Preferred environment: `nix develop`. `./flake.nix` defines only `devShells.default`; `./shell.nix` is just a `flake-compat` bridge.
- Use Cabal as the source of truth for validation. For normal work run:
  - `nix develop -c cabal build lib:mlkih test:mlkih-test`
  - `nix develop -c cabal test mlkih-test`
- Do not assume `nix build` or `nix flake check` are meaningful here; the flake does not define package/check outputs.

## Verification gotchas
- Do not default to `cabal build all` or `exe:mlkih`. `./app/Main.hs` still imports `MyLib`, while the library module is `Mlkih`, so the executable currently fails to build unless you are intentionally fixing it.
- Tests depend on Cabal-generated `Paths_mlkih` and packaged `data-files`; run them through Cabal, not `runghc test/Main.hs`.
- Malformed export fixtures live under `./test/fixtures/export/*.ndjson` and are loaded via `getDataFileName` in `./test/Main.hs`.
- Positive export-parser tests are generated from the in-repo Lean fixture project under `./test/fixtures/lean/`; malformed parser tests still use hand-written `.ndjson` fixtures.

## Local lean4export workflow
- The in-repo Lean fixture project under `./test/fixtures/lean/` depends on `lean4export` via a pinned Lake git dependency, not a machine-local Desktop path.
- Command shape matters: pass module names before `--`, then declaration names after it. Example: `lake env .lake/packages/lean4export/.lake/build/bin/lean4export Init.Data.Nat -- Nat.add_add_add_comm`.
- The repo now contains a checked-in Lean fixture project at `./test/fixtures/lean/` with its own `lakefile.toml` and `lean-toolchain`.
- Commit `./test/fixtures/lean/lake-manifest.json` so Lake's resolved `lean4export` revision stays reproducible across CI and local runs.
- For repo tests, Haskell locates `./test/fixtures/lean/lakefile.toml`, runs `lake build <FixtureModule>` in that directory, builds the dependency executable with `lake build @lean4export/lean4export`, and then runs `lake env .lake/packages/lean4export/.lake/build/bin/lean4export <FixtureModule> -- <fixture theorem name>` from the fixture project root.
- Use Lean core theorems from `/Users/berberman/Desktop/lean4/src/Init/` as sources for real fixtures. Do not touch mathlib yet.

## Repo shape
- `src/` contains the library.
- `test/Main.hs` is the main behavioral spec: parser acceptance/rejection cases, interning reuse rules, and level equivalence/ordering checks all live there.
- `app/Main.hs` and `src/Mlkih.hs` are still low-signal/template-like files. Do not infer architecture from them.
- `src/Mlkih/Kernel.hs` now holds checker state/context plumbing; AST construction and binder operations live in `src/Mlkih/AST.hs`.

## Domain-specific invariants
- `parseExportFile` expects newline-delimited JSON export records with the `meta` object first; blank lines terminate parsing.
- Interning preserves imported canonical ids when payloads match, and locally interned names/levels/exprs allocate fresh negative ids to avoid collisions.
- Level comparison is normalization-based: `levelEquiv` and `levelGeq` in `./src/Mlkih/Level.hs` are the rules to preserve when changing universe logic.
- Current generated exports use the upstream grouped inductive shape (`types` / `ctors` / `recs`). If you reintroduce coverage for the older alias-style shape, do it intentionally; do not invent synthetic theorem fixtures when real Lean exports are available.

## What is not here
- No repo-local `CLAUDE.md`, `.cursor` rules, Copilot instructions, CI workflows, or hook configs were present during inspection.
- No separate lint/format/typecheck scripts or task-runner wrappers were present; do not invent them in future sessions.
