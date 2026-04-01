///|
pub fn draw_grid(game : @types.Game) -> Unit {
  match game.level {
    None => ()
    Some(level) => {
      let grid = level.grid
      // Draw tiles
      for y in 0..<grid.height {
        for x in 0..<grid.width {
          let sx = @types.tile_screen_x(x)
          let sy = @types.tile_screen_y(y)
          let sz = @types.tile_size
          let tile = @types.grid_get(grid, x, y)
          match tile {
            Floor => {
              @raylib.draw_rectangle(sx, sy, sz, sz, @types.color_floor)
              @raylib.draw_rectangle_lines(
                sx, sy, sz, sz, @types.color_grid_line,
              )
            }
            Wall => {
              // Wall with shadow
              @raylib.draw_rectangle(
                sx + 2,
                sy + 2,
                sz,
                sz,
                @types.color_wall_shadow,
              )
              @raylib.draw_rectangle(sx, sy, sz, sz, @types.color_wall)
            }
            Gap => @raylib.draw_rectangle(sx, sy, sz, sz, @types.color_gap)
            Goal => {
              @raylib.draw_rectangle(sx, sy, sz, sz, @types.color_floor)
              // Check if already collected
              let collected = is_goal_collected(game, x, y)
              if collected {
                // Dim collected goal
                @raylib.draw_rectangle(
                  sx + 4,
                  sy + 4,
                  sz - 8,
                  sz - 8,
                  @types.color_goal_dim,
                )
              } else {
                // Pulsing goal
                let t = Float::from_int(game.frame_count) * 0.05
                let pulse = (sinf(t) + 1.0) * 0.5
                let size_mod = (pulse * 4.0).to_int()
                @raylib.draw_rectangle(
                  sx + 6 - size_mod,
                  sy + 6 - size_mod,
                  sz - 12 + size_mod * 2,
                  sz - 12 + size_mod * 2,
                  @types.color_goal,
                )
              }
              @raylib.draw_rectangle_lines(
                sx, sy, sz, sz, @types.color_grid_line,
              )
            }
            ColorTile(Red) => {
              @raylib.draw_rectangle(sx, sy, sz, sz, @types.color_red_tile)
              @raylib.draw_rectangle_lines(
                sx, sy, sz, sz, @types.color_grid_line,
              )
            }
            ColorTile(Blue) => {
              @raylib.draw_rectangle(sx, sy, sz, sz, @types.color_blue_tile)
              @raylib.draw_rectangle_lines(
                sx, sy, sz, sz, @types.color_grid_line,
              )
            }
            ColorTile(Green) => {
              @raylib.draw_rectangle(sx, sy, sz, sz, @types.color_green_tile)
              @raylib.draw_rectangle_lines(
                sx, sy, sz, sz, @types.color_grid_line,
              )
            }
            Block => {
              @raylib.draw_rectangle(sx, sy, sz, sz, @types.color_floor)
              @raylib.draw_rectangle_lines(
                sx, sy, sz, sz, @types.color_grid_line,
              )
            }
            Start => {
              @raylib.draw_rectangle(sx, sy, sz, sz, @types.color_start)
              @raylib.draw_rectangle_lines(
                sx, sy, sz, sz, @types.color_grid_line,
              )
            }
          }
        }
      }
      // Draw blocks
      draw_blocks(game)
      // Draw robot
      draw_robot(game)
    }
  }
}

///|
fn is_goal_collected(game : @types.Game, x : Int, y : Int) -> Bool {
  match game.trace {
    Some(trace) =>
      if game.trace_step >= 0 && game.trace_step < trace.states.length() {
        let state = trace.states[game.trace_step]
        match game.level {
          Some(level) => {
            for i in 0..<level.goals.length() {
              if level.goals[i].x == x &&
                level.goals[i].y == y &&
                i < state.goals_collected.length() {
                return state.goals_collected[i]
              }
            }
            false
          }
          None => false
        }
      } else {
        false
      }
    None =>
      match game.level {
        Some(level) => {
          for i in 0..<level.goals.length() {
            if level.goals[i].x == x && level.goals[i].y == y {
              return level.goals_collected[i]
            }
          }
          false
        }
        None => false
      }
  }
}

