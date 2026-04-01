// Isometric projection: convert 3D voxel coords to 2D screen position
///|
fn iso_project(x : Float, y : Float, z : Float, scale : Float) -> (Float, Float) {
  let sx = (x - z) * scale * @types.iso_x_factor
  let sy = (x + z) * scale * @types.iso_y_factor - y * scale
  (sx, sy)
}

// Draw a filled quad using two triangles
///|
fn draw_quad(
  x0 : Int,
  y0 : Int,
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
  x3 : Int,
  y3 : Int,
  color : @raylib.Color
) -> Unit {
  let v0 = @raylib.Vector2::new(Float::from_int(x0), Float::from_int(y0))
  let v1 = @raylib.Vector2::new(Float::from_int(x1), Float::from_int(y1))
  let v2 = @raylib.Vector2::new(Float::from_int(x2), Float::from_int(y2))
  let v3 = @raylib.Vector2::new(Float::from_int(x3), Float::from_int(y3))
  @raylib.draw_triangle(v0, v3, v1, color)
  @raylib.draw_triangle(v1, v3, v2, color)
}

// Draw quad outline for edge definition
///|
fn draw_quad_outline(
  x0 : Int,
  y0 : Int,
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
  x3 : Int,
  y3 : Int,
  color : @raylib.Color
) -> Unit {
  @raylib.draw_line(x0, y0, x1, y1, color)
  @raylib.draw_line(x1, y1, x2, y2, color)
  @raylib.draw_line(x2, y2, x3, y3, color)
  @raylib.draw_line(x3, y3, x0, y0, color)
}

///|
fn shade_color(base : @raylib.Color, factor : Float) -> @raylib.Color {
  let r = @types.mini(
    (Float::from_int(base.r.to_int()) * factor).to_int(),
    255,
  )
  let g = @types.mini(
    (Float::from_int(base.g.to_int()) * factor).to_int(),
    255,
  )
  let b = @types.mini(
    (Float::from_int(base.b.to_int()) * factor).to_int(),
    255,
  )
  @raylib.Color::new(r, g, b, 255)
}

///|
fn lighten_color(base : @raylib.Color, amount : Int) -> @raylib.Color {
  let r = @types.mini(base.r.to_int() + amount, 255)
  let g = @types.mini(base.g.to_int() + amount, 255)
  let b = @types.mini(base.b.to_int() + amount, 255)
  @raylib.Color::new(r, g, b, base.a.to_int())
}

// Check if a face should be visible (not occluded by another voxel)
///|
fn is_top_face_visible(
  grid : @types.VoxelGrid,
  x : Int,
  y : Int,
  z : Int
) -> Bool {
  !@voxel.get_voxel(grid, x, y + 1, z)
}

///|
fn is_left_face_visible(
  grid : @types.VoxelGrid,
  x : Int,
  y : Int,
  z : Int
) -> Bool {
  !@voxel.get_voxel(grid, x - 1, y, z)
}

///|
fn is_right_face_visible(
  grid : @types.VoxelGrid,
  x : Int,
  y : Int,
  z : Int
) -> Bool {
  !@voxel.get_voxel(grid, x, y, z + 1)
}

// Draw a single isometric voxel cube with edge outlines and face visibility
///|
fn draw_iso_cube(
  cx : Int,
  cy : Int,
  x : Float,
  y : Float,
  z : Float,
  scale : Float,
  top_color : @raylib.Color,
  left_color : @raylib.Color,
  right_color : @raylib.Color,
  draw_edges~ : Bool = true,
  grid? : @types.VoxelGrid,
  vx? : Int,
  vy? : Int,
  vz? : Int
) -> Unit {
  let (sx, sy) = iso_project(x, y, z, scale)
  let px = Float::from_int(cx) + sx
  let py = Float::from_int(cy) + sy
  let hs = scale * @types.iso_x_factor
  let vs = scale * @types.iso_y_factor
  // Compute vertex positions for all three faces
  let (tx0, ty0) = (px, py - scale)
  let (tx1, ty1) = (px + hs, py - scale + vs)
  let (tx2, ty2) = (px, py - scale + vs * 2.0)
  let (tx3, ty3) = (px - hs, py - scale + vs)
  let (lx0, ly0) = (px - hs, py - scale + vs)
  let (lx1, ly1) = (px, py - scale + vs * 2.0)
  let (lx2, ly2) = (px, py + vs * 2.0 - scale + scale)
  let (lx3, ly3) = (px - hs, py + vs - scale + scale)
  let (rx0, ry0) = (px, py - scale + vs * 2.0)
  let (rx1, ry1) = (px + hs, py - scale + vs)
  let (rx2, ry2) = (px + hs, py + vs - scale + scale)
  let (rx3, ry3) = (px, py + vs * 2.0 - scale + scale)
  // Check face visibility for occlusion culling
  let show_top = match grid {
    Some(g) =>
      match (vx, vy, vz) {
        (Some(ix), Some(iy), Some(iz)) => is_top_face_visible(g, ix, iy, iz)
        _ => true
      }
    None => true
  }
  let show_left = match grid {
    Some(g) =>
      match (vx, vy, vz) {
        (Some(ix), Some(iy), Some(iz)) => is_left_face_visible(g, ix, iy, iz)
        _ => true
      }
    None => true
  }
  let show_right = match grid {
    Some(g) =>
      match (vx, vy, vz) {
        (Some(ix), Some(iy), Some(iz)) => is_right_face_visible(g, ix, iy, iz)
        _ => true
      }
    None => true
  }
  let edge_color = @raylib.Color::new(10, 10, 20, 200)
  let highlight_edge = lighten_color(top_color, 40)
  // Draw faces with highlighting for definition
  if show_top {
    // Top face: brightest, with a slight highlight gradient
    draw_quad(
      tx0.to_int(), ty0.to_int(), tx1.to_int(), ty1.to_int(), tx2.to_int(),
      ty2.to_int(), tx3.to_int(), ty3.to_int(), top_color,
    )
    if draw_edges {
      draw_quad_outline(
        tx0.to_int(), ty0.to_int(), tx1.to_int(), ty1.to_int(), tx2.to_int(),
        ty2.to_int(), tx3.to_int(), ty3.to_int(), highlight_edge,
      )
    }
  }
  if show_left {
    draw_quad(
      lx0.to_int(), ly0.to_int(), lx1.to_int(), ly1.to_int(), lx2.to_int(),
      ly2.to_int(), lx3.to_int(), ly3.to_int(), left_color,
    )
    if draw_edges {
      draw_quad_outline(
        lx0.to_int(), ly0.to_int(), lx1.to_int(), ly1.to_int(), lx2.to_int(),
        ly2.to_int(), lx3.to_int(), ly3.to_int(), edge_color,
      )
    }
  }
  if show_right {
    draw_quad(
      rx0.to_int(), ry0.to_int(), rx1.to_int(), ry1.to_int(), rx2.to_int(),
      ry2.to_int(), rx3.to_int(), ry3.to_int(), right_color,
    )
    if draw_edges {
      draw_quad_outline(
        rx0.to_int(), ry0.to_int(), rx1.to_int(), ry1.to_int(), rx2.to_int(),
        ry2.to_int(), rx3.to_int(), ry3.to_int(), edge_color,
      )
    }
  }
}

