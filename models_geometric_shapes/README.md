# Models Geometric Shapes

This example renders a gallery of 3D geometric primitives using raylib in MoonBit, showing both solid and wireframe versions of cubes, spheres, cylinders, cones, and capsules. When you run it, you see a colorful arrangement of shapes on a grid viewed from a fixed overhead camera.

## Build and Run

```bash
moon build --target native models_geometric_shapes/
./_build/native/debug/build/models_geometric_shapes/models_geometric_shapes.exe
```

## Controls

No interactive controls -- displays a static scene with a fixed camera.

## What It Demonstrates

- **Cube drawing**: `@raylib.draw_cube` for solid cubes and `@raylib.draw_cube_wires` for wireframe cubes, with different sizes and colors.
- **Sphere drawing**: `@raylib.draw_sphere` for a solid sphere and `@raylib.draw_sphere_wires` for a wireframe sphere with configurable ring and slice counts.
- **Cylinder drawing**: `@raylib.draw_cylinder` for solid cylinders with different top and bottom radii (including cones when top radius is 0) and `@raylib.draw_cylinder_wires` for wireframe versions with configurable segment counts.
- **Capsule drawing**: `@raylib.draw_capsule` and `@raylib.draw_capsule_wires` for capsule shapes defined by two endpoints, a radius, and resolution parameters.
- **Scene composition**: Multiple shapes are positioned at different locations in world space to create a gallery-style layout on a grid.

## Public API Reference

### Package `models_geometric_shapes`

> Single-package example.

No public API -- self-contained main function.

## Architecture

The program initializes a window and sets up a fixed perspective camera at position (0, 10, 10) looking at the origin. The main loop draws all geometric primitives in a single 3D mode block: a solid red cube with gold wireframe, a maroon wireframe cube, a solid green sphere, a wireframe lime sphere, a solid skyblue cylinder with darkblue wireframe, a brown wireframe cylinder, a solid gold cone (cylinder with 0 top radius) with pink wireframe, and a solid violet capsule with purple wireframe. A grid is drawn underneath all shapes.

## Key Takeaways

- Raylib provides built-in functions for all common 3D geometric primitives, each with solid and wireframe variants.
- Cones are created using `draw_cylinder` with a top radius of 0, demonstrating that cylinders and cones share the same API.
- Capsules are defined by two endpoint positions rather than a center, making them useful for representing character colliders or bones.
