# Text: Rectangle Bounds

This example demonstrates word-wrapped text rendering inside a resizable container rectangle with text selection support. When you run it, you see a block of text constrained within a bordered rectangle that can be resized by dragging a corner handle, with a toggle for word wrap mode.

## Build and Run

```bash
moon build --target native text_rectangle_bounds/
./_build/native/debug/build/text_rectangle_bounds/text_rectangle_bounds.exe
```

## Controls

- **Space**: Toggle word wrap on/off
- **Left mouse button (drag corner handle)**: Resize the text container

## What It Demonstrates

- **Custom bounded text rendering**: `draw_text_boxed` implements text drawing constrained to a rectangle, with proper word wrapping and overflow clipping -- rendering stops when text exceeds the container height.
- **Word wrap algorithm**: A two-state machine (measure state and draw state) scans ahead to find word boundaries (spaces, tabs, newlines), then draws characters line by line. The measure state determines where to break lines; the draw state renders glyphs with `draw_text_codepoint`.
- **Text selection highlighting**: `draw_text_boxed_selectable` extends the bounded renderer with selection support, drawing colored backgrounds behind selected characters using `draw_rectangle_rec` with configurable `select_tint` and `select_back_tint`.
- **Codepoint-based text processing**: `load_codepoints` converts text to integer codepoints, and `get_glyph_info`/`get_glyph_atlas_rec` retrieve per-glyph metrics for manual text layout with proper advance width handling.
- **Interactive container resizing**: Mouse drag on a 14x14 corner handle resizes the container with clamping to min (60x60) and max dimensions.

## Public API Reference

### Package `text_rectangle_bounds`

> Single-package example.

- `draw_text_boxed(font, text, rec, font_size, spacing, word_wrap, tint) -> Unit` -- Draws text constrained within a rectangle, with optional word wrapping.
- `draw_text_boxed_selectable(font, text, rec, font_size, spacing, word_wrap, tint, select_start, select_length, select_tint, select_back_tint) -> Unit` -- Extended version that supports text selection highlighting with configurable foreground and background tints.

## Architecture

The program initializes a resizable container rectangle (25, 25) with a corner drag handle. Each frame, it processes mouse input for resizing (tracking drag state, computing delta, clamping dimensions) and Space key for word wrap toggling. The text is rendered inside the container using `draw_text_boxed` with the default font at size 20 and spacing 2. The container border changes color on hover (`fade` with 0.4 alpha), and the resize handle, word-wrap status, and instructions are drawn below.

## Key Takeaways

- Implementing word-wrapped text rendering requires a two-pass approach: first measuring to find line break positions at word boundaries, then drawing the actual characters.
- Codepoint-level text processing with `load_codepoints` and `get_glyph_info` gives the fine-grained control needed for custom text layout algorithms that handle tabs, spaces, and newlines correctly.
- A resizable container with clamped dimensions provides a good testing framework for verifying that text rendering handles various aspect ratios and overflow conditions correctly.
