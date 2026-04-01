///|
pub fn update(game : @types.Game) -> Unit {
  let dt = @raylib.get_frame_time()
  game.frame_count += 1
  game.anim_timer += dt
  game.signal_phase += dt * @types.pulse_speed
  if game.message_timer > 0.0 {
    game.message_timer -= dt
    if game.message_timer < 0.0 {
      game.message_timer = 0.0
      game.message = ""
    }
  }
  match game.screen {
    Title => update_title(game)
    LevelSelect => update_level_select(game)
    Playing => update_playing(game)
    Won => update_won(game)
    Failed => update_failed(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    game.screen = LevelSelect
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  // Scroll
  if @raylib.is_key_pressed(@raylib.KeyUp) && game.scroll_offset > 0 {
    game.scroll_offset -= 1
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) && game.scroll_offset < 2 {
    game.scroll_offset += 1
  }
  // Mouse wheel scroll
  let wheel = @raylib.get_mouse_wheel_move()
  if wheel > 0.0 && game.scroll_offset > 0 {
    game.scroll_offset -= 1
  }
  if wheel < 0.0 && game.scroll_offset < 2 {
    game.scroll_offset += 1
  }
  // Click to select level
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let clicked = detect_level_click(game, mx, my)
    if clicked >= 0 {
      start_level(game, clicked)
    }
  }
}

///|
fn detect_level_click(game : @types.Game, mx : Int, my : Int) -> Int {
  let start_y = 120 - game.scroll_offset * 200
  let mut cy = start_y
  for tier in 1..=3 {
    cy += 40
    let count = @levels.tier_level_count(tier)
    let start = @levels.tier_start_index(tier)
    let cols = 5
    for i in 0..<count {
      let col = i % cols
      let row = i / cols
      let bx = 80 + col * 180
      let by = cy + row * 70
      if mx >= bx && mx <= bx + 160 && my >= by && my <= by + 55 {
        return start + i
      }
    }
    let rows_used = (count + cols - 1) / cols
    cy += rows_used * 70 + 20
  }
  -1
}

///|
fn start_level(game : @types.Game, index : Int) -> Unit {
  let data = @levels.get_level(index)
  let state = @types.new_level_state(data)
  game.current_level = index
  game.level_data = Some(data)
  game.level_state = Some(state)
  game.screen = Playing
  // Run initial signal propagation
  let (all_lit, chain, paths) = @signal.propagate(state, data)
  state.all_receivers_lit = all_lit
  state.relay_chain_length = chain
  state.signal_paths = paths
}

///|
fn update_playing(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  match (game.level_data, game.level_state) {
    (Some(data), Some(state)) => {
      // Update cursor position from mouse
      let mx = @raylib.get_mouse_x()
      let my = @raylib.get_mouse_y()
      let col = @types.screen_to_grid_col(mx)
      let row = @types.screen_to_grid_row(my)
      state.cursor_col = col
      state.cursor_row = row
      state.hover_valid = can_place_tower(state, col, row)
      // Place tower on click
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        if state.hover_valid {
          place_tower(game, data, state, col, row)
        }
      }
      // Remove tower on right click
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
        if @types.in_grid(col, row) && state.grid[row][col].kind == Tower {
          remove_tower(game, data, state, col, row)
        }
      }
      // Reset level
      if @raylib.is_key_pressed(@raylib.KeyR) {
        reset_level(game, data)
      }
      // Animate signal paths
      for i in 0..<state.signal_paths.length() {
        let p = state.signal_paths[i]
        if p.active && p.progress < 1.0 {
          p.progress += @raylib.get_frame_time() * @types.signal_travel_speed
          if p.progress > 1.0 {
            p.progress = 1.0
          }
        }
      }
      // Animate signal on lit tiles
      for r in 0..<@types.grid_rows {
        for c in 0..<@types.grid_cols {
          let tile = state.grid[r][c]
          if tile.has_signal {
            tile.signal_anim += @raylib.get_frame_time() * @types.anim_speed
            if tile.signal_anim > 1.0 {
              tile.signal_anim = 1.0
            }
          } else {
            tile.signal_anim = 0.0
          }
        }
      }
    }
    _ => ()
  }
}

///|
fn can_place_tower(state : @types.LevelState, col : Int, row : Int) -> Bool {
  if !@types.in_grid(col, row) {
    return false
  }
  if state.towers_placed >= state.budget {
    return false
  }
  state.grid[row][col].kind == Empty
}

///|
fn place_tower(
  game : @types.Game,
  data : @types.LevelData,
  state : @types.LevelState,
  col : Int,
  row : Int
) -> Unit {
  state.grid[row][col].kind = Tower
  state.towers_placed += 1
  // Re-propagate signal
  let (all_lit, chain, paths) = @signal.propagate(state, data)
  state.all_receivers_lit = all_lit
  state.relay_chain_length = chain
  state.signal_paths = paths
  if all_lit {
    // Level completed!
    let stars = @signal.compute_stars(
      state.towers_placed, chain, data.par_towers, data.par_chain,
    )
    let prog = game.progress[game.current_level]
    prog.completed = true
    if @types.star_count(stars) > @types.star_count(prog.stars) {
      prog.stars = stars
    }
    if state.towers_placed < prog.best_towers {
      prog.best_towers = state.towers_placed
    }
    if chain < prog.best_chain {
      prog.best_chain = chain
    }
    game.screen = Won
  }
}

///|
fn remove_tower(
  _game : @types.Game,
  data : @types.LevelData,
  state : @types.LevelState,
  col : Int,
  row : Int
) -> Unit {
  state.grid[row][col].kind = Empty
  state.towers_placed -= 1
  let (all_lit, chain, paths) = @signal.propagate(state, data)
  state.all_receivers_lit = all_lit
  state.relay_chain_length = chain
  state.signal_paths = paths
}

///|
fn reset_level(game : @types.Game, data : @types.LevelData) -> Unit {
  let state = @types.new_level_state(data)
  game.level_state = Some(state)
  let (all_lit, chain, paths) = @signal.propagate(state, data)
  state.all_receivers_lit = all_lit
  state.relay_chain_length = chain
  state.signal_paths = paths
}

///|
fn update_won(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    // Go to next level or back to select
    if game.current_level < @types.total_levels - 1 {
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
fn update_failed(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyR) {
    match game.level_data {
      Some(data) => reset_level(game, data)
      _ => ()
    }
    game.screen = Playing
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}
