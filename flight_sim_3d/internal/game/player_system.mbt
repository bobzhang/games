// Player aircraft controls and physics

///|
/// Updates player aircraft controls, physics, fuel consumption, and weapon firing.
pub fn update_player(game : @types.Game, dt : Float) -> Unit {
  let player = game.player
  if !player.alive {
    return
  }
  let stats = @types.get_aircraft_stats(player.aircraft_type)
  // Throttle
  if @raylib.is_key_down(@raylib.KeyLeftShift) {
    player.throttle += 0.8 * dt
    if player.throttle > 1.0 {
      player.throttle = 1.0
    }
  }
  if @raylib.is_key_down(@raylib.KeyLeftControl) {
    player.throttle -= 0.8 * dt
    if player.throttle < 0.0 {
      player.throttle = 0.0
    }
  }
  // Pitch (W/S) - use per-aircraft pitch_rate
  if @raylib.is_key_down(@raylib.KeyW) {
    player.pitch -= stats.pitch_rate * dt
  }
  if @raylib.is_key_down(@raylib.KeyS) {
    player.pitch += stats.pitch_rate * dt
  }
  // Clamp pitch
  let max_pitch : Float = @types.pi * 0.45
  player.pitch = @types.clampf(player.pitch, -max_pitch, max_pitch)
  // Yaw (A/D) - use per-aircraft yaw_rate
  if @raylib.is_key_down(@raylib.KeyA) {
    player.yaw -= stats.yaw_rate * dt
  }
  if @raylib.is_key_down(@raylib.KeyD) {
    player.yaw += stats.yaw_rate * dt
  }
  // Roll (Q/E) - use per-aircraft roll_rate
  if @raylib.is_key_down(@raylib.KeyQ) {
    player.roll -= stats.roll_rate * dt
  }
  if @raylib.is_key_down(@raylib.KeyE) {
    player.roll += stats.roll_rate * dt
  }
  // Clamp roll
  let max_roll : Float = @types.pi * 0.8
  player.roll = @types.clampf(player.roll, -max_roll, max_roll)
  // Roll auto-center when no input
  if !@raylib.is_key_down(@raylib.KeyQ) && !@raylib.is_key_down(@raylib.KeyE) {
    if player.roll > 0.01 {
      player.roll -= 0.8 * dt
      if player.roll < 0.0 {
        player.roll = 0.0
      }
    } else if player.roll < -0.01 {
      player.roll += 0.8 * dt
      if player.roll > 0.0 {
        player.roll = 0.0
      }
    }
  }
  // Roll affects yaw (banking turn) - scaled by turn_rate
  player.yaw += @math.sinf(player.roll) * stats.turn_rate * 0.4 * dt
  // Speed based on throttle - use per-aircraft max_speed, min_speed, acceleration
  let target_speed = stats.min_speed +
    (stats.max_speed - stats.min_speed) * player.throttle
  let speed_diff = target_speed - player.speed
  player.speed += speed_diff * stats.acceleration * 10.0 * dt
  // Fuel consumption
  player.fuel -= @types.aircraft_fuel_rate * player.throttle * dt
  if player.fuel < 0.0 {
    player.fuel = 0.0
    player.throttle = 0.0
  }
  // Calculate forward direction
  let (fx, fy, fz) = @types.get_forward(player.pitch, player.yaw)
  // Apply movement
  player.x += fx * player.speed * dt
  player.y += fy * player.speed * dt
  player.z += fz * player.speed * dt
  // Gravity effect when slow or no fuel - stall based on per-aircraft stall_speed
  let lift = player.speed * @types.aircraft_lift_factor
  if lift < @types.aircraft_gravity {
    player.y -= (@types.aircraft_gravity - lift) * dt
  }
  // Stall detection using per-aircraft stall_speed
  if player.speed < stats.stall_speed && player.fuel > 0.0 {
    player.stalling = true
    player.stall_timer += dt
    // Force nose down during stall
    player.pitch += 0.5 * dt
  } else {
    player.stalling = false
    player.stall_timer = 0.0
  }
  // Terrain collision
  let ground = @types.terrain_height_at(player.x, player.z) +
    @types.aircraft_min_altitude
  if player.y < ground {
    // Crash if going too fast or too steep
    if player.speed > 25.0 || player.pitch.abs() > 0.3 {
      game.crash_player()
      return
    }
    player.y = ground
    player.pitch = 0.0
    if player.speed > 5.0 {
      player.speed -= 10.0 * dt
    }
  }
  // Damage flash timer
  if player.damage_flash > 0.0 {
    player.damage_flash -= dt
  }
  // Fire timer
  if player.fire_timer > 0.0 {
    player.fire_timer -= dt
  }
  // Weapon switch (Tab key)
  if player.weapon_switch_timer > 0.0 {
    player.weapon_switch_timer -= dt
  }
  if @raylib.is_key_pressed(@raylib.KeyTab) && player.weapon_switch_timer <= 0.0 {
    player.current_weapon = match player.current_weapon {
      MachineGun => Rockets
      Rockets => Bombs
      Bombs => MachineGun
    }
    player.weapon_switch_timer = 0.3
    @types.show_message(
      game,
      "Weapon: " + @types.weapon_name(player.current_weapon),
      1.0,
    )
  }
  // Fire weapon
  if @raylib.is_key_down(@raylib.KeySpace) && player.fire_timer <= 0.0 {
    game.fire_player_weapon()
  }
  // Landing check
  game.check_landing(dt)
  // Engine particles (exhaust trail)
  if game.frame_counter % 3 == 0 {
    let idx = @types.alloc_particle(game)
    if idx >= 0 {
      let p = game.particles[idx]
      p.active = true
      p.x = player.x - fx * 2.0
      p.y = player.y - fy * 2.0
      p.z = player.z - fz * 2.0
      p.vx = -fx * 3.0 + @types.rand_rangef(game, -0.5, 0.5)
      p.vy = -fy * 3.0 + @types.rand_rangef(game, -0.5, 0.5)
      p.vz = -fz * 3.0 + @types.rand_rangef(game, -0.5, 0.5)
      p.life = 0.5
      p.max_life = 0.5
      p.r = 200
      p.g = 200
      p.b = 200
      p.size = 0.15
    }
  }
}

