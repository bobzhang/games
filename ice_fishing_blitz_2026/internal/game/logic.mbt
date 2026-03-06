///|
/// Deactivates all particles and zeroes their fields.
fn @types.Game::clear_particles(game : @types.Game) -> Unit {
  for particle in game.particles {
    particle.active = false
    particle.x = 0.0
    particle.y = 0.0
    particle.vx = 0.0
    particle.vy = 0.0
    particle.life = 0.0
    particle.size = 0.0
    particle.kind = Splash
  }
}

///|
/// Deactivates all fish, hazards, and pickups and zeroes their fields.
fn @types.Game::clear_world(game : @types.Game) -> Unit {
  for fish_elem in game.fish {
    fish_elem.active = false
    fish_elem.x = 0.0
    fish_elem.y = 0.0
    fish_elem.vx = 0.0
    fish_elem.vy = 0.0
    fish_elem.r = 0.0
    fish_elem.value = 0
    fish_elem.kind = Trout
    fish_elem.phase = 0.0
    fish_elem.hooked = false
  }

  for hazard in game.hazards {
    hazard.active = false
    hazard.x = 0.0
    hazard.y = 0.0
    hazard.vx = 0.0
    hazard.vy = 0.0
    hazard.r = 0.0
    hazard.dmg = 0.0
    hazard.kind = Jelly
    hazard.phase = 0.0
  }

  for pickup in game.pickups {
    pickup.active = false
    pickup.x = 0.0
    pickup.y = 0.0
    pickup.vx = 0.0
    pickup.vy = 0.0
    pickup.kind = Bait
    pickup.phase = 0.0
  }
}

///|
/// Emits one particle from the pool with the given position, velocity, lifetime, size, and kind.
fn @types.Game::emit_particle(
  game : @types.Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : @types.ParticleKind,
) -> Unit {
  for particle in game.particles {
    if particle.active {
      continue
    }

    particle.active = true
    particle.x = x
    particle.y = y
    particle.vx = vx
    particle.vy = vy
    particle.life = life
    particle.size = size
    particle.kind = kind
    break
  }
}

///|
/// Emits `n` particles from the pool scattered around `(x, y)` with the given kind.
fn @types.Game::burst(
  game : @types.Game,
  x : Float,
  y : Float,
  n : Int,
  kind : @types.ParticleKind,
) -> Unit {
  for _i in 0..<n {
    game.emit_particle(
      x + @types.randf(-14.0, 14.0),
      y + @types.randf(-14.0, 14.0),
      @types.randf(-220.0, 220.0),
      @types.randf(-220.0, 140.0),
      @types.randf(0.2, 1.0),
      @types.randf(1.2, 5.6),
      kind,
    )
  }
}

///|
/// Advances all active particles: move, apply drag and gravity, deactivate on expiry.
fn @types.Game::update_particles(game : @types.Game, dt : Float) -> Unit {
  for particle in game.particles {
    if !particle.active {
      continue
    }

    particle.life = particle.life - dt
    if particle.life <= 0.0 {
      particle.active = false
      continue
    }

    particle.x = particle.x + particle.vx * dt
    particle.y = particle.y + particle.vy * dt

    let drag : Float = if particle.kind == Shimmer { 2.6 } else { 1.9 }
    particle.vx = particle.vx * (1.0 - dt * drag)
    particle.vy = particle.vy * (1.0 - dt * (drag - 0.4)) +
      dt * (if particle.kind == Spark { 160.0 } else { 90.0 })
  }
}

///|
/// Resets the hook to the ice hole position with zeroed velocity and no carried fish.
fn @types.Game::reset_rig(game : @types.Game) -> Unit {
  game.hook_x = @types.hole_xf()
  game.hook_y = @types.topf() + 70.0
  game.hook_vx = 0.0
  game.hook_vy = 0.0
  game.line_len = 70.0
  game.move_x = 0.0
  game.move_y = 0.0
  game.grab_on = false
  game.carrying_idx = -1
}

