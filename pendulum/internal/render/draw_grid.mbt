///|
fn draw_playing(game : @types.Game) -> Unit {
  draw_grid_background()
  match game.current_level {
    Some(level) => {
      draw_grid_cells(level)
      draw_arc_preview(game)
      draw_rope(game, level)
      draw_weight(game)
      draw_launch_preview(game)
      draw_hud(game, level)
    }
    None => ()
  }
}

///|
fn draw_grid_background() -> Unit {
  // Draw grid background
  @raylib.draw_rectangle(
    @types.grid_offset_x,
    @types.grid_offset_y,
    @types.grid_cols * @types.cell_size,
    @types.grid_rows * @types.cell_size,
    @types.color_grid_bg,
  )
  // Draw grid lines
  for col = 0; col <= @types.grid_cols; col = col + 1 {
    let x = @types.grid_offset_x + col * @types.cell_size
    @raylib.draw_line(
      x,
      @types.grid_offset_y,
      x,
      @types.grid_offset_y + @types.grid_rows * @types.cell_size,
      @types.color_grid_line,
    )
  }
  for row = 0; row <= @types.grid_rows; row = row + 1 {
    let y = @types.grid_offset_y + row * @types.cell_size
    @raylib.draw_line(
      @types.grid_offset_x,
      y,
      @types.grid_offset_x + @types.grid_cols * @types.cell_size,
      y,
      @types.color_grid_line,
    )
  }
}

///|
fn draw_grid_cells(level : @types.Level) -> Unit {
  let cs = @types.cell_size
  let half = cs / 2
  for row = 0; row < @types.grid_rows; row = row + 1 {
    for col = 0; col < @types.grid_cols; col = col + 1 {
      let cx = @types.grid_offset_x + col * cs + half
      let cy = @types.grid_offset_y + row * cs + half
      match level.grid[row][col] {
        Anchor => draw_anchor(cx, cy)
        Peg => draw_peg(cx, cy)
        Goal => draw_goal(cx, cy)
        Wall =>
          @raylib.draw_rectangle(
            @types.grid_offset_x + col * cs + 2,
            @types.grid_offset_y + row * cs + 2,
            cs - 4,
            cs - 4,
            @types.color_wall,
          )
        Collectible => draw_collectible(cx, cy)
        Empty => ()
      }
    }
  }
}

///|
fn draw_anchor(cx : Int, cy : Int) -> Unit {
  @raylib.draw_circle(cx, cy, 10.0, @types.color_anchor)
  @raylib.draw_circle_lines(cx, cy, 14.0, @types.color_anchor)
}

///|
fn draw_peg(cx : Int, cy : Int) -> Unit {
  @raylib.draw_circle(cx, cy, 7.0, @types.color_peg)
  @raylib.draw_circle_lines(cx, cy, 9.0, @types.color_peg)
}

///|
fn draw_goal(cx : Int, cy : Int) -> Unit {
  let fcx = Float::from_int(cx)
  let fcy = Float::from_int(cy)
  // Draw a star shape
  for i = 0; i < 5; i = i + 1 {
    let angle1 = Float::from_int(i) * @types.pi * 2.0 / 5.0 - @types.pi / 2.0
    let angle2 = Float::from_int(i + 1) * @types.pi * 2.0 / 5.0 -
      @types.pi / 2.0
    let x1 = fcx + @types.cosf(angle1) * 16.0
    let y1 = fcy + @types.sinf(angle1) * 16.0
    let x2 = fcx + @types.cosf(angle2) * 16.0
    let y2 = fcy + @types.sinf(angle2) * 16.0
    @raylib.draw_triangle(
      @raylib.Vector2::new(fcx, fcy),
      @raylib.Vector2::new(x1, y1),
      @raylib.Vector2::new(x2, y2),
      @types.color_goal,
    )
  }
  @raylib.draw_circle(cx, cy, 8.0, @types.color_goal)
}

///|
fn draw_collectible(cx : Int, cy : Int) -> Unit {
  @raylib.draw_circle(cx, cy, 8.0, @types.color_collectible)
  @raylib.draw_circle(cx, cy, 4.0, @types.color_bg)
}

