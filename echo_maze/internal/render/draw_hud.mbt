///|
/// Draw the HUD panel on the right side
pub fn draw_hud(game : @types.Game) -> Unit {
  let maze = match game.maze {
    Some(m) => m
    None => return
  }
  let sw = @types.screen_width
  // Right panel
  let panel_x = @types.grid_offset_x + maze.width * @types.tile_size + 16
  let panel_w = sw - panel_x - 10
  let panel_y = 30
  let panel_h = 660
  @raylib.draw_rectangle(
    panel_x, panel_y, panel_w, panel_h, @types.color_hud_bg,
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    panel_y,
    panel_w,
    panel_h,
    @raylib.Color::new(80, 65, 120, 200),
  )
  let nx = panel_x + 12
  let mut y = panel_y + 10
  // Level name
  let level_name = match
    @maze.get_level(game.current_world, game.current_level) {
    Some(ld) => ld.name
    None => "Unknown"
  }
  @draw.draw_text(level_name, nx, y, 16, @raylib.Color::new(0, 220, 240, 255))
  y += 22
  // World-Level indicator
  let world_names = ["Foundations", "Timing", "Mastery"]
  let world_name = if game.current_world < world_names.length() {
    world_names[game.current_world]
  } else {
    "Unknown"
  }
  @draw.draw_text(
    "W\{game.current_world + 1}: \{world_name}",
    nx,
    y,
    12,
    @raylib.Color::new(120, 110, 150, 255),
  )
  y += 24
  // Separator
  @raylib.draw_line(
    nx,
    y,
    nx + panel_w - 24,
    y,
    @raylib.Color::new(80, 65, 120, 120),
  )
  y += 10
  // Loop counter
  @draw.draw_text("LOOP", nx, y, 11, @raylib.Color::new(120, 110, 150, 255))
  y += 14
  let loop_str = "\{game.loop_count + 1} / \{@types.max_ghosts + 1}"
  @draw.draw_text(loop_str, nx, y, 20, @types.color_hud_text)
  y += 28
  // Tick counter
  @draw.draw_text("TICK", nx, y, 11, @raylib.Color::new(120, 110, 150, 255))
  y += 14
  let tick_str = "\{game.tick} / \{game.max_ticks}"
  @draw.draw_text(tick_str, nx, y, 18, @types.color_hud_text)
  y += 26
  // Tick progress bar
  let bar_w = panel_w - 24
  let bar_h = 8
  @raylib.draw_rectangle(
    nx,
    y,
    bar_w,
    bar_h,
    @raylib.Color::new(30, 25, 50, 200),
  )
  let fill_ratio : Float = Float::from_int(game.tick) /
    Float::from_int(game.max_ticks)
  let fill_w = (Float::from_int(bar_w) * fill_ratio).to_int()
  let bar_color = if fill_ratio > 0.8 {
    @raylib.Color::new(240, 50, 50, 255)
  } else if fill_ratio > 0.5 {
    @raylib.Color::new(240, 220, 40, 255)
  } else {
    @raylib.Color::new(0, 220, 240, 255)
  }
  @raylib.draw_rectangle(nx, y, fill_w, bar_h, bar_color)
  y += 18
  // Separator
  @raylib.draw_line(
    nx,
    y,
    nx + panel_w - 24,
    y,
    @raylib.Color::new(80, 65, 120, 120),
  )
  y += 10
  // Ghosts
  @draw.draw_text("GHOSTS", nx, y, 11, @raylib.Color::new(120, 110, 150, 255))
  y += 16
  for i in 0..<@types.max_ghosts {
    let gx = nx + i * 28
    if i < game.ghosts.length() {
      let ghost = game.ghosts[i]
      let color = @types.ghost_color_value(ghost.color)
      @raylib.draw_circle(gx + 10, y + 10, 10.0, color)
      if ghost.active {
        @raylib.draw_circle(
          gx + 10,
          y + 10,
          4.0,
          @raylib.Color::new(255, 255, 255, 180),
        )
      } else {
        // X through deactivated ghost
        @draw.draw_text(
          "X",
          gx + 5,
          y + 3,
          14,
          @raylib.Color::new(240, 50, 50, 200),
        )
      }
    } else {
      // Empty ghost slot
      @raylib.draw_circle_lines(
        gx + 10,
        y + 10,
        10.0,
        @raylib.Color::new(80, 65, 120, 100),
      )
    }
  }
  y += 30
  // Separator
  @raylib.draw_line(
    nx,
    y,
    nx + panel_w - 24,
    y,
    @raylib.Color::new(80, 65, 120, 120),
  )
  y += 10
  // Collectibles
  let maze_st = game.maze_state.unwrap()
  let mut collected = 0
  for c in maze_st.collectibles_collected {
    if c {
      collected += 1
    }
  }
  let total_c = maze.collectible_positions.length()
  if total_c > 0 {
    @draw.draw_text(
      "COLLECTIBLES",
      nx,
      y,
      11,
      @raylib.Color::new(120, 110, 150, 255),
    )
    y += 16
    let col_color = if collected >= total_c {
      @types.color_collectible
    } else {
      @types.color_hud_text
    }
    @draw.draw_text("\{collected}/\{total_c}", nx, y, 18, col_color)
    y += 26
  }
  // Play state
  @draw.draw_text("STATE", nx, y, 11, @raylib.Color::new(120, 110, 150, 255))
  y += 16
  let state_str = match game.play_state {
    Recording => "RECORDING"
    Reviewing => "PLANNING"
    Complete => "COMPLETE"
    Failed => "FAILED"
  }
  let state_color = match game.play_state {
    Recording => @raylib.Color::new(0, 220, 240, 255)
    Reviewing => @raylib.Color::new(240, 220, 40, 255)
    Complete => @raylib.Color::new(50, 255, 120, 255)
    Failed => @raylib.Color::new(240, 50, 50, 255)
  }
  @draw.draw_text(state_str, nx, y, 16, state_color)
  y += 28
  // Par info
  let par = match @maze.get_level(game.current_world, game.current_level) {
    Some(ld) => ld.par_loops
    None => 3
  }
  @draw.draw_text(
    "PAR: \{par} loops",
    nx,
    y,
    12,
    @raylib.Color::new(120, 110, 150, 255),
  )
  y += 24
  // Separator
  @raylib.draw_line(
    nx,
    y,
    nx + panel_w - 24,
    y,
    @raylib.Color::new(80, 65, 120, 120),
  )
  y += 10
  // Controls
  draw_controls_hint(nx, y)
  // Minimap
  draw_minimap(game, maze, nx, panel_y + panel_h - 90)
}

