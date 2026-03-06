///|
/// Deactivates all enemy/pickup object slots and resets every field to its zero value.
fn @types.Game::clear_objs(game : @types.Game) -> Unit {
  for obj in game.objs {
    obj.active = false
    obj.kind = Scout
    obj.x = 0.0
    obj.y = 0.0
    obj.vx = 0.0
    obj.vy = 0.0
    obj.w = 0.0
    obj.h = 0.0
    obj.hp = 0.0
    obj.shot_cd = 0.0
    obj.spin = 0.0
    obj.cloak = false
    obj.reward = 0
  }
}

///|
/// Deactivates all projectile slots and resets every field to its zero value.
fn @types.Game::clear_shots(game : @types.Game) -> Unit {
  for shot in game.shots {
    shot.active = false
    shot.from_player = true
    shot.x = 0.0
    shot.y = 0.0
    shot.vx = 0.0
    shot.vy = 0.0
    shot.life = 0.0
    shot.dmg = 0.0
    shot.kind = 0
  }
}

///|
/// Deactivates all spark particle slots and resets every field to its zero value.
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
/// Deactivates all shock-ring effect slots and resets every field to its zero value.
fn @types.Game::clear_rings(game : @types.Game) -> Unit {
  for ring in game.rings {
    ring.active = false
    ring.x = 0.0
    ring.y = 0.0
    ring.r = 0.0
    ring.life = 0.0
    ring.kind = 0
  }
}

///|
/// Deactivates all ghost after-image slots and resets every field to its zero value.
fn @types.Game::clear_ghosts(game : @types.Game) -> Unit {
  for ghost in game.ghosts {
    ghost.active = false
    ghost.x = 0.0
    ghost.y = 0.0
    ghost.w = 0.0
    ghost.h = 0.0
    ghost.rot = 0.0
    ghost.life = 0.0
    ghost.kind = 0
  }
}

///|
/// Repositions the player car to its starting coordinates and zeroes all velocity, heading, and timer fields.
fn reset_player(hero : @types.Player) -> Unit {
  hero.x = Float::from_int(@types.screen_w / 2)
  hero.y = Float::from_int(@types.screen_h) * 0.76
  hero.vx = 0.0
  hero.vy = 0.0
  hero.w = @types.car_w
  hero.h = @types.car_h
  hero.heading = 0.0
  hero.invuln = 0.0
  hero.hurt_t = 0.0
  hero.muzzle_t = 0.0
  hero.engine_t = 0.0
}

///|
/// Returns the index of a free object slot, evicting the slot with the largest y (furthest off screen) if all are active.
fn @types.Game::alloc_obj(game : @types.Game) -> Int {
  for i, slot in game.objs {
    if !slot.active {
      break i
    }
  } nobreak {
    let mut best = 0
    let mut best_y = game.objs[0].y
    for i in 1..<game.objs.length() {
      if game.objs[i].y > best_y {
        best_y = game.objs[i].y
        best = i
      }
    }
    best
  }
}

///|
/// Returns the index of a free shot slot, evicting the slot with the lowest remaining life if all are active.
fn @types.Game::alloc_shot(game : @types.Game) -> Int {
  for i, slot in game.shots {
    if !slot.active {
      break i
    }
  } nobreak {
    let mut best = 0
    let mut best_life = game.shots[0].life
    for i in 1..<game.shots.length() {
      if game.shots[i].life < best_life {
        best_life = game.shots[i].life
        best = i
      }
    }
    best
  }
}

///|
/// Returns the index of a free spark slot, evicting the slot with the lowest remaining life if all are active.
fn @types.Game::alloc_spark(game : @types.Game) -> Int {
  for i, slot in game.sparks {
    if !slot.active {
      break i
    }
  } nobreak {
    let mut best = 0
    let mut best_life = game.sparks[0].life
    for i in 1..<game.sparks.length() {
      if game.sparks[i].life < best_life {
        best_life = game.sparks[i].life
        best = i
      }
    }
    best
  }
}

///|
/// Returns the index of a free ring slot, evicting the slot with the lowest remaining life if all are active.
fn @types.Game::alloc_ring(game : @types.Game) -> Int {
  for i, slot in game.rings {
    if !slot.active {
      break i
    }
  } nobreak {
    let mut best = 0
    let mut best_life = game.rings[0].life
    for i in 1..<game.rings.length() {
      if game.rings[i].life < best_life {
        best_life = game.rings[i].life
        best = i
      }
    }
    best
  }
}

///|
/// Returns the index of a free ghost slot, evicting the slot with the lowest remaining life if all are active.
fn @types.Game::alloc_ghost(game : @types.Game) -> Int {
  for i, slot in game.ghosts {
    if !slot.active {
      break i
    }
  } nobreak {
    let mut best = 0
    let mut best_life = game.ghosts[0].life
    for i in 1..<game.ghosts.length() {
      if game.ghosts[i].life < best_life {
        best_life = game.ghosts[i].life
        best = i
      }
    }
    best
  }
}

