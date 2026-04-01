///|
pub fn update(game : @types.Game) -> Unit {
  let dt = @raylib.get_frame_time()
  game.anim_timer = game.anim_timer + dt
  game.frame_count = game.frame_count + 1
  game.energy_phase = game.energy_phase + dt * 2.0
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
    if game.message_timer <= 0.0 {
      game.message = ""
    }
  }
  match game.screen {
    Title => update_title(game)
    LevelSelect => update_level_select(game)
    Playing => update_playing(game)
    LevelComplete => update_level_complete(game)
    LevelFailed => update_level_failed(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_mouse_button_pressed(0) {
    game.screen = LevelSelect
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  // Scroll with up/down
  if @raylib.is_key_pressed(@raylib.KeyUp) && game.scroll_offset > 0 {
    game.scroll_offset = game.scroll_offset - 1
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.scroll_offset = game.scroll_offset + 1
  }
  // Mouse click to select level
  if @raylib.is_mouse_button_pressed(0) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    handle_level_select_click(game, mx, my)
  }
}

///|
fn handle_level_select_click(game : @types.Game, mx : Int, my : Int) -> Unit {
  let start_y = 80
  let row_height = 50
  for i in 0..<@types.total_levels {
    let visible_idx = i - game.scroll_offset
    if visible_idx < 0 || visible_idx > 11 {
      continue
    }
    let y = start_y + visible_idx * row_height
    if mx >= 50 && mx <= 850 && my >= y && my < y + row_height {
      if @types.level_unlocked(game.progress, i) {
        start_level(game, i)
      } else {
        game.message = "Level locked! Complete previous level first."
        game.message_timer = 2.0
      }
      return
    }
  }
}

///|
fn start_level(game : @types.Game, level_id : Int) -> Unit {
  match @levels.get_level(level_id) {
    Some(def) => {
      game.current_level = level_id
      game.level_def = Some(def)
      game.level_state = Some(@types.init_level_state(def))
      game.screen = Playing
      game.tool = PlaceWaystone
      game.message = ""
      game.message_timer = 0.0
    }
    None => ()
  }
}

///|
fn update_playing(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    game.level_def = None
    game.level_state = None
    return
  }
  guard game.level_state is Some(state) else { return }
  // Tool switching
  handle_tool_switch(game)
  // Mouse input
  update_cursor(state)
  handle_mouse_input(game, state)
  // Recalculate energy
  @energy.simulate(state)
  // Update glow animations
  update_cell_animations(state)
  // Check win/fail
  if state.all_temples_powered {
    complete_level(game, state)
  }
  // R to reset
  if @raylib.is_key_pressed(@raylib.KeyR) {
    guard game.level_def is Some(def) else { return }
    game.level_state = Some(@types.init_level_state(def))
  }
}

///|
fn handle_tool_switch(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.tool = PlaceWaystone
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.tool = RemoveWaystone
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.tool = DrawLine
  }
  if @raylib.is_key_pressed(@raylib.KeyFour) {
    game.tool = EraseLine
  }
}

///|
fn update_cursor(state : @types.LevelState) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let col = (mx - @types.grid_offset_x) / @types.cell_size
  let row = (my - @types.grid_offset_y) / @types.cell_size
  if @types.in_grid(col, row) {
    state.cursor_col = col
    state.cursor_row = row
    state.hover_valid = true
  } else {
    state.cursor_col = -1
    state.cursor_row = -1
    state.hover_valid = false
  }
}

///|
fn handle_mouse_input(game : @types.Game, state : @types.LevelState) -> Unit {
  if !state.hover_valid {
    if @raylib.is_mouse_button_released(0) {
      state.is_drawing_line = false
    }
    return
  }
  let col = state.cursor_col
  let row = state.cursor_row
  match game.tool {
    PlaceWaystone => handle_place_waystone(game, state, col, row)
    RemoveWaystone => handle_remove_waystone(game, state, col, row)
    DrawLine => handle_draw_line(game, state, col, row)
    EraseLine => handle_erase_line(game, state, col, row)
  }
}

///|
fn handle_place_waystone(
  game : @types.Game,
  state : @types.LevelState,
  col : Int,
  row : Int
) -> Unit {
  if @raylib.is_mouse_button_pressed(0) {
    if state.grid[row][col].kind is Empty {
      if state.waystones_placed < state.waystone_budget {
        state.grid[row][col].kind = Waystone
        state.waystones_placed = state.waystones_placed + 1
      } else {
        game.message = "No more waystones! Remove some first."
        game.message_timer = 2.0
      }
    }
  }
}

///|
fn handle_remove_waystone(
  game : @types.Game,
  state : @types.LevelState,
  col : Int,
  row : Int
) -> Unit {
  if @raylib.is_mouse_button_pressed(0) {
    if state.grid[row][col].kind is Waystone {
      // Check if this waystone was pre-placed in the level
      guard game.level_def is Some(def) else { return }
      let original = if row < def.grid.length() && col < def.grid[row].length() {
        def.grid[row][col]
      } else {
        Empty
      }
      if original is Waystone {
        game.message = "Cannot remove pre-placed waystone!"
        game.message_timer = 2.0
        return
      }
      state.grid[row][col].kind = Empty
      state.waystones_placed = state.waystones_placed - 1
      // Remove connections to this cell
      remove_connections_at(state, col, row)
    }
  }
}

