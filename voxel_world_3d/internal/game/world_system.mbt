// World systems: day/night cycle, entity spawning, entity AI

///|
/// Advances time-of-day state, updates day/night flags, and computes sky colors
/// used by world and UI rendering.
pub fn update_day_night(game : @types.Game, dt : Float) -> Unit {
  game.day_timer += dt
  if game.day_timer > @types.day_length {
    game.day_timer -= @types.day_length
    game.day_count += 1
  }
  // Time of day as 0..1
  let t = game.day_timer / @types.day_length
  // Sun angle for rendering
  game.sun_angle = t * @types.two_pi
  // Determine if night
  game.is_night = t > 0.6 || t < 0.1
  // Sky color cycle: dawn -> day -> dusk -> night -> dawn
  if t < @types.dawn_end {
    // Dawn: dark blue -> orange
    let p = t / @types.dawn_end
    game.sky_r = @types.lerpi(20, 255, p)
    game.sky_g = @types.lerpi(20, 160, p)
    game.sky_b = @types.lerpi(60, 80, p)
  } else if t < @types.morning_end {
    // Morning: orange -> bright blue
    let p = (t - @types.dawn_end) / (@types.morning_end - @types.dawn_end)
    game.sky_r = @types.lerpi(255, 135, p)
    game.sky_g = @types.lerpi(160, 206, p)
    game.sky_b = @types.lerpi(80, 235, p)
  } else if t < @types.day_end {
    // Daytime: bright blue
    game.sky_r = 135
    game.sky_g = 206
    game.sky_b = 235
  } else if t < @types.dusk_end {
    // Dusk: blue -> orange -> dark
    let p = (t - @types.day_end) / (@types.dusk_end - @types.day_end)
    game.sky_r = @types.lerpi(135, 220, p)
    game.sky_g = @types.lerpi(206, 100, p)
    game.sky_b = @types.lerpi(235, 50, p)
  } else if t < @types.late_dusk_end {
    // Late dusk: orange -> dark blue
    let p = (t - @types.dusk_end) / (@types.late_dusk_end - @types.dusk_end)
    game.sky_r = @types.lerpi(220, 20, p)
    game.sky_g = @types.lerpi(100, 20, p)
    game.sky_b = @types.lerpi(50, 60, p)
  } else {
    // Night: dark blue
    game.sky_r = 20
    game.sky_g = 20
    game.sky_b = 60
  }
}

///|
/// Advances transient message timer used for on-screen notifications.
pub fn update_message(game : @types.Game, dt : Float) -> Unit {
  if game.message_timer > 0.0 {
    game.message_timer -= dt
    if game.message_timer < 0.0 {
      game.message_timer = 0.0
    }
  }
}

// ========== Entity Spawning ==========

///|
/// Periodically attempts biome-aware mob spawning near the player while honoring
/// active-entity limits and valid terrain placement.
pub fn update_entity_spawning(game : @types.Game, dt : Float) -> Unit {
  game.entity_spawn_timer -= dt
  if game.entity_spawn_timer > 0.0 {
    return
  }
  game.entity_spawn_timer = 3.0 + @types.rand_float(game) * 5.0
  // Count active entities
  let mut active_count = 0
  for i in 0..<@types.entity_max {
    if game.entities[i].active {
      active_count += 1
    }
  }
  // Limit total entities
  if active_count >= @types.entity_max - 4 {
    return
  }
  // Find spawn position near player
  let angle = @types.rand_float(game) * @types.two_pi
  let dist = @types.entity_spawn_radius * 0.5 +
    @types.rand_float(game) * @types.entity_spawn_radius * 0.5
  let spawn_x = game.player.x + @math.cosf(angle) * dist
  let spawn_z = game.player.z + @math.sinf(angle) * dist
  // Check world bounds
  let world_max_x = Float::from_int(@types.world_chunks_x * @types.chunk_x) -
    1.0
  let world_max_z = Float::from_int(@types.world_chunks_z * @types.chunk_z) -
    1.0
  if spawn_x < 1.0 ||
    spawn_x > world_max_x ||
    spawn_z < 1.0 ||
    spawn_z > world_max_z {
    return
  }
  // Find surface height at spawn position
  let sx = spawn_x.to_int()
  let sz = spawn_z.to_int()
  // Light-based spawn suppression: check for nearby torches
  if game.is_night {
    let tr = @types.torch_spawn_suppress_radius
    let neg_tr = -tr
    let mut torch_nearby = false
    for dy in neg_tr..<=tr {
      if torch_nearby {
        break
      }
      for dz in neg_tr..<=tr {
        if torch_nearby {
          break
        }
        for dx in neg_tr..<=tr {
          if torch_nearby {
            break
          }
          let check_y = 20 + dy // approximate surface height
          let blk = @types.get_world_block(game, sx + dx, check_y, sz + dz)
          if blk == @types.block_torch {
            torch_nearby = true
          }
        }
      }
    }
    if torch_nearby {
      return
    }
  }
  let mut surface_y = 0
  for y = @types.chunk_y - 1; y >= 0; y = y - 1 {
    let block = @types.get_world_block(game, sx, y, sz)
    if @types.is_solid(block) {
      surface_y = y + 1
      // break substitute: y = -1
      // Instead, just record and continue; first hit is fine since we go top-down
      return game.spawn_entity_at(
        spawn_x,
        Float::from_int(surface_y) + 0.1,
        spawn_z,
      )
    }
  }
  // No surface found
  ignore(surface_y)
}

