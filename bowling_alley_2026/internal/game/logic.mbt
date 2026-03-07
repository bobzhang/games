///|
/// Sets the on-screen status message and starts its display timer.
fn @types.Game::set_message(
  game : @types.Game,
  msg : String,
  ttl : Float,
) -> Unit {
  game.message = msg
  game.message_t = ttl
}

///|
/// Deactivates and zeroes every spark in the particle pool.
fn @types.Game::clear_sparks(game : @types.Game) -> Unit {
  for spark in game.sparks {
    spark.active = false
    spark.x = 0.0
    spark.y = 0.0
    spark.vx = 0.0
    spark.vy = 0.0
    spark.life = 0.0
    spark.size = 0.0
    spark.kind = 0
  }
}

///|
/// Activates the first inactive spark slot with the supplied position, velocity, lifetime, and kind.
fn @types.Game::spawn_spark(
  game : @types.Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : Int,
) -> Unit {
  for spark in game.sparks {
    if spark.active {
      continue
    }

    spark.active = true
    spark.x = x
    spark.y = y
    spark.vx = vx
    spark.vy = vy
    spark.life = life
    spark.size = size
    spark.kind = kind
    break
  }
}

///|
/// Emits `n` sparks with random positions and velocities around the given point.
fn @types.Game::burst_sparks(
  game : @types.Game,
  x : Float,
  y : Float,
  n : Int,
  kind : Int,
) -> Unit {
  for _i in 0..<n {
    game.spawn_spark(
      x + @types.randf(-12.0, 12.0),
      y + @types.randf(-12.0, 12.0),
      @types.randf(-220.0, 220.0),
      @types.randf(-260.0, 120.0),
      @types.randf(0.25, 1.0),
      @types.randf(1.4, 5.2),
      kind,
    )
  }
}

///|
/// Advances each active spark position, applies drag, and deactivates expired ones.
fn @types.Game::update_sparks(game : @types.Game, dt : Float) -> Unit {
  for spark in game.sparks {
    if !spark.active {
      continue
    }

    spark.life = spark.life - dt
    if spark.life <= 0.0 {
      spark.active = false
      continue
    }

    spark.x = spark.x + spark.vx * dt
    spark.y = spark.y + spark.vy * dt
    spark.vx = spark.vx * (1.0 - dt * 2.8)
    spark.vy = spark.vy * (1.0 - dt * 2.4) + dt * 180.0
  }
}

///|
/// Returns the bowling ball to its start position with zeroed velocity and spin.
fn @types.Game::reset_ball(game : @types.Game) -> Unit {
  game.ball_x = @types.ball_start_x
  game.ball_y = @types.ball_start_y
  game.ball_vx = 0.0
  game.ball_vy = 0.0
  game.ball_spin = 0.0
  game.ball_live = false
  game.resolve_t = 0.0
}

///|
/// Positions all ten pins in standard triangular formation and zeroes their motion state.
fn @types.Game::reset_full_rack(game : @types.Game) -> Unit {
  let cx : Float = @types.ball_start_x
  for idx, pin in game.pins {
    if idx < 10 {
      let row : Int = if idx < 1 {
        0
      } else if idx < 3 {
        1
      } else if idx < 6 {
        2
      } else {
        3
      }
      let row_start : Int = row * (row + 1) / 2
      let col : Int = idx - row_start
      let y : Float = @types.pin_deck_y +
        Float::from_int(row) * @types.pin_row_gap
      let x0 : Float = cx - Float::from_int(row) * @types.pin_col_gap * 0.5

      pin.standing = true
      pin.x = x0 + Float::from_int(col) * @types.pin_col_gap
      pin.y = y
    } else {
      pin.standing = false
      pin.x = -200.0
      pin.y = -200.0
    }

    pin.vx = 0.0
    pin.vy = 0.0
    pin.ang = 0.0
    pin.ang_v = 0.0
  }
}

///|
/// Returns the number of pins that are still standing.
fn @types.Game::count_standing(game : @types.Game) -> Int {
  let mut n : Int = 0
  for pin in game.pins {
    if pin.standing {
      n = n + 1
    }
  }
  n
}

///|
/// Returns true when all knocked-down pins have slowed below the settle threshold.
fn @types.Game::pins_are_quiet(game : @types.Game) -> Bool {
  for pin in game.pins {
    if pin.standing {
      continue
    }

    let speed2 : Float = pin.vx * pin.vx + pin.vy * pin.vy
    if speed2 > 324.0 {
      return false
    }
  }

  true
}

