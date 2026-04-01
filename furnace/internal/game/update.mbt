///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  let dt = @types.minf(@raylib.get_frame_time(), 0.05)
  // Update message timer
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
  }
  match game.screen {
    Title => update_title(game)
    LevelSelect => update_level_select(game)
    Playing => update_playing(game, dt)
    Simulating => update_simulating(game, dt)
    LevelComplete => update_level_complete(game)
    LevelFailed => update_level_failed(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = LevelSelect
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  // Click on level buttons
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let cols = 5
    let btn_w = 180
    let btn_h = 80
    let gap = 15
    let w = @types.screen_width
    let start_x = (w - cols * (btn_w + gap)) / 2
    let start_y = 90
    for i in 0..<@types.total_levels {
      let col = i % cols
      let row = i / cols
      let x = start_x + col * (btn_w + gap)
      let y = start_y + row * (btn_h + gap)
      if mx >= x && mx < x + btn_w && my >= y && my < y + btn_h {
        if @types.is_level_unlocked(game, i) {
          @levels.load_level(game, i)
          game.screen = Playing
          return
        }
      }
    }
  }
}

///|
fn update_playing(game : @types.Game, _dt : Float) -> Unit {
  // ESC to level select
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  // Update hover position
  update_hover(game)
  // Tool selection hotkeys
  handle_tool_selection(game)
  // Place/erase with mouse click
  handle_tile_placement(game)
  // Start simulation with SPACE
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    start_simulation(game)
    return
  }
  // Reset with R
  if @raylib.is_key_pressed(@raylib.KeyR) {
    reset_current_level(game)
  }
  // Simulate button click
  handle_button_clicks(game)
}

///|
fn update_simulating(game : @types.Game, dt : Float) -> Unit {
  // ESC to stop simulation
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    stop_simulation(game)
    return
  }
  // SPACE to stop simulation
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    stop_simulation(game)
    return
  }
  // Advance simulation
  game.sim_timer = game.sim_timer + dt
  if game.sim_timer >= @types.sim_speed {
    game.sim_timer = game.sim_timer - @types.sim_speed
    @heat.simulate_step(game.grid)
    game.sim_turn = game.sim_turn + 1
    // Check if all targets are met
    if @types.check_all_targets(game.grid) {
      finish_level_success(game)
      return
    }
    // Check if stable (no more heat flow)
    let threshold : Float = 0.5
    if @heat.is_stable(game.grid, threshold) {
      // Simulation stabilized
      if @types.check_all_targets(game.grid) {
        finish_level_success(game)
      } else {
        finish_level_failure(game)
      }
      return
    }
    // Check if max turns exceeded
    if game.sim_turn >= @types.max_sim_turns {
      if @types.check_all_targets(game.grid) {
        finish_level_success(game)
      } else {
        finish_level_failure(game)
      }
      return
    }
  }
  // Handle button clicks during simulation
  handle_button_clicks(game)
}

///|
fn update_level_complete(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    // Go to next level
    if game.current_level < @types.total_levels - 1 {
      @levels.load_level(game, game.current_level + 1)
      game.screen = Playing
    } else {
      game.screen = LevelSelect
    }
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}

///|
fn update_level_failed(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyR) {
    reset_current_level(game)
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}

///|
fn update_hover(game : @types.Game) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let ox = @types.grid_offset_x
  let oy = @types.grid_offset_y
  let cs = @types.cell_size
  let col = (mx - ox) / cs
  let row = (my - oy) / cs
  if col >= 0 && col < @types.grid_size && row >= 0 && row < @types.grid_size {
    game.hover_row = row
    game.hover_col = col
  } else {
    game.hover_row = -1
    game.hover_col = -1
  }
}

///|
fn handle_tool_selection(game : @types.Game) -> Unit {
  let level = @levels.get_level(game.current_level)
  // Number keys 1-5 for materials
  for i = 0; i < level.available_materials.length(); i = i + 1 {
    if @raylib.is_key_pressed(@raylib.KeyOne + i) {
      game.tool_mode = Place(level.available_materials[i])
      return
    }
  }
  // E for eraser
  if @raylib.is_key_pressed(@raylib.KeyE) {
    game.tool_mode = Erase
  }
}