///|
fn draw_blocks(game : @types.Game) -> Unit {
  let blocks = get_current_blocks(game)
  let sz = @types.tile_size
  for i in 0..<blocks.length() {
    let bx = @types.tile_screen_x(blocks[i].x)
    let by = @types.tile_screen_y(blocks[i].y)
    // Shadow
    @raylib.draw_rectangle(
      bx + 3,
      by + 3,
      sz - 2,
      sz - 2,
      @types.color_wall_shadow,
    )
    // Block body
    @raylib.draw_rectangle(bx + 2, by + 2, sz - 4, sz - 4, @types.color_block)
    // Inner detail
    @raylib.draw_rectangle(
      bx + 8,
      by + 8,
      sz - 16,
      sz - 16,
      @raylib.Color::new(200, 160, 80, 255),
    )
    @raylib.draw_rectangle_lines(
      bx + 2,
      by + 2,
      sz - 4,
      sz - 4,
      @raylib.Color::new(140, 100, 40, 255),
    )
  }
}

///|
fn get_current_blocks(game : @types.Game) -> Array[@types.Vec2i] {
  match game.trace {
    Some(trace) =>
      if game.trace_step >= 0 && game.trace_step < trace.states.length() {
        trace.states[game.trace_step].blocks
      } else {
        match game.level {
          Some(level) => level.blocks
          None => []
        }
      }
    None =>
      match game.level {
        Some(level) => level.blocks
        None => []
      }
  }
}

///|
fn draw_robot(game : @types.Game) -> Unit {
  let (rx, ry, dir, alive) = get_robot_state(game)
  if !alive {
    // Draw X at last position
    let cx = @types.tile_center_x(rx)
    let cy = @types.tile_center_y(ry)
    @raylib.draw_line(cx - 12, cy - 12, cx + 12, cy + 12, @types.color_fail)
    @raylib.draw_line(cx - 12, cy + 12, cx + 12, cy - 12, @types.color_fail)
    return
  }
  let cx = Float::from_int(@types.tile_center_x(rx))
  let cy = Float::from_int(@types.tile_center_y(ry))
  let sz : Float = Float::from_int(@types.tile_size) / 2.0 - 4.0
  // Draw robot as triangle pointing in direction
  let (dx, dy) : (Float, Float) = match dir {
    North => (0.0, -1.0)
    South => (0.0, 1.0)
    East => (1.0, 0.0)
    West => (-1.0, 0.0)
  }
  // Triangle vertices
  let tip_x = cx + dx * sz
  let tip_y = cy + dy * sz
  // Perpendicular
  let px = -dy
  let py = dx
  let base_x = cx - dx * sz * 0.6
  let base_y = cy - dy * sz * 0.6
  let v1x = (base_x + px * sz * 0.5).to_int()
  let v1y = (base_y + py * sz * 0.5).to_int()
  let v2x = (base_x - px * sz * 0.5).to_int()
  let v2y = (base_y - py * sz * 0.5).to_int()
  // Glow behind robot
  @raylib.draw_circle(
    cx.to_int(),
    cy.to_int(),
    sz + 4.0,
    @types.color_robot_trail,
  )
  // Triangle body
  @raylib.draw_triangle(
    @raylib.Vector2::new(tip_x, tip_y),
    @raylib.Vector2::new(Float::from_int(v1x), Float::from_int(v1y)),
    @raylib.Vector2::new(Float::from_int(v2x), Float::from_int(v2y)),
    @types.color_robot,
  )
  // Eye dot
  let eye_x = (cx + dx * sz * 0.2).to_int()
  let eye_y = (cy + dy * sz * 0.2).to_int()
  @raylib.draw_circle(eye_x, eye_y, 3.0, @types.color_bg)
}

///|
fn get_robot_state(game : @types.Game) -> (Int, Int, @types.Direction, Bool) {
  match game.trace {
    Some(trace) =>
      if game.trace_step >= 0 && game.trace_step < trace.states.length() {
        let s = trace.states[game.trace_step]
        (s.pos.x, s.pos.y, s.dir, s.alive)
      } else {
        get_level_robot(game)
      }
    None => get_level_robot(game)
  }
}

///|
fn get_level_robot(game : @types.Game) -> (Int, Int, @types.Direction, Bool) {
  match game.level {
    Some(level) =>
      (level.robot.pos.x, level.robot.pos.y, level.robot.dir, level.robot.alive)
    None => (0, 0, East, false)
  }
}
