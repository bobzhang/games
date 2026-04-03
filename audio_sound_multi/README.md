# Audio Sound Multi

This example demonstrates how to play the same sound effect multiple times simultaneously using raylib's sound alias system. When you run it, pressing Space rapidly triggers overlapping playback of a WAV sound without cutting off previous instances.

## Build and Run

```bash
moon build --target native audio_sound_multi/
./_build/native/debug/build/audio_sound_multi/audio_sound_multi.exe
```

## Controls

- **Space** -- Play the WAV sound (can be pressed rapidly for overlapping playback)

## What It Demonstrates

- **`@raylib.load_sound`** -- Loading the original sound that owns the audio sample data.
- **`@raylib.load_sound_alias`** -- Creating aliases that share the same audio buffer as the original sound but can be played independently. This avoids duplicating audio data in memory.
- **`@raylib.play_sound`** -- Playing individual sound aliases to achieve overlapping playback.
- **`@raylib.unload_sound_alias`** -- Freeing alias handles (which do not free the shared audio data).
- **`@raylib.unload_sound`** -- Freeing the original sound and its audio data.
- **Round-robin sound slot pattern** -- A `current_sound` index cycles through the array of aliases (0 through 9), ensuring that each new press plays on a different slot, allowing up to 10 simultaneous overlapping instances.

## Public API Reference

### Package `audio_sound_multi`

> Single-package example.

No public API -- self-contained main function.

## Architecture

1. **Initialization** -- Window and audio device are created. One source sound is loaded, then 9 aliases are created from it, giving 10 total playback slots.
2. **Main loop** -- Each frame checks for Space key press. When pressed, the sound at the current slot index is played, and the index wraps around to 0 after reaching the maximum.
3. **Cleanup** -- All 9 aliases are unloaded first (they do not own the audio data), then the original source sound is unloaded, followed by audio device and window closure.

## Key Takeaways

- Sound aliases (`load_sound_alias`) share the underlying audio buffer with the original sound, allowing multiple simultaneous playback instances without duplicating memory.
- A round-robin index over an array of aliases is the standard pattern for polyphonic sound effects -- each press uses the next available slot.
- Aliases must be unloaded before the source sound, since they reference the source's audio data.
