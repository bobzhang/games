///|
fn @types.Game::clear_objs(game : @types.Game) -> Unit {
  for obj in game.objs {
    obj.active = false
    obj.kind = Wall
    obj.lane = 0
    obj.z = 0.0
    obj.y_off = 0.0
    obj.w = 0.0
    obj.h = 0.0
    obj.phase_only = 0
    obj.spin = 0.0
    obj.hit_lock = 0.0
  }
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
fn @types.Game::clear_trails(game : @types.Game) -> Unit {
  for trail in game.trails {
    trail.active = false
    trail.x = 0.0
    trail.y = 0.0
    trail.w = 0.0
    trail.h = 0.0
    trail.life = 0.0
    trail.beta = false
  }
}

///|
fn reset_hero(hero : @types.Player) -> Unit {
  hero.lane = 2
  hero.lane_f = @types.lane_world_x(hero.lane)
  hero.y = 0.0
  hero.vy = 0.0
  hero.jump_buf = 0.0
  hero.grounded = true
  hero.invuln_t = 0.0
  hero.hurt_t = 0.0
  hero.anim_t = 0.0
}

///|
fn @types.Game::alloc_obj_slot(game : @types.Game) -> Int {
  for i, slot in game.objs {
    if !slot.active {
      break i
    }
  } nobreak {
    let best = @utils.min_index_by(game.objs, fn(a, b) { a.z < b.z })
    if best >= 0 {
      best
    } else {
      0
    }
  }
}

///|
fn @types.Game::alloc_particle_slot(game : @types.Game) -> Int {
  for i, slot in game.particles {
    if !slot.active {
      break i
    }
  } nobreak {
    let best = @utils.min_index_by(
      game.particles,
      fn(a, b) { a.life < b.life },
    )
    if best >= 0 {
      best
    } else {
      0
    }
  }
}

///|
fn @types.Game::alloc_trail_slot(game : @types.Game) -> Int {
  for i, slot in game.trails {
    if !slot.active {
      break i
    }
  } nobreak {
    let best = @utils.min_index_by(
      game.trails,
      fn(a, b) { a.life < b.life },
    )
    if best >= 0 {
      best
    } else {
      0
    }
  }
}

///|
fn @types.Game::spawn_obj(
  game : @types.Game,
  kind : @types.ObjKind,
  lane : Int,
  z : Float,
  y_off : Float,
  w : Float,
  h : Float,
  phase_only : Int,
) -> Unit {
  let i = game.alloc_obj_slot()
  game.objs[i].active = true
  game.objs[i].kind = kind
  game.objs[i].lane = lane
  game.objs[i].z = z
  game.objs[i].y_off = y_off
  game.objs[i].w = w
  game.objs[i].h = h
  game.objs[i].phase_only = phase_only
  game.objs[i].spin = @types.randf(0.0, 6.28)
  game.objs[i].hit_lock = 0.0
}

///|
fn @types.Game::spawn_particle(
  game : @types.Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : Int,
) -> Unit {
  let i = game.alloc_particle_slot()
  game.particles[i].active = true
  game.particles[i].x = x
  game.particles[i].y = y
  game.particles[i].vx = vx
  game.particles[i].vy = vy
  game.particles[i].life = life
  game.particles[i].size = size
  game.particles[i].kind = kind
}

///|
fn @types.Game::burst(
  game : @types.Game,
  x : Float,
  y : Float,
  amount : Int,
  kind : Int,
) -> Unit {
  for _i in 0..<amount {
    game.spawn_particle(
      x + @types.randf(-24.0, 24.0),
      y + @types.randf(-16.0, 16.0),
      @types.randf(-420.0, 420.0),
      @types.randf(-420.0, 160.0),
      @types.randf(0.26, 1.1),
      @types.randf(2.0, 7.2),
      kind,
    )
  }
}

///|
fn @types.Game::spawn_trail(
  game : @types.Game,
  lane_x : Float,
  jump_y : Float,
  beta : Bool,
) -> Unit {
  let i = game.alloc_trail_slot()
  game.trails[i].active = true
  game.trails[i].x = lane_x
  game.trails[i].y = jump_y
  game.trails[i].w = 74.0
  game.trails[i].h = 20.0
  game.trails[i].life = 0.18
  game.trails[i].beta = beta
}

///|
fn @types.Game::set_stage(game : @types.Game, stage : Int) -> Unit {
  game.stage = stage
  game.stage_goal = @types.stage_base_distance +
    Float::from_int(stage - 1) * @types.stage_distance_growth
  game.stage_progress = 0.0
  game.speed = @types.base_speed +
    Float::from_int(stage - 1) * @types.speed_stage_gain
}

///|
fn @types.Game::spawn_orb_strip(
  game : @types.Game,
  z0 : Float,
  len : Int,
  lane : Int,
) -> Unit {
  for i in 0..<len {
    game.spawn_obj(
      Orb,
      lane,
      z0 + Float::from_int(i) * 72.0,
      48.0 + @math.sinf(Float::from_int(i) * 0.8) * 16.0,
      56.0,
      56.0,
      0,
    )
  }
}

///|
fn @types.Game::spawn_wave(game : @types.Game, z_base : Float) -> Unit {
  let p = @types.randi(0, 99)

  if p < 20 {
    let safe = @types.randi(0, @types.lane_count - 1)
    for lane in 0..<@types.lane_count {
      if lane == safe {
        game.spawn_orb_strip(z_base + 30.0, 4, lane)
      } else {
        game.spawn_obj(
          Wall,
          lane,
          z_base + @types.randf(0.0, 56.0),
          0.0,
          110.0,
          180.0,
          0,
        )
      }
    }
  } else if p < 36 {
    let mut lane = @types.randi(0, @types.lane_count - 1)
    for i in 0..<6 {
      game.spawn_obj(
        Wall,
        lane,
        z_base + Float::from_int(i) * 170.0,
        0.0,
        102.0,
        178.0,
        0,
      )
      if @types.chance(70) {
        let step_dir = if @types.chance(50) { 1 } else { -1 }
        lane = (lane + step_dir).clamp(min=0, max=@types.lane_count - 1)
      }
    }
  } else if p < 54 {
    for lane in 0..<@types.lane_count {
      game.spawn_obj(
        GateAlpha,
        lane,
        z_base + Float::from_int(lane) * 36.0,
        0.0,
        96.0,
        176.0,
        1,
      )
      game.spawn_obj(
        GateBeta,
        lane,
        z_base + 260.0 + Float::from_int(lane) * 36.0,
        0.0,
        96.0,
        176.0,
        2,
      )
    }
    game.spawn_orb_strip(
      z_base + 122.0,
      5,
      @types.randi(0, @types.lane_count - 1),
    )
  } else if p < 72 {
    let lane = @types.randi(0, @types.lane_count - 1)
    game.spawn_obj(Boost, lane, z_base + 180.0, 0.0, 112.0, 48.0, 0)
    game.spawn_orb_strip(z_base + 20.0, 3, lane)
    for i in 0..<5 {
      let l = (lane + i + 1) % @types.lane_count
      game.spawn_obj(
        Wall,
        l,
        z_base + 300.0 + Float::from_int(i) * 60.0,
        0.0,
        108.0,
        180.0,
        0,
      )
    }
  } else if p < 88 {
    let lane = @types.randi(0, @types.lane_count - 1)
    for i in 0..<7 {
      game.spawn_obj(
        JumpBar,
        lane,
        z_base + Float::from_int(i) * 130.0,
        0.0,
        108.0,
        72.0,
        0,
      )
      if i % 2 == 0 {
        let side_step = if @types.chance(50) { 1 } else { -1 }
        let side_lane = (lane + side_step).clamp(
          min=0,
          max=@types.lane_count - 1,
        )
        game.spawn_obj(
          Orb,
          side_lane,
          z_base + Float::from_int(i) * 130.0 + 32.0,
          62.0,
          56.0,
          56.0,
          0,
        )
      }
    }
  } else {
    for i in 0..<10 {
      let lane = @types.randi(0, @types.lane_count - 1)
      let kind : @types.ObjKind = if @types.chance(70) { Orb } else { Wall }
      let y_off : Float = if kind == Orb {
        Float::from_int(46) +
        @math.sinf(Float::from_int(i)) * Float::from_int(22)
      } else {
        0.0
      }
      let w : Float = if kind == Orb { 56.0 } else { 96.0 }
      let h : Float = if kind == Orb { 56.0 } else { 172.0 }
      game.spawn_obj(
        kind,
        lane,
        z_base + Float::from_int(i) * 110.0,
        y_off,
        w,
        h,
        0,
      )
    }
  }
}

///|
fn @types.Game::ensure_spawns(game : @types.Game) -> Unit {
  while game.next_spawn_z < 3000.0 {
    game.spawn_wave(game.next_spawn_z)
    let step = @types.randf(240.0, 420.0) -
      Float::from_int(game.stage - 1) * 4.0
    game.next_spawn_z = game.next_spawn_z + @types.maxf(180.0, step)
  }
}

///|
fn @types.Game::apply_damage(game : @types.Game, amount : Float) -> Unit {
  if game.hero.invuln_t > 0.0 {
    return
  }

  game.health = game.health - amount
  game.health = @types.maxf(0.0, game.health)
  game.combo = 0
  game.combo_t = 0.0
  game.hero.invuln_t = @types.invuln_time
  game.hero.hurt_t = 0.30
  game.flash_t = 0.24
  game.shake_t = 0.28

  game.burst(game.hero.lane_f, game.hero.y + 42.0, 24, 2)

  if game.health <= 0.0 {
    game.state = GameOver
    game.result_t = 0.0
    if game.score > game.best_score {
      game.best_score = game.score
    }
  }
}

///|
fn @types.Game::start_run(game : @types.Game) -> Unit {
  game.clear_objs()
  game.clear_particles()
  game.clear_trails()
  reset_hero(game.hero)

  game.state = Play
  game.set_stage(1)
  game.speed_mul = 1.0
  game.boost_t = 0.0
  game.score = 0
  game.stage_bonus = 0
  game.combo = 0
  game.combo_t = 0.0
  game.orbs = 0
  game.health = 100.0
  game.phase_energy = 100.0
  game.phase_beta = false
  game.phase_cd = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  game.result_t = 0.0
  game.hint_t = 9.0
  game.next_spawn_z = 380.0

  game.touch_left_prev = false
  game.touch_right_prev = false
  game.touch_jump_prev = false
  game.touch_phase_prev = false
  game.touch_restart_prev = false

  game.ensure_spawns()
}

///|
fn @types.Game::init_title_scene(game : @types.Game) -> Unit {
  game.clear_objs()
  game.clear_particles()
  game.clear_trails()
  reset_hero(game.hero)

  game.state = Title
  game.stage = 1
  game.stage_goal = @types.stage_base_distance
  game.stage_progress = 0.0
  game.speed = @types.base_speed * 0.55
  game.speed_mul = 1.0
  game.boost_t = 0.0
  game.score = 0
  game.stage_bonus = 0
  game.combo = 0
  game.combo_t = 0.0
  game.orbs = 0
  game.health = 100.0
  game.phase_energy = 100.0
  game.phase_beta = false
  game.phase_cd = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  game.title_t = 0.0
  game.result_t = 0.0
  game.hint_t = 0.0
  game.next_spawn_z = 420.0

  game.ensure_spawns()
}

///|
fn @types.Game::handle_lane_input(game : @types.Game) -> Unit {
  if game.input_move == 0 {
    return
  }

  game.hero.lane = (game.hero.lane + game.input_move).clamp(
    min=0,
    max=@types.lane_count - 1,
  )
}

///|
fn @types.Game::update_player(game : @types.Game, dt : Float) -> Unit {
  let hero = game.hero
  hero.anim_t = hero.anim_t + dt

  if hero.invuln_t > 0.0 {
    hero.invuln_t = @types.maxf(0.0, hero.invuln_t - dt)
  }
  if hero.hurt_t > 0.0 {
    hero.hurt_t = @types.maxf(0.0, hero.hurt_t - dt)
  }

  game.handle_lane_input()

  let lane_target = @types.lane_world_x(hero.lane)
  hero.lane_f = @types.lerpf(
    hero.lane_f,
    lane_target,
    @types.clampf(dt * 12.0, 0.0, 1.0),
  )

  if game.input_jump_press {
    hero.jump_buf = 0.12
  } else {
    hero.jump_buf = @types.maxf(0.0, hero.jump_buf - dt)
  }

  if hero.grounded && hero.jump_buf > 0.0 {
    hero.vy = @types.player_jump_speed
    hero.grounded = false
    hero.jump_buf = 0.0
    game.burst(hero.lane_f, 10.0, 10, 0)
  }

  if !hero.grounded {
    hero.vy = hero.vy - @types.player_gravity * dt
    if hero.vy > 0.0 && !game.input_jump_hold {
      hero.vy = hero.vy - @types.player_gravity * dt * 0.75
    }
    hero.y = hero.y + hero.vy * dt
    if hero.y <= 0.0 {
      hero.y = 0.0
      hero.vy = 0.0
      hero.grounded = true
    }
  }

  let gate : Float = if hero.y > 2.0 { 0.032 } else { 0.046 }
  let now_tick = (hero.anim_t / gate).to_int()
  let prev_tick = ((hero.anim_t - dt) / gate).to_int()
  if now_tick != prev_tick {
    game.spawn_trail(hero.lane_f, hero.y, game.phase_beta)
  }
}

///|
fn @types.Game::update_phase(game : @types.Game, dt : Float) -> Unit {
  if game.phase_cd > 0.0 {
    game.phase_cd = @types.maxf(0.0, game.phase_cd - dt)
  }

  if game.input_phase_press && game.phase_cd <= 0.0 {
    if game.phase_beta {
      game.phase_beta = false
      game.phase_cd = @types.phase_switch_cd
      game.burst(game.hero.lane_f, game.hero.y + 34.0, 8, 0)
    } else if game.phase_energy > 8.0 {
      game.phase_beta = true
      game.phase_energy = game.phase_energy - 8.0
      game.phase_cd = @types.phase_switch_cd
      game.burst(game.hero.lane_f, game.hero.y + 34.0, 8, 1)
    }
  }

  if game.phase_beta {
    game.phase_energy = @types.maxf(
      0.0,
      game.phase_energy - @types.phase_drain_per_sec * dt,
    )
    if game.phase_energy <= 0.0 {
      game.phase_beta = false
      game.phase_cd = @types.phase_switch_cd
    }
  } else {
    game.phase_energy = @types.minf(
      100.0,
      game.phase_energy + @types.phase_recover_per_sec * dt,
    )
  }
}

///|
fn @types.Game::combo_mul(game : @types.Game) -> Float {
  1.0 + Float::from_int(game.combo) * 0.08
}

///|
fn mark_hit_obj(o : @types.TrackObj) -> Unit {
  o.hit_lock = 0.18
}

///|
fn @types.Game::obj_affects_phase(
  game : @types.Game,
  o : @types.TrackObj,
) -> Bool {
  if o.phase_only == 1 {
    return !game.phase_beta
  }
  if o.phase_only == 2 {
    return game.phase_beta
  }
  true
}

///|
fn @types.Game::update_objects(game : @types.Game, dt : Float) -> Unit {
  let dz = game.speed * game.speed_mul * dt
  game.stage_progress = game.stage_progress + dz

  for o in game.objs {
    if !o.active {
      continue
    }

    o.z = o.z - dz
    o.spin = o.spin + dt * 2.0

    if o.hit_lock > 0.0 {
      o.hit_lock = @types.maxf(0.0, o.hit_lock - dt)
    }

    if o.z < -180.0 {
      o.active = false
      continue
    }

    if o.z > 130.0 || o.z < -24.0 {
      continue
    }

    let lane_dx = @types.lane_world_x(o.lane) - game.hero.lane_f
    let same_lane = lane_dx * lane_dx < 70.0 * 70.0
    if !same_lane {
      continue
    }

    if o.kind == Orb {
      let d2 = @types.dist2(
        @types.lane_world_x(o.lane),
        o.y_off + 24.0,
        game.hero.lane_f,
        game.hero.y + 14.0,
      )
      if d2 < 78.0 * 78.0 {
        o.active = false
        game.orbs = game.orbs + 1
        game.combo = (game.combo + 1).clamp(min=0, max=999)
        game.combo_t = @types.combo_decay_time
        game.score = game.score +
          (Float::from_int(96 + game.combo * 6) * game.combo_mul()).to_int()
        game.burst(@types.lane_world_x(o.lane), o.y_off + 22.0, 10, 0)
      }
      continue
    }

    if o.kind == Boost {
      if game.hero.y <= 48.0 {
        o.active = false
        game.boost_t = 1.4
        game.speed_mul = 1.78
        game.score = game.score + 280
        game.burst(@types.lane_world_x(o.lane), 22.0, 16, 1)
      }
      continue
    }

    if !game.obj_affects_phase(o) {
      continue
    }

    if o.hit_lock > 0.0 {
      continue
    }

    if o.kind == JumpBar {
      if game.hero.y > 84.0 {
        continue
      }
      mark_hit_obj(o)
      game.apply_damage(14.0)
      continue
    }

    if o.kind == GateAlpha || o.kind == GateBeta {
      if game.hero.y > 106.0 {
        continue
      }
      mark_hit_obj(o)
      game.apply_damage(17.0)
      continue
    }

    if o.kind == Wall {
      if game.hero.y > 120.0 {
        continue
      }
      mark_hit_obj(o)
      game.apply_damage(20.0)
      continue
    }
  }

  game.ensure_spawns()

  if game.boost_t > 0.0 {
    game.boost_t = @types.maxf(0.0, game.boost_t - dt)
    game.speed_mul = @types.approachf(game.speed_mul, 1.0, dt * 1.4)
  } else {
    game.speed_mul = @types.approachf(game.speed_mul, 1.0, dt * 2.6)
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
    particle.vx = particle.vx * (1.0 - dt * 2.3)
    particle.vy = particle.vy * (1.0 - dt * 1.8) - dt * 140.0
  }

  for trail in game.trails {
    if !trail.active {
      continue
    }

    trail.life = trail.life - dt
    if trail.life <= 0.0 {
      trail.active = false
    }
  }
}

///|
fn @types.Game::update_score(game : @types.Game, dt : Float) -> Unit {
  if game.combo_t > 0.0 {
    game.combo_t = @types.maxf(0.0, game.combo_t - dt)
    if game.combo_t <= 0.0 {
      game.combo = 0
    }
  }

  let points = (game.speed * game.speed_mul * dt * 0.10 * game.combo_mul()).to_int()
  game.score = game.score + points

  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
fn @types.Game::update_play(game : @types.Game, dt : Float) -> Unit {
  if game.input_pause_press {
    game.init_title_scene()
    return
  }

  if game.hint_t > 0.0 {
    game.hint_t = @types.maxf(0.0, game.hint_t - dt)
  }

  game.update_player(dt)
  game.update_phase(dt)
  game.update_objects(dt)
  game.update_particles(dt)
  game.update_score(dt)

  if game.flash_t > 0.0 {
    game.flash_t = @types.maxf(0.0, game.flash_t - dt)
  }
  if game.shake_t > 0.0 {
    game.shake_t = @types.maxf(0.0, game.shake_t - dt)
  }

  if game.stage_progress >= game.stage_goal {
    game.state = StageClear
    game.result_t = 1.7
    game.stage_bonus = 520 + game.combo * 14 + (game.health * 5.0).to_int()
    game.score = game.score + game.stage_bonus
    if game.score > game.best_score {
      game.best_score = game.score
    }
    game.flash_t = 0.34
    game.burst(game.hero.lane_f, game.hero.y + 26.0, 34, 1)
  }

  if game.input_restart_press {
    game.start_run()
  }
}

///|
fn @types.Game::update_stage_clear(game : @types.Game, dt : Float) -> Unit {
  game.update_particles(dt)

  game.result_t = game.result_t - dt
  if game.result_t <= 0.0 {
    game.set_stage(game.stage + 1)
    game.state = Play
    game.result_t = 0.0
    game.stage_bonus = 0
    game.health = @types.minf(100.0, game.health + 15.0)
    game.hint_t = 2.0
  }

  if game.input_restart_press {
    game.start_run()
  }
}

///|
fn @types.Game::update_game_over(game : @types.Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  game.update_particles(dt)

  if game.input_restart_press || (game.result_t > 0.35 && game.input_jump_press) {
    game.start_run()
  }
}

///|
fn @types.Game::update_title_scene(game : @types.Game, dt : Float) -> Unit {
  game.title_t = game.title_t + dt

  let demo_dz = @types.base_speed * 0.52 * dt
  for obj in game.objs {
    if !obj.active {
      continue
    }

    obj.z = obj.z - demo_dz
    obj.spin = obj.spin + dt * 2.0
    if obj.z < -180.0 {
      obj.active = false
    }
  }

  game.ensure_spawns()
  game.update_particles(dt)

  if game.input_jump_press || game.input_phase_press || game.input_restart_press {
    game.start_run()
  }
}

///|
/// Advance one simulation step based on current game state.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  // Handle input first based on current state
  match game.state {
    Title => game.update_title_input()
    Play => game.update_play_input()
    StageClear => game.update_stage_clear_input()
    GameOver => game.update_result_input()
  }

  // Then update game logic
  match game.state {
    Title => game.update_title_scene(dt)
    Play => game.update_play(dt)
    StageClear => game.update_stage_clear(dt)
    GameOver => game.update_game_over(dt)
  }
}

///|
/// Initialize the game state to the animated title scene.
pub fn init_game(game : @types.Game) -> Unit {
  game.init_title_scene()
}
