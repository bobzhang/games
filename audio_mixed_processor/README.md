# Audio Mixed Processor

This example demonstrates how to attach a custom audio processor callback to raylib's mixed audio output. When you run it, a music stream plays continuously while a real-time volume waveform visualization is drawn on screen. The audio is processed through a power-curve distortion effect controlled by the left/right arrow keys, and a coin sound effect can be triggered with the spacebar to show that all audio goes through the same processor.

## Build and Run

```bash
moon build --target native audio_mixed_processor/
./_build/native/debug/build/audio_mixed_processor/audio_mixed_processor.exe
```

## Controls

- **Left/Right Arrow Keys** -- Decrease/increase the exponent value (controls distortion intensity, clamped 0.5 to 3.0)
- **Space** -- Play a coin sound effect

## What It Demonstrates

- **`@raylib.attach_audio_mixed_processor`** and **`@raylib.detach_audio_mixed_processor`** -- Registering and unregistering a custom callback that processes the final mixed audio output before it reaches the speakers.
- **`@raylib.audio_buffer_get_sample`** and **`@raylib.audio_buffer_set_sample`** -- Reading and writing individual samples in the audio buffer from within the processor callback.
- **Audio distortion via power curve** -- Each sample is raised to a configurable exponent while preserving its sign, creating a nonlinear distortion effect.
- **Real-time waveform visualization** -- A rolling history of 400 average volume values is maintained in a `FixedArray` and rendered as vertical bars.
- **MoonBit pattern: `FixedArray` for mutable global state** -- Since the audio callback cannot capture mutable locals, `FixedArray[Float]` is used for `exponent` and `average_volume` to allow mutation from the callback context.
- **MoonBit pattern: `FuncRef` for callbacks** -- The `process_audio` binding wraps the implementation function via a `FuncRef` lambda, which is the required type for raylib audio processor attachment.

## Public API Reference

### Package `audio_mixed_processor`

> Single-package example.

No public API -- self-contained main function. The following module-level declarations are used internally:

- `let exponent : FixedArray[Float]` -- Audio exponentiation value (mutable via FixedArray).
- `let average_volume : FixedArray[Float]` -- Rolling history of 400 average volume samples.
- `fn powf(Float, Float) -> Float` -- Helper for float exponentiation.
- `fn process_audio_impl(AudioBuffer, UInt) -> Unit` -- The actual audio processing logic.
- `let process_audio : FuncRef[...]` -- Function reference wrapping the processor for raylib attachment.

## Architecture

1. **Initialization** -- Window, audio device, and music/sound resources are created. The custom audio processor is attached via `attach_audio_mixed_processor`.
2. **Main loop** -- Each frame updates the music stream, reads arrow key input to adjust the exponent, optionally plays a sound on spacebar, and draws the waveform visualization plus status text.
3. **Audio callback** -- Runs on the audio thread. For each stereo frame, it applies `powf(abs(sample), exponent) * sign(sample)` to both channels, computes an average, and shifts the volume history buffer.
4. **Cleanup** -- Unloads music, detaches the audio processor, closes the audio device and window.

## Key Takeaways

- Raylib's mixed audio processor lets you apply DSP effects to all audio output at once, and the MoonBit binding uses `FuncRef` to pass callbacks to native code.
- `FixedArray` serves as a practical workaround for mutable global state that must be accessible from audio callbacks, since closures over mutable locals are not supported in this context.
- The `audio_buffer_get_sample` / `audio_buffer_set_sample` API provides per-sample access for implementing custom audio effects in MoonBit.
