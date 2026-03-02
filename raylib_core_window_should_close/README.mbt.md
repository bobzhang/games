# Core Window Should Close

This example demonstrates how to intercept the window close event in raylib using MoonBit. Instead of immediately closing when the user presses the X button or Escape key, the program displays a confirmation dialog asking the user to confirm with Y or cancel with N. When you run it, you see a light screen with instructional text; attempting to close the window reveals a black overlay with the confirmation prompt.

## Build and Run

```bash
moon build --target native raylib_core_window_should_close/
./_build/native/debug/build/raylib_core_window_should_close/raylib_core_window_should_close.exe
```

## Controls

- **X button / Escape**: Request window close (shows confirmation dialog)
- **Y**: Confirm exit (while confirmation dialog is shown)
- **N**: Cancel exit (while confirmation dialog is shown)

## What It Demonstrates

- **Window close interception**: Uses `@raylib.set_exit_key(@raylib.KeyNull)` to disable the default Escape-to-close behavior, then manually checks `@raylib.window_should_close()` and `@raylib.is_key_pressed(@raylib.KeyEscape)` to trigger a custom confirmation flow.
- **Custom game loop exit logic**: Manages two boolean flags (`exit_window_requested` and `exit_window`) to separate the "close requested" state from the "actually close" state, enabling a confirmation step before shutdown.
- **Conditional rendering**: Draws different UI content depending on whether the close confirmation is active, using `@raylib.draw_rectangle` for a dark overlay and `@raylib.draw_text` for the prompt.

## Public API Reference

### Package `raylib_core_window_should_close`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes an 800x450 window and disables the default exit key. The main loop checks for close requests (X button or Escape) and sets a flag. When the flag is active, the loop listens for Y/N key presses to confirm or cancel. Drawing alternates between an instructional message and the confirmation overlay. On confirmed exit, the loop terminates and the window is closed via `@raylib.close_window()`.

## Key Takeaways

- Use `@raylib.set_exit_key(@raylib.KeyNull)` to prevent automatic window closure and implement custom shutdown logic such as save-before-exit or confirmation dialogs.
- The `@raylib.window_should_close()` function detects OS-level close requests (like clicking the X button), while `@raylib.is_key_pressed` handles keyboard-driven close requests separately.
- Managing game loop termination with explicit boolean flags is a clean pattern for multi-step exit workflows in MoonBit.
