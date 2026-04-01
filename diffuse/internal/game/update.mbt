///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
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
  if @raylib.is_mouse_button_pressed(0) {
    let cx = @types.screen_width / 2
    let btn_w = 200
    let btn_h = 50
    let btn_x = cx - btn_w / 2
    let btn_y = 380
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    if mx >= btn_x && mx <= btn_x + btn_w && my >= btn_y && my <= btn_y + btn_h {
      game.screen = TierSelect
    }
  }
  // Also allow Enter/Space to start
  if @raylib.is_key_pressed(257) || @raylib.is_key_pressed(32) {
    // 257 = Enter, 32 = Space
    game.screen = TierSelect
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  if @raylib.is_mouse_button_pressed(0) {
    let cx = @types.screen_width / 2
    let tiers : Array[@types.Tier] = [Watercolor, Pigment, Palette]
    for i in 0..<tiers.length() {
      let by = 160 + i * 140
      let bx = cx - 250
      let bw = 500
      let bh = 110
      let mx = @raylib.get_mouse_x()
      let my = @raylib.get_mouse_y()
      if mx >= bx && mx <= bx + bw && my >= by && my <= by + bh {
        game.selected_tier = tiers[i]
        game.screen = LevelSelect
        return
      }
    }
    // Back button
    if check_back_button() {
      game.screen = Title
    }
  }
  if @raylib.is_key_pressed(256) {
    // Escape
    game.screen = Title
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_mouse_button_pressed(0) {
    let cx = @types.screen_width / 2
    let tier = game.selected_tier
    let start = @types.tier_start_index(tier)
    let count = @types.tier_level_count(tier)
    let cols = 5
    let btn_size = 100
    let gap = 20
    let total_w = cols * btn_size + (cols - 1) * gap
    let sx = cx - total_w / 2
    let sy = 120
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    for i = 0; i < count; i = i + 1 {
      let col = i % cols
      let row = i / cols
      let bx = sx + col * (btn_size + gap)
      let by = sy + row * (btn_size + gap)
      if mx >= bx && mx <= bx + btn_size && my >= by && my <= by + btn_size {
        game.selected_level = start + i
        @levels.load_level_into_game(game, game.selected_level)
        game.screen = Playing
        return
      }
    }
    if check_back_button() {
      game.screen = TierSelect
    }
  }
  if @raylib.is_key_pressed(256) {
    game.screen = TierSelect
  }
}

///|
fn update_playing(game : @types.Game) -> Unit {
  // Update hover position
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  game.hover_col = (mx - @types.grid_offset_x) / @types.cell_size
  game.hover_row = (my - @types.grid_offset_y) / @types.cell_size
  // Handle win/fail overlay
  if game.play_state == Won || game.play_state == Failed {
    update_results_overlay(game)
    return
  }
  // Handle spread animation
  if game.play_state == Spreading {
    game.spread_timer = game.spread_timer - @raylib.get_frame_time()
    if game.spread_timer <= 0.0 {
      // Perform the spread
      let new_grid = @ink.spread_once(game.grid)
      game.grid = new_grid
      game.turn = game.turn + 1
      game.play_state = Placing
      // Check win/fail
      check_game_state(game)
    }
    return
  }
  // Ink channel selection via keyboard
  if @raylib.is_key_pressed(49) {
    // Key 1
    game.selected_channel = Cyan
  }
  if @raylib.is_key_pressed(50) {
    // Key 2
    game.selected_channel = Magenta
  }
  if @raylib.is_key_pressed(51) {
    // Key 3
    game.selected_channel = Yellow
  }
  // Ink channel selection via click on palette
  if @raylib.is_mouse_button_pressed(0) {
    let panel_x = @types.grid_offset_x + game.grid.width * @types.cell_size + 30
    let panel_w = @types.screen_width - panel_x - 20
    if mx >= panel_x && mx <= panel_x + panel_w {
      if my >= 145 && my < 185 {
        game.selected_channel = Cyan
      } else if my >= 195 && my < 235 {
        game.selected_channel = Magenta
      } else if my >= 245 && my < 285 {
        game.selected_channel = Yellow
      }
    }
  }
  // Drop ink on click
  if @raylib.is_mouse_button_pressed(0) {
    let col = game.hover_col
    let row = game.hover_row
    if @types.grid_in_bounds(game.grid, col, row) {
      let tile = @types.grid_get(game.grid, col, row)
      if tile.kind != Barrier {
        let remaining = @types.budget_get(game.budget, game.selected_channel)
        if remaining > 0 {
          // Save history for undo
          save_history(game)
          // Apply ink drop
          let new_ink = @types.ink_add_channel(tile.ink, game.selected_channel)
          tile.ink = { c: new_ink.c, m: new_ink.m, y: new_ink.y }
          @types.budget_use(game.budget, game.selected_channel)
          game.drops_used = game.drops_used + 1
          // Check game state after drop
          check_game_state(game)
        }
      }
    }
  }
  // Space to spread
  if @raylib.is_key_pressed(32) {
    // Space
    if @ink.has_any_ink(game.grid) {
      save_history(game)
      game.play_state = Spreading
      game.spread_timer = @types.spread_anim_time
    }
  }
  // Z to undo
  if @raylib.is_key_pressed(90) {
    // Z key
    undo(game)
  }
  // R to restart
  if @raylib.is_key_pressed(82) {
    // R key
    @levels.load_level_into_game(game, game.selected_level)
  }
  // Escape to go back
  if @raylib.is_key_pressed(256) {
    game.screen = LevelSelect
  }
  // P to toggle preview
  if @raylib.is_key_pressed(80) {
    game.show_preview = !game.show_preview
  }
}

///|
fn update_results_overlay(game : @types.Game) -> Unit {
  if @raylib.is_mouse_button_pressed(0) {
    let cx = @types.screen_width / 2
    let cy = @types.screen_height / 2
    let panel_h = 280
    let py = cy - panel_h / 2
    let btn_y = py + panel_h - 70
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    // Retry button
    let retry_x = cx - 180
    let retry_w = 150
    let retry_h = 40
    if mx >= retry_x &&
      mx <= retry_x + retry_w &&
      my >= btn_y &&
      my <= btn_y + retry_h {
      @levels.load_level_into_game(game, game.selected_level)
      return
    }
    // Next/Menu button
    let next_x = cx + 30
    let next_w = 150
    let next_h = 40
    if mx >= next_x &&
      mx <= next_x + next_w &&
      my >= btn_y &&
      my <= btn_y + next_h {
      if game.play_state == Won {
        // Go to next level
        if game.selected_level < @types.total_levels - 1 {
          game.selected_level = game.selected_level + 1
          @levels.load_level_into_game(game, game.selected_level)
        } else {
          game.screen = LevelSelect
        }
      } else {
        game.screen = LevelSelect
      }
      return
    }
  }
  // R to restart, Escape to menu
  if @raylib.is_key_pressed(82) {
    @levels.load_level_into_game(game, game.selected_level)
  }
  if @raylib.is_key_pressed(256) {
    game.screen = LevelSelect
  }
  // Enter/Space for next
  if @raylib.is_key_pressed(257) || @raylib.is_key_pressed(32) {
    if game.play_state == Won {
      if game.selected_level < @types.total_levels - 1 {
        game.selected_level = game.selected_level + 1
        @levels.load_level_into_game(game, game.selected_level)
      } else {
        game.screen = LevelSelect
      }
    } else {
      @levels.load_level_into_game(game, game.selected_level)
    }
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  // Back button or escape
  if @raylib.is_mouse_button_pressed(0) {
    if check_back_button() {
      game.screen = LevelSelect
    }
  }
  if @raylib.is_key_pressed(256) {
    game.screen = LevelSelect
  }
}

///|
fn check_game_state(game : @types.Game) -> Unit {
  // Check if all targets are satisfied
  if @ink.all_targets_satisfied(game.grid) {
    game.play_state = Won
    // Save score
    let stars = @ink.compute_stars(game.grid, game.drops_used, game.par_drops)
    let score = game.scores[game.selected_level]
    score.completed = true
    // Only upgrade stars, never downgrade
    if @types.star_count(stars) > @types.star_count(score.stars) {
      score.stars = stars
    }
    if game.drops_used < score.drops_used || score.drops_used == 0 {
      score.drops_used = game.drops_used
    }
    return
  }
  // Check for fail state: a target has ink channels it shouldn't
  if @ink.any_target_wrong_color(game.grid) {
    // Only fail if we can't fix it (no budget left for needed colors)
    // For simplicity, mark as failed if a target has unwanted channels
    game.play_state = Failed
    return
  }
}

///|
fn save_history(game : @types.Game) -> Unit {
  let entry : @types.HistoryEntry = {
    tiles: @types.clone_tiles(game.grid.tiles),
    budget: @types.clone_budget(game.budget),
    drops_used: game.drops_used,
  }
  game.history.push(entry)
}

///|
fn undo(game : @types.Game) -> Unit {
  if game.history.length() > 0 {
    let entry = game.history.unsafe_pop()
    game.grid = {
      width: game.grid.width,
      height: game.grid.height,
      tiles: entry.tiles,
    }
    game.budget = entry.budget
    game.drops_used = entry.drops_used
    game.play_state = Placing
  }
}

///|
fn check_back_button() -> Bool {
  let bx = 20
  let by = @types.screen_height - 60
  let bw = 100
  let bh = 40
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  mx >= bx && mx <= bx + bw && my >= by && my <= by + bh
}
