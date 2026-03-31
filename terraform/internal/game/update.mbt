///|
pub fn update(game : @types.Game) -> Unit {
  let dt : Float = 1.0 / 60.0
  game.frame_count += 1
  game.anim_timer = game.anim_timer + dt
  // Message timer
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
  }
  match game.screen {
    Title => update_title(game)
    TierSelect => update_tier_select(game)
    LevelSelect => update_level_select(game)
    Playing => update_playing(game, dt)
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
fn update_results(game : @types.Game) -> Unit {
  match game.play_state {
    Complete => update_complete(game)
    Failed => update_failed(game)
    _ => game.screen = Playing
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  } else if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.current_tier = Seeds
    game.screen = LevelSelect
  } else if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.current_tier = Balance
    game.screen = LevelSelect
  } else if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.current_tier = Harmony
    game.screen = LevelSelect
  }
  // Mouse click on tier cards
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let card_w = 300
    let card_h = 350
    let card_gap = 40
    let total_w = card_w * 3 + card_gap * 2
    let start_x = (@types.screen_width - total_w) / 2
    let card_y = 140
    // Check each card
    if my >= card_y && my <= card_y + card_h {
      if mx >= start_x && mx <= start_x + card_w {
        game.current_tier = Seeds
        game.screen = LevelSelect
      } else if mx >= start_x + card_w + card_gap && mx <= start_x + card_w *
        2 + card_gap {
        game.current_tier = Balance
        game.screen = LevelSelect
      } else if mx >= start_x + (card_w + card_gap) * 2 && mx <= start_x +
        card_w * 3 + card_gap * 2 {
        game.current_tier = Harmony
        game.screen = LevelSelect
      }
    }
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
    return
  }
  let (start_idx, end_idx) = @types.tier_level_range(game.current_tier)
  let count = end_idx - start_idx
  // Number keys 1-9 select levels
  let keys = [
    @raylib.KeyOne, @raylib.KeyTwo, @raylib.KeyThree, @raylib.KeyFour,
    @raylib.KeyFive, @raylib.KeySix, @raylib.KeySeven, @raylib.KeyEight,
    @raylib.KeyNine,
  ]
  for i in 0..<@types.mini(count, keys.length()) {
    if @raylib.is_key_pressed(keys[i]) {
      let level_idx = start_idx + i
      start_level(game, level_idx)
      return
    }
  }
  // Mouse click on level cards
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let cols = @types.mini(5, count)
    let cell_w = 160
    let cell_h = 120
    let gap = 20
    let total_grid_w = cols * cell_w + (cols - 1) * gap
    let base_x = (@types.screen_width - total_grid_w) / 2
    let base_y = 100
    for i in 0..<count {
      let col = i % cols
      let row = i / cols
      let x = base_x + col * (cell_w + gap)
      let y = base_y + row * (cell_h + gap)
      if mx >= x && mx <= x + cell_w && my >= y && my <= y + cell_h {
        let level_idx = start_idx + i
        start_level(game, level_idx)
        return
      }
    }
  }
}

///|
fn start_level(game : @types.Game, level_idx : Int) -> Unit {
  let level = @levels.get_level(level_idx)
  game.current_level = level_idx
  game.current_tier = level.tier
  game.grid = @levels.init_grid_from_level(level)
  game.budget = @types.new_budget(
    level.budget.forest, level.budget.ocean, level.budget.desert,
  )
  game.targets = level.targets
  game.par_turns = level.par_turns
  game.current_turn = 0
  game.play_state = Painting
  game.hover_col = -1
  game.hover_row = -1
  game.undo_stack = []
  game.resolve_timer = 0.0
  game.resolve_step = 0
  game.prev_snapshot = []
  game.changed_tiles = []
  game.screen = Playing
  game.message = @types.level_name(level_idx)
  game.message_timer = 2.0
  // Auto-select first available biome
  auto_select_biome(game)
}

///|
fn auto_select_biome(game : @types.Game) -> Unit {
  // Select the first biome with remaining paint
  if game.budget.forest > 0 {
    game.selected_biome = Forest
  } else if game.budget.ocean > 0 {
    game.selected_biome = Ocean
  } else if game.budget.desert > 0 {
    game.selected_biome = Desert
  } else {
    game.selected_biome = Forest
  }
}

