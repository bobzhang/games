# Raylib Examples in MoonBit

A large MoonBit module containing hundreds of small game and graphics examples built with `tonyfettes/raylib`.

Each `raylib_*` directory is an independent package set that can be built and run on its own.

## Goals

- Keep examples easy to run and read.
- Keep gameplay logic, rendering, and shared types separated.
- Keep documentation quality high enough for package-level onboarding and API browsing.

## Quick Start

```bash
moon check
moon build --target native raylib_2048/
moon run --target native raylib_2048/
```

To run another game, replace `raylib_2048/` with a different package directory.

## Repository Layout

- `moon.mod.json`: module metadata and dependencies.
- `raylib_*`: example/game packages.
- `raygui_demo`: raygui-focused demo package.
- `tools/`: build/publish helper scripts.

A typical game package uses this structure:

- `main.mbt`: executable entry and frame loop.
- `internal/types`: exported constants, types, helpers.
- `internal/game`: state transitions and simulation.
- `internal/render`: draw pipeline.

## Documentation Standards

- Public declarations must have `///` documentation when `+missing_doc` is enabled.
- Each game should have a `README.mbt.md` describing:
  - gameplay and controls,
  - build/run instructions,
  - public API summary,
  - architecture notes,
  - refinement roadmap.
- API surface should stay aligned with `pkg.generated.mbti` output from `moon info`.

## Validation Workflow

```bash
moon check
moon info
moon test
```

For targeted validation:

```bash
moon check --package-path raylib_2048
```

## Notes

This repository is intentionally broad and example-heavy. Most packages are small by design and prioritize clarity over deep framework abstraction.