///|
fn @types.Game::spawn_entity_at(
  game : @types.Game,
  x : Float,
  y : Float,
  z : Float,
) -> Unit {
  // Determine biome at spawn location
  let biome = @types.get_biome_at(x.to_int(), z.to_int())
  let rng_val = @types.rand_next(game)
  let kind = @levels.get_spawn_type_for_biome(biome, game.is_night, rng_val)
  if kind == 0 {
    return
  }
  // Find free entity slot
  for i in 0..<@types.entity_max {
    if !game.entities[i].active {
      let ent = game.entities[i]
      ent.active = true
      ent.kind = kind
      ent.x = x
      ent.y = y
      ent.z = z
      ent.vx = 0.0
      ent.vy = 0.0
      ent.vz = 0.0
      ent.max_health = @types.get_entity_max_health(kind)
      ent.health = ent.max_health
      ent.ai_state = Idle
      ent.ai_timer = 2.0 + @types.rand_float(game) * 3.0
      ent.target_x = x
      ent.target_z = z
      ent.yaw = @types.rand_float(game) * @types.two_pi
      ent.on_ground = false
      ent.damage_flash = 0.0
      ent.anim_timer = 0.0
      ent.attack_cooldown = 0.0
      return
    }
  }
}

// ========== Entity AI and physics ==========

///|
/// Updates active entities (AI, physics, cooldowns, and despawn checks) each frame.
pub fn update_entities(game : @types.Game, dt : Float) -> Unit {
  let player = game.player
  for i in 0..<@types.entity_max {
    let ent = game.entities[i]
    if !ent.active {
      continue
    }
    // Animation timer
    ent.anim_timer += dt
    // Damage flash decay
    if ent.damage_flash > 0.0 {
      ent.damage_flash -= dt * 3.0
      if ent.damage_flash < 0.0 {
        ent.damage_flash = 0.0
      }
    }
    // Attack cooldown
    if ent.attack_cooldown > 0.0 {
      ent.attack_cooldown -= dt
      if ent.attack_cooldown < 0.0 {
        ent.attack_cooldown = 0.0
      }
    }
    // Despawn if too far from player
    let dist_to_player = @types.distance_xz(ent.x, ent.z, player.x, player.z)
    if dist_to_player > @types.entity_despawn_radius {
      ent.active = false
      continue
    }
    // AI state machine
    game.update_entity_ai(ent, dt, dist_to_player)
    // Apply physics
    game.update_entity_physics(ent, dt)
  }
}