///|
fn cycle_biome_forward(game : @types.Game) -> Unit {
  let order : Array[@types.BiomeKind] = [Forest, Ocean, Desert]
  let mut idx = 0
  for i in 0..<order.length() {
    if order[i] == game.selected_biome {
      idx = i
    }
  }
  // Try next biomes in order, skip if no budget
  for _attempt in 0..<3 {
    idx = (idx + 1) % order.length()
    if @types.budget_remaining(game.budget, order[idx]) > 0 {
      game.selected_biome = order[idx]
      return
    }
  }
  // No budget for anything - keep current
}

///|
fn cycle_biome_backward(game : @types.Game) -> Unit {
  let order : Array[@types.BiomeKind] = [Forest, Ocean, Desert]
  let mut idx = 0
  for i in 0..<order.length() {
    if order[i] == game.selected_biome {
      idx = i
    }
  }
  for _attempt in 0..<3 {
    idx = (idx + order.length() - 1) % order.length()
    if @types.budget_remaining(game.budget, order[idx]) > 0 {
      game.selected_biome = order[idx]
      return
    }
  }
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  match game.play_state {
    Painting => update_painting(game)
    Resolving => update_resolving(game, dt)
    Complete => update_complete(game)
    Failed => update_failed(game)
  }
}

///|
fn update_painting(game : @types.Game) -> Unit {
  // Biome selection via number keys
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    if game.budget.forest > 0 {
      game.selected_biome = Forest
    } else {
      game.message = "No Forest paint remaining!"
      game.message_timer = 1.0
    }
  } else if @raylib.is_key_pressed(@raylib.KeyTwo) {
    if game.budget.ocean > 0 {
      game.selected_biome = Ocean
    } else {
      game.message = "No Ocean paint remaining!"
      game.message_timer = 1.0
    }
  } else if @raylib.is_key_pressed(@raylib.KeyThree) {
    if game.budget.desert > 0 {
      game.selected_biome = Desert
    } else {
      game.message = "No Desert paint remaining!"
      game.message_timer = 1.0
    }
  }
  // Tab to cycle biomes
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    if @raylib.is_key_down(@raylib.KeyLeftShift) || @raylib.is_key_down(
      @raylib.KeyRightShift,
    ) {
      cycle_biome_backward(game)
    } else {
      cycle_biome_forward(game)
    }
  }
  // Scroll wheel to cycle biomes
  let wheel = @raylib.get_mouse_wheel_move()
  if wheel > 0.0 {
    cycle_biome_forward(game)
  } else if wheel < 0.0 {
    cycle_biome_backward(game)
  }
  // Hover tracking
  let mx = Float::from_int(@raylib.get_mouse_x())
  let my = Float::from_int(@raylib.get_mouse_y())
  let (hc, hr) = @types.pixel_to_hex(mx, my, game.grid.width, game.grid.height)
  game.hover_col = hc
  game.hover_row = hr
  // Left click to paint
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    try_paint(game, hc, hr)
  }
  // Right click to cycle biome and paint in one action
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
    cycle_biome_forward(game)
  }
  // Enter to manually resolve (without painting)
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    if game.current_turn > 0 {
      begin_resolve(game)
    } else {
      game.message = "Paint a tile first!"
      game.message_timer = 1.0
    }
  }
  // Undo
  if @raylib.is_key_pressed(@raylib.KeyU) {
    undo_last(game)
  }
  // Restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level)
  }
  // Back to levels
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}

///|
fn try_paint(game : @types.Game, col : Int, row : Int) -> Unit {
  if col < 0 || row < 0 || col >= game.grid.width || row >= game.grid.height {
    return
  }
  let tile = @types.get_tile(game.grid, col, row)
  // Cannot paint locked tiles
  if tile.locked {
    game.message = "This tile is locked!"
    game.message_timer = 1.0
    return
  }
  // Cannot paint non-barren tiles
  if tile.biome != Barren {
    game.message = "Can only paint Barren tiles"
    game.message_timer = 1.0
    return
  }
  let biome = game.selected_biome
  // Check budget
  if @types.budget_remaining(game.budget, biome) <= 0 {
    game.message = "No " + @types.biome_name(biome) + " paint remaining!"
    game.message_timer = 1.5
    // Try to auto-switch to a biome with budget
    auto_select_biome(game)
    return
  }
  // Save undo entry
  game.undo_stack.push(
    { col, row, prev_biome: tile.biome, biome_used: biome },
  )
  // Apply paint
  @types.set_biome(game.grid, col, row, biome)
  @types.deduct_budget(game.budget, biome)
  game.current_turn += 1
  // Auto-switch if current biome depleted
  if @types.budget_remaining(game.budget, game.selected_biome) <= 0 {
    auto_select_biome(game)
  }
  // Auto-resolve after painting
  begin_resolve(game)
}

