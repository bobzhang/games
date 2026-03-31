///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count += 1
  let dt : Float = @raylib.get_frame_time()
  game.anim_timer += dt
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
  if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(
    @raylib.KeySpace,
  ) {
    game.screen = TierSelect
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.selected_tier = match game.selected_tier {
      Coil => DoubleHelix
      Twist => Coil
      DoubleHelix => Twist
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.selected_tier = match game.selected_tier {
      Coil => Twist
      Twist => DoubleHelix
      DoubleHelix => Coil
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(
    @raylib.KeySpace,
  ) {
    game.selected_level = 0
    game.screen = LevelSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  let count = @types.tier_level_count(game.selected_tier)
  let cols = 4
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.selected_level = (game.selected_level + 1) % count
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.selected_level = (game.selected_level - 1 + count) % count
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    let next = game.selected_level + cols
    if next < count {
      game.selected_level = next
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    let prev = game.selected_level - cols
    if prev >= 0 {
      game.selected_level = prev
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(
    @raylib.KeySpace,
  ) {
    let level_idx = @types.tier_start_index(game.selected_tier) +
      game.selected_level
    start_level(game, level_idx)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
  }
}

///|
fn start_level(game : @types.Game, level_idx : Int) -> Unit {
  let level = @levels.get_level(level_idx)
  game.current_level = Some(level)
  game.cw_pos = 0
  game.ccw_pos = 0
  game.steps = 0
  game.play_state = Moving
  game.history = []
  game.pickups_count = 0
  game.message = ""
  game.message_timer = 0.0
  // Initialize pickup tracking
  let total_cells = level.cw_spiral.cells.length() +
    level.ccw_spiral.cells.length()
  let pc : Array[Bool] = Array::new(capacity=total_cells)
  for _i in 0..<total_cells {
    pc.push(false)
  }
  game.pickups_collected = pc
  // Initialize oneshot tracking
  let link_count = level.switch_links.length()
  let ou : Array[Bool] = Array::new(capacity=link_count)
  for _i in 0..<link_count {
    ou.push(false)
  }
  game.oneshot_used = ou
  game.screen = Playing
}

///|
fn update_playing(game : @types.Game) -> Unit {
  // Step forward
  if game.play_state == Moving {
    if @raylib.is_key_pressed(@raylib.KeySpace) || @raylib.is_key_pressed(
      @raylib.KeyEnter,
    ) {
      @spiral.step(game)
      // Check if blocked after step
      if game.play_state != Won && @spiral.check_blocked(game) {
        game.play_state = Blocked
        game.message = "Both tokens are blocked!"
        game.message_timer = 2.0
      }
    }
  }
  // Undo
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    if game.history.length() > 0 {
      @types.restore_history(game)
      game.message = "Undone"
      game.message_timer = 0.5
    }
  }
  // Restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    let level_idx = @types.tier_start_index(game.selected_tier) +
      game.selected_level
    start_level(game, level_idx)
  }
  // Back to level select
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
  // Go to results on win
  if game.play_state == Won {
    if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(
      @raylib.KeySpace,
    ) {
      // Save score
      let level_idx = @types.tier_start_index(game.selected_tier) +
        game.selected_level
      let level = match game.current_level {
        None => return
        Some(l) => l
      }
      let stars = @types.calculate_stars(
        game.steps,
        level.par_steps,
        game.pickups_count,
        level.pickups_total,
      )
      let score = game.level_scores[level_idx]
      if !score.completed || game.steps < score.steps {
        score.steps = game.steps
      }
      if !score.completed || stars > score.stars {
        score.stars = stars
      }
      if !score.completed || game.pickups_count > score.pickups {
        score.pickups = game.pickups_count
      }
      score.completed = true
      game.screen = Results
    }
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(
    @raylib.KeySpace,
  ) {
    // Next level
    let count = @types.tier_level_count(game.selected_tier)
    if game.selected_level + 1 < count {
      game.selected_level += 1
      let level_idx = @types.tier_start_index(game.selected_tier) +
        game.selected_level
      start_level(game, level_idx)
    } else {
      game.screen = TierSelect
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    let level_idx = @types.tier_start_index(game.selected_tier) +
      game.selected_level
    start_level(game, level_idx)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}
