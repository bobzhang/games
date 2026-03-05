// Main game update dispatcher (FSM)

///|
/// Advances one frame of puzzle gameplay by dispatching the active state machine,
/// then ticking shared timers (transitions, messages, and achievement popups).
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_counter += 1
  game.update_particles(dt)
  match game.state {
    StateMenu => game.update_menu(dt)
    StatePlaying => game.update_playing(dt)
    StatePaused => game.update_paused(dt)
    StateLevelComplete => game.update_level_complete(dt)
    StateGameOver => game.update_game_over(dt)
    StateFloorSelect => game.update_floor_select(dt)
    StateCampaignComplete => game.update_campaign_complete(dt)
    StateWorldSelect => game.update_world_select(dt)
    _ => ()
  }
  // Update transition
  if game.transition_timer > 0.0 {
    game.transition_timer -= dt
    if game.transition_timer <= 0.0 {
      game.transition_timer = 0.0
    }
  }
  // Update message
  if game.message_timer > 0.0 {
    game.message_timer -= dt
    if game.message_timer <= 0.0 {
      game.message_timer = 0.0
    }
  }
  // Update achievement display
  if game.achievement_display_timer > 0.0 {
    game.achievement_display_timer -= dt
    if game.achievement_display_timer <= 0.0 {
      game.achievement_display_timer = 0.0
    }
  }
}

///|
fn @types.Game::update_menu(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * @types.menu_blink_speed
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.menu_cursor -= 1
    if game.menu_cursor < 0 {
      game.menu_cursor = 2
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.menu_cursor += 1
    if game.menu_cursor > 2 {
      game.menu_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.menu_cursor == 0 {
      // New game
      game.reset_progress()
      load_floor(game, 0)
      game.state = StatePlaying
    } else if game.menu_cursor == 1 {
      // World select
      game.state = StateWorldSelect
    } else {
      // Floor select
      game.state = StateFloorSelect
    }
  }
}

///|
fn @types.Game::update_playing(game : @types.Game, dt : Float) -> Unit {
  // Update level timer
  game.level_timer += dt
  // Pause
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = StatePaused
    return
  }
  // Undo
  if @raylib.is_key_pressed(@raylib.KeyZ) ||
    @raylib.is_key_pressed(@raylib.KeyU) {
    game.undo_move()
    return
  }
  // Restart level
  if @raylib.is_key_pressed(@raylib.KeyR) {
    load_floor(game, game.current_floor)
    return
  }
  // Update animations
  game.update_player_animation(dt)
  game.update_entity_animations(dt)
  // Update spike timer (timed spikes in lava world)
  if game.current_world == WorldLava {
    game.update_timed_spikes(dt)
  }
  // Ambient particles for decorations
  game.update_decoration_particles(dt)
  // Camera rotation
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    game.camera_angle += 90.0
  }
  if @raylib.is_key_pressed(@raylib.KeyE) {
    game.camera_angle -= 90.0
  }
  // Gate animation
  if game.gate_anim_timer > 0.0 {
    game.gate_anim_timer -= dt
    if game.gate_anim_timer <= 0.0 {
      game.gate_anim_timer = 0.0
    }
  }
  // Tutorial timer
  if game.tutorial_active {
    game.tutorial_timer += dt
  }
  // Player input (only when not moving)
  if not(game.player_moving) {
    let mut dir : @types.Dir = DirNone
    if @raylib.is_key_pressed(@raylib.KeyUp) ||
      @raylib.is_key_pressed(@raylib.KeyW) {
      dir = DirUp
    } else if @raylib.is_key_pressed(@raylib.KeyDown) ||
      @raylib.is_key_pressed(@raylib.KeyS) {
      dir = DirDown
    } else if @raylib.is_key_pressed(@raylib.KeyLeft) ||
      @raylib.is_key_pressed(@raylib.KeyA) {
      dir = DirLeft
    } else if @raylib.is_key_pressed(@raylib.KeyRight) ||
      @raylib.is_key_pressed(@raylib.KeyD) {
      dir = DirRight
    }
    if dir != DirNone {
      game.try_move_player(dir)
    }
  }
  // Update camera target towards player
  let target_x = Float::from_int(game.player_gx)
  let target_z = Float::from_int(game.player_gy)
  game.camera_target_x += (target_x - game.camera_target_x) *
    @types.minf(dt * 5.0, 1.0)
  game.camera_target_z += (target_z - game.camera_target_z) *
    @types.minf(dt * 5.0, 1.0)
}

