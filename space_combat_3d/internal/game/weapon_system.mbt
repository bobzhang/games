// Projectile update and collision

///|
/// Updates all active projectiles including homing, movement, trails, and collision detection.
pub fn update_projectiles(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.projectiles.length() {
    let proj = game.projectiles[i]
    if !proj.active {
      continue
    }

    // Lifetime
    proj.life -= dt
    if proj.life <= 0.0 {
      proj.active = false
      continue
    }

    // Missile homing logic
    if proj.kind == Missile && proj.from_player && proj.target_idx >= 0 {
      if proj.fuel > 0.0 {
        proj.fuel -= dt
        if proj.target_idx < game.enemies.length() &&
          game.enemies[proj.target_idx].active {
          let target = game.enemies[proj.target_idx]
          let dx = target.x - proj.x
          let dy = target.y - proj.y
          let dz = target.z - proj.z
          let dist_to_target = @types.length3d(dx, dy, dz)

          // Proximity detonation
          if dist_to_target < @types.missile_prox_radius {
            game.missile_detonate(i)
            continue
          }

          let norm = @types.normalize3d(dx, dy, dz)
          let spd = @types.length3d(proj.vx, proj.vy, proj.vz)
          let cur_norm = @types.normalize3d(proj.vx, proj.vy, proj.vz)
          let turn = @types.missile_turn_rate * dt
          let nx = @types.lerpf(cur_norm.0, norm.0, turn)
          let ny = @types.lerpf(cur_norm.1, norm.1, turn)
          let nz = @types.lerpf(cur_norm.2, norm.2, turn)
          let new_norm = @types.normalize3d(nx, ny, nz)
          // Accelerate missile slightly over time
          let accel_spd = @types.minf(
            spd + 10.0 * dt,
            @types.missile_speed * 1.5,
          )
          proj.vx = new_norm.0 * accel_spd
          proj.vy = new_norm.1 * accel_spd
          proj.vz = new_norm.2 * accel_spd
        }
      }
    }

    // Move
    proj.x += proj.vx * dt
    proj.y += proj.vy * dt
    proj.z += proj.vz * dt

    // Trail particles
    if proj.kind == Laser && game.frame_counter % 3 == 0 {
      // Laser light trail: brief fading glow
      let idx2 = @types.alloc_particle(game)
      if idx2 >= 0 {
        let p = game.particles[idx2]
        p.active = true
        p.x = proj.x
        p.y = proj.y
        p.z = proj.z
        p.vx = 0.0
        p.vy = 0.0
        p.vz = 0.0
        p.life = 0.1
        p.max_life = 0.1
        p.r = if proj.from_player { 255 } else { 255 }
        p.g = if proj.from_player { 255 } else { 80 }
        p.b = if proj.from_player { 100 } else { 80 }
        p.size = 0.04
        p.kind = 3
      }
    }
    if proj.kind == Missile {
      // Missile smoke trail every frame, fire every 2 frames
      if game.frame_counter % 2 == 0 {
        @types.spawn_particles(game, proj.x, proj.y, proj.z, 1, 255, 200, 100)
      }
      if game.frame_counter % 3 == 0 {
        // Smoke trail
        let idx2 = @types.alloc_particle(game)
        if idx2 >= 0 {
          let p = game.particles[idx2]
          p.active = true
          p.x = proj.x + @types.rand_rangef(game, -0.1, 0.1)
          p.y = proj.y + @types.rand_rangef(game, -0.1, 0.1)
          p.z = proj.z + @types.rand_rangef(game, -0.1, 0.1)
          p.vx = @types.rand_rangef(game, -0.5, 0.5)
          p.vy = @types.rand_rangef(game, 0.2, 0.8)
          p.vz = @types.rand_rangef(game, -0.5, 0.5)
          p.life = 0.6
          p.max_life = 0.6
          p.r = 120
          p.g = 120
          p.b = 120
          p.size = 0.15
          p.kind = 0
        }
      }
    }
    if proj.kind == Plasma && game.frame_counter % 2 == 0 {
      // Plasma glowing orb trail
      let idx2 = @types.alloc_particle(game)
      if idx2 >= 0 {
        let p = game.particles[idx2]
        p.active = true
        p.x = proj.x
        p.y = proj.y
        p.z = proj.z
        p.vx = 0.0
        p.vy = 0.0
        p.vz = 0.0
        p.life = 0.25
        p.max_life = 0.25
        p.r = if proj.from_player { 100 } else { 255 }
        p.g = if proj.from_player { 255 } else { 100 }
        p.b = if proj.from_player { 100 } else { 100 }
        p.size = 0.2
        p.kind = 2
      }
    }
    if proj.kind == Railgun {
      // Railgun leaves a fading trail
      let idx2 = @types.alloc_particle(game)
      if idx2 >= 0 {
        let p = game.particles[idx2]
        p.active = true
        p.x = proj.x
        p.y = proj.y
        p.z = proj.z
        p.vx = 0.0
        p.vy = 0.0
        p.vz = 0.0
        p.life = 0.2
        p.max_life = 0.2
        p.r = 150
        p.g = 200
        p.b = 255
        p.size = 0.03
        p.kind = 3
      }
    }

    // Collision detection
    if proj.from_player {
      let mut hit_something = false

      // Check against enemies
      for j in 0..<game.enemies.length() {
        let e = game.enemies[j]
        if !e.active {
          continue
        }
        let dist = @types.distance3d(proj.x, proj.y, proj.z, e.x, e.y, e.z)
        let hit_radius : Float = e.size * 0.8
        if dist < hit_radius {
          // Apply damage - check weak points for capital ships
          let actual_damage = check_weak_point_hit(
            game, j, proj.x, proj.y, proj.z, proj.damage,
          )
          damage_enemy(game, j, actual_damage)
          game.player.shots_hit += 1

          // Hit sparks by weapon type
          let spark_r : Int = match proj.kind {
            Laser => 255
            Missile => 255
            Plasma => 100
            _ => 150
          }
          let spark_g : Int = match proj.kind {
            Laser => 50
            Missile => 180
            Plasma => 255
            _ => 200
          }
          let spark_b : Int = match proj.kind {
            Laser => 50
            Missile => 50
            Plasma => 100
            _ => 255
          }
          @types.spawn_particles(
            game,
            proj.x,
            proj.y,
            proj.z,
            5,
            spark_r,
            spark_g,
            spark_b,
          )

          // Plasma splash damage: hit nearby enemies within splash radius
          if proj.kind == Plasma {
            let splash_radius : Float = 8.0
            let splash_fraction : Float = 0.4
            for k in 0..<game.enemies.length() {
              if k == j {
                continue
              }
              let splash_e = game.enemies[k]
              if !splash_e.active {
                continue
              }
              let splash_dist = @types.distance3d(
                proj.x,
                proj.y,
                proj.z,
                splash_e.x,
                splash_e.y,
                splash_e.z,
              )
              if splash_dist < splash_radius {
                let falloff : Float = 1.0 - splash_dist / splash_radius
                let splash_dmg : Float = proj.damage * splash_fraction * falloff
                damage_enemy(game, k, splash_dmg)
              }
            }
            @types.spawn_particles(
              game,
              proj.x,
              proj.y,
              proj.z,
              8,
              100,
              255,
              100,
            )
          }

          if !proj.piercing {
            proj.active = false
            hit_something = true
            break
          }
          // Piercing rounds continue but lose damage
          proj.damage = proj.damage * 0.7
        }
      }

      // Check against asteroids
      if proj.active && !hit_something {
        for j in 0..<game.asteroids.length() {
          let a = game.asteroids[j]
          if !a.active {
            continue
          }
          let dist = @types.distance3d(proj.x, proj.y, proj.z, a.x, a.y, a.z)
          if dist < a.size {
            damage_asteroid(game, j, proj.damage)
            @types.spawn_particles(
              game,
              proj.x,
              proj.y,
              proj.z,
              4,
              150,
              130,
              100,
            )
            if !proj.piercing {
              proj.active = false
              break
            }
            proj.damage = proj.damage * 0.5
          }
        }
      }

      // Check against enemy stations
      if proj.active {
        for s in game.stations {
          if !s.active {
            continue
          }
          if s.kind != @types.station_enemy {
            continue
          }
          let dist = @types.distance3d(proj.x, proj.y, proj.z, s.x, s.y, s.z)
          if dist < 8.0 {
            s.hp -= proj.damage
            @types.spawn_particles(
              game,
              proj.x,
              proj.y,
              proj.z,
              5,
              200,
              100,
              50,
            )
            if !proj.piercing {
              proj.active = false
              break
            }
          }
        }
      }
    } else {
      // Enemy projectile: check against player
      let dist = @types.distance3d(
        proj.x,
        proj.y,
        proj.z,
        game.player.x,
        game.player.y,
        game.player.z,
      )
      if dist < 2.0 {
        damage_player(game, proj.damage)
        proj.active = false
        @types.spawn_particles(game, proj.x, proj.y, proj.z, 4, 255, 100, 100)
      } else if dist < @types.near_miss_distance && game.near_miss_timer <= 0.0 {
        // Near-miss: enemy projectile passed close without hitting
        game.near_miss_timer = @types.near_miss_duration
        // Compute direction from player to projectile for screen edge flash
        let nm_dx = proj.x - game.player.x
        let nm_dz = proj.z - game.player.z
        let nm_len = (nm_dx * nm_dx + nm_dz * nm_dz).sqrt()
        if nm_len > 0.01 {
          game.near_miss_dir_x = nm_dx / nm_len
          game.near_miss_dir_y = nm_dz / nm_len
        }
        // Brief directional camera shake
        game.camera_shake = @types.maxf(game.camera_shake, 0.15)
      }

      // Enemy projectiles also hit friendly stations
      if proj.active {
        for s in game.stations {
          if !s.active {
            continue
          }
          if s.kind != @types.station_friendly {
            continue
          }
          let sdist = @types.distance3d(proj.x, proj.y, proj.z, s.x, s.y, s.z)
          if sdist < 8.0 {
            s.hp -= proj.damage
            @types.spawn_particles(
              game,
              proj.x,
              proj.y,
              proj.z,
              3,
              200,
              150,
              50,
            )
            proj.active = false
            break
          }
        }
      }
    }
  }
}

