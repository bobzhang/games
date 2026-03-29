///|
fn count_active_minions(game : @types.Game) -> Int {
  let mut count = 0
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if e.active && e.kind != BroodMother && e.kind != LichKing {
      match e.state {
        Dead(_) => ()
        _ => count += 1
      }
    }
  }
  count
}

///|
pub fn update_boss(game : @types.Game, dt : Float) -> Unit {
  if !game.boss_active {
    return
  }
  // Find the boss enemy
  let mut boss_idx = -1
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if e.active && (e.kind == BroodMother || e.kind == LichKing) {
      boss_idx = i
      break
    }
  }
  if boss_idx < 0 {
    game.boss_active = false
    return
  }
  let boss = game.enemies[boss_idx]
  // If boss is dead, deactivate boss mode and skip all AI
  match boss.state {
    Dead(_) => {
      game.boss_active = false
      return
    }
    _ => ()
  }
  let p = game.player

  // Determine phase from HP
  let hp_ratio = Float::from_int(boss.hp) / Float::from_int(boss.max_hp)
  let new_phase = if hp_ratio > 0.75 {
    1
  } else if hp_ratio > 0.5 {
    2
  } else if hp_ratio > 0.25 {
    3
  } else {
    4
  }

  if new_phase != game.boss_phase {
    game.boss_phase = new_phase
    game.boss_phase_timer = 0.0
    push_event(game, BossPhaseChange(new_phase))
    shake_camera(game, 10.0, 0.5)
    boss.attack_cooldown = 1.5 // Brief pause before new phase attacks
    boss.vx = 0.0 // Stop movement during transition
    boss.vy = 0.0
    // Spawn minions on phase change (cap at 20 to avoid pool overflow)
    if new_phase >= 2 && count_active_minions(game) < 20 {
      let count = new_phase
      let minion_kind : @types.EnemyKind = if boss.kind == LichKing {
        Skeleton
      } else {
        Spider
      }
      for _i in 0..<count {
        if count_active_minions(game) >= 20 {
          break
        }
        let (s1, ox) = @types.rng_range(game.rng_state, -100.0, 100.0)
        let (s2, oy) = @types.rng_range(s1, -100.0, 100.0)
        game.rng_state = s2
        spawn_enemy(game, minion_kind, boss.x + ox, boss.y + oy)
      }
    }
  }

  game.boss_phase_timer += dt
  boss.attack_cooldown -= dt
  boss.phase += dt

  if game.boss_phase_timer < 0.5 {
    // Brief pause at phase transition
    return
  }

  // Phase-based AI
  let (dx, dy) = @types.normalize(p.x - boss.x, p.y - boss.y)
  boss.facing_x = dx
  boss.facing_y = dy

  match boss.kind {
    LichKing =>
      match game.boss_phase {
        1 => lich_phase1_ai(game, boss, dt, dx, dy)
        2 => lich_phase2_ai(game, boss, dt, dx, dy)
        3 => lich_phase3_ai(game, boss, dt, dx, dy)
        _ => lich_phase4_ai(game, boss, dt, dx, dy)
      }
    _ =>
      match game.boss_phase {
        1 => phase1_ai(game, boss, dt, dx, dy)
        2 => phase2_ai(game, boss, dt, dx, dy)
        3 => phase3_ai(game, boss, dt, dx, dy)
        _ => phase4_ai(game, boss, dt, dx, dy)
      }
  }

  // Apply velocity
  boss.x += boss.vx * dt
  boss.y += boss.vy * dt
  boss.vx *= 0.92
  boss.vy *= 0.92
  // Tile collision for boss
  collide_enemy_with_tiles(game, boss)
}

