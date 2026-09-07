///|
/// Main update entry point.
pub fn update(game : @types.Game) -> Unit {
  let dt = @raylib.get_frame_time()
  game.anim_timer += dt
  game.frame_count += 1
  if game.message_timer > 0.0 {
    game.message_timer -= dt
  }
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
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = TierSelect
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  }
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.current_tier = Tier1
    game.screen = LevelSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.current_tier = Tier2
    game.screen = LevelSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.current_tier = Tier3
    game.screen = LevelSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = LevelSelect
  }
  // Arrow keys to cycle tiers
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.current_tier = match game.current_tier {
      Tier1 => Tier3
      Tier2 => Tier1
      Tier3 => Tier2
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyRight) {
    game.current_tier = match game.current_tier {
      Tier1 => Tier2
      Tier2 => Tier3
      Tier3 => Tier1
    }
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
  }
  let tier_lvls = @types.tier_levels(game.levels, game.current_tier)
  // Number keys 1-7 for level selection
  let key_offsets : Array[(Int, Int)] = [
    (@raylib.KeyOne, 0),
    (@raylib.KeyTwo, 1),
    (@raylib.KeyThree, 2),
    (@raylib.KeyFour, 3),
    (@raylib.KeyFive, 4),
    (@raylib.KeySix, 5),
    (@raylib.KeySeven, 6),
  ]
  for entry in key_offsets {
    let key = entry.0
    let idx = entry.1
    if @raylib.is_key_pressed(key) && idx < tier_lvls.length() {
      game.current_level = tier_lvls[idx]
      start_level(game)
      return
    }
  }
  // Mouse click on level boxes
  if @raylib.is_mouse_button_pressed(0) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    for i, lvl_idx in tier_lvls {
      let row = i / 4
      let col = i % 4
      let bx = 80 + col * 290
      let by = 140 + row * 130
      let bw = 260
      let bh = 110
      if mx >= bx && mx < bx + bw && my >= by && my < by + bh {
        game.current_level = lvl_idx
        start_level(game)
        return
      }
    }
  }
}

///|
fn start_level(game : @types.Game) -> Unit {
  @types.init_grid(game)
  game.screen = Playing
  game.message = ""
  game.message_timer = 0.0
}

///|
fn update_playing(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  // Update hover cell
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  game.hover_cell = @types.screen_to_grid(mx, my)
  match game.play_state {
    Placing => update_placing(game)
    Simulating => update_simulating(game)
    Complete => update_complete(game)
    Failed => update_failed(game)
  }
}

///|
fn update_placing(game : @types.Game) -> Unit {
  // Tool selection
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.selected_tool = Aqueduct
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.selected_tool = Reservoir
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.selected_tool = Dam
  }
  // Place / remove on click
  if @raylib.is_mouse_button_pressed(0) {
    guard game.hover_cell is Some(pos) else { () }
    handle_click(game, pos)
  }
  // Undo
  if @raylib.is_key_pressed(@raylib.KeyU) {
    undo_last(game)
  }
  // Clear all placed tiles
  if @raylib.is_key_pressed(@raylib.KeyC) {
    clear_placed(game)
  }
  // Run simulation
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    @water.reset_water(game)
    game.play_state = Simulating
    game.sim_timer = 0.0
    game.sim_step = 0
  }
  // Reset water
  if @raylib.is_key_pressed(@raylib.KeyR) {
    @water.reset_water(game)
    show_message(game, "Water reset", 1.5)
  }
}

///|
fn handle_click(game : @types.Game, pos : @types.Pos) -> Unit {
  let level = game.levels[game.current_level]
  guard @types.in_bounds(pos, level.grid_cols, level.grid_rows) else { return }
  let idx = @types.pos_to_index(pos, level.grid_cols)
  let tile = game.grid[idx]
  if tile.kind is Empty {
    // Place new tile
    let undo : @types.UndoEntry = {
      pos,
      prev_kind: tile.kind,
      prev_connections: tile.connections.copy(),
    }
    game.undo_stack.push(undo)
    tile.kind = game.selected_tool
    tile.connections = @types.all_directions.copy()
    game.segments_placed += 1
  } else if tile.kind is Aqueduct || tile.kind is Reservoir || tile.kind is Dam {
    // Check if it's a player-placed tile (not a level-defined one)
    let is_level_defined = is_level_defined_tile(game, pos)
    if !is_level_defined {
      // Remove player-placed tile
      let undo : @types.UndoEntry = {
        pos,
        prev_kind: tile.kind,
        prev_connections: tile.connections.copy(),
      }
      game.undo_stack.push(undo)
      tile.kind = Empty
      tile.connections = []
      game.segments_placed -= 1
    }
  }
}

