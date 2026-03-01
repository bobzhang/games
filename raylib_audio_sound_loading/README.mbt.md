# Audio Sound Loading

This example demonstrates the basics of loading and playing sound effects using raylib. When you run it, a window displays instructions for playing two different sound files -- a WAV and an OGG -- triggered by key presses.

## Build and Run

```bash
moon build --target native raylib_audio_sound_loading/
./_build/native/debug/build/raylib_audio_sound_loading/raylib_audio_sound_loading.exe
```

## Controls

- **Space** -- Play WAV sound
- **Enter** -- Play OGG sound

## What It Demonstrates

- **`@raylib.init_audio_device`** and **`@raylib.close_audio_device`** -- Initializing and shutting down the audio subsystem, which must bracket all audio operations.
- **`@raylib.load_sound`** -- Loading sound files from disk. Both WAV and OGG formats are supported.
- **`@raylib.play_sound`** -- Triggering one-shot playback of a loaded sound effect.
- **`@raylib.unload_sound`** -- Properly freeing sound resources before closing the audio device.
- **`@raylib.is_key_pressed`** -- Detecting single key press events (not held) for triggering discrete actions.

## Public API Reference

### Package `raylib_audio_sound_loading`

> Single-package example.

No public API -- self-contained main function.

## Architecture

1. **Initialization** -- Window and audio device are created, then two sound files (WAV and OGG) are loaded into memory.
2. **Main loop** -- Each frame checks for Space and Enter key presses, playing the corresponding sound effect. The screen displays usage instructions.
3. **Cleanup** -- Both sounds are unloaded, then the audio device and window are closed.

## Key Takeaways

- Sound effects loaded with `load_sound` are fully decompressed into memory, making them suitable for short, frequently-played audio clips like UI sounds or game effects.
- Raylib supports multiple audio formats (WAV, OGG, MP3, etc.) through the same `load_sound` API with no format-specific code needed.
- Always unload sounds before closing the audio device to avoid resource leaks.
