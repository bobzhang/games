# Core Automation Events

This example demonstrates raylib's automation event system for recording and replaying input events in a simple platformer scene. When you run it, you can control a player character on platforms, record your input sequences, export them to a file, and replay them -- useful for automated testing, demos, and replay systems.

## Build and Run

```bash
moon build --target native core_automation_events/
./_build/native/debug/build/core_automation_events/core_automation_events.exe
```

## Controls

- **Left/Right Arrow Keys** -- Move player horizontally
- **Space** -- Jump (when on a platform)
- **R** -- Reset game state (player position and camera)
- **S** -- Start/stop recording input events (exports to `automation.rae`)
- **A** -- Replay the last recorded events
- **Mouse Wheel** -- Zoom camera in/out
- **Drop a `.rae` or `.txt` file** -- Load and replay an automation event file

## What It Demonstrates

- **`@raylib.load_automation_event_list`** -- Loading an automation event list from a file (or creating an empty one with an empty string).
- **`@raylib.set_automation_event_list`** -- Setting the active event list for recording.
- **`@raylib.start_automation_event_recording`** and **`@raylib.stop_automation_event_recording`** -- Starting and stopping input event capture.
- **`@raylib.set_automation_event_base_frame`** -- Setting the frame offset for recording.
- **`@raylib.export_automation_event_list`** -- Saving recorded events to a `.rae` file.
- **`@raylib.play_automation_event`** -- Replaying individual events during playback.
- **`@raylib.automation_event_list_count`** and **`@raylib.automation_event_list_get`** -- Accessing events by index during playback.
- **`@raylib.is_file_dropped`** / **`@raylib.load_dropped_files`** -- Handling drag-and-drop file input for loading event files.
- **Simple platformer with physics** -- Gravity, jumping, horizontal movement, and collision with blocking rectangles.
- **Camera with map boundary clamping** -- Same technique as the 2D camera platformer example, keeping the view within map bounds.

## Public API Reference

### Package `core_automation_events`

> Single-package example.

No public API -- self-contained main function.

## Architecture

1. **Initialization** -- Window is created, player state and 5 environment platforms are defined, camera is set up, and an empty automation event list is loaded and set as active.
2. **Main loop** -- Each frame handles file drops (loading `.rae` files and starting replay), player physics (movement, gravity, collision), camera updates with boundary clamping, and automation controls (S to toggle recording, A to start replay). During replay, events are played frame-by-frame using `play_automation_event` matched to the current frame counter. Visual indicators (red circle for recording, green triangle for playing) show the automation state.
3. **Cleanup** -- Window is closed.

## Key Takeaways

- Raylib's automation event system captures all input events (keyboard, mouse, etc.) with frame-accurate timing, enabling deterministic replay when the game state is reset to the same initial conditions.
- The recording/playback workflow is: load/create event list, set it active, record with start/stop, export to file, then replay by iterating events matched to frame counters.
- This system is valuable for automated testing, creating game demos, and implementing replay functionality.
