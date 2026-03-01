# Directory Files

This example demonstrates raylib's file system utilities for listing directory contents. It displays the current directory path and a scrollable list of files, with optional filtering by extension. A back button navigates to the parent directory.

## Build and Run

```bash
moon build --target native raylib_core_directory_files/
./_build/native/debug/build/raylib_core_directory_files/raylib_core_directory_files.exe
```

## Controls

- Click the **<** button to navigate to the parent directory
- Scroll and click in the file list to browse directory contents

## What It Demonstrates

- `@raylib.get_working_directory()` to retrieve the current working directory path
- `@raylib.load_directory_files_ex()` to list files in a directory with an extension filter (e.g., `.png;.c`) and optional recursive scanning
- `@raylib.load_directory_files()` to list all files in a directory without filtering
- `@raylib.get_prev_directory_path()` to navigate to the parent directory
- `@raylib.unload_directory_files()` to properly free the file path list when no longer needed
- `@raylib.file_path_list_count()` and `@raylib.file_path_list_get()` to iterate over a `FilePathList`
- Raygui widgets: `gui_button` for the back button, `gui_label` for the directory path, and `gui_list_view_ex` for the scrollable file list with selection tracking

## Public API Reference

### Package `raylib_core_directory_files`

> Single-package example.

No public API -- self-contained main function. The helper function `file_path_list_to_array` converts a raylib `FilePathList` to a MoonBit `Array[String]` for use with raygui's list view.

## Architecture

The program starts by loading the current working directory's file list (filtered to `.png` and `.c` files). Each frame, if the back button was pressed, it navigates to the parent directory and reloads the file list. The raygui `gui_list_view_ex` widget handles scrolling and item selection. On exit, the file list is unloaded to free memory.

## Key Takeaways

- Raylib provides cross-platform file system utilities for directory listing and navigation, accessible without platform-specific code.
- The `FilePathList` type requires explicit unloading via `unload_directory_files` to avoid memory leaks, following raylib's resource management pattern.
- Raygui's `gui_list_view_ex` provides a ready-made scrollable list widget that works well for file browser UIs.
