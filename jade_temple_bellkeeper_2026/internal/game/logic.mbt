///|
/// Deactivates and resets all foe records in the pool.
fn @types.Game::clear_foes(game : @types.Game) -> Unit {
  for foe in game.foes {
    foe.active = false
    foe.kind = @types.foe_wisp
    foe.x = 0.0
    foe.y = 0.0
    foe.vx = 0.0
    foe.vy = 0.0
    foe.w = 0.0
    foe.h = 0.0
    foe.hp = 0.0
    foe.life = 0.0
    foe.phase = 0.0
    foe.shot_cd = 0.0
    foe.reward = 0
    foe.marked = false
  }
}

///|
/// Deactivates and resets all bolt projectile records in the pool.
fn @types.Game::clear_bolts(game : @types.Game) -> Unit {
  for bolt in game.bolts {
    bolt.active = false
    bolt.x = 0.0
    bolt.y = 0.0
    bolt.vx = 0.0
    bolt.vy = 0.0
    bolt.life = 0.0
    bolt.dmg = 0.0
    bolt.kind = 0
  }
}

///|
/// Deactivates and resets all spark particle records in the pool.
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
/// Deactivates and resets all expanding ring effect records in the pool.
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
/// Deactivates and resets all echo trail effect records in the pool.
fn @types.Game::clear_echoes(game : @types.Game) -> Unit {
  for echo_item in game.echoes {
    echo_item.active = false
    echo_item.x = 0.0
    echo_item.y = 0.0
    echo_item.w = 0.0
    echo_item.h = 0.0
    echo_item.life = 0.0
    echo_item.rot = 0.0
  }
}

///|
/// Restores all bells to their orbiting positions with full charge and no cooldown.
fn @types.Game::reset_bells(game : @types.Game) -> Unit {
  for i in 0..<@types.bell_count {
    let p = @types.bell_pos(i)
    game.bells[i].x = p.0
    game.bells[i].y = p.1
    game.bells[i].cooldown = 0.0
    game.bells[i].glow = 0.0
    game.bells[i].charge = 1.0
  }
}

///|
/// Repositions and resets all hero fields to their initial values.
fn @types.Game::reset_hero(game : @types.Game) -> Unit {
  game.hero.x = @types.shrine_x()
  game.hero.y = @types.shrine_y() + 130.0
  game.hero.vx = 0.0
  game.hero.vy = 0.0
  game.hero.w = @types.hero_w
  game.hero.h = @types.hero_h
  game.hero.angle = 0.0
  game.hero.dash_cd = 0.0
  game.hero.dash_t = 0.0
  game.hero.invuln = 0.0
  game.hero.hurt_t = 0.0
  game.hero.aura_t = 0.0
  game.hero.anim_t = 0.0
}