///|
/// Allocates a spark slot and sets it up with the supplied position, velocity, lifetime, size, and visual kind.
fn @types.Game::emit_spark(
  game : @types.Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : Int,
) -> Unit {
  let i = game.alloc_spark()
  game.sparks[i].active = true
  game.sparks[i].x = x
  game.sparks[i].y = y
  game.sparks[i].vx = vx
  game.sparks[i].vy = vy
  game.sparks[i].life = life
  game.sparks[i].size = size
  game.sparks[i].kind = kind
}

///|
/// Emits `count` randomly scattered sparks centred on `(x, y)` with the given kind for explosion effects.
fn @types.Game::burst(
  game : @types.Game,
  x : Float,
  y : Float,
  count : Int,
  kind : Int,
) -> Unit {
  for _i in 0..<count {
    game.emit_spark(
      x + @types.randf(-20.0, 20.0),
      y + @types.randf(-20.0, 20.0),
      @types.randf(-270.0, 270.0),
      @types.randf(-270.0, 270.0),
      @types.randf(0.24, 1.02),
      @types.randf(1.2, 6.6),
      kind,
    )
  }
}

///|
/// Allocates a shock-ring slot and sets it up with the given centre, starting radius, lifetime, and kind.
fn @types.Game::spawn_ring(
  game : @types.Game,
  x : Float,
  y : Float,
  r : Float,
  life : Float,
  kind : Int,
) -> Unit {
  let i = game.alloc_ring()
  game.rings[i].active = true
  game.rings[i].x = x
  game.rings[i].y = y
  game.rings[i].r = r
  game.rings[i].life = life
  game.rings[i].kind = kind
}

///|
/// Allocates a ghost after-image slot at the given position, size, rotation, lifetime, and visual kind.
fn @types.Game::emit_ghost(
  game : @types.Game,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  rot : Float,
  life : Float,
  kind : Int,
) -> Unit {
  let i = game.alloc_ghost()
  game.ghosts[i].active = true
  game.ghosts[i].x = x
  game.ghosts[i].y = y
  game.ghosts[i].w = w
  game.ghosts[i].h = h
  game.ghosts[i].rot = rot
  game.ghosts[i].life = life
  game.ghosts[i].kind = kind
}

///|
/// Allocates a projectile slot and initialises it with origin, velocity, lifetime, damage, kind, and ownership flag.
fn @types.Game::spawn_shot(
  game : @types.Game,
  from_player : Bool,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  dmg : Float,
  kind : Int,
) -> Unit {
  let i = game.alloc_shot()
  game.shots[i].active = true
  game.shots[i].from_player = from_player
  game.shots[i].x = x
  game.shots[i].y = y
  game.shots[i].vx = vx
  game.shots[i].vy = vy
  game.shots[i].life = life
  game.shots[i].dmg = dmg
  game.shots[i].kind = kind
}

///|
/// Allocates an enemy/pickup object slot and populates it with the given kind, transform, HP, fire cooldown, cloak flag, and reward.
fn @types.Game::spawn_obj(
  game : @types.Game,
  kind : @types.ObjKind,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  w : Float,
  h : Float,
  hp : Float,
  shot_cd : Float,
  cloak : Bool,
  reward : Int,
) -> Unit {
  let i = game.alloc_obj()
  game.objs[i].active = true
  game.objs[i].kind = kind
  game.objs[i].x = x
  game.objs[i].y = y
  game.objs[i].vx = vx
  game.objs[i].vy = vy
  game.objs[i].w = w
  game.objs[i].h = h
  game.objs[i].hp = hp
  game.objs[i].shot_cd = shot_cd
  game.objs[i].spin = @types.randf(0.0, 6.283)
  game.objs[i].cloak = cloak
  game.objs[i].reward = reward
}

///|
/// Returns the combo-scaled score delta for the given base value.
fn @types.Game::score_gain(game : @types.Game, base : Int) -> Int {
  let bonus = base * game.combo / 5
  base + bonus
}