///|
fn phase1_ai(
  game : @types.Game,
  boss : @types.Enemy,
  _dt : Float,
  dx : Float,
  dy : Float
) -> Unit {
  // Phase 1: Slow chase + charge attack + web projectiles
  let stats = @data.get_enemy_stats(boss.kind, game.floor_num)
  boss.vx += dx * stats.speed * 0.5
  boss.vy += dy * stats.speed * 0.5

  if boss.attack_cooldown <= 0.0 {
    game.boss_attack_pattern = (game.boss_attack_pattern + 1) % 3
    match game.boss_attack_pattern {
      0 => boss_charge_attack(game, boss, dx, dy)
      1 => boss_web_attack(game, boss, dx, dy)
      _ => boss_slam_attack(game, boss)
    }
    boss.attack_cooldown = 2.0
  }
}

///|
fn phase2_ai(
  game : @types.Game,
  boss : @types.Enemy,
  _dt : Float,
  dx : Float,
  dy : Float
) -> Unit {
  // Phase 2: Faster, more frequent attacks, spawns minions
  let stats = @data.get_enemy_stats(boss.kind, game.floor_num)
  boss.vx += dx * stats.speed * 0.7
  boss.vy += dy * stats.speed * 0.7

  if boss.attack_cooldown <= 0.0 {
    game.boss_attack_pattern = (game.boss_attack_pattern + 1) % 4
    match game.boss_attack_pattern {
      0 => boss_charge_attack(game, boss, dx, dy)
      1 => boss_web_spread(game, boss)
      2 => boss_slam_attack(game, boss)
      _ => boss_web_attack(game, boss, dx, dy)
    }
    boss.attack_cooldown = 1.5
  }
}

///|
fn phase3_ai(
  game : @types.Game,
  boss : @types.Enemy,
  _dt : Float,
  dx : Float,
  dy : Float
) -> Unit {
  // Phase 3: Enraged, continuous attacks
  let stats = @data.get_enemy_stats(boss.kind, game.floor_num)
  boss.vx += dx * stats.speed * 1.0
  boss.vy += dy * stats.speed * 1.0

  if boss.attack_cooldown <= 0.0 {
    game.boss_attack_pattern = (game.boss_attack_pattern + 1) % 3
    match game.boss_attack_pattern {
      0 => {
        boss_charge_attack(game, boss, dx, dy)
        boss_web_spread(game, boss)
      }
      1 => boss_slam_attack(game, boss)
      _ => boss_web_spread(game, boss)
    }
    boss.attack_cooldown = 1.0
  }
}

///|
fn phase4_ai(
  game : @types.Game,
  boss : @types.Enemy,
  dt : Float,
  dx : Float,
  dy : Float
) -> Unit {
  // Phase 4: Desperate, everything faster
  let stats = @data.get_enemy_stats(boss.kind, game.floor_num)
  boss.vx += dx * stats.speed * 1.3
  boss.vy += dy * stats.speed * 1.3

  // Continuous minion spawning (capped to avoid pool overflow)
  if count_active_minions(game) < 20 &&
    (game.boss_phase_timer * 2.0).to_int() % 3 == 0 {
    let (s1, roll) = @types.rng_next(game.rng_state)
    game.rng_state = s1
    if roll < 0.02 {
      let (s2, ox) = @types.rng_range(game.rng_state, -80.0, 80.0)
      let (s3, oy) = @types.rng_range(s2, -80.0, 80.0)
      game.rng_state = s3
      spawn_enemy(game, SlimeSmall, boss.x + ox, boss.y + oy)
    }
  }

  if boss.attack_cooldown <= 0.0 {
    game.boss_attack_pattern = (game.boss_attack_pattern + 1) % 2
    match game.boss_attack_pattern {
      0 => {
        boss_charge_attack(game, boss, dx, dy)
        boss_slam_attack(game, boss)
      }
      _ => boss_web_spread(game, boss)
    }
    boss.attack_cooldown = 0.7
  }
  ignore(dt)
}

///|
fn boss_charge_attack(
  game : @types.Game,
  boss : @types.Enemy,
  dx : Float,
  dy : Float
) -> Unit {
  // Lunge toward player
  boss.vx = dx * 500.0
  boss.vy = dy * 500.0
  boss.state = Attack(0.4)
  shake_camera(game, 4.0, 0.15)
}