///|
/// Returns the index of a free foe slot, or the slot with the shortest remaining life if the pool is full.
fn @types.Game::alloc_foe(game : @types.Game) -> Int {
  for i in 0..<game.foes.length() {
    if not(game.foes[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.foes[0].life
  for i in 1..<game.foes.length() {
    if game.foes[i].life < best_life {
      best_life = game.foes[i].life
      best = i
    }
  }
  best
}

///|
/// Returns the index of a free bolt slot, or the slot with the shortest remaining life if the pool is full.
fn @types.Game::alloc_bolt(game : @types.Game) -> Int {
  for i in 0..<game.bolts.length() {
    if not(game.bolts[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.bolts[0].life
  for i in 1..<game.bolts.length() {
    if game.bolts[i].life < best_life {
      best_life = game.bolts[i].life
      best = i
    }
  }
  best
}

///|
/// Returns the index of a free spark slot, or the slot with the shortest remaining life if the pool is full.
fn @types.Game::alloc_spark(game : @types.Game) -> Int {
  for i in 0..<game.sparks.length() {
    if not(game.sparks[i].active) {
      return i
    }
  }

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

///|
/// Returns the index of a free ring slot, or the slot with the shortest remaining life if the pool is full.
fn @types.Game::alloc_ring(game : @types.Game) -> Int {
  for i in 0..<game.rings.length() {
    if not(game.rings[i].active) {
      return i
    }
  }

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

///|
/// Returns the index of a free echo slot, or the slot with the shortest remaining life if the pool is full.
fn @types.Game::alloc_echo(game : @types.Game) -> Int {
  for i in 0..<game.echoes.length() {
    if not(game.echoes[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.echoes[0].life
  for i in 1..<game.echoes.length() {
    if game.echoes[i].life < best_life {
      best_life = game.echoes[i].life
      best = i
    }
  }
  best
}

///|
/// Allocates a spark particle and initializes it with the given position, velocity, lifetime, size, and kind.
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
/// Emits `n` sparks radiating randomly outward from a point with the given kind.
fn @types.Game::burst_sparks(
  game : @types.Game,
  x : Float,
  y : Float,
  n : Int,
  kind : Int,
) -> Unit {
  for _i in 0..<n {
    game.emit_spark(
      x + @types.randf(-16.0, 16.0),
      y + @types.randf(-16.0, 16.0),
      @types.randf(-240.0, 240.0),
      @types.randf(-240.0, 240.0),
      @types.randf(0.24, 1.06),
      @types.randf(1.0, 4.6),
      kind,
    )
  }
}

///|
/// Allocates a ring effect and initializes it with the given position, initial radius, lifetime, and kind.
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
/// Allocates an echo trail effect and initializes it with the given position, size, lifetime, and rotation.
fn @types.Game::spawn_echo(
  game : @types.Game,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  life : Float,
  rot : Float,
) -> Unit {
  let i = game.alloc_echo()
  game.echoes[i].active = true
  game.echoes[i].x = x
  game.echoes[i].y = y
  game.echoes[i].w = w
  game.echoes[i].h = h
  game.echoes[i].life = life
  game.echoes[i].rot = rot
}

///|
/// Allocates a bolt projectile and initializes it with the given position, velocity, lifetime, damage, and kind.
fn @types.Game::spawn_bolt(
  game : @types.Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  dmg : Float,
  kind : Int,
) -> Unit {
  let i = game.alloc_bolt()
  game.bolts[i].active = true
  game.bolts[i].x = x
  game.bolts[i].y = y
  game.bolts[i].vx = vx
  game.bolts[i].vy = vy
  game.bolts[i].life = life
  game.bolts[i].dmg = dmg
  game.bolts[i].kind = kind
}

///|
/// Allocates a foe and initializes all its fields including position, velocity, size, HP, lifetime, shot cooldown, and score reward.
fn @types.Game::spawn_foe(
  game : @types.Game,
  kind : Int,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  w : Float,
  h : Float,
  hp : Float,
  life : Float,
  shot_cd : Float,
  reward : Int,
) -> Unit {
  let i = game.alloc_foe()
  game.foes[i].active = true
  game.foes[i].kind = kind
  game.foes[i].x = x
  game.foes[i].y = y
  game.foes[i].vx = vx
  game.foes[i].vy = vy
  game.foes[i].w = w
  game.foes[i].h = h
  game.foes[i].hp = hp
  game.foes[i].life = life
  game.foes[i].phase = @types.randf(0.0, 6.283)
  game.foes[i].shot_cd = shot_cd
  game.foes[i].reward = reward
  game.foes[i].marked = false
}

///|
/// Computes the actual score gained from a base value, scaled by the current combo multiplier.
fn @types.Game::score_gain(game : @types.Game, base : Int) -> Int {
  let bonus = base * game.combo / 6
  base + bonus
}

///|
/// Adds combo-scaled score to the game total and updates the best score if exceeded.
fn @types.Game::add_score(game : @types.Game, base : Int) -> Unit {
  let g = game.score_gain(base)
  game.score = game.score + g
  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
/// Increments the combo counter (capped at 28) and resets the combo decay timer.
fn @types.Game::push_combo(game : @types.Game) -> Unit {
  game.combo = (game.combo + 1).clamp(min=0, max=28)
  game.combo_t = 3.6
}

///|
/// Resets the combo counter and decay timer to zero.
fn @types.Game::clear_combo(game : @types.Game) -> Unit {
  game.combo = 0
  game.combo_t = 0.0
}

///|
/// Applies damage to the shrine and hero if not invulnerable, triggering flash, shake, and spark effects.
fn @types.Game::hurt_hero(game : @types.Game, dmg : Float) -> Unit {
  if game.hero.invuln > 0.0 {
    return
  }

  game.shrine_hp = @types.maxf(0.0, game.shrine_hp - dmg)
  game.spirit = @types.maxf(0.0, game.spirit - 10.0)

  game.hero.invuln = @types.hero_invuln_time
  game.hero.hurt_t = @types.hero_hurt_time
  game.flash_t = @types.maxf(game.flash_t, 0.32)
  game.shake_t = @types.maxf(game.shake_t, 0.52)

  game.burst_sparks(game.hero.x, game.hero.y, 18, 1)
  game.clear_combo()

  if game.shrine_hp <= 0.0 {
    game.state = GameOver
    game.result_t = 0.0
  }
}

///|
/// Triggers a bell shockwave if not on cooldown and sufficient spirit is available, damaging foes and destroying bolts in range.
fn @types.Game::ring_bell(game : @types.Game, bell_i : Int) -> Unit {
  if bell_i < 0 || bell_i >= @types.bell_count {
    return
  }

  if game.bells[bell_i].cooldown > 0.0 || game.spirit < @types.bell_cost {
    return
  }

  game.bells[bell_i].cooldown = @types.bell_cd_time
  game.bells[bell_i].glow = 0.9
  game.bells[bell_i].charge = 0.0

  game.spirit = @types.maxf(0.0, game.spirit - @types.bell_cost)
  game.hero.aura_t = 0.42

  game.spawn_ring(game.bells[bell_i].x, game.bells[bell_i].y, 16.0, 0.9, 0)
  game.burst_sparks(game.bells[bell_i].x, game.bells[bell_i].y, 28, 0)

  let rr2 = @types.bell_shock_radius * @types.bell_shock_radius

  for foe in game.foes {
    if not(foe.active) {
      continue
    }

    let d2 = @types.dist2(
      game.bells[bell_i].x,
      game.bells[bell_i].y,
      foe.x,
      foe.y,
    )
    if d2 > rr2 {
      continue
    }

    if @types.is_relic(foe.kind) {
      foe.active = false
      game.rescued = game.rescued + 1
      game.add_score(180)
      game.spirit = @types.minf(@types.spirit_max, game.spirit + 20.0)
      game.shrine_hp = @types.minf(@types.shrine_max_hp, game.shrine_hp + 12.0)
      game.spawn_ring(foe.x, foe.y, 10.0, 0.5, 2)
      game.burst_sparks(foe.x, foe.y, 12, 2)
      continue
    }

    let dmg = if foe.kind == @types.foe_brute {
      @types.bell_shock_damage * 0.7
    } else {
      @types.bell_shock_damage
    }

    foe.hp = foe.hp - dmg
    foe.marked = true

    let dx = foe.x - game.bells[bell_i].x
    let dy = foe.y - game.bells[bell_i].y
    let n2 = @types.maxf(1.0, dx * dx + dy * dy)
    let inv = Float::from_int(1) / n2.sqrt()
    foe.vx = foe.vx + dx * inv * 220.0
    foe.vy = foe.vy + dy * inv * 220.0

    if foe.hp <= 0.0 {
      let x = foe.x
      let y = foe.y
      let reward = foe.reward
      foe.active = false
      game.add_score(reward)
      game.push_combo()
      game.defeats = game.defeats + 1
      game.spawn_ring(x, y, 9.0, 0.44, 1)
      game.burst_sparks(x, y, 14, 1)
    }
  }

  for bolt in game.bolts {
    if not(bolt.active) {
      continue
    }

    let d2 = @types.dist2(
      game.bells[bell_i].x,
      game.bells[bell_i].y,
      bolt.x,
      bolt.y,
    )
    if d2 <= rr2 {
      bolt.active = false
      game.emit_spark(
        bolt.x,
        bolt.y,
        @types.randf(-80.0, 80.0),
        @types.randf(-80.0, 80.0),
        @types.randf(0.2, 0.42),
        @types.randf(1.2, 3.0),
        2,
      )
    }
  }
}

///|
/// Returns the index of the bell within ring reach of the hero, or -1 if none is close enough.
fn @types.Game::find_nearest_bell(game : @types.Game) -> Int {
  let mut best = -1
  let mut best_d2 = @types.bell_ring_reach * @types.bell_ring_reach

  for i in 0..<@types.bell_count {
    let d2 = @types.dist2(
      game.hero.x,
      game.hero.y,
      game.bells[i].x,
      game.bells[i].y,
    )
    if d2 <= best_d2 {
      best_d2 = d2
      best = i
    }
  }

  best
}

///|
/// Returns a random spawn position along one of the four edges of the play area.
fn edge_spawn() -> (Float, Float) {
  let side = @types.randi(0, 3)

  if side == 0 {
    (
      @types.play_left - 120.0,
      @types.randf(@types.play_top - 20.0, @types.play_bottom + 20.0),
    )
  } else if side == 1 {
    (
      @types.play_right + 120.0,
      @types.randf(@types.play_top - 20.0, @types.play_bottom + 20.0),
    )
  } else if side == 2 {
    (
      @types.randf(@types.play_left - 20.0, @types.play_right + 20.0),
      @types.play_top - 120.0,
    )
  } else {
    (
      @types.randf(@types.play_left - 20.0, @types.play_right + 20.0),
      @types.play_bottom + 120.0,
    )
  }
}

///|
/// Spawns a wisp foe at a random edge position with stage-scaled HP.
fn @types.Game::spawn_wisp(game : @types.Game) -> Unit {
  let p = edge_spawn()

  game.spawn_foe(
    @types.foe_wisp,
    p.0,
    p.1,
    @types.randf(-20.0, 20.0),
    @types.randf(-20.0, 20.0),
    @types.randf(36.0, 44.0),
    @types.randf(36.0, 44.0),
    16.0 + Float::from_int(game.stage - 1) * 3.0,
    @types.randf(7.0, 13.0),
    @types.randf(1.2, 2.4),
    120,
  )
}

///|
/// Spawns a brute foe at a random edge position with stage-scaled HP.
fn @types.Game::spawn_brute(game : @types.Game) -> Unit {
  let p = edge_spawn()

  game.spawn_foe(
    @types.foe_brute,
    p.0,
    p.1,
    @types.randf(-12.0, 12.0),
    @types.randf(-12.0, 12.0),
    @types.randf(58.0, 74.0),
    @types.randf(58.0, 74.0),
    38.0 + Float::from_int(game.stage - 1) * 7.0,
    @types.randf(9.0, 15.0),
    @types.randf(2.0, 3.0),
    180,
  )
}

///|
/// Spawns a shaman foe at a random edge position with stage-scaled HP.
fn @types.Game::spawn_shaman(game : @types.Game) -> Unit {
  let p = edge_spawn()

  game.spawn_foe(
    @types.foe_shaman,
    p.0,
    p.1,
    @types.randf(-16.0, 16.0),
    @types.randf(-16.0, 16.0),
    @types.randf(50.0, 62.0),
    @types.randf(50.0, 62.0),
    22.0 + Float::from_int(game.stage - 1) * 4.0,
    @types.randf(8.0, 14.0),
    @types.randf(0.6, 1.5),
    160,
  )
}

///|
/// Spawns a relic pickup at a random edge position that can be rescued for spirit and shrine HP.
fn @types.Game::spawn_relic(game : @types.Game) -> Unit {
  let p = edge_spawn()

  game.spawn_foe(
    @types.foe_relic,
    p.0,
    p.1,
    @types.randf(-18.0, 18.0),
    @types.randf(-18.0, 18.0),
    @types.randf(34.0, 42.0),
    @types.randf(34.0, 42.0),
    1.0,
    @types.randf(8.0, 12.0),
    99.0,
    0,
  )
}

///|
/// Spawns a randomly composed wave of foes, with count and type mix scaled by current stage.
fn @types.Game::spawn_wave(game : @types.Game) -> Unit {
  let n = 1 + @types.randi(0, 1 + game.stage / 2)

  for _i in 0..<n {
    let roll = @types.randi(0, 99)
    if roll < 40 {
      game.spawn_wisp()
    } else if roll < 66 {
      game.spawn_brute()
    } else if roll < 88 {
      game.spawn_shaman()
    } else {
      game.spawn_relic()
    }
  }

  if @types.chance(14 + game.stage * 3) {
    game.spawn_relic()
  }
}

///|
/// Advances the spawn cooldown and triggers a new wave when it expires, scaling pressure by stage.
fn @types.Game::spawn_step(game : @types.Game, dt : Float) -> Unit {
  game.spawn_cd = game.spawn_cd - dt

  if game.spawn_cd <= 0.0 {
    game.spawn_wave()

    let pressure = Float::from_int(game.stage - 1) * 0.06
    game.spawn_cd = @types.randf(
      @types.maxf(@types.spawn_cd_min, @types.spawn_cd_max - pressure - 0.4),
      @types.spawn_cd_max - pressure,
    )
  }
}

///|
/// Initiates a dash in the input direction, spending spirit and granting brief invulnerability.
fn @types.Game::apply_dash(game : @types.Game) -> Unit {
  game.hero.dash_cd = @types.dash_cd_time
  game.hero.dash_t = @types.dash_time
  game.hero.invuln = @types.maxf(game.hero.invuln, 0.24)
  game.spirit = @types.maxf(0.0, game.spirit - @types.spirit_dash_cost)

  let mut dx = game.input_x
  let mut dy = game.input_y

  if dx.abs() < 0.01 && dy.abs() < 0.01 {
    dx = @math.sinf(game.hero.angle * 0.017)
    dy = -@math.cosf(game.hero.angle * 0.017)
  }

  let n2 = @types.maxf(0.01, dx * dx + dy * dy)
  let inv = Float::from_int(1) / n2.sqrt()
  game.hero.vx = dx * inv * @types.dash_speed
  game.hero.vy = dy * inv * @types.dash_speed

  game.hero.aura_t = 0.3
  game.spawn_ring(game.hero.x, game.hero.y, 14.0, 0.52, 2)
  game.burst_sparks(game.hero.x, game.hero.y, 18, 2)
}

///|
/// Processes hero movement, dash, bell-ring input, speed clamping, boundary clamping, and echo trails.
fn @types.Game::update_hero(game : @types.Game, dt : Float) -> Unit {
  if game.input_dash_press &&
    game.hero.dash_cd <= 0.0 &&
    game.spirit >= @types.spirit_dash_cost {
    game.apply_dash()
  }

  if game.input_ring_press {
    let bi = game.find_nearest_bell()
    if bi >= 0 {
      game.ring_bell(bi)
    }
  }

  game.hero.vx = game.hero.vx + game.input_x * @types.hero_accel * dt
  game.hero.vy = game.hero.vy + game.input_y * @types.hero_accel * dt

  let cx = @types.shrine_x() - game.hero.x
  let cy = @types.shrine_y() - game.hero.y
  game.hero.vx = game.hero.vx + cx * 0.6 * dt
  game.hero.vy = game.hero.vy + cy * 0.6 * dt

  let drag = @types.clampf(1.0 - @types.hero_drag * dt, 0.0, 1.0)
  game.hero.vx = game.hero.vx * drag
  game.hero.vy = game.hero.vy * drag

  let speed2 = game.hero.vx * game.hero.vx + game.hero.vy * game.hero.vy
  if speed2 > @types.hero_max_speed * @types.hero_max_speed {
    let inv = Float::from_int(1) / speed2.sqrt()
    game.hero.vx = game.hero.vx * inv * @types.hero_max_speed
    game.hero.vy = game.hero.vy * inv * @types.hero_max_speed
  }

  game.hero.x = game.hero.x + game.hero.vx * dt
  game.hero.y = game.hero.y + game.hero.vy * dt

  game.hero.x = @types.clampf(game.hero.x, @types.play_left, @types.play_right)
  game.hero.y = @types.clampf(game.hero.y, @types.play_top, @types.play_bottom)

  if game.hero.dash_t > 0.0 {
    game.spawn_echo(
      game.hero.x,
      game.hero.y,
      game.hero.w,
      game.hero.h,
      @types.randf(0.1, 0.24),
      game.hero.angle,
    )
  }

  game.hero.angle = @types.clampf(
    game.hero.vx / @types.hero_max_speed * 30.0,
    -30.0,
    30.0,
  )
}

///|
/// Fires a bolt from the given shaman foe aimed at the hero's current position.
fn @types.Game::fire_shaman_bolt(game : @types.Game, f : @types.Foe) -> Unit {
  let dx = game.hero.x - f.x
  let dy = game.hero.y - f.y
  let n2 = @types.maxf(1.0, dx * dx + dy * dy)
  let inv = Float::from_int(1) / n2.sqrt()

  game.spawn_bolt(
    f.x,
    f.y,
    dx * inv * @types.bolt_speed,
    dy * inv * @types.bolt_speed,
    @types.bolt_life,
    10.0,
    0,
  )
}

///|
/// Deactivates foe at index `i`, awards score, pushes the combo, and spawns death ring and spark effects.
fn @types.Game::kill_foe(game : @types.Game, i : Int, reward : Int, kind : Int) -> Unit {
  let x = game.foes[i].x
  let y = game.foes[i].y
  game.foes[i].active = false
  game.defeats = game.defeats + 1
  game.add_score(reward)
  game.push_combo()
  game.spawn_ring(x, y, 10.0, 0.44, kind)
  game.burst_sparks(x, y, 14 + @types.randi(0, 8), kind)
}

///|
/// Advances all active foes: movement, AI targeting, shrine contact damage, hero collision, and out-of-bounds removal.
fn @types.Game::update_foes(game : @types.Game, dt : Float) -> Unit {
  let dash_hit = game.hero.dash_t > 0.0

  for i in 0..<game.foes.length() {
    if not(game.foes[i].active) {
      continue
    }

    game.foes[i].life = game.foes[i].life - dt
    game.foes[i].phase = game.foes[i].phase + dt
    game.foes[i].marked = false

    let mut tx = @types.shrine_x()
    let mut ty = @types.shrine_y()

    if game.foes[i].kind == @types.foe_wisp {
      tx = game.hero.x
      ty = game.hero.y
    } else if game.foes[i].kind == @types.foe_shaman {
      let away_x = game.foes[i].x - @types.shrine_x()
      let away_y = game.foes[i].y - @types.shrine_y()
      let n2 = @types.maxf(1.0, away_x * away_x + away_y * away_y)
      let inv = Float::from_int(1) / n2.sqrt()
      tx = @types.shrine_x() + away_x * inv * 180.0
      ty = @types.shrine_y() + away_y * inv * 180.0
    }

    let dx = tx - game.foes[i].x
    let dy = ty - game.foes[i].y
    let n2 = @types.maxf(1.0, dx * dx + dy * dy)
    let inv = Float::from_int(1) / n2.sqrt()

    let accel : Float = if game.foes[i].kind == @types.foe_wisp {
      180.0
    } else if game.foes[i].kind == @types.foe_brute {
      100.0
    } else if game.foes[i].kind == @types.foe_shaman {
      120.0
    } else {
      74.0
    }

    game.foes[i].vx = game.foes[i].vx + dx * inv * accel * dt
    game.foes[i].vy = game.foes[i].vy + dy * inv * accel * dt

    if game.foes[i].kind == @types.foe_wisp {
      game.foes[i].vx = game.foes[i].vx +
        @math.sinf(game.foes[i].phase * 11.0) * 30.0 * dt
      game.foes[i].vy = game.foes[i].vy +
        @math.cosf(game.foes[i].phase * 9.0) * 26.0 * dt
    } else if game.foes[i].kind == @types.foe_shaman {
      game.foes[i].vx = game.foes[i].vx +
        @math.cosf(game.foes[i].phase * 4.2) * 40.0 * dt
      game.foes[i].vy = game.foes[i].vy +
        @math.sinf(game.foes[i].phase * 4.8) * 40.0 * dt
      game.foes[i].shot_cd = game.foes[i].shot_cd - dt
      if game.foes[i].shot_cd <= 0.0 {
        game.fire_shaman_bolt(game.foes[i])
        game.foes[i].shot_cd = @types.randf(0.9, 1.7)
      }
    } else if game.foes[i].kind == @types.foe_relic {
      game.foes[i].vx = game.foes[i].vx +
        @math.sinf(game.foes[i].phase * 6.0) * 34.0 * dt
      game.foes[i].vy = game.foes[i].vy +
        @math.cosf(game.foes[i].phase * 7.0) * 34.0 * dt
    }

    let speed_cap : Float = if game.foes[i].kind == @types.foe_wisp {
      260.0
    } else if game.foes[i].kind == @types.foe_brute {
      180.0
    } else if game.foes[i].kind == @types.foe_shaman {
      220.0
    } else {
      170.0
    }

    let v2 = game.foes[i].vx * game.foes[i].vx +
      game.foes[i].vy * game.foes[i].vy
    if v2 > speed_cap * speed_cap {
      let invv = Float::from_int(1) / v2.sqrt()
      game.foes[i].vx = game.foes[i].vx * invv * speed_cap
      game.foes[i].vy = game.foes[i].vy * invv * speed_cap
    }

    game.foes[i].x = game.foes[i].x + game.foes[i].vx * dt
    game.foes[i].y = game.foes[i].y + game.foes[i].vy * dt

    let outside = game.foes[i].life <= 0.0 ||
      game.foes[i].x < @types.play_left - 240.0 ||
      game.foes[i].x > @types.play_right + 240.0 ||
      game.foes[i].y < @types.play_top - 240.0 ||
      game.foes[i].y > @types.play_bottom + 240.0

    if outside {
      game.foes[i].active = false
      continue
    }

    if @types.is_relic(game.foes[i].kind) {
      let d2h = @types.dist2(
        game.hero.x,
        game.hero.y,
        game.foes[i].x,
        game.foes[i].y,
      )
      let rrh = @types.hero_hit_r(game.hero) + @types.foe_hit_r(game.foes[i])
      if d2h <= rrh * rrh {
        game.foes[i].active = false
        game.rescued = game.rescued + 1
        game.add_score(160)
        game.spirit = @types.minf(@types.spirit_max, game.spirit + 22.0)
        game.shrine_hp = @types.minf(
          @types.shrine_max_hp,
          game.shrine_hp + 14.0,
        )
        game.spawn_ring(game.hero.x, game.hero.y, 10.0, 0.44, 2)
        game.burst_sparks(game.hero.x, game.hero.y, 14, 2)
      }
      continue
    }

    let d2_shrine = @types.dist2(
      @types.shrine_x(),
      @types.shrine_y(),
      game.foes[i].x,
      game.foes[i].y,
    )
    let shrine_rr = @types.shrine_radius + @types.foe_hit_r(game.foes[i])
    if d2_shrine <= shrine_rr * shrine_rr {
      let dmg = if game.foes[i].kind == @types.foe_wisp {
        @types.shrine_drain_wisp
      } else if game.foes[i].kind == @types.foe_brute {
        @types.shrine_drain_brute
      } else {
        @types.shrine_drain_shaman
      }
      game.shrine_hp = @types.maxf(0.0, game.shrine_hp - dmg)
      game.foes[i].active = false
      game.shake_t = @types.maxf(game.shake_t, 0.44)
      game.flash_t = @types.maxf(game.flash_t, 0.2)
      game.burst_sparks(@types.shrine_x(), @types.shrine_y(), 18, 1)
      game.clear_combo()

      if game.shrine_hp <= 0.0 {
        game.state = GameOver
        game.result_t = 0.0
      }
      continue
    }

    let d2h = @types.dist2(
      game.hero.x,
      game.hero.y,
      game.foes[i].x,
      game.foes[i].y,
    )
    let rrh = @types.hero_hit_r(game.hero) + @types.foe_hit_r(game.foes[i])
    if d2h <= rrh * rrh {
      if dash_hit {
        game.kill_foe(i, game.foes[i].reward, 0)
      } else {
        let dmg : Float = if game.foes[i].kind == @types.foe_brute {
          14.0
        } else {
          10.0
        }
        game.hurt_hero(dmg)
        game.foes[i].hp = game.foes[i].hp - 10.0
        if game.foes[i].hp <= 0.0 {
          game.kill_foe(i, game.foes[i].reward, 1)
        }
      }
    }
  }
}

///|
/// Advances all active bolts, removing those that expire or leave bounds, and applies damage on hero collision.
fn @types.Game::update_bolts(game : @types.Game, dt : Float) -> Unit {
  for bolt in game.bolts {
    if not(bolt.active) {
      continue
    }

    bolt.x = bolt.x + bolt.vx * dt
    bolt.y = bolt.y + bolt.vy * dt
    bolt.life = bolt.life - dt

    let dead = bolt.life <= 0.0 ||
      bolt.x < @types.play_left - 120.0 ||
      bolt.x > @types.play_right + 120.0 ||
      bolt.y < @types.play_top - 120.0 ||
      bolt.y > @types.play_bottom + 120.0

    if dead {
      bolt.active = false
      continue
    }

    let d2 = @types.dist2(game.hero.x, game.hero.y, bolt.x, bolt.y)
    let rr = @types.hero_hit_r(game.hero) + 8.0
    if d2 <= rr * rr {
      bolt.active = false
      game.hurt_hero(bolt.dmg)
      game.emit_spark(
        game.hero.x,
        game.hero.y,
        @types.randf(-90.0, 90.0),
        @types.randf(-90.0, 90.0),
        @types.randf(0.2, 0.46),
        @types.randf(1.2, 3.0),
        1,
      )
    }
  }
}

///|
/// Advances all active spark, ring, and echo effects, expiring those whose lifetimes reach zero.
fn @types.Game::update_effects(game : @types.Game, dt : Float) -> Unit {
  for spark in game.sparks {
    if not(spark.active) {
      continue
    }

    spark.x = spark.x + spark.vx * dt
    spark.y = spark.y + spark.vy * dt
    spark.life = spark.life - dt

    if spark.kind == 3 {
      spark.vy = spark.vy + 12.0 * dt
    }

    if spark.life <= 0.0 {
      spark.active = false
    }
  }

  for ring in game.rings {
    if not(ring.active) {
      continue
    }

    ring.life = ring.life - dt
    ring.r = ring.r + (130.0 + Float::from_int(ring.kind) * 44.0) * dt

    if ring.life <= 0.0 {
      ring.active = false
    }
  }

  for echo_item in game.echoes {
    if not(echo_item.active) {
      continue
    }

    echo_item.life = echo_item.life - dt
    if echo_item.life <= 0.0 {
      echo_item.active = false
    }
  }
}

///|
/// Decrements bell cooldowns and glow timers, and recomputes the charge fraction for each bell.
fn @types.Game::update_bells(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<@types.bell_count {
    game.bells[i].cooldown = @types.maxf(0.0, game.bells[i].cooldown - dt)
    game.bells[i].glow = @types.maxf(0.0, game.bells[i].glow - dt)

    if game.bells[i].cooldown <= 0.0 {
      game.bells[i].charge = 1.0
    } else {
      game.bells[i].charge = @types.clampf(
        1.0 - game.bells[i].cooldown / @types.bell_cd_time,
        0.0,
        1.0,
      )
    }
  }
}

///|
/// Randomly emits upward-drifting ambient spark particles along the top of the play area.
fn @types.Game::emit_ambient(game : @types.Game, dt : Float) -> Unit {
  let tries = (dt * 200.0).to_int().clamp(min=1, max=12)

  for _i in 0..<tries {
    if @types.chance(28) {
      game.emit_spark(
        @types.randf(@types.play_left, @types.play_right),
        @types.randf(@types.play_top - 20.0, @types.play_top + 60.0),
        @types.randf(-40.0, 40.0),
        @types.randf(22.0, 90.0),
        @types.randf(0.8, 1.6),
        @types.randf(0.8, 2.2),
        3,
      )
    }
  }
}

///|
/// Advances global timers and hero sub-timers by `dt`, including combo decay.
fn @types.Game::update_timers(game : @types.Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  game.hint_t = game.hint_t + dt
  game.wave_t = game.wave_t + dt

  game.hero.dash_cd = @types.maxf(0.0, game.hero.dash_cd - dt)
  game.hero.dash_t = @types.maxf(0.0, game.hero.dash_t - dt)
  game.hero.invuln = @types.maxf(0.0, game.hero.invuln - dt)
  game.hero.hurt_t = @types.maxf(0.0, game.hero.hurt_t - dt)
  game.hero.aura_t = @types.maxf(0.0, game.hero.aura_t - dt)
  game.hero.anim_t = game.hero.anim_t + dt

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
/// Clears all entities, resets all counters, and sets the game to the Title state.
fn @types.Game::init_title_scene(game : @types.Game) -> Unit {
  game.clear_foes()
  game.clear_bolts()
  game.clear_sparks()
  game.clear_rings()
  game.clear_echoes()
  game.reset_bells()
  game.reset_hero()

  game.state = Title
  game.stage = 1
  game.stage_goal = @types.stage_goal_base
  game.score = 0
  game.defeats = 0
  game.rescued = 0
  game.combo = 0
  game.combo_t = 0.0

  game.shrine_hp = @types.shrine_max_hp
  game.spirit = @types.spirit_max
  game.time_left = @types.stage_time_base

  game.spawn_cd = 0.62
  game.wave_t = 0.0

  game.flash_t = 0.0
  game.shake_t = 0.0
  game.result_t = 0.0
  game.hint_t = 0.0
  game.time_s = 0.0
}

///|
/// Resets entities, sets the Play state for the given stage, and scales goal, time, and starting resources.
fn @types.Game::start_stage(game : @types.Game, stage : Int) -> Unit {
  game.clear_foes()
  game.clear_bolts()
  game.clear_sparks()
  game.clear_rings()
  game.clear_echoes()
  game.reset_bells()
  game.reset_hero()

  game.state = Play
  game.stage = stage
  game.stage_goal = @types.stage_goal_base +
    (stage - 1) * @types.stage_goal_bonus

  game.time_left = @types.stage_time_base +
    Float::from_int(stage - 1) * @types.stage_time_bonus
  game.shrine_hp = @types.minf(@types.shrine_max_hp, game.shrine_hp + 24.0)
  game.spirit = @types.minf(@types.spirit_max, game.spirit + 30.0)

  game.spawn_cd = 0.5
  game.wave_t = 0.0
  game.clear_combo()

  game.flash_t = 0.0
  game.shake_t = 0.0
  game.result_t = 0.0
  game.hint_t = 0.0

  game.spawn_ring(@types.shrine_x(), @types.shrine_y(), 18.0, 0.72, 2)
  game.burst_sparks(@types.shrine_x(), @types.shrine_y(), 28, 2)
}

///|
/// Resets the run score and statistics, then starts stage 1.
fn @types.Game::start_run(game : @types.Game) -> Unit {
  game.score = 0
  game.defeats = 0
  game.rescued = 0
  game.shrine_hp = @types.shrine_max_hp
  game.spirit = @types.spirit_max
  game.start_stage(1)
}

///|
/// Runs one play-state simulation tick: ticks time, updates hero, bells, spawns, foes, bolts, effects, and checks win/lose conditions.
fn @types.Game::update_play(game : @types.Game, dt : Float) -> Unit {
  game.time_left = @types.maxf(0.0, game.time_left - dt)

  game.update_hero(dt)
  game.update_bells(dt)

  game.spawn_step(dt)
  game.update_foes(dt)
  game.update_bolts(dt)

  game.emit_ambient(dt)
  game.update_effects(dt)

  game.spirit = @types.minf(
    @types.spirit_max,
    game.spirit + @types.spirit_regen * dt,
  )

  if game.time_left <= 0.0 {
    game.state = GameOver
    game.result_t = 0.0
  }

  if game.shrine_hp <= 0.0 {
    game.state = GameOver
    game.result_t = 0.0
  }

  if game.state == Play && game.score >= game.stage_goal {
    game.state = StageClear
    game.result_t = 0.0
    game.add_score(280 + game.stage * 120)
    game.shrine_hp = @types.minf(@types.shrine_max_hp, game.shrine_hp + 14.0)
    game.spirit = @types.minf(@types.spirit_max, game.spirit + 24.0)
    game.spawn_ring(@types.shrine_x(), @types.shrine_y(), 20.0, 0.84, 2)
    game.burst_sparks(@types.shrine_x(), @types.shrine_y(), 32, 2)
  }
}

///|
/// Updates ambient effects and bells during the title screen, and starts a run on start input.
fn @types.Game::update_title(game : @types.Game, dt : Float) -> Unit {
  game.emit_ambient(dt)
  game.update_effects(dt)
  game.update_bells(dt)

  if @types.chance(6) {
    let bi = @types.randi(0, @types.bell_count - 1)
    game.bells[bi].glow = @types.maxf(game.bells[bi].glow, 0.24)
  }

  if game.input_restart_press {
    game.start_run()
  }
}

///|
/// Runs the stage-clear celebration state, emitting sparks and advancing to the next stage when ready.
fn @types.Game::update_stage_clear(game : @types.Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  game.emit_ambient(dt)
  game.update_effects(dt)
  game.update_bells(dt)

  if @types.chance(34) {
    game.emit_spark(
      @types.shrine_x() + @types.randf(-40.0, 40.0),
      @types.shrine_y() + @types.randf(-40.0, 40.0),
      @types.randf(-50.0, 50.0),
      @types.randf(-90.0, -20.0),
      @types.randf(0.3, 0.7),
      @types.randf(1.5, 4.0),
      2,
    )
  }

  if game.input_restart_press || game.result_t >= @types.stage_clear_wait {
    game.start_stage(game.stage + 1)
  }
}

///|
/// Updates ambient effects during the game-over state and returns to the title on restart input.
fn @types.Game::update_game_over(game : @types.Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  game.emit_ambient(dt)
  game.update_effects(dt)
  game.update_bells(dt)

  if game.input_restart_press {
    game.init_title_scene()
  }
}

///|
/// Advances one simulation frame, including input and state updates.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.mouse_x = Float::from_int(@raylib.get_mouse_x())
  game.mouse_y = Float::from_int(@raylib.get_mouse_y())
  game.touch_count = @raylib.get_touch_point_count()
  game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
    game.touch_count > 0

  match game.state {
    Title => game.update_title_input()
    Play => game.update_play_input()
    StageClear | GameOver => game.update_result_input()
  }

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
