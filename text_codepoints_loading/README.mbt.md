# Text: Codepoints Loading

This example demonstrates how to load a font with only the specific Unicode codepoints needed for a given text, rather than loading the entire character set. When you run it, you see Japanese hiragana text (the Iroha poem) rendered with a custom TTF font, with the ability to toggle between the rendered text and the generated font atlas texture.

## Build and Run

```bash
moon build --target native text_codepoints_loading/
./_build/native/debug/build/text_codepoints_loading/text_codepoints_loading.exe
```

## Controls

- **Space**: Toggle between displaying the rendered text and the font texture atlas

## What It Demonstrates

- **Codepoint extraction**: `load_codepoints` converts a UTF-8 string into an array of integer codepoints, allowing analysis of which characters the text actually uses.
- **Duplicate codepoint removal**: A custom `codepoint_remove_duplicates` function filters out repeated codepoints so the font atlas contains only unique glyphs, reducing texture memory.
- **Selective font loading**: `load_font_ex_codepoints` loads a TTF font (`DotGothic16-Regular.ttf`) and generates a texture atlas containing only the specified codepoints, instead of loading the default ASCII range or the entire font.
- **Bilinear texture filtering**: `set_font_texture_filter` with bilinear filtering (mode 1) improves font rendering quality at non-native sizes.
- **Font atlas visualization**: The generated font texture atlas is displayed via `get_font_texture` and `draw_texture`, showing how raylib packs glyph bitmaps into a single texture.
- **Multi-line text rendering**: `set_text_line_spacing` configures line spacing, and `draw_text_ex` renders the multi-line Japanese text.

## Public API Reference

### Package `text_codepoints_loading`

> Single-package example.

- `codepoint_remove_duplicates(codepoints : Array[Int]) -> Array[Int]` -- Removes duplicate codepoints from an array, returning a new array with unique values only.

## Architecture

The program loads a Japanese poem as a UTF-8 string, extracts its codepoints, removes duplicates, and uses the unique codepoints to load only the necessary glyphs from a TTF font file. In the main loop, pressing Space toggles between drawing the rendered text with `draw_text_ex` and displaying the raw font texture atlas with `draw_texture`. The header bar shows the total codepoint count and the deduplicated count. On exit, the font is unloaded.

## Key Takeaways

- Loading fonts with only the required codepoints significantly reduces the font atlas size, which is especially important for CJK and other large character sets.
- `load_codepoints` paired with custom deduplication logic gives fine-grained control over which glyphs are included in the font texture.
- Viewing the font atlas texture is a useful debugging technique to verify that glyph packing and codepoint selection are working correctly.