///|
fn boss_web_attack(
  game : @types.Game,
  boss : @types.Enemy,
  dx : Float,
  dy : Float
) -> Unit {
  // Single aimed web projectile
  let idx = @types.alloc_projectile(game.projectiles)
  let proj = game.projectiles[idx]
  proj.active = true
  proj.x = boss.x + dx * 30.0
  proj.y = boss.y + dy * 30.0
  proj.vx = dx * 250.0
  proj.vy = dy * 250.0
  proj.damage = 15
  proj.is_player = false
  proj.lifetime = 3.0
  proj.radius = 8.0
  proj.piercing = false
  proj.homing = false
  proj.is_crit = false
}

///|
fn boss_web_spread(game : @types.Game, boss : @types.Enemy) -> Unit {
  // 8-directional web spread
  let directions : Array[(Float, Float)] = [
    (1.0, 0.0),
    (-1.0, 0.0),
    (0.0, 1.0),
    (0.0, -1.0),
    (0.707, 0.707),
    (-0.707, 0.707),
    (0.707, -0.707),
    (-0.707, -0.707),
  ]
  for i in 0..<directions.length() {
    let (dx, dy) = directions[i]
    let idx = @types.alloc_projectile(game.projectiles)
    let proj = game.projectiles[idx]
    proj.active = true
    proj.x = boss.x + dx * 30.0
    proj.y = boss.y + dy * 30.0
    proj.vx = dx * 180.0
    proj.vy = dy * 180.0
    proj.damage = 10
    proj.is_player = false
    proj.lifetime = 2.5
    proj.radius = 6.0
    proj.piercing = false
    proj.homing = false
    proj.is_crit = false
  }
  shake_camera(game, 3.0, 0.2)
}

///|
fn boss_slam_attack(game : @types.Game, boss : @types.Enemy) -> Unit {
  // AoE ground slam - damage nearby player
  let p = game.player
  let d2 = @types.dist2(boss.x, boss.y, p.x, p.y)
  let slam_range : Float = 120.0
  if d2 < slam_range * slam_range {
    damage_player(game, 20)
    // Apply slow effect
    apply_status_effect(p, Slow(2.0))
  }
  // Visual: big particle burst
  spawn_particles_burst(game, boss.x, boss.y, 25, 150, 100, 60)
  shake_camera(game, 8.0, 0.3)
}

///|
pub fn apply_status_effect(p : @types.Player, effect : @types.StatusEffect) -> Unit {
  // Replace existing effect of same type or add new
  for i in 0..<p.status_effects.length() {
    match (p.status_effects[i], effect) {
      (Slow(_), Slow(_)) => {
        p.status_effects[i] = effect
        return
      }
      (Poison(_), Poison(_)) => {
        p.status_effects[i] = effect
        return
      }
      (Shield(_), Shield(_)) => {
        p.status_effects[i] = effect
        return
      }
      (Haste(_), Haste(_)) => {
        p.status_effects[i] = effect
        return
      }
      _ => ()
    }
  }
  p.status_effects.push(effect)
}

///|
pub fn spawn_boss(game : @types.Game, x : Float, y : Float) -> Unit {
  let kind : @types.EnemyKind = if game.floor_num % 10 == 0 {
    LichKing
  } else {
    BroodMother
  }
  let idx = @types.alloc_enemy(game.enemies)
  let e = game.enemies[idx]
  let stats = @data.get_enemy_stats(kind, game.floor_num)
  e.active = true
  e.kind = kind
  e.x = x
  e.y = y
  e.vx = 0.0
  e.vy = 0.0
  e.hp = stats.hp
  e.max_hp = stats.hp
  e.state = Idle
  e.facing_x = -1.0
  e.facing_y = 0.0
  e.patrol_x = x
  e.patrol_y = y
  e.attack_cooldown = 2.0
  e.anim_timer = 0.0
  e.anim_frame = 0
  e.flash_timer = 0.0
  e.knockback_timer = 0.0
  e.phase = 0.0
  e.room_id = match game.floor {
    Some(floor) => floor.current_room
    None => -1
  }
  game.boss_active = true
  game.boss_phase = 1
  game.boss_phase_timer = 0.0
  game.boss_attack_pattern = 0
}