///|
fn @types.Game::update_timed_spikes(game : @types.Game, dt : Float) -> Unit {
  game.spike_timer += dt
  if game.spike_timer >= @types.spike_cycle_time {
    game.spike_timer -= @types.spike_cycle_time
    game.spike_phase = not(game.spike_phase)
    // Toggle all spikes
    game.toggle_spikes()
  }
}

///|
fn @types.Game::update_decoration_particles(
  game : @types.Game,
  dt : Float,
) -> Unit {
  ignore(dt)
  // Spawn particles near decorations periodically
  if game.frame_counter % 30 == 0 {
    for i in 0..<game.decoration_count {
      let d = game.decorations[i]
      if not(d.active) {
        continue
      }
      match d.kind {
        DecoTorch =>
          @types.spawn_ambient_particles(
            game,
            d.x,
            0.6,
            d.z,
            1,
            255,
            160,
            50,
            0.1,
            0.8,
          )
        DecoCrystal =>
          @types.spawn_ambient_particles(
            game,
            d.x,
            0.4,
            d.z,
            1,
            100,
            200,
            255,
            0.1,
            0.4,
          )
        DecoMagmaPool =>
          @types.spawn_ambient_particles(
            game,
            d.x,
            0.1,
            d.z,
            1,
            255,
            100,
            20,
            0.15,
            0.3,
          )
        DecoFloatingRock =>
          @types.spawn_ambient_particles(
            game,
            d.x,
            0.5,
            d.z,
            1,
            150,
            100,
            200,
            0.1,
            0.3,
          )
        _ => ()
      }
    }
  }
}

///|
fn @types.Game::update_paused(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = StatePlaying
  }
  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.state = StateMenu
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    load_floor(game, game.current_floor)
    game.state = StatePlaying
  }
  if @raylib.is_key_pressed(@raylib.KeyL) {
    game.state = StateFloorSelect
  }
}

///|
fn @types.Game::update_level_complete(game : @types.Game, dt : Float) -> Unit {
  game.complete_timer += dt
  // Spawn celebration particles periodically
  if game.frame_counter % 10 == 0 && game.complete_timer < 3.0 {
    let px = Float::from_int(game.player_gx) +
      @types.rand_rangef(game, -2.0, 2.0)
    let pz = Float::from_int(game.player_gy) +
      @types.rand_rangef(game, -2.0, 2.0)
    @types.spawn_ambient_particles(
      game, px, 0.5, pz, 3, @types.color_exit_r, @types.color_exit_g, @types.color_exit_b,
      0.3, 2.0,
    )
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    let next = game.current_floor + 1
    if next >= @types.max_floors {
      game.state = StateCampaignComplete
    } else {
      load_floor(game, next)
      game.state = StatePlaying
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.state = StateMenu
  }
  if @raylib.is_key_pressed(@raylib.KeyL) {
    game.state = StateFloorSelect
  }
}

///|
fn @types.Game::update_game_over(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    load_floor(game, game.current_floor)
    game.state = StatePlaying
  }
  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.state = StateMenu
  }
}

///|
fn @types.Game::update_floor_select(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = StateMenu
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.floor_select_cursor -= 1
    if game.floor_select_cursor < 0 {
      game.floor_select_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.floor_select_cursor += 1
    if game.floor_select_cursor >= @types.max_floors {
      game.floor_select_cursor = @types.max_floors - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.floor_select_cursor -= 6
    if game.floor_select_cursor < 0 {
      game.floor_select_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.floor_select_cursor += 6
    if game.floor_select_cursor >= @types.max_floors {
      game.floor_select_cursor = @types.max_floors - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.floor_info[game.floor_select_cursor].unlocked {
      load_floor(game, game.floor_select_cursor)
      game.state = StatePlaying
    }
  }
}

///|
fn @types.Game::update_world_select(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = StateMenu
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.world_select_cursor -= 1
    if game.world_select_cursor < 0 {
      game.world_select_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.world_select_cursor += 1
    if game.world_select_cursor >= @types.num_worlds {
      game.world_select_cursor = @types.num_worlds - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if @types.is_world_unlocked(game, game.world_select_cursor) {
      let first_floor = game.world_select_cursor * @types.floors_per_world
      game.floor_select_cursor = first_floor
      game.state = StateFloorSelect
    }
  }
}

///|
fn @types.Game::update_campaign_complete(
  game : @types.Game,
  _dt : Float,
) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyM) {
    game.state = StateMenu
  }
}
