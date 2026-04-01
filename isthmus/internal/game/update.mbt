///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count += 1
  game.anim_timer += @raylib.get_frame_time()
  // Update message timer
  if game.message_timer > 0.0 {
    game.message_timer -= @raylib.get_frame_time()
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
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyOne + 0) {
    game.selected_tier = Shores
    game.screen = LevelSelect
  } else if @raylib.is_key_pressed(@raylib.KeyOne + 1) {
    if is_tier_unlocked(game, Straits) {
      game.selected_tier = Straits
      game.screen = LevelSelect
    }
  } else if @raylib.is_key_pressed(@raylib.KeyOne + 2) {
    if is_tier_unlocked(game, Archipelago) {
      game.selected_tier = Archipelago
      game.screen = LevelSelect
    }
  }
}

///|
fn is_tier_unlocked(game : @types.Game, tier : @types.Tier) -> Bool {
  match tier {
    Shores => true
    Straits => {
      let mut completed = 0
      let start = @types.tier_start_level(Shores)
      let count = @types.tier_level_count(Shores)
      for i in start..<(start + count) {
        if game.level_scores[i].completed {
          completed += 1
        }
      }
      completed >= 4
    }
    Archipelago => {
      let mut completed = 0
      let start = @types.tier_start_level(Straits)
      let count = @types.tier_level_count(Straits)
      for i in start..<(start + count) {
        if game.level_scores[i].completed {
          completed += 1
        }
      }
      completed >= 4
    }
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
    return
  }
  let start = @types.tier_start_level(game.selected_tier)
  let count = @types.tier_level_count(game.selected_tier)
  // Number keys 1-9, 0 for 10
  for i in 0..<@types.mini(count, 10) {
    if @raylib.is_key_pressed(@raylib.KeyOne + i) {
      let level_idx = start + i
      start_level(game, level_idx)
      return
    }
  }
}

///|
fn start_level(game : @types.Game, level_idx : Int) -> Unit {
  let level = @levels.get_level(level_idx)
  game.selected_level = level_idx
  game.grid = @types.grid_from_level(level)
  game.sea_level = 0
  game.max_sea_level = level.max_sea_level
  game.sand_remaining = level.sand_budget
  game.turn = 0
  game.play_state = Placing
  game.history = []
  game.never_disconnected = true
  game.rising_anim = 0.0
  game.screen = Playing
  // Save initial snapshot
  game.history.push(
    @types.snapshot_grid(game.grid, game.sea_level, game.sand_remaining),
  )
  // Check initial connectivity
  check_connectivity(game)
}

///|
fn check_connectivity(game : @types.Game) -> Unit {
  let connected = @terrain.all_settlements_connected(game.grid, game.sea_level)
  if !connected {
    game.never_disconnected = false
  }
}

///|
fn update_playing(game : @types.Game) -> Unit {
  // Handle escape
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  // Handle restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.selected_level)
    return
  }
  // If game is over, go to results on any non-R, non-ESC key
  if game.play_state == Won || game.play_state == Lost {
    game.screen = Results
    return
  }
  // Handle rising animation
  if game.play_state == Rising {
    game.rising_anim += @raylib.get_frame_time()
    if game.rising_anim >= 0.5 {
      // Complete the rise
      finish_sea_rise(game)
    }
    return
  }
  // Toggle flood preview
  if @raylib.is_key_pressed(@raylib.KeyF) {
    game.show_flood_preview = !game.show_flood_preview
  }
  // Handle undo
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    undo(game)
    return
  }
  // Handle end turn (space)
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    begin_sea_rise(game)
    return
  }
  // Update hover position
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  let gx = (mx - @types.grid_offset_x) / @types.cell_size
  let gy = (my - @types.grid_offset_y) / @types.cell_size
  if @types.grid_in_bounds(game.grid, gx, gy) {
    game.hover_x = gx
    game.hover_y = gy
  } else {
    game.hover_x = -1
    game.hover_y = -1
  }
  // Handle click to place sand
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    if game.hover_x >= 0 && game.hover_y >= 0 && game.sand_remaining > 0 {
      // Save snapshot before placing
      let snap = @types.snapshot_grid(
        game.grid,
        game.sea_level,
        game.sand_remaining,
      )
      let placed = @terrain.place_sand(
        game.grid,
        game.hover_x,
        game.hover_y,
        game.sea_level,
      )
      if placed {
        game.sand_remaining -= 1
        game.history.push(snap)
        check_connectivity(game)
        @types.set_message(game, "Sand placed!", 0.8)
      } else {
        @types.set_message(game, "Cannot place here", 0.8)
      }
    } else if game.sand_remaining <= 0 {
      @types.set_message(game, "No sand remaining!", 0.8)
    }
  }
}

///|
fn begin_sea_rise(game : @types.Game) -> Unit {
  if game.sea_level >= game.max_sea_level {
    // Final check - game ends
    finalize_game(game)
    return
  }
  // Save snapshot before sea rise
  game.history.push(
    @types.snapshot_grid(game.grid, game.sea_level, game.sand_remaining),
  )
  game.play_state = Rising
  game.rising_anim = 0.0
  game.turn += 1
}

///|
fn finish_sea_rise(game : @types.Game) -> Unit {
  game.sea_level += 1
  game.play_state = Placing
  // Check if any settlement is flooded
  if @terrain.any_settlement_flooded(game.grid, game.sea_level) {
    game.play_state = Lost
    @types.set_message(game, "A settlement was flooded!", 2.0)
    return
  }
  // Check connectivity
  check_connectivity(game)
  // Check if we've reached max sea level
  if game.sea_level >= game.max_sea_level {
    finalize_game(game)
    return
  }
  // Warn about settlements that will flood next
  if @terrain.will_settlement_flood_next(game.grid, game.sea_level) {
    @types.set_message(game, "Warning: Settlement in danger!", 1.5)
  }
}

///|
fn finalize_game(game : @types.Game) -> Unit {
  let all_connected = @terrain.all_settlements_connected(
    game.grid,
    game.sea_level,
  )
  let no_flooded = !@terrain.any_settlement_flooded(game.grid, game.sea_level)
  if all_connected && no_flooded {
    game.play_state = Won
    // Update score
    let stars = compute_stars(game)
    let score = game.level_scores[game.selected_level]
    score.completed = true
    if stars > score.stars {
      score.stars = stars
    }
    @types.set_message(game, "Victory!", 2.0)
  } else {
    game.play_state = Lost
    if !no_flooded {
      @types.set_message(game, "Settlement flooded!", 2.0)
    } else {
      @types.set_message(game, "Settlements not connected!", 2.0)
    }
  }
}

///|
fn compute_stars(game : @types.Game) -> Int {
  let level = @levels.get_level(game.selected_level)
  let mut stars = 1
  if game.sand_remaining >= level.par_sand {
    stars = 2
  }
  if game.never_disconnected && game.sand_remaining >= level.par_sand {
    stars = 3
  }
  stars
}

///|
fn undo(game : @types.Game) -> Unit {
  if game.history.length() <= 1 {
    @types.set_message(game, "Nothing to undo", 0.8)
    return
  }
  let snap = game.history.pop()
  match snap {
    Some(s) => {
      @types.restore_snapshot(game.grid, s)
      game.sea_level = s.sea_level
      game.sand_remaining = s.sand_remaining
      game.play_state = Placing
      check_connectivity(game)
      @types.set_message(game, "Undone", 0.6)
    }
    None => ()
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.selected_level)
  }
}
