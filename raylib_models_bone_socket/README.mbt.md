# Models Bone Socket

This example demonstrates the bone socket technique for attaching equipment models (hat, sword, shield) to specific bones of an animated character in raylib using MoonBit. When you run it, you see a green humanoid character with toggleable equipment items that follow the character's skeletal animation, viewed through a third-person camera.

## Build and Run

```bash
moon build --target native raylib_models_bone_socket/
./_build/native/debug/build/raylib_models_bone_socket/raylib_models_bone_socket.exe
```

## Controls

- **Mouse**: Rotate the third-person camera
- **T/G**: Switch to next/previous animation
- **F/H**: Rotate the character left/right
- **1**: Toggle hat visibility
- **2**: Toggle sword visibility
- **3**: Toggle shield visibility

## What It Demonstrates

- **Bone socket lookup**: Iterates through model bones using `@raylib.get_model_bone_count` and `@raylib.get_model_bone_name` to find named socket bones (`socket_hat`, `socket_hand_R`, `socket_hand_L`) by index.
- **Equipment attachment via bone transforms**: Retrieves animation frame pose translation and rotation for each socket bone using `@raylib.get_model_animation_frame_pose_translation` and `get_model_animation_frame_pose_rotation`, then computes the difference from the bind pose rotation using quaternion math.
- **Quaternion and matrix operations**: Uses `@raylib.Vector4::quat_from_axis_angle`, `quat_to_matrix`, `quat_multiply`, `quat_invert`, and `@raylib.Matrix::multiply`/`translate` to compute character rotation and equipment placement.
- **Low-level mesh/material drawing**: Uses `@raylib.get_model_mesh`, `@raylib.get_model_material`, and `@raylib.draw_mesh` to draw individual meshes with explicit transform matrices, rather than using the higher-level `draw_model`.
- **glTF model loading**: Loads character and three equipment models from `.glb` files.

## Public API Reference

### Package `raylib_models_bone_socket`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program loads a character model and three equipment models from glTF files, then scans the character's bone hierarchy to find named socket bone indices. Each frame, it updates the camera, handles character rotation (F/H keys) and animation cycling (T/G keys), then updates the animation. For rendering, it computes the character's world transform from a quaternion rotation and translation, draws the character mesh directly with `draw_mesh`, then for each visible equipment piece: retrieves the socket bone's current animation pose, computes the rotation delta from the bind pose (`quat_multiply(out_rotation, quat_invert(in_rotation))`), builds a combined transform matrix (socket rotation, socket translation, character transform), and draws the equipment mesh at that transform. Resources are properly unloaded on exit.

## Key Takeaways

- Bone sockets enable equipment attachment by naming specific bones in the 3D modeling tool and looking them up at runtime by name with `get_model_bone_name`.
- The key calculation for socket attachment is: compute the rotation difference between the current animation frame pose and the bind pose, apply it as a transform, translate to the bone's animated position, then multiply by the character's world transform.
- Using `draw_mesh` with explicit transform matrices provides the control needed for equipment systems where each piece has its own computed world transform.