///|
fn draw_arc_preview(game : @types.Game) -> Unit {
  if game.weight.state != Swinging {
    return
  }
  let arc = game.arc_points
  if arc.length() == 0 {
    return
  }
  let bottom = @physics.find_bottom_index(arc)
  let (left_limit, right_limit) = @physics.compute_swing_extent(arc, bottom)
  // Draw the full reachable arc with faded gradient trail
  // Points near the current position are brighter, edges are dimmer
  let curr_idx = game.weight.arc_index
  for i = left_limit; i <= right_limit; i = i + 1 {
    let sx = @types.grid_to_screen_x(arc[i].gx).to_int()
    let sy = @types.grid_to_screen_y(arc[i].gy).to_int()
    // Distance from current weight position along arc
    let dist = @types.absi(i - curr_idx)
    let max_dist = @types.maxi(right_limit - left_limit, 1)
    let frac = Float::from_int(dist) / Float::from_int(max_dist)
    // Fade alpha: bright near weight, dim at extremes
    let base_alpha : Float = 160.0
    let fade_range : Float = 120.0
    let min_alpha : Float = 20.0
    let alpha_val = base_alpha - frac * fade_range
    let alpha = if alpha_val < min_alpha {
      20
    } else {
      alpha_val.to_int()
    }
    let trail_color = @raylib.Color::new(100, 140, 200, alpha)
    let r : Float = if i == left_limit || i == right_limit {
      4.0
    } else if i % 2 == 0 {
      2.5
    } else {
      1.5
    }
    @raylib.draw_circle(sx, sy, r, trail_color)
  }
  // Draw swing extent markers at left and right limits
  let lx = @types.grid_to_screen_x(arc[left_limit].gx).to_int()
  let ly = @types.grid_to_screen_y(arc[left_limit].gy).to_int()
  @raylib.draw_circle_lines(lx, ly, 6.0, @raylib.Color::new(100, 140, 220, 120))
  let rx = @types.grid_to_screen_x(arc[right_limit].gx).to_int()
  let ry = @types.grid_to_screen_y(arc[right_limit].gy).to_int()
  @raylib.draw_circle_lines(rx, ry, 6.0, @raylib.Color::new(100, 140, 220, 120))
}

///|
fn draw_rope(game : @types.Game, level : @types.Level) -> Unit {
  if game.weight.state != Swinging {
    return
  }
  let rope = game.rope
  // Draw from original anchor through wrapped pegs to weight
  let mut prev_x = @types.grid_to_screen_x(level.anchor_pos.x)
  let mut prev_y = @types.grid_to_screen_y(level.anchor_pos.y)
  // Draw through wrapped pegs
  for i = 0; i < rope.wrapped_pegs.length(); i = i + 1 {
    let px = @types.grid_to_screen_x(rope.wrapped_pegs[i].x)
    let py = @types.grid_to_screen_y(rope.wrapped_pegs[i].y)
    @raylib.draw_line_ex(
      @raylib.Vector2::new(prev_x, prev_y),
      @raylib.Vector2::new(px, py),
      2.0,
      @types.color_rope,
    )
    prev_x = px
    prev_y = py
  }
  // Draw from last anchor to weight
  let wx = @types.grid_to_screen_x(game.weight.pos.x)
  let wy = @types.grid_to_screen_y(game.weight.pos.y)
  @raylib.draw_line_ex(
    @raylib.Vector2::new(prev_x, prev_y),
    @raylib.Vector2::new(wx, wy),
    2.0,
    @types.color_rope,
  )
}

///|
fn draw_weight(game : @types.Game) -> Unit {
  if game.weight.state == Stopped && game.play_state != Won {
    // Draw stopped weight as dimmed
    let sx = @types.grid_to_screen_x(game.weight.pos.x).to_int()
    let sy = @types.grid_to_screen_y(game.weight.pos.y).to_int()
    @raylib.draw_circle(sx, sy, 12.0, @raylib.Color::new(180, 140, 40, 200))
    return
  }
  if game.weight.state == AtGoal {
    // Draw at goal with glow effect
    let sx = @types.grid_to_screen_x(game.weight.pos.x).to_int()
    let sy = @types.grid_to_screen_y(game.weight.pos.y).to_int()
    let pulse = @types.absf(
      @types.sinf(Float::from_int(game.frame_count) * 0.1),
    )
    let r : Float = 12.0 + pulse * 4.0
    @raylib.draw_circle(sx, sy, r + 4.0, @raylib.Color::new(50, 220, 100, 80))
    @raylib.draw_circle(sx, sy, r, @types.color_goal)
    return
  }
  let sx = @types.grid_to_screen_x(game.weight.pos.x).to_int()
  let sy = @types.grid_to_screen_y(game.weight.pos.y).to_int()
  // Glow
  @raylib.draw_circle(sx, sy, 18.0, @raylib.Color::new(255, 200, 50, 40))
  // Weight
  @raylib.draw_circle(sx, sy, 12.0, @types.color_weight)
  @raylib.draw_circle(sx, sy, 6.0, @raylib.Color::new(255, 230, 120, 255))
}

