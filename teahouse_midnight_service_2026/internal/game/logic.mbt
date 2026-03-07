///|
fn @types.Game::clear_customers(game : @types.Game) -> Unit {
  for customer in game.customers {
    customer.active = false
    customer.tea_type = Jasmine
    customer.slot = 0
    customer.x = 0.0
    customer.y = 0.0
    customer.patience = 0.0
    customer.patience_max = 0.0
    customer.life = 0.0
    customer.reward = 0
    customer.mood = 0.0
    customer.served_t = 0.0
    customer.angry = false
  }
}

///|
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
fn @types.Game::clear_shadows(game : @types.Game) -> Unit {
  for shadow in game.shadows {
    shadow.active = false
    shadow.x = 0.0
    shadow.y = 0.0
    shadow.w = 0.0
    shadow.h = 0.0
    shadow.life = 0.0
    shadow.rot = 0.0
  }
}

///|
fn @types.Game::reset_player(game : @types.Game) -> Unit {
  game.player.x = 628.0
  game.player.y = 468.0
  game.player.vx = 0.0
  game.player.vy = 0.0
  game.player.w = @types.player_w
  game.player.h = @types.player_h
  game.player.angle = 0.0
  game.player.dash_cd = 0.0
  game.player.dash_t = 0.0
  game.player.interact_t = 0.0
  game.player.anim_t = 0.0
  game.player.carry_water = false
  game.player.carry_leaf = None
}

///|
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
fn @types.Game::alloc_shadow(game : @types.Game) -> Int {
  for i, slot in game.shadows {
    if !slot.active {
      break i
    }
  } nobreak {
    let mut best = 0
    let mut best_life = game.shadows[0].life
    for i in 1..<game.shadows.length() {
      if game.shadows[i].life < best_life {
        best_life = game.shadows[i].life
        best = i
      }
    }
    best
  }
}

///|
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
fn @types.Game::burst_sparks(
  game : @types.Game,
  x : Float,
  y : Float,
  n : Int,
  kind : Int,
) -> Unit {
  for _i in 0..<n {
    game.emit_spark(
      x + @types.randf(-14.0, 14.0),
      y + @types.randf(-14.0, 14.0),
      @types.randf(-230.0, 230.0),
      @types.randf(-230.0, 230.0),
      @types.randf(0.24, 1.02),
      @types.randf(1.0, 4.4),
      kind,
    )
  }
}

///|
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
fn @types.Game::spawn_shadow(
  game : @types.Game,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  life : Float,
  rot : Float,
) -> Unit {
  let i = game.alloc_shadow()
  game.shadows[i].active = true
  game.shadows[i].x = x
  game.shadows[i].y = y
  game.shadows[i].w = w
  game.shadows[i].h = h
  game.shadows[i].life = life
  game.shadows[i].rot = rot
}

///|
fn @types.Game::score_gain(game : @types.Game, base : Int) -> Int {
  let bonus = base * game.combo / 5
  base + bonus
}