///|
fn is_level_defined_tile(game : @types.Game, pos : @types.Pos) -> Bool {
  let level = game.levels[game.current_level]
  for s in level.springs {
    if s == pos {
      return true
    }
  }
  for f in level.fountains {
    if f == pos {
      return true
    }
  }
  for r in level.reservoirs {
    if r == pos {
      return true
    }
  }
  for entry in level.dams {
    if entry.0 == pos {
      return true
    }
  }
  false
}

///|
fn undo_last(game : @types.Game) -> Unit {
  guard game.undo_stack.length() > 0 else { return }
  let entry = game.undo_stack.pop()
  guard entry is Some(undo) else { return }
  let level = game.levels[game.current_level]
  let idx = @types.pos_to_index(undo.pos, level.grid_cols)
  let tile = game.grid[idx]
  // If current tile is player-placed, decrement count
  if tile.kind is Aqueduct || tile.kind is Reservoir || tile.kind is Dam {
    if !is_level_defined_tile(game, undo.pos) {
      game.segments_placed -= 1
    }
  }
  tile.kind = undo.prev_kind
  tile.connections = undo.prev_connections
  // If restoring a player-placed tile, increment count
  if tile.kind is Aqueduct || tile.kind is Reservoir || tile.kind is Dam {
    if !is_level_defined_tile(game, undo.pos) {
      game.segments_placed += 1
    }
  }
  show_message(game, "Undone", 0.8)
}

///|
fn clear_placed(game : @types.Game) -> Unit {
  let level = game.levels[game.current_level]
  let cols = level.grid_cols
  let rows = level.grid_rows
  for y in 0..<rows {
    for x in 0..<cols {
      let pos : @types.Pos = { x, y, }
      if !is_level_defined_tile(game, pos) {
        let idx = @types.pos_to_index(pos, cols)
        let tile = game.grid[idx]
        if !(tile.kind is Empty) &&
          !(tile.kind is Spring) &&
          !(tile.kind is Fountain) {
          tile.kind = Empty
          tile.connections = []
        }
      }
    }
  }
  game.segments_placed = 0
  game.undo_stack = []
  @water.reset_water(game)
  show_message(game, "All cleared", 1.5)
}

///|
fn update_simulating(game : @types.Game) -> Unit {
  let dt = @raylib.get_frame_time()
  game.sim_timer += dt
  if game.sim_timer >= @types.sim_tick_interval {
    game.sim_timer -= @types.sim_tick_interval
    let changed = @water.sim_step(game)
    game.sim_step += 1
    if !changed || game.sim_step > 80 {
      // Simulation done
      finish_simulation(game)
    }
  }
  // Allow canceling simulation
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    finish_simulation(game)
  }
}

///|
fn finish_simulation(game : @types.Game) -> Unit {
  // Count filled fountains
  let level = game.levels[game.current_level]
  let mut filled = 0
  for f in level.fountains {
    let idx = @types.pos_to_index(f, level.grid_cols)
    if game.grid[idx].has_water {
      filled += 1
    }
  }
  game.fountains_filled = filled
  game.total_fountains = level.fountains.length()
  if filled == level.fountains.length() {
    game.play_state = Complete
    let stars = @water.calculate_stars(game)
    let segments = @types.count_segments(game)
    game.scores[game.current_level] = {
      completed: true,
      stars,
      segments_used: segments,
    }
    show_message(game, "All fountains flowing!", 2.0)
  } else {
    game.play_state = Failed
    show_message(game, "Some fountains are dry...", 2.0)
  }
}

///|
fn update_complete(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = Results
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    @water.reset_water(game)
    game.play_state = Placing
  }
}

///|
fn update_failed(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyR) {
    @water.reset_water(game)
    game.play_state = Placing
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game)
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    // Go to next level
    let tier_lvls = @types.tier_levels(game.levels, game.current_tier)
    let mut current_idx = -1
    for i, lvl_idx in tier_lvls {
      if lvl_idx == game.current_level {
        current_idx = i
        break
      }
    }
    if current_idx >= 0 && current_idx + 1 < tier_lvls.length() {
      game.current_level = tier_lvls[current_idx + 1]
      start_level(game)
    } else {
      game.screen = LevelSelect
    }
  }
}

///|
fn show_message(game : @types.Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}
