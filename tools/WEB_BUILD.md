# Web Build Pipeline

This repository uses a Node.js orchestrator to build web bundles and generate a homepage:

- Entry command: `tools/build_web_games.sh`
- Node implementation: `tools/build_web_games.js`
- Per-game native web builder: `tools/build_web_native_emcc.sh`
- Homepage generator: `tools/prepare_web_games_site.sh`
- Ad-hoc per-game overrides: `tools/web_games.special.js`

## Default Behavior

`tools/build_web_games.sh` builds selected games in parallel.

- By default, failing games are **auto-skipped**.
- Successful games still produce bundles.
- Homepage generation still runs (unless `--no-site`).
- A report is written to:
  - `<out-root>/BUILD_FAILURES.md` (default: `_build/web/BUILD_FAILURES.md`)

The report contains `FIXME(<game>)` entries for:

- games skipped by special rules
- games that failed during the current build run

## Strict Mode

Use `--strict` if you want CI-style failure when any game fails:

```bash
tools/build_web_games.sh --jobs 8 --strict
```

## Selecting Games

Build all discovered `raylib_*` games:

```bash
tools/build_web_games.sh --jobs 8
```

Build filtered subset:

```bash
tools/build_web_games.sh --filter 'tank|fighter'
```

Build explicit list:

```bash
tools/build_web_games.sh --games raylib_tank_1990,raylib_bomber_grid_2026
```

List selected games without building:

```bash
tools/build_web_games.sh --list --filter 'tank|fighter'
```

## Ad-hoc Special Handling

Use `tools/web_games.special.js` to customize game-specific behavior:

- `skip: true` to disable a package on web temporarily
- `reason` for report visibility
- `pkgPath`, `outDirName`, `outDir`, `extraArgs`
- optional `resolveGame(game, plan)` hook for dynamic logic

If a game is known to fail on web, add it with a `FIXME(web)` comment in that file.

## GitHub Pages (Manual, No CI)

After building the site, deploy it to `gh-pages` with:

```bash
tools/deploy_github_pages.sh --site-dir _build/web_pages_site_full_skip
```

Options:

- `--remote origin` (default: `origin`)
- `--branch gh-pages` (default: `gh-pages`)
- `--message "Deploy web games"` custom commit message
- `--dry-run` prepare deploy commit without pushing

The script uses a temporary git worktree and pushes the static site to the target branch.
