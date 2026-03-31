///|
/// Main update dispatch
pub fn update(game : @types.Game) -> Unit {
  let dt = @types.minf(@raylib.get_frame_time(), 0.05)
  game.frame_count += 1
  game.sound_queue = []
  // Update message timer
  if game.message_timer > 0.0 {
    game.message_timer -= dt
    if game.message_timer <= 0.0 {
      game.message = ""
    }
  }
  match game.screen {
    Title => process_title_input(game)
    LevelSelect => process_level_select_input(game)
    Playing => update_playing(game, dt)
    Paused => process_pause_input(game)
    Hacking => update_hacking(game, dt)
    Results => process_results_input(game)
    Victory => process_victory_input(game)
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
  // Update time
  game.time_played += dt
  // Process player input
  process_input(game, dt)
  // Update player pixel position (smooth lerp)
  let lerp_speed = @types.move_lerp_speed * dt
  game.player.px = @types.lerpf(
    game.player.px,
    game.player.target_px,
    lerp_speed,
  )
  game.player.py = @types.lerpf(
    game.player.py,
    game.player.target_py,
    lerp_speed,
  )
  // Update stealth state
  @stealth.update_shadow_state(game)
  @stealth.update_detection(game)
  @stealth.update_noise(game, dt)
  // Update guard AI
  @guard.update_guards(game, dt)
  @guard.update_cameras(game, dt)
  // Check if player caught by alert guard
  if @stealth.check_player_caught(game) {
    // Player caught - reset to start of level
    @types.set_message(game, "Caught! Restarting...", 2.0)
    game.fade_timer = 1.0
    // Reset player position
    game.player.gx = game.level.start_x
    game.player.gy = game.level.start_y
    game.player.px = @types.tile_to_pixel_x(game.level.start_x)
    game.player.py = @types.tile_to_pixel_y(game.level.start_y)
    game.player.target_px = game.player.px
    game.player.target_py = game.player.py
    game.player.alert_triggered = true
    // Reset guards
    reset_guards(game)
  }
  // Update fade
  if game.fade_timer > 0.0 {
    game.fade_timer -= dt
  }
  // Check level completion (player on exit tile)
  if game.player.gx == game.level.exit_x &&
    game.player.gy == game.level.exit_y &&
    !game.level_complete {
    complete_level(game)
  }
}

///|
fn update_hacking(game : @types.Game, dt : Float) -> Unit {
  process_hack_input(game)
  @hacking.update_hack_minigame(game, dt)
}

///|
/// Start a level
pub fn start_level(game : @types.Game, index : Int) -> Unit {
  game.level_index = index
  game.level = @level.load_level(index)
  game.player = @types.new_agent(game.level.start_x, game.level.start_y)
  game.time_played = 0.0
  game.level_complete = false
  game.hack_game = @types.new_hack_minigame()
  game.score = @types.new_level_score()
  game.noise_radius = 0
  game.noise_timer = 0.0
  game.coin_active = false
  game.fade_timer = 0.0
  game.message = ""
  game.message_timer = 0.0
  game.screen = Playing
  @types.set_message(game, game.level.name, 2.0)
}

///|
/// Complete the current level
fn complete_level(game : @types.Game) -> Unit {
  game.level_complete = true
  game.score = calculate_score(game)
  game.level_scores[game.level_index] = Some(game.score)
  game.all_levels_complete = all_levels_complete(game)
  game.screen = Results
  @types.push_sound(game, LevelComplete)
}

///|
/// Reset guards to their initial positions
fn reset_guards(game : @types.Game) -> Unit {
  for i in 0..<game.level.guards.length() {
    let g = game.level.guards[i]
    if g.patrol_points.length() > 0 {
      let start = g.patrol_points[0]
      g.gx = start.x
      g.gy = start.y
      g.px = @types.tile_to_pixel_x(start.x)
      g.py = @types.tile_to_pixel_y(start.y)
    }
    g.alert_state = Patrolling
    g.suspicious_timer = 0.0
    g.alert_timer = 0.0
    g.detection_meter = 0.0
    g.patrol_index = 0
    g.patrol_forward = true
  }
}