///|
fn @types.Game::fire_player_weapon(game : @types.Game) -> Unit {
  let player = game.player
  let (fx, fy, fz) = @types.get_forward(player.pitch, player.yaw)
  match player.current_weapon {
    MachineGun => {
      if player.ammo_mg <= 0 {
        @types.show_message(game, "MG ammo depleted!", 1.0)
        return
      }
      let idx = @types.alloc_projectile(game)
      if idx < 0 {
        return
      }
      player.ammo_mg -= 1
      player.shots_fired += 1
      player.fire_timer = 0.1
      let proj = game.projectiles[idx]
      proj.active = true
      proj.kind = @types.proj_bullet
      proj.x = player.x + fx * 2.5
      proj.y = player.y + fy * 2.5
      proj.z = player.z + fz * 2.5
      proj.dx = fx
      proj.dy = fy
      proj.dz = fz
      proj.speed = 140.0
      proj.damage = 15.0
      proj.life = 1.8
      proj.is_enemy = false
      proj.gravity_affected = false
      proj.blast_radius = 0.0
    }
    Rockets => {
      if player.ammo_rockets <= 0 {
        @types.show_message(game, "No rockets remaining!", 1.0)
        return
      }
      let idx = @types.alloc_projectile(game)
      if idx < 0 {
        return
      }
      player.ammo_rockets -= 1
      player.shots_fired += 1
      player.fire_timer = 0.6
      let proj = game.projectiles[idx]
      proj.active = true
      proj.kind = @types.proj_rocket
      proj.x = player.x + fx * 2.5
      proj.y = player.y + fy * 2.5
      proj.z = player.z + fz * 2.5
      proj.dx = fx
      proj.dy = fy
      proj.dz = fz
      proj.speed = 90.0
      proj.damage = 60.0
      proj.life = 3.0
      proj.is_enemy = false
      proj.gravity_affected = false
      proj.blast_radius = 6.0
    }
    Bombs => {
      if player.ammo_bombs <= 0 {
        @types.show_message(game, "No bombs remaining!", 1.0)
        return
      }
      let idx = @types.alloc_projectile(game)
      if idx < 0 {
        return
      }
      player.ammo_bombs -= 1
      player.shots_fired += 1
      player.fire_timer = 1.0
      let proj = game.projectiles[idx]
      proj.active = true
      proj.kind = @types.proj_bomb
      proj.x = player.x
      proj.y = player.y - 1.0
      proj.z = player.z
      // Bombs inherit aircraft forward velocity but mostly drop
      proj.dx = fx * 0.3
      proj.dy = -0.2
      proj.dz = fz * 0.3
      proj.speed = player.speed * 0.5
      proj.damage = 120.0
      proj.life = 8.0
      proj.is_enemy = false
      proj.gravity_affected = true
      proj.blast_radius = 10.0
    }
  }
}