///|
/// Resets the ball and optionally the full rack, then allows the player to throw.
fn @types.Game::prepare_roll(game : @types.Game, reset_rack : Bool) -> Unit {
  if reset_rack {
    game.reset_full_rack()
  }

  game.pins_left = game.count_standing()
  game.pins_before_roll = game.pins_left
  game.reset_ball()

  game.can_throw = true
  game.charging = false
  game.power = 0.22
  game.power_dir = 1.0
  game.ball_spin = 0.0
  game.spin = @types.clampf(game.spin * 0.65, @types.spin_min, @types.spin_max)
}

///|
/// Zeroes all frame counters, stat totals, and the roll log for a new match.
fn @types.Game::reset_match_stats(game : @types.Game) -> Unit {
  game.frame = 0
  game.roll_in_frame = 0
  game.first_roll = 0
  game.last_knock = 0

  game.strikes = 0
  game.spares = 0
  game.opens = 0

  game.game_t = 0.0
  game.ui_t = 0.0
  game.shake_t = 0.0
  game.clear_rolls()
}

///|
/// Resets all match stats, clears sparks, and begins the first roll of frame 1.
fn @types.Game::start_match(game : @types.Game) -> Unit {
  game.reset_match_stats()
  game.state = Play
  game.aim = 0.0
  game.spin = 0.0
  game.clear_sparks()

  game.prepare_roll(true)
  game.set_message("Frame 1: aim and hold power", 2.0)
}

///|
/// Recomputes the final score, transitions to the result screen, and shows an end message.
fn @types.Game::finalize_match(game : @types.Game) -> Unit {
  game.recompute_score()
  game.state = Result
  game.can_throw = false
  game.charging = false

  if game.score >= 220 {
    game.set_message("Legend game! Score \{game.score}", 2.4)
  } else if game.score >= 180 {
    game.set_message("Great run! Score \{game.score}", 2.4)
  } else {
    game.set_message("Final score \{game.score}", 2.4)
  }
}

///|
/// Topples pin `i` with the given impulse, spawns a spark burst, and triggers a screen shake.
fn @types.Game::knock_pin(
  game : @types.Game,
  i : Int,
  vx : Float,
  vy : Float,
  impact_kind : Int,
) -> Unit {
  if i < 0 || i >= game.pins.length() {
    return
  }

  if !game.pins[i].standing {
    return
  }

  game.pins[i].standing = false
  game.pins[i].vx = vx
  game.pins[i].vy = vy
  game.pins[i].ang_v = @types.randf(-7.0, 7.0)
  game.pins_left = game.count_standing()

  game.burst_sparks(game.pins[i].x, game.pins[i].y, 12, impact_kind)
  game.shake_t = @types.maxf(game.shake_t, 0.08)
}

///|
/// Launches the ball from the current aim and power settings; returns false when throwing is not allowed.
fn @types.Game::throw_ball(game : @types.Game) -> Bool {
  if game.state != Play || !game.can_throw {
    return false
  }

  let power_speed : Float = 520.0 + game.power * 780.0
  let angle : Float = @types.deg_to_rad(game.aim)

  game.ball_vx = @math.sinf(angle) * power_speed + game.spin * 96.0
  game.ball_vy = -@math.cosf(angle) * power_speed
  game.ball_spin = game.spin
  game.ball_live = true
  game.can_throw = false
  game.charging = false
  game.resolve_t = -1.0
  game.last_knock = 0

  game.set_message("Ball out", 0.7)
  game.burst_sparks(game.ball_x, game.ball_y, 14, 0)
  true
}

