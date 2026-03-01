#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

PKG_PATH="${1:-raylib_tank_1990}"
PKG_PATH="${PKG_PATH%/}"
PKG_NAME="$(basename "$PKG_PATH")"
OUT_DIR="${2:-_build/web/${PKG_NAME}}"
PRE_JS="$ROOT_DIR/tools/web_force_webgl1.pre.js"
POST_JS="$ROOT_DIR/tools/web_mobile_touch.post.js"

if ! command -v moon >/dev/null 2>&1; then
  echo "error: moon command not found in PATH" >&2
  exit 1
fi

if ! command -v emcc >/dev/null 2>&1; then
  echo "error: emcc command not found in PATH" >&2
  echo "hint: install emscripten (for example: brew install emscripten)" >&2
  exit 1
fi

MOON_HOME="${MOON_HOME:-$HOME/.moon}"
if [[ ! -f "$MOON_HOME/lib/runtime.c" || ! -f "$MOON_HOME/include/moonbit.h" ]]; then
  MOON_BIN_DIR="$(cd "$(dirname "$(command -v moon)")" && pwd)"
  MOON_HOME="$(cd "$MOON_BIN_DIR/.." && pwd)"
fi

if [[ ! -f "$MOON_HOME/lib/runtime.c" || ! -f "$MOON_HOME/include/moonbit.h" ]]; then
  echo "error: cannot locate MoonBit runtime files under MOON_HOME=$MOON_HOME" >&2
  exit 1
fi

if [[ ! -f "$PRE_JS" ]]; then
  echo "error: missing pre-js patch file: $PRE_JS" >&2
  exit 1
fi

if [[ ! -f "$POST_JS" ]]; then
  echo "error: missing post-js patch file: $POST_JS" >&2
  exit 1
fi

echo "[1/3] Building MoonBit package with native backend: $PKG_PATH"
moon build --target native "$PKG_PATH"

GENERATED_C="_build/native/debug/build/${PKG_PATH}/${PKG_NAME}.c"
if [[ ! -f "$GENERATED_C" ]]; then
  echo "error: generated C file not found: $GENERATED_C" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
RUNTIME_OBJ="$OUT_DIR/runtime.o"
OUTPUT_HTML="$OUT_DIR/${PKG_NAME}.html"

# Detect resource directories to embed in the Emscripten virtual filesystem.
# Games use change_directory("<name>") then load from "resources/",
# so we embed at the matching virtual path.
EMBED_FLAGS=()
if [[ -d "$PKG_PATH/resources" ]]; then
  EMBED_FLAGS+=(--embed-file "$PKG_PATH/resources@$PKG_PATH/resources")
fi

echo "[2/3] Compiling MoonBit runtime C: $RUNTIME_OBJ"
# Keep runtime compilation isolated from raylib include paths, otherwise
# .mooncakes/tonyfettes/raylib/internal/raylib/external/dirent.h can shadow the system dirent.h header.
emcc -c \
  "$MOON_HOME/lib/runtime.c" \
  -I"$MOON_HOME/include" \
  -include string.h \
  -fwrapv \
  -fno-strict-aliasing \
  -Wno-unused-value \
  -o "$RUNTIME_OBJ"

echo "[3/3] Linking browser output with emcc: $OUTPUT_HTML"
emcc \
  "$RUNTIME_OBJ" \
  "$GENERATED_C" \
  .mooncakes/tonyfettes/raylib/internal/raylib/utils.c \
  .mooncakes/tonyfettes/raylib/internal/raylib/rcore.c \
  .mooncakes/tonyfettes/raylib/internal/raylib/rshapes.c \
  .mooncakes/tonyfettes/raylib/internal/raylib/rtextures.c \
  .mooncakes/tonyfettes/raylib/internal/raylib/rtext.c \
  .mooncakes/tonyfettes/raylib/internal/raylib/rmodels.c \
  .mooncakes/tonyfettes/raylib/internal/raylib/raudio.c \
  .mooncakes/tonyfettes/raylib/internal/raylib/stub_window.c \
  .mooncakes/tonyfettes/raylib/internal/raylib/stub_input.c \
  .mooncakes/tonyfettes/raylib/internal/raylib/stub_drawing.c \
  .mooncakes/tonyfettes/raylib/internal/raylib/stub_camera.c \
  .mooncakes/tonyfettes/raylib/internal/raylib/stub_color.c \
  .mooncakes/tonyfettes/raylib/internal/raylib/stub_shapes.c \
  .mooncakes/tonyfettes/raylib/internal/raylib/stub_textures.c \
  .mooncakes/tonyfettes/raylib/internal/raylib/stub_text.c \
  .mooncakes/tonyfettes/raylib/internal/raylib/stub_models.c \
  .mooncakes/tonyfettes/raylib/internal/raylib/stub_audio.c \
  .mooncakes/tonyfettes/raylib/internal/raylib/stub_image_processing.c \
  .mooncakes/tonyfettes/raylib/internal/raylib/stub_image_drawing.c \
  .mooncakes/tonyfettes/raylib/internal/raylib/stub_filesystem.c \
  .mooncakes/tonyfettes/raylib/internal/raylib/stub_utils.c \
  .mooncakes/tonyfettes/raylib/internal/raylib/stub_automation.c \
  -I"$MOON_HOME/include" \
  -I.mooncakes/tonyfettes/raylib/internal/raylib \
  -include string.h \
  -DPLATFORM_WEB \
  -DGRAPHICS_API_OPENGL_ES2 \
  -fwrapv \
  -fno-strict-aliasing \
  -Wno-unused-value \
  -sUSE_GLFW=3 \
  -sASYNCIFY \
  -sASYNCIFY_STACK_SIZE=10485760 \
  -sALLOW_MEMORY_GROWTH=1 \
  -sFORCE_FILESYSTEM=1 \
  -sASSERTIONS=1 \
  -sEXPORTED_FUNCTIONS=_main \
  -sEXPORTED_RUNTIME_METHODS=ccall,cwrap,HEAPF32 \
  ${EMBED_FLAGS[@]+"${EMBED_FLAGS[@]}"} \
  --pre-js "$PRE_JS" \
  --post-js "$POST_JS" \
  -o "$OUTPUT_HTML"

echo
echo "Built browser bundle:"
echo "  $OUTPUT_HTML"
echo "  ${OUTPUT_HTML%.html}.js"
echo "  ${OUTPUT_HTML%.html}.wasm"
echo
echo "Run a local server (example):"
echo "  emrun --no_browser --port 8080 \"$OUTPUT_HTML\""
