///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_count = game.frame_count + 1
  // Update animation timers
  if game.gravity_anim_timer > 0.0 {
    game.gravity_anim_timer = game.gravity_anim_timer - dt
    if game.gravity_anim_timer < 0.0 {
      game.gravity_anim_timer = 0.0
    }
  }
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
    if game.message_timer < 0.0 {
      game.message_timer = 0.0
    }
  }
  // Update entity slide animation timers
  match game.level {
    Some(level) =>
      for i in 0..<level.entities.length() {
        let e = level.entities[i]
        if e.slide_timer > 0.0 {
          e.slide_timer = e.slide_timer - dt * @types.anim_speed
          if e.slide_timer < 0.0 {
            e.slide_timer = 0.0
          }
        }
      }
    None => ()
  }
  match game.screen {
    Title => update_title(game)
    Playing => update_playing(game, dt)
    LevelComplete => update_level_complete(game)
    WorldSelect => update_world_select(game)
    LevelSelect => update_level_select(game)
    Paused => update_paused(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = WorldSelect
  }
}

///|
fn update_world_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    if game.current_world > 0 {
      game.current_world = game.current_world - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    if game.current_world < @types.num_worlds - 1 {
      game.current_world = game.current_world + 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.current_level = 0
    game.screen = LevelSelect
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  let unlocked = game.levels_unlocked[game.current_world]
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    if game.current_level > 0 {
      game.current_level = game.current_level - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    if game.current_level < @types.levels_per_world - 1 &&
      game.current_level < unlocked - 1 {
      game.current_level = game.current_level + 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    if game.current_level >= 5 {
      game.current_level = game.current_level - 5
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    let next = game.current_level + 5
    if next < @types.levels_per_world && next < unlocked {
      game.current_level = next
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.current_level < unlocked {
      start_level(game, game.current_world, game.current_level)
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = WorldSelect
  }
}

///|
fn start_level(game : @types.Game, world : Int, level : Int) -> Unit {
  let lvl = @content.get_level(world, level)
  game.level = Some(lvl)
  game.current_world = world
  game.current_level = level
  game.undo_stack = []
  game.settling = false
  game.settle_timer = 0.0
  game.gravity_anim_timer = 0.0
  game.screen = Playing
  // Initial settle - let everything fall into place
  ignore(@physics.settle_all(lvl))
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  let level = match game.level {
    Some(l) => l
    None => return
  }
  // Check for death
  if level.player_dead {
    game.message_text = "Oops! Press R to retry"
    game.message_timer = @types.message_duration
    // Auto restart after short delay
    if @raylib.is_key_pressed(@raylib.KeyR) {
      restart_level(game)
    }
    return
  }
  // Check for completion
  if level.completed {
    complete_level(game)
    return
  }
  // Handle settling (gravity animation)
  if game.settling {
    game.settle_timer = game.settle_timer - dt
    if game.settle_timer <= 0.0 {
      let moved = @physics.step_gravity(level)
      if moved {
        game.settle_timer = @types.settle_delay
      } else {
        game.settling = false
      }
    }
    return
  }
  // Pause
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Paused
    return
  }
  // Restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    restart_level(game)
    return
  }
  // Undo
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    if game.undo_stack.length() > 0 {
      let snap = game.undo_stack.pop()
      match snap {
        Some(s) => @types.restore_snapshot(level, s)
        None => ()
      }
    }
    return
  }
  // Gravity rotation: Q = counter-clockwise, E = clockwise
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    let new_dir = @types.rotate_gravity_ccw(level.gravity)
    @physics.rotate_gravity(level, game, new_dir)
    game.settling = true
    game.settle_timer = @types.settle_delay
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyE) {
    let new_dir = @types.rotate_gravity_cw(level.gravity)
    @physics.rotate_gravity(level, game, new_dir)
    game.settling = true
    game.settle_timer = @types.settle_delay
    return
  }
  // Player movement (perpendicular to gravity)
  let (perp1, perp2) = @types.gravity_perp_vectors(level.gravity)
  let (p1x, p1y) = perp1
  let (p2x, p2y) = perp2
  // Map arrow keys based on gravity direction
  let mut moved = false
  match level.gravity {
    Down | Up => {
      if @raylib.is_key_pressed(@raylib.KeyLeft) {
        moved = @physics.try_move_player(level, game, p1x, p1y)
      }
      if @raylib.is_key_pressed(@raylib.KeyRight) && !(moved) {
        moved = @physics.try_move_player(level, game, p2x, p2y)
      }
    }
    Left | Right => {
      if @raylib.is_key_pressed(@raylib.KeyUp) {
        moved = @physics.try_move_player(level, game, p1x, p1y)
      }
      if @raylib.is_key_pressed(@raylib.KeyDown) && !(moved) {
        moved = @physics.try_move_player(level, game, p2x, p2y)
      }
    }
  }
  if moved {
    // Trigger settling after player move
    game.settling = true
    game.settle_timer = @types.settle_delay
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
  }
}

///|
fn update_level_complete(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    // Go to next level
    let next_level = game.current_level + 1
    if next_level < @types.levels_per_world {
      start_level(game, game.current_world, next_level)
    } else {
      // Completed world, go to world select
      let next_world = game.current_world + 1
      if next_world < @types.num_worlds {
        game.current_world = next_world
      }
      game.screen = WorldSelect
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}

///|
fn complete_level(game : @types.Game) -> Unit {
  let level = match game.level {
    Some(l) => l
    None => return
  }
  let stars = @types.calc_stars(level.moves, level.par_moves)
  let global_idx = game.current_world * @types.levels_per_world +
    game.current_level
  if global_idx < game.level_stars.length() && stars > game.level_stars[global_idx] {
    game.total_stars = game.total_stars - game.level_stars[global_idx] + stars
    game.level_stars[global_idx] = stars
  }
  // Unlock next level
  let next = game.current_level + 2
  if next > game.levels_unlocked[game.current_world] {
    game.levels_unlocked[game.current_world] = if next > @types.levels_per_world {
      @types.levels_per_world
    } else {
      next
    }
  }
  // Unlock next world if all levels completed
  if game.levels_unlocked[game.current_world] >= @types.levels_per_world {
    let nw = game.current_world + 1
    if nw < @types.num_worlds && game.levels_unlocked[nw] < 1 {
      game.levels_unlocked[nw] = 1
    }
  }
  game.screen = LevelComplete
}

///|
fn restart_level(game : @types.Game) -> Unit {
  start_level(game, game.current_world, game.current_level)
}