///|
/// Records a completed roll, updates frame progression and spare/strike counters, and prepares the next delivery.
fn @types.Game::on_roll_scored(game : @types.Game, knocked : Int) -> Unit {
  let k : Int = if knocked < 0 {
    0
  } else if knocked > game.pins_before_roll {
    game.pins_before_roll
  } else {
    knocked
  }

  game.push_roll(k)
  game.last_knock = k

  if game.frame < 9 {
    if game.roll_in_frame == 0 {
      game.first_roll = k
      if k == 10 {
        game.strikes = game.strikes + 1
        game.frame = game.frame + 1
        game.roll_in_frame = 0

        if game.frame >= 10 {
          game.finalize_match()
          return
        }

        game.prepare_roll(true)
        game.set_message("Strike! Frame \{game.frame + 1}", 1.3)
      } else {
        game.roll_in_frame = 1
        game.prepare_roll(false)
        game.set_message(
          "Frame \{game.frame + 1} roll 2: \{10 - k} pins left",
          1.2,
        )
      }
    } else {
      if game.first_roll + k == 10 {
        game.spares = game.spares + 1
        game.set_message("Spare!", 1.1)
      } else {
        game.opens = game.opens + 1
        game.set_message("Open frame", 1.0)
      }

      game.frame = game.frame + 1
      game.roll_in_frame = 0

      if game.frame >= 10 {
        game.finalize_match()
        return
      }

      game.prepare_roll(true)
      game.set_message("Frame \{game.frame + 1}", 1.0)
    }

    game.recompute_score()
    return
  }

  // Tenth frame handling.
  if game.roll_in_frame == 0 {
    game.first_roll = k

    if k == 10 {
      game.strikes = game.strikes + 1
      game.roll_in_frame = 1
      game.prepare_roll(true)
      game.set_message("10th frame strike, bonus balls", 1.4)
    } else {
      game.roll_in_frame = 1
      game.prepare_roll(false)
      game.set_message("10th frame roll 2", 1.1)
    }

    game.recompute_score()
    return
  }

  if game.roll_in_frame == 1 {
    if game.first_roll == 10 {
      if k == 10 {
        game.strikes = game.strikes + 1
        game.prepare_roll(true)
      } else {
        game.prepare_roll(false)
      }

      game.roll_in_frame = 2
      game.set_message("10th frame final ball", 1.1)
      game.recompute_score()
      return
    }

    if game.first_roll + k == 10 {
      game.spares = game.spares + 1
      game.roll_in_frame = 2
      game.prepare_roll(true)
      game.set_message("Spare! bonus ball", 1.3)
      game.recompute_score()
      return
    }

    game.opens = game.opens + 1
    game.finalize_match()
    return
  }

  game.finalize_match()
}

///|
/// Moves the live ball, applies spin drift and lane drag, and detects lane-edge and slow-stop conditions.
fn @types.Game::update_ball(game : @types.Game, dt : Float) -> Unit {
  if !game.ball_live {
    return
  }

  game.ball_x = game.ball_x + game.ball_vx * dt
  game.ball_y = game.ball_y + game.ball_vy * dt

  game.ball_vx = game.ball_vx + game.ball_spin * 44.0 * dt
  game.ball_vx = game.ball_vx * (1.0 - dt * 0.56)
  game.ball_vy = game.ball_vy * (1.0 - dt * 0.42)

  let min_x : Float = @types.lane_left + 28.0
  let max_x : Float = @types.lane_right - 28.0

  if game.ball_x < min_x {
    game.ball_x = min_x
    game.ball_vx = game.ball_vx.abs() * 0.76
    game.burst_sparks(game.ball_x, game.ball_y, 8, 2)
  } else if game.ball_x > max_x {
    game.ball_x = max_x
    game.ball_vx = -game.ball_vx.abs() * 0.76
    game.burst_sparks(game.ball_x, game.ball_y, 8, 2)
  }

  if game.ball_y < @types.lane_top + 40.0 {
    game.ball_live = false
    game.resolve_t = 0.42
  }

  let speed2 : Float = game.ball_vx * game.ball_vx + game.ball_vy * game.ball_vy
  if speed2 < 6400.0 && game.ball_y < @types.foul_line_y - 30.0 {
    game.ball_live = false
    game.resolve_t = 0.48
  }
}

///|
/// Tests the live ball against every standing pin and knocks any pin within collision range.
fn @types.Game::collide_ball_pins(game : @types.Game) -> Unit {
  if !game.ball_live {
    return
  }

  let hit_r : Float = @types.pin_radius + @types.ball_radius
  let hit_r2 : Float = hit_r * hit_r

  for i in 0..<game.pins.length() {
    if !game.pins[i].standing {
      continue
    }

    let d2 : Float = @types.dist2(
      game.ball_x,
      game.ball_y,
      game.pins[i].x,
      game.pins[i].y,
    )
    if d2 > hit_r2 {
      continue
    }

    let dx : Float = game.pins[i].x - game.ball_x
    let dy : Float = game.pins[i].y - game.ball_y
    let d : Float = d2.sqrt() + 0.0001

    let nx : Float = dx / d
    let ny : Float = dy / d
    let impulse : Float = @types.maxf(
      150.0,
      (game.ball_vx * game.ball_vx + game.ball_vy * game.ball_vy).sqrt(),
    )

    game.knock_pin(
      i,
      nx * impulse * 1.04 + @types.randf(-50.0, 50.0),
      ny * impulse * 1.04 + @types.randf(-40.0, 30.0),
      1,
    )

    game.ball_vx = game.ball_vx - nx * 95.0
    game.ball_vy = game.ball_vy - ny * 95.0
    game.ball_vx = game.ball_vx * 0.83
    game.ball_vy = game.ball_vy * 0.83
  }
}

