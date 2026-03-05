# Compute Hash

This example demonstrates raylib's built-in cryptographic hashing and Base64 encoding functions. It presents a GUI (powered by raygui) where the user can type text into an input box, click a button to compute hashes, and see the resulting CRC32, MD5, and SHA1 hash values along with the Base64-encoded representation of the input.

## Build and Run

```bash
moon build --target native core_compute_hash/
./_build/native/debug/build/core_compute_hash/core_compute_hash.exe
```

## Controls

- Click the text box to edit the input string
- Click "COMPUTE INPUT DATA HASHES" to compute all hash values and Base64 encoding

## What It Demonstrates

- `@raylib.compute_crc32()` to compute a 32-bit CRC32 checksum of arbitrary byte data
- `@raylib.compute_md5()` to compute a 128-bit MD5 hash, returned as 16 bytes
- `@raylib.compute_sha1()` to compute a 160-bit SHA1 hash, returned as 20 bytes
- `@raylib.encode_data_base64()` to encode binary data into a Base64 string
- raygui integration with `@raygui.gui_text_box()` for editable text input, `@raygui.gui_button()` for triggering actions, and `@raygui.gui_label()` for display labels
- `@raygui.gui_set_style()` to customize text size, spacing, and read-only mode for text boxes
- Manual byte conversion helpers (`string_to_bytes`, `int_to_hex`, `bytes_to_hex`) for bridging MoonBit strings to raylib's byte-oriented API

## Public API Reference

### Package `core_compute_hash`

> Single-package example.

No public API -- self-contained main function. The helper functions `string_to_bytes`, `int_to_hex`, and `bytes_to_hex` are package-private utilities for data conversion.

## Architecture

The program initializes an 800x450 window with raygui styling. On each frame it checks if the compute button was pressed; if so, it converts the input string to bytes and calls `compute_crc32`, `compute_md5`, `compute_sha1`, and `encode_data_base64`. The results are displayed in read-only text boxes. The GUI layout uses raygui labels, editable text boxes, and a button, with text style changes for section headers.

## Key Takeaways

- Raylib provides built-in utility functions for common hashing algorithms (CRC32, MD5, SHA1) and Base64 encoding, accessible directly from MoonBit via the raylib bindings.
- Raygui widgets like `gui_text_box` and `gui_button` can be combined to build simple interactive tool UIs without custom widget code.
- MoonBit's `Ref[String]` type is used to pass mutable string references to raygui text box widgets, matching the C API's pointer-based interface.
