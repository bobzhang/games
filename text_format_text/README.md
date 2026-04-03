# Text: Format Text

This example demonstrates text formatting and display using MoonBit's string interpolation as a replacement for C's `TextFormat`/`sprintf`. When you run it, you see formatted score, high score, lives count, and real-time frame time values drawn to the screen with different colors.

## Build and Run

```bash
moon build --target native text_format_text/
./_build/native/debug/build/text_format_text/text_format_text.exe
```

## Controls

No interactive controls -- runs automatically.

## What It Demonstrates

- **MoonBit string interpolation**: Uses `\{variable}` syntax (e.g., `"Score: \{score}"`, `"Elapsed Time: \{frame_time} ms"`) to embed values directly in strings, replacing C's `TextFormat` function with a type-safe, idiomatic approach.
- **Basic text drawing**: `draw_text` renders formatted strings at specific screen positions with different colors (red for score, green for high score, blue for lives, black for frame time).
- **Frame time measurement**: `get_frame_time` retrieves the elapsed time for the current frame in seconds, multiplied by 1000.0 to display in milliseconds.
- **Static and dynamic values**: Demonstrates both compile-time constants (`score = 100020`, `hiscore = 200450`, `lives = 5`) and runtime values (frame time) in formatted text output.

## Public API Reference

### Package `text_format_text`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes a window with predefined score, high score, and lives values. Each frame, it computes the frame time in milliseconds via `get_frame_time() * 1000.0` and draws four formatted text lines using `draw_text` with MoonBit string interpolation. The program runs until the window is closed.

## Key Takeaways

- MoonBit's string interpolation (`\{expr}`) provides a clean, type-safe alternative to C-style format strings, making text formatting straightforward and less error-prone.
- `get_frame_time` is useful for displaying real-time performance metrics and can be combined with string interpolation for live HUD displays.
- `draw_text` with the default font is the simplest way to render formatted information to screen for debugging or UI purposes.
