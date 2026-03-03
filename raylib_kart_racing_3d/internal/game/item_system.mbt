// Item system: dropped items, projectile homing, item box respawns, powerup effects

// Update dropped items (bananas, oil slicks) on the track

///|
/// Updates lifetime, animation, and gravity settling for all dropped track hazards.
pub fn update_dropped_items(game : @types.Game, dt : Float) -> Unit {
  for item in game.dropped_items {
    if not(item.active) {
      continue
    }
    // Decrease lifetime
    item.lifetime -= dt
    if item.lifetime <= 0.0 {
      item.active = false
      // Fade-out particles
      @types.spawn_typed_particles(
        game,
        @types.particle_dust,
        item.x,
        item.y + 0.2,
        item.z,
        3,
        180,
        180,
        120,
        0.04,
        0.3,
      )
      continue
    }
    // Banana rotation animation
    if item.item_type == @types.powerup_banana {
      item.rotation += dt * 2.0
      if item.rotation > @types.two_pi {
        item.rotation -= @types.two_pi
      }
    }
    // Oil slick subtle pulsing handled in render
    // Gravity settling: if item is above ground, settle it down
    let ground_y = get_ground_height(game, item.x, item.z)
    if item.y > ground_y + 0.15 {
      item.y -= dt * 3.0
      if item.y < ground_y + 0.1 {
        item.y = ground_y + 0.1
      }
    }
  }
}

// Check collisions between karts and dropped items

///|
/// Checks collisions between all karts and dropped hazard items on the track.
pub fn check_dropped_item_collisions(game : @types.Game) -> Unit {
  for ki in 0..<@types.max_karts {
    let kart = game.karts[ki]
    if not(kart.active) || kart.finished {
      continue
    }
    // Skip if already spinning or stunned
    if kart.spin_timer > 0.0 || kart.stunned_timer > 0.0 {
      continue
    }
    for item in game.dropped_items {
      if not(item.active) {
        continue
      }
      // Don't hit your own item for a brief grace period (first 0.5s)
      let grace_time : Float = item.lifetime
      let max_life : Float = if item.item_type == @types.powerup_banana {
        @types.banana_lifetime
      } else {
        @types.oil_slick_lifetime
      }
      let elapsed = max_life - grace_time
      if item.owner == ki && elapsed < 0.5 {
        continue
      }
      let dist = @types.distance2d(kart.x, kart.z, item.x, item.z)
      let hit_radius : Float = 1.3
      if dist < hit_radius {
        // Check for shield protection
        if kart.shield_timer > 0.0 {
          kart.shield_timer = 0.0
          @types.spawn_particles(
            game,
            kart.x,
            kart.y + 0.5,
            kart.z,
            10,
            100,
            200,
            255,
          )
          item.active = false
          continue
        }
        // Check for star invincibility
        if kart.star_timer > 0.0 || kart.invincible_timer > 0.0 {
          item.active = false
          @types.spawn_particles(
            game,
            item.x,
            item.y + 0.3,
            item.z,
            6,
            255,
            255,
            100,
          )
          continue
        }
        // Apply item effect
        if item.item_type == @types.powerup_banana {
          apply_banana_hit(game, ki)
        } else if item.item_type == @types.powerup_oil_slick {
          apply_oil_slick_hit(game, ki)
        }
        item.active = false
      }
    }
  }
}

// Apply banana peel hit effect - causes spin

///|
fn apply_banana_hit(game : @types.Game, kart_idx : Int) -> Unit {
  let kart = game.karts[kart_idx]
  kart.spin_timer = @types.spin_duration
  kart.speed = kart.speed * 0.4
  // Spawn banana peel explosion particles
  @types.spawn_particles(game, kart.x, kart.y + 0.3, kart.z, 12, 255, 230, 50)
  @types.spawn_typed_particles(
    game,
    @types.particle_explosion,
    kart.x,
    kart.y + 0.5,
    kart.z,
    6,
    255,
    200,
    0,
    0.08,
    0.5,
  )
}

