# Audio Music Stream

This example demonstrates the basics of streaming music playback using raylib. When you run it, an MP3 file plays in a loop with a progress bar showing the current playback position. You can pause, resume, and restart the music with simple key presses.

## Build and Run

```bash
moon build --target native raylib_audio_music_stream/
./_build/native/debug/build/raylib_audio_music_stream/raylib_audio_music_stream.exe
```

## Controls

- **Space** -- Restart music from the beginning
- **P** -- Pause/resume music

## What It Demonstrates

- **`@raylib.init_audio_device`** and **`@raylib.close_audio_device`** -- Setting up and tearing down the audio subsystem.
- **`@raylib.load_music_stream`** -- Loading an MP3 file for streaming playback (as opposed to loading the entire file into memory).
- **`@raylib.play_music_stream`**, **`@raylib.stop_music_stream`**, **`@raylib.pause_music_stream`**, **`@raylib.resume_music_stream`** -- Complete transport controls for music.
- **`@raylib.update_music_stream`** -- The essential per-frame call that feeds new audio data into the streaming buffer.
- **`@raylib.get_music_time_played`** and **`@raylib.get_music_time_length`** -- Computing a normalized playback position (0.0 to 1.0) for the progress bar.
- **Progress bar rendering** -- A simple layered rectangle approach: background bar, filled portion proportional to time played, and an outline.

## Public API Reference

### Package `raylib_audio_music_stream`

> Single-package example.

No public API -- self-contained main function.

## Architecture

1. **Initialization** -- Window and audio device are created, an MP3 music stream is loaded and playback begins at 30 FPS.
2. **Main loop** -- Each frame calls `update_music_stream` to keep the buffer filled, checks for Space (restart) and P (pause/resume) key presses, computes the normalized time played, and draws the status text and progress bar.
3. **Cleanup** -- Unloads the music stream, closes the audio device and window.

## Key Takeaways

- Music streaming is the preferred approach for long audio files since it loads data incrementally rather than all at once, and `update_music_stream` must be called every frame.
- The pause/resume pattern using a boolean toggle with `pause_music_stream` / `resume_music_stream` is the standard way to implement playback pause in raylib.
- Normalized time (played / length) is a clean way to drive progress bar rendering without worrying about absolute durations.
