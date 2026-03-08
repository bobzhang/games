///|
/// Resets all entity slots in the pool to their inactive default state.
fn @types.Game::clear_entities(game : @types.Game) -> Unit {
  for entity in game.entities {
    entity.active = false
    entity.kind = FoeBike
    entity.x = 0.0
    entity.y = 0.0
    entity.vx = 0.0
    entity.vy = 0.0
    entity.w = 0.0
    entity.h = 0.0
    entity.hp = 0.0
    entity.shot_cd = 0.0
    entity.spin = 0.0
    entity.cloak = false
    entity.reward = 0
  }
}

///|
/// Resets all bullet slots in the pool to their inactive default state.
fn @types.Game::clear_bullets(game : @types.Game) -> Unit {
  for bullet in game.bullets {
    bullet.active = false
    bullet.from_player = true
    bullet.x = 0.0
    bullet.y = 0.0
    bullet.vx = 0.0
    bullet.vy = 0.0
    bullet.life = 0.0
    bullet.dmg = 0.0
    bullet.kind = 0
  }
}

///|
/// Resets all spark slots in the pool to their inactive default state.
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
/// Resets all glow ring slots in the pool to their inactive default state.
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
/// Resets all afterimage slots in the pool to their inactive default state.
fn @types.Game::clear_images(game : @types.Game) -> Unit {
  for image in game.images {
    image.active = false
    image.x = 0.0
    image.y = 0.0
    image.w = 0.0
    image.h = 0.0
    image.rot = 0.0
    image.life = 0.0
    image.kind = 0
  }
}

///|
/// Resets all player fields to their starting values at the center-bottom of the screen.
fn reset_player(hero : @types.Player) -> Unit {
  hero.x = Float::from_int(@types.screen_w / 2)
  hero.y = Float::from_int(@types.screen_h) * 0.76
  hero.vx = 0.0
  hero.vy = 0.0
  hero.w = @types.player_w
  hero.h = @types.player_h
  hero.heading = 0.0
  hero.invuln = 0.0
  hero.hurt_t = 0.0
  hero.muzzle_t = 0.0
  hero.engine_t = 0.0
}

///|
/// Returns the index of a free entity slot, or evicts the lowest-priority active entity if the pool is full.
fn @types.Game::alloc_entity(game : @types.Game) -> Int {
  for i, slot in game.entities {
    if !slot.active {
      break i
    }
  } nobreak {
    let best = @utils.max_index_by(game.entities, fn(a, b) { a.y > b.y })
    if best >= 0 {
      best
    } else {
      0
    }
  }
}

