// Main game update dispatcher

///|
/// Updates all game systems for one frame with delta time `dt`.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_counter += 1
  // Apply speed multiplier to dt for gameplay (not menu/UI)
  let game_dt : Float = match game.state {
    Playing => dt * game.speed_multiplier
    _ => dt
  }
  game.update_particles(dt)
  game.update_chain_lines(dt)
  game.update_notifications(dt)
  game.update_wave_message(dt)
  match game.state {
    Menu => game.update_menu(dt)
    MapSelect => game.update_map_select(dt)
    Playing => game.update_playing(game_dt)
    Paused => game.update_paused(dt)
    WavePrep => game.update_wave_prep(dt)
    Building => game.update_building(dt)
    TowerInfo => game.update_tower_info(dt)
    GameOver => game.update_game_over(dt)
    Victory => game.update_victory(dt)
  }
}

///|
/// Updates the main menu navigation and difficulty selection.
fn @types.Game::update_menu(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * 3.5
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
  // Difficulty selection with Left/Right
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.difficulty -= 1
    if game.difficulty < 0 {
      game.difficulty = 2
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.difficulty += 1
    if game.difficulty > 2 {
      game.difficulty = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.menu_cursor == 0 {
      // Start game -> map select
      game.state = MapSelect
      game.menu_cursor = 0
    } else if game.menu_cursor == 1 {
      // Cycle difficulty
      game.difficulty = (game.difficulty + 1) % 3
    }
  }
}

///|
/// Updates the map selection screen cursor and input handling.
fn @types.Game::update_map_select(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * 3.5
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.menu_cursor -= 1
    if game.menu_cursor < 0 {
      game.menu_cursor = @types.map_count - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.menu_cursor += 1
    if game.menu_cursor >= @types.map_count {
      game.menu_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = Menu
    game.menu_cursor = 0
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.current_map = game.menu_cursor
    load_map(game, game.current_map)
    game.state = WavePrep
    game.wave_timer = @types.wave_prep_time
  }
  ignore(dt)
}

///|
/// Updates active gameplay including spawning, combat, and wave completion checks.
fn @types.Game::update_playing(game : @types.Game, dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = Paused
    return
  }
  // Toggle building mode
  if @raylib.is_key_pressed(@raylib.KeyB) {
    game.prev_state = Playing
    game.state = Building
    return
  }
  // Toggle range display
  if @raylib.is_key_pressed(@raylib.KeyR) {
    game.show_ranges = !game.show_ranges
  }
  // Toggle minimap
  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.show_minimap = !game.show_minimap
  }
  // Speed control
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    game.speed_setting = (game.speed_setting + 1) % 3
    game.speed_multiplier = @types.speed_from_setting(game.speed_setting)
  }
  // Tower selection with mouse click (select tower by clicking on it)
  if @raylib.is_key_pressed(@raylib.KeyT) {
    // Open tower info if tower is selected
    if game.selected_tower_idx >= 0 {
      game.prev_state = Playing
      game.state = TowerInfo
      return
    }
  }
  // Select/deselect tower with number keys when not in build mode
  game.handle_tower_selection()
  game.update_camera(dt)
  game.update_spawning(dt)
  game.update_enemies(dt)
  game.update_towers(dt)
  game.update_projectiles(dt)
  game.update_interest(dt)
  // Check wave complete
  if game.enemies_spawned >= game.enemies_to_spawn {
    let mut alive = false
    for enemy in game.enemies {
      if enemy.active {
        alive = true
        break
      }
    }
    if !alive && game.wave_active {
      // Wave complete
      game.wave_active = false
      let info = @levels.get_wave_info(game.current_wave)
      game.gold += info.bonus_gold + @types.wave_completion_bonus
      game.total_gold_earned += info.bonus_gold + @types.wave_completion_bonus
      if game.current_wave > game.longest_wave {
        game.longest_wave = game.current_wave
      }
      game.current_wave += 1
      if game.current_wave >= @types.max_waves {
        game.state = Victory
      } else {
        game.state = WavePrep
        game.wave_timer = @types.wave_prep_time
      }
    }
  }
  // Check game over
  if game.lives <= 0 {
    game.lives = 0
    game.state = GameOver
  }
}

///|
/// Updates the pause screen handling resume and quit input.
fn @types.Game::update_paused(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = Playing
  }
  // Allow quitting to menu
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    game.reset_game()
    game.state = Menu
  }
}