///|
fn @types.Game::crash_player(game : @types.Game) -> Unit {
  let player = game.player
  player.alive = false
  @types.spawn_explosion(game, player.x, player.y, player.z)
  @types.show_message(game, "CRASHED!", 3.0)
  game.state = GameOver
}

///|
/// Applies `amount` damage to the player from attacker at (`ax`, `az`), triggering damage flash, vignette, and direction indicator.
pub fn damage_player(
  game : @types.Game,
  amount : Float,
  attacker_x? : Float = 0.0,
  attacker_z? : Float = 0.0,
) -> Unit {
  let player = game.player
  if !player.alive {
    return
  }
  if player.damage_flash > 0.0 {
    return
  }
  player.hp -= amount
  player.damage_flash = 0.3
  // Trigger damage vignette and direction indicator
  @types.trigger_damage_feedback(game, attacker_x, attacker_z)
  // Camera jolt
  @types.trigger_screen_shake(game, @types.shake_light)
  if player.hp <= 0.0 {
    player.hp = 0.0
    player.alive = false
    @types.spawn_explosion(game, player.x, player.y, player.z)
    @types.show_message(game, "SHOT DOWN!", 3.0)
    game.state = GameOver
  }
}

///|
fn @types.Game::check_landing(game : @types.Game, dt : Float) -> Unit {
  let mission = game.missions[game.current_mission]
  if !mission.has_landing {
    return
  }
  let player = game.player
  let land_x = mission.landing_x
  let land_z = mission.landing_z
  let dist_h = @types.distance2d(player.x, player.z, land_x, land_z)
  let ground = @types.terrain_height_at(land_x, land_z) +
    @types.aircraft_min_altitude
  let altitude_above_ground = player.y - ground
  // Check if near landing zone
  if dist_h < 15.0 && altitude_above_ground < 3.0 {
    if !game.landing_approach {
      game.landing_approach = true
      @types.show_message(game, "Landing approach - slow down!", 2.0)
    }
    // Check successful landing conditions
    if altitude_above_ground < 1.0 &&
      player.speed < 25.0 &&
      player.pitch.abs() < 0.2 &&
      player.roll.abs() < 0.3 {
      game.landing_timer += dt
      if game.landing_timer > 1.5 {
        mission.targets_done = mission.target_count
        @types.show_message(game, "Landing successful!", 3.0)
      }
    } else {
      game.landing_timer = 0.0
    }
  } else {
    game.landing_approach = false
    game.landing_timer = 0.0
  }
}