///|
/// Resets the full game state and starts a new fishing run in the Play state.
fn @types.Game::start_run(game : @types.Game) -> Unit {
  game.clear_world()
  game.clear_particles()

  game.state = Play

  game.reset_rig()

  game.boost_on = false
  game.lives = 3
  game.line_hp = 100.0
  game.bait = 100.0
  game.turbo_t = 0.0
  game.repair_cd = 0.0

  game.score = 0
  game.caught = 0
  game.escaped = 0
  game.wave = 1
  game.combo = 0
  game.combo_t = 0.0

  game.fish_spawn_t = 0.6
  game.hazard_spawn_t = 0.25
  game.pickup_spawn_t = 1.4

  game.game_t = 0.0
  game.ui_t = 0.0

  game.hint_left = 3
  game.hint_t = 0.0
  game.hint_x = @types.hole_xf()
  game.hint_y = @types.topf() + 160.0

  game.msg = ""
  game.msg_t = 0.0
  game.shake_t = 0.0
  game.touch_cd = 0.0
  game.win = false

  @types.set_msg(game, "Catch fish and reel to top zone.", 2.6)
}

///|
/// Transitions the game to the Result state, recording win/loss and triggering burst effect.
fn @types.Game::finish_run(game : @types.Game, win : Bool) -> Unit {
  if game.state != Play {
    return
  }

  game.state = Result
  game.win = win

  game.move_x = 0.0
  game.move_y = 0.0
  game.boost_on = false
  game.grab_on = false

  if game.score > game.best_score {
    game.best_score = game.score
  }

  if win {
    @types.set_msg(game, "Festival haul complete!", 3.0)
    game.burst(@types.hole_xf(), @types.topf() + 18.0, 64, Shimmer)
  } else {
    @types.set_msg(game, "Ice line snapped. Mission over.", 3.0)
    game.burst(game.hook_x, game.hook_y, 50, Spark)
  }
}

///|
/// Spawns a fish of random kind and velocity from either side of the world; returns false if full.
fn @types.Game::spawn_fish(game : @types.Game) -> Bool {
  for fish_elem in game.fish {
    if fish_elem.active {
      continue
    }

    let roll : Int = @raylib.get_random_value(0, 99)
    let kind : @types.FishKind = if roll < 58 {
      Trout
    } else if roll < 90 {
      Salmon
    } else {
      Gold
    }

    let side : Int = @raylib.get_random_value(0, 1)
    if side == 0 {
      fish_elem.x = @types.world_left() + 20.0
      fish_elem.vx = @types.randf(60.0, 130.0)
    } else {
      fish_elem.x = @types.world_right() - 20.0
      fish_elem.vx = @types.randf(-130.0, -60.0)
    }

    fish_elem.y = @types.randf(@types.topf() + 90.0, @types.bottomf() - 40.0)
    fish_elem.vy = @types.randf(-36.0, 36.0)

    fish_elem.active = true
    fish_elem.kind = kind
    fish_elem.hooked = false
    fish_elem.phase = @types.randf(0.0, 6.28)

    match kind {
      Trout => {
        fish_elem.r = @types.randf(16.0, 22.0)
        fish_elem.value = @raylib.get_random_value(22, 35)
      }
      Salmon => {
        fish_elem.r = @types.randf(22.0, 28.0)
        fish_elem.value = @raylib.get_random_value(38, 56)
      }
      Gold => {
        fish_elem.r = @types.randf(14.0, 20.0)
        fish_elem.value = @raylib.get_random_value(70, 110)
      }
    }

    return true
  }

  false
}

