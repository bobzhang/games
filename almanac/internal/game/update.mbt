///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count += 1
  let dt = @types.minf(@raylib.get_frame_time(), 0.05)
  // Update message timer
  if game.message_timer > 0.0 {
    game.message_timer -= dt
  }
  // Update animation timer
  game.anim_timer += dt
  match game.screen {
    Title => update_title(game)
    TierSelect => update_tier_select(game)
    LevelSelect => update_level_select(game)
    Playing => update_playing(game)
    Results => update_results(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = TierSelect
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.current_tier = match game.current_tier {
      Spring => Monsoon
      Summer => Spring
      Monsoon => Summer
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.current_tier = match game.current_tier {
      Spring => Summer
      Summer => Monsoon
      Monsoon => Spring
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.current_tier = Spring
    enter_level_select(game)
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.current_tier = Summer
    enter_level_select(game)
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.current_tier = Monsoon
    enter_level_select(game)
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    enter_level_select(game)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  }
}

///|
fn enter_level_select(game : @types.Game) -> Unit {
  let (start, _end) = @levels.tier_levels(game.current_tier)
  game.current_level = start
  game.screen = LevelSelect
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  let (start, end) = @levels.tier_levels(game.current_tier)
  let count = end - start
  let cols = 4
  let idx = game.current_level - start
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    let new_idx = (idx + 1) % count
    game.current_level = start + new_idx
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    let new_idx = (idx - 1 + count) % count
    game.current_level = start + new_idx
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    let new_idx = @types.mini(idx + cols, count - 1)
    game.current_level = start + new_idx
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    let new_idx = @types.maxi(idx - cols, 0)
    game.current_level = start + new_idx
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    start_level(game, game.current_level)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
  }
}

///|
fn start_level(game : @types.Game, level_idx : Int) -> Unit {
  let level = @levels.get_level(level_idx)
  game.current_level = level_idx
  game.grid = @types.make_grid(
    level.grid_width,
    level.grid_height,
    level.heights,
    level.targets,
  )
  game.placed_sources = []
  // Copy source budget
  let budget : Array[(@types.SourceKind, Int)] = []
  for i in 0..<level.source_budget.length() {
    let (k, c) = level.source_budget[i]
    budget.push((k, c))
  }
  game.available_sources = budget
  game.selected_source = 0
  game.wind_dir = East
  game.turn_count = 0
  game.play_state = Placing
  game.cursor_col = level.grid_width / 2
  game.cursor_row = level.grid_height / 2
  game.history = []
  game.stable = false
  game.prev_weather = []
  game.anim_timer = 0.0
  game.screen = Playing
  @types.set_message(game, level.name, 2.0)
}

///|
fn update_playing(game : @types.Game) -> Unit {
  // ESC to go back
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  // R to restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level)
    return
  }
  match game.play_state {
    Placing => update_placing(game)
    Simulating => update_simulating(game)
    Won => {
      // Auto transition to results
      game.screen = Results
      let level = @levels.get_level(game.current_level)
      let stars = @weather.calculate_stars(
        true,
        game.placed_sources.length(),
        game.turn_count,
        level.par_sources,
        level.par_turns,
      )
      let score = game.level_scores[game.current_level]
      score.completed = true
      score.sources_used = game.placed_sources.length()
      score.turns_taken = game.turn_count
      if stars > score.stars {
        score.stars = stars
      }
    }
    Failed =>
      if @raylib.is_key_pressed(@raylib.KeySpace) ||
        @raylib.is_key_pressed(@raylib.KeyEnter) {
        // Allow re-simulating or restart
        game.play_state = Placing
        // Reset weather to initial state
        @types.clear_weather(game.grid)
        game.turn_count = 0
        game.prev_weather = []
        game.stable = false
      }
  }
}