///|
fn lich_phase1_ai(
  game : @types.Game,
  boss : @types.Enemy,
  _dt : Float,
  dx : Float,
  dy : Float
) -> Unit {
  // Phase 1: Teleport around room, cast homing dark orbs
  let stats = @data.get_enemy_stats(boss.kind, game.floor_num)
  // Slow drift away from player
  boss.vx += -dx * stats.speed * 0.3
  boss.vy += -dy * stats.speed * 0.3
  if boss.attack_cooldown <= 0.0 {
    game.boss_attack_pattern = (game.boss_attack_pattern + 1) % 3
    match game.boss_attack_pattern {
      0 => lich_dark_orb(game, boss, dx, dy)
      1 => lich_teleport(game, boss)
      _ => lich_dark_orb(game, boss, dx, dy)
    }
    boss.attack_cooldown = 2.0
  }
}

///|
fn lich_phase2_ai(
  game : @types.Game,
  boss : @types.Enemy,
  _dt : Float,
  dx : Float,
  dy : Float
) -> Unit {
  // Phase 2: Summon skeletons, cast AoE darkness ring
  let stats = @data.get_enemy_stats(boss.kind, game.floor_num)
  boss.vx += -dx * stats.speed * 0.4
  boss.vy += -dy * stats.speed * 0.4
  if boss.attack_cooldown <= 0.0 {
    game.boss_attack_pattern = (game.boss_attack_pattern + 1) % 4
    match game.boss_attack_pattern {
      0 => lich_dark_orb(game, boss, dx, dy)
      1 => lich_darkness_ring(game, boss)
      2 => lich_summon_skeletons(game, boss)
      _ => lich_teleport(game, boss)
    }
    boss.attack_cooldown = 1.5
  }
}

///|
fn lich_phase3_ai(
  game : @types.Game,
  boss : @types.Enemy,
  _dt : Float,
  dx : Float,
  dy : Float
) -> Unit {
  // Phase 3: Rapid-fire orbs, constant skeleton spawning
  let stats = @data.get_enemy_stats(boss.kind, game.floor_num)
  boss.vx += -dx * stats.speed * 0.5
  boss.vy += -dy * stats.speed * 0.5
  if boss.attack_cooldown <= 0.0 {
    game.boss_attack_pattern = (game.boss_attack_pattern + 1) % 3
    match game.boss_attack_pattern {
      0 => {
        lich_dark_orb(game, boss, dx, dy)
        lich_dark_orb(game, boss, -dy, dx)
      }
      1 => {
        lich_darkness_ring(game, boss)
        lich_summon_skeletons(game, boss)
      }
      _ => {
        lich_teleport(game, boss)
        lich_dark_orb(game, boss, dx, dy)
      }
    }
    boss.attack_cooldown = 1.0
  }
}

///|
fn lich_phase4_ai(
  game : @types.Game,
  boss : @types.Enemy,
  dt : Float,
  dx : Float,
  dy : Float
) -> Unit {
  // Phase 4: Enraged - all abilities combined
  let stats = @data.get_enemy_stats(boss.kind, game.floor_num)
  boss.vx += -dx * stats.speed * 0.6
  boss.vy += -dy * stats.speed * 0.6
  // Continuous skeleton spawning (capped to avoid pool overflow)
  if count_active_minions(game) < 20 &&
    (game.boss_phase_timer * 2.0).to_int() % 3 == 0 {
    let (s1, roll) = @types.rng_next(game.rng_state)
    game.rng_state = s1
    if roll < 0.02 {
      let (s2, ox) = @types.rng_range(game.rng_state, -80.0, 80.0)
      let (s3, oy) = @types.rng_range(s2, -80.0, 80.0)
      game.rng_state = s3
      spawn_enemy(game, Skeleton, boss.x + ox, boss.y + oy)
    }
  }
  if boss.attack_cooldown <= 0.0 {
    game.boss_attack_pattern = (game.boss_attack_pattern + 1) % 3
    match game.boss_attack_pattern {
      0 => {
        lich_dark_orb(game, boss, dx, dy)
        lich_darkness_ring(game, boss)
      }
      1 => {
        lich_teleport(game, boss)
        lich_summon_skeletons(game, boss)
      }
      _ => {
        lich_dark_orb(game, boss, dx, dy)
        lich_dark_orb(game, boss, -dx, -dy)
      }
    }
    boss.attack_cooldown = 0.7
  }
  ignore(dt)
}

