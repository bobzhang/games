# Audio Stream Effects

This example demonstrates how to attach and detach real-time audio effects to a music stream using raylib's stream processor API. When you run it, music plays with a progress bar, and you can toggle a low-pass filter (LPF) effect and a delay (echo) effect independently.

## Build and Run

```bash
moon build --target native raylib_audio_stream_effects/
./_build/native/debug/build/raylib_audio_stream_effects/raylib_audio_stream_effects.exe
```

## Controls

- **Space** -- Restart music from the beginning
- **P** -- Pause/resume music
- **F** -- Toggle low-pass filter effect on/off
- **D** -- Toggle delay (echo) effect on/off

## What It Demonstrates

- **`@raylib.attach_music_stream_processor`** and **`@raylib.detach_music_stream_processor`** -- Attaching and detaching per-stream audio processor callbacks at runtime. Unlike `attach_audio_mixed_processor`, these affect only a specific music stream.
- **Low-pass filter (LPF) implementation** -- A simple one-pole LPF with a 70 Hz cutoff applied to stereo audio. The filter state is stored in a `FixedArray[Float]` for left and right channels.
- **Delay/echo effect implementation** -- A circular buffer of 96000 samples (1 second at 48 kHz stereo) with separate read and write indices, mixing 50% dry signal with 50% delayed signal.
- **`@raylib.audio_buffer_get_sample`** and **`@raylib.audio_buffer_set_sample`** -- Per-sample read/write access within the processor callbacks.
- **MoonBit pattern: `FixedArray` for callback-accessible state** -- Filter state (`low`), delay buffer (`delay_buffer`), and read/write indices are stored as module-level `FixedArray` values to allow mutation from within the audio callback context.
- **MoonBit pattern: `FuncRef` for callback binding** -- Both `audio_process_effect_lpf` and `audio_process_effect_delay` are `FuncRef` values wrapping implementation functions.

## Public API Reference

### Package `raylib_audio_stream_effects`

> Single-package example.

No public API -- self-contained main function. The following module-level declarations support the audio effects:

- `let low : FixedArray[Float]` -- LPF state for left and right channels.
- `const DelayBufferSize : Int` -- Size of the delay buffer (96000 samples).
- `let delay_buffer : FixedArray[Float]` -- Circular buffer for the delay effect.
- `let delay_read_index : FixedArray[Int]` and `let delay_write_index : FixedArray[Int]` -- Read/write cursors for the delay ring buffer.
- `fn audio_process_effect_lpf_impl(AudioBuffer, UInt) -> Unit` -- LPF processor implementation.
- `fn audio_process_effect_delay_impl(AudioBuffer, UInt) -> Unit` -- Delay processor implementation.
- `let audio_process_effect_lpf : FuncRef[...]` and `let audio_process_effect_delay : FuncRef[...]` -- FuncRef wrappers for attachment.

## Architecture

1. **Initialization** -- Window and audio device are created, music is loaded and playback begins. Effect state arrays are initialized at module level.
2. **Main loop** -- Each frame updates the music stream, handles transport controls (Space, P), and toggles effects (F for LPF, D for delay) by attaching or detaching the corresponding processor callback. A progress bar and status indicators for each effect are drawn.
3. **Audio callbacks** -- The LPF callback applies a one-pole low-pass filter per sample. The delay callback reads from a circular buffer, mixes 50/50 with the current sample, and writes the result back to both the output and the delay buffer.
4. **Cleanup** -- Music stream is unloaded, audio device and window are closed.

## Key Takeaways

- Per-stream processors (`attach_music_stream_processor`) allow effects to be applied to individual streams rather than the global mix, and they can be dynamically attached/detached at runtime.
- Audio DSP effects in MoonBit require storing filter state in module-level `FixedArray` values since the callback functions cannot capture mutable local variables.
- The delay effect demonstrates a classic circular buffer pattern with separate read/write indices, which is fundamental to many audio effects (echo, reverb, chorus).
