#!/usr/bin/env bash
#
# Capture screenshots of featured MoonBit games (macOS).
#
# Each game is built natively, launched in the background, and after a short
# warm-up period macOS `screencapture` grabs the game window.  The script
# tries to identify the window by its process ID; if that fails it falls
# back to a full-screen capture cropped to the frontmost window.
#
# Usage:
#   ./tools/capture_screenshots.sh                  # all featured games
#   ./tools/capture_screenshots.sh tank_1990 mario  # specific games only
#
# Requirements:
#   - macOS (uses `screencapture` and `osascript`)
#   - `moon` CLI on PATH
#   - Native raylib backend compiled (the script runs `moon build`)
#
# Environment variables:
#   WARMUP_SECS   Seconds to let the game run before capturing (default: 3)
#   OUT_DIR        Output directory for PNGs (default: website/dist/screenshots)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WARMUP_SECS="${WARMUP_SECS:-3}"
OUT_DIR="${OUT_DIR:-$ROOT/website/dist/screenshots}"
mkdir -p "$OUT_DIR"

# ── Featured / default game list ────────────────────────────────────
DEFAULT_GAMES=(
  abyssal_rift
  fighter_97_lite
  kart_racing_3d
  tower_defense_3d
  space_combat_3d
  naval_combat_3d
  dungeon_crawler_3d
  survival_arena_3d
  bomberman_1983_lite
  tank_1990
  mario
  2048
)

# Use arguments if provided, otherwise fall back to defaults.
if [[ $# -gt 0 ]]; then
  GAMES=("$@")
else
  GAMES=("${DEFAULT_GAMES[@]}")
fi

# ── Helpers ─────────────────────────────────────────────────────────

# Try to find the CGWindowID for a given PID so `screencapture -l` can
# grab exactly that window (no user interaction required, no shadow).
get_window_id_for_pid() {
  local pid="$1"
  # Ask the WindowServer for windows owned by this PID.  The list is
  # JSON-ish; we pull the first kCGWindowNumber.
  osascript -e "
    use framework \"Foundation\"
    use framework \"CoreGraphics\"
    set wList to current application's CGWindowListCopyWindowInfo(current application's kCGWindowListOptionOnScreenOnly, 0)
    set wCount to wList's |count|()
    repeat with i from 0 to (wCount - 1)
      set w to (wList's objectAtIndex:i)
      set wPID to (w's objectForKey:\"kCGWindowOwnerPID\") as integer
      set wLayer to (w's objectForKey:\"kCGWindowLayer\") as integer
      if wPID = $pid and wLayer = 0 then
        return (w's objectForKey:\"kCGWindowNumber\") as integer
      end if
    end repeat
    return 0
  " 2>/dev/null || echo "0"
}

ok_count=0
fail_count=0
skip_count=0

# ── Main loop ───────────────────────────────────────────────────────

for game in "${GAMES[@]}"; do
  echo "=== $game ==="

  # 1) Build native
  echo "  Building..."
  if ! (cd "$ROOT" && moon build "$game" --target native 2>&1 | tail -3); then
    echo "  SKIP (build failed)"
    (( skip_count++ )) || true
    continue
  fi

  # 2) Locate executable
  exe="$ROOT/_build/native/release/build/$game/$game"
  if [[ ! -f "$exe" ]]; then
    echo "  SKIP (no executable at $exe)"
    (( skip_count++ )) || true
    continue
  fi

  # 3) Launch the game
  echo "  Launching (warm-up ${WARMUP_SECS}s)..."
  "$exe" &
  pid=$!
  sleep "$WARMUP_SECS"

  # Make sure the process is still alive
  if ! kill -0 "$pid" 2>/dev/null; then
    echo "  SKIP (process exited early)"
    wait "$pid" 2>/dev/null || true
    (( skip_count++ )) || true
    continue
  fi

  # 4) Capture the screenshot
  out_path="$OUT_DIR/${game}.png"
  captured=false

  # Method A: window-specific capture via CGWindowID
  wid="$(get_window_id_for_pid "$pid")"
  if [[ "$wid" =~ ^[0-9]+$ ]] && [[ "$wid" -gt 0 ]]; then
    echo "  Capturing window $wid..."
    if screencapture -x -o -l "$wid" "$out_path" 2>/dev/null; then
      captured=true
    fi
  fi

  # Method B: fallback -- capture the frontmost window
  if [[ "$captured" == "false" ]]; then
    echo "  Fallback: capturing frontmost window..."
    # Bring the game to front
    osascript -e "
      tell application \"System Events\"
        set frontProcess to first process whose unix id is $pid
        set frontmost of frontProcess to true
      end tell
    " 2>/dev/null || true
    sleep 0.5
    if screencapture -x -o -w "$out_path" 2>/dev/null; then
      captured=true
    fi
  fi

  # 5) Terminate the game
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true

  if [[ "$captured" == "true" ]] && [[ -f "$out_path" ]]; then
    size=$(stat -f%z "$out_path" 2>/dev/null || echo "?")
    echo "  OK -> $out_path ($size bytes)"
    (( ok_count++ )) || true
  else
    echo "  FAILED (no screenshot produced)"
    (( fail_count++ )) || true
  fi
done

# ── Summary ─────────────────────────────────────────────────────────

echo ""
echo "=== Summary ==="
echo "  Captured: $ok_count"
echo "  Failed:   $fail_count"
echo "  Skipped:  $skip_count"
echo "  Output:   $OUT_DIR/"
