///|
/// Main game update function - state machine.
pub fn update(game : @types.Game) -> Unit {
  let dt : Float = 1.0 / 60.0
  game.frame_count += 1
  game.anim_timer = game.anim_timer + dt
  game.title_pulse = game.title_pulse + dt
  if game.message_timer > 0.0 {
    game.message_timer = game.message_timer - dt
  }
  match game.screen {
    Title => update_title(game)
    WorldSelect => update_world_select(game)
    LevelSelect => update_level_select(game)
    Playing => update_playing(game, dt)
    Results => update_results(game)
    Paused => update_paused(game)
  }
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    game.screen = WorldSelect
    game.world = 0
  }
}

///|
fn update_world_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.world = (game.world + 1) % 3
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.world = (game.world + 2) % 3
  }
  if @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = LevelSelect
    game.level_index = 0
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  let cols = 5
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.level_index = (game.level_index + 1) % @types.levels_per_world
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.level_index = (game.level_index + @types.levels_per_world - 1) %
      @types.levels_per_world
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.level_index = game.level_index + cols
    if game.level_index >= @types.levels_per_world {
      game.level_index = game.level_index - @types.levels_per_world
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.level_index = game.level_index - cols
    if game.level_index < 0 {
      game.level_index = game.level_index + @types.levels_per_world
    }
  }
  if @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    start_level(game)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = WorldSelect
  }
}

///|
fn start_level(game : @types.Game) -> Unit {
  let idx = @types.global_level_index(game.world, game.level_index)
  let level = @levels.get_level(idx)
  game.current_level = Some(level)
  game.screen = Playing
  @types.reset_level(game)
  // Recompute preview
  update_preview(game)
}

///|
fn update_preview(game : @types.Game) -> Unit {
  let level = match game.current_level {
    Some(l) => l
    None => return
  }
  let points = @physics.compute_preview(
    level, level.start_pos, game.aim_angle, @types.preview_bounces,
  )
  game.preview_points.clear()
  for p in points {
    game.preview_points.push(p)
  }
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  match game.ball_state {
    Aiming => update_aiming(game)
    Moving => update_moving(game, dt)
    Complete => update_complete(game)
    Failed => update_failed(game)
  }
  // Common controls
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Paused
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    @types.reset_level(game)
    update_preview(game)
  }
}

///|
fn update_aiming(game : @types.Game) -> Unit {
  let dt : Float = 1.0 / 60.0
  let mut changed = false
  if @raylib.is_key_down(@raylib.KeyLeft) {
    game.aim_angle = game.aim_angle - @types.aim_speed * dt
    changed = true
  }
  if @raylib.is_key_down(@raylib.KeyRight) {
    game.aim_angle = game.aim_angle + @types.aim_speed * dt
    changed = true
  }
  // Mouse aiming
  let level = match game.current_level {
    Some(l) => l
    None => return
  }
  if @raylib.is_mouse_button_down(@raylib.MouseButtonRight) {
    let mx = Float::from_int(@raylib.get_mouse_x()) - @types.arena_offset_x
    let my = Float::from_int(@raylib.get_mouse_y()) - @types.arena_offset_y
    let dx = mx - level.start_pos.x
    let dy = my - level.start_pos.y
    game.aim_angle = @types.atan2f(dy, dx)
    changed = true
  }
  // Clamp angle
  if game.aim_angle > @types.two_pi {
    game.aim_angle = game.aim_angle - @types.two_pi
  }
  if game.aim_angle < -@types.two_pi {
    game.aim_angle = game.aim_angle + @types.two_pi
  }
  if changed {
    update_preview(game)
  }
  // Launch
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    game.ball_state = Moving
    let vx = @types.cosf(game.aim_angle) * @types.ball_speed
    let vy = @types.sinf(game.aim_angle) * @types.ball_speed
    let ball = @types.new_ball(level.start_pos, @types.vec2(vx, vy))
    game.balls.clear()
    game.balls.push(ball)
    game.total_bounces = 0
  }
}

///|
fn update_moving(game : @types.Game, dt : Float) -> Unit {
  let level = match game.current_level {
    Some(l) => l
    None => return
  }
  // Run physics - use sub-steps for accuracy
  let sub_steps = 4
  let sub_dt = dt / Float::from_int(sub_steps)
  for _s in 0..<sub_steps {
    @physics.simulate_step(game, sub_dt)
  }
  @physics.update_timers(game, dt)
  // Check completion
  if @types.all_targets_hit(level) {
    game.ball_state = Complete
    game.result_timer = 1.0
    // Calculate and save score
    let idx = @types.global_level_index(game.world, game.level_index)
    let score = game.scores[idx]
    score.completed = true
    if game.total_bounces < score.best_bounces {
      score.best_bounces = game.total_bounces
    }
    // Calculate stars
    let has_pickup = @types.pickup_collected(level)
    let under_par = game.total_bounces <= level.par_bounces
    let mut stars = 1
    if under_par {
      stars = 2
    }
    if under_par && has_pickup {
      stars = 3
    }
    if stars > score.stars {
      score.stars = stars
    }
  } else if !(@types.any_ball_active(game.balls)) {
    game.ball_state = Failed
    game.result_timer = 0.5
  }
}

///|
fn update_complete(game : @types.Game) -> Unit {
  game.result_timer = game.result_timer - 1.0 / 60.0
  if game.result_timer <= 0.0 {
    game.screen = Results
  }
}

///|
fn update_failed(game : @types.Game) -> Unit {
  game.result_timer = game.result_timer - 1.0 / 60.0
  if game.result_timer <= 0.0 {
    game.screen = Results
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    let level = match game.current_level {
      Some(l) => l
      None => {
        game.screen = LevelSelect
        return
      }
    }
    if @types.all_targets_hit(level) {
      // Advance to next level
      if game.level_index < @types.levels_per_world - 1 {
        game.level_index += 1
        start_level(game)
      } else {
        game.screen = LevelSelect
      }
    } else {
      // Retry
      @types.reset_level(game)
      update_preview(game)
      game.screen = Playing
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    @types.reset_level(game)
    update_preview(game)
    game.screen = Playing
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
  }
}

///|
fn update_paused(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Playing
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    @types.reset_level(game)
    update_preview(game)
    game.screen = Playing
  }
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    game.screen = LevelSelect
  }
}