///|
fn @types.Game::missile_detonate(game : @types.Game, proj_idx : Int) -> Unit {
  let proj = game.projectiles[proj_idx]
  proj.active = false

  // Explosion at detonation point
  @types.spawn_explosion(game, proj.x, proj.y, proj.z, 15, 255, 180, 50)
  game.camera_shake = @types.maxf(game.camera_shake, 0.4)

  // Area damage to nearby enemies
  for j in 0..<game.enemies.length() {
    let e = game.enemies[j]
    if !e.active {
      continue
    }
    let dist = @types.distance3d(proj.x, proj.y, proj.z, e.x, e.y, e.z)
    if dist < @types.missile_prox_radius * 2.0 {
      // Damage falls off with distance
      let falloff : Float = 1.0 - dist / (@types.missile_prox_radius * 2.0)
      let aoe_damage : Float = proj.damage * falloff
      damage_enemy(game, j, aoe_damage)
      game.player.shots_hit += 1
    }
  }

  // Also damage nearby asteroids
  for j in 0..<game.asteroids.length() {
    let a = game.asteroids[j]
    if !a.active {
      continue
    }
    let dist = @types.distance3d(proj.x, proj.y, proj.z, a.x, a.y, a.z)
    if dist < @types.missile_prox_radius * 2.0 {
      let falloff : Float = 1.0 - dist / (@types.missile_prox_radius * 2.0)
      let aoe_damage : Float = proj.damage * falloff
      damage_asteroid(game, j, aoe_damage)
    }
  }
}