///|
/// Spawns a hazard of random kind with appropriate starting position; returns false if full.
fn @types.Game::spawn_hazard(game : @types.Game) -> Bool {
  for hazard in game.hazards {
    if hazard.active {
      continue
    }

    let roll : Int = @raylib.get_random_value(0, 99)
    let kind : @types.HazardKind = if roll < 46 {
      Jelly
    } else if roll < 78 {
      Eel
    } else {
      Ice
    }

    hazard.active = true
    hazard.kind = kind
    hazard.phase = @types.randf(0.0, 6.28)

    match kind {
      Jelly => {
        hazard.x = @types.randf(
          @types.world_left() + 24.0,
          @types.world_right() - 24.0,
        )
        hazard.y = @types.topf() + @types.randf(80.0, 180.0)
        hazard.vx = @types.randf(-44.0, 44.0)
        hazard.vy = @types.randf(22.0, 80.0)
        hazard.r = @types.randf(26.0, 36.0)
        hazard.dmg = @types.randf(7.0, 12.0)
      }
      Eel => {
        hazard.x = @types.randf(
          @types.world_left() + 30.0,
          @types.world_right() - 30.0,
        )
        hazard.y = @types.bottomf() - @types.randf(50.0, 180.0)
        hazard.vx = @types.randf(-26.0, 26.0)
        hazard.vy = @types.randf(-22.0, 22.0)
        hazard.r = @types.randf(18.0, 24.0)
        hazard.dmg = @types.randf(10.0, 16.0)
      }
      Ice => {
        hazard.x = @types.randf(
          @types.world_left() + 20.0,
          @types.world_right() - 20.0,
        )
        hazard.y = @types.topf() + 10.0
        hazard.vx = @types.randf(-18.0, 18.0)
        hazard.vy = @types.randf(180.0, 280.0) +
          Float::from_int(game.wave) * 12.0
        hazard.r = @types.randf(12.0, 18.0)
        hazard.dmg = @types.randf(14.0, 24.0)
      }
    }

    return true
  }

  false
}

///|
/// Spawns a pickup of random kind at a random underwater position; returns false if full.
fn @types.Game::spawn_pickup(game : @types.Game) -> Bool {
  for pickup in game.pickups {
    if pickup.active {
      continue
    }

    pickup.active = true
    pickup.x = @types.randf(
      @types.world_left() + 24.0,
      @types.world_right() - 24.0,
    )
    pickup.y = @types.topf() + @types.randf(60.0, 240.0)
    pickup.vx = @types.randf(-42.0, 42.0)
    pickup.vy = @types.randf(-16.0, 40.0)
    pickup.phase = @types.randf(0.0, 6.28)

    let roll : Int = @raylib.get_random_value(0, 99)
    pickup.kind = if roll < 46 {
      Bait
    } else if roll < 80 {
      Repair
    } else {
      Thermos
    }

    return true
  }

  false
}

///|
/// Toggles grab-on state; only active during play; shows HUD message.
fn @types.Game::try_toggle_grab(game : @types.Game) -> Bool {
  if game.state != Play {
    return false
  }

  game.grab_on = !game.grab_on

  if game.grab_on {
    @types.set_msg(game, "Hook clamp ON.", 0.8)
  } else {
    @types.set_msg(game, "Hook clamp OFF.", 0.8)
  }

  true
}

///|
/// Attempts a line repair: requires hook near hole and sufficient bait; applies cost and heal.
fn @types.Game::try_repair(game : @types.Game) -> Bool {
  if game.state != Play {
    return false
  }
  if game.repair_cd > 0.0 {
    return false
  }

  if game.hook_y > @types.topf() + 86.0 {
    @types.set_msg(game, "Reel up near the ice hole to repair.", 1.0)
    game.repair_cd = 0.22
    return false
  }

  if game.bait < 8.0 {
    @types.set_msg(game, "Not enough bait energy.", 1.0)
    game.repair_cd = 0.22
    return false
  }

  game.bait = @types.maxf(0.0, game.bait - 8.0)
  game.line_hp = @types.minf(100.0, game.line_hp + 30.0)
  game.repair_cd = 1.1

  game.score = game.score + 12
  @types.set_msg(game, "Line repaired.", 1.0)
  game.burst(game.hook_x, game.hook_y, 20, Shimmer)

  true
}

