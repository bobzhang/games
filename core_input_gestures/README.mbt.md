# Input Gestures

This example demonstrates raylib's touch/mouse gesture detection system. A touch area on the right side of the screen detects gestures such as tap, double-tap, hold, drag, swipe (in all four directions), and pinch. Detected gestures are logged in a scrolling list on the left, and a circle follows the current touch position.

## Build and Run

```bash
moon build --target native core_input_gestures/
./_build/native/debug/build/core_input_gestures/core_input_gestures.exe
```

## Controls

- **Touch/click** in the right-side gesture area to trigger gestures
- Supported gestures: tap, double-tap, hold, drag, swipe left/right/up/down, pinch in/out

## What It Demonstrates

- `@raylib.get_gesture_detected()` to identify the current gesture type each frame
- Gesture type constants: `GestureNone`, `GestureTap`, `GestureDoubletap`, `GestureHold`, `GestureDrag`, `GestureSwipeRight`, `GestureSwipeLeft`, `GestureSwipeUp`, `GestureSwipeDown`, `GesturePinchIn`, `GesturePinchOut`
- `@raylib.get_touch_position()` to get the current touch/mouse position
- `@raylib.check_collision_point_rec()` to test whether the touch point falls within the gesture detection area
- Gesture change detection by comparing `current_gesture` to `last_gesture` to avoid logging repeated events
- `@raylib.draw_rectangle_rec()` and `@raylib.draw_circle_v()` for rendering the touch area and indicator

## Public API Reference

### Package `core_input_gestures`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program defines a rectangular touch area and maintains an array of detected gesture strings. Each frame, it reads the current gesture and touch position. If the touch is inside the gesture area and the gesture has changed since last frame, the gesture name is appended to the log. The log resets when it reaches 20 entries. The draw phase renders the gesture area, the log with alternating row backgrounds, and a circle at the current touch position.

## Key Takeaways

- Raylib's gesture detection works with both touch screens and mouse input, making it useful for cross-platform applications.
- Comparing the current gesture to the previous frame's gesture prevents duplicate logging of continuous gestures like hold or drag.
- The `check_collision_point_rec` function is a convenient way to restrict gesture detection to a specific screen region.