///|
fn handle_tile_placement(game : @types.Game) -> Unit {
  if !@raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) &&
    !@raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
    return
  }
  let r = game.hover_row
  let c = game.hover_col
  if r < 0 || c < 0 || r >= @types.grid_size || c >= @types.grid_size {
    return
  }
  let tile = game.grid.tiles[r][c]
  if tile.locked {
    return
  }
  match game.tool_mode {
    Place(mat) =>
      if tile.material != mat {
        tile.material = mat
        tile.temperature = @types.ambient_temp
      }
    Erase =>
      if tile.material != Empty {
        tile.material = Empty
        tile.temperature = @types.ambient_temp
      }
  }
}

///|
fn handle_button_clicks(game : @types.Game) -> Unit {
  if !@raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    return
  }
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let level = @levels.get_level(game.current_level)
  let tx = @types.toolbar_x
  let ty = @types.toolbar_y
  let eraser_y = ty + 80 + level.available_materials.length() * 50
  let stats_y = eraser_y + 55
  let btn_y = stats_y + 70
  // Simulate/Stop button
  if mx >= tx && mx < tx + 120 && my >= btn_y && my < btn_y + 35 {
    if game.sim_running {
      stop_simulation(game)
    } else {
      start_simulation(game)
    }
    return
  }
  // Reset button
  if mx >= tx + 130 && mx < tx + 250 && my >= btn_y && my < btn_y + 35 {
    reset_current_level(game)
    return
  }
  // Material palette clicks
  for i = 0; i < level.available_materials.length(); i = i + 1 {
    let mat_y = ty + 80 + i * 50
    if mx >= tx && mx < tx + 160 && my >= mat_y && my < mat_y + 36 {
      game.tool_mode = Place(level.available_materials[i])
      return
    }
  }
  // Eraser click
  if mx >= tx && mx < tx + 160 && my >= eraser_y && my < eraser_y + 36 {
    game.tool_mode = Erase
  }
}

///|
fn start_simulation(game : @types.Game) -> Unit {
  // Reset temperatures before simulation
  @types.reset_temperatures(game.grid)
  // Re-set heat sources to their temperatures
  for r in 0..<@types.grid_size {
    for c in 0..<@types.grid_size {
      match game.grid.tiles[r][c].kind {
        HeatSource(heat) => game.grid.tiles[r][c].temperature = heat
        _ => ()
      }
    }
  }
  game.sim_turn = 0
  game.sim_timer = 0.0
  game.sim_running = true
  game.screen = Simulating
  @types.set_message(game, "Simulation running...", 2.0)
}

///|
fn stop_simulation(game : @types.Game) -> Unit {
  game.sim_running = false
  game.screen = Playing
  @types.set_message(game, "Simulation stopped", 1.0)
}

///|
fn reset_current_level(game : @types.Game) -> Unit {
  @levels.load_level(game, game.current_level)
  game.screen = Playing
  @types.set_message(game, "Level reset", 1.0)
}

///|
fn finish_level_success(game : @types.Game) -> Unit {
  game.sim_running = false
  let level = @levels.get_level(game.current_level)
  let materials_used = @types.count_placed_materials(game.grid)
  let turns = game.sim_turn
  let stars = @types.calculate_stars(
    true,
    materials_used,
    turns,
    level.par_materials,
    level.par_turns,
  )
  game.result.all_targets_met = true
  game.result.materials_used = materials_used
  game.result.turns_taken = turns
  game.result.stars = stars
  // Update progress
  let progress = game.level_progress[game.current_level]
  progress.completed = true
  if @types.star_count(stars) > @types.star_count(progress.best_stars) {
    progress.best_stars = stars
  }
  @types.recalculate_total_stars(game)
  game.screen = LevelComplete
}

///|
fn finish_level_failure(game : @types.Game) -> Unit {
  game.sim_running = false
  game.result.all_targets_met = false
  game.result.materials_used = @types.count_placed_materials(game.grid)
  game.result.turns_taken = game.sim_turn
  game.result.stars = Zero
  game.screen = LevelFailed
}