///|
/// Drops the currently carried fish without scoring: marks it escaped, penalises score.
fn @types.Game::drop_carrying_fish(game : @types.Game) -> Unit {
  if game.carrying_idx < 0 || game.carrying_idx >= game.fish.length() {
    game.carrying_idx = -1
    return
  }

  let idx : Int = game.carrying_idx
  if game.fish[idx].active {
    game.fish[idx].hooked = false
    game.fish[idx].vx = @types.randf(-140.0, 140.0)
    game.fish[idx].vy = @types.randf(30.0, 120.0)

    game.escaped = game.escaped + 1
    game.score = (0).max(game.score - 14)
    @types.set_msg(game, "Fish slipped from hook.", 1.0)
  }

  game.carrying_idx = -1
}

///|
/// Lands the hooked fish into the catch zone: increments caught, combo, and score.
fn @types.Game::land_carrying_fish(game : @types.Game) -> Unit {
  if game.carrying_idx < 0 || game.carrying_idx >= game.fish.length() {
    game.carrying_idx = -1
    return
  }

  let idx : Int = game.carrying_idx
  if !game.fish[idx].active {
    game.carrying_idx = -1
    return
  }

  game.fish[idx].active = false
  game.fish[idx].hooked = false

  game.caught = game.caught + 1
  game.combo = (20).min(game.combo + 1)
  game.combo_t = 2.2

  let bonus : Int = game.fish[idx].value + game.combo * 2 + game.wave
  game.score = game.score + bonus
  if game.score > game.best_score {
    game.best_score = game.score
  }

  @types.set_msg(game, "Fish landed +" + bonus.to_string(), 1.1)
  game.burst(@types.hole_xf(), @types.hole_yf() + 20.0, 26, Shimmer)

  game.carrying_idx = -1
}

///|
/// Applies the effect of collecting a pickup item: bait, repair, or thermos bonus.
fn @types.Game::collect_pickup(
  game : @types.Game,
  kind : @types.PickupKind,
  x : Float,
  y : Float,
) -> Unit {
  match kind {
    Bait => {
      game.bait = @types.minf(100.0, game.bait + 34.0)
      game.score = game.score + 10
      @types.set_msg(game, "Bait crate collected.", 1.0)
      game.burst(x, y, 16, Splash)
    }
    Repair => {
      game.line_hp = @types.minf(100.0, game.line_hp + 26.0)
      game.score = game.score + 10
      @types.set_msg(game, "Line reinforced.", 1.0)
      game.burst(x, y, 16, Shimmer)
    }
    Thermos => {
      game.turbo_t = @types.maxf(game.turbo_t, 7.0)
      game.score = game.score + 16
      @types.set_msg(game, "Thermos boost activated.", 1.0)
      game.burst(x, y, 20, Shimmer)
    }
  }
}

///|
/// Returns the movement speed multiplier for a fish kind.
fn fish_speed_mul(kind : @types.FishKind) -> Float {
  match kind {
    Trout => 1.0
    Salmon => 0.84
    Gold => 1.16
  }
}

