# API Documentation Guide

This repository has no single monolithic API. It exposes many small package APIs, one per game/example.

## API Boundaries

For most game directories, the public surface is split into three internal layers plus the executable root:

1. `<game>`
- Primary executable entrypoint (`main`).

2. `<game>/internal/types`
- Public constants, enums/structs, and math/layout helpers shared by other internal packages.

3. `<game>/internal/game`
- Public simulation update entrypoints (for example `update_game`).

4. `<game>/internal/render`
- Public frame rendering entrypoints (for example `draw_frame`).

## Authoritative API Source

Generated MBTI files are the source of truth:

```bash
moon info
```

This emits `pkg.generated.mbti` files that summarize exported types/functions without implementation details.

## API Quality Rules

- Every public symbol should have `///` docs where `+missing_doc` is enabled.
- Public names should stay stable unless a package-specific README documents a breaking change.
- Changes to exported APIs should be visible in `pkg.generated.mbti` diffs.

## How To Review API Changes

1. Run `moon info`.
2. Review changed `pkg.generated.mbti` files.
3. Confirm matching updates in the package README API section.
4. Run `moon check` to ensure doc and type quality gates pass.
