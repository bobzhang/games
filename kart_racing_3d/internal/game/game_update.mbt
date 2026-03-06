// Main game update dispatcher

///|
/// Updates all game systems for the current frame based on the active game state.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_counter += 1
  update_particles(game, dt)
  match game.state {
    Menu => game.update_menu(dt)
    KartSelect => game.update_kart_select(dt)
    TrackPreview => game.update_track_preview(dt)
    Countdown => game.update_countdown(dt)
    Racing => game.update_racing(dt)
    Paused => game.update_paused(dt)
    RaceComplete => game.update_race_complete(dt)
    CupComplete => game.update_cup_complete(dt)
  }
}

///|
fn @types.Game::update_menu(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * 3.5
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.menu_cursor -= 1
    if game.menu_cursor < 0 {
      game.menu_cursor = @types.cups_count - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.menu_cursor += 1
    if game.menu_cursor >= @types.cups_count {
      game.menu_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.current_cup = game.menu_cursor
    game.current_race = 0
    game.state = KartSelect
    game.kart_select_cursor = 0
    game.selected_kart_type = 0
    game.selected_character = 0
  }
}

///|
fn @types.Game::update_kart_select(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * 3.5
  // Navigate kart types
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.selected_kart_type -= 1
    if game.selected_kart_type < 0 {
      game.selected_kart_type = @types.kart_type_count - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.selected_kart_type += 1
    if game.selected_kart_type >= @types.kart_type_count {
      game.selected_kart_type = 0
    }
  }
  // Navigate characters with up/down
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.selected_character -= 1
    if game.selected_character < 0 {
      game.selected_character = @types.max_karts - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.selected_character += 1
    if game.selected_character >= @types.max_karts {
      game.selected_character = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    // Move to track preview
    game.state = TrackPreview
    game.preview_timer = 0.0
    game.preview_rotation = 0.0
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = Menu
  }
}

///|
fn @types.Game::update_track_preview(game : @types.Game, dt : Float) -> Unit {
  game.preview_timer += dt
  game.preview_rotation += dt * 0.5
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    game.preview_timer > 5.0 {
    reset_cup_points(game)
    game.start_race()
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = KartSelect
  }
}

///|
fn @types.Game::start_race(game : @types.Game) -> Unit {
  load_track(game, game.current_cup, game.current_race)
  game.state = Countdown
  game.countdown_timer = @types.countdown_total
}

///|
fn @types.Game::update_countdown(game : @types.Game, dt : Float) -> Unit {
  game.countdown_timer -= dt
  game.update_camera_chase(dt)
  if game.countdown_timer <= 0.0 {
    game.state = Racing
    game.race_time = 0.0
    game.lap_start_time = 0.0
  }
}

///|
fn @types.Game::update_racing(game : @types.Game, dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = Paused
    return
  }
  game.race_time += dt
  game.current_lap_time = game.race_time - game.lap_start_time
  // Update global effects
  game.update_lightning_effect(dt)
  game.update_star_effects(dt)
  // Update all systems
  update_player_kart(game, dt)
  update_ai_karts(game, dt)
  // Waypoint tracking and surface detection for all karts
  for i in 0..<@types.max_karts {
    update_kart_waypoint(game, i)
    game.update_kart_surface(i)
    game.update_kart_wrong_way(i, dt)
  }
  check_kart_collisions(game)
  update_positions(game)
  check_powerup_collisions(game)
  update_powerup_respawns(game, dt)
  update_projectiles(game, dt)
  update_dropped_items(game, dt)
  check_dropped_item_collisions(game)
  update_projectile_homing(game, dt)
  update_item_box_respawns(game, dt)
  game.update_camera_chase(dt)
  // Emit track-based particles (boost pads, etc.)
  game.emit_surface_particles()
  // Check race end
  if player_finished(game) || all_karts_finished(game) {
    // Auto-finish any remaining karts
    for i in 0..<@types.max_karts {
      let kart = game.karts[i]
      if kart.active && !kart.finished {
        kart.finished = true
        kart.finish_time = game.race_time + Float::from_int(kart.place) * 2.0
      }
    }
    update_positions(game)
    apply_race_results(game)
    game.state = RaceComplete
    game.results_scroll = 0.0
  }
}

///|
fn @types.Game::update_paused(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = Racing
  }
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    game.state = Menu
  }
}