///|
/// Updates all active particles including lifetime decay, movement, and size changes.
pub fn update_particles(game : @types.Game, dt : Float) -> Unit {
  for p in game.particles {
    if !p.active {
      continue
    }
    p.life -= dt
    if p.life <= 0.0 {
      p.active = false
      continue
    }
    p.x += p.vx * dt
    p.y += p.vy * dt
    p.z += p.vz * dt

    // Different behavior by particle kind
    if p.kind == 0 {
      // Standard particles: dampen and shrink
      p.vx *= 0.96
      p.vy *= 0.96
      p.vz *= 0.96
      p.size *= 0.98
    } else if p.kind == 1 {
      // Explosion particles: grow slightly then shrink
      let life_pct = p.life / p.max_life
      if life_pct > 0.7 {
        p.size *= 1.02
      } else {
        p.size *= 0.97
      }
      p.vx *= 0.94
      p.vy *= 0.94
      p.vz *= 0.94
    } else if p.kind == 2 {
      // Shield hit: expand quickly
      p.size *= 1.05
      p.vx *= 0.9
      p.vy *= 0.9
      p.vz *= 0.9
    } else {
      // Trail: static, just fade
      p.size *= 0.95
    }
  }
}

///|
/// Checks if a hit on a capital ship struck a weak point. Returns actual damage to apply.
fn check_weak_point_hit(
  game : @types.Game,
  enemy_idx : Int,
  hit_x : Float,
  hit_y : Float,
  hit_z : Float,
  base_damage : Float,
) -> Float {
  let e = game.enemies[enemy_idx]
  if e.kind != @types.enemy_capital || e.weak_point_hp <= 0.0 {
    return base_damage
  }
  // Check each weak point
  for wp_i in 0..<@types.capital_weak_point_count {
    let off = @types.capital_weak_point_offset(wp_i)
    let wp_x = e.x + off.0
    let wp_y = e.y + off.1
    let wp_z = e.z + off.2
    let wp_dist = @types.distance3d(hit_x, hit_y, hit_z, wp_x, wp_y, wp_z)
    if wp_dist < @types.weak_point_hit_radius {
      // Weak point hit
      let wp_damage = base_damage * @types.weak_point_damage_mult
      e.weak_point_hp -= wp_damage
      // Spark effect at weak point
      @types.spawn_particles(game, wp_x, wp_y, wp_z, 8, 255, 255, 50)
      @types.spawn_damage_number(game, wp_x, wp_y + 1.0, wp_z, wp_damage.to_int(), 255, 100, 50)
      if e.weak_point_hp <= 0.0 {
        // Weak point destroyed - massive damage
        e.weak_point_hp = 0.0
        @types.spawn_explosion(game, wp_x, wp_y, wp_z, 20, 255, 200, 50)
        game.camera_shake = @types.maxf(game.camera_shake, 0.6)
        @types.add_kill_feed(game, "WEAK POINT DESTROYED", 255, 200, 50)
        return base_damage + @types.weak_point_destroy_damage
      }
      return wp_damage
    }
  }
  base_damage
}