///|
/// Updates the wave preparation countdown and allows building during the timer.
fn @types.Game::update_wave_prep(game : @types.Game, dt : Float) -> Unit {
  game.update_camera(dt)
  // Allow building during prep
  if @raylib.is_key_pressed(@raylib.KeyB) {
    game.prev_state = WavePrep
    game.state = Building
    return
  }
  // Tower selection with number keys
  game.handle_tower_placement_keys()
  // Speed control
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    game.speed_setting = (game.speed_setting + 1) % 3
    game.speed_multiplier = @types.speed_from_setting(game.speed_setting)
  }
  game.wave_timer -= dt
  if game.wave_timer <= 0.0 || @raylib.is_key_pressed(@raylib.KeySpace) {
    game.start_wave(game.current_wave)
    game.state = Playing
  }
}

///|
/// Updates the tower building mode with cursor movement and placement input.
fn @types.Game::update_building(game : @types.Game, dt : Float) -> Unit {
  game.update_camera(dt)
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyB) {
    // Return to previous state
    match game.prev_state {
      Playing => game.state = Playing
      _ => game.state = WavePrep
    }
    return
  }
  game.handle_tower_placement_keys()
  // Hover position (arrow keys for grid cursor)
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.hover_gx -= 1
    if game.hover_gx < 0 {
      game.hover_gx = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.hover_gx += 1
    if game.hover_gx >= @types.map_w {
      game.hover_gx = @types.map_w - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.hover_gy -= 1
    if game.hover_gy < 0 {
      game.hover_gy = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.hover_gy += 1
    if game.hover_gy >= @types.map_h {
      game.hover_gy = @types.map_h - 1
    }
  }
  game.hover_valid = @types.can_place_tower(game, game.hover_gx, game.hover_gy)
  // Place tower
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.try_place_tower()
  }
}

///|
/// Updates the tower info panel with upgrade, sell, and targeting controls.
fn @types.Game::update_tower_info(game : @types.Game, dt : Float) -> Unit {
  game.update_camera(dt)
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyT) {
    game.state = game.prev_state
    return
  }
  // Upgrade tower with U
  if @raylib.is_key_pressed(@raylib.KeyU) {
    game.try_upgrade_tower()
  }
  // Sell tower with S
  if @raylib.is_key_pressed(@raylib.KeyS) {
    game.try_sell_tower()
    game.state = game.prev_state
    return
  }
  // Cycle targeting mode with F
  if @raylib.is_key_pressed(@raylib.KeyF) {
    game.cycle_targeting_mode()
  }
  // Navigate between towers with Left/Right
  if @raylib.is_key_pressed(@raylib.KeyLeft) ||
    @raylib.is_key_pressed(@raylib.KeyRight) {
    let dir : Int = if @raylib.is_key_pressed(@raylib.KeyRight) {
      1
    } else {
      -1
    }
    let start = game.selected_tower_idx
    let mut next = start + dir
    for _iter in 0..<game.towers.length() {
      if next < 0 {
        next = game.towers.length() - 1
      }
      if next >= game.towers.length() {
        next = 0
      }
      if game.towers[next].active {
        game.selected_tower_idx = next
        return
      }
      next += dir
    }
  }
}

///|
/// Updates the game over screen waiting for return-to-menu input.
fn @types.Game::update_game_over(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.reset_game()
    game.state = Menu
  }
}

///|
/// Updates the victory screen waiting for return-to-menu input.
fn @types.Game::update_victory(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.reset_game()
    game.state = Menu
  }
}

///|
/// Updates camera rotation, pan, zoom, and pitch from keyboard and mouse input.
fn @types.Game::update_camera(game : @types.Game, dt : Float) -> Unit {
  // Camera rotation with Q/E
  if @raylib.is_key_down(@raylib.KeyQ) {
    game.camera_angle += 60.0 * dt
  }
  if @raylib.is_key_down(@raylib.KeyE) {
    game.camera_angle -= 60.0 * dt
  }
  // Camera pan with WASD (when not in build mode moving cursor)
  if game.state != Building {
    let pan_speed : Float = 15.0 * dt
    if @raylib.is_key_down(@raylib.KeyW) {
      game.camera_target_z -= pan_speed
    }
    if @raylib.is_key_down(@raylib.KeyS) {
      game.camera_target_z += pan_speed
    }
    if @raylib.is_key_down(@raylib.KeyA) {
      game.camera_target_x -= pan_speed
    }
    if @raylib.is_key_down(@raylib.KeyD) {
      game.camera_target_x += pan_speed
    }
  }
  // Clamp camera target
  let map_max_x = Float::from_int(@types.map_w) * @types.cell_size
  let map_max_z = Float::from_int(@types.map_h) * @types.cell_size
  game.camera_target_x = @types.clampf(game.camera_target_x, 0.0, map_max_x)
  game.camera_target_z = @types.clampf(game.camera_target_z, 0.0, map_max_z)
  // Camera zoom with mouse wheel or +/-
  let wheel = @raylib.get_mouse_wheel_move()
  if wheel != 0.0 {
    game.camera_dist -= wheel * 2.0
    game.camera_dist = @types.clampf(
      game.camera_dist,
      @types.camera_min_dist,
      @types.camera_max_dist,
    )
  }
  // Camera pitch adjustment with Z/X
  if @raylib.is_key_down(@raylib.KeyZ) {
    game.camera_pitch += 30.0 * dt
    game.camera_pitch = @types.clampf(game.camera_pitch, 20.0, 80.0)
  }
  if @raylib.is_key_down(@raylib.KeyX) {
    game.camera_pitch -= 30.0 * dt
    game.camera_pitch = @types.clampf(game.camera_pitch, 20.0, 80.0)
  }
  ignore(dt)
}

