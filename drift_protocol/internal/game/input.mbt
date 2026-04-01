///|
/// Process player input during gameplay
pub fn process_input(game : @types.Game, dt : Float) -> Unit {
  // Movement cooldown
  game.move_cooldown -= dt
  if game.move_cooldown > 0.0 {
    return
  }
  // Check for running (shift held)
  game.player.running = @raylib.is_key_down(@raylib.KeyLeftShift)
  // WASD movement
  let mut dx = 0
  let mut dy = 0
  if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
    dy = -1
    game.player.facing = Up
  } else if @raylib.is_key_down(@raylib.KeyS) ||
    @raylib.is_key_down(@raylib.KeyDown) {
    dy = 1
    game.player.facing = Down
  } else if @raylib.is_key_down(@raylib.KeyA) ||
    @raylib.is_key_down(@raylib.KeyLeft) {
    dx = -1
    game.player.facing = Left
  } else if @raylib.is_key_down(@raylib.KeyD) ||
    @raylib.is_key_down(@raylib.KeyRight) {
    dx = 1
    game.player.facing = Right
  }
  if dx != 0 || dy != 0 {
    let nx = game.player.gx + dx
    let ny = game.player.gy + dy
    if !@types.is_tile_blocked(game, nx, ny) {
      game.player.gx = nx
      game.player.gy = ny
      game.player.target_px = @types.tile_to_pixel_x(nx)
      game.player.target_py = @types.tile_to_pixel_y(ny)
      game.player.moving = true
      game.move_cooldown = @types.move_cooldown_time
      // Generate noise
      @stealth.generate_movement_noise(game)
      // Notify guards of noise
      @guard.guards_hear_noise(
        game,
        game.noise_x,
        game.noise_y,
        game.noise_radius,
      )
    }
  }
  // E to interact (hack terminal / power node)
  if @raylib.is_key_pressed(@raylib.KeyE) {
    @hacking.try_hack_terminal(game)
  }
  // Q to toss coin (distraction)
  if @raylib.is_key_pressed(@raylib.KeyQ) && game.player.coins > 0 {
    // Toss coin in facing direction, 3 tiles away
    let cdx = @types.direction_dx(game.player.facing) * 3
    let cdy = @types.direction_dy(game.player.facing) * 3
    let tx = @types.clampi(game.player.gx + cdx, 0, @types.grid_width - 1)
    let ty = @types.clampi(game.player.gy + cdy, 0, @types.grid_height - 1)
    @stealth.generate_coin_noise(game, tx, ty)
    @guard.guards_hear_noise(game, tx, ty, @types.coin_noise_radius)
  }
}

///|
/// Process input on title screen
pub fn process_title_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = LevelSelect
    game.menu_selection = 0
  }
}

///|
/// Process input on level select screen
pub fn process_level_select_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    game.menu_selection -= 1
    if game.menu_selection < 0 {
      game.menu_selection = @types.total_levels - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    game.menu_selection += 1
    if game.menu_selection >= @types.total_levels {
      game.menu_selection = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    start_level(game, game.menu_selection)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  }
}

///|
/// Process input while paused
pub fn process_pause_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.screen = Playing
  }
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    game.screen = LevelSelect
  }
}

///|
/// Process input on results screen
pub fn process_results_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.all_levels_complete {
      game.screen = Victory
    } else {
      game.screen = LevelSelect
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    // Replay level
    start_level(game, game.level_index)
  }
}

///|
/// Process hack minigame input
pub fn process_hack_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyLeft) ||
    @raylib.is_key_pressed(@raylib.KeyA) {
    @hacking.hack_input(game, 0)
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) ||
    @raylib.is_key_pressed(@raylib.KeyD) {
    @hacking.hack_input(game, 1)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.hack_game.active = false
    game.hack_game.failed = true
    game.screen = Playing
  }
}

///|
/// Process victory screen input
pub fn process_victory_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = Title
  }
}
