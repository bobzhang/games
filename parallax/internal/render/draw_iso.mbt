// Isometric projection: convert 3D voxel coords to 2D screen position
///|
fn iso_project(x : Float, y : Float, z : Float, scale : Float) -> (Float, Float) {
  let sx = (x - z) * scale * @types.iso_x_factor
  let sy = (x + z) * scale * @types.iso_y_factor - y * scale
  (sx, sy)
}

// Draw a single isometric voxel cube at given position
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
  right_color : @raylib.Color
) -> Unit {
  let (sx, sy) = iso_project(x, y, z, scale)
  let px = Float::from_int(cx) + sx
  let py = Float::from_int(cy) + sy
  let hs = scale * @types.iso_x_factor
  let vs = scale * @types.iso_y_factor
  // Top face (diamond)
  let (tx0, ty0) = (px, py - scale)
  let (tx1, ty1) = (px + hs, py - scale + vs)
  let (tx2, ty2) = (px, py - scale + vs * 2.0)
  let (tx3, ty3) = (px - hs, py - scale + vs)
  draw_quad(
    tx0.to_int(),
    ty0.to_int(),
    tx1.to_int(),
    ty1.to_int(),
    tx2.to_int(),
    ty2.to_int(),
    tx3.to_int(),
    ty3.to_int(),
    top_color,
  )
  // Left face
  let (lx0, ly0) = (px - hs, py - scale + vs)
  let (lx1, ly1) = (px, py - scale + vs * 2.0)
  let (lx2, ly2) = (px, py + vs * 2.0 - scale + scale)
  let (lx3, ly3) = (px - hs, py + vs - scale + scale)
  draw_quad(
    lx0.to_int(),
    ly0.to_int(),
    lx1.to_int(),
    ly1.to_int(),
    lx2.to_int(),
    ly2.to_int(),
    lx3.to_int(),
    ly3.to_int(),
    left_color,
  )
  // Right face
  let (rx0, ry0) = (px, py - scale + vs * 2.0)
  let (rx1, ry1) = (px + hs, py - scale + vs)
  let (rx2, ry2) = (px + hs, py + vs - scale + scale)
  let (rx3, ry3) = (px, py + vs * 2.0 - scale + scale)
  draw_quad(
    rx0.to_int(),
    ry0.to_int(),
    rx1.to_int(),
    ry1.to_int(),
    rx2.to_int(),
    ry2.to_int(),
    rx3.to_int(),
    ry3.to_int(),
    right_color,
  )
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

///|
fn shade_color(
  base : @raylib.Color,
  factor : Float
) -> @raylib.Color {
  let r = (Float::from_int(base.r.to_int()) * factor).to_int()
  let g = (Float::from_int(base.g.to_int()) * factor).to_int()
  let b = (Float::from_int(base.b.to_int()) * factor).to_int()
  @raylib.Color::new(r, g, b, 255)
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
  // Draw voxels from back to front (painter's algorithm)
  for z = 0; z < size; z = z + 1 {
    for y = 0; y < size; y = y + 1 {
      for x = 0; x < size; x = x + 1 {
        if @voxel.get_voxel(game.grid, x, y, z) {
          let fx = Float::from_int(x)
          let fy = Float::from_int(y)
          let fz = Float::from_int(z)
          let depth_factor : Float = 0.6 +
            0.4 * Float::from_int(y) / Float::from_int(size)
          let top_c = shade_color(@types.color_iso_top, depth_factor)
          let left_c = shade_color(@types.color_iso_left, depth_factor)
          let right_c = shade_color(@types.color_iso_right, depth_factor)
          draw_iso_cube(cx, cy, fx, fy, fz, scale, top_c, left_c, right_c)
        }
      }
    }
  }
  // Draw preview voxel if hovering
  if game.hover.active && game.play_state == Editing {
    let hx = Float::from_int(game.hover.vx)
    let hy = Float::from_int(game.hover.vy)
    let hz = Float::from_int(game.hover.vz)
    let is_filled = @voxel.get_voxel(
      game.grid,
      game.hover.vx,
      game.hover.vy,
      game.hover.vz,
    )
    if !is_filled {
      draw_iso_cube(
        cx,
        cy,
        hx,
        hy,
        hz,
        scale,
        @types.color_preview,
        @types.color_preview,
        @types.color_preview,
      )
    }
  }
}
