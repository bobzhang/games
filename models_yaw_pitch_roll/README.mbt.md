# Models: Yaw, Pitch, Roll

This example demonstrates how to apply yaw, pitch, and roll rotations to a 3D model using matrix transformations. When you run it, you see a textured WWI plane model that can be rotated around all three axes using keyboard controls. The rotations smoothly return toward zero when keys are released, simulating a self-centering flight stick.

## Build and Run

```bash
moon build --target native models_yaw_pitch_roll/
./_build/native/debug/build/models_yaw_pitch_roll/models_yaw_pitch_roll.exe
```

## Controls

- **Up/Down Arrows** -- Control pitch (nose up/down rotation around the x-axis)
- **Left/Right Arrows** -- Control roll (rotation around the z-axis)
- **A/S Keys** -- Control yaw (rotation around the y-axis)

All axes auto-center when the corresponding keys are released.

## What It Demonstrates

- **Euler angle rotations (yaw, pitch, roll)**: Accumulates rotation angles in degrees for each axis and converts them to radians using a `deg2rad` constant before applying them as a combined rotation matrix.
- **Model transform matrix**: Uses `@raylib.Matrix::rotate_xyz` to construct a single rotation matrix from a `Vector3` of (pitch, yaw, roll) angles in radians, then applies it via `set_model_transform` to update the model's orientation each frame.
- **OBJ model and texture loading**: Loads a plane model from an `.obj` file and its diffuse texture separately, then binds the texture to the model's albedo material map via `set_model_material_texture`.
- **Auto-centering input**: When no key is held, each rotation angle decays toward zero at a fixed rate, creating a smooth return-to-neutral behavior.

## Public API Reference

### Package `models_yaw_pitch_roll`

> Single-package example.

No public API -- self-contained main function. The constant `deg2rad` is package-level but not exported.

## Architecture

The program initializes a window, changes directory for resource access, and loads a plane model with its diffuse texture. A fixed camera looks at the origin from above. Three mutable float variables track pitch, roll, and yaw angles in degrees. Each frame, keyboard input adjusts these angles (with auto-centering when keys are released), a rotation matrix is constructed from the angles via `Matrix::rotate_xyz`, and the model's transform is updated via `set_model_transform`. The model is drawn at a fixed position, followed by a grid and on-screen control hints. On exit, the model and texture are unloaded.

## Key Takeaways

- `Matrix::rotate_xyz` provides a convenient way to combine yaw, pitch, and roll into a single transformation matrix without manually composing individual rotation matrices.
- Setting the model's transform matrix via `set_model_transform` allows rotating a model independently of its draw position, keeping the rotation logic separate from the translation.
- Auto-centering input (decaying angles toward zero when no key is pressed) is a simple but effective technique for creating responsive, intuitive rotation controls.