///|
fn begin_resolve(game : @types.Game) -> Unit {
  game.play_state = Resolving
  game.resolve_timer = 0.0
  game.resolve_step = 0
  game.prev_snapshot = @types.snapshot_biomes(game.grid)
}

///|
fn update_resolving(game : @types.Game, dt : Float) -> Unit {
  game.resolve_timer = game.resolve_timer + dt
  if game.resolve_timer >= @types.resolve_delay {
    game.resolve_timer = 0.0
    game.resolve_step += 1
    // Apply one ecosystem step
    game.changed_tiles = @biome.resolve_ecosystem(game.grid)
    // Check if anything changed
    let mut any_change = false
    for i in 0..<game.changed_tiles.length() {
      if game.changed_tiles[i] {
        any_change = true
        break
      }
    }
    if !any_change || game.resolve_step >= @types.resolve_steps {
      // Resolution complete
      finish_resolve(game)
    }
  }
}

///|
fn finish_resolve(game : @types.Game) -> Unit {
  // Count how many tiles changed this resolution
  let mut changes = 0
  for i in 0..<game.changed_tiles.length() {
    if game.changed_tiles[i] {
      changes += 1
    }
  }
  if changes > 0 {
    game.message = changes.to_string() + " tile" + (if changes > 1 {
      "s"
    } else {
      ""
    }) + " changed"
    game.message_timer = 1.0
  }
  // Check win condition
  if @biome.check_targets(game.grid, game.targets) {
    // Win!
    let stars = @biome.calculate_stars(
      game.grid, game.targets, game.budget, game.current_turn, game.par_turns,
    )
    let score = game.level_scores[game.current_level]
    if stars > score.stars {
      score.stars = stars
    }
    score.completed = true
    if game.current_turn < score.best_turns {
      score.best_turns = game.current_turn
    }
    game.play_state = Complete
    game.screen = Results
    game.message = "Target ratios achieved!"
    game.message_timer = 3.0
  } else if @biome.check_failure(game.grid, game.budget, game.targets) {
    game.play_state = Failed
    game.screen = Results
    game.message = "No more moves possible"
    game.message_timer = 3.0
  } else {
    game.play_state = Painting
    // Keep changed_tiles for one frame of visual feedback, then clear
    // (they'll be cleared on next paint action)
  }
}

///|
fn undo_last(game : @types.Game) -> Unit {
  if game.undo_stack.length() == 0 {
    game.message = "Nothing to undo"
    game.message_timer = 0.8
    return
  }
  let entry = game.undo_stack.pop()
  match entry {
    Some(e) => {
      // Revert the grid
      @types.set_biome(game.grid, e.col, e.row, e.prev_biome)
      @types.add_budget(game.budget, e.biome_used)
      game.current_turn -= 1
      // We also need to revert any ecosystem changes from the resolve
      // that happened after this paint. For simplicity, we revert
      // the grid to the state before the last resolve by re-applying
      // the previous snapshot if available.
      if game.prev_snapshot.length() > 0 {
        // Restore from previous snapshot
        for i in 0..<game.prev_snapshot.length() {
          if !game.grid.tiles[i].locked {
            // Only revert tiles that weren't the undo target
            let col = i % game.grid.width
            let row = i / game.grid.width
            if col != e.col || row != e.row {
              game.grid.tiles[i].biome = game.prev_snapshot[i]
            }
          }
        }
      }
      game.changed_tiles = []
      game.message = "Undid " + @types.biome_name(e.biome_used) + " paint"
      game.message_timer = 1.0
    }
    None => ()
  }
}

///|
fn update_complete(game : @types.Game) -> Unit {
  // Enter -> next level
  if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(
    @raylib.KeySpace,
  ) {
    let next = game.current_level + 1
    if next < @types.total_levels {
      start_level(game, next)
    } else {
      game.message = "All levels complete!"
      game.message_timer = 3.0
      game.screen = TierSelect
    }
  }
  // N -> next level (alternative)
  if @raylib.is_key_pressed(@raylib.KeyN) {
    let next = game.current_level + 1
    if next < @types.total_levels {
      start_level(game, next)
    }
  }
  // R -> retry
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level)
  }
  // Esc -> back to level select
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}

///|
fn update_failed(game : @types.Game) -> Unit {
  // R -> retry
  if @raylib.is_key_pressed(@raylib.KeyR) || @raylib.is_key_pressed(
    @raylib.KeyEnter,
  ) || @raylib.is_key_pressed(@raylib.KeySpace) {
    start_level(game, game.current_level)
  }
  // Esc -> back to level select
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}
