# Architecture

## Module-Level View

This module is a collection of independent game/example packages under one MoonBit module root.

- Shared dependency layer: `tonyfettes/raylib` plus MoonBit core packages.
- Package isolation: each game/example folder owns its own package graph and runtime loop.
- Tooling layer: shell/python helpers in `tools/` for build and publishing workflows.

## Typical In-Game Architecture

Most games follow the same separation model:

1. Root executable package
- Initializes window, frame timing, and high-level state orchestration.

2. `internal/types`
- Data model, constants, utility math/conversion helpers.

3. `internal/game`
- Input handling and state transitions.
- Core gameplay update logic.

4. `internal/render`
- Draw code, HUD, overlays, and visual effects orchestration.

This keeps mutation-heavy simulation logic separate from drawing code, which improves readability and testability.

## Build and Validation Architecture

- `moon check` is the primary fast correctness gate.
- `moon info` is the API contract gate (`pkg.generated.mbti`).
- Per-package READMEs act as human-facing design and API documentation.

## Documentation Architecture

Documentation is layered:

- Package-level: `README.mbt.md` for gameplay and API specifics.
- Module-level: this file plus `README.md`, `API.md`, and `TODO.md`.
- Symbol-level: `///` comments on public declarations.
