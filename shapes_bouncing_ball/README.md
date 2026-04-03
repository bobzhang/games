# Shapes - Bouncing Ball

This example demonstrates basic 2D physics simulation with a ball that bounces off the edges of the window. It features a simple velocity-based movement system with wall collision detection and a pause toggle. When you run it, you see a maroon ball bouncing around the screen, with the ability to pause and resume the animation.

## Build and Run

```bash
moon build --target native shapes_bouncing_ball/
./_build/native/debug/build/shapes_bouncing_ball/shapes_bouncing_ball.exe
```

## Controls

- **Space**: Toggle pause/resume

## What It Demonstrates

- **Basic 2D movement and velocity**: Updates ball position by adding speed values each frame (`ball_position_x += ball_speed_x`), demonstrating the simplest form of frame-based movement.
- **Wall collision with velocity reflection**: Detects when the ball (accounting for its radius) reaches any screen edge and reverses the corresponding velocity component, creating a bounce effect.
- **Pause state management**: Uses a boolean `pause` flag toggled by `is_key_pressed` with `KeySpace`, stopping position updates when active.
- **Blinking text effect**: Displays a "PAUSED" message that blinks on and off using a frame counter with modular arithmetic (`frames_counter / 30 % 2`).
- **Circle drawing**: Uses `draw_circle_v` with a `Vector2` position to render the ball.

## Public API Reference

### Package `shapes_bouncing_ball`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes ball position at screen center with diagonal velocity (5.0, 4.0) and a radius of 20 pixels. MSAA 4x is enabled for smooth circle rendering. Each frame, if not paused, the ball position is updated and checked against all four screen edges (accounting for radius). If paused, a frame counter increments to drive the blinking text effect. The ball is drawn as a filled circle, with help text at the bottom and a blinking "PAUSED" indicator when appropriate. On exit, the window is closed.

## Key Takeaways

- Bouncing ball physics is implemented by negating the velocity component perpendicular to the collided wall, a foundational pattern for simple 2D games.
- Frame-counter-based blinking (`counter / N % 2`) is a common technique for creating intermittent visual indicators without timers.
- MSAA (`FlagMsaa4xHint`) significantly improves the visual quality of circle rendering by smoothing aliased edges.
