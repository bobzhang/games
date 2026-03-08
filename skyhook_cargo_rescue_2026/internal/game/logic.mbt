///|
fn @types.Game::set_msg(game : @types.Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
}

///|
fn @types.Game::clear_particles(game : @types.Game) -> Unit {
  for particle in game.particles {
    particle.active = false
    particle.x = 0.0
    particle.y = 0.0
    particle.vx = 0.0
    particle.vy = 0.0
    particle.life = 0.0
    particle.size = 0.0
    particle.kind = 0
  }
}

///|
fn @types.Game::clear_world(game : @types.Game) -> Unit {
  for survivor in game.survivors {
    survivor.active = false
    survivor.x = 0.0
    survivor.y = 0.0
    survivor.vx = 0.0
    survivor.vy = 0.0
    survivor.carried = false
    survivor.panic = 0.0
    survivor.phase = 0.0
  }

  for hazard in game.hazards {
    hazard.active = false
    hazard.x = 0.0
    hazard.y = 0.0
    hazard.vx = 0.0
    hazard.vy = 0.0
    hazard.r = 0.0
    hazard.hp = 0.0
    hazard.kind = Cloud
    hazard.phase = 0.0
  }

  for pickup in game.pickups {
    pickup.active = false
    pickup.x = 0.0
    pickup.y = 0.0
    pickup.vx = 0.0
    pickup.vy = 0.0
    pickup.kind = Fuel
    pickup.phase = 0.0
  }
}

///|
fn @types.Game::emit_particle(
  game : @types.Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : Int,
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
fn @types.Game::burst(
  game : @types.Game,
  x : Float,
  y : Float,
  n : Int,
  kind : Int,
) -> Unit {
  for _i in 0..<n {
    game.emit_particle(
      x + @types.randf(-14.0, 14.0),
      y + @types.randf(-14.0, 14.0),
      @types.randf(-260.0, 260.0),
      @types.randf(-220.0, 160.0),
      @types.randf(0.22, 1.1),
      @types.randf(1.2, 5.8),
      kind,
    )
  }
}

///|
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

    let damp : Float = if particle.kind == 2 { 2.8 } else { 1.9 }
    particle.vx = particle.vx * (1.0 - dt * damp)
    particle.vy = particle.vy * (1.0 - dt * (damp - 0.4)) +
      dt * (if particle.kind == 1 { 180.0 } else { 110.0 })
  }
}

///|
fn @types.Game::reset_heli(game : @types.Game) -> Unit {
  game.heli_x = Float::from_int(@types.world_x0 + @types.world_w / 2)
  game.heli_y = Float::from_int(@types.world_y0 + @types.world_h - 220)
  game.heli_vx = 0.0
  game.heli_vy = 0.0
  game.move_x = 0.0
  game.move_y = 0.0

  game.hook_len = 46.0
  game.hook_target = 46.0
  game.hook_extending = false
  game.carrying_idx = -1
}

///|
fn @types.Game::start_run(game : @types.Game) -> Unit {
  game.clear_world()
  game.clear_particles()

  game.state = Play

  game.reset_heli()

  game.boost_on = false
  game.lives = 3
  game.hull = 100.0
  game.fuel = 100.0
  game.turbo_t = 0.0
  game.repair_cd = 0.0

  game.score = 0
  game.rescued = 0
  game.lost = 0
  game.wave = 1
  game.combo = 0
  game.combo_t = 0.0

  game.survivor_spawn_t = 0.55
  game.hazard_spawn_t = 0.35
  game.pickup_spawn_t = 1.2
  game.storm_t = 0.0

  game.game_t = 0.0
  game.ui_t = 0.0
  game.touch_cd = 0.0

  game.hint_left = 3
  game.hint_t = 0.0
  game.hint_x = @types.safe_cx()
  game.hint_y = @types.safe_cy()

  game.msg = ""
  game.msg_t = 0.0
  game.shake_t = 0.0
  game.win = false

  game.set_msg("Rescue 18 survivors with the skyhook.", 2.8)
}

