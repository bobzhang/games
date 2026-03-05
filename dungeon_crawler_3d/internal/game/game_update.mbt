// Main game update dispatcher (FSM)

///|
/// Advances one frame of dungeon gameplay by dispatching updates for the active game state.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_counter += 1
  if game.state == StateMenu {
    game.update_menu(dt)
  } else if game.state == StatePlaying {
    game.update_playing(dt)
  } else if game.state == StatePaused {
    game.update_paused(dt)
  } else if game.state == StateGameOver {
    game.update_game_over(dt)
  } else if game.state == StateLevelUp {
    game.update_level_up(dt)
  } else if game.state == StateFloorComplete {
    game.update_floor_complete(dt)
  } else if game.state == StateClassSelect {
    game.update_class_select(dt)
  } else if game.state == StateShop {
    game.update_shop(dt)
  } else if game.state == StateShrine {
    game.update_shrine(dt)
  }
  // Update message
  if game.message_timer > 0.0 {
    game.message_timer -= dt
    if game.message_timer <= 0.0 {
      game.message_timer = 0.0
    }
  }
  // Update level up timer
  if game.level_up_timer > 0.0 {
    game.level_up_timer -= dt
    if game.level_up_timer <= 0.0 {
      game.level_up_timer = 0.0
    }
  }
}

///|
fn @types.Game::update_menu(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * @types.menu_blink_speed
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.menu_cursor -= 1
    if game.menu_cursor < 0 {
      game.menu_cursor = 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.menu_cursor += 1
    if game.menu_cursor > 1 {
      game.menu_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.menu_cursor == 0 {
      // New game
      game.start_new_game()
    } else {
      // Continue (restart)
      game.start_new_game()
    }
  }
}

///|
fn @types.Game::start_new_game(game : @types.Game) -> Unit {
  // Reset player stats
  game.player_hp = @types.player_start_hp
  game.player_max_hp = @types.player_start_hp
  game.player_atk = @types.player_start_atk
  game.player_def = @types.player_start_def
  game.player_level = 1
  game.player_xp = 0
  game.player_xp_next = @types.xp_per_level
  game.current_floor = 0
  game.camera_yaw = 0.0
  game.camera_pitch = 0.0
  // Reset floor info
  for i in 0..<@types.max_floors {
    game.floor_info[i].cleared = false
    game.floor_info[i].enemies_killed = 0
    game.floor_info[i].enemies_total = 0
  }
  // Generate first dungeon
  generate_dungeon(game)
  game.state = StatePlaying
  @raylib.disable_cursor()
}

///|
fn @types.Game::update_playing(game : @types.Game, dt : Float) -> Unit {
  // Pause
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = StatePaused
    @raylib.enable_cursor()
    return
  }
  // Update systems
  update_player(game, dt)
  update_enemies(game, dt)
  update_projectiles(game, dt)
  update_particles(game, dt)
  update_loot_bob(game, dt)
}

///|
fn @types.Game::update_paused(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = StatePlaying
    @raylib.disable_cursor()
  }
  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.state = StateMenu
    @raylib.enable_cursor()
  }
}

///|
fn @types.Game::update_game_over(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    // Restart game
    game.start_new_game()
  }
  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.state = StateMenu
    @raylib.enable_cursor()
  }
}

///|
fn @types.Game::update_level_up(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.state = StatePlaying
    @raylib.disable_cursor()
  }
}

///|
fn @types.Game::update_floor_complete(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.current_floor < @types.max_floors - 1 {
      game.current_floor += 1
      generate_dungeon(game)
      game.state = StatePlaying
      @raylib.disable_cursor()
    } else {
      // Game won - return to menu
      game.state = StateMenu
      @raylib.enable_cursor()
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.state = StateMenu
    @raylib.enable_cursor()
  }
}

///|
fn @types.Game::update_class_select(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * @types.menu_blink_speed
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.class_select_cursor -= 1
    if game.class_select_cursor < 0 {
      game.class_select_cursor = 2
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.class_select_cursor += 1
    if game.class_select_cursor > 2 {
      game.class_select_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.player_class = @types.ship_class_from_int(game.class_select_cursor)
    game.start_new_game()
  }
}

///|
fn @types.Game::update_shop(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = StatePlaying
    @raylib.disable_cursor()
  }
}

///|
fn @types.Game::update_shrine(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = StatePlaying
    @raylib.disable_cursor()
  }
}
