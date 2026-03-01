# TODO (Future)

## Documentation

- [ ] Add a root index that links all game packages by genre/theme.
- [ ] Standardize API tables across all package READMEs.
- [ ] Add a short "testing strategy" section to each game README.
- [ ] Define a lightweight style guide for public `///` doc comments.

## Quality and Tooling

- [ ] Add CI job that runs `moon check` and fails on warnings for selected package sets.
- [ ] Add CI job that runs `moon info` and reports unexpected public API changes.
- [ ] Add a helper to detect README/API section drift versus `pkg.generated.mbti`.

## Architecture

- [ ] Document shared architecture patterns for 2D vs 3D examples.
- [ ] Identify opportunities for reusable internal utility packages where duplication is high.
- [ ] Define package tagging metadata (genre, mechanics, complexity).

## Developer Experience

- [ ] Add a top-level command map for common tasks (`check`, `run`, `build-web`).
- [ ] Add troubleshooting docs for platform-specific raylib issues.
- [ ] Add a "new game package template" guide.