///|
fn @types.Game::finish_run(game : @types.Game, win : Bool) -> Unit {
  if game.state != Play {
    return
  }

  game.state = Result
  game.win = win

  game.move_x = 0.0
  game.move_y = 0.0
  game.boost_on = false

  if game.score > game.best_score {
    game.best_score = game.score
  }

  if win {
    game.set_msg("All priority civilians extracted.", 3.0)
    game.burst(@types.safe_cx(), @types.safe_cy(), 70, 2)
  } else {
    game.set_msg("Rescue mission failed in storm zone.", 3.0)
    game.burst(game.heli_x, game.heli_y, 56, 1)
  }
}

///|
fn @types.Game::spawn_survivor(game : @types.Game) -> Bool {
  for survivor in game.survivors {
    if survivor.active {
      continue
    }

    survivor.active = true
    survivor.carried = false

    let lane : Int = @raylib.get_random_value(0, 4)
    survivor.x = @types.world_left() +
      110.0 +
      Float::from_int(lane) * (Float::from_int(@types.world_w) - 220.0) / 4.0 +
      @types.randf(-40.0, 40.0)
    survivor.y = @types.world_bottom() - @types.randf(70.0, 130.0)

    survivor.vx = @types.randf(-18.0, 18.0)
    survivor.vy = @types.randf(-8.0, 8.0)
    survivor.panic = @types.randf(0.0, 1.0)
    survivor.phase = @types.randf(0.0, 6.28)

    return true
  }

  false
}

///|
fn @types.Game::spawn_hazard(game : @types.Game) -> Bool {
  for hazard in game.hazards {
    if hazard.active {
      continue
    }

    let roll : Int = @raylib.get_random_value(0, 99)
    let kind : @types.HazardKind = if roll < 52 {
      Cloud
    } else if roll < 82 {
      Drone
    } else {
      Ice
    }

    let side : Int = @raylib.get_random_value(0, 2)
    if side == 0 {
      hazard.x = @types.randf(
        @types.world_left() + 30.0,
        @types.world_right() - 30.0,
      )
      hazard.y = @types.world_top() - 60.0
    } else if side == 1 {
      hazard.x = @types.world_left() - 60.0
      hazard.y = @types.randf(
        @types.world_top() + 30.0,
        @types.world_bottom() - 30.0,
      )
    } else {
      hazard.x = @types.world_right() + 60.0
      hazard.y = @types.randf(
        @types.world_top() + 30.0,
        @types.world_bottom() - 30.0,
      )
    }

    hazard.active = true
    hazard.kind = kind
    hazard.phase = @types.randf(0.0, 6.28)

    match kind {
      Cloud => {
        hazard.r = @types.randf(32.0, 46.0)
        hazard.hp = @types.randf(20.0, 28.0)
        hazard.vx = @types.randf(-58.0, 58.0)
        hazard.vy = @types.randf(48.0, 96.0) + Float::from_int(game.wave) * 6.0
      }
      Drone => {
        hazard.r = @types.randf(20.0, 28.0)
        hazard.hp = @types.randf(34.0, 44.0)
        hazard.vx = @types.randf(-24.0, 24.0)
        hazard.vy = @types.randf(-24.0, 24.0)
      }
      Ice => {
        hazard.r = @types.randf(16.0, 22.0)
        hazard.hp = @types.randf(12.0, 18.0)
        hazard.vx = @types.randf(-34.0, 34.0)
        hazard.vy = @types.randf(160.0, 240.0) +
          Float::from_int(game.wave) * 14.0
      }
    }

    return true
  }

  false
}

///|
fn @types.Game::spawn_pickup(game : @types.Game) -> Bool {
  for pickup in game.pickups {
    if pickup.active {
      continue
    }

    pickup.active = true
    pickup.x = @types.randf(
      @types.world_left() + 26.0,
      @types.world_right() - 26.0,
    )
    pickup.y = @types.world_top() - @types.randf(40.0, 240.0)
    pickup.vx = @types.randf(-40.0, 40.0)
    pickup.vy = @types.randf(100.0, 160.0)
    pickup.phase = @types.randf(0.0, 6.28)

    let roll : Int = @raylib.get_random_value(0, 99)
    pickup.kind = if roll < 52 {
      Fuel
    } else if roll < 82 {
      Medkit
    } else {
      Turbo
    }

    return true
  }

  false
}

