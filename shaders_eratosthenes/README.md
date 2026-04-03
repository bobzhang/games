# Shaders: Sieve of Eratosthenes

This example demonstrates running a computational algorithm entirely on the GPU using a fragment shader. When you run it, you see a visual representation of the Sieve of Eratosthenes, where each pixel represents a number and prime numbers are highlighted, all computed in real time by the fragment shader.

## Build and Run

```bash
moon build --target native shaders_eratosthenes/
./_build/native/debug/build/shaders_eratosthenes/shaders_eratosthenes.exe
```

## Controls

No interactive controls -- runs automatically.

## What It Demonstrates

- **GPU-computed algorithm via fragment shader**: Loads a custom `eratosthenes.fs` shader that implements the Sieve of Eratosthenes directly in GLSL, treating each pixel's screen position as a number and testing for primality.
- **Fullscreen shader rendering**: Applies the shader to a fullscreen rectangle using `begin_shader_mode`/`end_shader_mode`, turning the entire screen into a shader canvas.
- **Render texture usage**: Creates a render texture with `load_render_texture` as part of the rendering pipeline, drawing a black rectangle into it before applying the shader to the screen.
- **Minimal MoonBit host code**: The MoonBit code is intentionally minimal -- it simply sets up the window, loads the shader, and draws a fullscreen rectangle each frame. All the interesting computation happens in the GLSL shader.

## Public API Reference

### Package `shaders_eratosthenes`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes an 800x450 window, loads a render texture and the Eratosthenes fragment shader. Each frame, a black rectangle is drawn into the render texture (as a canvas), then a fullscreen rectangle is drawn to the screen within shader mode, causing the fragment shader to execute for every pixel. The shader maps each pixel to a number and applies the sieve algorithm to determine if it is prime, coloring it accordingly. On exit, the shader and render texture are unloaded.

## Key Takeaways

- Fragment shaders can implement non-graphical algorithms by mapping pixel coordinates to problem-space indices, enabling massively parallel computation on the GPU.
- The pattern of drawing a fullscreen rectangle in shader mode is the simplest way to execute a fragment shader across every screen pixel in raylib.
- Even complex mathematical algorithms like prime sieves can be expressed concisely in GLSL and visualized directly through pixel coloring.
