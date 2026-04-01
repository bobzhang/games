///|
pub fn spawn_boss(game : @types.Game, kind : @types.BossKind) -> Unit {
  let stats = boss_stats(kind)
  game.boss = Some({
    active: true,
    kind,
    pos: @types.vec2(game.arena_width / 2.0, 200.0),
    vel: @types.vec2_zero(),
    hp: stats.0,
    max_hp: stats.0,
    phase: 1,
    phase_timer: 0.0,
    attack_timer: 2.0,
    pattern_index: 0,
    radius: stats.1,
    shield: stats.2,
    enraged: false,
    spawn_timer: 0.0,
    score_value: stats.3,
  })
}

///|
fn boss_stats(kind : @types.BossKind) -> (Int, Float, Int, Int) {
  // (hp, radius, shield, score)
  match kind {
    Leviathan => (60, 50.0, 0, 500)
    Hive => (40, 40.0, 0, 400)
    Dreadnought => (80, 55.0, 10, 600)
  }
}

///|
pub fn update_boss(game : @types.Game, dt : Float) -> Unit {
  match game.boss {
    None => ()
    Some(boss) => {
      if !boss.active {
        return
      }
      let ship = game.ship
      boss.phase_timer = boss.phase_timer + dt
      boss.attack_timer = boss.attack_timer - dt
      boss.spawn_timer = boss.spawn_timer - dt
      // Phase transitions
      let hp_pct = Float::from_int(boss.hp) / Float::from_int(boss.max_hp)
      if hp_pct < 0.25 && boss.phase < 3 {
        boss.phase = 3
        boss.enraged = true
        @types.push_sound(game, BossPhase)
        @types.set_message(game, "BOSS ENRAGED!", 2.0)
      } else if hp_pct < 0.5 && boss.phase < 2 {
        boss.phase = 2
        @types.push_sound(game, BossPhase)
        @types.set_message(game, "BOSS PHASE 2", 1.5)
      }
      match boss.kind {
        Leviathan => update_leviathan(game, boss, ship, dt)
        Hive => update_hive(game, boss, ship, dt)
        Dreadnought => update_dreadnought(game, boss, ship, dt)
      }
      // Clamp to arena
      @physics.clamp_to_arena(
        boss.pos,
        boss.radius,
        game.arena_width,
        game.arena_height,
      )
    }
  }
}

///|
fn update_leviathan(
  game : @types.Game,
  boss : @types.Boss,
  ship : @types.Ship,
  dt : Float,
) -> Unit {
  // Leviathan: charges at player, fires spread shots
  let to_player = @types.vec2_normalize(@types.vec2_sub(ship.pos, boss.pos))
  let charge_speed : Float = if boss.enraged { 250.0 } else { 150.0 }
  // Move toward player
  boss.vel.x = @types.lerpf(boss.vel.x, to_player.x * charge_speed, 2.0 * dt)
  boss.vel.y = @types.lerpf(boss.vel.y, to_player.y * charge_speed, 2.0 * dt)
  boss.pos.x = boss.pos.x + boss.vel.x * dt
  boss.pos.y = boss.pos.y + boss.vel.y * dt
  // Attack patterns based on phase
  if boss.attack_timer <= 0.0 {
    let shot_count = match boss.phase {
      1 => 5
      2 => 8
      _ => 12
    }
    let fire_rate : Float = if boss.enraged { 1.0 } else { 2.0 }
    boss.attack_timer = fire_rate
    // Spread shot toward player
    let base_angle = @types.angle_to(boss.pos, ship.pos)
    let spread : Float = if boss.phase >= 2 { 0.8 } else { 0.5 }
    for i in 0..<shot_count {
      let t = Float::from_int(i) / Float::from_int(shot_count - 1) - 0.5
      let angle = base_angle + t * spread
      let target = @types.vec2(
        boss.pos.x + @types.cosf(angle) * 400.0,
        boss.pos.y + @types.sinf(angle) * 400.0,
      )
      @weapons.fire_enemy_projectile(game, boss.pos, target, 200.0, 2)
    }
    @types.add_shake(game.shake, @types.shake_boss_hit)
  }
}