///|
fn @types.Game::count_active_survivors(game : @types.Game) -> Int {
  @utils.count_by(game.survivors, fn(survivor) { survivor.active })
}

///|
fn @types.Game::try_toggle_hook(game : @types.Game) -> Bool {
  if game.state != Play {
    return false
  }

  game.hook_extending = !game.hook_extending
  game.hook_target = if game.hook_extending { 240.0 } else { 46.0 }

  if game.hook_extending {
    game.set_msg("Hook extending.", 0.8)
  } else {
    game.set_msg("Hook retracting.", 0.8)
  }

  true
}

///|
fn @types.Game::try_repair(game : @types.Game) -> Bool {
  if game.state != Play {
    return false
  }
  if game.repair_cd > 0.0 {
    return false
  }

  let near_pad : Bool = @types.dist2(
      game.heli_x,
      game.heli_y,
      @types.safe_cx(),
      @types.safe_cy(),
    ) <=
    180.0 * 180.0

  if !near_pad {
    game.set_msg("Return to rescue pad for repair.", 1.0)
    game.repair_cd = 0.22
    return false
  }

  if game.fuel < 8.0 {
    game.set_msg("Not enough fuel for field repair.", 1.0)
    game.repair_cd = 0.22
    return false
  }

  game.fuel = @types.maxf(0.0, game.fuel - 8.0)
  game.hull = @types.minf(100.0, game.hull + 32.0)
  game.repair_cd = 1.1

  game.score = game.score + 14
  game.set_msg("Repair complete.", 1.1)
  game.burst(game.heli_x, game.heli_y, 24, 2)

  true
}

///|
fn @types.Game::hurt_heli(game : @types.Game, dmg : Float) -> Unit {
  game.hull = game.hull - dmg
  game.combo = 0
  game.combo_t = 0.0
  game.shake_t = @types.maxf(game.shake_t, 0.26)

  if game.hull <= 0.0 {
    game.lives = game.lives - 1
    game.hull = 100.0
    game.fuel = @types.maxf(0.0, game.fuel - 16.0)

    game.reset_heli()
    game.set_msg("Helicopter downed. Life lost.", 1.6)
    game.burst(game.heli_x, game.heli_y, 34, 1)

    if game.lives <= 0 {
      game.finish_run(false)
    }
  } else {
    game.burst(game.heli_x, game.heli_y, 14, 1)
  }
}

///|
fn @types.Game::drop_carried_survivor(game : @types.Game) -> Unit {
  if game.carrying_idx < 0 || game.carrying_idx >= game.survivors.length() {
    game.carrying_idx = -1
    return
  }

  let idx : Int = game.carrying_idx
  if game.survivors[idx].active {
    game.survivors[idx].active = false
    game.survivors[idx].carried = false
    game.lost = game.lost + 1
    game.score = (0).max(game.score - 18)
    game.set_msg("Passenger lost in storm.", 1.3)
    game.burst(game.survivors[idx].x, game.survivors[idx].y, 22, 1)
  }

  game.carrying_idx = -1
  game.hook_extending = false
  game.hook_target = 46.0
}

///|
fn @types.Game::rescue_carried_survivor(game : @types.Game) -> Unit {
  if game.carrying_idx < 0 || game.carrying_idx >= game.survivors.length() {
    game.carrying_idx = -1
    return
  }

  let idx : Int = game.carrying_idx
  if game.survivors[idx].active {
    game.survivors[idx].active = false
    game.survivors[idx].carried = false

    game.rescued = game.rescued + 1
    game.combo = (15).min(game.combo + 1)
    game.combo_t = 2.3

    let bonus : Int = 24 + game.wave + game.combo * 2
    game.score = game.score + bonus

    if game.score > game.best_score {
      game.best_score = game.score
    }

    game.set_msg("Civilian delivered +" + bonus.to_string(), 1.1)
    game.burst(@types.safe_cx(), @types.safe_cy(), 28, 2)
  }

  game.carrying_idx = -1
  game.hook_extending = false
  game.hook_target = 46.0
}