///|
fn @types.Game::update_entity_ai(
  game : @types.Game,
  ent : @types.Entity,
  dt : Float,
  dist_to_player : Float,
) -> Unit {
  let player = game.player
  ent.ai_timer -= dt
  let is_hostile_mob = @types.is_hostile(ent.kind)

  if is_hostile_mob {
    // Hostile AI
    if dist_to_player < 20.0 {
      // Chase player
      ent.ai_state = Chase
      ent.target_x = player.x
      ent.target_z = player.z
      if dist_to_player < @types.entity_attack_range {
        ent.ai_state = Attack
      }
      // Skeleton ranged attack: fire arrows from range instead of melee only
      if ent.kind == @types.entity_skeleton &&
        dist_to_player < @types.skeleton_shoot_range &&
        dist_to_player > @types.entity_attack_range &&
        ent.attack_cooldown <= 0.0 {
        // Fire an arrow projectile toward the player
        game.spawn_arrow_projectile(ent, player)
        ent.attack_cooldown = @types.skeleton_shoot_interval
      }
      // Spider lunge: brief speed burst when within lunge range
      if ent.kind == @types.entity_spider &&
        dist_to_player < @types.spider_lunge_range &&
        dist_to_player > @types.entity_attack_range &&
        ent.on_ground {
        let dx = player.x - ent.x
        let dz = player.z - ent.z
        let dl = @math.hypotf(dx, dz)
        if dl > 0.1 {
          ent.vx = dx / dl * @types.spider_lunge_speed
          ent.vz = dz / dl * @types.spider_lunge_speed
          ent.vy = 4.0 // jump toward player
          ent.on_ground = false
        }
      }
      // Wander
    } else if ent.ai_timer <= 0.0 {
      ent.ai_state = Wander
      ent.ai_timer = 3.0 + @types.rand_float(game) * 4.0
      ent.target_x = ent.x + (@types.rand_float(game) - 0.5) * 16.0
      ent.target_z = ent.z + (@types.rand_float(game) - 0.5) * 16.0
    }
    // Passive AI
  } else if ent.ai_state == Flee {
    // Continue fleeing
    if ent.ai_timer <= 0.0 {
      ent.ai_state = Idle
      ent.ai_timer = 2.0 + @types.rand_float(game) * 3.0
    }
  } else if ent.ai_state == Idle {
    if ent.ai_timer <= 0.0 {
      ent.ai_state = Wander
      ent.ai_timer = 3.0 + @types.rand_float(game) * 5.0
      ent.target_x = ent.x + (@types.rand_float(game) - 0.5) * 10.0
      ent.target_z = ent.z + (@types.rand_float(game) - 0.5) * 10.0
    }
  } else if ent.ai_state == Wander {
    let dx = ent.target_x - ent.x
    let dz = ent.target_z - ent.z
    let dist_to_target = @math.hypotf(dx, dz)
    if dist_to_target < 1.0 || ent.ai_timer <= 0.0 {
      ent.ai_state = Idle
      ent.ai_timer = 1.0 + @types.rand_float(game) * 4.0
    }
  }

  // Move toward target
  if ent.ai_state == Wander ||
    ent.ai_state == Chase ||
    ent.ai_state == Flee ||
    ent.ai_state == Attack {
    let dx = ent.target_x - ent.x
    let dz = ent.target_z - ent.z
    let dist = @math.hypotf(dx, dz)
    if dist > 0.5 {
      let speed : Float = if is_hostile_mob &&
        (ent.ai_state == Chase || ent.ai_state == Attack) {
        // Spiders are faster than other hostiles
        if ent.kind == @types.entity_spider {
          @types.entity_speed_spider
        } else {
          @types.entity_speed_hostile
        }
      } else if ent.ai_state == Flee {
        @types.entity_speed_hostile
      } else {
        @types.entity_speed_passive
      }
      ent.vx = dx / dist * speed
      ent.vz = dz / dist * speed
      // Update yaw to face movement direction
      ent.yaw = @math.atan2f(dx, dz)
    } else {
      ent.vx = 0.0
      ent.vz = 0.0
    }
  } else {
    ent.vx = 0.0
    ent.vz = 0.0
  }

  // Jump over obstacles
  if (ent.ai_state == Wander || ent.ai_state == Chase || ent.ai_state == Flee) &&
    ent.on_ground {
    // Check if blocked ahead
    let ahead_x = ent.x + @math.sinf(ent.yaw) * 0.8
    let ahead_z = ent.z + @math.cosf(ent.yaw) * 0.8
    let ahead_block = @types.get_world_block(
      game,
      ahead_x.to_int(),
      ent.y.to_int(),
      ahead_z.to_int(),
    )
    if @types.is_solid(ahead_block) {
      // Spiders can climb 2-block walls with higher jump
      if ent.kind == @types.entity_spider {
        let above_block = @types.get_world_block(
          game,
          ahead_x.to_int(),
          ent.y.to_int() + 1,
          ahead_z.to_int(),
        )
        if @types.is_solid(above_block) {
          ent.vy = 9.0 // higher jump for 2-block walls
        } else {
          ent.vy = 6.0
        }
      } else {
        ent.vy = 6.0
      }
      ent.on_ground = false
    }
  }
  ignore(game)
}

