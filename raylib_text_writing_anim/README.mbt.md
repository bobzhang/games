# Text: Writing Animation

This example demonstrates a typewriter-style text writing animation effect. When you run it, you see a message being revealed character by character over time, with the ability to speed up the animation or restart it.

## Build and Run

```bash
moon build --target native raylib_text_writing_anim/
./_build/native/debug/build/raylib_text_writing_anim/raylib_text_writing_anim.exe
```

## Controls

- **Space (hold)**: Speed up the writing animation (8x faster)
- **Enter**: Restart the animation from the beginning

## What It Demonstrates

- **Text substring extraction**: A custom `text_subtext` function extracts the first N characters of a string using `StringBuilder`, simulating the progressive reveal of text.
- **Frame-based animation timing**: A frame counter incremented each frame (divided by 10) controls how many characters are visible, creating a steady character reveal rate at approximately 6 characters per second at 60 FPS.
- **Speed control**: Holding Space increases the counter increment from 1 to 8 per frame via `is_key_down`, making the text appear 8x faster.
- **Animation reset**: Pressing Enter resets `frames_counter` to 0 via `is_key_pressed`, restarting the reveal from the first character.
- **Multi-line text animation**: The message contains a `\n` newline, demonstrating that the typewriter effect works naturally with multi-line text rendered by `draw_text`.

## Public API Reference

### Package `raylib_text_writing_anim`

> Single-package example.

- `text_subtext(text : String, end_pos : Int) -> String` -- Returns the first `end_pos` characters of a string, clamped to the string length.

## Architecture

The program initializes a message string and a frame counter set to 0. Each frame, the counter increments (by 1 normally, by 8 when Space is held via `is_key_down`), and pressing Enter resets it to 0. The visible portion of the message is extracted using `text_subtext(message, frames_counter / 10)` and drawn with `draw_text` at position (210, 160). Helper text for controls is displayed below.

## Key Takeaways

- A typewriter text animation is trivially implemented by incrementally revealing a substring based on a frame counter, without any complex animation system.
- Frame counter division (e.g., `/10`) provides a simple way to control animation speed relative to the frame rate.
- `StringBuilder` in MoonBit provides an efficient way to build substrings character by character for text manipulation.
