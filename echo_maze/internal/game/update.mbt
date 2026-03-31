///|
/// Main update dispatch - called every frame
pub fn update(game : @types.Game) -> Unit {
  let dt = @types.minf(@raylib.get_frame_time(), 0.05)
  game.frame_count += 1
  // Update message timer
  if game.message_timer > 0.0 {
    game.message_timer -= dt
    if game.message_timer <= 0.0 {
      game.message = ""
    }
  }
  match game.screen {
    Title => process_title_input(game)
    WorldSelect => process_world_select_input(game)
    LevelSelect => process_level_select_input(game)
    Playing => update_playing(game, dt)
    Planning => update_planning(game)
    Results => process_results_input(game)
    Paused => process_pause_input(game)
  }
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  // Check pause
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.screen = Paused
    return
  }
  // Tick timer
  game.tick_timer += dt
  if game.tick_timer < @types.tick_interval {
    return
  }
  game.tick_timer -= @types.tick_interval
  // Get player input direction
  let move_dir = get_move_input()
  // Check for time loop controls
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    // Finish current loop, enter planning
    @time.enter_planning(game)
    return
  }
  // Check for restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    @time.reset_level(game)
    @types.set_message(game, "Level Reset", 1.0)
    return
  }
  // Run simulation tick
  if game.tick < game.max_ticks && game.play_state is Recording {
    let result = @time.advance_tick(game, move_dir)
    match result {
      Completed(_) => @time.complete_current_level(game)
      Failed => {
        @types.set_message(game, "Caught! Press R to retry", 2.0)
        game.play_state = Failed
      }
      Continue(_) => ()
    }
    // Check tick limit
    if game.tick >= game.max_ticks {
      @types.set_message(game, "Time's up! Press SPACE for new loop", 2.0)
      @time.enter_planning(game)
    }
  }
  // Handle failed state
  if game.play_state is Failed {
    if @raylib.is_key_pressed(@raylib.KeyR) {
      @time.reset_level(game)
    }
  }
}

///|
fn update_planning(game : @types.Game) -> Unit {
  // In planning mode, player reviews and decides next action
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Paused
    return
  }
  // Start new loop
  if @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    @time.start_new_loop(game)
    game.screen = Playing
    return
  }
  // Undo last ghost
  if @raylib.is_key_pressed(@raylib.KeyU) {
    if @time.undo_loop(game) {
      @types.set_message(game, "Ghost removed", 1.0)
    } else {
      @types.set_message(game, "No ghosts to undo", 1.0)
    }
  }
  // Full reset
  if @raylib.is_key_pressed(@raylib.KeyR) {
    @time.reset_level(game)
    game.screen = Playing
    @types.set_message(game, "Level Reset", 1.0)
  }
  // Quit to level select
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    game.screen = LevelSelect
  }
  // Scrub timeline with left/right
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.planning_tick = @types.mini(
      game.planning_tick + 1,
      game.timeline.length() - 1,
    )
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.planning_tick = @types.maxi(game.planning_tick - 1, 0)
  }
}

///|
fn get_move_input() -> @types.Direction? {
  if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
    return Some(North)
  }
  if @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown) {
    return Some(South)
  }
  if @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft) {
    return Some(West)
  }
  if @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight) {
    return Some(East)
  }
  None
}

///|
fn process_title_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = WorldSelect
    game.selected_world = 0
  }
}

///|
fn process_world_select_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyUp) || @raylib.is_key_pressed(@raylib.KeyW) {
    game.selected_world -= 1
    if game.selected_world < 0 {
      game.selected_world = @types.num_worlds - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) || @raylib.is_key_pressed(@raylib.KeyS) {
    game.selected_world += 1
    if game.selected_world >= @types.num_worlds {
      game.selected_world = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if @types.is_world_unlocked(game, game.selected_world) {
      game.current_world = game.selected_world
      game.selected_level = 0
      game.screen = LevelSelect
    } else {
      @types.set_message(game, "Need 6 stars to unlock!", 1.5)
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  }
}

///|
fn process_level_select_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyUp) || @raylib.is_key_pressed(@raylib.KeyW) {
    game.selected_level -= 1
    if game.selected_level < 0 {
      game.selected_level = @types.levels_per_world - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) || @raylib.is_key_pressed(@raylib.KeyS) {
    game.selected_level += 1
    if game.selected_level >= @types.levels_per_world {
      game.selected_level = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if @types.is_level_unlocked(game, game.current_world, game.selected_level) {
      let _ = @time.load_level(game, game.current_world, game.selected_level)
      game.screen = Playing
    } else {
      @types.set_message(game, "Complete previous level first!", 1.5)
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = WorldSelect
  }
}

///|
fn process_pause_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    match game.play_state {
      Reviewing => game.screen = Planning
      _ => game.screen = Playing
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    game.screen = LevelSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    @time.reset_level(game)
    game.screen = Playing
    @types.set_message(game, "Level Reset", 1.0)
  }
}

///|
fn process_results_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = LevelSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    // Replay level
    let _ = @time.load_level(game, game.current_world, game.current_level)
    game.screen = Playing
  }
}