///|
/// Returns the index of a free bullet slot, or evicts the shortest-lived active bullet if the pool is full.
fn @types.Game::alloc_bullet(game : @types.Game) -> Int {
  for i, slot in game.bullets {
    if !slot.active {
      break i
    }
  } nobreak {
    let best = @utils.min_index_by(
      game.bullets,
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
/// Returns the index of a free spark slot, or evicts the shortest-lived active spark if the pool is full.
fn @types.Game::alloc_spark(game : @types.Game) -> Int {
  for i, slot in game.sparks {
    if !slot.active {
      break i
    }
  } nobreak {
    let best = @utils.min_index_by(
      game.sparks,
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
/// Returns the index of a free glow ring slot, or evicts the shortest-lived active ring if the pool is full.
fn @types.Game::alloc_ring(game : @types.Game) -> Int {
  for i, slot in game.rings {
    if !slot.active {
      break i
    }
  } nobreak {
    let best = @utils.min_index_by(
      game.rings,
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
/// Returns the index of a free afterimage slot, or evicts the shortest-lived active afterimage if the pool is full.
fn @types.Game::alloc_image(game : @types.Game) -> Int {
  for i, slot in game.images {
    if !slot.active {
      break i
    }
  } nobreak {
    let best = @utils.min_index_by(
      game.images,
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
/// Activates a spark slot with the given position, velocity, lifetime, size, and visual kind.
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
/// Spawns `count` sparks with randomized offsets and velocities around position `(x, y)`.
fn @types.Game::burst(
  game : @types.Game,
  x : Float,
  y : Float,
  count : Int,
  kind : Int,
) -> Unit {
  for _i in 0..<count {
    game.emit_spark(
      x + @types.randf(-22.0, 22.0),
      y + @types.randf(-22.0, 22.0),
      @types.randf(-280.0, 280.0),
      @types.randf(-280.0, 280.0),
      @types.randf(0.24, 1.04),
      @types.randf(1.2, 6.8),
      kind,
    )
  }
}

///|
/// Activates a glow ring slot at position `(x, y)` with the given initial radius, lifetime, and visual kind.
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
/// Activates an afterimage slot at position `(x, y)` with the given dimensions, rotation, lifetime, and visual kind.
fn @types.Game::emit_image(
  game : @types.Game,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  rot : Float,
  life : Float,
  kind : Int,
) -> Unit {
  let i = game.alloc_image()
  game.images[i].active = true
  game.images[i].x = x
  game.images[i].y = y
  game.images[i].w = w
  game.images[i].h = h
  game.images[i].rot = rot
  game.images[i].life = life
  game.images[i].kind = kind
}

///|
/// Activates a bullet slot with team, position, velocity, lifetime, damage, and visual kind.
fn @types.Game::spawn_bullet(
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
  let i = game.alloc_bullet()
  game.bullets[i].active = true
  game.bullets[i].from_player = from_player
  game.bullets[i].x = x
  game.bullets[i].y = y
  game.bullets[i].vx = vx
  game.bullets[i].vy = vy
  game.bullets[i].life = life
  game.bullets[i].dmg = dmg
  game.bullets[i].kind = kind
}

///|
/// Activates an entity slot with all required spawn parameters including kind, position, size, HP, and behavior tuning.
fn @types.Game::spawn_entity(
  game : @types.Game,
  kind : @types.EntityKind,
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
  let i = game.alloc_entity()
  game.entities[i].active = true
  game.entities[i].kind = kind
  game.entities[i].x = x
  game.entities[i].y = y
  game.entities[i].vx = vx
  game.entities[i].vy = vy
  game.entities[i].w = w
  game.entities[i].h = h
  game.entities[i].hp = hp
  game.entities[i].shot_cd = shot_cd
  game.entities[i].spin = @types.randf(0.0, 6.283)
  game.entities[i].cloak = cloak
  game.entities[i].reward = reward
}

///|
/// Computes the combo-scaled score gain for a base point value.
fn @types.Game::score_gain(game : @types.Game, base : Int) -> Int {
  let bonus = base * game.combo / 5
  base + bonus
}

///|
/// Adds combo-scaled points to the running score and updates the best score if exceeded.
fn @types.Game::add_score(game : @types.Game, base : Int) -> Unit {
  let gained = game.score_gain(base)
  game.score = game.score + gained
  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
/// Increments the combo counter by one (capped at 24) and resets the combo decay timer.
fn @types.Game::push_combo(game : @types.Game) -> Unit {
  game.combo = (game.combo + 1).clamp(min=0, max=24)
  game.combo_t = 3.6
}

///|
/// Resets the combo counter and decay timer to zero.
fn @types.Game::reset_combo(game : @types.Game) -> Unit {
  game.combo = 0
  game.combo_t = 0.0
}

///|
/// Applies damage to the player's shield, triggers hurt effects and invulnerability, and transitions to GameOver if shield reaches zero.
fn @types.Game::damage_player(game : @types.Game, dmg : Float) -> Unit {
  if game.hero.invuln > 0.0 {
    return
  }

  game.shield = @types.maxf(0.0, game.shield - dmg)
  game.hero.invuln = @types.invuln_after_hit
  game.hero.hurt_t = 0.58
  game.flash_t = @types.maxf(game.flash_t, 0.34)
  game.shake_t = @types.maxf(game.shake_t, 0.6)

  game.burst(game.hero.x, game.hero.y, 22, 1)
  game.reset_combo()

  if game.shield <= 0.0 {
    game.state = GameOver
    game.result_t = 0.0
  }
}

///|
/// Clears all pools, resets the player, and configures speed, distance goal, and resource levels for the given stage number.
fn @types.Game::start_stage(game : @types.Game, stage : Int) -> Unit {
  game.clear_entities()
  game.clear_bullets()
  game.clear_sparks()
  game.clear_rings()
  game.clear_images()

  reset_player(game.hero)

  game.state = Play
  game.stage = stage
  game.distance = 0.0
  game.stage_goal = @types.stage_distance_base +
    Float::from_int(stage - 1) * @types.stage_distance_gain
  game.scroll_speed = @types.base_scroll_speed +
    Float::from_int(stage - 1) * @types.stage_scroll_gain
  game.next_spawn_y = @types.spawn_start_y

  game.fire_cd = 0.0
  game.boost_cd = 0.0
  game.boost_t = 0.0
  game.hack_cd = 0.0
  game.hack_t = 0.0
  game.result_t = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  game.hint_t = 0.0
  game.reset_combo()

  if stage <= 1 {
    game.score = 0
    game.credits = 0
    game.kills = 0
    game.shield = @types.player_shield_max
    game.energy = @types.player_energy_max
  } else {
    game.shield = @types.minf(@types.player_shield_max, game.shield + 22.0)
    game.energy = @types.minf(@types.player_energy_max, game.energy + 34.0)
  }

  game.spawn_ring(game.hero.x, game.hero.y, 16.0, 0.72, 0)
}

///|
/// Clears all pools, resets game counters, and transitions the game to the title screen state.
fn @types.Game::init_title_scene(game : @types.Game) -> Unit {
  game.clear_entities()
  game.clear_bullets()
  game.clear_sparks()
  game.clear_rings()
  game.clear_images()
  reset_player(game.hero)

  game.state = Title
  game.stage = 1
  game.distance = 0.0
  game.stage_goal = @types.stage_distance_base
  game.score = 0
  game.credits = 0
  game.kills = 0
  game.combo = 0
  game.combo_t = 0.0
  game.shield = @types.player_shield_max
  game.energy = @types.player_energy_max

  game.fire_cd = 0.0
  game.boost_cd = 0.0
  game.boost_t = 0.0
  game.hack_cd = 0.0
  game.hack_t = 0.0

  game.time_s = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  game.result_t = 0.0
  game.hint_t = 0.0

  game.scroll_speed = @types.base_scroll_speed
  game.next_spawn_y = @types.spawn_start_y
}

///|
/// Starts a new run from stage 1.
fn @types.Game::start_run(game : @types.Game) -> Unit {
  game.start_stage(1)
}

///|
/// Spawns a random pack of 1-3 enemies or items at vertical position `y`, using stage-appropriate types and parameters.
fn @types.Game::spawn_enemy_pack(game : @types.Game, y : Float) -> Unit {
  let depth = game.distance + (Float::from_int(@types.screen_h) - y)
  let center = @types.road_center_at(depth, game.time_s)

  let pack = 1 + @types.randi(0, 2)
  for _i in 0..<pack {
    let roll = @types.randi(0, 99)

    if roll < 34 {
      let lane = @types.randi(0, @types.lanes_count - 1)
      let x = @types.lane_x(lane, center) + @types.randf(-12.0, 12.0)
      game.spawn_entity(
        FoeBike,
        x,
        y + @types.randf(-28.0, 20.0),
        @types.randf(-44.0, 44.0),
        @types.randf(-20.0, 40.0),
        44.0,
        76.0,
        18.0 + Float::from_int(game.stage - 1) * 3.0,
        @types.randf(0.42, 1.22),
        false,
        120,
      )
    } else if roll < 56 {
      let lane = @types.randi(0, @types.lanes_count - 1)
      let x = @types.lane_x(lane, center) + @types.randf(-16.0, 16.0)
      game.spawn_entity(
        FoeDrone,
        x,
        y + @types.randf(-26.0, 24.0),
        @types.randf(-60.0, 60.0),
        @types.randf(-10.0, 30.0),
        40.0,
        40.0,
        12.0 + Float::from_int(game.stage - 1) * 2.0,
        @types.randf(0.26, 0.9),
        game.stage >= 3 && @types.chance(26),
        110,
      )
    } else if roll < 70 {
      let lane = @types.randi(0, @types.lanes_count - 1)
      let x = @types.lane_x(lane, center)
      game.spawn_entity(
        FoeTruck,
        x,
        y + @types.randf(-32.0, 22.0),
        @types.randf(-18.0, 18.0),
        @types.randf(-16.0, 18.0),
        82.0,
        124.0,
        46.0 + Float::from_int(game.stage - 1) * 7.0,
        @types.randf(0.7, 1.8),
        false,
        190,
      )
    } else if roll < 80 {
      let lane = @types.randi(0, @types.lanes_count - 1)
      let x = @types.lane_x(lane, center)
      game.spawn_entity(
        FoeLaser,
        x,
        y + @types.randf(-14.0, 12.0),
        0.0,
        @types.randf(-6.0, 12.0),
        126.0,
        18.0,
        16.0,
        @types.randf(0.9, 2.0),
        false,
        96,
      )
    } else if roll < 90 {
      let x = @types.road_spawn_x(game.distance, game.time_s, game.stage, y)
      game.spawn_entity(
        ItemCredit,
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
      let x = @types.road_spawn_x(game.distance, game.time_s, game.stage, y)
      game.spawn_entity(
        ItemBattery,
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
      let x = @types.road_spawn_x(game.distance, game.time_s, game.stage, y)
      game.spawn_entity(
        ItemHackcell,
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
/// Advances the spawn cursor by scroll speed and spawns enemy packs whenever the cursor crosses the screen top.
fn @types.Game::spawn_step(game : @types.Game, dt : Float) -> Unit {
  game.next_spawn_y = game.next_spawn_y + game.scroll_speed * dt

  let mut spawn_count = 0
  while game.next_spawn_y >= 0.0 && spawn_count < 18 {
    game.next_spawn_y = game.next_spawn_y -
      @types.randf(@types.spawn_spacing_min, @types.spawn_spacing_max)
    game.spawn_enemy_pack(game.next_spawn_y)
    spawn_count = spawn_count + 1
  }
}

///|
/// Triggers the hack pulse: disables nearby enemy cloaks, destroys close-range enemies, and sweeps enemy bullets within the hack radius.
fn @types.Game::apply_hack_pulse(game : @types.Game) -> Unit {
  game.hack_cd = @types.hack_cd_time
  game.hack_t = @types.hack_time

  game.spawn_ring(game.hero.x, game.hero.y, 14.0, 0.9, 2)
  game.burst(game.hero.x, game.hero.y, 24, 2)

  let rr2 = @types.hack_radius * @types.hack_radius
  let kill2 = @types.hack_pulse_kill * @types.hack_pulse_kill

  for entity in game.entities {
    if !entity.active {
      continue
    }

    let d2 = @types.dist2(game.hero.x, game.hero.y, entity.x, entity.y)
    if d2 > rr2 {
      continue
    }

    entity.cloak = false

    if @types.entity_is_hostile(entity.kind) && d2 <= kill2 {
      let kind = entity.kind
      let x = entity.x
      let y = entity.y
      entity.active = false
      game.add_score(if kind == FoeTruck { 140 } else { 88 })
      game.push_combo()
      game.burst(x, y, 18, 1)
      game.spawn_ring(x, y, 10.0, 0.52, 1)
      game.kills = game.kills + 1
    }
  }

  for bullet in game.bullets {
    if !bullet.active || bullet.from_player {
      continue
    }

    let d2 = @types.dist2(game.hero.x, game.hero.y, bullet.x, bullet.y)
    if d2 <= rr2 {
      bullet.active = false
      game.emit_spark(
        bullet.x,
        bullet.y,
        @types.randf(-90.0, 90.0),
        @types.randf(-90.0, 90.0),
        @types.randf(0.2, 0.45),
        @types.randf(1.2, 3.4),
        2,
      )
    }
  }
}

///|
/// Fires two parallel bullets from the player's gun ports and optionally a center bullet on higher stages.
fn @types.Game::shoot_player_bullet(game : @types.Game) -> Unit {
  let spread : Float = if game.boost_t > 0.0 { 16.0 } else { 8.0 }

  game.spawn_bullet(
    true,
    game.hero.x - 10.0,
    game.hero.y - game.hero.h * 0.44,
    @types.randf(-spread, spread),
    -@types.bullet_speed,
    @types.bullet_life,
    8.0,
    0,
  )
  game.spawn_bullet(
    true,
    game.hero.x + 10.0,
    game.hero.y - game.hero.h * 0.44,
    @types.randf(-spread, spread),
    -@types.bullet_speed,
    @types.bullet_life,
    8.0,
    0,
  )

  if game.stage >= 4 && @types.chance(28) {
    game.spawn_bullet(
      true,
      game.hero.x,
      game.hero.y - game.hero.h * 0.54,
      @types.randf(-6.0, 6.0),
      -@types.bullet_speed * 1.08,
      @types.bullet_life,
      6.0,
      1,
    )
  }

  game.hero.muzzle_t = 0.12
}

///|
/// Processes boost, hack, fire, and movement inputs, applies drag and velocity clamping, and moves the player for this frame.
fn @types.Game::apply_player_input(game : @types.Game, dt : Float) -> Unit {
  if game.input_boost_press && game.boost_cd <= 0.0 && game.energy >= 14.0 {
    game.boost_t = @types.boost_time
    game.boost_cd = @types.boost_cd_time
    game.energy = @types.maxf(0.0, game.energy - 12.0)
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

    game.hero.vx = game.hero.vx + dx * @types.boost_speed_bonus
    game.hero.vy = game.hero.vy + dy * @types.boost_speed_bonus * 0.7

    game.spawn_ring(game.hero.x, game.hero.y, 18.0, 0.58, 0)
    game.burst(game.hero.x, game.hero.y, 16, 0)
  }

  if game.input_hack_press && game.hack_cd <= 0.0 && game.energy >= 18.0 {
    game.energy = @types.maxf(0.0, game.energy - 18.0)
    game.apply_hack_pulse()
  }

  if game.input_fire_hold && game.fire_cd <= 0.0 {
    game.shoot_player_bullet()
    game.fire_cd = if game.boost_t > 0.0 {
      @types.fire_cooldown_base * 0.62
    } else {
      @types.fire_cooldown_base
    }
  }

  game.hero.vx = game.hero.vx + game.input_x * @types.player_accel_x * dt
  game.hero.vy = game.hero.vy + game.input_y * @types.player_accel_y * dt

  if game.boost_t > 0.0 {
    game.hero.vy = game.hero.vy - 150.0 * dt
    game.emit_image(
      game.hero.x,
      game.hero.y + 18.0,
      game.hero.w,
      game.hero.h,
      game.hero.heading,
      @types.randf(0.14, 0.26),
      1,
    )
  }

  let drag_mul = @types.clampf(1.0 - @types.player_drag * dt, 0.0, 1.0)
  game.hero.vx = game.hero.vx * drag_mul
  game.hero.vy = game.hero.vy * drag_mul

  game.hero.vx = @types.clampf(
    game.hero.vx,
    -@types.player_max_speed_x,
    @types.player_max_speed_x,
  )
  game.hero.vy = @types.clampf(
    game.hero.vy,
    -@types.player_max_speed_y,
    @types.player_max_speed_y,
  )

  game.hero.x = game.hero.x + game.hero.vx * dt
  game.hero.y = game.hero.y + game.hero.vy * dt

  game.hero.y = @types.clampf(
    game.hero.y,
    Float::from_int(@types.ui_panel_h + 56),
    Float::from_int(@types.screen_h) - 80.0,
  )
}

///|
/// Pushes the player back inside the road edges if they stray past the curb and applies damage for colliding with the barrier.
fn @types.Game::constrain_player_to_road(game : @types.Game) -> Unit {
  let d = game.distance + (Float::from_int(@types.screen_h) - game.hero.y)
  let edges = @types.road_edges(game.stage, d, game.time_s)
  let left = edges.0
  let right = edges.1

  let rr = @types.player_hit_radius(game.hero)

  if game.hero.x - rr < left {
    game.hero.x = left + rr
    game.hero.vx = game.hero.vx.abs() * 0.2
    game.damage_player(10.0)
  }

  if game.hero.x + rr > right {
    game.hero.x = right - rr
    game.hero.vx = -game.hero.vx.abs() * 0.2
    game.damage_player(10.0)
  }
}

///|
/// Fires a bullet from entity `e` toward the player using the firing pattern appropriate for its kind.
fn @types.Game::entity_fire(game : @types.Game, e : @types.Entity) -> Unit {
  match e.kind {
    FoeBike =>
      game.spawn_bullet(
        false,
        e.x,
        e.y + e.h * 0.4,
        @types.randf(-120.0, 120.0),
        @types.enemy_bullet_speed,
        2.2,
        9.0,
        0,
      )
    FoeDrone => {
      let dx = game.hero.x - e.x
      let dy = game.hero.y - e.y
      let n2 = @types.maxf(dx * dx + dy * dy, 1.0)
      let inv = Float::from_int(1) / n2.sqrt()
      game.spawn_bullet(
        false,
        e.x,
        e.y,
        dx * inv * @types.enemy_bullet_speed,
        dy * inv * @types.enemy_bullet_speed,
        2.5,
        11.0,
        1,
      )
    }
    FoeTruck => {
      game.spawn_bullet(
        false,
        e.x - 18.0,
        e.y + e.h * 0.32,
        -60.0,
        @types.enemy_bullet_speed * 0.86,
        2.6,
        12.0,
        2,
      )
      game.spawn_bullet(
        false,
        e.x + 18.0,
        e.y + e.h * 0.32,
        60.0,
        @types.enemy_bullet_speed * 0.86,
        2.6,
        12.0,
        2,
      )
    }
    _ => ()
  }
}

///|
/// Deactivates entity `i`, awards score, increments the kill count, and spawns a burst and glow ring at the kill position.
fn @types.Game::kill_entity(
  game : @types.Game,
  i : Int,
  bonus : Int,
  burst_kind : Int,
) -> Unit {
  let x = game.entities[i].x
  let y = game.entities[i].y
  game.entities[i].active = false
  game.add_score(bonus)
  game.push_combo()
  game.kills = game.kills + 1
  game.burst(x, y, 16 + @types.randi(0, 8), burst_kind)
  game.spawn_ring(x, y, 10.0, 0.56, burst_kind)
}

///|
/// Applies the effect of collecting a pickup item: credits add score and combo, batteries restore energy, and hackcells reduce hack cooldown.
fn @types.Game::collect_pickup(
  game : @types.Game,
  kind : @types.EntityKind,
) -> Unit {
  match kind {
    ItemCredit => {
      game.credits = game.credits + 1
      game.add_score(60)
      game.push_combo()
    }
    ItemBattery => {
      game.energy = @types.minf(
        @types.player_energy_max,
        game.energy + @types.energy_pickup,
      )
      game.add_score(40)
    }
    _ => {
      game.hack_cd = @types.maxf(0.0, game.hack_cd - 1.1)
      game.energy = @types.minf(@types.player_energy_max, game.energy + 12.0)
      game.add_score(78)
      game.push_combo()
    }
  }
}

///|
/// Moves all active entities by scroll speed and their own velocity, runs their firing timers, checks player collision, and deactivates out-of-bounds entities.
fn @types.Game::update_entities(game : @types.Game, dt : Float) -> Unit {
  let ram_hit = game.boost_t > 0.0

  for i in 0..<game.entities.length() {
    if !game.entities[i].active {
      continue
    }

    game.entities[i].x = game.entities[i].x + game.entities[i].vx * dt
    game.entities[i].y = game.entities[i].y +
      (game.scroll_speed + game.entities[i].vy) * dt
    game.entities[i].spin = game.entities[i].spin + dt * 1.9
    game.entities[i].shot_cd = game.entities[i].shot_cd - dt

    match game.entities[i].kind {
      FoeBike =>
        game.entities[i].x = game.entities[i].x +
          @math.sinf(game.entities[i].spin * 2.2) * 34.0 * dt
      FoeDrone =>
        game.entities[i].y = game.entities[i].y +
          @math.cosf(game.entities[i].spin * 2.8) * 26.0 * dt
      FoeTruck =>
        game.entities[i].x = game.entities[i].x +
          @math.sinf(game.entities[i].spin * 1.4) * 18.0 * dt
      FoeLaser => {
        game.entities[i].w = 118.0 +
          @math.sinf(game.entities[i].spin * 3.4) * 26.0
        game.entities[i].h = 18.0 +
          @math.sinf(game.entities[i].spin * 4.2) * 4.0
      }
      _ =>
        game.entities[i].x = game.entities[i].x +
          @math.sinf(game.entities[i].spin * 2.6) * 16.0 * dt
    }

    let out = game.entities[i].y > Float::from_int(@types.screen_h) + 220.0 ||
      game.entities[i].x < -260.0 ||
      game.entities[i].x > Float::from_int(@types.screen_w) + 260.0
    if out {
      game.entities[i].active = false
      continue
    }

    if @types.entity_is_hostile(game.entities[i].kind) &&
      game.entities[i].shot_cd <= 0.0 {
      game.entity_fire(game.entities[i])
      game.entities[i].shot_cd = match game.entities[i].kind {
        FoeBike => @types.randf(0.74, 1.44)
        FoeDrone => @types.randf(0.48, 1.02)
        FoeTruck => @types.randf(1.18, 2.1)
        _ => @types.randf(1.0, 1.8)
      }
    }

    let d2 = @types.dist2(
      game.hero.x,
      game.hero.y,
      game.entities[i].x,
      game.entities[i].y,
    )
    let rr = @types.player_hit_radius(game.hero) +
      @types.entity_hit_radius(game.entities[i])

    if d2 <= rr * rr {
      let kind = game.entities[i].kind
      if @types.is_pickup(kind) {
        game.entities[i].active = false
        game.collect_pickup(kind)
        game.burst(game.hero.x, game.hero.y, 10, 2)
      } else if ram_hit {
        game.kill_entity(i, game.entities[i].reward, 0)
      } else {
        let dmg : Float = match kind {
          FoeTruck => 24.0
          FoeLaser => 16.0
          _ => 14.0
        }
        game.damage_player(dmg)
        if kind != FoeLaser {
          game.entities[i].active = false
        }
      }
    }
  }
}

///|
/// Moves all active bullets, deactivates expired or out-of-bounds bullets, and resolves player-bullet and entity-bullet hit detection.
fn @types.Game::update_bullets(game : @types.Game, dt : Float) -> Unit {
  for bullet in game.bullets {
    if !bullet.active {
      continue
    }

    bullet.x = bullet.x + bullet.vx * dt
    bullet.y = bullet.y + (bullet.vy + game.scroll_speed * 0.1) * dt
    bullet.life = bullet.life - dt

    let dead = bullet.life <= 0.0 ||
      bullet.y < -120.0 ||
      bullet.y > Float::from_int(@types.screen_h) + 120.0 ||
      bullet.x < -120.0 ||
      bullet.x > Float::from_int(@types.screen_w) + 120.0
    if dead {
      bullet.active = false
      continue
    }

    if bullet.from_player {
      let mut hit = false
      for j in 0..<game.entities.length() {
        if !game.entities[j].active || @types.is_pickup(game.entities[j].kind) {
          continue
        }

        let d2 = @types.dist2(
          bullet.x,
          bullet.y,
          game.entities[j].x,
          game.entities[j].y,
        )
        let rr = @types.entity_hit_radius(game.entities[j]) + 8.0
        if d2 <= rr * rr {
          game.entities[j].hp = game.entities[j].hp - bullet.dmg
          bullet.active = false
          hit = true

          game.emit_spark(
            game.entities[j].x,
            game.entities[j].y,
            @types.randf(-90.0, 90.0),
            @types.randf(-90.0, 90.0),
            @types.randf(0.18, 0.42),
            @types.randf(1.0, 3.2),
            0,
          )

          if game.entities[j].hp <= 0.0 {
            game.kill_entity(j, game.entities[j].reward, 0)
          }
          break
        }
      }

      if hit {
        continue
      }
    } else {
      let d2 = @types.dist2(bullet.x, bullet.y, game.hero.x, game.hero.y)
      let rr = @types.player_hit_radius(game.hero) + 8.0
      if d2 <= rr * rr {
        bullet.active = false
        game.damage_player(bullet.dmg)
        continue
      }
    }
  }
}

///|
/// Updates sparks, glow rings, and afterimages: advances their positions and lifetimes, and deactivates expired entries.
fn @types.Game::update_effects(game : @types.Game, dt : Float) -> Unit {
  for spark in game.sparks {
    if !spark.active {
      continue
    }

    spark.x = spark.x + spark.vx * dt
    spark.y = spark.y + (spark.vy + game.scroll_speed * 0.16) * dt
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

  for image in game.images {
    if !image.active {
      continue
    }

    image.y = image.y + game.scroll_speed * 0.26 * dt
    image.life = image.life - dt
    if image.life <= 0.0 {
      image.active = false
    }
  }
}

///|
/// Probabilistically emits small spark particles along the road edges each frame to simulate ambient neon traffic glow.
fn @types.Game::emit_ambient_traffic_glow(
  game : @types.Game,
  dt : Float,
) -> Unit {
  let tries = (dt * 230.0).to_int().clamp(min=1, max=10)
  let mut i = 0
  while i < tries {
    if @types.chance(32) {
      let y = @types.randf(
        Float::from_int(@types.ui_panel_h),
        Float::from_int(@types.screen_h) + 12.0,
      )
      let depth = game.distance + (Float::from_int(@types.screen_h) - y)
      let edges = @types.road_edges(game.stage, depth, game.time_s)
      let side : Float = if @types.chance(50) {
        Float::from_int(-1)
      } else {
        Float::from_int(1)
      }
      let x = if side < 0.0 {
        edges.0 + @types.randf(8.0, 30.0)
      } else {
        edges.1 - @types.randf(8.0, 30.0)
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
/// Decrements all per-frame cooldown and effect timers on the player and game state.
fn @types.Game::update_timers(game : @types.Game, dt : Float) -> Unit {
  game.hero.invuln = @types.maxf(0.0, game.hero.invuln - dt)
  game.hero.hurt_t = @types.maxf(0.0, game.hero.hurt_t - dt)
  game.hero.muzzle_t = @types.maxf(0.0, game.hero.muzzle_t - dt)
  game.hero.engine_t = game.hero.engine_t + dt

  game.fire_cd = @types.maxf(0.0, game.fire_cd - dt)
  game.boost_cd = @types.maxf(0.0, game.boost_cd - dt)
  game.boost_t = @types.maxf(0.0, game.boost_t - dt)
  game.hack_cd = @types.maxf(0.0, game.hack_cd - dt)
  game.hack_t = @types.maxf(0.0, game.hack_t - dt)

  game.flash_t = @types.maxf(0.0, game.flash_t - dt)
  game.shake_t = @types.maxf(0.0, game.shake_t - dt)

  if game.combo_t > 0.0 {
    game.combo_t = game.combo_t - dt
    if game.combo_t <= 0.0 {
      game.reset_combo()
    }
  }
}

///|
/// Runs one frame of active gameplay: advances distance, processes player input, spawns enemies, updates entities, bullets, effects, and drains energy.
fn @types.Game::update_play(game : @types.Game, dt : Float) -> Unit {
  game.scroll_speed = @types.base_scroll_speed +
    Float::from_int(game.stage - 1) * @types.stage_scroll_gain +
    @types.minf(70.0, game.distance * 0.006)
  game.distance = game.distance + game.scroll_speed * dt

  game.apply_player_input(dt)
  game.constrain_player_to_road()

  game.spawn_step(dt)
  game.update_entities(dt)
  game.update_bullets(dt)
  game.update_effects(dt)

  game.energy = @types.maxf(
    0.0,
    game.energy -
    @types.energy_drain_base * dt -
    game.hero.vx.abs() / @types.player_max_speed_x * 1.2 * dt,
  )
  if game.boost_t > 0.0 {
    game.energy = @types.maxf(0.0, game.energy - @types.energy_drain_boost * dt)
  }

  game.shield = @types.maxf(
    0.0,
    game.shield - @types.shield_damage_decay * dt * 0.03,
  )

  game.emit_ambient_traffic_glow(dt)

  if game.energy <= 0.0 {
    game.damage_player(100.0)
  }

  if game.state == Play && game.distance >= game.stage_goal {
    game.state = StageClear
    game.result_t = 0.0
    game.add_score(320 + game.stage * 120)
    game.shield = @types.minf(@types.player_shield_max, game.shield + 14.0)
    game.energy = @types.minf(@types.player_energy_max, game.energy + 20.0)
    game.spawn_ring(game.hero.x, game.hero.y, 18.0, 0.9, 2)
    game.burst(game.hero.x, game.hero.y, 28, 2)
  }
}

///|
/// Advances the title screen: scrolls ambient effects and starts a run when the player presses start.
fn @types.Game::update_title(game : @types.Game, dt : Float) -> Unit {
  game.scroll_speed = 96.0
  game.distance = game.distance + game.scroll_speed * dt * 0.7

  game.emit_ambient_traffic_glow(dt)
  game.update_effects(dt)

  if game.input_restart_press {
    game.start_run()
  }
}

///|
/// Runs the stage-clear intermission: decelerates scroll speed, emits celebration sparks, and advances to the next stage after the delay.
fn @types.Game::update_stage_clear(game : @types.Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  game.scroll_speed = @types.maxf(90.0, game.scroll_speed - 140.0 * dt)

  game.update_effects(dt)
  game.emit_ambient_traffic_glow(dt)

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

  if game.input_restart_press || game.result_t >= @types.stage_clear_delay {
    game.start_stage(game.stage + 1)
  }
}

///|
/// Runs the game-over state: decelerates scroll speed, keeps effects alive, and returns to the title when the player presses restart.
fn @types.Game::update_game_over(game : @types.Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  game.scroll_speed = @types.maxf(52.0, game.scroll_speed - 120.0 * dt)

  game.update_effects(dt)
  game.emit_ambient_traffic_glow(dt)

  if game.input_restart_press {
    game.init_title_scene()
  }
}

///|
/// Advances the game simulation by one frame using the current input state.
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  game.hint_t = game.hint_t + dt

  // Read mouse/touch state into game struct
  game.mouse_x = Float::from_int(@raylib.get_mouse_x())
  game.mouse_y = Float::from_int(@raylib.get_mouse_y())
  game.touch_count = @raylib.get_touch_point_count()
  game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
    game.touch_count > 0

  // Process input based on state
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