///|
fn @types.Game::update_race_complete(game : @types.Game, dt : Float) -> Unit {
  game.results_scroll += dt
  game.update_camera_chase(dt)
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.current_race += 1
    if game.current_race >= @types.races_per_cup {
      game.state = CupComplete
      game.results_scroll = 0.0
    } else {
      game.start_race()
    }
  }
}

///|
fn @types.Game::update_cup_complete(game : @types.Game, dt : Float) -> Unit {
  game.results_scroll += dt
  ignore(dt)
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.state = Menu
  }
}

///|
fn @types.Game::update_camera_chase(game : @types.Game, dt : Float) -> Unit {
  let kart = game.karts[@types.player_kart]
  if !kart.active {
    return
  }
  // Target camera position behind the kart
  let behind_x = kart.x - @math.sinf(kart.angle) * @types.camera_dist
  let behind_z = kart.z - @math.cosf(kart.angle) * @types.camera_dist
  let behind_y = kart.y + @types.camera_height
  // Add drift camera offset (shift to the side when drifting)
  let drift_offset : Float = if kart.drift_left {
    -@types.camera_drift_offset
  } else if kart.drift_right {
    @types.camera_drift_offset
  } else {
    0.0
  }
  let perp_x = @math.cosf(kart.angle) * drift_offset
  let perp_z = -@math.sinf(kart.angle) * drift_offset
  let target_x = behind_x + perp_x
  let target_z = behind_z + perp_z
  // Smooth interpolation
  let smooth = @types.camera_smooth * dt
  let s = @types.clampf(smooth, 0.0, 1.0)
  game.camera_x = @types.lerpf(game.camera_x, target_x, s)
  game.camera_y = @types.lerpf(game.camera_y, behind_y, s)
  game.camera_z = @types.lerpf(game.camera_z, target_z, s)
  // Look at a point ahead of the kart
  let look_ahead : Float = 3.0
  game.camera_look_x = kart.x + @math.sinf(kart.angle) * look_ahead
  game.camera_look_y = kart.y + 0.5
  game.camera_look_z = kart.z + @math.cosf(kart.angle) * look_ahead
  // Dynamic FOV: widen during boosts
  let target_fov : Float = if kart.boost_timer > 0.0 || kart.star_timer > 0.0 {
    @types.camera_fovy + @types.camera_boost_fov_add
  } else {
    @types.camera_fovy
  }
  game.camera_fov = @types.lerpf(game.camera_fov, target_fov, s)
  // Camera shake when stunned or on rough surfaces
  if kart.spin_timer > 0.0 || kart.stunned_timer > 0.0 {
    game.camera_shake = @types.lerpf(game.camera_shake, 0.3, 0.1)
  } else if kart.on_surface_type == Dirt {
    game.camera_shake = @types.lerpf(game.camera_shake, 0.05, 0.1)
  } else {
    game.camera_shake = @types.lerpf(game.camera_shake, 0.0, 0.1)
  }
  if game.camera_shake > 0.01 {
    let shake_x = @types.rand_rangef(
      game,
      -game.camera_shake,
      game.camera_shake,
    )
    let shake_y = @types.rand_rangef(
      game,
      -game.camera_shake,
      game.camera_shake,
    )
    game.camera_x = game.camera_x + shake_x
    game.camera_y = game.camera_y + shake_y
  }
}

// Update kart surface detection