///|
/// Applies player input and ocean sway to the hook; enforces line length limit and emits wake particles.
fn @types.Game::update_hook(game : @types.Game, dt : Float) -> Unit {
  let boost_mul : Float = if game.boost_on || game.turbo_t > 0.0 {
    1.55
  } else {
    1.0
  }

  let sway_x : Float = @math.sinf(game.ui_t * 1.2 + game.hook_y * 0.008) *
    (22.0 + Float::from_int(game.wave) * 2.4)
  let sway_y : Float = @math.cosf(game.ui_t * 0.86 + game.hook_x * 0.006) * 16.0

  game.hook_vx = game.hook_vx + (game.move_x * 640.0 * boost_mul + sway_x) * dt
  game.hook_vy = game.hook_vy + (game.move_y * 620.0 * boost_mul + sway_y) * dt

  game.hook_vx = game.hook_vx * (1.0 - dt * 3.0)
  game.hook_vy = game.hook_vy * (1.0 - dt * 3.0)

  game.hook_x = game.hook_x + game.hook_vx * dt
  game.hook_y = game.hook_y + game.hook_vy * dt

  game.hook_x = @types.clampf(
    game.hook_x,
    @types.world_left() + 18.0,
    @types.world_right() - 18.0,
  )
  game.hook_y = @types.clampf(
    game.hook_y,
    @types.topf() + 20.0,
    @types.bottomf() - 12.0,
  )

  let line_raw : Float = (game.hook_y - @types.hole_yf()).abs() +
    (game.hook_x - @types.hole_xf()).abs() * 0.22
  game.line_len = @types.clampf(
    line_raw, @types.min_line_len, @types.max_line_len,
  )

  if line_raw > @types.max_line_len + 6.0 {
    let bias_x : Float = (@types.hole_xf() - game.hook_x) * dt * 8.0
    let bias_y : Float = (@types.hole_yf() + @types.max_line_len - game.hook_y) *
      dt *
      8.0
    game.hook_x = game.hook_x + bias_x
    game.hook_y = game.hook_y + bias_y
  }

  if game.boost_on || game.turbo_t > 0.0 {
    game.emit_particle(
      game.hook_x + @types.randf(-6.0, 6.0),
      game.hook_y + @types.randf(-6.0, 6.0),
      @types.randf(-40.0, 40.0),
      @types.randf(30.0, 100.0),
      @types.randf(0.18, 0.44),
      @types.randf(1.1, 3.0),
      Splash,
    )
  }
}

///|
/// Advances all active fish: follows hook if hooked, swims with sway, bounces off walls, detects hook collision.
fn @types.Game::update_fish(game : @types.Game, dt : Float) -> Unit {
  let mut active_count : Int = 0

  for i in 0..<game.fish.length() {
    if !game.fish[i].active {
      continue
    }

    active_count = active_count + 1

    if game.fish[i].hooked {
      game.fish[i].x = game.fish[i].x +
        (game.hook_x - game.fish[i].x) * @types.minf(1.0, dt * 12.0)
      game.fish[i].y = game.fish[i].y +
        (game.hook_y + 16.0 - game.fish[i].y) * @types.minf(1.0, dt * 12.0)
      game.fish[i].phase = game.fish[i].phase + dt * 8.0

      if @types.in_catch_zone(game.fish[i].x, game.fish[i].y) &&
        game.hook_y <= @types.topf() + 72.0 {
        game.land_carrying_fish()
      }

      continue
    }

    let kind_idx : Float = match game.fish[i].kind {
      Trout => 0.0
      Salmon => 1.0
      Gold => 2.0
    }
    game.fish[i].phase = game.fish[i].phase + dt * (1.6 + kind_idx * 0.7)

    let sw_x : Float = @math.sinf(game.fish[i].phase * 1.8) *
      40.0 *
      fish_speed_mul(game.fish[i].kind)
    let sw_y : Float = @math.cosf(game.fish[i].phase * 1.4) *
      22.0 *
      fish_speed_mul(game.fish[i].kind)

    game.fish[i].vx = game.fish[i].vx * (1.0 - dt * 1.8) + sw_x * dt
    game.fish[i].vy = game.fish[i].vy * (1.0 - dt * 1.8) + sw_y * dt

    game.fish[i].x = game.fish[i].x + game.fish[i].vx * dt
    game.fish[i].y = game.fish[i].y + game.fish[i].vy * dt

    if game.fish[i].x < @types.world_left() + game.fish[i].r {
      game.fish[i].x = @types.world_left() + game.fish[i].r
      game.fish[i].vx = game.fish[i].vx.abs() * 0.8
    }
    if game.fish[i].x > @types.world_right() - game.fish[i].r {
      game.fish[i].x = @types.world_right() - game.fish[i].r
      game.fish[i].vx = -game.fish[i].vx.abs() * 0.8
    }

    if game.fish[i].y < @types.topf() + game.fish[i].r + 20.0 {
      game.fish[i].y = @types.topf() + game.fish[i].r + 20.0
      game.fish[i].vy = game.fish[i].vy.abs() * 0.8
    }
    if game.fish[i].y > @types.bottomf() - game.fish[i].r - 8.0 {
      game.fish[i].y = @types.bottomf() - game.fish[i].r - 8.0
      game.fish[i].vy = -game.fish[i].vy.abs() * 0.8
    }

    let rr : Float = game.fish[i].r + @types.hook_r + 8.0
    if game.grab_on &&
      game.carrying_idx < 0 &&
      @types.dist2(game.fish[i].x, game.fish[i].y, game.hook_x, game.hook_y) <=
      rr * rr {
      game.fish[i].hooked = true
      game.carrying_idx = i
      game.grab_on = false
      @types.set_msg(game, "Fish hooked. Reel it up!", 1.1)
      game.burst(game.hook_x, game.hook_y, 14, Shimmer)
      continue
    }

    if game.fish[i].kind == Gold && @raylib.get_random_value(0, 999) < 2 {
      game.fish[i].active = false
      game.escaped = game.escaped + 1
    }
  }

  ignore(active_count)
}