///|
fn @types.Game::update_entity_physics(
  game : @types.Game,
  ent : @types.Entity,
  dt : Float,
) -> Unit {
  // Gravity
  ent.vy -= @types.gravity * dt
  if ent.vy < -@types.terminal_velocity {
    ent.vy = -@types.terminal_velocity
  }
  // Move X
  let new_x = ent.x + ent.vx * dt
  let bx = new_x.to_int()
  let by = ent.y.to_int()
  let bz = ent.z.to_int()
  let block_at_new_x = @types.get_world_block(game, bx, by, bz)
  if !@types.is_solid(block_at_new_x) {
    ent.x = new_x
  } else {
    ent.vx = 0.0
  }
  // Move Z
  let new_z = ent.z + ent.vz * dt
  let bz2 = new_z.to_int()
  let block_at_new_z = @types.get_world_block(game, ent.x.to_int(), by, bz2)
  if !@types.is_solid(block_at_new_z) {
    ent.z = new_z
  } else {
    ent.vz = 0.0
  }
  // Move Y
  let new_y = ent.y + ent.vy * dt
  let by2 = new_y.to_int()
  let block_at_new_y = @types.get_world_block(
    game,
    ent.x.to_int(),
    by2,
    ent.z.to_int(),
  )
  if !@types.is_solid(block_at_new_y) {
    ent.y = new_y
    ent.on_ground = false
  } else {
    if ent.vy < 0.0 {
      ent.on_ground = true
      let foot_y = (ent.y - 0.01).floor().to_int()
      ent.y = Float::from_int(foot_y + 1) + 0.001
    }
    ent.vy = 0.0
  }
  // World bounds
  let world_max_x = Float::from_int(@types.world_chunks_x * @types.chunk_x) -
    0.5
  let world_max_z = Float::from_int(@types.world_chunks_z * @types.chunk_z) -
    0.5
  ent.x = @types.clampf(ent.x, 0.5, world_max_x)
  ent.z = @types.clampf(ent.z, 0.5, world_max_z)
  if ent.y < 1.0 {
    ent.y = 1.0
    ent.vy = 0.0
    ent.on_ground = true
  }
}

// ========== Projectile system (skeleton arrows) ==========

///|
/// Spawns an arrow projectile from a skeleton toward the player.
fn @types.Game::spawn_arrow_projectile(
  game : @types.Game,
  ent : @types.Entity,
  player : @types.Player,
) -> Unit {
  // Find a free projectile slot
  for i in 0..<@types.projectile_max {
    let proj = game.projectiles[i]
    if !proj.active {
      let dx = player.x - ent.x
      let dy = (player.y + 0.8) - (ent.y + 1.0)
      let dz = player.z - ent.z
      let dist = (dx * dx + dy * dy + dz * dz).sqrt()
      if dist < 0.1 {
        return
      }
      proj.active = true
      proj.x = ent.x
      proj.y = ent.y + 1.0
      proj.z = ent.z
      proj.vx = dx / dist * @types.arrow_speed
      proj.vy = dy / dist * @types.arrow_speed + 1.5 // slight arc
      proj.vz = dz / dist * @types.arrow_speed
      proj.lifetime = 3.0
      proj.damage = @types.arrow_damage
      proj.owner_kind = @types.entity_skeleton
      return
    }
  }
}

///|
/// Updates all active projectiles: movement, wall collision, and player hit detection.
pub fn update_projectiles(game : @types.Game, dt : Float) -> Unit {
  let player = game.player
  for i in 0..<@types.projectile_max {
    let proj = game.projectiles[i]
    if !proj.active {
      continue
    }
    // Update lifetime
    proj.lifetime -= dt
    if proj.lifetime <= 0.0 {
      proj.active = false
      continue
    }
    // Apply gravity to arrow
    proj.vy -= @types.gravity * 0.5 * dt
    // Move projectile
    proj.x += proj.vx * dt
    proj.y += proj.vy * dt
    proj.z += proj.vz * dt
    // Check wall collision
    let bx = proj.x.to_int()
    let by = proj.y.to_int()
    let bz = proj.z.to_int()
    let block = @types.get_world_block(game, bx, by, bz)
    if @types.is_solid(block) {
      proj.active = false
      continue
    }
    // Check player hit
    let dx = proj.x - player.x
    let dy = proj.y - (player.y + 0.8)
    let dz = proj.z - player.z
    let dist_sq = dx * dx + dy * dy + dz * dz
    if dist_sq < 0.8 {
      // Hit player
      damage_player(game, proj.damage)
      @types.show_message(game, "Hit by arrow!", 1.5)
      // Knockback from arrow direction
      let speed = (proj.vx * proj.vx + proj.vz * proj.vz).sqrt()
      if speed > 0.1 {
        player.vx += proj.vx / speed * 3.0
        player.vz += proj.vz / speed * 3.0
        player.vy += 2.0
      }
      proj.active = false
    }
  }
}
