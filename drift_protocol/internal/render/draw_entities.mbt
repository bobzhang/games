///|
/// Draw the player as a cyan diamond
pub fn draw_player(game : @types.Game) -> Unit {
  let px = game.player.px
  let py = game.player.py
  let half : Float = Float::from_int(@types.tile_size) / 2.0 - 4.0
  let color = if game.player.in_shadow {
    @types.color_player_dim
  } else {
    @types.color_player
  }
  // Diamond shape (rotated square)
  let v1 = @raylib.Vector2::new(px, py - half) // top
  let v2 = @raylib.Vector2::new(px + half, py) // right
  let v3 = @raylib.Vector2::new(px, py + half) // bottom
  let v4 = @raylib.Vector2::new(px - half, py) // left
  @raylib.draw_triangle(v1, v2, v3, color)
  @raylib.draw_triangle(v1, v3, v4, color)
  // Direction indicator (small line in facing direction)
  let dir_len : Float = half + 4.0
  let dxf : Float = Float::from_int(@types.direction_dx(game.player.facing))
  let dyf : Float = Float::from_int(@types.direction_dy(game.player.facing))
  @raylib.draw_line_ex(
    @raylib.Vector2::new(px, py),
    @raylib.Vector2::new(px + dxf * dir_len, py + dyf * dir_len),
    2.0,
    @types.color_white,
  )
}

///|
/// Draw all guards as colored triangles with vision cones
pub fn draw_guards(game : @types.Game) -> Unit {
  for i in 0..<game.level.guards.length() {
    let g = game.level.guards[i]
    if !g.active {
      continue
    }
    draw_guard_vision_cone(g, game)
    draw_guard_body(g)
    draw_guard_detection_meter(g)
  }
}

///|
fn draw_guard_vision_cone(g : @types.Guard, game : @types.Game) -> Unit {
  let cone_color = match g.alert_state {
    Alert => @types.color_vision_alert
    _ => @types.color_vision_cone
  }
  let range = g.vision_range * Float::from_int(@types.tile_size)
  let half_cone = g.vision_cone / 2.0
  let segments = 12
  let angle_step = g.vision_cone / Float::from_int(segments)
  let start_angle = g.facing_angle - half_cone
  for s in 0..<segments {
    let a1 = start_angle + Float::from_int(s) * angle_step
    let a2 = a1 + angle_step
    let x1 = g.px + @types.cosf(a1) * range
    let y1 = g.py + @types.sinf(a1) * range
    let x2 = g.px + @types.cosf(a2) * range
    let y2 = g.py + @types.sinf(a2) * range
    // Check LOS for outer points
    let tx1 = @types.pixel_to_tile_x(x1)
    let ty1 = @types.pixel_to_tile_y(y1)
    let tx2 = @types.pixel_to_tile_x(x2)
    let ty2 = @types.pixel_to_tile_y(y2)
    let has_los1 = @types.in_bounds(tx1, ty1) &&
      @types.has_line_of_sight(game.level.tiles, g.gx, g.gy, tx1, ty1)
    let has_los2 = @types.in_bounds(tx2, ty2) &&
      @types.has_line_of_sight(game.level.tiles, g.gx, g.gy, tx2, ty2)
    if has_los1 || has_los2 {
      @raylib.draw_triangle(
        @raylib.Vector2::new(g.px, g.py),
        @raylib.Vector2::new(x1, y1),
        @raylib.Vector2::new(x2, y2),
        cone_color,
      )
    }
  }
}

///|
fn draw_guard_body(g : @types.Guard) -> Unit {
  let color = @types.guard_color(g.alert_state)
  let half : Float = Float::from_int(@types.tile_size) / 2.0 - 6.0
  // Triangle pointing in facing direction
  let angle = g.facing_angle
  let front_x = g.px + @types.cosf(angle) * half
  let front_y = g.py + @types.sinf(angle) * half
  let back_angle1 = angle + 2.4
  let back_angle2 = angle - 2.4
  let back_x1 = g.px + @types.cosf(back_angle1) * half * 0.7
  let back_y1 = g.py + @types.sinf(back_angle1) * half * 0.7
  let back_x2 = g.px + @types.cosf(back_angle2) * half * 0.7
  let back_y2 = g.py + @types.sinf(back_angle2) * half * 0.7
  @raylib.draw_triangle(
    @raylib.Vector2::new(front_x, front_y),
    @raylib.Vector2::new(back_x1, back_y1),
    @raylib.Vector2::new(back_x2, back_y2),
    color,
  )
  // Guard type indicator
  match g.kind {
    Sentinel => {
      // Ring around sentinel
      @raylib.draw_circle_lines_v(
        @raylib.Vector2::new(g.px, g.py),
        half + 2.0,
        color,
      )
    }
    Hunter => {
      // Small dot for hunter
      @raylib.draw_circle_v(
        @raylib.Vector2::new(g.px, g.py),
        3.0,
        @types.color_white,
      )
    }
    Patrol => ()
  }
}

///|
fn draw_guard_detection_meter(g : @types.Guard) -> Unit {
  if g.detection_meter <= 0.01 {
    return
  }
  let bar_w : Float = Float::from_int(@types.tile_size) - 8.0
  let bar_h : Float = 4.0
  let bx = g.px - bar_w / 2.0
  let by = g.py - Float::from_int(@types.tile_size) / 2.0 - 6.0
  // Background
  @raylib.draw_rectangle(
    bx.to_int(),
    by.to_int(),
    bar_w.to_int(),
    bar_h.to_int(),
    @raylib.Color::new(0, 0, 0, 150),
  )
  // Fill
  let fill_w = bar_w * g.detection_meter
  let fill_color = if g.detection_meter > 0.7 {
    @types.color_guard_alert
  } else {
    @types.color_guard_suspicious
  }
  @raylib.draw_rectangle(
    bx.to_int(),
    by.to_int(),
    fill_w.to_int(),
    bar_h.to_int(),
    fill_color,
  )
}

///|
/// Draw cameras
pub fn draw_cameras(game : @types.Game) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  for i in 0..<game.level.cameras.length() {
    let cam = game.level.cameras[i]
    if !cam.active {
      continue
    }
    let cx = Float::from_int(ox + cam.gx * ts + ts / 2)
    let cy = Float::from_int(oy + cam.gy * ts + ts / 2)
    let color = if cam.powered {
      @types.color_camera_tile
    } else {
      @raylib.Color::new(60, 60, 60, 255)
    }
    // Camera body (circle)
    @raylib.draw_circle_v(@raylib.Vector2::new(cx, cy), 6.0, color)
    if cam.powered {
      // Vision line
      let range = cam.vision_range * Float::from_int(ts)
      let end_x = cx + @types.cosf(cam.facing_angle) * range
      let end_y = cy + @types.sinf(cam.facing_angle) * range
      @raylib.draw_line_ex(
        @raylib.Vector2::new(cx, cy),
        @raylib.Vector2::new(end_x, end_y),
        1.0,
        @raylib.Color::new(200, 200, 200, 60),
      )
    }
  }
}