///|
fn @types.Game::update_kart_surface(game : @types.Game, kart_idx : Int) -> Unit {
  let kart = game.karts[kart_idx]
  if !kart.active {
    return
  }
  kart.on_surface_type = @types.detect_surface_type(game, kart.x, kart.z)
  // Boost pad effect
  if kart.on_surface_type == BoostPad && kart.on_ground {
    if kart.boost_timer < 0.3 {
      kart.boost_timer = 0.3
      kart.boost_power = @types.boost_speed_add * 0.5
    }
  }
}

// Update wrong way detection

///|
fn @types.Game::update_kart_wrong_way(
  game : @types.Game,
  kart_idx : Int,
  dt : Float,
) -> Unit {
  let kart = game.karts[kart_idx]
  if !kart.active || kart.finished {
    return
  }
  kart.wrong_way = @types.is_wrong_way(game, kart)
  if kart.wrong_way {
    kart.wrong_way_timer += dt
  } else {
    kart.wrong_way_timer = 0.0
  }
}

// Update global lightning effect

///|
fn @types.Game::update_lightning_effect(game : @types.Game, dt : Float) -> Unit {
  if game.lightning_active {
    game.lightning_timer -= dt
    if game.lightning_timer <= 0.0 {
      game.lightning_active = false
      // Restore all karts from lightning
      for i in 0..<@types.max_karts {
        game.karts[i].lightning_timer = 0.0
      }
    }
  }
}

// Update star effects

///|
fn @types.Game::update_star_effects(game : @types.Game, dt : Float) -> Unit {
  game.star_rainbow_timer += dt * 5.0
  for i in 0..<@types.max_karts {
    let kart = game.karts[i]
    if !kart.active {
      continue
    }
    if kart.star_timer > 0.0 {
      kart.star_timer -= dt
      kart.invincible_timer = kart.star_timer
      // Spawn star sparkle particles
      if game.frame_counter % 4 == 0 {
        let r = 200 + @types.rand_range(game, 0, 55)
        let g = 150 + @types.rand_range(game, 0, 105)
        let b = 50 + @types.rand_range(game, 0, 205)
        @types.spawn_typed_particles(
          game,
          @types.particle_star_sparkle,
          kart.x,
          kart.y + 0.5,
          kart.z,
          2,
          r,
          g,
          b,
          0.06,
          0.3,
        )
      }
    }
  }
}

// Emit surface-based particles (dust on dirt, sparks on boost pads)

///|
fn @types.Game::emit_surface_particles(game : @types.Game) -> Unit {
  for i in 0..<@types.max_karts {
    let kart = game.karts[i]
    if !kart.active || !kart.on_ground {
      continue
    }
    if kart.speed < 3.0 {
      continue
    }
    // Dust on dirt/grass
    if kart.on_surface_type == Dirt || kart.on_surface_type == Grass {
      if game.frame_counter % 6 == i % 6 {
        let dc : (Int, Int, Int) = if kart.on_surface_type == Dirt {
          (160, 130, 80)
        } else {
          (80, 140, 60)
        }
        @types.spawn_typed_particles(
          game,
          @types.particle_dust,
          kart.x,
          kart.y + 0.1,
          kart.z,
          1,
          dc.0,
          dc.1,
          dc.2,
          0.08,
          0.5,
        )
      }
    }
    // Sparks on boost pad
    if kart.on_surface_type == BoostPad {
      if game.frame_counter % 3 == i % 3 {
        @types.spawn_typed_particles(
          game,
          @types.particle_boost_flame,
          kart.x,
          kart.y + 0.05,
          kart.z,
          1,
          255,
          220,
          50,
          0.05,
          0.3,
        )
      }
    }
    // Ice spray on ice surface
    if kart.on_surface_type == SurfaceIce {
      if game.frame_counter % 8 == i % 8 {
        @types.spawn_typed_particles(
          game,
          @types.particle_splash,
          kart.x,
          kart.y + 0.05,
          kart.z,
          1,
          200,
          220,
          255,
          0.04,
          0.4,
        )
      }
    }
  }
}
