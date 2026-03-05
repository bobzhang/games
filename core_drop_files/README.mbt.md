# Drop Files

This example demonstrates raylib's drag-and-drop file detection. When you drag files onto the window, their paths are displayed in an alternating-shade list. Additional files can be dropped at any time and are appended to the list.

## Build and Run

```bash
moon build --target native core_drop_files/
./_build/native/debug/build/core_drop_files/core_drop_files.exe
```

## Controls

- Drag and drop files onto the window to see their paths listed

## What It Demonstrates

- `@raylib.is_file_dropped()` to check whether files have been dropped onto the window in the current frame
- `@raylib.load_dropped_files()` to retrieve the list of dropped file paths as a `FilePathList`
- `@raylib.file_path_list_count()` and `@raylib.file_path_list_get()` to iterate over dropped file entries
- `@raylib.unload_dropped_files()` to free the dropped file path list after extracting the data
- `@raylib.fade()` to create semi-transparent background colors for alternating list rows

## Public API Reference

### Package `core_drop_files`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes an 800x450 window and maintains a growing `Array[String]` of file paths. Each frame, `is_file_dropped()` is checked; when true, the dropped file list is loaded, its entries are pushed onto the array, and the list is unloaded. The draw phase renders either a prompt message or the accumulated file paths with alternating row backgrounds.

## Key Takeaways

- Raylib handles OS-level drag-and-drop events transparently; just check `is_file_dropped()` each frame and process the results.
- The dropped file list must be unloaded with `unload_dropped_files()` after copying the data you need, following raylib's manual resource management convention.
- Accumulating dropped paths into a MoonBit `Array[String]` decouples the ephemeral raylib resource from long-lived application state.
