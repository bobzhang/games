///|
pub fn update(game : @types.Game) -> Unit {
  let dt = @raylib.get_frame_time()
  game.frame_count = game.frame_count + 1
  // Update message timer
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
    if game.message_timer < 0.0 {
      game.message_timer = 0.0
      game.message = ""
    }
  }
  // Update input cooldown
  if game.input_cooldown > 0.0 {
    game.input_cooldown = game.input_cooldown - dt
    if game.input_cooldown < 0.0 {
      game.input_cooldown = 0.0
    }
  }
  // Update animation
  @types.update_anim(game.anim, dt)
  match game.screen {
    Title => update_title(game)
    Playing => update_playing(game, dt)
    LevelSelect => update_level_select(game)
    LevelComplete => update_level_complete(game)
    GameComplete => update_game_complete(game)
    Paused => update_paused(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = LevelSelect
    game.level_select_cursor = 0
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  // Navigate with arrow keys
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.level_select_cursor = @types.maxi(game.level_select_cursor - 1, 0)
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.level_select_cursor = @types.mini(
      game.level_select_cursor + 1,
      @types.total_levels - 1,
    )
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.level_select_cursor = @types.maxi(game.level_select_cursor - 5, 0)
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.level_select_cursor = @types.mini(
      game.level_select_cursor + 5,
      @types.total_levels - 1,
    )
  }
  // Select level
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if @types.level_unlocked(game.level_results, game.level_select_cursor) {
      load_level(game, game.level_select_cursor)
    } else {
      @types.set_message(game, "Level locked!", 1.0)
    }
  }
  // Back to title
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  }
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  // Pause
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Paused
    return
  }
  // Don't accept input during animations
  if game.anim.active {
    update_player_movement(game, dt)
    return
  }
  // Update player smooth movement
  update_player_movement(game, dt)
  // Player input
  if game.input_cooldown <= 0.0 {
    // Movement
    let mut moved = false
    if @raylib.is_key_pressed(@raylib.KeyW) ||
      @raylib.is_key_pressed(@raylib.KeyUp) {
      moved = try_move(game, 0, -1)
    } else if @raylib.is_key_pressed(@raylib.KeyS) ||
      @raylib.is_key_pressed(@raylib.KeyDown) {
      moved = try_move(game, 0, 1)
    } else if @raylib.is_key_pressed(@raylib.KeyA) ||
      @raylib.is_key_pressed(@raylib.KeyLeft) {
      moved = try_move(game, -1, 0)
    } else if @raylib.is_key_pressed(@raylib.KeyD) ||
      @raylib.is_key_pressed(@raylib.KeyRight) {
      moved = try_move(game, 1, 0)
    }
    if moved {
      game.input_cooldown = @types.player_move_delay
      // Check for special tiles after moving
      check_tile_interactions(game)
    }
    // Layer swap (Tab)
    if @raylib.is_key_pressed(@raylib.KeyTab) {
      if game.merge_state == Split {
        @layers.swap_layer(game)
        // Verify player can stand here
        if !@layers.can_walk(game, game.player.grid_x, game.player.grid_y) {
          // Swap back - invalid position
          @layers.swap_layer(game)
          // Undo the double count
          game.swap_count = game.swap_count - 2
          @types.set_message(game, "Can't swap here!", 0.8)
        }
      }
    }
    // Merge (Space)
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      @layers.toggle_merge(game)
      // If merging, check if player position is valid
      if game.merge_state == Merged {
        if !@layers.can_walk(game, game.player.grid_x, game.player.grid_y) {
          @layers.toggle_merge(game)
          @types.set_message(game, "Can't merge here!", 0.8)
        }
      }
    }
    // Reset level (R)
    if @raylib.is_key_pressed(@raylib.KeyR) {
      load_level(game, game.current_level)
      @types.set_message(game, "Level reset", 0.5)
    }
  }
}

