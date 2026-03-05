# Network: Async HTTP Fetch

This example demonstrates asynchronous HTTP networking combined with a raylib rendering loop using MoonBit's async runtime. When you run it, the application fetches the HTML content of `https://example.com` in the background while displaying a loading message. Once the response arrives, the fetched text is displayed in a scrollable view with a header bar showing the URL and a footer bar showing line count and scroll position.

## Build and Run

```bash
moon build --target native network_curl/
./_build/native/debug/build/network_curl/network_curl.exe
```

## Controls

- **Up/Down Arrows** -- Scroll one line up/down
- **Page Up/Page Down** -- Scroll one page at a time
- **Mouse Wheel** -- Scroll content

## What It Demonstrates

- **MoonBit async/await with raylib**: Uses `async fn main` along with `@async.with_task_group` to run an HTTP fetch task concurrently with the render loop. The `@async.pause()` call yields control each frame, allowing the async runtime to process background tasks.
- **Async HTTP client**: Uses `@http.get_stream` from `moonbitlang/async/http` to perform a non-blocking HTTP GET request, reading the response body with `read_all().text()`.
- **Shared mutable state between tasks**: The `AppState` struct is shared between the HTTP fetch task and the render loop. Since MoonBit's async runtime is single-threaded, this is safe without synchronization primitives.
- **Text rendering with scrolling**: Implements a scrollable text viewer with line wrapping via the `split_lines` helper, arrow key and mouse wheel input handling, and visible line range calculation.

## Public API Reference

### Package `network_curl`

> Single-package example.

No public API -- self-contained async main function. The `AppState` struct and `split_lines` helper are package-level but not exported.

## Architecture

The async main function initializes a raylib window, creates a shared `AppState`, and enters a task group. A background task performs the HTTP fetch, updating `state.lines` and `state.status` upon completion (or recording an error). The main render loop calls `@async.pause()` each frame to cooperate with the async scheduler, then processes scroll input (arrow keys, page keys, mouse wheel) and renders the UI: a dark blue header bar with the URL, the scrollable text content in the middle, and a gray footer bar with status information. When the window closes, `with_task_group` automatically cancels any remaining background tasks.

## Key Takeaways

- MoonBit's async runtime integrates cleanly with raylib's frame loop by using `@async.pause()` to yield each frame, enabling concurrent I/O without threads or callbacks.
- `@async.with_task_group` and `group.spawn_bg` provide structured concurrency where background tasks are automatically cancelled when the group scope exits.
- Sharing mutable state between async tasks is straightforward in MoonBit's single-threaded async model, avoiding the complexity of locks or channels.