///|
/// Integrates velocity and angular motion of knocked-down pins and clamps them within lane bounds.
fn @types.Game::update_pin_motion(game : @types.Game, dt : Float) -> Unit {
  for pin in game.pins {
    if pin.standing {
      continue
    }

    pin.x = pin.x + pin.vx * dt
    pin.y = pin.y + pin.vy * dt

    pin.vx = pin.vx * (1.0 - dt * 2.5)
    pin.vy = pin.vy * (1.0 - dt * 2.2) + dt * 160.0
    pin.ang = pin.ang + pin.ang_v * dt
    pin.ang_v = pin.ang_v * (1.0 - dt * 2.1)

    let min_x : Float = @types.lane_left + 20.0
    let max_x : Float = @types.lane_right - 20.0

    if pin.x < min_x {
      pin.x = min_x
      pin.vx = pin.vx.abs() * 0.48
    } else if pin.x > max_x {
      pin.x = max_x
      pin.vx = -pin.vx.abs() * 0.48
    }

    if pin.y < @types.lane_top + 12.0 {
      pin.y = @types.lane_top + 12.0
      pin.vy = pin.vy.abs() * 0.38
    }
    if pin.y > @types.lane_bottom - 6.0 {
      pin.y = @types.lane_bottom - 6.0
      pin.vy = -pin.vy.abs() * 0.28
    }
  }
}

///|
/// Propagates fast-moving knocked pins into nearby standing pins to simulate chain reactions.
fn @types.Game::chain_pin_hits(game : @types.Game) -> Unit {
  let hit : Float = @types.pin_radius * 2.0
  let hit2 : Float = hit * hit

  for i in 0..<game.pins.length() {
    if game.pins[i].standing {
      continue
    }

    let speed2 : Float = game.pins[i].vx * game.pins[i].vx +
      game.pins[i].vy * game.pins[i].vy
    if speed2 < 7800.0 {
      continue
    }

    for j in 0..<game.pins.length() {
      if i == j || !game.pins[j].standing {
        continue
      }

      let d2 : Float = @types.dist2(
        game.pins[i].x,
        game.pins[i].y,
        game.pins[j].x,
        game.pins[j].y,
      )
      if d2 > hit2 {
        continue
      }

      game.knock_pin(
        j,
        game.pins[i].vx * 0.62 + @types.randf(-32.0, 32.0),
        game.pins[i].vy * 0.62 + @types.randf(-28.0, 28.0),
        1,
      )
      game.pins[i].vx = game.pins[i].vx * 0.72
      game.pins[i].vy = game.pins[i].vy * 0.72
    }
  }
}

///|
/// Drives the full play-state simulation: timers, ball physics, collisions, and roll resolution.
fn @types.Game::update_play(game : @types.Game, dt : Float) -> Unit {
  game.game_t = game.game_t + dt
  game.ui_t = game.ui_t + dt

  if game.message_t > 0.0 {
    game.message_t = game.message_t - dt
  }
  if game.shake_t > 0.0 {
    game.shake_t = game.shake_t - dt
  }
  if game.touch_cd > 0.0 {
    game.touch_cd = game.touch_cd - dt
  }

  game.update_sparks(dt)
  game.update_ball(dt)
  game.collide_ball_pins()
  game.update_pin_motion(dt)
  game.chain_pin_hits()

  if game.ball_live {
    return
  }

  if game.resolve_t < 0.0 {
    game.resolve_t = 0.52
  }

  if game.resolve_t > 0.0 {
    game.resolve_t = game.resolve_t - dt
    return
  }

  if !game.pins_are_quiet() {
    return
  }

  let standing : Int = game.count_standing()
  let knocked : Int = game.pins_before_roll - standing
  game.on_roll_scored(knocked)
}

///|
/// Advances one frame of state updates, input, and bowling simulation.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  match game.state {
    Title => game.update_title_input()
    Play => {
      game.update_play_input(dt)
      game.update_play(dt)
    }
    Result => game.update_result_input()
  }
}