///|
fn @types.Game::add_score(game : @types.Game, base : Int) -> Unit {
  let g = game.score_gain(base)
  game.score = game.score + g
  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
fn @types.Game::push_combo(game : @types.Game) -> Unit {
  game.combo = (game.combo + 1).clamp(min=0, max=30)
  game.combo_t = 3.8
}

///|
fn @types.Game::clear_combo(game : @types.Game) -> Unit {
  game.combo = 0
  game.combo_t = 0.0
}

///|
fn @types.Game::slot_used(game : @types.Game, slot : Int) -> Bool {
  for customer in game.customers {
    if customer.active && customer.slot == slot {
      return true
    }
  }
  false
}

///|
fn @types.Game::find_open_slot(game : @types.Game) -> Int {
  for s in 0..<@types.customer_slots {
    if !game.slot_used(s) {
      return s
    }
  }
  -1
}

///|
fn @types.Game::alloc_customer(game : @types.Game) -> Int {
  for i, slot in game.customers {
    if !slot.active {
      break i
    }
  } nobreak {
    let mut best = 0
    let mut best_patience = game.customers[0].patience
    for i in 1..<game.customers.length() {
      if game.customers[i].patience < best_patience {
        best_patience = game.customers[i].patience
        best = i
      }
    }
    best
  }
}

///|
fn customer_base_patience(stage : Int) -> Float {
  @types.maxf(8.0, 20.0 - Float::from_int(stage - 1) * 1.1)
}

///|
fn pick_tea_type(stage : Int) -> @types.Tea {
  let r = @types.randi(0, 99)

  if stage <= 1 {
    if r < 40 {
      Jasmine
    } else if r < 72 {
      Oolong
    } else if r < 86 {
      Matcha
    } else {
      Berry
    }
  } else if stage <= 3 {
    if r < 24 {
      Jasmine
    } else if r < 46 {
      Oolong
    } else if r < 66 {
      Puer
    } else if r < 84 {
      Matcha
    } else {
      Berry
    }
  } else {
    @types.tea_from_index(@types.randi(0, @types.tea_count - 1))
  }
}

///|
fn @types.Game::spawn_customer(game : @types.Game) -> Unit {
  let slot = game.find_open_slot()
  if slot < 0 {
    return
  }

  let i = game.alloc_customer()
  let tea = pick_tea_type(game.stage)
  let p = @types.customer_slot_pos(slot)

  let base_pat = customer_base_patience(game.stage)
  let patience_max = base_pat + @types.randf(-2.0, 4.0)

  game.customers[i].active = true
  game.customers[i].tea_type = tea
  game.customers[i].slot = slot
  game.customers[i].x = p.0 + @types.randf(-5.0, 5.0)
  game.customers[i].y = p.1 + @types.randf(-5.0, 5.0)
  game.customers[i].patience_max = @types.maxf(6.0, patience_max)
  game.customers[i].patience = game.customers[i].patience_max
  game.customers[i].life = 0.0
  game.customers[i].reward = 96 + @types.tea_index(tea) * 24 + game.stage * 12
  game.customers[i].mood = 1.0
  game.customers[i].served_t = 0.0
  game.customers[i].angry = false

  game.burst_sparks(game.customers[i].x, game.customers[i].y, 10, 0)
}

///|
fn nearest_leaf_station(px : Float, py : Float, reach : Float) -> Int {
  for tea in 0..<@types.tea_count; best = -1, best_d2 = reach * reach {
    let d2 = @types.dist2(px, py, @types.leaf_x(), @types.leaf_y(tea))
    if d2 <= best_d2 {
      continue tea, d2
    }
  } nobreak {
    best
  }
}

///|
fn @types.Game::nearest_customer(
  game : @types.Game,
  x : Float,
  y : Float,
  reach : Float,
) -> Int {
  for i in 0..<game.customers.length(); best = -1, best_d2 = reach * reach {
    if !game.customers[i].active {
      continue
    }

    let d2 = @types.dist2(x, y, game.customers[i].x, game.customers[i].y)
    if d2 <= best_d2 {
      continue i, d2
    }
  } nobreak {
    best
  }
}

///|
fn @types.Game::start_brew(game : @types.Game) -> Unit {
  game.brew_active = true
  game.brew_t = @types.maxf(
    @types.brew_time_min,
    @types.brew_time_base - Float::from_int(game.stage - 1) * 0.12,
  )
  match game.player.carry_leaf {
    Some(leaf) => game.brew_type = leaf
    None => ()
  }
  game.player.carry_water = false
  game.player.carry_leaf = None

  game.spawn_ring(@types.brew_x, @types.brew_y, 12.0, 0.42, 0)
  game.burst_sparks(@types.brew_x, @types.brew_y, 12, 0)
}

///|
fn @types.Game::finish_brew(game : @types.Game) -> Unit {
  game.brew_active = false
  game.ready_cup = Some(game.brew_type)

  game.spawn_ring(@types.brew_x, @types.brew_y, 16.0, 0.7, 2)
  game.burst_sparks(@types.brew_x, @types.brew_y, 22, 2)
}

///|
fn @types.Game::serve_customer(game : @types.Game, ci : Int) -> Unit {
  if ci < 0 || ci >= game.customers.length() {
    return
  }

  let c = game.customers[ci]
  if !c.active {
    return
  }

  if game.ready_cup == Some(c.tea_type) {
    game.customers[ci].active = false
    game.served = game.served + 1
    game.add_score(game.customers[ci].reward)
    game.reputation = @types.minf(@types.reputation_max, game.reputation + 6.0)
    game.focus = @types.minf(@types.focus_max, game.focus + 10.0)
    game.push_combo()

    game.spawn_ring(c.x, c.y, 10.0, 0.5, 2)
    game.burst_sparks(c.x, c.y, 18, 2)
  } else {
    game.customers[ci].angry = true
    game.customers[ci].mood = @types.maxf(0.0, game.customers[ci].mood - 0.4)
    game.reputation = @types.maxf(
      0.0,
      game.reputation - @types.wrong_serve_penalty,
    )
    game.focus = @types.maxf(0.0, game.focus - 6.0)
    game.clear_combo()

    game.flash_t = @types.maxf(game.flash_t, 0.22)
    game.shake_t = @types.maxf(game.shake_t, 0.2)

    game.burst_sparks(c.x, c.y, 16, 1)
  }

  game.ready_cup = None
  game.player.interact_t = 0.2
}

///|
fn @types.Game::apply_interact(game : @types.Game) -> Unit {
  let px = game.player.x
  let py = game.player.y

  if @types.near_station(
      px, py, @types.kettle_x, @types.kettle_y, @types.interact_reach,
    ) {
    game.player.carry_water = true
    game.player.interact_t = 0.22
    game.spawn_ring(@types.kettle_x, @types.kettle_y, 10.0, 0.4, 0)
    game.burst_sparks(@types.kettle_x, @types.kettle_y, 10, 0)
    return
  }

  let leaf = nearest_leaf_station(px, py, @types.interact_reach)
  if leaf >= 0 {
    game.player.carry_leaf = Some(@types.tea_from_index(leaf))
    game.player.interact_t = 0.22
    game.spawn_ring(@types.leaf_x(), @types.leaf_y(leaf), 8.0, 0.36, 0)
    game.burst_sparks(@types.leaf_x(), @types.leaf_y(leaf), 8, 0)
    return
  }

  if @types.near_station(
      px, py, @types.brew_x, @types.brew_y, @types.interact_reach,
    ) {
    if !game.brew_active &&
      game.ready_cup is None &&
      game.player.carry_water &&
      !(game.player.carry_leaf is None) {
      game.start_brew()
      game.player.interact_t = 0.26
    }
    return
  }

  if !(game.ready_cup is None) &&
    @types.near_station(
      px,
      py,
      @types.counter_x,
      @types.counter_y,
      @types.interact_reach + 10.0,
    ) {
    let ci = game.nearest_customer(px, py, @types.serve_reach)
    if ci >= 0 {
      game.serve_customer(ci)
    }
    return
  }
}

///|
fn @types.Game::apply_dash(game : @types.Game) -> Unit {
  if game.player.dash_cd > 0.0 || game.focus < @types.dash_focus_cost {
    return
  }

  let mut dx = game.input_x
  let mut dy = game.input_y

  if dx.abs() < 0.01 && dy.abs() < 0.01 {
    dx = @math.sinf(game.player.angle * 0.017)
    dy = -@math.cosf(game.player.angle * 0.017)
  }

  let n2 = @types.maxf(0.01, dx * dx + dy * dy)
  let inv = Float::from_int(1) / n2.sqrt()

  game.player.vx = dx * inv * @types.dash_speed
  game.player.vy = dy * inv * @types.dash_speed

  game.player.dash_t = @types.dash_time
  game.player.dash_cd = @types.dash_cd_time
  game.focus = @types.maxf(0.0, game.focus - @types.dash_focus_cost)

  game.spawn_ring(game.player.x, game.player.y, 14.0, 0.46, 2)
  game.burst_sparks(game.player.x, game.player.y, 16, 2)
}

///|
fn @types.Game::update_player(game : @types.Game, dt : Float) -> Unit {
  if game.input_dash_press {
    game.apply_dash()
  }

  if game.input_interact_press {
    game.apply_interact()
  }

  let speed_mul : Float = if game.focus_mode { 1.15 } else { 1.0 }

  game.player.vx = game.player.vx +
    game.input_x * @types.player_accel * speed_mul * dt
  game.player.vy = game.player.vy +
    game.input_y * @types.player_accel * speed_mul * dt

  let drag = @types.clampf(1.0 - @types.player_drag * dt, 0.0, 1.0)
  game.player.vx = game.player.vx * drag
  game.player.vy = game.player.vy * drag

  let cap = @types.player_max_speed * speed_mul
  game.player.vx = @types.clampf(game.player.vx, -cap, cap)
  game.player.vy = @types.clampf(game.player.vy, -cap, cap)

  game.player.x = game.player.x + game.player.vx * dt
  game.player.y = game.player.y + game.player.vy * dt

  game.player.x = @types.clampf(
    game.player.x,
    @types.play_left,
    @types.play_right,
  )
  game.player.y = @types.clampf(
    game.player.y,
    @types.play_top,
    @types.play_bottom,
  )

  if game.player.dash_t > 0.0 {
    game.spawn_shadow(
      game.player.x,
      game.player.y,
      game.player.w,
      game.player.h,
      @types.randf(0.1, 0.22),
      game.player.angle,
    )
  }

  game.player.angle = @types.clampf(
    game.player.vx / @types.maxf(1.0, cap) * 24.0,
    -24.0,
    24.0,
  )
}

///|
fn @types.Game::customer_drain_rate(game : @types.Game) -> Float {
  let base : Float = 1.0 + Float::from_int(game.stage - 1) * 0.1
  if game.focus_mode {
    base * 0.58
  } else {
    base
  }
}

///|
fn @types.Game::update_customers(game : @types.Game, dt : Float) -> Unit {
  let drain = game.customer_drain_rate()

  for customer in game.customers {
    if !customer.active {
      continue
    }

    customer.life = customer.life + dt
    customer.patience = customer.patience - drain * dt
    customer.served_t = @types.maxf(0.0, customer.served_t - dt)

    if customer.patience <= customer.patience_max * 0.25 {
      customer.angry = true
    }

    customer.mood = @types.clampf(
      customer.patience / @types.maxf(1.0, customer.patience_max),
      0.0,
      1.0,
    )

    if customer.patience <= 0.0 {
      let x = customer.x
      let y = customer.y

      customer.active = false
      game.missed = game.missed + 1
      game.reputation = @types.maxf(0.0, game.reputation - @types.miss_penalty)
      game.focus = @types.maxf(0.0, game.focus - 10.0)
      game.clear_combo()

      game.flash_t = @types.maxf(game.flash_t, 0.22)
      game.shake_t = @types.maxf(game.shake_t, 0.28)

      game.burst_sparks(x, y, 18, 1)
      game.spawn_ring(x, y, 10.0, 0.45, 1)
    }
  }
}

///|
fn @types.Game::update_brew(game : @types.Game, dt : Float) -> Unit {
  if !game.brew_active {
    return
  }

  let speed : Float = if game.focus_mode { 1.36 } else { 1.0 }
  game.brew_t = game.brew_t - dt * speed

  if @types.chance(16) {
    game.emit_spark(
      @types.brew_x + @types.randf(-14.0, 14.0),
      @types.brew_y + @types.randf(-14.0, 14.0),
      @types.randf(-30.0, 30.0),
      @types.randf(-90.0, -20.0),
      @types.randf(0.2, 0.5),
      @types.randf(1.2, 3.0),
      0,
    )
  }

  if game.brew_t <= 0.0 {
    game.finish_brew()
  }
}

///|
fn @types.Game::update_focus(game : @types.Game, dt : Float) -> Unit {
  game.focus_mode = false

  if game.input_focus_hold && game.focus > 0.0 {
    game.focus_mode = true
    game.focus = @types.maxf(0.0, game.focus - @types.focus_drain * dt)
  } else {
    game.focus = @types.minf(
      @types.focus_max,
      game.focus + @types.focus_regen * dt,
    )
  }
}

///|
fn @types.Game::update_effects(game : @types.Game, dt : Float) -> Unit {
  for spark in game.sparks {
    if !spark.active {
      continue
    }

    spark.x = spark.x + spark.vx * dt
    spark.y = spark.y + spark.vy * dt
    spark.life = spark.life - dt

    if spark.kind == 3 {
      spark.vy = spark.vy + 14.0 * dt
    }

    if spark.life <= 0.0 {
      spark.active = false
    }
  }

  for ring in game.rings {
    if !ring.active {
      continue
    }

    ring.life = ring.life - dt
    ring.r = ring.r + (120.0 + Float::from_int(ring.kind) * 38.0) * dt

    if ring.life <= 0.0 {
      ring.active = false
    }
  }

  for shadow in game.shadows {
    if !shadow.active {
      continue
    }

    shadow.life = shadow.life - dt
    if shadow.life <= 0.0 {
      shadow.active = false
    }
  }
}

///|
fn @types.Game::emit_ambient(game : @types.Game, dt : Float) -> Unit {
  let tries = (dt * 220.0).to_int().clamp(min=1, max=10)

  for _i in 0..<tries {
    if @types.chance(24) {
      game.emit_spark(
        @types.randf(@types.play_left, @types.play_right),
        @types.play_top - @types.randf(20.0, 110.0),
        @types.randf(-30.0, 30.0),
        @types.randf(24.0, 84.0),
        @types.randf(0.8, 1.6),
        @types.randf(0.8, 2.2),
        3,
      )
    }
  }
}

///|
fn @types.Game::spawn_step(game : @types.Game, dt : Float) -> Unit {
  game.spawn_cd = game.spawn_cd - dt

  if game.spawn_cd <= 0.0 {
    game.spawn_customer()

    if game.stage >= 3 && @types.chance(32) {
      game.spawn_customer()
    }

    let pressure = Float::from_int(game.stage - 1) * 0.08
    let lo = @types.maxf(
      @types.spawn_cd_min,
      @types.spawn_cd_max - pressure - 0.6,
    )
    let hi = @types.maxf(lo + 0.1, @types.spawn_cd_max - pressure)
    game.spawn_cd = @types.randf(lo, hi)
  }
}

///|
fn @types.Game::update_timers(game : @types.Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  game.hint_t = game.hint_t + dt

  game.player.dash_cd = @types.maxf(0.0, game.player.dash_cd - dt)
  game.player.dash_t = @types.maxf(0.0, game.player.dash_t - dt)
  game.player.interact_t = @types.maxf(0.0, game.player.interact_t - dt)
  game.player.anim_t = game.player.anim_t + dt

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
fn @types.Game::start_stage(game : @types.Game, stage : Int) -> Unit {
  game.clear_customers()
  game.clear_sparks()
  game.clear_rings()
  game.clear_shadows()
  game.reset_player()

  game.state = Play
  game.stage = stage
  game.stage_goal = @types.stage_goal_base +
    (stage - 1) * @types.stage_goal_bonus

  game.time_left = @types.stage_time_base +
    Float::from_int(stage - 1) * @types.stage_time_bonus
  game.reputation = @types.minf(@types.reputation_max, game.reputation + 18.0)
  game.focus = @types.minf(@types.focus_max, game.focus + 26.0)

  game.spawn_cd = 0.6
  game.brew_active = false
  game.brew_t = 0.0
  game.brew_type = Jasmine
  game.ready_cup = None
  game.focus_mode = false
  game.clear_combo()

  game.flash_t = 0.0
  game.shake_t = 0.0
  game.result_t = 0.0
  game.hint_t = 0.0

  game.spawn_ring(@types.brew_x, @types.brew_y, 16.0, 0.68, 2)
  game.burst_sparks(@types.brew_x, @types.brew_y, 22, 2)
}

///|
fn @types.Game::start_run(game : @types.Game) -> Unit {
  game.score = 0
  game.served = 0
  game.missed = 0
  game.reputation = @types.reputation_max
  game.focus = @types.focus_max
  game.start_stage(1)
}

///|
fn @types.Game::update_play(game : @types.Game, dt : Float) -> Unit {
  game.time_left = @types.maxf(0.0, game.time_left - dt)

  game.update_focus(dt)
  game.update_player(dt)
  game.update_brew(dt)
  game.spawn_step(dt)
  game.update_customers(dt)

  game.emit_ambient(dt)
  game.update_effects(dt)

  if game.reputation <= 0.0 || game.time_left <= 0.0 {
    game.state = GameOver
    game.result_t = 0.0
  }

  if game.state == Play && game.score >= game.stage_goal {
    game.state = StageClear
    game.result_t = 0.0
    game.add_score(@types.stage_clear_bonus + game.stage * 120)
    game.reputation = @types.minf(@types.reputation_max, game.reputation + 12.0)
    game.focus = @types.minf(@types.focus_max, game.focus + 18.0)

    game.spawn_ring(@types.counter_x, @types.counter_y, 20.0, 0.84, 2)
    game.burst_sparks(@types.counter_x, @types.counter_y, 30, 2)
  }
}

///|
fn @types.Game::update_title(game : @types.Game, dt : Float) -> Unit {
  game.emit_ambient(dt)
  game.update_effects(dt)

  if game.input_restart_press {
    game.start_run()
  }
}

///|
fn @types.Game::update_stage_clear(game : @types.Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt

  game.emit_ambient(dt)
  game.update_effects(dt)

  if @types.chance(28) {
    game.emit_spark(
      @types.counter_x + @types.randf(-24.0, 24.0),
      @types.counter_y + @types.randf(-20.0, 20.0),
      @types.randf(-44.0, 44.0),
      @types.randf(-90.0, -14.0),
      @types.randf(0.3, 0.64),
      @types.randf(1.8, 4.0),
      2,
    )
  }

  if game.input_restart_press || game.result_t >= @types.stage_clear_wait {
    game.start_stage(game.stage + 1)
  }
}

///|
fn @types.Game::update_game_over(game : @types.Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt

  game.emit_ambient(dt)
  game.update_effects(dt)

  if game.input_restart_press {
    @types.init_title_scene(game)
  }
}

///|
/// Advances one frame of simulation, input handling, and state transitions.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  // Read mouse/touch state and store in game fields
  game.mouse_x = Float::from_int(@raylib.get_mouse_x())
  game.mouse_y = Float::from_int(@raylib.get_mouse_y())
  game.touch_count = @raylib.get_touch_point_count()
  game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
    game.touch_count > 0

  // Dispatch input based on state
  match game.state {
    Title => game.update_title_input()
    Play => game.update_play_input()
    _ => game.update_result_input()
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
