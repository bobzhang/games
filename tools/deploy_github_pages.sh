#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v node >/dev/null 2>&1; then
  echo "error: node command not found in PATH" >&2
  exit 1
fi

exec node "$ROOT_DIR/tools/deploy_github_pages.js" "$@"