///|
fn @types.Game::collect_pickup(
  game : @types.Game,
  kind : @types.PickupKind,
  x : Float,
  y : Float,
) -> Unit {
  match kind {
    Fuel => {
      game.fuel = @types.minf(100.0, game.fuel + 30.0)
      game.score = game.score + 10
      game.set_msg("Fuel pod collected.", 1.0)
      game.burst(x, y, 18, 0)
    }
    Medkit => {
      game.hull = @types.minf(100.0, game.hull + 28.0)
      game.score = game.score + 10
      game.set_msg("Hull repairs online.", 1.0)
      game.burst(x, y, 18, 2)
    }
    Turbo => {
      game.turbo_t = @types.maxf(game.turbo_t, 7.0)
      game.score = game.score + 16
      game.set_msg("Turbo rotor boost ready.", 1.0)
      game.burst(x, y, 20, 2)
    }
  }
}

///|
fn @types.Game::update_heli(game : @types.Game, dt : Float) -> Unit {
  let wind_x : Float = @math.sinf(game.storm_t * 0.82 + game.heli_y * 0.010) *
    (52.0 + Float::from_int(game.wave) * 6.0)
  let wind_y : Float = @math.cosf(game.storm_t * 0.64 + game.heli_x * 0.008) *
    26.0

  let boost_mul : Float = if game.boost_on || game.turbo_t > 0.0 {
    1.45
  } else {
    1.0
  }

  game.heli_vx = game.heli_vx + (game.move_x * 720.0 * boost_mul + wind_x) * dt
  game.heli_vy = game.heli_vy + (game.move_y * 680.0 * boost_mul + wind_y) * dt

  game.heli_vx = game.heli_vx * (1.0 - dt * 3.0)
  game.heli_vy = game.heli_vy * (1.0 - dt * 3.0)

  game.heli_x = game.heli_x + game.heli_vx * dt
  game.heli_y = game.heli_y + game.heli_vy * dt

  let left : Float = @types.world_left() + @types.heli_r + 8.0
  let right : Float = @types.world_right() - @types.heli_r - 8.0
  let top : Float = @types.world_top() + @types.heli_r + 8.0
  let bottom : Float = @types.world_bottom() - @types.heli_r - 8.0

  if game.heli_x < left {
    game.heli_x = left
    game.heli_vx = game.heli_vx.abs() * 0.24
  } else if game.heli_x > right {
    game.heli_x = right
    game.heli_vx = -game.heli_vx.abs() * 0.24
  }

  if game.heli_y < top {
    game.heli_y = top
    game.heli_vy = game.heli_vy.abs() * 0.24
  } else if game.heli_y > bottom {
    game.heli_y = bottom
    game.heli_vy = -game.heli_vy.abs() * 0.24
  }

  if game.boost_on || game.turbo_t > 0.0 {
    game.emit_particle(
      game.heli_x + @types.randf(-8.0, 8.0),
      game.heli_y + @types.randf(14.0, 22.0),
      @types.randf(-40.0, 40.0),
      @types.randf(30.0, 110.0),
      @types.randf(0.18, 0.44),
      @types.randf(1.2, 3.6),
      0,
    )
  }
}

