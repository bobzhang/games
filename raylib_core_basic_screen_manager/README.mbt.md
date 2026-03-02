# Core Basic Screen Manager

This example demonstrates a simple state machine for managing multiple game screens. When you run it, the application cycles through four screens: a Logo screen that auto-advances after 2 seconds, a Title screen, a Gameplay screen, and an Ending screen. You advance between screens by pressing Enter or tapping.

## Build and Run

```bash
moon build --target native raylib_core_basic_screen_manager/
./_build/native/debug/build/raylib_core_basic_screen_manager/raylib_core_basic_screen_manager.exe
```

## Controls

- **Enter or Tap** -- Advance to the next screen (from Title to Gameplay, Gameplay to Ending, Ending back to Title)
- Logo screen auto-advances after 2 seconds (120 frames at 60 FPS)

## What It Demonstrates

- **Integer-based screen state** -- Using an integer (`0`=Logo, `1`=Title, `2`=Gameplay, `3`=Ending) to represent the current screen, switched via MoonBit's `match` expression.
- **Frame-based timing** -- The Logo screen uses a frame counter that auto-advances to the Title screen after 120 frames (2 seconds at 60 FPS).
- **`@raylib.is_key_pressed`** -- Detecting discrete key press events for screen transitions.
- **`@raylib.is_gesture_detected(GestureTap)`** -- Supporting touch/tap input alongside keyboard for screen transitions.
- **Screen-specific rendering** -- Each screen has its own background color and text, drawn in a `match` block that selects based on the current screen state.
- **Cyclic screen flow** -- The Ending screen transitions back to Title (not Logo), creating a loop through the main screens.

## Public API Reference

### Package `raylib_core_basic_screen_manager`

> Single-package example.

No public API -- self-contained main function.

## Architecture

1. **Initialization** -- Window is created, current screen is set to Logo (0), and a frames counter is initialized.
2. **Main loop** -- Each frame has an update phase (using `match` to handle transitions: Logo counts frames and auto-advances, other screens check for Enter/Tap input) and a draw phase (using `match` to render the appropriate screen with its background color and text).
3. **Cleanup** -- Window is closed.

## Key Takeaways

- A simple integer-based state machine with `match` is an effective and readable pattern for managing game screens in MoonBit, and scales well for small to medium projects.
- Frame counting is the simplest approach for timed transitions (like splash/logo screens) when frame rate is fixed.
- Supporting both keyboard (`is_key_pressed`) and touch (`is_gesture_detected`) input makes the application work across desktop and mobile platforms.