///|
fn update_hive(
  game : @types.Game,
  boss : @types.Boss,
  ship : @types.Ship,
  dt : Float,
) -> Unit {
  // Hive: spawns drones, retreats when close
  let dist = @types.vec2_dist(boss.pos, ship.pos)
  let dir = @types.vec2_normalize(@types.vec2_sub(ship.pos, boss.pos))
  if dist < 300.0 {
    // Retreat
    boss.vel.x = -dir.x * 120.0
    boss.vel.y = -dir.y * 120.0
  } else {
    // Slow approach
    boss.vel.x = dir.x * 40.0
    boss.vel.y = dir.y * 40.0
  }
  boss.pos.x = boss.pos.x + boss.vel.x * dt
  boss.pos.y = boss.pos.y + boss.vel.y * dt
  // Spawn drones
  let spawn_rate : Float = match boss.phase {
    1 => 3.0
    2 => 2.0
    _ => 1.0
  }
  if boss.spawn_timer <= 0.0 {
    boss.spawn_timer = spawn_rate
    let spawn_count = if boss.enraged { 3 } else { 2 }
    for _i in 0..<spawn_count {
      let angle = @types.rng_float() * 6.28
      let ox = @types.cosf(angle) * boss.radius * 1.5
      let oy = @types.sinf(angle) * boss.radius * 1.5
      @enemies.spawn_enemy(game, Swarm, boss.pos.x + ox, boss.pos.y + oy)
    }
  }
  // Periodic ring shot
  if boss.attack_timer <= 0.0 {
    let hive_rate : Float = if boss.enraged { 2.0 } else { 3.5 }
    boss.attack_timer = hive_rate
    let ring_count = if boss.phase >= 2 { 16 } else { 10 }
    for i in 0..<ring_count {
      let angle = Float::from_int(i) / Float::from_int(ring_count) * 6.28
      let target = @types.vec2(
        boss.pos.x + @types.cosf(angle) * 300.0,
        boss.pos.y + @types.sinf(angle) * 300.0,
      )
      @weapons.fire_enemy_projectile(game, boss.pos, target, 180.0, 1)
    }
  }
}

///|
fn update_dreadnought(
  game : @types.Game,
  boss : @types.Boss,
  ship : @types.Ship,
  dt : Float,
) -> Unit {
  // Dreadnought: slow, heavily shielded, powerful attacks
  let dir = @types.vec2_normalize(@types.vec2_sub(ship.pos, boss.pos))
  let move_speed : Float = 50.0
  boss.vel.x = dir.x * move_speed
  boss.vel.y = dir.y * move_speed
  boss.pos.x = boss.pos.x + boss.vel.x * dt
  boss.pos.y = boss.pos.y + boss.vel.y * dt
  // Shield regen in phase 1
  if boss.phase == 1 && boss.shield < 10 {
    boss.spawn_timer = boss.spawn_timer - dt
    if boss.spawn_timer <= 0.0 {
      boss.spawn_timer = 5.0
      boss.shield = @types.mini(boss.shield + 3, 10)
    }
  }
  // Attacks
  if boss.attack_timer <= 0.0 {
    let pattern = boss.pattern_index % 3
    boss.pattern_index += 1
    match pattern {
      0 => {
        // Heavy aimed shot
        let rate0 : Float = if boss.enraged { 1.0 } else { 2.0 }
        boss.attack_timer = rate0
        @weapons.fire_enemy_projectile(game, boss.pos, ship.pos, 350.0, 4)
        @types.add_shake(game.shake, 3.0)
      }
      1 => {
        // Cross pattern
        let rate1 : Float = if boss.enraged { 1.5 } else { 2.5 }
        boss.attack_timer = rate1
        let dirs : Array[Float] = [0.0, 1.57, 3.14, 4.71]
        for i in 0..<dirs.length() {
          let angle = dirs[i]
          let target = @types.vec2(
            boss.pos.x + @types.cosf(angle) * 400.0,
            boss.pos.y + @types.sinf(angle) * 400.0,
          )
          @weapons.fire_enemy_projectile(game, boss.pos, target, 250.0, 3)
        }
      }
      _ => {
        // Spawn shield bearer
        boss.attack_timer = 3.0
        if boss.phase >= 2 {
          @enemies.spawn_enemy(
            game,
            ShieldBearer,
            boss.pos.x + @types.rng_range(-80.0, 80.0),
            boss.pos.y + @types.rng_range(-80.0, 80.0),
          )
        }
      }
    }
  }
}

///|
pub fn boss_name(kind : @types.BossKind) -> String {
  match kind {
    Leviathan => "THE LEVIATHAN"
    Hive => "THE HIVE MIND"
    Dreadnought => "DREADNOUGHT"
  }
}

///|
pub fn boss_for_depth(depth : Int) -> @types.BossKind {
  match depth % 3 {
    0 => Leviathan
    1 => Hive
    _ => Dreadnought
  }
}