///|
fn @types.Game::update_hook(game : @types.Game, dt : Float) -> Float {
  let old_len : Float = game.hook_len

  if game.hook_extending {
    game.hook_target = 240.0
  } else {
    game.hook_target = 46.0
  }

  if game.hook_len < game.hook_target {
    game.hook_len = @types.minf(game.hook_target, game.hook_len + dt * 520.0)
  } else {
    game.hook_len = @types.maxf(game.hook_target, game.hook_len - dt * 580.0)
  }

  let tip_x : Float = @types.hook_tip_x(game)
  let tip_y : Float = @types.hook_tip_y(game)

  if game.carrying_idx < 0 && game.hook_len > 82.0 {
    for i in 0..<game.survivors.length() {
      if !game.survivors[i].active || game.survivors[i].carried {
        continue
      }

      let rr : Float = @types.survivor_r + 16.0
      if @types.dist2(tip_x, tip_y, game.survivors[i].x, game.survivors[i].y) <=
        rr * rr {
        game.carrying_idx = i
        game.survivors[i].carried = true
        game.survivors[i].panic = 0.0
        game.set_msg("Passenger latched.", 0.9)
        game.burst(tip_x, tip_y, 16, 2)
        break
      }
    }
  }

  if game.carrying_idx >= 0 && game.carrying_idx < game.survivors.length() {
    let idx : Int = game.carrying_idx

    if game.survivors[idx].active {
      game.survivors[idx].x = game.survivors[idx].x +
        (tip_x - game.survivors[idx].x) * @types.minf(1.0, dt * 12.0)
      game.survivors[idx].y = game.survivors[idx].y +
        (tip_y - game.survivors[idx].y) * @types.minf(1.0, dt * 12.0)

      game.survivors[idx].vx = 0.0
      game.survivors[idx].vy = 0.0
      game.survivors[idx].phase = game.survivors[idx].phase + dt * 6.0

      if game.hook_len <= 64.0 &&
        @types.inside_safe_zone(game.survivors[idx].x, game.survivors[idx].y) {
        game.rescue_carried_survivor()
      }
    } else {
      game.carrying_idx = -1
    }
  }

  (game.hook_len - old_len).abs() / @types.maxf(0.0001, dt)
}

///|
fn @types.Game::update_survivors(game : @types.Game, dt : Float) -> Unit {
  for survivor in game.survivors {
    if !survivor.active {
      continue
    }

    if survivor.carried {
      continue
    }

    survivor.phase = survivor.phase + dt * 1.7
    survivor.panic = @types.minf(4.0, survivor.panic + dt * 0.18)

    let drift_x : Float = @math.sinf(survivor.phase * 2.2) *
      (10.0 + survivor.panic * 3.0)
    let drift_y : Float = @math.cosf(survivor.phase * 1.9) *
      (6.0 + survivor.panic * 2.0)

    survivor.vx = survivor.vx * (1.0 - dt * 2.0) + drift_x * dt
    survivor.vy = survivor.vy * (1.0 - dt * 2.0) + drift_y * dt

    survivor.x = survivor.x + survivor.vx * dt
    survivor.y = survivor.y + survivor.vy * dt

    survivor.x = @types.clampf(
      survivor.x,
      @types.world_left() + @types.survivor_r + 10.0,
      @types.world_right() - @types.survivor_r - 10.0,
    )
    survivor.y = @types.clampf(
      survivor.y,
      @types.world_top() + @types.survivor_r + 14.0,
      @types.world_bottom() - @types.survivor_r - 12.0,
    )

    let near_hazard : Bool = false
    ignore(near_hazard)

    if @types.dist2(survivor.x, survivor.y, @types.safe_cx(), @types.safe_cy()) <
      86.0 * 86.0 {
      survivor.panic = @types.maxf(0.0, survivor.panic - dt * 0.5)
    }
  }
}

///|
fn hazard_damage(kind : @types.HazardKind) -> Float {
  match kind {
    Drone => 24.0
    Cloud => 16.0
    Ice => 20.0
  }
}