///|
/// Advances all active hazards: applies kind-specific movement, bounces or despawns, applies line damage on hit.
fn @types.Game::update_hazards(game : @types.Game, dt : Float) -> Unit {
  for hazard in game.hazards {
    if !hazard.active {
      continue
    }

    let hkind_idx : Float = match hazard.kind {
      Jelly => 0.0
      Eel => 1.0
      Ice => 2.0
    }
    hazard.phase = hazard.phase + dt * (1.1 + hkind_idx * 0.9)

    match hazard.kind {
      Jelly => {
        hazard.vx = hazard.vx + @math.sinf(hazard.phase * 1.7) * dt * 72.0
        hazard.vy = hazard.vy + @math.cosf(hazard.phase * 1.3) * dt * 24.0
      }
      Eel => {
        let dx : Float = game.hook_x - hazard.x
        let dy : Float = game.hook_y - hazard.y
        let d : Float = dx.abs() + dy.abs()
        let nx : Float = if d <= 0.001 { 0.0 } else { dx / d }
        let ny : Float = if d <= 0.001 { 0.0 } else { dy / d }

        hazard.vx = hazard.vx * (1.0 - dt * 2.2) + nx * dt * 300.0
        hazard.vy = hazard.vy * (1.0 - dt * 2.2) + ny * dt * 300.0
      }
      Ice => {
        hazard.vx = hazard.vx + @math.sinf(hazard.phase * 2.5) * dt * 66.0
        hazard.vy = hazard.vy + dt * 44.0
      }
    }

    hazard.vx = @types.clampf(hazard.vx, -220.0, 220.0)
    hazard.vy = @types.clampf(hazard.vy, -220.0, 280.0)

    hazard.x = hazard.x + hazard.vx * dt
    hazard.y = hazard.y + hazard.vy * dt

    if hazard.kind == Ice && hazard.y > @types.bottomf() + 30.0 {
      hazard.active = false
      continue
    }

    if hazard.x < @types.world_left() - 60.0 ||
      hazard.x > @types.world_right() + 60.0 ||
      hazard.y < @types.topf() - 60.0 ||
      hazard.y > @types.bottomf() + 80.0 {
      hazard.active = false
      continue
    }

    let rr : Float = hazard.r + @types.hook_r
    if @types.dist2(hazard.x, hazard.y, game.hook_x, game.hook_y) <= rr * rr {
      game.line_hp = @types.maxf(0.0, game.line_hp - hazard.dmg)
      game.shake_t = @types.maxf(game.shake_t, 0.22)

      game.burst(game.hook_x, game.hook_y, 12, Spark)

      if hazard.kind == Ice {
        hazard.active = false
      } else {
        hazard.vx = -hazard.vx * 0.6
        hazard.vy = -hazard.vy * 0.6
      }

      if game.carrying_idx >= 0 && @raylib.get_random_value(0, 99) < 34 {
        game.drop_carrying_fish()
      }

      if game.line_hp <= 0.0 {
        return
      }
    }

    if hazard.kind == Eel &&
      game.carrying_idx >= 0 &&
      game.carrying_idx < game.fish.length() {
      let idx : Int = game.carrying_idx
      if game.fish[idx].active {
        let r2 : Float = hazard.r + game.fish[idx].r
        if @types.dist2(hazard.x, hazard.y, game.fish[idx].x, game.fish[idx].y) <=
          r2 * r2 {
          hazard.active = false
          game.drop_carrying_fish()
        }
      }
    }
  }
}

