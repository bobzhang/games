# Text: Input Box

This example demonstrates a basic text input box with mouse hover detection, character input handling, and a blinking cursor. When you run it, you see a text input field that activates when you hover the mouse over it, accepts keyboard input of printable ASCII characters, and displays a blinking underscore cursor.

## Build and Run

```bash
moon build --target native raylib_text_input_box/
./_build/native/debug/build/raylib_text_input_box/raylib_text_input_box.exe
```

## Controls

- **Mouse hover over input box**: Activate the input field (cursor changes to I-beam)
- **Type characters**: Enter text (printable ASCII characters 32-125, up to 9 characters)
- **Backspace**: Delete the last character

## What It Demonstrates

- **Mouse-rectangle collision**: `check_collision_point_rec` detects whether the mouse cursor is over the text box rectangle, triggering visual feedback and enabling input.
- **Custom cursor management**: `set_mouse_cursor` switches between `MouseCursorDefault` and `MouseCursorIbeam` based on hover state.
- **Character input queue**: `get_char_pressed` retrieves Unicode characters from the input queue in a `while` loop, handling multiple keypresses per frame.
- **Key press detection**: `is_key_pressed` with `KeyBackspace` handles character deletion via a custom `string_take` helper.
- **Blinking cursor animation**: A frame counter with modular arithmetic (`frames_counter / 20 % 2 == 0`) creates a blinking underscore effect drawn with `draw_text`.
- **Text measurement for cursor placement**: `measure_text` computes the pixel width of the current text to position the blinking cursor correctly after the last character.
- **String interpolation for counters**: `"INPUT CHARS: \{letter_count}/\{max_input_chars}"` displays the character count using MoonBit interpolation.

## Public API Reference

### Package `raylib_text_input_box`

> Single-package example.

- `string_take(s : String, n : Int) -> String` -- Returns the first `n` characters of a string, or the full string if shorter than `n`.

## Architecture

The program creates a text box rectangle centered horizontally on screen. Each frame, it checks mouse-box collision to determine hover state. When hovering, character input is read from `get_char_pressed` in a loop and appended to the name string (up to 9 characters, ASCII 32-125). Backspace truncates the string using `string_take`. The drawing phase renders the box with a colored border (red when hovered, dark gray otherwise), the current text in maroon, a character count indicator, and a blinking underscore cursor when the box is active and not full.

## Key Takeaways

- `get_char_pressed` must be called in a loop to drain the entire input queue, as multiple characters can be pressed in a single frame.
- Blinking cursor effects are easily achieved with a simple frame counter and modular arithmetic, without needing timer callbacks.
- Combining `check_collision_point_rec` with `set_mouse_cursor` creates an intuitive text input interaction pattern similar to native UI text fields.