///|
fn draw_launch_preview(game : @types.Game) -> Unit {
  if game.weight.state != Swinging {
    return
  }
  let level = match game.current_level {
    Some(l) => l
    None => return
  }
  // Show where the weight would go if cut now
  let vel = @types.compute_launch_velocity(
    game.rope.anchor,
    game.weight.pos,
    game.weight.swing_dir,
  )
  let mut px = Float::from_int(game.weight.pos.x)
  let mut py = Float::from_int(game.weight.pos.y)
  let mut hits_goal = false
  let mut prev_sx = @types.grid_to_screen_x(game.weight.pos.x)
  let mut prev_sy = @types.grid_to_screen_y(game.weight.pos.y)
  for step = 0; step < 16; step = step + 1 {
    px = px + vel.x
    py = py + vel.y
    let gx = @types.roundf(px)
    let gy = @types.roundf(py)
    if gx < 0 || gx >= @types.grid_cols || gy < 0 || gy >= @types.grid_rows {
      break
    }
    // Check wall collision
    let mut hit_wall = false
    for w = 0; w < level.walls.length(); w = w + 1 {
      if level.walls[w].x == gx && level.walls[w].y == gy {
        hit_wall = true
        break
      }
    }
    if hit_wall {
      break
    }
    let sx = @types.grid_to_screen_x(gx)
    let sy = @types.grid_to_screen_y(gy)
    // Fade dots along trajectory
    let alpha = 180 - step * 10
    let a = if alpha < 40 { 40 } else { alpha }
    let dot_color = @raylib.Color::new(255, 100, 100, a)
    // Draw connecting line segment
    @raylib.draw_line_ex(
      @raylib.Vector2::new(prev_sx, prev_sy),
      @raylib.Vector2::new(sx, sy),
      1.0,
      @raylib.Color::new(255, 100, 100, a / 2),
    )
    let r : Float = if step < 3 { 3.0 } else { 2.0 }
    @raylib.draw_circle(sx.to_int(), sy.to_int(), r, dot_color)
    prev_sx = sx
    prev_sy = sy
    if gx == level.goal_pos.x && gy == level.goal_pos.y {
      hits_goal = true
    }
  }
  // Cut timing indicator: show if current cut leads toward goal
  draw_cut_indicator(game, hits_goal)
}

///|
fn draw_cut_indicator(game : @types.Game, hits_goal : Bool) -> Unit {
  let wx = @types.grid_to_screen_x(game.weight.pos.x).to_int()
  let wy = @types.grid_to_screen_y(game.weight.pos.y).to_int()
  if hits_goal {
    // Green pulsing ring: optimal cut window
    let pulse = @types.absf(
      @types.sinf(Float::from_int(game.frame_count) * 0.15),
    )
    let r : Float = 18.0 + pulse * 4.0
    @raylib.draw_circle_lines(
      wx,
      wy,
      r,
      @raylib.Color::new(50, 255, 100, 200),
    )
    @raylib.draw_circle_lines(
      wx,
      wy,
      r + 2.0,
      @raylib.Color::new(50, 255, 100, 100),
    )
    // "CUT!" label
    let label = "CUT!"
    let tw = @draw.measure_text(label, 14)
    @raylib.draw_rectangle(
      wx - tw / 2 - 3,
      wy - 32,
      tw + 6,
      18,
      @raylib.Color::new(0, 0, 0, 180),
    )
    @draw.draw_text(
      label,
      wx - tw / 2,
      wy - 30,
      14,
      @raylib.Color::new(50, 255, 100, 255),
    )
  } else {
    // Dim indicator: not optimal
    @raylib.draw_circle_lines(
      wx,
      wy,
      16.0,
      @raylib.Color::new(255, 100, 100, 60),
    )
  }
}