///|
/// Advances all active pickups: applies drift and wave motion, bounces off walls, detects hook collection.
fn @types.Game::update_pickups(game : @types.Game, dt : Float) -> Unit {
  for pickup in game.pickups {
    if !pickup.active {
      continue
    }

    pickup.phase = pickup.phase + dt * 2.3

    pickup.x = pickup.x +
      (pickup.vx + @math.sinf(pickup.phase * 2.0) * 20.0) * dt
    pickup.y = pickup.y +
      (pickup.vy + @math.cosf(pickup.phase * 1.3) * 18.0) * dt

    if pickup.x < @types.world_left() + 16.0 {
      pickup.x = @types.world_left() + 16.0
      pickup.vx = pickup.vx.abs() * 0.6
    }
    if pickup.x > @types.world_right() - 16.0 {
      pickup.x = @types.world_right() - 16.0
      pickup.vx = -pickup.vx.abs() * 0.6
    }

    if pickup.y < @types.topf() + 20.0 {
      pickup.y = @types.topf() + 20.0
      pickup.vy = pickup.vy.abs() * 0.6
    }
    if pickup.y > @types.bottomf() - 16.0 {
      pickup.y = @types.bottomf() - 16.0
      pickup.vy = -pickup.vy.abs() * 0.6
    }

    let rr : Float = @types.hook_r + 16.0
    if @types.dist2(game.hook_x, game.hook_y, pickup.x, pickup.y) <= rr * rr {
      let kind : @types.PickupKind = pickup.kind
      let px : Float = pickup.x
      let py : Float = pickup.y
      pickup.active = false
      game.collect_pickup(kind, px, py)
    }
  }
}

///|
/// Uses a hint charge to mark the nearest relevant target; costs one hint and deducts 5 score.
fn @types.Game::use_hint(game : @types.Game) -> Bool {
  if game.state != Play || game.hint_left <= 0 {
    return false
  }

  let mut hx : Float = @types.hole_xf()
  let mut hy : Float = @types.topf() + 120.0
  let mut text : String = "Hint: reel to catch zone."

  if game.carrying_idx >= 0 {
    hx = @types.hole_xf()
    hy = @types.topf() + 40.0
    text = "Hint: bring hooked fish up."
  } else if game.bait < 40.0 {
    let mut best_d2 : Float = 1000000000.0
    for pickup in game.pickups {
      if !pickup.active || pickup.kind != Bait {
        continue
      }

      let d2 : Float = @types.dist2(
        game.hook_x,
        game.hook_y,
        pickup.x,
        pickup.y,
      )

      if d2 < best_d2 {
        best_d2 = d2
        hx = pickup.x
        hy = pickup.y
        text = "Hint: bait crate marked."
      }
    }
  } else {
    let mut best_score : Int = -1
    let mut best_d2 : Float = 1000000000.0

    for fish_elem in game.fish {
      if !fish_elem.active || fish_elem.hooked {
        continue
      }

      let d2 : Float = @types.dist2(
        game.hook_x,
        game.hook_y,
        fish_elem.x,
        fish_elem.y,
      )

      if fish_elem.value > best_score ||
        (fish_elem.value == best_score && d2 < best_d2) {
        best_score = fish_elem.value
        best_d2 = d2
        hx = fish_elem.x
        hy = fish_elem.y
        text = "Hint: high-value fish marked."
      }
    }
  }

  game.hint_x = hx
  game.hint_y = hy
  game.hint_t = 2.8
  game.hint_left = game.hint_left - 1
  game.score = (0).max(game.score - 5)

  @types.set_msg(game, text, 1.3)

  true
}