///|
fn @types.Game::update_hazards(
  game : @types.Game,
  dt : Float,
  hook_speed : Float,
) -> Unit {
  let tip_x : Float = @types.hook_tip_x(game)
  let tip_y : Float = @types.hook_tip_y(game)

  for hazard in game.hazards {
    if !hazard.active {
      continue
    }

    let kind_f : Float = match hazard.kind {
      Cloud => 0.0
      Drone => 1.0
      Ice => 2.0
    }
    hazard.phase = hazard.phase + dt * (1.0 + kind_f * 0.8)

    match hazard.kind {
      Cloud => {
        hazard.vx = hazard.vx + @math.sinf(hazard.phase * 1.4) * dt * 80.0
        hazard.vy = hazard.vy + dt * 24.0
      }
      Drone => {
        let tx : Float = if game.carrying_idx >= 0 {
          tip_x
        } else {
          game.heli_x
        }
        let ty : Float = if game.carrying_idx >= 0 {
          tip_y
        } else {
          game.heli_y
        }

        let dx : Float = tx - hazard.x
        let dy : Float = ty - hazard.y

        let w : Float = dx.abs() + dy.abs()
        let nx : Float = if w <= 0.001 { 0.0 } else { dx / w }
        let ny : Float = if w <= 0.001 { 0.0 } else { dy / w }

        hazard.vx = hazard.vx * (1.0 - dt * 2.4) + nx * dt * 420.0
        hazard.vy = hazard.vy * (1.0 - dt * 2.4) + ny * dt * 420.0
      }
      Ice => {
        hazard.vx = hazard.vx + @math.sinf(hazard.phase * 3.0) * dt * 96.0
        hazard.vy = hazard.vy + dt * 54.0
      }
    }

    hazard.vx = @types.clampf(hazard.vx, -260.0, 260.0)
    hazard.vy = @types.clampf(hazard.vy, -220.0, 300.0)

    hazard.x = hazard.x + hazard.vx * dt
    hazard.y = hazard.y + hazard.vy * dt

    if hazard.x < @types.world_left() - 120.0 ||
      hazard.x > @types.world_right() + 120.0 ||
      hazard.y < @types.world_top() - 120.0 ||
      hazard.y > @types.world_bottom() + 120.0 {
      hazard.active = false
      continue
    }

    let rr_heli : Float = hazard.r + @types.heli_r - 4.0
    if @types.dist2(hazard.x, hazard.y, game.heli_x, game.heli_y) <=
      rr_heli * rr_heli {
      game.hurt_heli(hazard_damage(hazard.kind))
      hazard.active = false
      if game.state != Play {
        return
      }
      continue
    }

    if game.carrying_idx >= 0 && game.carrying_idx < game.survivors.length() {
      let idx : Int = game.carrying_idx
      if game.survivors[idx].active {
        let rr_car : Float = hazard.r + @types.survivor_r
        if @types.dist2(
            hazard.x,
            hazard.y,
            game.survivors[idx].x,
            game.survivors[idx].y,
          ) <=
          rr_car * rr_car {
          hazard.active = false
          game.drop_carried_survivor()
          continue
        }
      }
    }

    let rr_hook : Float = hazard.r + 12.0
    if hook_speed > 260.0 &&
      @types.dist2(hazard.x, hazard.y, tip_x, tip_y) <= rr_hook * rr_hook {
      let dmg : Float = if hook_speed > 460.0 { 34.0 } else { 18.0 }
      hazard.hp = hazard.hp - dmg

      game.burst(hazard.x, hazard.y, 14, 0)

      if hazard.hp <= 0.0 {
        hazard.active = false
        game.score = game.score + 8 + game.wave
      }
    }
  }
}

///|
fn @types.Game::update_pickups(game : @types.Game, dt : Float) -> Unit {
  for pickup in game.pickups {
    if !pickup.active {
      continue
    }

    pickup.phase = pickup.phase + dt * 2.2

    pickup.x = pickup.x +
      (pickup.vx + @math.sinf(pickup.phase * 2.3) * 20.0) * dt
    pickup.y = pickup.y + (pickup.vy + Float::from_int(game.wave) * 4.0) * dt

    if pickup.x < @types.world_left() + 16.0 {
      pickup.x = @types.world_left() + 16.0
      pickup.vx = pickup.vx.abs() * 0.6
    }
    if pickup.x > @types.world_right() - 16.0 {
      pickup.x = @types.world_right() - 16.0
      pickup.vx = -pickup.vx.abs() * 0.6
    }

    if pickup.y > @types.world_bottom() + 80.0 {
      pickup.active = false
      continue
    }

    let rr : Float = @types.heli_r + 16.0
    if @types.dist2(game.heli_x, game.heli_y, pickup.x, pickup.y) <= rr * rr {
      let kind : @types.PickupKind = pickup.kind
      let px : Float = pickup.x
      let py : Float = pickup.y
      pickup.active = false
      game.collect_pickup(kind, px, py)
    }
  }
}

