///|
pub fn spawn_enemy(
  game : @types.Game,
  kind : @types.EnemyKind,
  x : Float,
  y : Float
) -> Unit {
  let idx = @types.alloc_enemy(game.enemies)
  if idx < 0 {
    return
  }
  let e = game.enemies[idx]
  e.active = true
  e.kind = kind
  e.pos = @types.vec2(x, y)
  e.vel = @types.vec2_zero()
  e.angle = 0.0
  e.frozen_timer = 0.0
  e.shield = 0
  e.behavior_timer = 0.0
  e.target_pos = @types.vec2_zero()
  let stats = enemy_stats(kind)
  e.hp = stats.0
  e.max_hp = stats.0
  e.damage = stats.1
  e.speed = stats.2
  e.fire_rate = stats.3
  e.fire_timer = stats.3 * @types.rng_float()
  e.radius = stats.4
  e.score_value = stats.5
}

///|
fn enemy_stats(
  kind : @types.EnemyKind
) -> (Int, Int, Float, Float, Float, Int) {
  // (hp, damage, speed, fire_rate, radius, score)
  match kind {
    Drone => (2, 1, 150.0, 2.0, 14.0, 10)
    Fighter => (4, 2, 120.0, 1.5, 18.0, 25)
    Kiter => (3, 1, 180.0, 1.2, 15.0, 20)
    Swarm => (1, 1, 200.0, 3.0, 10.0, 5)
    Turret => (6, 2, 0.0, 0.8, 22.0, 30)
    Carrier => (8, 1, 60.0, 4.0, 28.0, 50)
    Bomber => (3, 3, 100.0, 2.5, 16.0, 35)
    ShieldBearer => (5, 1, 90.0, 1.8, 20.0, 40)
  }
}

///|
pub fn update_enemy_ai(
  game : @types.Game,
  enemy : @types.Enemy,
  dt : Float
) -> Unit {
  if !(enemy.active) || enemy.frozen_timer > 0.0 {
    return
  }
  let ship = game.ship
  let to_player = @types.vec2_sub(ship.pos, enemy.pos)
  let dist = @types.vec2_len(to_player)
  let dir = @types.vec2_normalize(to_player)
  enemy.angle = @types.angle_to(enemy.pos, ship.pos)
  match enemy.kind {
    Drone => {
      // Simple chase
      enemy.vel.x = dir.x * enemy.speed
      enemy.vel.y = dir.y * enemy.speed
      // Shoot when close enough
      enemy.fire_timer = enemy.fire_timer - dt
      if enemy.fire_timer <= 0.0 && dist < 400.0 {
        enemy.fire_timer = enemy.fire_rate
        @weapons.fire_enemy_projectile(
          game, enemy.pos, ship.pos, 250.0, enemy.damage,
        )
      }
    }
    Fighter => {
      // Chase and circle
      if dist > 200.0 {
        enemy.vel.x = dir.x * enemy.speed
        enemy.vel.y = dir.y * enemy.speed
      } else {
        // Circle strafe
        let perp = @types.vec2(-dir.y, dir.x)
        enemy.vel.x = perp.x * enemy.speed
        enemy.vel.y = perp.y * enemy.speed
      }
      enemy.fire_timer = enemy.fire_timer - dt
      if enemy.fire_timer <= 0.0 && dist < 500.0 {
        enemy.fire_timer = enemy.fire_rate
        @weapons.fire_enemy_projectile(
          game, enemy.pos, ship.pos, 300.0, enemy.damage,
        )
      }
    }
    Kiter => {
      // Keep distance, shoot from afar
      if dist < 250.0 {
        // Flee
        enemy.vel.x = -dir.x * enemy.speed
        enemy.vel.y = -dir.y * enemy.speed
      } else if dist > 400.0 {
        // Approach
        enemy.vel.x = dir.x * enemy.speed * 0.5
        enemy.vel.y = dir.y * enemy.speed * 0.5
      } else {
        // Strafe
        let perp = @types.vec2(-dir.y, dir.x)
        enemy.vel.x = perp.x * enemy.speed * 0.7
        enemy.vel.y = perp.y * enemy.speed * 0.7
      }
      enemy.fire_timer = enemy.fire_timer - dt
      if enemy.fire_timer <= 0.0 {
        enemy.fire_timer = enemy.fire_rate
        @weapons.fire_enemy_projectile(
          game, enemy.pos, ship.pos, 350.0, enemy.damage,
        )
      }
    }
    Swarm => {
      // Rush directly at player
      enemy.vel.x = dir.x * enemy.speed
      enemy.vel.y = dir.y * enemy.speed
      // Contact damage only, no shooting
    }
    Turret => {
      // Stationary, shoots frequently
      enemy.vel.x = 0.0
      enemy.vel.y = 0.0
      enemy.fire_timer = enemy.fire_timer - dt
      if enemy.fire_timer <= 0.0 {
        enemy.fire_timer = enemy.fire_rate
        // Burst of 3
        for j in 0..<3 {
          let spread = (Float::from_int(j) - 1.0) * 0.15
          let angle = enemy.angle + spread
          let target = @types.vec2(
            enemy.pos.x + @types.cosf(angle) * 300.0,
            enemy.pos.y + @types.sinf(angle) * 300.0,
          )
          @weapons.fire_enemy_projectile(
            game, enemy.pos, target, 280.0, enemy.damage,
          )
        }
      }
    }
    Carrier => {
      // Slow, spawns drones periodically
      if dist > 300.0 {
        enemy.vel.x = dir.x * enemy.speed
        enemy.vel.y = dir.y * enemy.speed
      } else {
        enemy.vel.x = -dir.x * enemy.speed * 0.3
        enemy.vel.y = -dir.y * enemy.speed * 0.3
      }
      enemy.fire_timer = enemy.fire_timer - dt
      if enemy.fire_timer <= 0.0 {
        enemy.fire_timer = enemy.fire_rate
        // Spawn a swarm drone
        let offset_x = @types.rng_range(-30.0, 30.0)
        let offset_y = @types.rng_range(-30.0, 30.0)
        spawn_enemy(game, Swarm, enemy.pos.x + offset_x, enemy.pos.y + offset_y)
      }
    }
    Bomber => {
      // Rush in, explode near player
      enemy.vel.x = dir.x * enemy.speed
      enemy.vel.y = dir.y * enemy.speed
      if dist < 50.0 {
        // Self-destruct
        enemy.hp = 0
        // Explosion handled in combat resolution
      }
    }
    ShieldBearer => {
      // Has shield, approaches cautiously
      if enemy.shield <= 0 {
        enemy.shield = 0
      }
      if dist > 250.0 {
        enemy.vel.x = dir.x * enemy.speed
        enemy.vel.y = dir.y * enemy.speed
      } else {
        let perp = @types.vec2(-dir.y, dir.x)
        enemy.vel.x = perp.x * enemy.speed * 0.6
        enemy.vel.y = perp.y * enemy.speed * 0.6
      }
      enemy.fire_timer = enemy.fire_timer - dt
      if enemy.fire_timer <= 0.0 && dist < 400.0 {
        enemy.fire_timer = enemy.fire_rate
        @weapons.fire_enemy_projectile(
          game, enemy.pos, ship.pos, 220.0, enemy.damage,
        )
      }
    }
  }
}

