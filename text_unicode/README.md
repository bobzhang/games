# Text: Unicode

This example demonstrates Unicode text rendering with multiple scripts, emoji display, and multi-language message display using BMFont files. When you run it, you see a grid of clickable emoji characters, each associated with a random message in one of eleven languages including German, Armenian, Polish, Romanian, Russian, French, Spanish, Greek, Chinese, Japanese, and Korean.

## Build and Run

```bash
moon build --target native text_unicode/
./_build/native/debug/build/text_unicode/text_unicode.exe
```

## Controls

- **Left mouse click on an emoji**: Select it and display its associated message in a chat bubble
- **Space**: Randomize all emoji assignments, colors, and messages

## What It Demonstrates

- **Multi-script font loading**: Three BMFont files are loaded: `dejavu.fnt` for Latin/Cyrillic/Greek scripts, `noto_cjk.fnt` for Chinese/Japanese/Korean, and `symbola.fnt` for emoji rendering.
- **Unicode emoji rendering**: 180 emoji codepoints (U+1F300 to U+1F4A3) are stored as MoonBit Unicode escape strings in the `emoji_codepoints` array and rendered as font glyphs (not image textures) with `draw_text_ex`.
- **Language-aware font selection**: The correct font is chosen at runtime based on the `Message.language` property -- CJK font for Chinese, Japanese, and Korean; the default font for European scripts.
- **Word-wrapped text in chat bubbles**: A custom `draw_text_boxed` function renders word-wrapped text inside dynamically positioned and sized chat bubble rectangles with triangle pointers.
- **Unicode codepoint vs byte counting**: `get_codepoint_count` counts logical characters and `@utf8.encode(...).length()` measures UTF-8 byte length, displayed in the chat bubble info line.
- **HSV color distribution**: Emoji colors use golden-ratio-based hue distribution for visually distinct colors via `color_from_hsv` and `fade`.
- **Screen-edge clamping**: Chat bubble positions are adjusted to stay within screen bounds.

## Public API Reference

### Package `text_unicode`

> Single-package example.

- `EmojiPerWidth : Int` -- Number of emojis per row in the grid (8).
- `EmojiPerHeight : Int` -- Number of emoji rows (4).
- `emoji_codepoints : Array[String]` -- Array of 180 emoji Unicode strings covering faces, food, plants, hearts, and symbols.
- `Message` -- Struct with `text : String` and `language : String` fields.
- `messages : Array[Message]` -- Array of multi-language messages spanning 11 languages.
- `EmojiData` -- Struct with `index : Int` (emoji codepoint index), `message : Int` (message index), and `color : Color` fields.
- `draw_text_boxed(font, text, rec, font_size, spacing, word_wrap, tint) -> Unit` -- Renders word-wrapped text within a rectangle using codepoint-level layout.

## Architecture

The program loads three BMFont files and initializes a grid of 32 random emojis (8x4), each with a random color and message assignment via a local `randomize_emoji` closure. In the main loop, mouse hover highlights emojis and clicking selects one to display its associated message. The selected message appears in a colored chat bubble with a triangle pointer, positioned near the emoji and clamped to screen edges. The font is selected based on the language. Pressing Space calls `randomize_emoji` to refresh. On exit, all three fonts are unloaded.

## Key Takeaways

- Supporting multiple Unicode scripts in a single application requires loading separate font files for different character ranges and selecting the appropriate font based on the text's language or script.
- Emoji characters are regular Unicode codepoints rendered from a font, not image textures, which means they can be styled with tinting, sizing, and spacing like any other text.
- Measuring text with `get_codepoint_count` vs UTF-8 byte length highlights the distinction between logical characters and encoded bytes, which is important for multi-byte text handling.
