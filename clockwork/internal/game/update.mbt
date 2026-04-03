///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  let dt_raw = @raylib.get_frame_time()
  let dt = @types.minf(dt_raw, 0.05)
  // Update message timer
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
  }
  match game.screen {
    Title => update_title(game)
    LevelSelect => update_level_select(game)
    Playing => update_playing(game, dt)
    Paused => update_paused(game)
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
  // Navigate tiers with left/right
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    if game.tier_scroll < 2 {
      game.tier_scroll = game.tier_scroll + 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    if game.tier_scroll > 0 {
      game.tier_scroll = game.tier_scroll - 1
    }
  }
  // Check for level selection via number keys or mouse
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let tier : @types.Tier = match game.tier_scroll {
      0 => Ticks
      1 => Timing
      _ => Clockwork
    }
    if @levels.tier_unlocked(game, tier) {
      let (start, end) = @levels.levels_in_tier(tier)
      for i = start; i < end; i = i + 1 {
        let idx = i - start
        let bx = 200 + idx % 4 * 220
        let by = 280 + idx / 4 * 120
        if mx >= bx && mx < bx + 200 && my >= by && my < by + 100 {
          @levels.load_level(game, i)
          game.screen = Playing
          return
        }
      }
    }
  }
  // Back to title with Escape
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  }
  // Quick level select with number keys
  let tier : @types.Tier = match game.tier_scroll {
    0 => Ticks
    1 => Timing
    _ => Clockwork
  }
  if @levels.tier_unlocked(game, tier) {
    let (start, end) = @levels.levels_in_tier(tier)
    let count = end - start
    for i in 0..<count {
      if @raylib.is_key_pressed(@raylib.KeyOne + i) {
        @levels.load_level(game, start + i)
        game.screen = Playing
        return
      }
    }
  }
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Paused
    return
  }
  match game.sim.state {
    Idle => update_placing(game)
    Running => {
      @gears.update_simulation(game, dt)
      // Speed controls
      if @raylib.is_key_pressed(@raylib.KeyUp) {
        game.sim.speed_mult = @types.minf(game.sim.speed_mult * 2.0, 8.0)
      }
      if @raylib.is_key_pressed(@raylib.KeyDown) {
        game.sim.speed_mult = @types.maxf(game.sim.speed_mult * 0.5, 0.25)
      }
      if @raylib.is_key_pressed(@raylib.KeyR) {
        stop_simulation(game)
      }
      if game.sim.state == Complete {
        let stars = @gears.calculate_stars(game)
        let prev = game.level_stars[game.current_level]
        if stars > prev {
          game.level_stars[game.current_level] = stars
        }
        game.screen = LevelComplete
      }
      if game.sim.state == Failed {
        game.screen = LevelFailed
      }
    }
    Paused =>
      if @raylib.is_key_pressed(@raylib.KeySpace) {
        game.sim.state = Running
      }
    Complete => ()
    Failed => ()
  }
}

///|
fn update_placing(game : @types.Game) -> Unit {
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  game.hover_col = @types.mouse_to_grid_col(mx)
  game.hover_row = @types.mouse_to_grid_row(my)
  // Check toolbar area for palette selection
  let toolbar_y = @types.grid_offset_y +
    @types.grid_rows * @types.cell_size +
    20
  let palette = game.level_def.palette
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    // Check palette buttons
    for i in 0..<palette.available.length() {
      let bx = @types.grid_offset_x + i * 80
      let by = toolbar_y
      if mx >= bx && mx < bx + 70 && my >= by && my < by + 60 {
        if palette.counts[i] > 0 {
          game.selected_palette = i
        }
        return
      }
    }
    // Check grid placement
    if game.selected_palette >= 0 &&
      @types.grid_valid(game.hover_col, game.hover_row) {
      let cell = @types.grid_get(game, game.hover_col, game.hover_row)
      if cell == -1 && palette.counts[game.selected_palette] > 0 {
        place_component(game, game.hover_col, game.hover_row)
      }
    }
  }
  // Right click to remove placed component
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
    if @types.grid_valid(game.hover_col, game.hover_row) {
      let cell = @types.grid_get(game, game.hover_col, game.hover_row)
      if cell >= 0 && cell < game.components.length() {
        let comp = game.components[cell]
        if !comp.fixed {
          remove_component(game, cell)
        }
      }
    }
  }
  // Start simulation with Enter or Space
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    start_simulation(game)
  }
  // Reset level with R
  if @raylib.is_key_pressed(@raylib.KeyR) {
    @levels.load_level(game, game.current_level)
  }
  // Deselect with D or clicking same palette item again
  if @raylib.is_key_pressed(@raylib.KeyD) {
    game.selected_palette = -1
  }
}

///|
fn place_component(game : @types.Game, col : Int, row : Int) -> Unit {
  let palette = game.level_def.palette
  let pal_idx = game.selected_palette
  if pal_idx < 0 || pal_idx >= palette.available.length() {
    return
  }
  if palette.counts[pal_idx] <= 0 {
    return
  }
  let kind = palette.available[pal_idx]
  let comp = @types.new_component(kind, col, row)
  let idx = game.components.length()
  game.components.push(comp)
  @types.grid_set(game, col, row, idx)
  palette.counts[pal_idx] = palette.counts[pal_idx] - 1
  if palette.counts[pal_idx] <= 0 {
    game.selected_palette = -1
  }
}

///|
fn remove_component(game : @types.Game, idx : Int) -> Unit {
  let comp = game.components[idx]
  if comp.fixed {
    return
  }
  // Return to palette
  let palette = game.level_def.palette
  for i in 0..<palette.available.length() {
    if palette.available[i] == comp.kind {
      palette.counts[i] = palette.counts[i] + 1
      break
    }
  }
  // Clear from grid
  @types.grid_set(game, comp.col, comp.row, -1)
  comp.active = false
}

///|
fn start_simulation(game : @types.Game) -> Unit {
  @gears.init_simulation(game)
}

///|
fn stop_simulation(game : @types.Game) -> Unit {
  @types.reset_simulation(game.sim)
  // Reset component states
  for i in 0..<game.components.length() {
    let c = game.components[i]
    c.rotation = 0.0
    c.cam_offset = 0.0
    c.spring_released = false
    c.spring_energy = 0.0
    c.escapement_phase = 0.0
    c.escapement_locked = false
    c.bell_rung = false
    c.bell_ring_timer = 0.0
  }
}

///|
fn update_paused(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.screen = Playing
  }
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    game.screen = LevelSelect
    @types.reset_simulation(game.sim)
  }
}

///|
fn update_level_complete(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    // Go to next level or back to select
    if game.current_level < @types.total_levels - 1 {
      @levels.load_level(game, game.current_level + 1)
      game.screen = Playing
    } else {
      game.screen = LevelSelect
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    @levels.load_level(game, game.current_level)
    game.screen = Playing
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}

///|
fn update_level_failed(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeyR) {
    @levels.load_level(game, game.current_level)
    game.screen = Playing
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}
