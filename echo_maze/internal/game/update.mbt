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
  // Update restart flash timer
  if game.restart_flash_timer > 0.0 {
    game.restart_flash_timer -= dt
  }
  // Update loop transition timer
  if game.loop_transition_timer > 0.0 {
    game.loop_transition_timer -= dt
  }
  // Update ghost button feedback timers
  let mut i = 0
  while i < game.ghost_button_feedback.length() {
    game.ghost_button_feedback[i].timer -= dt
    if game.ghost_button_feedback[i].timer <= 0.0 {
      let _ = game.ghost_button_feedback.remove(i)
    } else {
      i += 1
    }
  }
  // Update door animations
  match game.maze_state {
    Some(maze_state) => {
      @types.update_door_animations(maze_state, dt)
      // Update guard alert timers
      @simulation.update_guard_alert_timers(maze_state, dt)
    }
    None => ()
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
  // Check for restart (faster restart with flash feedback)
  if @raylib.is_key_pressed(@raylib.KeyR) {
    @time.reset_level(game)
    game.restart_flash_timer = 0.3
    @types.set_message(game, "Level Reset", 0.6)
    return
  }
  // Run simulation tick
  if game.tick < game.max_ticks && game.play_state is Recording {
    let result = @time.advance_tick(game, move_dir)
    // Detect ghost button presses for visual feedback
    match game.maze {
      Some(maze) => {
        let presses = @simulation.detect_ghost_button_presses(maze, game.ghosts)
        for press in presses {
          // Check if we already have feedback for this ghost+button combo
          let mut already_tracked = false
          for fb in game.ghost_button_feedback {
            if fb.ghost_index == press.0 && fb.button_id == press.1 {
              fb.timer = 0.8 // refresh timer
              already_tracked = true
            }
          }
          if !already_tracked {
            game.ghost_button_feedback.push(
              { ghost_index: press.0, button_id: press.1, timer: 0.8 },
            )
          }
        }
      }
      None => ()
    }
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
  // Handle failed state - quick restart
  if game.play_state is Failed {
    if @raylib.is_key_pressed(@raylib.KeyR) {
      @time.reset_level(game)
      game.restart_flash_timer = 0.3
      @types.set_message(game, "Retry!", 0.6)
    }
    // Also allow Space to enter planning from failed state
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      @time.enter_planning(game)
    }
  }
}

///|
fn update_planning(game : @types.Game) -> Unit {
  game.planning_paused = true
  // In planning mode, player reviews and decides next action
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Paused
    return
  }
  // Start new loop with transition
  if @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    @time.start_new_loop(game)
    game.loop_transition_timer = 0.3
    game.planning_paused = false
    game.screen = Playing
    return
  }
  // Undo last ghost
  if @raylib.is_key_pressed(@raylib.KeyU) {
    if @time.undo_loop(game) {
      @types.set_message(game, "Ghost removed", 0.8)
    } else {
      @types.set_message(game, "No ghosts to undo", 0.8)
    }
  }
  // Full reset (faster restart)
  if @raylib.is_key_pressed(@raylib.KeyR) {
    @time.reset_level(game)
    game.restart_flash_timer = 0.3
    game.planning_paused = false
    game.screen = Playing
    @types.set_message(game, "Level Reset", 0.6)
  }
  // Quit to level select
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    game.planning_paused = false
    game.screen = LevelSelect
  }
  // Scrub timeline with left/right (with held-key fast scrub)
  if @raylib.is_key_pressed(@raylib.KeyRight) ||
    (@raylib.is_key_down(@raylib.KeyRight) && game.frame_count % 4 == 0) {
    game.planning_tick = @types.mini(
      game.planning_tick + 1,
      game.timeline.length() - 1,
    )
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) ||
    (@raylib.is_key_down(@raylib.KeyLeft) && game.frame_count % 4 == 0) {
    game.planning_tick = @types.maxi(game.planning_tick - 1, 0)
  }
  // Home/End keys for quick timeline jump
  if @raylib.is_key_pressed(@raylib.KeyHome) {
    game.planning_tick = 0
  }
  if @raylib.is_key_pressed(@raylib.KeyEnd) {
    game.planning_tick = @types.maxi(game.timeline.length() - 1, 0)
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
