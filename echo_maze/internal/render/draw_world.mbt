///|
/// Draw the tile grid
pub fn draw_tiles(maze : @types.Maze, maze_state : @types.MazeState) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  for y in 0..<maze.height {
    for x in 0..<maze.width {
      let px = ox + x * ts
      let py = oy + y * ts
      let tile = maze.tiles[y][x]
      let color = tile_color(tile.kind, maze_state)
      @raylib.draw_rectangle(px, py, ts, ts, color)
      // Subtle grid lines
      @raylib.draw_rectangle_lines(
        px,
        py,
        ts,
        ts,
        @raylib.Color::new(30, 25, 50, 60),
      )
    }
  }
}

///|
fn tile_color(
  kind : @types.TileKind,
  maze_state : @types.MazeState
) -> @raylib.Color {
  match kind {
    Floor => @types.color_floor
    Wall => @types.color_wall
    Start => @types.color_start
    Exit => @types.color_exit
    Button(_) => @types.color_floor // glow drawn separately
    Door(id) => {
      let mut open = false
      for ds in maze_state.door_states {
        if ds.door_id == id {
          open = ds.open
        }
      }
      if open { @types.color_door_open } else { @types.color_door_closed }
    }
    TimedDoor(id, _) => {
      let mut open = false
      for ds in maze_state.door_states {
        if ds.door_id == id {
          open = ds.open
        }
      }
      if open {
        @raylib.Color::new(100, 60, 220, 60)
      } else {
        @types.color_timed_door
      }
    }
    Guard => @types.color_floor
    Collectible => @types.color_floor // drawn separately
  }
}

///|
/// Draw wall edges for depth effect
pub fn draw_wall_edges(maze : @types.Maze) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  for y in 0..<maze.height {
    for x in 0..<maze.width {
      if maze.tiles[y][x].kind is Wall {
        let px = ox + x * ts
        let py = oy + y * ts
        // Draw edge highlight on bottom and right of walls adjacent to non-walls
        if y + 1 < maze.height && !(maze.tiles[y + 1][x].kind is Wall) {
          @raylib.draw_line(
            px,
            py + ts,
            px + ts,
            py + ts,
            @types.color_wall_edge,
          )
        }
        if x + 1 < maze.width && !(maze.tiles[y][x + 1].kind is Wall) {
          @raylib.draw_line(
            px + ts,
            py,
            px + ts,
            py + ts,
            @types.color_wall_edge,
          )
        }
        // Left edge
        if x > 0 && !(maze.tiles[y][x - 1].kind is Wall) {
          @raylib.draw_line(px, py, px, py + ts, @types.color_wall_edge)
        }
        // Top edge
        if y > 0 && !(maze.tiles[y - 1][x].kind is Wall) {
          @raylib.draw_line(px, py, px + ts, py, @types.color_wall_edge)
        }
      }
    }
  }
}

///|
/// Draw border around the grid
pub fn draw_grid_border(maze : @types.Maze) -> Unit {
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let gw = maze.width * @types.tile_size
  let gh = maze.height * @types.tile_size
  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(
      Float::from_int(ox - 1),
      Float::from_int(oy - 1),
      Float::from_int(gw + 2),
      Float::from_int(gh + 2),
    ),
    1.0,
    @raylib.Color::new(80, 65, 120, 200),
  )
}

///|
/// Draw exit tile glow
pub fn draw_exit_glow(maze : @types.Maze, game : @types.Game) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let pulse = @types.sinf(Float::from_int(game.frame_count) * 0.1) * 0.4 + 0.6
  let cx = Float::from_int(ox + maze.exit.x * ts + ts / 2)
  let cy = Float::from_int(oy + maze.exit.y * ts + ts / 2)
  let radius = Float::from_int(ts / 2) + 6.0 * pulse
  let alpha_f : Float = 30.0 * pulse
  @raylib.draw_circle_v(
    @raylib.Vector2::new(cx, cy),
    radius,
    @raylib.Color::new(50, 255, 120, alpha_f.to_int()),
  )
}

///|
/// Draw button glow effects
pub fn draw_button_glow(
  maze : @types.Maze,
  maze_state : @types.MazeState,
  game : @types.Game
) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let pulse = @types.sinf(Float::from_int(game.frame_count) * 0.12) * 0.3 + 0.7
  for y in 0..<maze.height {
    for x in 0..<maze.width {
      match maze.tiles[y][x].kind {
        Button(btn_id) => {
          let cx = Float::from_int(ox + x * ts + ts / 2)
          let cy = Float::from_int(oy + y * ts + ts / 2)
          let pressed = btn_id < maze_state.button_pressed.length() &&
            maze_state.button_pressed[btn_id]
          let color = if pressed {
            @types.color_button_pressed
          } else {
            @types.color_button
          }
          // Button body
          let btn_size = ts - 12
          @raylib.draw_rectangle(
            ox + x * ts + 6,
            oy + y * ts + 6,
            btn_size,
            btn_size,
            color,
          )
          // Glow ring when not pressed
          if !pressed {
            let radius = Float::from_int(ts / 2 - 2) + 3.0 * pulse
            let alpha_f : Float = 40.0 * pulse
            @raylib.draw_circle_lines_v(
              @raylib.Vector2::new(cx, cy),
              radius,
              @raylib.Color::new(255, 200, 40, alpha_f.to_int()),
            )
          }
          // Label
          let label = "B\{btn_id}"
          let lw = @draw.measure_text(label, 10)
          @draw.draw_text(
            label,
            ox + x * ts + ts / 2 - lw / 2,
            oy + y * ts + ts / 2 - 5,
            10,
            @raylib.Color::new(0, 0, 0, 200),
          )
        }
        _ => ()
      }
    }
  }
}

