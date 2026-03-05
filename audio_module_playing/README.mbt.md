# Audio Module Playing

This example demonstrates streaming playback of a tracker module file (XM format) using raylib's music stream API. When you run it, an XM music file plays while colorful circles animate on screen, fading in and out. A progress bar at the bottom shows the current playback position, and you can pause, restart, or adjust the playback pitch.

## Build and Run

```bash
moon build --target native audio_module_playing/
./_build/native/debug/build/audio_module_playing/audio_module_playing.exe
```

## Controls

- **Space** -- Restart music (stop and play from beginning)
- **P** -- Pause/resume music
- **Up/Down Arrow Keys** -- Increase/decrease playback pitch

## What It Demonstrates

- **`@raylib.load_music_stream`** -- Loading a tracker module file (`.xm` format) for streaming playback.
- **`@raylib.play_music_stream`**, **`@raylib.stop_music_stream`**, **`@raylib.pause_music_stream`**, **`@raylib.resume_music_stream`** -- Full transport control for music streams.
- **`@raylib.update_music_stream`** -- Required per-frame call to feed audio data to the streaming buffer.
- **`@raylib.set_music_pitch`** -- Real-time pitch adjustment of the playing music.
- **`@raylib.get_music_time_played`** and **`@raylib.get_music_time_length`** -- Querying playback position for the progress bar.
- **`@raylib.fade`** -- Applying alpha transparency to colors for the animated circle effects.
- **`@raylib.set_config_flags(FlagMsaa4xHint)`** -- Enabling 4x MSAA anti-aliasing before window creation.
- **Visual circle animation** -- 64 circles with random positions, sizes, and colors animate by fading in/out and growing, resetting when their alpha reaches zero.

## Public API Reference

### Package `audio_module_playing`

> Single-package example.

No public API -- self-contained main function.

## Architecture

1. **Initialization** -- MSAA hint is set, window and audio device are created, 14 predefined colors are defined, and 64 circles are initialized with random properties. An XM music file is loaded and playback begins.
2. **Main loop** -- Each frame updates the music stream, handles input (Space to restart, P to pause/resume, Up/Down to adjust pitch), animates circles when not paused (incrementing alpha and radius, resetting on fade-out), and draws all circles plus a progress bar and help text.
3. **Cleanup** -- Unloads the music stream, closes the audio device and window.

## Key Takeaways

- Raylib supports tracker module formats (XM, MOD, etc.) through its music stream API, and `update_music_stream` must be called every frame to keep the audio buffer filled.
- Pitch can be adjusted in real time with `set_music_pitch`, allowing dynamic speed/pitch changes during playback.
- The `fade` function is a convenient way to create semi-transparent color effects for visual animations alongside audio playback.