// Apply oil slick hit effect - causes sliding and speed loss

///|
fn apply_oil_slick_hit(game : @types.Game, kart_idx : Int) -> Unit {
  let kart = game.karts[kart_idx]
  kart.stunned_timer = 1.2
  kart.speed = kart.speed * 0.5
  // Add a sideways drift effect
  let slide_angle = @types.rand_rangef(game, -0.5, 0.5)
  kart.angle = kart.angle + slide_angle
  // Spawn oil splash particles
  @types.spawn_typed_particles(
    game,
    @types.particle_splash,
    kart.x,
    kart.y + 0.1,
    kart.z,
    8,
    40,
    40,
    50,
    0.06,
    0.4,
  )
  @types.spawn_particles(game, kart.x, kart.y + 0.2, kart.z, 6, 80, 80, 90)
}

// Update projectile homing behavior

///|
/// Updates homing guidance and trail particles for all active missile projectiles.
pub fn update_projectile_homing(game : @types.Game, dt : Float) -> Unit {
  for proj in game.projectiles {
    if not(proj.active) {
      continue
    }
    // Only home if we have a valid target
    if proj.target_kart < 0 || proj.target_kart >= @types.max_karts {
      continue
    }
    let target = game.karts[proj.target_kart]
    if not(target.active) || target.finished {
      // Lost target, find a new one
      proj.target_kart = @types.find_target_ahead(game, proj.owner)
      continue
    }
    // Calculate angle to target
    let dx = target.x - proj.x
    let dz = target.z - proj.z
    let target_angle = @math.atan2f(dx, dz)
    let angle_delta = @types.angle_diff(proj.angle, target_angle)
    // Gradually turn towards target
    let max_turn = proj.homing_strength * dt
    let turn = @types.clampf(angle_delta, -max_turn, max_turn)
    proj.angle = proj.angle + turn
    proj.angle = @types.normalize_angle(proj.angle)
    // Spawn trail particles for homing missiles
    if game.frame_counter % 3 == 0 {
      let trail_x = proj.x - @math.sinf(proj.angle) * 0.3
      let trail_z = proj.z - @math.cosf(proj.angle) * 0.3
      @types.spawn_typed_particles(
        game,
        @types.particle_boost_flame,
        trail_x,
        proj.y,
        trail_z,
        1,
        255,
        120,
        30,
        0.04,
        0.2,
      )
    }
  }
}

// Enhanced powerup usage effects with more detailed behavior

// Apply shield activation with visual feedback

// Launch missile with enhanced targeting

// Drop banana behind kart with arc trajectory

// Drop oil slick behind kart

// Activate star power with full effect

// Activate lightning bolt affecting all opponents

// Apply triple mushroom boost (one of three uses)

// Item box respawn with enhanced variety

///|
/// Updates respawn timers and bobbing animation for collected item box pickups.
pub fn update_item_box_respawns(game : @types.Game, dt : Float) -> Unit {
  for pu in game.powerups {
    if not(pu.active) {
      continue
    }
    if pu.collected {
      pu.respawn_timer -= dt
      if pu.respawn_timer <= 0.0 {
        pu.collected = false
        // Respawn with position-aware item type
        // Items near the start/finish are more likely to be basic
        let variety = @types.rand_range(game, 1, @types.powerup_type_count - 1)
        pu.kind = variety
        // Respawn sparkle
        @types.spawn_typed_particles(
          game,
          @types.particle_star_sparkle,
          pu.x,
          pu.y,
          pu.z,
          4,
          255,
          255,
          200,
          0.05,
          0.3,
        )
      }
    }
    // Bob animation offset update
    pu.bob_offset += dt * 2.5
    if pu.bob_offset > @types.two_pi {
      pu.bob_offset -= @types.two_pi
    }
  }
}

// Projectile-kart collision check with enhanced effects

// Check if a kart has a defensive item ready

// Check if a kart has an offensive item ready

// Get item name for display purposes

// Get item color for UI display (r, g, b)

// Calculate item effectiveness based on kart position
