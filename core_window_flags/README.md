# Window Flags

This example is an interactive demonstration of raylib's window configuration flags. A bouncing ball animates in the background while the user toggles various window properties at runtime using keyboard shortcuts. The current state of each flag is displayed on screen with color-coded on/off indicators.

## Build and Run

```bash
moon build --target native core_window_flags/
./_build/native/debug/build/core_window_flags/core_window_flags.exe
```

## Controls

- **F** -- toggle fullscreen mode
- **R** -- toggle window resizable
- **D** -- toggle window undecorated (no title bar)
- **H** -- hide window (auto-restores after 4 seconds)
- **N** -- minimize window (auto-restores after 4 seconds)
- **M** -- toggle window maximized
- **U** -- toggle window unfocused
- **T** -- toggle window topmost (always on top)
- **A** -- toggle window always-run (update even when unfocused)
- **V** -- toggle VSync hint

## What It Demonstrates

- `@raylib.set_window_state()` and `@raylib.clear_window_state()` to enable/disable window flags at runtime
- `@raylib.is_window_state()` to query the current state of any window flag
- `@raylib.toggle_fullscreen()` to switch between fullscreen and windowed modes
- `@raylib.minimize_window()`, `@raylib.maximize_window()`, and `@raylib.restore_window()` for window size management
- Runtime-toggleable flags: `FlagFullscreenMode`, `FlagWindowResizable`, `FlagWindowUndecorated`, `FlagWindowHidden`, `FlagWindowMinimized`, `FlagWindowMaximized`, `FlagWindowUnfocused`, `FlagWindowTopmost`, `FlagWindowAlwaysRun`, `FlagVsyncHint`
- Pre-creation-only flags (display-only): `FlagWindowHighdpi`, `FlagWindowTransparent`, `FlagMsaa4xHint`
- Auto-restore pattern: hidden and minimized states automatically restore after 240 frames (4 seconds)
- Simple bouncing ball animation with boundary collision

## Public API Reference

### Package `core_window_flags`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program creates an 800x450 window without `set_target_fps` (frame rate is uncontrolled unless VSync is toggled). Each frame, keyboard presses toggle corresponding window flags using `set_window_state`/`clear_window_state` or dedicated functions like `toggle_fullscreen`. For hidden and minimized states, a frame counter triggers automatic restoration after 240 frames. A bouncing ball provides visual animation feedback. The draw phase shows each flag's name, key binding, and current state as color-coded text (lime for on, maroon for off).

## Key Takeaways

- Raylib distinguishes between flags that can be toggled at runtime (resizable, undecorated, topmost, etc.) and flags that must be set before window creation (HighDPI, transparent, MSAA).
- `set_window_state` and `clear_window_state` accept the same flag constants, providing a symmetric API for enabling and disabling window properties.
- This example serves as a comprehensive reference for all available raylib window flags and their runtime behavior.