///|
/// Runs one frame of play simulation: timers, spawning, hook/fish/hazard/pickup updates, win/loss checks.
fn @types.Game::update_play(game : @types.Game, dt : Float) -> Unit {
  let step : Float = @types.clampf(dt, 0.0, 0.04)

  game.ui_t = game.ui_t + step
  game.touch_cd = @types.maxf(0.0, game.touch_cd - step)
  game.msg_t = @types.maxf(0.0, game.msg_t - step)
  game.shake_t = @types.maxf(0.0, game.shake_t - step)
  game.hint_t = @types.maxf(0.0, game.hint_t - step)

  game.combo_t = @types.maxf(0.0, game.combo_t - step)
  if game.combo_t <= 0.0 {
    game.combo = 0
  }

  game.turbo_t = @types.maxf(0.0, game.turbo_t - step)
  game.repair_cd = @types.maxf(0.0, game.repair_cd - step)

  game.update_particles(step)

  if game.state != Play {
    return
  }

  game.game_t = game.game_t + step

  if game.score >= @types.score_goal {
    game.finish_run(true)
    return
  }

  if game.game_t >= @types.run_time_goal {
    game.finish_run(game.score >= @types.score_goal * 8 / 10)
    return
  }

  game.wave = (1 + (game.game_t / 22.0).to_int()).clamp(min=1, max=10)

  game.fish_spawn_t = game.fish_spawn_t + step
  let fish_interval : Float = @types.maxf(
    0.24,
    0.90 - Float::from_int(game.wave) * 0.05,
  )
  while game.fish_spawn_t >= fish_interval {
    game.fish_spawn_t = game.fish_spawn_t - fish_interval
    ignore(game.spawn_fish())
  }

  game.hazard_spawn_t = game.hazard_spawn_t + step
  let hazard_interval : Float = @types.maxf(
    0.34,
    0.98 - Float::from_int(game.wave) * 0.06,
  )
  while game.hazard_spawn_t >= hazard_interval {
    game.hazard_spawn_t = game.hazard_spawn_t - hazard_interval
    ignore(game.spawn_hazard())
  }

  game.pickup_spawn_t = game.pickup_spawn_t + step
  if game.pickup_spawn_t >= 3.1 {
    game.pickup_spawn_t = 0.0
    ignore(game.spawn_pickup())
  }

  game.update_hook(step)
  game.update_fish(step)
  game.update_hazards(step)
  if game.line_hp <= 0.0 {
    game.lives = game.lives - 1
    game.line_hp = 100.0
    game.bait = @types.maxf(0.0, game.bait - 14.0)

    game.drop_carrying_fish()
    game.reset_rig()

    @types.set_msg(game, "Line snapped. Life lost.", 1.4)
    game.burst(@types.hole_xf(), @types.topf() + 30.0, 30, Spark)

    if game.lives <= 0 {
      game.finish_run(false)
      return
    }
  }

  game.update_pickups(step)

  let drain : Float = if game.boost_on || game.turbo_t > 0.0 {
    2.5 + Float::from_int(game.wave) * 0.10
  } else {
    1.0 + Float::from_int(game.wave) * 0.07
  }

  game.bait = @types.maxf(0.0, game.bait - drain * step)

  if game.bait <= 0.0 {
    game.line_hp = @types.maxf(0.0, game.line_hp - step * 6.0)
  }

  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
/// Advances one frame of fishing simulation, input, and state flow.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.mouse_x = @raylib.get_mouse_x() |> Float::from_int
  game.mouse_y = @raylib.get_mouse_y() |> Float::from_int
  game.touch_count = @raylib.get_touch_point_count()
  game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
    game.touch_count > 0

  match game.state {
    Title => {
      game.update_title_input()
      game.update_play(dt)
    }
    Play => {
      game.update_play_input(dt)
      game.update_play(dt)
    }
    Result => {
      game.update_result_input()
      game.update_play(dt)
    }
  }
}
