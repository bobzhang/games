# Core Clipboard Text

This example demonstrates system clipboard read and write operations using raylib and raygui. When you run it, you see a text editor interface with buttons for Cut, Copy, Paste, and Clear operations, plus a text box for input and a read-only display of the current clipboard contents. Both GUI buttons and keyboard shortcuts (Ctrl+X/C/V) are supported.

## Build and Run

```bash
moon build --target native core_clipboard_text/
./_build/native/debug/build/core_clipboard_text/core_clipboard_text.exe
```

## Controls

- **Ctrl+X** -- Cut text to clipboard
- **Ctrl+C** -- Copy text to clipboard
- **Ctrl+V** -- Paste text from clipboard
- **GUI Buttons** -- CUT, COPY, PASTE, CLEAR, and Random text (dice icon)
- **Click text box** -- Toggle edit mode for typing

## What It Demonstrates

- **`@raylib.set_clipboard_text`** -- Writing text to the system clipboard, making it available to other applications.
- **`@raylib.get_clipboard_text`** -- Reading text from the system clipboard, including text copied from external applications.
- **`@raygui.gui_text_box`** -- An interactive text input box with edit mode toggle. Uses a `Ref[String]` for the text buffer.
- **`@raygui.gui_button`** -- Clickable buttons with icon codes (e.g., `"#17#CUT"`, `"#16#COPY"`).
- **`@raygui.gui_label`** -- Static text labels for instructions and status display.
- **`@raygui.gui_set_style`** -- Configuring GUI appearance (text size, icon scale, read-only mode for text boxes).
- **`@raygui.gui_disable`** / **`@raygui.gui_enable`** -- Disabling interactive elements for read-only display sections.
- **Keyboard shortcuts with modifier keys** -- Using `is_key_down` for Left/Right Ctrl and `is_key_pressed` for X/C/V to implement standard clipboard shortcuts.
- **MoonBit pattern: `Ref[String]` for mutable string** -- The text input buffer uses `Ref[String]` since raygui's `gui_text_box` requires a mutable string reference.

## Public API Reference

### Package `core_clipboard_text`

> Single-package example.

No public API -- self-contained main function.

## Architecture

1. **Initialization** -- Window is created, sample texts are defined, raygui style is configured (text size 20, icon scale 2), and input/clipboard state variables are initialized.
2. **Main loop** -- Each frame processes button press results from the previous frame (cut, copy, paste, clear, random), handles keyboard shortcuts (Ctrl+X/C/V), then draws the GUI: an instruction label, the editable text box with a random button, four action buttons (Cut/Copy/Paste/Clear), and a disabled read-only section showing the current clipboard contents.
3. **Cleanup** -- Window is closed.

## Key Takeaways

- Raylib's clipboard functions (`set_clipboard_text` / `get_clipboard_text`) provide cross-platform access to the system clipboard, enabling interoperability with other applications.
- The raygui library provides immediate-mode GUI widgets that integrate naturally with the raylib drawing loop -- functions like `gui_button` return a boolean indicating whether the button was pressed.
- Using `Ref[String]` as a mutable string container is a MoonBit pattern required by raygui's text box API, which needs to modify the string in place.