///|
pub fn spawn_wave(game : @types.Game, wave : Int, sector_kind : @types.SectorKind) -> Unit {
  let count = @types.base_wave_enemies + wave
  let kinds = wave_enemy_pool(wave, sector_kind)
  for _i in 0..<count {
    let kind = kinds[@types.rng_int(kinds.length())]
    // Spawn at arena edges
    let side = @types.rng_int(4)
    let x : Float = match side {
      0 => @types.rng_range(0.0, game.arena_width)
      1 => @types.rng_range(0.0, game.arena_width)
      2 => 0.0
      _ => game.arena_width
    }
    let y : Float = match side {
      0 => 0.0
      1 => game.arena_height
      2 => @types.rng_range(0.0, game.arena_height)
      _ => @types.rng_range(0.0, game.arena_height)
    }
    spawn_enemy(game, kind, x, y)
    game.sector_enemies_total += 1
  }
}

///|
fn wave_enemy_pool(
  wave : Int,
  sector_kind : @types.SectorKind
) -> Array[@types.EnemyKind] {
  let base : Array[@types.EnemyKind] = match sector_kind {
    Asteroids => [Drone, Swarm]
    Nebula => [Kiter, Fighter]
    Station => [Turret, Fighter, ShieldBearer]
    EliteZone => [Fighter, Bomber, Carrier, ShieldBearer]
    _ => [Drone, Swarm, Fighter]
  }
  if wave >= 3 {
    base.push(Bomber)
  }
  if wave >= 5 {
    base.push(Carrier)
  }
  base
}

///|
pub fn enemy_shape_sides(kind : @types.EnemyKind) -> Int {
  match kind {
    Drone => 3
    Fighter => 4
    Kiter => 5
    Swarm => 3
    Turret => 6
    Carrier => 8
    Bomber => 3
    ShieldBearer => 6
  }
}