///|
fn @types.Game::use_hint(game : @types.Game) -> Bool {
  if game.state != Play || game.hint_left <= 0 {
    return false
  }

  let mut hx : Float = @types.safe_cx()
  let mut hy : Float = @types.safe_cy()
  let mut msg : String = "Hint: deliver to safe zone."

  if game.carrying_idx >= 0 && game.carrying_idx < game.survivors.length() {
    hx = @types.safe_cx()
    hy = @types.safe_cy()
    msg = "Hint: retract hook inside safe zone."
  } else {
    let mut best_d2 : Float = 1000000000.0

    if game.fuel < 40.0 {
      for pickup in game.pickups {
        if !pickup.active || pickup.kind != Fuel {
          continue
        }

        let d2 : Float = @types.dist2(
          game.heli_x,
          game.heli_y,
          pickup.x,
          pickup.y,
        )

        if d2 < best_d2 {
          best_d2 = d2
          hx = pickup.x
          hy = pickup.y
          msg = "Hint: fuel canister marked."
        }
      }
    }

    if best_d2 >= 900000000.0 {
      for survivor in game.survivors {
        if !survivor.active || survivor.carried {
          continue
        }

        let d2 : Float = @types.dist2(
          game.heli_x,
          game.heli_y,
          survivor.x,
          survivor.y,
        )

        if d2 < best_d2 {
          best_d2 = d2
          hx = survivor.x
          hy = survivor.y
          msg = "Hint: nearest civilian marked."
        }
      }
    }
  }

  game.hint_x = hx
  game.hint_y = hy
  game.hint_t = 2.8
  game.hint_left = game.hint_left - 1
  game.score = (0).max(game.score - 5)

  game.set_msg(msg, 1.3)

  true
}

///|
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
  game.storm_t = game.storm_t + step

  if game.rescued >= @types.rescue_target {
    game.finish_run(true)
    return
  }

  if game.game_t >= @types.run_time_goal {
    game.finish_run(false)
    return
  }

  game.wave = (1 + (game.game_t / 24.0).to_int()).clamp(min=1, max=10)

  game.survivor_spawn_t = game.survivor_spawn_t + step
  let spawn_survivor_every : Float = @types.maxf(
    1.1,
    2.5 - Float::from_int(game.wave) * 0.12,
  )
  if game.survivor_spawn_t >= spawn_survivor_every {
    game.survivor_spawn_t = game.survivor_spawn_t - spawn_survivor_every
    if game.count_active_survivors() < 9 {
      ignore(game.spawn_survivor())
    }
  }

  game.hazard_spawn_t = game.hazard_spawn_t + step
  let spawn_hazard_every : Float = @types.maxf(
    0.26,
    0.74 - Float::from_int(game.wave) * 0.04,
  )
  while game.hazard_spawn_t >= spawn_hazard_every {
    game.hazard_spawn_t = game.hazard_spawn_t - spawn_hazard_every
    ignore(game.spawn_hazard())
  }

  game.pickup_spawn_t = game.pickup_spawn_t + step
  if game.pickup_spawn_t >= 3.0 {
    game.pickup_spawn_t = 0.0
    ignore(game.spawn_pickup())
  }

  game.update_heli(step)
  let hook_speed : Float = game.update_hook(step)
  game.update_survivors(step)
  game.update_hazards(step, hook_speed)
  if game.state != Play {
    return
  }
  game.update_pickups(step)

  let fuel_drain : Float = if game.boost_on || game.turbo_t > 0.0 {
    2.7 + Float::from_int(game.wave) * 0.12
  } else {
    1.2 + Float::from_int(game.wave) * 0.08
  }

  game.fuel = @types.maxf(0.0, game.fuel - fuel_drain * step)

  if game.fuel <= 0.0 {
    game.hull = @types.maxf(0.0, game.hull - step * 7.0)
  }

  if game.hull <= 0.0 {
    game.hurt_heli(100.0)
    if game.state != Play {
      return
    }
  }

  if game.lives <= 0 {
    game.finish_run(false)
    return
  }

  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
/// Advances one frame of rescue gameplay, input processing, and state flow.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  // Update mouse/touch state
  game.mouse_x = @raylib.get_mouse_x() |> Float::from_int
  game.mouse_y = @raylib.get_mouse_y() |> Float::from_int
  game.touch_count = @raylib.get_touch_point_count()
  game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
    game.touch_count > 0

  // Handle input based on state
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
