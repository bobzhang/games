///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count = game.frame_count + 1
  let dt_raw = @raylib.get_frame_time()
  let dt = @types.minf(dt_raw, 0.05)
  game.anim_timer = game.anim_timer + dt
  // Tick message timer
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
fn update_tier_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let tiers : Array[@types.Tier] = [Detection, Precision, Crisis]
    for i in 0..<tiers.length() {
      let bx = 340
      let by = 150 + i * 160
      let bw = 600
      let bh = 130
      if mx >= bx && mx < bx + bw && my >= by && my < by + bh {
        let tier = tiers[i]
        if @types.tier_unlocked(game, tier) {
          game.current_tier = tier
          game.screen = LevelSelect
        }
        break
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
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    let mx = @raylib.get_mouse_x()
    let my = @raylib.get_mouse_y()
    let tier = game.current_tier
    let start = @types.tier_start_index(tier)
    let count = @types.tier_level_count(tier)
    let cols = 5
    let bw = 200
    let bh = 100
    let margin = 20
    let start_x = (1280 - (cols * bw + (cols - 1) * margin)) / 2
    let start_y = 100
    for i in 0..<count {
      let idx = start + i
      let col = i % cols
      let row = i / cols
      let bx = start_x + col * (bw + margin)
      let by = start_y + row * (bh + margin)
      if mx >= bx && mx < bx + bw && my >= by && my < by + bh {
        if @types.level_unlocked(game, idx) {
          start_level(game, idx)
        }
        break
      }
    }
  }
}

///|
fn start_level(game : @types.Game, index : Int) -> Unit {
  let level = @levels.get_level(index)
  game.level = Some(level)
  game.current_level_index = index
  game.screen = Playing
  game.play_state = Placing
  game.sensors = []
  game.readings = []
  game.selected_sensor = Broad
  game.selected_direction = North
  game.budget_used = 0
  game.guess_pos = None
  game.guess_count = 0
  game.sensor_place_count = 0
  game.hover_tile = None
  game.message = ""
  game.message_timer = 0.0
  game.show_overlap = true
  // Reset epicenter found state
  for i in 0..<level.epicenters.length() {
    level.epicenters[i].found = false
  }
  // Seed rng based on level index and frame count
  @types.seed_rng(index * 997 + game.frame_count)
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  let _ = dt
  // Escape: back to level select
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  // R: restart level
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level_index)
    return
  }
  // If level complete or failed, enter goes to results
  if game.play_state == Complete || game.play_state == Failed {
    if @raylib.is_key_pressed(@raylib.KeyEnter) ||
      @raylib.is_key_pressed(@raylib.KeySpace) {
      game.screen = Results
    }
    return
  }
  // Tab: toggle placing/guessing mode
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    if game.play_state == Placing {
      game.play_state = Guessing
      set_message(game, "Guessing mode", 1.5)
    } else if game.play_state == Guessing {
      game.play_state = Placing
      set_message(game, "Placing mode", 1.5)
    }
  }
  // 1/2/3: select sensor type
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.selected_sensor = Broad
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    let tier = match game.level {
      Some(l) => l.tier
      None => Detection
    }
    if tier != Detection {
      game.selected_sensor = Precise
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    let tier = match game.level {
      Some(l) => l.tier
      None => Detection
    }
    if tier != Detection {
      game.selected_sensor = Directional
    }
  }
  // Arrow keys: change direction (for directional sensor)
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.selected_direction = North
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.selected_direction = East
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.selected_direction = South
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.selected_direction = West
  }
  // Z: undo last sensor
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    if game.play_state == Placing {
      if @sensors.remove_last_sensor(game) {
        set_message(game, "Sensor removed", 1.0)
      }
    }
  }
  // O: toggle overlap display
  if @raylib.is_key_pressed(@raylib.KeyO) {
    game.show_overlap = !game.show_overlap
  }
  // Update hover tile from mouse position
  let mx = @raylib.get_mouse_x()
  let my = @raylib.get_mouse_y()
  game.hover_tile = @types.pixel_to_tile(mx, my)
  // Mouse click: place sensor or make guess
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
    match game.hover_tile {
      None => ()
      Some(tile) =>
        if game.play_state == Placing {
          handle_place_click(game, tile)
        } else if game.play_state == Guessing {
          handle_guess_click(game, tile)
        }
    }
  }
}

///|
fn handle_place_click(game : @types.Game, tile : @types.Vec2i) -> Unit {
  if @sensors.can_place_sensor(game, tile) {
    let placed = @sensors.place_sensor(game, tile)
    if placed {
      let kind_name = match game.selected_sensor {
        Broad => "Broad"
        Precise => "Precise"
        Directional => "Directional"
      }
      set_message(game, kind_name + " sensor placed", 1.0)
    }
  } else {
    set_message(game, "Cannot place here", 1.0)
  }
}

///|
fn handle_guess_click(game : @types.Game, tile : @types.Vec2i) -> Unit {
  match game.level {
    None => ()
    Some(level) => {
      game.guess_pos = Some(tile)
      game.guess_count = game.guess_count + 1
      let found_idx = @sensors.check_all_epicenters(
        tile,
        level.epicenters,
        @types.guess_tolerance,
      )
      if found_idx >= 0 {
        level.epicenters[found_idx].found = true
        // Recompute readings without found epicenters
        @sensors.recompute_readings(game)
        if @sensors.all_epicenters_found(level.epicenters) {
          // Level complete
          game.play_state = Complete
          compute_score(game, level)
          set_message(game, "All epicenters found!", 3.0)
        } else {
          let remaining = count_remaining(level)
          set_message(
            game,
            "Found! " + remaining.to_string() + " remaining",
            2.0,
          )
        }
      } else {
        set_message(game, "Miss! Try again", 1.5)
      }
    }
  }
}

///|
fn count_remaining(level : @types.Level) -> Int {
  let mut remaining = 0
  for i in 0..<level.epicenters.length() {
    if !level.epicenters[i].found {
      remaining = remaining + 1
    }
  }
  remaining
}

///|
fn compute_score(game : @types.Game, level : @types.Level) -> Unit {
  let idx = level.level_index
  let score = game.level_scores[idx]
  let mut stars = 1 // Star 1: completed
  if game.budget_used <= level.par_budget {
    stars = 2 // Star 2: within par budget
  }
  if game.budget_used <= level.par_budget &&
    game.guess_count <= level.par_guesses {
    stars = 3 // Star 3: par budget + par guesses
  }
  score.completed = true
  if stars > score.stars {
    score.stars = stars
  }
  if game.budget_used < score.best_budget_used {
    score.best_budget_used = game.budget_used
  }
  if game.guess_count < score.best_guesses {
    score.best_guesses = game.guess_count
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  // R: retry
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_level(game, game.current_level_index)
    return
  }
  // Escape: back to level select
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  // Enter: next level (or back to level select if last)
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    let next_idx = game.current_level_index + 1
    if next_idx < @types.total_levels && @types.level_unlocked(game, next_idx) {
      start_level(game, next_idx)
    } else {
      game.screen = LevelSelect
    }
  }
}

///|
fn set_message(game : @types.Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}