///|
/// Updates all active particles applying velocity, gravity, and lifetime decay.
fn @types.Game::update_particles(game : @types.Game, dt : Float) -> Unit {
  for p in game.particles {
    if !p.active {
      continue
    }
    p.life -= dt
    if p.life <= 0.0 {
      p.active = false
      continue
    }
    p.x += p.vx * dt
    p.y += p.vy * dt
    p.z += p.vz * dt
    p.vy -= 8.0 * dt
    p.vx *= 0.97
    p.vz *= 0.97
    // Gold particles float upward
    if p.kind == @types.particle_gold {
      p.vy = 2.0
      p.vx *= 0.9
      p.vz *= 0.9
    }
    // Lightning particles jitter
    if p.kind == @types.particle_lightning {
      p.x += @types.rand_rangef(game, -0.1, 0.1)
      p.z += @types.rand_rangef(game, -0.1, 0.1)
    }
  }
}

///|
/// Updates chain lightning visual lines and removes expired ones.
fn @types.Game::update_chain_lines(game : @types.Game, dt : Float) -> Unit {
  for cl in game.chain_lines {
    if !cl.active {
      continue
    }
    cl.life -= dt
    if cl.life <= 0.0 {
      cl.active = false
    }
  }
}

///|
/// Updates the on-screen notification countdown timer.
fn @types.Game::update_notifications(game : @types.Game, dt : Float) -> Unit {
  if game.notification_timer > 0.0 {
    game.notification_timer -= dt
  }
}

///|
/// Updates the wave announcement message countdown timer.
fn @types.Game::update_wave_message(game : @types.Game, dt : Float) -> Unit {
  if game.wave_message_timer > 0.0 {
    game.wave_message_timer -= dt
  }
}

///|
/// Updates the gold interest system, awarding periodic income based on savings.
fn @types.Game::update_interest(game : @types.Game, dt : Float) -> Unit {
  game.interest_timer += dt
  if game.interest_timer >= @types.interest_interval {
    game.interest_timer = 0.0
    let interest_amount : Float = Float::from_int(game.gold) *
      @types.interest_rate
    let capped = interest_amount.to_int().min(@types.interest_cap)
    if capped > 0 {
      game.gold += capped
      game.total_gold_earned += capped
    }
  }
}

///|
/// Handles number key input to select tower types for placement.
fn @types.Game::handle_tower_placement_keys(game : @types.Game) -> Unit {
  // Quick-place with number keys
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.selected_tower_type = Arrow
  } else if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.selected_tower_type = Cannon
  } else if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.selected_tower_type = Frost
  } else if @raylib.is_key_pressed(@raylib.KeyFour) {
    game.selected_tower_type = Lightning
  } else if @raylib.is_key_pressed(@raylib.KeyFive) {
    game.selected_tower_type = Flame
  } else if @raylib.is_key_pressed(@raylib.KeySix) {
    game.selected_tower_type = Sniper
  } else if @raylib.is_key_pressed(@raylib.KeySeven) {
    game.selected_tower_type = Splash
  } else if @raylib.is_key_pressed(@raylib.KeyEight) {
    game.selected_tower_type = Buff
  }
}

///|
/// Handles tower selection by finding the nearest tower to the camera target.
fn @types.Game::handle_tower_selection(game : @types.Game) -> Unit {
  // Select towers by moving cursor over them and pressing T
  // For now, find nearest tower to cursor
  if @raylib.is_key_pressed(@raylib.KeyT) {
    let cam_x = game.camera_target_x
    let cam_z = game.camera_target_z
    for i, tower in game.towers; best_idx = -1, best_dist = 999.0F {
      if !tower.active {
        continue
      }
      let tx = @types.grid_to_world_x(tower.gx)
      let tz = @types.grid_to_world_z(tower.gy)
      let dist = @types.distance2d(cam_x, cam_z, tx, tz)
      if dist < best_dist {
        continue i, dist
      }
    } nobreak {
      game.selected_tower_idx = best_idx
    }
  }
}
