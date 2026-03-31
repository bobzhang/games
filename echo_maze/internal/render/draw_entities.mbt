///|
/// Draw the player as a cyan diamond shape
pub fn draw_player(game : @types.Game) -> Unit {
  if !game.player.alive {
    return
  }
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let px = Float::from_int(ox + game.player.pos.x * ts + ts / 2)
  let py = Float::from_int(oy + game.player.pos.y * ts + ts / 2)
  let half : Float = Float::from_int(ts) / 2.0 - 4.0
  // Diamond shape (rotated square)
  let v1 = @raylib.Vector2::new(px, py - half) // top
  let v2 = @raylib.Vector2::new(px + half, py) // right
  let v3 = @raylib.Vector2::new(px, py + half) // bottom
  let v4 = @raylib.Vector2::new(px - half, py) // left
  @raylib.draw_triangle(v1, v2, v3, @types.color_player)
  @raylib.draw_triangle(v1, v3, v4, @types.color_player)
  // Direction indicator
  let dir_delta = @types.dir_to_delta(game.player.dir)
  let dxf = Float::from_int(dir_delta.x)
  let dyf = Float::from_int(dir_delta.y)
  let dir_len = half + 4.0
  @raylib.draw_line_ex(
    @raylib.Vector2::new(px, py),
    @raylib.Vector2::new(px + dxf * dir_len, py + dyf * dir_len),
    2.0,
    @raylib.Color::new(255, 255, 255, 220),
  )
  // Pulse outline
  let pulse = @types.sinf(Float::from_int(game.frame_count) * 0.1) * 2.0
  let outline_half = half + pulse
  @raylib.draw_circle_lines_v(
    @raylib.Vector2::new(px, py),
    outline_half,
    @raylib.Color::new(0, 220, 240, 40),
  )
}

///|
/// Draw all ghosts as translucent shapes
pub fn draw_ghosts(game : @types.Game, maze : @types.Maze) -> Unit {
  ignore(maze)
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  for ghost in game.ghosts {
    if !ghost.active {
      continue
    }
    let px = Float::from_int(ox + ghost.pos.x * ts + ts / 2)
    let py = Float::from_int(oy + ghost.pos.y * ts + ts / 2)
    let half : Float = Float::from_int(ts) / 2.0 - 6.0
    let color = @types.ghost_color_value(ghost.color)
    // Ghost body: circle (translucent)
    @raylib.draw_circle_v(@raylib.Vector2::new(px, py), half, color)
    // Inner eye dots
    let eye_offset : Float = half * 0.3
    @raylib.draw_circle_v(
      @raylib.Vector2::new(px - eye_offset, py - eye_offset * 0.5),
      3.0,
      @raylib.Color::new(255, 255, 255, 180),
    )
    @raylib.draw_circle_v(
      @raylib.Vector2::new(px + eye_offset, py - eye_offset * 0.5),
      3.0,
      @raylib.Color::new(255, 255, 255, 180),
    )
    // Wavy bottom for ghost shape
    let wave_y = py + half
    let wave_amp : Float = 3.0
    let wave_freq : Float = 0.3
    let segments = 6
    let seg_w = half * 2.0 / Float::from_int(segments)
    for s in 0..<segments {
      let sx = px - half + Float::from_int(s) * seg_w
      let wave = @types.sinf(
        Float::from_int(s * 2 + game.frame_count) * wave_freq,
      ) * wave_amp
      @raylib.draw_rectangle(
        sx.to_int(),
        (wave_y + wave).to_int(),
        seg_w.to_int() + 1,
        3,
        color,
      )
    }
    // Ghost outline ring
    let outline_color = match ghost.color {
      Green => @raylib.Color::new(60, 220, 80, 100)
      Yellow => @raylib.Color::new(240, 220, 40, 100)
      Orange => @raylib.Color::new(240, 140, 40, 100)
    }
    @raylib.draw_circle_lines_v(
      @raylib.Vector2::new(px, py),
      half + 1.0,
      outline_color,
    )
  }
}

///|
/// Draw guards as red triangles
pub fn draw_guards(maze_state : @types.MazeState, game : @types.Game) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  for gs in maze_state.guard_states {
    let px = Float::from_int(ox + gs.pos.x * ts + ts / 2)
    let py = Float::from_int(oy + gs.pos.y * ts + ts / 2)
    let half : Float = Float::from_int(ts) / 2.0 - 5.0
    // Determine patrol direction for visual indicator
    let facing_x : Float = if gs.forward { 1.0 } else { -1.0 }
    // Triangle pointing in patrol direction
    let front_x = px + facing_x * half
    let front_y = py
    let back_x1 = px - facing_x * half * 0.6
    let back_y1 = py - half * 0.7
    let back_x2 = px - facing_x * half * 0.6
    let back_y2 = py + half * 0.7
    @raylib.draw_triangle(
      @raylib.Vector2::new(front_x, front_y),
      @raylib.Vector2::new(back_x1, back_y1),
      @raylib.Vector2::new(back_x2, back_y2),
      @types.color_guard,
    )
    // Guard vision cone (simplified - highlight tiles in patrol direction)
    let vision_range = 2
    let dir_x : Int = if gs.forward { 1 } else { -1 }
    for v in 1..=vision_range {
      let vx = gs.pos.x + dir_x * v
      let vy = gs.pos.y
      if vx >= 0 && vx < 16 && vy >= 0 && vy < 12 {
        @raylib.draw_rectangle(
          ox + vx * ts,
          oy + vy * ts,
          ts,
          ts,
          @raylib.Color::new(240, 50, 50, 25),
        )
      }
    }
    // Alert pulse
    let pulse = @types.sinf(Float::from_int(game.frame_count) * 0.2) * 3.0
    @raylib.draw_circle_lines_v(
      @raylib.Vector2::new(px, py),
      half + 2.0 + pulse,
      @raylib.Color::new(240, 50, 50, 40),
    )
    // "!" indicator
    @draw.draw_text(
      "!",
      (px - 3.0).to_int(),
      (py - half - 14.0).to_int(),
      12,
      @types.color_guard,
    )
  }
}
