///|
fn reset_level(game : @types.Game) -> Unit {
  let level = @levels.get_level(game.current_level)
  game.play_state = Aiming
  game.tick_count = 0
  game.trail = []
  game.probe.pos = @types.vec2f(level.launch_pos.x, level.launch_pos.y)
  game.probe.vel = @types.vec2f_zero()
  game.probe.active = false
  game.message = ""
  game.message_timer = 0.0
  // Reset waypoints
  for i in 0..<level.waypoints.length() {
    level.waypoints[i].collected = false
  }
  // Update preview
  game.preview = @physics.compute_preview(
    level.launch_pos,
    game.launch_angle,
    level.planets,
    level.station,
  )
}

///|
fn launch_probe(game : @types.Game) -> Unit {
  let level = @levels.get_level(game.current_level)
  game.play_state = Flying
  game.probe.pos = @types.vec2f(level.launch_pos.x, level.launch_pos.y)
  let vx = @types.cosf(game.launch_angle) * @types.launch_speed
  let vy = @types.sinf(game.launch_angle) * @types.launch_speed
  game.probe.vel = @types.vec2f(vx, vy)
  game.probe.active = true
  game.tick_count = 0
  game.trail = []
}

///|
fn compute_stars(game : @types.Game, level : @types.Level) -> Int {
  let mut stars = 1 // Completed = 1 star
  // Under par = 2 stars
  if game.tick_count <= level.par_ticks {
    stars = 2
  }
  // Under par + all waypoints = 3 stars
  if game.tick_count <= level.par_ticks {
    let mut all_collected = true
    for i in 0..<level.waypoints.length() {
      if !level.waypoints[i].collected {
        all_collected = false
      }
    }
    if all_collected && level.waypoints.length() > 0 {
      stars = 3
    } else if level.waypoints.length() == 0 &&
      game.tick_count <= level.par_ticks {
      stars = 3
    }
  }
  stars
}

///|
fn handle_win(game : @types.Game) -> Unit {
  let level = @levels.get_level(game.current_level)
  let stars = compute_stars(game, level)
  let score = game.scores[game.current_level]
  score.completed = true
  if game.tick_count < score.best_ticks {
    score.best_ticks = game.tick_count
  }
  if stars > score.stars {
    score.stars = stars
  }
  game.play_state = Won
  @types.set_message(game, "TARGET REACHED!", 2.0)
}

///|
fn update_title(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    game.screen = TierSelect
  }
}

///|
fn update_tier_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = Title
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.current_tier = Launch
    game.screen = LevelSelect
  } else if @raylib.is_key_pressed(@raylib.KeyTwo) {
    if @types.tier_unlocked(Slingshot, game.scores) {
      game.current_tier = Slingshot
      game.screen = LevelSelect
    }
  } else if @raylib.is_key_pressed(@raylib.KeyThree) {
    if @types.tier_unlocked(Navigation, game.scores) {
      game.current_tier = Navigation
      game.screen = LevelSelect
    }
  }
}

///|
fn update_level_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = TierSelect
    return
  }
  let count = @types.tier_level_count(game.current_tier)
  let start = @types.tier_start_index(game.current_tier)
  // Number keys 1-9 to select level
  let keys = [
    @raylib.KeyOne,
    @raylib.KeyTwo,
    @raylib.KeyThree,
    @raylib.KeyFour,
    @raylib.KeyFive,
    @raylib.KeySix,
    @raylib.KeySeven,
    @raylib.KeyEight,
    @raylib.KeyNine,
  ]
  for i in 0..<count {
    if i < keys.length() && @raylib.is_key_pressed(keys[i]) {
      game.current_level = start + i
      game.launch_angle = 0.0
      game.screen = Playing
      reset_level(game)
      return
    }
  }
}

///|
fn update_playing(game : @types.Game) -> Unit {
  let level = @levels.get_level(game.current_level)
  // ESC to go back to level select
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  // R to restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    reset_level(game)
    return
  }
  match game.play_state {
    Aiming => {
      // Adjust angle
      if @raylib.is_key_down(@raylib.KeyLeft) {
        game.launch_angle -= @types.angle_step
      }
      if @raylib.is_key_down(@raylib.KeyRight) {
        game.launch_angle += @types.angle_step
      }
      // Update preview
      game.preview = @physics.compute_preview(
        level.launch_pos,
        game.launch_angle,
        level.planets,
        level.station,
      )
      // Launch
      if @raylib.is_key_pressed(@raylib.KeySpace) {
        launch_probe(game)
      }
    }
    Flying =>
      // Auto-tick simulation
      for _t in 0..<@types.tick_rate {
        if !game.probe.active {
          break
        }
        game.tick_count += 1
        // Record trail position before simulation step
        game.trail.push(@types.vec2f(game.probe.pos.x, game.probe.pos.y))
        if game.trail.length() > @types.trail_max {
          let new_trail : Array[@types.Vec2f] = []
          for j in 1..<game.trail.length() {
            new_trail.push(game.trail[j])
          }
          game.trail = new_trail
        }
        let result = @physics.simulate_tick(
          game.probe,
          level.planets,
          level.station,
          level.waypoints,
          game.tick_count,
        )
        match result {
          Continue => ()
          ReachedStation => {
            handle_win(game)
            break
          }
          HitPlanet => {
            game.play_state = Failed
            @types.set_message(game, "HIT PLANET!", 2.0)
            break
          }
          OutOfBounds => {
            game.play_state = Failed
            @types.set_message(game, "OUT OF BOUNDS!", 2.0)
            break
          }
          MaxTicks => {
            game.play_state = Failed
            @types.set_message(game, "TIME EXPIRED!", 2.0)
            break
          }
        }
      }
    Won =>
      if @raylib.is_key_pressed(@raylib.KeyEnter) ||
        @raylib.is_key_pressed(@raylib.KeyEnter) {
        game.screen = Results
      }
    Failed => ()
  }
  // Decrease message timer
  if game.message_timer > 0.0 {
    let dt = @raylib.get_frame_time()
    game.message_timer -= dt
  }
}

///|
fn update_results(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.screen = LevelSelect
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    game.screen = Playing
    reset_level(game)
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeyEnter) {
    // Go to next level if available
    let count = @types.tier_level_count(game.current_tier)
    let start = @types.tier_start_index(game.current_tier)
    let next = game.current_level + 1
    if next < start + count {
      game.current_level = next
      game.launch_angle = 0.0
      game.screen = Playing
      reset_level(game)
    } else {
      game.screen = LevelSelect
    }
  }
}

///|
pub fn update(game : @types.Game) -> Unit {
  game.frame_count += 1
  match game.screen {
    Title => update_title(game)
    TierSelect => update_tier_select(game)
    LevelSelect => update_level_select(game)
    Playing => update_playing(game)
    Results => update_results(game)
  }
}