///|
pub fn draw_isometric_view(game : @types.Game, level : @types.Level) -> Unit {
  let size = level.size
  let scale : Float = if size <= 3 {
    @types.iso_scale
  } else if size <= 4 {
    16.0
  } else {
    13.0
  }
  let cx = @types.iso_center_x
  let cy = @types.iso_center_y
  // Panel background
  @raylib.draw_rectangle(
    @types.view_iso_x - 5,
    @types.view_iso_y - 5,
    580,
    310,
    @types.color_panel_bg,
  )
  @draw.draw_text(
    "ISOMETRIC VIEW",
    @types.view_iso_x,
    @types.view_iso_y - 22,
    16,
    @types.color_text,
  )
  // Draw voxels back-to-front using proper depth sorting:
  // Sort by (x + z - y) descending for correct painter's algorithm
  // Iterate: y from 0 to max, then x from max to 0, then z from 0 to max
  for y in 0..<size {
    for z in 0..<size {
      for x = size - 1; x >= 0; x = x - 1 {
        if @voxel.get_voxel(game.grid, x, y, z) {
          let fx = Float::from_int(x)
          let fy = Float::from_int(y)
          let fz = Float::from_int(z)
          // Height-based brightness: higher voxels are brighter
          let height_factor : Float = 0.65 +
            0.35 * Float::from_int(y) / Float::from_int(size)
          // Distinct face colors for clarity:
          // Top face: brightest (light hits from above)
          let top_c = shade_color(@types.color_iso_top, height_factor * 1.1)
          // Left face: medium (side-lit)
          let left_c = shade_color(@types.color_iso_left, height_factor * 0.85)
          // Right face: darkest (shadow side)
          let right_c = shade_color(
            @types.color_iso_right, height_factor * 0.7,
          )
          draw_iso_cube(
            cx,
            cy,
            fx,
            fy,
            fz,
            scale,
            top_c,
            left_c,
            right_c,
            grid=game.grid,
            vx=x,
            vy=y,
            vz=z,
          )
        }
      }
    }
  }
  // Draw preview voxel if hovering with pulsing highlight
  if game.hover.active && game.play_state == Editing {
    let hx = Float::from_int(game.hover.vx)
    let hy = Float::from_int(game.hover.vy)
    let hz = Float::from_int(game.hover.vz)
    let is_filled = @voxel.get_voxel(
      game.grid, game.hover.vx, game.hover.vy, game.hover.vz,
    )
    if !is_filled {
      // Pulsing alpha for preview
      let t : Float = Float::from_int(game.frame_count) * 0.1
      let pulse = Float::from_double(@math.sin(t.to_double())) * 30.0 + 100.0
      let alpha = pulse.to_int()
      let preview_top = @raylib.Color::new(255, 255, 100, alpha)
      let preview_left = @raylib.Color::new(200, 200, 60, alpha)
      let preview_right = @raylib.Color::new(160, 160, 40, alpha)
      draw_iso_cube(
        cx, cy, hx, hy, hz, scale, preview_top, preview_left, preview_right,
        draw_edges=true,
      )
    } else {
      // Preview removal: show red-tinted ghost
      let t : Float = Float::from_int(game.frame_count) * 0.1
      let pulse = Float::from_double(@math.sin(t.to_double())) * 30.0 + 80.0
      let alpha = pulse.to_int()
      let remove_color = @raylib.Color::new(255, 60, 60, alpha)
      draw_iso_cube(
        cx, cy, hx, hy, hz, scale, remove_color, remove_color, remove_color,
        draw_edges=true,
      )
    }
  }
}
