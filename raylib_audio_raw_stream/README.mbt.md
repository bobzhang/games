# Audio Raw Stream

This example demonstrates real-time audio synthesis by generating a sine wave and streaming it through raylib's raw audio stream API. When you run it, a sine wave tone plays continuously. Clicking and dragging the mouse changes the frequency (based on Y position) and stereo panning (based on X position), with the current waveform visualized on screen.

## Build and Run

```bash
moon build --target native raylib_audio_raw_stream/
./_build/native/debug/build/raylib_audio_raw_stream/raylib_audio_raw_stream.exe
```

## Controls

- **Left Mouse Button (hold and drag)** -- Change sine wave frequency (Y axis) and stereo pan (X axis)

## What It Demonstrates

- **`@raylib.load_audio_stream`** -- Creating a raw audio stream with specified sample rate (44100), sample size (16-bit), and channel count (mono).
- **`@raylib.set_audio_stream_buffer_size_default`** -- Configuring the default buffer size before creating the stream.
- **`@raylib.play_audio_stream`** -- Starting playback of the raw audio stream.
- **`@raylib.is_audio_stream_processed`** -- Polling whether the stream needs more data (the audio buffer has been consumed).
- **`@raylib.update_audio_stream`** -- Feeding new audio data into the stream buffer.
- **`@raylib.set_audio_stream_pan`** -- Adjusting stereo panning in real time based on mouse X position.
- **Sine wave synthesis** -- Computing sine wave samples using `@math.sinf` with a frequency derived from mouse input, stored as 16-bit signed integers.
- **Ring buffer pattern** -- A `read_cursor` tracks the current position within the waveform cycle, wrapping around via modulo to produce continuous audio without clicks.
- **Byte-level buffer manipulation** -- 16-bit samples are manually packed into a `FixedArray[Byte]` in little-endian format, then reinterpreted as `Bytes` for the stream update call.

## Public API Reference

### Package `raylib_audio_raw_stream`

> Single-package example.

No public API -- self-contained main function. The module-level constant `let pi : Float` is defined for use in sine wave computation.

## Architecture

1. **Initialization** -- Window and audio device are created, buffer size is configured, and a 44100 Hz / 16-bit / mono audio stream is loaded and started.
2. **Main loop** -- Each frame samples mouse input to update frequency and pan, regenerates the sine wave lookup table when frequency changes, polls `is_audio_stream_processed` to check if more data is needed, fills the write buffer by cycling through the waveform data with a ring buffer read cursor, and calls `update_audio_stream` to push the new samples. The current waveform is drawn as red pixels across the screen width.
3. **Cleanup** -- Unloads the audio stream, closes the audio device and window.

## Key Takeaways

- Raw audio streams give you complete control over audio synthesis, but you must manually manage buffer filling by polling `is_audio_stream_processed` and calling `update_audio_stream` with correctly formatted sample data.
- When working with 16-bit audio in MoonBit, samples must be manually packed into bytes in little-endian order since there is no direct 16-bit array type for the stream API.
- A ring buffer approach for reading waveform data ensures seamless looping and minimizes audible artifacts when the frequency changes.
