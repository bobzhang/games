# Models Loading M3D

This example demonstrates loading an M3D format 3D model with skeletal animation, featuring toggleable mesh and skeleton visualization with both bind-pose and frame-pose rendering. When you run it, you see a humanoid figure (CesiumMan) with visible bones that can be animated frame-by-frame or continuously.

## Build and Run

```bash
moon build --target native raylib_models_loading_m3d/
./_build/native/debug/build/raylib_models_loading_m3d/raylib_models_loading_m3d.exe
```

## Controls

- **Mouse**: First-person camera look
- **WASD**: Move the camera
- **Space (hold)**: Play animation continuously
- **N**: Step one animation frame
- **C**: Cycle through available animations
- **M**: Toggle mesh drawing on/off
- **B**: Toggle skeleton drawing on/off

## What It Demonstrates

- **M3D model format**: Loads a model in M3D format (`cesium_man.m3d`) using `@raylib.load_model` and its animations via `load_model_animations`.
- **Skeleton visualization**: Draws the bone hierarchy by iterating through bones with `get_model_bone_count`, getting bone positions, and drawing small cubes at each joint connected by lines to parent bones via `get_model_bone_parent`.
- **Bind-pose vs frame-pose display**: When no animation has played, shows the static bind pose using `get_model_bind_pose_translation`. Once animation starts, switches to frame-pose display using `get_model_animation_frame_pose_translation` and `get_model_animation_bone_parent`.
- **Frame stepping**: Allows single-frame advancement with the N key for detailed animation inspection.
- **Toggle drawing modes**: Independently toggles mesh rendering and skeleton overlay with M and B keys.

## Public API Reference

### Package `raylib_models_loading_m3d`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads an M3D model and its animations, sets up a first-person camera. Each frame, it updates the camera, advances the animation (on Space hold or N press), cycles animations on C press, and toggles drawing modes on M/B press. During rendering, if mesh drawing is enabled, the model is drawn normally. If skeleton drawing is enabled, all bones (except the last sentinel bone) are iterated: in bind-pose mode, bone positions come from `get_model_bind_pose_translation`; in animation mode, from `get_model_animation_frame_pose_translation`. Each bone is drawn as a small red cube with a line to its parent bone.

## Key Takeaways

- M3D is a lightweight model format that supports skeletal animation, similar to glTF but in a more compact binary format.
- Skeleton visualization is useful for debugging animations; raylib provides per-bone position queries for both bind pose and animation frame pose.
- The last bone in a model is often a sentinel "no bone" entry -- skipping it (iterating to `bone_count - 1`) avoids drawing spurious geometry at the origin.
