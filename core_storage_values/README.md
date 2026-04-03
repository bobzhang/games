# Storage Values

This example demonstrates saving and loading integer values to and from a binary file using raylib's file I/O functions. A score and hi-score can be generated randomly, saved to `storage.data`, and loaded back, showing how to implement simple persistent storage.

## Build and Run

```bash
moon build --target native core_storage_values/
./_build/native/debug/build/core_storage_values/core_storage_values.exe
```

## Controls

- **R** -- generate random score (1000-2000) and hi-score (2000-4000) values
- **Enter** -- save current values to `storage.data`
- **Space** -- load previously saved values from `storage.data`

## What It Demonstrates

- `@raylib.load_file_data()` to read raw bytes from a binary file
- `@raylib.save_file_data()` to write raw bytes to a binary file
- `@raylib.get_random_value()` to generate random integers within a range
- Manual little-endian byte serialization of 32-bit integers using bitwise operations (`&`, `>>`, `<<`, `|`)
- `FixedArray::unsafe_reinterpret_as_bytes()` for zero-copy conversion from `FixedArray[Byte]` to `Bytes`
- Position-based storage: each value is stored at a specific slot (offset = position * 4 bytes)

## Public API Reference

### Package `core_storage_values`

> Single-package example.

No public API -- self-contained main function. Helper functions `save_storage_value` and `load_storage_value` are package-private utilities that handle byte-level serialization.

## Architecture

The program maintains a score and hi-score. Pressing R generates random values. Pressing Enter calls `save_storage_value` for positions 0 and 1, which loads the existing file (if any), extends it if necessary, writes the integer as four little-endian bytes at the correct offset, and saves the file back. Pressing Space calls `load_storage_value`, which reads the file and extracts the integer from the appropriate offset. The values and key instructions are displayed on screen.

## Key Takeaways

- Raylib's `load_file_data` and `save_file_data` provide low-level binary file I/O that can be used to build custom persistence systems.
- Manual byte-level serialization with bitwise operations gives full control over the binary format, which is important for cross-platform compatibility.
- The position-based slot pattern (each value at `position * 4` bytes) is a simple approach to storing multiple named values in a single binary file.