///|
/// Adds a combo-scaled amount to the session score and updates best-score if the total exceeds it.
fn @types.Game::add_score(game : @types.Game, base : Int) -> Unit {
  let g = game.score_gain(base)
  game.score = game.score + g
  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
/// Increments the combo counter by one (capped at 24) and resets the combo display timer.
fn @types.Game::push_combo(game : @types.Game) -> Unit {
  game.combo = (game.combo + 1).clamp(min=0, max=24)
  game.combo_t = 3.6
}

///|
/// Resets the combo counter and display timer to zero.
fn @types.Game::clear_combo(game : @types.Game) -> Unit {
  game.combo = 0
  game.combo_t = 0.0
}

///|
/// Deducts armor, triggers hurt flash and screen-shake, resets combo, and transitions to GameOver when armor reaches zero.
fn @types.Game::hurt_player(game : @types.Game, dmg : Float) -> Unit {
  if game.hero.invuln > 0.0 {
    return
  }

  game.armor = @types.maxf(0.0, game.armor - dmg)
  game.hero.invuln = @types.invuln_time
  game.hero.hurt_t = 0.58
  game.flash_t = @types.maxf(game.flash_t, 0.34)
  game.shake_t = @types.maxf(game.shake_t, 0.58)

  game.burst(game.hero.x, game.hero.y, 22, 1)
  game.clear_combo()

  if game.armor <= 0.0 {
    game.state = GameOver
    game.result_t = 0.0
  }
}

///|
/// Clears all entities, transitions to Play, sets stage-scaled distance goal and scroll speed, resets all cooldowns, and fully restores or partially replenishes armor and heat depending on whether this is the first stage.
fn @types.Game::start_stage(game : @types.Game, stage : Int) -> Unit {
  game.clear_objs()
  game.clear_shots()
  game.clear_sparks()
  game.clear_rings()
  game.clear_ghosts()
  reset_player(game.hero)

  game.state = Play
  game.stage = stage
  game.distance = 0.0
  game.stage_goal = @types.stage_goal_base +
    Float::from_int(stage - 1) * @types.stage_goal_bonus
  game.scroll = @types.base_scroll +
    Float::from_int(stage - 1) * @types.stage_scroll_bonus
  game.next_spawn_y = @types.spawn_start_y

  game.fire_cd = 0.0
  game.dash_cd = 0.0
  game.dash_t = 0.0
  game.emp_cd = 0.0
  game.emp_t = 0.0
  game.result_t = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  game.hint_t = 0.0
  game.clear_combo()

  if stage <= 1 {
    game.score = 0
    game.coins = 0
    game.kills = 0
    game.armor = @types.armor_max
    game.heat = @types.heat_max
  } else {
    game.armor = @types.minf(@types.armor_max, game.armor + 20.0)
    game.heat = @types.minf(@types.heat_max, game.heat + 34.0)
  }

  game.spawn_ring(game.hero.x, game.hero.y, 16.0, 0.72, 0)
}

///|
/// Clears all entities, resets the player and every session stat to zero, and transitions to the Title state.
fn @types.Game::init_title_scene(game : @types.Game) -> Unit {
  game.clear_objs()
  game.clear_shots()
  game.clear_sparks()
  game.clear_rings()
  game.clear_ghosts()
  reset_player(game.hero)

  game.state = Title
  game.stage = 1
  game.distance = 0.0
  game.stage_goal = @types.stage_goal_base
  game.score = 0
  game.coins = 0
  game.kills = 0
  game.combo = 0
  game.combo_t = 0.0
  game.armor = @types.armor_max
  game.heat = @types.heat_max

  game.fire_cd = 0.0
  game.dash_cd = 0.0
  game.dash_t = 0.0
  game.emp_cd = 0.0
  game.emp_t = 0.0

  game.time_s = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  game.result_t = 0.0
  game.hint_t = 0.0

  game.scroll = @types.base_scroll
  game.next_spawn_y = @types.spawn_start_y
}

///|
/// Starts a new run from stage 1 by delegating to `start_stage`.
fn @types.Game::start_run(game : @types.Game) -> Unit {
  game.start_stage(1)
}

///|
/// Spawns 1-3 randomly selected enemies or pickups at the given screen Y, with positions, velocities, and HP scaled to the current stage.
fn @types.Game::spawn_wave(game : @types.Game, y : Float) -> Unit {
  let depth = game.distance + (Float::from_int(@types.screen_h) - y)
  let center = @types.track_center(depth, game.time_s)

  let c = 1 + @types.randi(0, 2)
  for _i in 0..<c {
    let roll = @types.randi(0, 99)

    if roll < 34 {
      let lane = @types.randi(0, @types.lane_count - 1)
      let x = @types.lane_pos(lane, center) + @types.randf(-12.0, 12.0)
      game.spawn_obj(
        Scout,
        x,
        y + @types.randf(-28.0, 22.0),
        @types.randf(-42.0, 42.0),
        @types.randf(-18.0, 38.0),
        44.0,
        76.0,
        18.0 + Float::from_int(game.stage - 1) * 3.0,
        @types.randf(0.42, 1.28),
        false,
        120,
      )
    } else if roll < 56 {
      let lane = @types.randi(0, @types.lane_count - 1)
      let x = @types.lane_pos(lane, center) + @types.randf(-14.0, 14.0)
      game.spawn_obj(
        Spinner,
        x,
        y + @types.randf(-26.0, 22.0),
        @types.randf(-62.0, 62.0),
        @types.randf(-10.0, 30.0),
        40.0,
        40.0,
        12.0 + Float::from_int(game.stage - 1) * 2.0,
        @types.randf(0.26, 0.94),
        game.stage >= 3 && @types.chance(24),
        108,
      )
    } else if roll < 70 {
      let lane = @types.randi(0, @types.lane_count - 1)
      let x = @types.lane_pos(lane, center)
      game.spawn_obj(
        Tank,
        x,
        y + @types.randf(-32.0, 24.0),
        @types.randf(-18.0, 18.0),
        @types.randf(-16.0, 18.0),
        82.0,
        122.0,
        46.0 + Float::from_int(game.stage - 1) * 7.0,
        @types.randf(0.7, 1.9),
        false,
        188,
      )
    } else if roll < 80 {
      let lane = @types.randi(0, @types.lane_count - 1)
      let x = @types.lane_pos(lane, center)
      game.spawn_obj(
        GearWall,
        x,
        y + @types.randf(-16.0, 12.0),
        0.0,
        @types.randf(-6.0, 12.0),
        126.0,
        18.0,
        16.0,
        @types.randf(0.9, 2.02),
        false,
        94,
      )
    } else if roll < 90 {
      let x = @types.spawn_x(game.distance, game.time_s, game.stage, y)
      game.spawn_obj(
        Coin,
        x,
        y + @types.randf(-18.0, 18.0),
        @types.randf(-34.0, 34.0),
        @types.randf(-14.0, 16.0),
        34.0,
        34.0,
        1.0,
        0.0,
        false,
        0,
      )
    } else if roll < 96 {
      let x = @types.spawn_x(game.distance, game.time_s, game.stage, y)
      game.spawn_obj(
        Coolant,
        x,
        y + @types.randf(-18.0, 18.0),
        @types.randf(-28.0, 28.0),
        @types.randf(-12.0, 18.0),
        38.0,
        38.0,
        1.0,
        0.0,
        false,
        0,
      )
    } else {
      let x = @types.spawn_x(game.distance, game.time_s, game.stage, y)
      game.spawn_obj(
        EmpCell,
        x,
        y + @types.randf(-14.0, 14.0),
        @types.randf(-20.0, 20.0),
        @types.randf(-10.0, 14.0),
        34.0,
        34.0,
        1.0,
        0.0,
        false,
        0,
      )
    }
  }
}

///|
/// Advances the spawn cursor by scroll distance this frame and calls `spawn_wave` for each gap threshold that has been crossed.
fn @types.Game::spawn_step(game : @types.Game, dt : Float) -> Unit {
  game.next_spawn_y = game.next_spawn_y + game.scroll * dt

  let mut n = 0
  while game.next_spawn_y >= 0.0 && n < 18 {
    game.next_spawn_y = game.next_spawn_y -
      @types.randf(@types.spawn_gap_min, @types.spawn_gap_max)
    game.spawn_wave(game.next_spawn_y)
    n = n + 1
  }
}

///|
/// Activates the EMP pulse: sets cooldown and effect timers, emits a ring and burst, destroys or uncloaks hostiles inside the kill radius, and nullifies enemy shots inside the EMP radius.
fn @types.Game::apply_emp(game : @types.Game) -> Unit {
  game.emp_cd = @types.emp_cd_time
  game.emp_t = @types.emp_time

  game.spawn_ring(game.hero.x, game.hero.y, 14.0, 0.9, 2)
  game.burst(game.hero.x, game.hero.y, 24, 2)

  let rr2 = @types.emp_radius * @types.emp_radius
  let kill2 = @types.emp_kill_radius * @types.emp_kill_radius

  for obj in game.objs {
    if !obj.active {
      continue
    }

    let d2 = @types.dist2(game.hero.x, game.hero.y, obj.x, obj.y)
    if d2 > rr2 {
      continue
    }

    obj.cloak = false

    if @types.is_hostile(obj.kind) && d2 <= kill2 {
      let kind = obj.kind
      let x = obj.x
      let y = obj.y
      obj.active = false
      game.add_score(if kind == Tank { 140 } else { 88 })
      game.push_combo()
      game.burst(x, y, 18, 1)
      game.spawn_ring(x, y, 10.0, 0.5, 1)
      game.kills = game.kills + 1
    }
  }

  for shot in game.shots {
    if !shot.active || shot.from_player {
      continue
    }

    let d2 = @types.dist2(game.hero.x, game.hero.y, shot.x, shot.y)
    if d2 <= rr2 {
      shot.active = false
      game.emit_spark(
        shot.x,
        shot.y,
        @types.randf(-86.0, 86.0),
        @types.randf(-86.0, 86.0),
        @types.randf(0.2, 0.45),
        @types.randf(1.2, 3.4),
        2,
      )
    }
  }
}

///|
/// Fires twin shots from the player car's front cannons with wider spread during a dash; adds a centre bonus shot on stage 4 and above.
fn @types.Game::shoot_player(game : @types.Game) -> Unit {
  let spread : Float = if game.dash_t > 0.0 { 15.0 } else { 8.0 }

  game.spawn_shot(
    true,
    game.hero.x - 10.0,
    game.hero.y - game.hero.h * 0.44,
    @types.randf(-spread, spread),
    -@types.shot_speed,
    @types.shot_life,
    8.0,
    0,
  )
  game.spawn_shot(
    true,
    game.hero.x + 10.0,
    game.hero.y - game.hero.h * 0.44,
    @types.randf(-spread, spread),
    -@types.shot_speed,
    @types.shot_life,
    8.0,
    0,
  )

  if game.stage >= 4 && @types.chance(26) {
    game.spawn_shot(
      true,
      game.hero.x,
      game.hero.y - game.hero.h * 0.54,
      @types.randf(-6.0, 6.0),
      -@types.shot_speed * 1.08,
      @types.shot_life,
      6.0,
      1,
    )
  }

  game.hero.muzzle_t = 0.12
}

///|
/// Processes dash, EMP, and fire inputs including their heat and cooldown costs, applies directional acceleration and drag, and moves the player car; emits ghost after-images while dashing.
fn @types.Game::apply_player_input(game : @types.Game, dt : Float) -> Unit {
  if game.input_dash_press && game.dash_cd <= 0.0 && game.heat >= 14.0 {
    game.dash_t = @types.dash_time
    game.dash_cd = @types.dash_cd_time
    game.heat = @types.maxf(0.0, game.heat - 12.0)
    game.hero.invuln = @types.maxf(game.hero.invuln, 0.22)

    let mut dx = game.input_x
    let mut dy = game.input_y
    let n2 = dx * dx + dy * dy
    if n2 <= 0.001 {
      dx = 0.0
      dy = -1.0
    } else {
      let inv : Float = Float::from_int(1) / n2.sqrt()
      dx = dx * inv
      dy = dy * inv
    }

    game.hero.vx = game.hero.vx + dx * @types.dash_boost
    game.hero.vy = game.hero.vy + dy * @types.dash_boost * 0.72

    game.spawn_ring(game.hero.x, game.hero.y, 18.0, 0.58, 0)
    game.burst(game.hero.x, game.hero.y, 16, 0)
  }

  if game.input_emp_press && game.emp_cd <= 0.0 && game.heat >= 18.0 {
    game.heat = @types.maxf(0.0, game.heat - 18.0)
    game.apply_emp()
  }

  if game.input_fire_hold && game.fire_cd <= 0.0 {
    game.shoot_player()
    game.fire_cd = if game.dash_t > 0.0 {
      @types.shot_cd_base * 0.62
    } else {
      @types.shot_cd_base
    }
  }

  game.hero.vx = game.hero.vx + game.input_x * @types.accel_x * dt
  game.hero.vy = game.hero.vy + game.input_y * @types.accel_y * dt

  if game.dash_t > 0.0 {
    game.hero.vy = game.hero.vy - 150.0 * dt
    game.emit_ghost(
      game.hero.x,
      game.hero.y + 16.0,
      game.hero.w,
      game.hero.h,
      game.hero.heading,
      @types.randf(0.14, 0.26),
      1,
    )
  }

  let drag = @types.clampf(1.0 - @types.car_drag * dt, 0.0, 1.0)
  game.hero.vx = game.hero.vx * drag
  game.hero.vy = game.hero.vy * drag

  game.hero.vx = @types.clampf(
    game.hero.vx,
    -@types.max_speed_x,
    @types.max_speed_x,
  )
  game.hero.vy = @types.clampf(
    game.hero.vy,
    -@types.max_speed_y,
    @types.max_speed_y,
  )

  game.hero.x = game.hero.x + game.hero.vx * dt
  game.hero.y = game.hero.y + game.hero.vy * dt

  game.hero.y = @types.clampf(
    game.hero.y,
    Float::from_int(@types.hud_h + 56),
    Float::from_int(@types.screen_h) - 80.0,
  )
}

///|
/// Pushes the player back inside the track edges and inflicts collision damage when either side boundary is exceeded.
fn @types.Game::constrain_to_track(game : @types.Game) -> Unit {
  let depth = game.distance + (Float::from_int(@types.screen_h) - game.hero.y)
  let e = @types.track_edges(game.stage, depth, game.time_s)
  let left = e.0
  let right = e.1

  let rr = @types.player_hit_r(game.hero)

  if game.hero.x - rr < left {
    game.hero.x = left + rr
    game.hero.vx = game.hero.vx.abs() * 0.2
    game.hurt_player(10.0)
  }

  if game.hero.x + rr > right {
    game.hero.x = right - rr
    game.hero.vx = -game.hero.vx.abs() * 0.2
    game.hurt_player(10.0)
  }
}

///|
/// Fires projectiles from an enemy object according to its kind: Scout shoots a random downward spread, Spinner aims directly at the player, and Tank fires twin angled shots.
fn @types.Game::enemy_fire(game : @types.Game, o : @types.Obj) -> Unit {
  match o.kind {
    Scout =>
      game.spawn_shot(
        false,
        o.x,
        o.y + o.h * 0.4,
        @types.randf(-120.0, 120.0),
        @types.enemy_shot_speed,
        2.2,
        9.0,
        0,
      )
    Spinner => {
      let dx = game.hero.x - o.x
      let dy = game.hero.y - o.y
      let n2 = @types.maxf(dx * dx + dy * dy, 1.0)
      let inv : Float = Float::from_int(1) / n2.sqrt()
      game.spawn_shot(
        false,
        o.x,
        o.y,
        dx * inv * @types.enemy_shot_speed,
        dy * inv * @types.enemy_shot_speed,
        2.5,
        11.0,
        1,
      )
    }
    Tank => {
      game.spawn_shot(
        false,
        o.x - 18.0,
        o.y + o.h * 0.32,
        -60.0,
        @types.enemy_shot_speed * 0.86,
        2.6,
        12.0,
        2,
      )
      game.spawn_shot(
        false,
        o.x + 18.0,
        o.y + o.h * 0.32,
        60.0,
        @types.enemy_shot_speed * 0.86,
        2.6,
        12.0,
        2,
      )
    }
    _ => ()
  }
}

///|
/// Deactivates an enemy object, awards score, increments kills, pushes the combo, and emits a burst and ring at the object's position.
fn @types.Game::kill_obj(
  game : @types.Game,
  i : Int,
  base : Int,
  burst_kind : Int,
) -> Unit {
  let x = game.objs[i].x
  let y = game.objs[i].y
  game.objs[i].active = false
  game.add_score(base)
  game.push_combo()
  game.kills = game.kills + 1
  game.burst(x, y, 16 + @types.randi(0, 8), burst_kind)
  game.spawn_ring(x, y, 10.0, 0.56, burst_kind)
}

///|
/// Applies the effect of a collected pickup: Coin increments coin count and score with combo; Coolant restores heat; EmpCell reduces EMP cooldown and adds heat and score with combo.
fn @types.Game::collect_item(game : @types.Game, kind : @types.ObjKind) -> Unit {
  match kind {
    Coin => {
      game.coins = game.coins + 1
      game.add_score(60)
      game.push_combo()
    }
    Coolant => {
      game.heat = @types.minf(@types.heat_max, game.heat + @types.heat_pickup)
      game.add_score(40)
    }
    EmpCell => {
      game.emp_cd = @types.maxf(0.0, game.emp_cd - 1.1)
      game.heat = @types.minf(@types.heat_max, game.heat + 12.0)
      game.add_score(78)
      game.push_combo()
    }
    _ => ()
  }
}

///|
/// Moves all active objects by their velocity and scroll speed, applies per-kind oscillation, fires enemy weapons when cooldowns expire, handles player-collision outcomes (pickup collection, ram kills, or player damage), and culls objects that drift off screen.
fn @types.Game::update_objs(game : @types.Game, dt : Float) -> Unit {
  let ram = game.dash_t > 0.0

  for i in 0..<game.objs.length() {
    if !game.objs[i].active {
      continue
    }

    game.objs[i].x = game.objs[i].x + game.objs[i].vx * dt
    game.objs[i].y = game.objs[i].y + (game.scroll + game.objs[i].vy) * dt
    game.objs[i].spin = game.objs[i].spin + dt * 1.9
    game.objs[i].shot_cd = game.objs[i].shot_cd - dt

    match game.objs[i].kind {
      Scout =>
        game.objs[i].x = game.objs[i].x +
          @math.sinf(game.objs[i].spin * 2.2) * 34.0 * dt
      Spinner =>
        game.objs[i].y = game.objs[i].y +
          @math.cosf(game.objs[i].spin * 2.8) * 26.0 * dt
      Tank =>
        game.objs[i].x = game.objs[i].x +
          @math.sinf(game.objs[i].spin * 1.4) * 18.0 * dt
      GearWall => {
        game.objs[i].w = 118.0 + @math.sinf(game.objs[i].spin * 3.4) * 26.0
        game.objs[i].h = 18.0 + @math.sinf(game.objs[i].spin * 4.2) * 4.0
      }
      _ =>
        game.objs[i].x = game.objs[i].x +
          @math.sinf(game.objs[i].spin * 2.6) * 16.0 * dt
    }

    let out = game.objs[i].y > Float::from_int(@types.screen_h) + 220.0 ||
      game.objs[i].x < -260.0 ||
      game.objs[i].x > Float::from_int(@types.screen_w) + 260.0
    if out {
      game.objs[i].active = false
      continue
    }

    if @types.is_hostile(game.objs[i].kind) && game.objs[i].shot_cd <= 0.0 {
      game.enemy_fire(game.objs[i])
      game.objs[i].shot_cd = match game.objs[i].kind {
        Scout => @types.randf(0.74, 1.44)
        Spinner => @types.randf(0.48, 1.02)
        Tank => @types.randf(1.18, 2.1)
        _ => @types.randf(1.0, 1.8)
      }
    }

    let d2 = @types.dist2(
      game.hero.x,
      game.hero.y,
      game.objs[i].x,
      game.objs[i].y,
    )
    let rr = @types.player_hit_r(game.hero) + @types.obj_hit_r(game.objs[i])

    if d2 <= rr * rr {
      let kind = game.objs[i].kind
      if @types.is_pickup(kind) {
        game.objs[i].active = false
        game.collect_item(kind)
        game.burst(game.hero.x, game.hero.y, 10, 2)
      } else if ram {
        game.kill_obj(i, game.objs[i].reward, 0)
      } else {
        let dmg : Float = match kind {
          Tank => 24.0
          GearWall => 16.0
          _ => 14.0
        }
        game.hurt_player(dmg)
        if kind != GearWall {
          game.objs[i].active = false
        }
      }
    }
  }
}

///|
/// Moves all active shots, deactivates expired or out-of-bounds shots, resolves player shots against enemies (dealing damage or triggering kills), and resolves enemy shots against the player.
fn @types.Game::update_shots(game : @types.Game, dt : Float) -> Unit {
  for shot in game.shots {
    if !shot.active {
      continue
    }

    shot.x = shot.x + shot.vx * dt
    shot.y = shot.y + (shot.vy + game.scroll * 0.1) * dt
    shot.life = shot.life - dt

    let dead = shot.life <= 0.0 ||
      shot.y < -120.0 ||
      shot.y > Float::from_int(@types.screen_h) + 120.0 ||
      shot.x < -120.0 ||
      shot.x > Float::from_int(@types.screen_w) + 120.0
    if dead {
      shot.active = false
      continue
    }

    if shot.from_player {
      let mut hit = false
      for j in 0..<game.objs.length() {
        if !game.objs[j].active || @types.is_pickup(game.objs[j].kind) {
          continue
        }

        let d2 = @types.dist2(shot.x, shot.y, game.objs[j].x, game.objs[j].y)
        let rr = @types.obj_hit_r(game.objs[j]) + 8.0
        if d2 <= rr * rr {
          game.objs[j].hp = game.objs[j].hp - shot.dmg
          shot.active = false
          hit = true

          game.emit_spark(
            game.objs[j].x,
            game.objs[j].y,
            @types.randf(-90.0, 90.0),
            @types.randf(-90.0, 90.0),
            @types.randf(0.18, 0.42),
            @types.randf(1.0, 3.2),
            0,
          )

          if game.objs[j].hp <= 0.0 {
            game.kill_obj(j, game.objs[j].reward, 0)
          }
          break
        }
      }

      if hit {
        continue
      }
    } else {
      let d2 = @types.dist2(shot.x, shot.y, game.hero.x, game.hero.y)
      let rr = @types.player_hit_r(game.hero) + 8.0
      if d2 <= rr * rr {
        shot.active = false
        game.hurt_player(shot.dmg)
        continue
      }
    }
  }
}

///|
/// Advances and ages all active spark particles, expanding rings, and dash ghost after-images; deactivates any that have exhausted their lifetime.
fn @types.Game::update_fx(game : @types.Game, dt : Float) -> Unit {
  for spark in game.sparks {
    if !spark.active {
      continue
    }

    spark.x = spark.x + spark.vx * dt
    spark.y = spark.y + (spark.vy + game.scroll * 0.16) * dt
    spark.life = spark.life - dt

    if spark.life <= 0.0 {
      spark.active = false
    }
  }

  for ring in game.rings {
    if !ring.active {
      continue
    }

    ring.life = ring.life - dt
    ring.r = ring.r + (130.0 + Float::from_int(ring.kind) * 52.0) * dt
    if ring.life <= 0.0 {
      ring.active = false
    }
  }

  for ghost in game.ghosts {
    if !ghost.active {
      continue
    }

    ghost.y = ghost.y + game.scroll * 0.26 * dt
    ghost.life = ghost.life - dt
    if ghost.life <= 0.0 {
      ghost.active = false
    }
  }
}

///|
/// Randomly emits roadside ambient sparks near the track edges each frame to convey the scrolling city environment.
fn @types.Game::emit_ambient(game : @types.Game, dt : Float) -> Unit {
  let tries = (dt * 230.0).to_int().clamp(min=1, max=10)
  let mut i = 0
  while i < tries {
    if @types.chance(32) {
      let y = @types.randf(
        Float::from_int(@types.hud_h),
        Float::from_int(@types.screen_h) + 12.0,
      )
      let depth = game.distance + (Float::from_int(@types.screen_h) - y)
      let e = @types.track_edges(game.stage, depth, game.time_s)
      let side : Float = if @types.chance(50) {
        Float::from_int(-1)
      } else {
        Float::from_int(1)
      }
      let x = if side < 0.0 {
        e.0 + @types.randf(8.0, 30.0)
      } else {
        e.1 - @types.randf(8.0, 30.0)
      }

      game.emit_spark(
        x,
        y,
        side * @types.randf(4.0, 20.0),
        @types.randf(-20.0, 34.0),
        @types.randf(0.5, 1.4),
        @types.randf(1.0, 2.8),
        if @types.chance(40) {
          2
        } else {
          0
        },
      )
    }
    i = i + 1
  }
}

///|
/// Decrements all cooldown and duration timers (invulnerability, hurt flash, muzzle, fire, dash, EMP, screen flash, screen shake, combo) and expires the combo counter when its timer runs out.
fn @types.Game::update_timers(game : @types.Game, dt : Float) -> Unit {
  game.hero.invuln = @types.maxf(0.0, game.hero.invuln - dt)
  game.hero.hurt_t = @types.maxf(0.0, game.hero.hurt_t - dt)
  game.hero.muzzle_t = @types.maxf(0.0, game.hero.muzzle_t - dt)
  game.hero.engine_t = game.hero.engine_t + dt

  game.fire_cd = @types.maxf(0.0, game.fire_cd - dt)
  game.dash_cd = @types.maxf(0.0, game.dash_cd - dt)
  game.dash_t = @types.maxf(0.0, game.dash_t - dt)
  game.emp_cd = @types.maxf(0.0, game.emp_cd - dt)
  game.emp_t = @types.maxf(0.0, game.emp_t - dt)

  game.flash_t = @types.maxf(0.0, game.flash_t - dt)
  game.shake_t = @types.maxf(0.0, game.shake_t - dt)

  if game.combo_t > 0.0 {
    game.combo_t = game.combo_t - dt
    if game.combo_t <= 0.0 {
      game.clear_combo()
    }
  }
}

///|
/// Runs one Play-state tick: advances scroll speed and distance, processes player input, spawns and updates all objects/shots/effects, drains heat and armor passively, emits ambient sparks, and checks for StageClear when the distance goal is reached.
fn @types.Game::update_play(game : @types.Game, dt : Float) -> Unit {
  game.scroll = @types.base_scroll +
    Float::from_int(game.stage - 1) * @types.stage_scroll_bonus +
    @types.minf(70.0, game.distance * 0.006)
  game.distance = game.distance + game.scroll * dt

  game.apply_player_input(dt)
  game.constrain_to_track()

  game.spawn_step(dt)
  game.update_objs(dt)
  game.update_shots(dt)
  game.update_fx(dt)

  game.heat = @types.maxf(
    0.0,
    game.heat -
    @types.heat_drain_base * dt -
    game.hero.vx.abs() / @types.max_speed_x * 1.2 * dt,
  )

  if game.dash_t > 0.0 {
    game.heat = @types.maxf(0.0, game.heat - @types.heat_drain_dash * dt)
  }

  game.armor = @types.maxf(0.0, game.armor - @types.armor_drain_passive * dt)

  game.emit_ambient(dt)

  if game.heat <= 0.0 {
    game.hurt_player(100.0)
  }

  if game.state == Play && game.distance >= game.stage_goal {
    game.state = StageClear
    game.result_t = 0.0
    game.add_score(320 + game.stage * 120)
    game.armor = @types.minf(@types.armor_max, game.armor + 14.0)
    game.heat = @types.minf(@types.heat_max, game.heat + 20.0)
    game.spawn_ring(game.hero.x, game.hero.y, 18.0, 0.9, 2)
    game.burst(game.hero.x, game.hero.y, 28, 2)
  }
}

///|
/// Runs one Title-state tick: advances the decorative scroll, updates ambient and effect particles, and launches a new run when the start input is pressed.
fn @types.Game::update_title(game : @types.Game, dt : Float) -> Unit {
  game.scroll = 96.0
  game.distance = game.distance + game.scroll * dt * 0.7

  game.emit_ambient(dt)
  game.update_fx(dt)

  if game.input_restart_press {
    game.start_run()
  }
}

///|
/// Runs one StageClear-state tick: accumulates the result timer, decelerates the scroll, updates particles, emits celebratory sparks, and advances to the next stage when the wait elapses or the player presses restart.
fn @types.Game::update_stage_clear(game : @types.Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  game.scroll = @types.maxf(90.0, game.scroll - 140.0 * dt)

  game.update_fx(dt)
  game.emit_ambient(dt)

  if @types.chance(24) {
    game.emit_spark(
      game.hero.x + @types.randf(-30.0, 30.0),
      game.hero.y + @types.randf(-30.0, 30.0),
      @types.randf(-44.0, 44.0),
      @types.randf(-80.0, -16.0),
      @types.randf(0.26, 0.62),
      @types.randf(2.0, 4.2),
      2,
    )
  }

  if game.input_restart_press || game.result_t >= @types.stage_clear_wait {
    game.start_stage(game.stage + 1)
  }
}

///|
/// Runs one GameOver-state tick: accumulates the result timer, decelerates the scroll, updates particles, and returns to Title when the restart input is pressed.
fn @types.Game::update_game_over(game : @types.Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  game.scroll = @types.maxf(52.0, game.scroll - 120.0 * dt)

  game.update_fx(dt)
  game.emit_ambient(dt)

  if game.input_restart_press {
    game.init_title_scene()
  }
}

///|
/// Advances the game simulation by one frame using the current input state.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  // Read input first
  match game.state {
    Title => game.update_title_input()
    Play => game.update_play_input()
    StageClear | GameOver => game.update_result_input()
  }

  game.time_s = game.time_s + dt
  game.hint_t = game.hint_t + dt

  game.update_timers(dt)

  match game.state {
    Title => game.update_title(dt)
    Play => game.update_play(dt)
    StageClear => game.update_stage_clear(dt)
    GameOver => game.update_game_over(dt)
  }

  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
/// Initializes the title-screen state and presentation values.
pub fn init_title(game : @types.Game) -> Unit {
  game.init_title_scene()
}