///|
fn handle_draw_line(
  _game : @types.Game,
  state : @types.LevelState,
  col : Int,
  row : Int
) -> Unit {
  if @raylib.is_mouse_button_pressed(0) {
    if @types.is_connectable(state.grid[row][col].kind) {
      state.is_drawing_line = true
      state.draw_start_col = col
      state.draw_start_row = row
    }
  }
  if @raylib.is_mouse_button_released(0) && state.is_drawing_line {
    let sc = state.draw_start_col
    let sr = state.draw_start_row
    state.is_drawing_line = false
    if @types.in_grid(col, row) &&
      @types.is_connectable(state.grid[row][col].kind) &&
      @types.is_adjacent(sc, sr, col, row) &&
      !@types.connection_exists(state.connections, sc, sr, col, row) &&
      (sc != col || sr != row) {
      state.connections.push(@types.new_connection(sc, sr, col, row))
    }
  }
}

///|
fn handle_erase_line(
  _game : @types.Game,
  state : @types.LevelState,
  col : Int,
  row : Int
) -> Unit {
  if @raylib.is_mouse_button_pressed(0) {
    if @types.is_connectable(state.grid[row][col].kind) {
      state.is_drawing_line = true
      state.draw_start_col = col
      state.draw_start_row = row
    }
  }
  if @raylib.is_mouse_button_released(0) && state.is_drawing_line {
    let sc = state.draw_start_col
    let sr = state.draw_start_row
    state.is_drawing_line = false
    if @types.in_grid(col, row) {
      remove_specific_connection(state, sc, sr, col, row)
    }
  }
}

///|
fn remove_connections_at(state : @types.LevelState, col : Int, row : Int) -> Unit {
  let new_conns : Array[@types.Connection] = []
  for i in 0..<state.connections.length() {
    let c = state.connections[i]
    if !((c.from_col == col && c.from_row == row) ||
      (c.to_col == col && c.to_row == row)) {
      new_conns.push(c)
    }
  }
  state.connections = new_conns
}

///|
fn remove_specific_connection(
  state : @types.LevelState,
  c1 : Int,
  r1 : Int,
  c2 : Int,
  r2 : Int
) -> Unit {
  let new_conns : Array[@types.Connection] = []
  for i in 0..<state.connections.length() {
    let c = state.connections[i]
    let matches = (c.from_col == c1 &&
      c.from_row == r1 &&
      c.to_col == c2 &&
      c.to_row == r2) ||
      (c.from_col == c2 && c.from_row == r2 && c.to_col == c1 && c.to_row == r1)
    if !matches {
      new_conns.push(c)
    }
  }
  state.connections = new_conns
}

///|
fn update_cell_animations(state : @types.LevelState) -> Unit {
  for row in 0..<@types.grid_rows {
    for col in 0..<@types.grid_cols {
      let cell = state.grid[row][col]
      if cell.energy_received > 0.1 {
        if cell.glow_anim < 1.0 {
          cell.glow_anim = cell.glow_anim + 0.05
          if cell.glow_anim > 1.0 {
            cell.glow_anim = 1.0
          }
        }
      } else {
        if cell.glow_anim > 0.0 {
          cell.glow_anim = cell.glow_anim - 0.03
          if cell.glow_anim < 0.0 {
            cell.glow_anim = 0.0
          }
        }
      }
    }
  }
}

///|
fn complete_level(game : @types.Game, state : @types.LevelState) -> Unit {
  guard game.level_def is Some(def) else { return }
  let stars = calculate_stars(def, state)
  let prog = game.progress[game.current_level]
  prog.completed = true
  if star_value(stars) > star_value(prog.stars) {
    prog.stars = stars
  }
  if prog.best_waystones == 0 ||
    state.waystones_placed < prog.best_waystones {
    prog.best_waystones = state.waystones_placed
  }
  if state.total_energy_delivered > prog.best_energy {
    prog.best_energy = state.total_energy_delivered
  }
  game.screen = LevelComplete
}

///|
fn calculate_stars(
  def : @types.LevelDef,
  state : @types.LevelState
) -> @types.StarRating {
  let energy = state.total_energy_delivered
  if energy >= def.gold_threshold && state.waystones_placed <= def.par_waystones {
    Gold
  } else if energy >= def.silver_threshold {
    Silver
  } else {
    Bronze
  }
}

///|
fn star_value(rating : @types.StarRating) -> Int {
  match rating {
    None => 0
    Bronze => 1
    Silver => 2
    Gold => 3
  }
}

///|
fn update_level_complete(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    // Go to next level or back to select
    if game.current_level + 1 < @types.total_levels {
      start_level(game, game.current_level + 1)
    } else {
      game.screen = LevelSelect
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}

///|
fn update_level_failed(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyR) {
    guard game.level_def is Some(def) else { return }
    game.level_state = Some(@types.init_level_state(def))
    game.screen = Playing
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}
