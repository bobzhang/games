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
    draw_guard_footstep_timing(g)
    draw_guard_body(g)
    draw_guard_detection_meter(g)
  }
}

///|
/// Draw footstep timing indicator under guard
fn draw_guard_footstep_timing(g : @types.Guard) -> Unit {
  // Only show for moving guard types
  if g.kind is Sentinel {
    return
  }
  // Show a small arc that fills as the move timer counts down
  let interval : Float = match g.alert_state {
    Patrolling => @types.guard_move_interval
    Suspicious => @types.guard_move_interval * 0.8
    Alert => @types.guard_move_interval * 0.5
  }
  if interval <= 0.0 {
    return
  }
  let ratio : Float = 1.0 - g.move_timer / interval
  let ratio_clamped : Float = @types.clampf(ratio, 0.0, 1.0)
  // Draw small dots that light up as guard is about to step
  let dot_count = 3
  let dot_radius : Float = 2.0
  let spread : Float = 10.0
  let base_y : Float = g.py + Float::from_int(@types.tile_size) / 2.0 - 2.0
  for d in 0..<dot_count {
    let threshold : Float = Float::from_int(d + 1) / Float::from_int(dot_count)
    let dx : Float = Float::from_int(d - 1) * spread
    let alpha : Float = if ratio_clamped >= threshold { 120.0 } else { 30.0 }
    @raylib.draw_circle_v(
      @raylib.Vector2::new(g.px + dx, base_y),
      dot_radius,
      @raylib.Color::new(200, 200, 255, alpha.to_int()),
    )
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
/// Compute a smooth guard color that transitions based on detection meter
fn smooth_guard_color(g : @types.Guard) -> @raylib.Color {
  match g.alert_state {
    Patrolling => {
      // Blend from patrol green toward suspicious yellow based on detection
      let t : Float = g.detection_meter
      let r : Float = 50.0 + 205.0 * t
      let gv : Float = 200.0 + 55.0 * t
      let b : Float = 50.0 - 50.0 * t
      @raylib.Color::new(
        @types.clampi(r.to_int(), 0, 255),
        @types.clampi(gv.to_int(), 0, 255),
        @types.clampi(b.to_int(), 0, 255),
        255,
      )
    }
    Suspicious => {
      // Pulse between yellow and orange based on timer
      let pulse : Float = @types.sinf(g.suspicious_timer * 4.0) * 0.3 + 0.7
      let r : Float = 255.0 * pulse
      let gv : Float = 200.0 * pulse
      @raylib.Color::new(
        @types.clampi(r.to_int(), 0, 255),
        @types.clampi(gv.to_int(), 0, 255),
        30,
        255,
      )
    }
    Alert => {
      // Flash red with intensity
      let pulse : Float = @types.sinf(g.alert_timer * 6.0) * 0.2 + 0.8
      let r : Float = 255.0 * pulse
      @raylib.Color::new(@types.clampi(r.to_int(), 0, 255), 30, 30, 255)
    }
  }
}

///|
fn draw_guard_body(g : @types.Guard) -> Unit {
  let color = smooth_guard_color(g)
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
    Sentinel =>
      // Ring around sentinel
      @raylib.draw_circle_lines_v(
        @raylib.Vector2::new(g.px, g.py),
        half + 2.0,
        color,
      )
    Hunter =>
      // Small dot for hunter
      @raylib.draw_circle_v(
        @raylib.Vector2::new(g.px, g.py),
        3.0,
        @types.color_white,
      )
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
