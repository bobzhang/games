# Logo Raylib Animation

This example demonstrates a multi-state animation that builds the raylib logo piece by piece. When you run it, a small square blinks, then the top and left borders grow outward, followed by the bottom and right borders, then the "raylib" text appears letter by letter, and finally everything fades out.

## Build and Run

```bash
moon build --target native shapes_logo_anim/
./_build/native/debug/build/shapes_logo_anim/shapes_logo_anim.exe
```

## Controls

- **R** -- Replay the animation (after it completes)

## What It Demonstrates

- **State machine animation** -- Five states (0-4) drive the logo construction sequence: blinking, top/left bars growing, bottom/right bars growing, text appearing with fade-out, and wait for replay.
- **`draw_rectangle`** with dynamic dimensions -- Rectangle widths and heights are animated by incrementing each frame, creating a progressive reveal effect.
- **`fade`** -- Applies decreasing alpha transparency during state 3 to create the fade-out effect on all logo elements.
- **Text substring animation** -- A `match` expression maps `letters_count` (0-6) to progressively longer substrings of "raylib", simulating a typewriter effect.
- **Frame-based timing** -- Uses `frames_counter` with modulo arithmetic for blinking (state 0, every 15 frames) and letter timing (state 3, every 12 frames).

## Public API Reference

### Package `shapes_logo_anim`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program uses a five-state machine: State 0 blinks a 16x16 square for 120 frames. State 1 grows `top_side_rec_width` and `left_side_rec_height` by 4 pixels per frame until 256. State 2 similarly grows the bottom and right bars. State 3 reveals letters every 12 frames while decrementing alpha from 1.0 to 0.0 at 0.02 per frame. State 4 waits for R to reset all variables and restart. Each state's draw logic layers rectangles to form the logo frame, with state 3 adding the inner white area and progressive text.

## Key Takeaways

- A simple integer state machine with a frame counter is sufficient for complex multi-phase animations -- no animation library needed.
- Progressive rectangle growth by incrementing width/height each frame creates clean "drawing" animations.
- MoonBit's `match` expression provides a clean way to implement string substring selection for typewriter-style text animation.