///|
fn draw_controls_hint(x : Int, y : Int) -> Unit {
  let dim = @raylib.Color::new(100, 95, 130, 255)
  @draw.draw_text("CONTROLS", x, y, 10, @raylib.Color::new(120, 110, 150, 255))
  @draw.draw_text("WASD/Arrows  Move", x, y + 13, 10, dim)
  @draw.draw_text("SPACE  End Loop", x, y + 25, 10, dim)
  @draw.draw_text("R  Reset Level", x, y + 37, 10, dim)
  @draw.draw_text("ESC  Pause", x, y + 49, 10, dim)
}

///|
fn draw_minimap(
  game : @types.Game,
  maze : @types.Maze,
  x : Int,
  y : Int,
) -> Unit {
  let scale = 4
  let w = maze.width * scale
  let h = maze.height * scale
  // Background
  @raylib.draw_rectangle(
    x - 2,
    y - 2,
    w + 4,
    h + 4,
    @raylib.Color::new(15, 10, 30, 200),
  )
  @raylib.draw_rectangle_lines(
    x - 2,
    y - 2,
    w + 4,
    h + 4,
    @raylib.Color::new(80, 65, 120, 150),
  )
  // Tiles
  for ty in 0..<maze.height {
    for tx in 0..<maze.width {
      let px = x + tx * scale
      let py = y + ty * scale
      let color = match maze.tiles[ty][tx].kind {
        Wall => @raylib.Color::new(60, 50, 90, 255)
        Exit => @raylib.Color::new(50, 255, 120, 255)
        Button(_) => @raylib.Color::new(255, 200, 40, 255)
        Door(_) | TimedDoor(_, _) => @raylib.Color::new(60, 100, 220, 255)
        _ => @raylib.Color::new(25, 20, 40, 255)
      }
      @raylib.draw_rectangle(px, py, scale, scale, color)
    }
  }
  // Guards
  let maze_state = game.maze_state.unwrap()
  for gs in maze_state.guard_states {
    let gpx = x + gs.pos.x * scale
    let gpy = y + gs.pos.y * scale
    @raylib.draw_rectangle(gpx, gpy, scale, scale, @types.color_guard)
  }
  // Ghosts
  for ghost in game.ghosts {
    if ghost.active {
      let gpx = x + ghost.pos.x * scale
      let gpy = y + ghost.pos.y * scale
      @raylib.draw_rectangle(
        gpx,
        gpy,
        scale,
        scale,
        @types.ghost_color_value(ghost.color),
      )
    }
  }
  // Player
  if game.player.alive {
    let ppx = x + game.player.pos.x * scale
    let ppy = y + game.player.pos.y * scale
    @raylib.draw_rectangle(ppx, ppy, scale, scale, @types.color_player)
  }
}

///|
fn draw_message(game : @types.Game, maze : @types.Maze) -> Unit {
  if game.message_timer <= 0.0 {
    return
  }
  let text = game.message
  let size = 24
  let tw = @draw.measure_text(text, size)
  let cx = @types.grid_offset_x + maze.width * @types.tile_size / 2 - tw / 2
  let cy = @types.grid_offset_y + maze.height * @types.tile_size / 2 - size / 2
  // Background
  @raylib.draw_rectangle(
    cx - 15,
    cy - 8,
    tw + 30,
    size + 16,
    @types.color_hud_bg,
  )
  @raylib.draw_rectangle_lines(
    cx - 15,
    cy - 8,
    tw + 30,
    size + 16,
    @raylib.Color::new(80, 65, 120, 200),
  )
  @draw.draw_text(text, cx, cy, size, @raylib.Color::new(0, 220, 240, 255))
}
