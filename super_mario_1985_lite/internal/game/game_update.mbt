///|
fn @types.Game::update_camera(game : @types.Game, dt : Float) -> Unit {
  let width_f = Float::from_int(@types.screen_width)
  let mut target_x = if game.player.reached_flag {
    game.player.x - width_f * 0.45
  } else {
    game.player.x -
    width_f * 0.36 +
    Float::from_int(game.player.facing) * @types.camera_lead_px
  }

  target_x = @types.clampf(target_x, 0.0, @types.world_width_px - width_f)

  let blend = @types.clampf(dt * @types.camera_lerp, 0.0, 1.0)
  game.camera_x += (target_x - game.camera_x) * blend
}

///|
fn @types.Game::tick_level_timer(game : @types.Game, dt : Float) -> Unit {
  if game.player.reached_flag || game.state != @types.state_playing {
    return
  }

  game.time_accum += dt
  while game.time_accum >= 1.0 {
    game.time_accum -= 1.0
    game.time_left -= 1
    if game.time_left <= 0 {
      game.time_left = 0
      game.state = @types.state_game_over
      game.player.lives = 0
      return
    }
  }
}

///|
fn @types.Game::update_playing(
  game : @types.Game,
  input : @types.Input,
  dt : Float,
) -> Unit {
  game.tick_level_timer(dt)
  if game.state != @types.state_playing {
    return
  }

  game.update_player(input, dt)
  game.update_enemies(dt)
  game.update_coins(dt)
  @particles.update_particles(game, dt)

  if game.shake_t > 0.0 {
    game.shake_t -= dt
    if game.shake_t < 0.0 {
      game.shake_t = 0.0
    }
  }

  game.update_camera(dt)
}

///|
/// Builds and initializes the level, then enters title state.
pub fn init_game(game : @types.Game) -> Unit {
  game.build_level()
  game.state = @types.state_title
  game.time_left = @types.start_time_seconds
  game.time_accum = 0.0
}

///|
/// Advances one frame of game logic using input and delta time.
pub fn update_game(
  game : @types.Game,
  input : @types.Input,
  dt : Float,
) -> Unit {
  game.elapsed += dt

  if game.state == @types.state_title {
    @particles.update_particles(game, dt)
    if input.accept {
      game.reset_full_run()
    }
    return
  }

  if game.state == @types.state_playing {
    game.update_playing(input, dt)
    return
  }

  @particles.update_particles(game, dt)
  if input.restart {
    game.reset_full_run()
  }
}