///|
fn lich_dark_orb(
  game : @types.Game,
  boss : @types.Enemy,
  dx : Float,
  dy : Float
) -> Unit {
  // Homing dark orb toward player
  let idx = @types.alloc_projectile(game.projectiles)
  let proj = game.projectiles[idx]
  proj.active = true
  proj.x = boss.x + dx * 30.0
  proj.y = boss.y + dy * 30.0
  proj.vx = dx * 200.0
  proj.vy = dy * 200.0
  proj.damage = 18
  proj.is_player = false
  proj.lifetime = 4.0
  proj.radius = 10.0
  proj.piercing = false
  proj.homing = true
  proj.is_crit = false
}

///|
fn lich_teleport(game : @types.Game, boss : @types.Enemy) -> Unit {
  // Teleport to a random position in the room
  match game.floor {
    None => ()
    Some(floor) => {
      let room = floor.rooms[floor.current_room]
      let ts = @types.tile_sizef
      let (s1, rx) = @types.rng_range(
        game.rng_state,
        Float::from_int(room.x + 3) * ts,
        Float::from_int(room.x + room.w - 3) * ts,
      )
      let (s2, ry) = @types.rng_range(
        s1,
        Float::from_int(room.y + 3) * ts,
        Float::from_int(room.y + room.h - 3) * ts,
      )
      game.rng_state = s2
      // Particles at old position
      spawn_particles_burst(game, boss.x, boss.y, 15, 140, 60, 200)
      boss.x = rx
      boss.y = ry
      boss.vx = 0.0
      boss.vy = 0.0
      // Particles at new position
      spawn_particles_burst(game, boss.x, boss.y, 15, 140, 60, 200)
    }
  }
}

///|
fn lich_darkness_ring(game : @types.Game, boss : @types.Enemy) -> Unit {
  // 12-directional ring of dark projectiles
  let num_orbs = 12
  for i in 0..<num_orbs {
    let angle = Float::from_int(i) / Float::from_int(num_orbs) * 6.28318
    let dx = Float::from_double(@math.cos(angle.to_double()))
    let dy = Float::from_double(@math.sin(angle.to_double()))
    let idx = @types.alloc_projectile(game.projectiles)
    let proj = game.projectiles[idx]
    proj.active = true
    proj.x = boss.x + dx * 30.0
    proj.y = boss.y + dy * 30.0
    proj.vx = dx * 160.0
    proj.vy = dy * 160.0
    proj.damage = 12
    proj.is_player = false
    proj.lifetime = 3.0
    proj.radius = 7.0
    proj.piercing = false
    proj.homing = false
    proj.is_crit = false
  }
  shake_camera(game, 5.0, 0.25)
}

///|
fn lich_summon_skeletons(game : @types.Game, boss : @types.Enemy) -> Unit {
  // Summon 2-3 skeleton minions (capped to avoid pool overflow)
  if count_active_minions(game) >= 20 {
    spawn_particles_burst(game, boss.x, boss.y, 10, 140, 60, 200)
    return
  }
  let (s1, count_roll) = @types.rng_int(game.rng_state, 2, 3)
  game.rng_state = s1
  for _i in 0..<count_roll {
    if count_active_minions(game) >= 20 {
      break
    }
    let (s2, ox) = @types.rng_range(game.rng_state, -80.0, 80.0)
    let (s3, oy) = @types.rng_range(s2, -80.0, 80.0)
    game.rng_state = s3
    spawn_enemy(game, Skeleton, boss.x + ox, boss.y + oy)
  }
  spawn_particles_burst(game, boss.x, boss.y, 10, 140, 60, 200)
}