///|
fn try_move(game : @types.Game, dx : Int, dy : Int) -> Bool {
  let new_x = game.player.grid_x + dx
  let new_y = game.player.grid_y + dy
  if @layers.can_walk(game, new_x, new_y) {
    game.player.grid_x = new_x
    game.player.grid_y = new_y
    game.player.target_x = @types.grid_to_pixel_x(new_x)
    game.player.target_y = @types.grid_to_pixel_y(new_y)
    game.player.moving = true
    @types.start_anim(game.anim, PlayerMove, @types.anim_move_duration)
    true
  } else {
    false
  }
}

///|
fn update_player_movement(game : @types.Game, dt : Float) -> Unit {
  if game.player.moving {
    let speed : Float = 8.0 * dt * 60.0
    let dx = game.player.target_x - game.player.pixel_x
    let dy = game.player.target_y - game.player.pixel_y
    if @types.absf(dx) < 1.0 && @types.absf(dy) < 1.0 {
      game.player.pixel_x = game.player.target_x
      game.player.pixel_y = game.player.target_y
      game.player.moving = false
    } else {
      game.player.pixel_x = game.player.pixel_x + dx * speed * 0.3
      game.player.pixel_y = game.player.pixel_y + dy * speed * 0.3
    }
  }
}

///|
fn check_tile_interactions(game : @types.Game) -> Unit {
  // Check gem
  if @layers.check_gem(game) && !game.gem_collected {
    @layers.collect_gem(game)
    @types.set_message(game, "Gem collected!", 0.8)
  }
  // Check switch
  let switch_id = @layers.check_switch(game)
  if switch_id >= 0 {
    @layers.activate_switch(game, switch_id)
    @types.set_message(game, "Switch activated!", 0.5)
  }
  // Check exit
  if @layers.check_exit(game) {
    complete_level(game)
  }
}

///|
fn complete_level(game : @types.Game) -> Unit {
  let level_def = @levels.get_level(game.current_level)
  let stars = @layers.calc_stars(
    game.swap_count,
    level_def.par_swaps,
    game.gem_collected,
  )
  let result = game.level_results[game.current_level]
  result.completed = true
  if stars > result.stars {
    result.stars = stars
  }
  if game.swap_count < result.best_swaps {
    result.best_swaps = game.swap_count
  }
  @types.start_anim(game.anim, LevelClear, @types.anim_clear_duration)
  if game.current_level >= @types.total_levels - 1 {
    // Check if all levels complete
    let mut all_done = true
    for i in 0..<@types.total_levels {
      if !game.level_results[i].completed {
        all_done = false
        break
      }
    }
    if all_done {
      game.screen = GameComplete
    } else {
      game.screen = LevelComplete
    }
  } else {
    game.screen = LevelComplete
  }
}

///|
pub fn load_level(game : @types.Game, level_index : Int) -> Unit {
  let idx = @types.clampi(level_index, 0, @types.total_levels - 1)
  let level_def = @levels.get_level(idx)
  game.current_level = idx
  game.swap_count = 0
  game.gem_collected = false
  game.merge_state = Split
  game.message = ""
  game.message_timer = 0.0
  game.input_cooldown = 0.2
  // Copy tile arrays
  game.fg_tiles = Array::make(@types.grid_cols * @types.grid_rows, Empty)
  for i in 0..<level_def.fg.length() {
    game.fg_tiles[i] = level_def.fg[i]
  }
  game.bg_tiles = Array::make(@types.grid_cols * @types.grid_rows, Empty)
  for i in 0..<level_def.bg.length() {
    game.bg_tiles[i] = level_def.bg[i]
  }
  // Reset switch states
  for i in 0..<game.switch_states.length() {
    game.switch_states[i] = false
  }
  // Set player position
  let p = game.player
  p.grid_x = level_def.player_start_x
  p.grid_y = level_def.player_start_y
  p.pixel_x = @types.grid_to_pixel_x(p.grid_x)
  p.pixel_y = @types.grid_to_pixel_y(p.grid_y)
  p.target_x = p.pixel_x
  p.target_y = p.pixel_y
  p.active_layer = level_def.player_start_layer
  p.moving = false
  p.move_timer = 0.0
  game.screen = Playing
  @types.set_message(game, level_def.name, 1.5)
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
    let next = game.current_level + 1
    if next < @types.total_levels {
      load_level(game, next)
    } else {
      game.screen = LevelSelect
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}

///|
fn update_game_complete(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}