///|
/// Draw collectible items
pub fn draw_collectibles(
  maze : @types.Maze,
  maze_state : @types.MazeState,
  game : @types.Game
) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let pulse = @types.sinf(Float::from_int(game.frame_count) * 0.15) * 3.0 + 8.0
  for i in 0..<maze.collectible_positions.length() {
    if maze_state.collectibles_collected[i] {
      continue
    }
    let pos = maze.collectible_positions[i]
    let cx = Float::from_int(ox + pos.x * ts + ts / 2)
    let cy = Float::from_int(oy + pos.y * ts + ts / 2)
    // Star-like shape using layered circles
    @raylib.draw_circle_v(
      @raylib.Vector2::new(cx, cy),
      pulse,
      @types.color_collectible,
    )
    // Inner bright core
    @raylib.draw_circle_v(
      @raylib.Vector2::new(cx, cy),
      4.0,
      @raylib.Color::new(255, 255, 255, 200),
    )
    // Glow
    let glow_r = pulse + 4.0
    @raylib.draw_circle_v(
      @raylib.Vector2::new(cx, cy),
      glow_r,
      @raylib.Color::new(255, 215, 0, 30),
    )
  }
}

///|
/// Draw door labels
pub fn draw_door_labels(
  maze : @types.Maze,
  maze_state : @types.MazeState
) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  for y in 0..<maze.height {
    for x in 0..<maze.width {
      match maze.tiles[y][x].kind {
        Door(id) | TimedDoor(id, _) => {
          let cx = ox + x * ts + ts / 2
          let cy = oy + y * ts + ts / 2
          let mut is_open = false
          for ds in maze_state.door_states {
            if ds.door_id == id {
              is_open = ds.open
            }
          }
          let label = if is_open { "O" } else { "X" }
          let color = if is_open {
            @types.color_door_open
          } else {
            @raylib.Color::new(200, 200, 255, 200)
          }
          let lw = @draw.measure_text(label, 12)
          @draw.draw_text(label, cx - lw / 2, cy - 6, 12, color)
        }
        _ => ()
      }
    }
  }
}

///|
/// Draw a pulsing marker on the start tile
pub fn draw_start_marker(maze : @types.Maze, game : @types.Game) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let sx = maze.start.x
  let sy = maze.start.y
  let cx = Float::from_int(ox + sx * ts + ts / 2)
  let cy = Float::from_int(oy + sy * ts + ts / 2)
  let pulse = @types.sinf(Float::from_int(game.frame_count) * 0.08) * 0.3 + 0.7
  let radius = Float::from_int(ts / 2 - 4) * pulse
  let alpha_f : Float = 40.0 * pulse
  @raylib.draw_circle_v(
    @raylib.Vector2::new(cx, cy),
    radius,
    @raylib.Color::new(0, 180, 200, alpha_f.to_int()),
  )
  // "S" label
  let label = "S"
  let lw = @draw.measure_text(label, 14)
  @draw.draw_text(
    label,
    (cx - Float::from_int(lw) / 2.0).to_int(),
    (cy - 7.0).to_int(),
    14,
    @raylib.Color::new(0, 220, 240, 160),
  )
}

///|
/// Draw timed door timer indicators
pub fn draw_timed_door_indicators(
  maze : @types.Maze,
  maze_state : @types.MazeState,
  game : @types.Game
) -> Unit {
  let ts = @types.tile_size
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  for y in 0..<maze.height {
    for x in 0..<maze.width {
      match maze.tiles[y][x].kind {
        TimedDoor(id, duration) => {
          let px = ox + x * ts
          let py = oy + y * ts
          let mut is_open = false
          for ds in maze_state.door_states {
            if ds.door_id == id {
              is_open = ds.open
            }
          }
          // Timer bar below door
          let cycle = duration * 2
          let phase = game.tick % cycle
          let ratio : Float = Float::from_int(phase) / Float::from_int(cycle)
          let bar_w = ts - 4
          let bar_h = 3
          @raylib.draw_rectangle(
            px + 2,
            py + ts - 5,
            bar_w,
            bar_h,
            @raylib.Color::new(30, 20, 50, 200),
          )
          let fill_w = (Float::from_int(bar_w) * ratio).to_int()
          let bar_color = if is_open {
            @raylib.Color::new(100, 60, 220, 200)
          } else {
            @raylib.Color::new(200, 60, 220, 200)
          }
          @raylib.draw_rectangle(
            px + 2,
            py + ts - 5,
            fill_w,
            bar_h,
            bar_color,
          )
        }
        _ => ()
      }
    }
  }
}