///|
fn update_placing(game : @types.Game) -> Unit {
  let g = game.grid
  // Cursor movement via arrow keys
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.cursor_col = @types.mini(game.cursor_col + 1, g.width - 1)
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.cursor_col = @types.maxi(game.cursor_col - 1, 0)
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.cursor_row = @types.mini(game.cursor_row + 1, g.height - 1)
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.cursor_row = @types.maxi(game.cursor_row - 1, 0)
  }
  // Mouse cursor
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  let mc = (mx - ox) / cs
  let mr = (my - oy) / cs
  if mc >= 0 && mc < g.width && mr >= 0 && mr < g.height {
    game.cursor_col = mc
    game.cursor_row = mr
  }
  // Source selection via number keys
  if @raylib.is_key_pressed(@raylib.KeyOne) &&
    game.available_sources.length() > 0 {
    game.selected_source = 0
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) &&
    game.available_sources.length() > 1 {
    game.selected_source = 1
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) &&
    game.available_sources.length() > 2 {
    game.selected_source = 2
  }
  // Wind direction toggle
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    game.wind_dir = match game.wind_dir {
      North => West
      West => South
      South => East
      East => North
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyE) {
    game.wind_dir = match game.wind_dir {
      North => East
      East => South
      South => West
      West => North
    }
  }
  // Place source via Enter or left mouse button
  let place = @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
  if place &&
    game.available_sources.length() > 0 &&
    game.selected_source < game.available_sources.length() {
    let (kind, count) = game.available_sources[game.selected_source]
    if count > 0 {
      // Check not already occupied by a source
      let mut occupied = false
      for i in 0..<game.placed_sources.length() {
        let s = game.placed_sources[i]
        if s.col == game.cursor_col && s.row == game.cursor_row {
          occupied = true
        }
      }
      if !occupied {
        // Save history for undo
        let hist_tiles = @types.clone_weather(game.grid)
        let hist_sources : Array[@types.Source] = []
        for i in 0..<game.placed_sources.length() {
          hist_sources.push(game.placed_sources[i])
        }
        game.history.push({ tiles: hist_tiles, sources: hist_sources, })
        // Place the source
        let src : @types.Source = {
          kind,
          col: game.cursor_col,
          row: game.cursor_row,
          wind_dir: game.wind_dir,
        }
        game.placed_sources.push(src)
        // Decrement count
        game.available_sources[game.selected_source] = (kind, count - 1)
        // If count is now 0, try to select next available
        if count - 1 == 0 {
          let mut found = false
          for i in 0..<game.available_sources.length() {
            let (_k, c) = game.available_sources[i]
            if c > 0 {
              game.selected_source = i
              found = true
              break
            }
          }
          if !found {
            // All sources placed
          }
        }
      } else {
        @types.set_message(game, "Tile already has a source!", 1.5)
      }
    } else {
      @types.set_message(game, "No more of this source!", 1.5)
    }
  }
  // Z to undo last source placement
  if @raylib.is_key_pressed(@raylib.KeyZ) && game.history.length() > 0 {
    let entry = game.history.unsafe_pop()
    // Restore weather
    @types.restore_weather(game.grid, entry.tiles)
    // Restore sources
    // Figure out what was removed
    let removed_count = game.placed_sources.length() - entry.sources.length()
    if removed_count > 0 {
      let removed = game.placed_sources[game.placed_sources.length() - 1]
      // Add the source back to budget
      for i in 0..<game.available_sources.length() {
        let (k, c) = game.available_sources[i]
        if k == removed.kind {
          game.available_sources[i] = (k, c + 1)
        }
      }
    }
    game.placed_sources = entry.sources
    game.turn_count = 0
    game.prev_weather = []
    game.stable = false
    @types.set_message(game, "Undo", 0.8)
  }
  // Space to simulate one turn
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.placed_sources.length() > 0 {
      game.play_state = Simulating
      // Reset weather before first simulation
      if game.turn_count == 0 {
        @types.clear_weather(game.grid)
      }
    } else {
      @types.set_message(game, "Place at least one source first!", 1.5)
    }
  }
}

///|
fn update_simulating(game : @types.Game) -> Unit {
  // Save previous state for stability check
  game.prev_weather = @types.clone_weather(game.grid)
  // Run one turn of simulation
  @weather.simulate_turn(game.grid, game.placed_sources)
  game.turn_count += 1
  // Check targets
  let targets_met = @weather.check_targets(game.grid)
  let stable = @weather.check_stable(game.grid, game.prev_weather)
  game.stable = stable
  if targets_met {
    game.play_state = Won
    @types.set_message(game, "All targets met!", 2.0)
  } else if stable {
    // Weather stabilized but targets not met
    game.play_state = Failed
    @types.set_message(
      game, "Weather stabilized - targets not met. Space to retry, R to restart.",
      3.0,
    )
  } else {
    // Continue - go back to placing state, press Space again for next turn
    game.play_state = Placing
    let (met, total) = @weather.count_targets_met(game.grid)
    @types.set_message(
      game,
      "Turn " +
      game.turn_count.to_string() +
      " - Targets: " +
      met.to_string() +
      "/" +
      total.to_string(),
      1.5,
    )
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level)
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    // Next level
    let next = game.current_level + 1
    if next < @types.total_levels {
      start_level(game, next)
    } else {
      game.screen = TierSelect
    }
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}
