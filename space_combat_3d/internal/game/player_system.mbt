// Player movement and controls — 6DOF inertia-based flight model

///|
/// Rotates the player orientation basis by pitch, yaw, and roll angular velocities.
fn rotate_orientation(p : @types.Player, dt : Float) -> Unit {
  // Apply pitch rotation (around right axis)
  if p.ang_vx.abs() > 0.0001 {
    let angle = p.ang_vx * dt
    let nf = @types.rotate_around_axis(
      p.ori_fx,
      p.ori_fy,
      p.ori_fz,
      p.ori_rx,
      p.ori_ry,
      p.ori_rz,
      angle,
    )
    let nu = @types.rotate_around_axis(
      p.ori_ux,
      p.ori_uy,
      p.ori_uz,
      p.ori_rx,
      p.ori_ry,
      p.ori_rz,
      angle,
    )
    p.ori_fx = nf.0
    p.ori_fy = nf.1
    p.ori_fz = nf.2
    p.ori_ux = nu.0
    p.ori_uy = nu.1
    p.ori_uz = nu.2
  }
  // Apply yaw rotation (around up axis)
  if p.ang_vy.abs() > 0.0001 {
    let angle = p.ang_vy * dt
    let nf = @types.rotate_around_axis(
      p.ori_fx,
      p.ori_fy,
      p.ori_fz,
      p.ori_ux,
      p.ori_uy,
      p.ori_uz,
      angle,
    )
    let nr = @types.rotate_around_axis(
      p.ori_rx,
      p.ori_ry,
      p.ori_rz,
      p.ori_ux,
      p.ori_uy,
      p.ori_uz,
      angle,
    )
    p.ori_fx = nf.0
    p.ori_fy = nf.1
    p.ori_fz = nf.2
    p.ori_rx = nr.0
    p.ori_ry = nr.1
    p.ori_rz = nr.2
  }
  // Apply roll rotation (around forward axis)
  if p.ang_vz.abs() > 0.0001 {
    let angle = p.ang_vz * dt
    let nu = @types.rotate_around_axis(
      p.ori_ux,
      p.ori_uy,
      p.ori_uz,
      p.ori_fx,
      p.ori_fy,
      p.ori_fz,
      angle,
    )
    let nr = @types.rotate_around_axis(
      p.ori_rx,
      p.ori_ry,
      p.ori_rz,
      p.ori_fx,
      p.ori_fy,
      p.ori_fz,
      angle,
    )
    p.ori_ux = nu.0
    p.ori_uy = nu.1
    p.ori_uz = nu.2
    p.ori_rx = nr.0
    p.ori_ry = nr.1
    p.ori_rz = nr.2
  }
  // Re-orthonormalize to prevent drift
  let fn2 = @types.normalize3d(p.ori_fx, p.ori_fy, p.ori_fz)
  p.ori_fx = fn2.0
  p.ori_fy = fn2.1
  p.ori_fz = fn2.2
  // Right = cross(forward, up), then normalize
  let rn = @types.cross3d(
    p.ori_fx,
    p.ori_fy,
    p.ori_fz,
    p.ori_ux,
    p.ori_uy,
    p.ori_uz,
  )
  let rn2 = @types.normalize3d(rn.0, rn.1, rn.2)
  p.ori_rx = rn2.0
  p.ori_ry = rn2.1
  p.ori_rz = rn2.2
  // Up = cross(right, forward)
  let un = @types.cross3d(
    p.ori_rx,
    p.ori_ry,
    p.ori_rz,
    p.ori_fx,
    p.ori_fy,
    p.ori_fz,
  )
  let un2 = @types.normalize3d(un.0, un.1, un.2)
  p.ori_ux = un2.0
  p.ori_uy = un2.1
  p.ori_uz = un2.2
}

///|
/// Extracts yaw, pitch, roll Euler angles from the orientation basis for rendering.
fn sync_euler_from_orientation(p : @types.Player) -> Unit {
  p.yaw = @math.atan2f(p.ori_fx, p.ori_fz)
  let horiz = (p.ori_fx * p.ori_fx + p.ori_fz * p.ori_fz).sqrt()
  p.pitch = @math.atan2f(p.ori_fy, horiz)
  // Roll: angle between world-up projected onto the right-up plane
  // and the ship's up vector
  let world_up_dot_ship_right = p.ori_ry
  let world_up_dot_ship_up = p.ori_uy
  p.roll = @math.atan2f(-world_up_dot_ship_right, world_up_dot_ship_up)
}

///|
/// Updates player ship movement, controls, weapon firing, boost, and shield regeneration.
pub fn update_player(game : @types.Game, dt : Float) -> Unit {
  let p = game.player
  let sc = p.ship_class
  let turn = @types.ship_class_turn(sc)

  // --- Angular input: add torque to angular velocity ---

  // Pitch control (W/S)
  if @raylib.is_key_down(@raylib.KeyW) {
    p.ang_vx += turn * dt
  }
  if @raylib.is_key_down(@raylib.KeyS) {
    p.ang_vx -= turn * dt
  }

  // Yaw control (A/D)
  if @raylib.is_key_down(@raylib.KeyA) {
    p.ang_vy -= turn * dt
  }
  if @raylib.is_key_down(@raylib.KeyD) {
    p.ang_vy += turn * dt
  }

  // Roll control (Q/E)
  if @raylib.is_key_down(@raylib.KeyQ) {
    p.ang_vz -= @types.player_roll_speed * dt
  }
  if @raylib.is_key_down(@raylib.KeyE) {
    p.ang_vz += @types.player_roll_speed * dt
  }

  // Angular velocity damping
  let ang_drag = @types.angular_drag * dt
  let no_pitch = !@raylib.is_key_down(@raylib.KeyW) &&
    !@raylib.is_key_down(@raylib.KeyS)
  let no_yaw = !@raylib.is_key_down(@raylib.KeyA) &&
    !@raylib.is_key_down(@raylib.KeyD)
  let no_roll = !@raylib.is_key_down(@raylib.KeyQ) &&
    !@raylib.is_key_down(@raylib.KeyE)
  if no_pitch {
    p.ang_vx = p.ang_vx * @types.maxf(0.0, 1.0 - ang_drag)
  }
  if no_yaw {
    p.ang_vy = p.ang_vy * @types.maxf(0.0, 1.0 - ang_drag)
  }
  if no_roll {
    p.ang_vz = p.ang_vz * @types.maxf(0.0, 1.0 - ang_drag)
  }

  // Clamp angular velocity
  let max_ang = turn * 1.5
  p.ang_vx = @types.clampf(p.ang_vx, -max_ang, max_ang)
  p.ang_vy = @types.clampf(p.ang_vy, -max_ang, max_ang)
  let max_roll_ang = @types.player_roll_speed * 1.5
  p.ang_vz = @types.clampf(p.ang_vz, -max_roll_ang, max_roll_ang)

  // Rotate orientation basis by angular velocity
  rotate_orientation(p, dt)

  // Sync Euler angles for rendering and other systems
  sync_euler_from_orientation(p)

  // Flight assist toggle (F key)
  if @raylib.is_key_pressed(@raylib.KeyF) {
    p.flight_assist = !p.flight_assist
  }

  // --- Translational movement: thrust as acceleration ---

  // Strafe controls (arrow keys)
  let strafe_accel : Float = 30.0
  let mut strafe_ax : Float = 0.0
  let mut strafe_ay : Float = 0.0
  if @raylib.is_key_down(@raylib.KeyLeft) {
    strafe_ax = -strafe_accel
  }
  if @raylib.is_key_down(@raylib.KeyRight) {
    strafe_ax = strafe_accel
  }
  if @raylib.is_key_down(@raylib.KeyUp) {
    strafe_ay = strafe_accel
  }
  if @raylib.is_key_down(@raylib.KeyDown) {
    strafe_ay = -strafe_accel
  }
  p.strafe_x = strafe_ax
  p.strafe_y = strafe_ay

  // Boost (left shift) - uses fuel
  let can_boost = p.boost_fuel > 0.0
  p.boosting = @raylib.is_key_down(@raylib.KeyLeftShift) && can_boost
  if p.boosting {
    p.boost_fuel -= @types.boost_fuel_drain * dt
    if p.boost_fuel < 0.0 {
      p.boost_fuel = 0.0
    }
  }

  // Forward thrust acceleration
  let base_accel = @types.thrust_acceleration
  let speed_boost_mult : Float = if p.speed_boost_timer > 0.0 {
    1.3
  } else {
    1.0
  }
  let boost_mult : Float = if p.boosting {
    @types.boost_acceleration_mult
  } else {
    1.0
  }
  let throttle_accel = base_accel * boost_mult * speed_boost_mult

  // Brake (left ctrl) — applies reverse thrust
  let braking = @raylib.is_key_down(@raylib.KeyLeftControl)

  // Apply thrust along ship's forward axis
  if !braking {
    p.vx += p.ori_fx * throttle_accel * dt
    p.vy += p.ori_fy * throttle_accel * dt
    p.vz += p.ori_fz * throttle_accel * dt
  } else {
    // Braking: decelerate toward zero
    let brake_force : Float = base_accel * 1.5
    let spd = @types.length3d(p.vx, p.vy, p.vz)
    if spd > 0.5 {
      let inv_spd : Float = 1.0F / spd
      p.vx -= p.vx * inv_spd * brake_force * dt
      p.vy -= p.vy * inv_spd * brake_force * dt
      p.vz -= p.vz * inv_spd * brake_force * dt
    } else {
      p.vx = p.vx * 0.9
      p.vy = p.vy * 0.9
      p.vz = p.vz * 0.9
    }
  }

  // Apply strafe acceleration along ship's right and up axes
  if strafe_ax.abs() > 0.1 {
    p.vx += p.ori_rx * strafe_ax * dt
    p.vy += p.ori_ry * strafe_ax * dt
    p.vz += p.ori_rz * strafe_ax * dt
  }
  if strafe_ay.abs() > 0.1 {
    p.vx += p.ori_ux * strafe_ay * dt
    p.vy += p.ori_uy * strafe_ay * dt
    p.vz += p.ori_uz * strafe_ay * dt
  }

  // Flight assist: auto-level and kill lateral drift
  if p.flight_assist {
    // Kill lateral drift (velocity component not along forward axis)
    let fwd_speed = @types.dot3d(p.vx, p.vy, p.vz, p.ori_fx, p.ori_fy, p.ori_fz)
    let lateral_vx = p.vx - p.ori_fx * fwd_speed
    let lateral_vy = p.vy - p.ori_fy * fwd_speed
    let lateral_vz = p.vz - p.ori_fz * fwd_speed
    let drift_kill = @types.flight_assist_drift_kill * dt
    p.vx -= lateral_vx * drift_kill
    p.vy -= lateral_vy * drift_kill
    p.vz -= lateral_vz * drift_kill

    // Auto-level: gently rotate ship up toward world up when no roll input
    if no_roll {
      let level_strength = @types.flight_assist_level_strength * dt
      p.ang_vz -= p.roll * level_strength
    }
  }

  // Translational drag (always applies)
  let drag_factor : Float = 1.0F - @types.flight_drag * dt
  p.vx = p.vx * drag_factor
  p.vy = p.vy * drag_factor
  p.vz = p.vz * drag_factor

  // Clamp max speed to prevent runaway
  let max_speed = @types.ship_class_boost(sc) * 1.5
  let cur_speed = @types.length3d(p.vx, p.vy, p.vz)
  if cur_speed > max_speed {
    let scale = max_speed / cur_speed
    p.vx = p.vx * scale
    p.vy = p.vy * scale
    p.vz = p.vz * scale
  }
  p.speed = cur_speed

  // Move
  p.x += p.vx * dt
  p.y += p.vy * dt
  p.z += p.vz * dt

  // Wrap around world
  p.x = @types.wrap_coord(p.x)
  p.y = @types.wrap_coord(p.y)
  p.z = @types.wrap_coord(p.z)

  // Shield regeneration
  if p.shield_timer > 0.0 {
    p.shield_timer -= dt
  } else if p.shield < p.max_shield {
    p.shield += @types.shield_regen_rate * dt
    if p.shield > p.max_shield {
      p.shield = p.max_shield
    }
  }

  // Weapon fire timer
  if p.fire_timer > 0.0 {
    p.fire_timer -= dt
  }

  // Weapon selection (1-4)
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    p.weapon = Laser
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    p.weapon = Missile
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    p.weapon = Plasma
  }
  if @raylib.is_key_pressed(@raylib.KeyFour) {
    p.weapon = Railgun
  }

  // Fire weapon (Space or left mouse)
  let can_fire = p.fire_timer <= 0.0
  let has_energy = p.weapon_energy >= @types.weapon_energy_cost(p.weapon)
  let has_ammo = p.weapon != Missile || p.missile_ammo > 0
  if (
      @raylib.is_key_down(@raylib.KeySpace) ||
      @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
    ) &&
    can_fire &&
    has_energy &&
    has_ammo {
    game.fire_weapon()
    p.fire_timer = @types.weapon_cooldown(p.weapon)
    // Deduct energy
    let cost = @types.weapon_energy_cost(p.weapon)
    p.weapon_energy -= cost
    if p.weapon == Missile {
      p.missile_ammo -= 1
    }
    p.shots_fired += 1
  }

  // Tab to cycle targets
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    game.cycle_target()
  }

  // T to target nearest
  if @raylib.is_key_pressed(@raylib.KeyT) {
    game.target_nearest()
  }

  // Engine particles
  if game.frame_counter % 3 == 0 {
    let ex = p.x - p.ori_fx * 1.5
    let ey = p.y - p.ori_fy * 1.5
    let ez = p.z - p.ori_fz * 1.5
    let r : Int = if p.boosting { 100 } else { 50 }
    let g : Int = if p.boosting { 180 } else { 120 }
    @types.spawn_particles(game, ex, ey, ez, 1, r, g, 255)
  }

  // Extra engine particles for boost
  if p.boosting && game.frame_counter % 2 == 0 {
    let ex = p.x - p.ori_fx * 2.0 + @types.rand_rangef(game, -0.3, 0.3)
    let ey = p.y - p.ori_fy * 2.0 + @types.rand_rangef(game, -0.3, 0.3)
    let ez = p.z - p.ori_fz * 2.0 + @types.rand_rangef(game, -0.3, 0.3)
    @types.spawn_particles(game, ex, ey, ez, 2, 200, 220, 255)
  }

  // Smoke particles when hull is low
  if p.hull < p.max_hull * 0.3 && game.frame_counter % 5 == 0 {
    @types.spawn_particles(game, p.x, p.y, p.z, 1, 80, 80, 80)
  }
}

///|
fn @types.Game::fire_weapon(game : @types.Game) -> Unit {
  let p = game.player
  let fwd = (p.ori_fx, p.ori_fy, p.ori_fz)
  let rgt = (p.ori_rx, p.ori_ry, p.ori_rz)

  let damage_mult : Float = if p.weapon_boost_timer > 0.0 { 1.5 } else { 1.0 }

  match p.weapon {
    Laser => game.fire_laser(fwd, rgt, damage_mult)
    Missile => game.fire_missile(fwd, damage_mult)
    Plasma => game.fire_plasma(fwd, damage_mult)
    Railgun => game.fire_railgun(fwd, damage_mult)
  }
  game.camera_shake = @types.maxf(game.camera_shake, 0.3)
}

///|
fn @types.Game::fire_laser(
  game : @types.Game,
  fwd : (Float, Float, Float),
  rgt : (Float, Float, Float),
  damage_mult : Float,
) -> Unit {
  let p = game.player
  // Fire two bolts (left and right of ship)
  let offsets : Array[Float] = [0.4, -0.4]
  for off in offsets {
    let idx = @types.alloc_projectile(game)
    if idx < 0 {
      break
    }
    let proj = game.projectiles[idx]
    proj.active = true
    proj.kind = Laser
    proj.from_player = true
    proj.x = p.x + fwd.0 * 2.0 + rgt.0 * off
    proj.y = p.y + fwd.1 * 2.0 + rgt.1 * off
    proj.z = p.z + fwd.2 * 2.0 + rgt.2 * off
    proj.vx = fwd.0 * @types.laser_speed + p.vx
    proj.vy = fwd.1 * @types.laser_speed + p.vy
    proj.vz = fwd.2 * @types.laser_speed + p.vz
    proj.damage = @types.laser_damage * damage_mult
    proj.life = @types.laser_range / @types.laser_speed
    proj.target_idx = -1
    proj.size = 0.06
    proj.fuel = 0.0
    proj.piercing = false
  }
}

///|
fn @types.Game::fire_missile(
  game : @types.Game,
  fwd : (Float, Float, Float),
  damage_mult : Float,
) -> Unit {
  let p = game.player
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let proj = game.projectiles[idx]
  proj.active = true
  proj.kind = Missile
  proj.from_player = true
  proj.x = p.x + fwd.0 * 2.0
  proj.y = p.y + fwd.1 * 2.0
  proj.z = p.z + fwd.2 * 2.0
  proj.vx = fwd.0 * @types.missile_speed + p.vx
  proj.vy = fwd.1 * @types.missile_speed + p.vy
  proj.vz = fwd.2 * @types.missile_speed + p.vz
  proj.damage = @types.missile_damage * damage_mult
  proj.life = @types.missile_range / @types.missile_speed
  proj.target_idx = game.target_idx
  proj.size = 0.2
  proj.fuel = @types.missile_fuel
  proj.piercing = false
}

///|
fn @types.Game::fire_plasma(
  game : @types.Game,
  fwd : (Float, Float, Float),
  damage_mult : Float,
) -> Unit {
  let p = game.player
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let proj = game.projectiles[idx]
  proj.active = true
  proj.kind = Plasma
  proj.from_player = true
  proj.x = p.x + fwd.0 * 2.0
  proj.y = p.y + fwd.1 * 2.0
  proj.z = p.z + fwd.2 * 2.0
  proj.vx = fwd.0 * @types.plasma_speed + p.vx
  proj.vy = fwd.1 * @types.plasma_speed + p.vy
  proj.vz = fwd.2 * @types.plasma_speed + p.vz
  proj.damage = @types.plasma_damage * damage_mult
  proj.life = @types.plasma_range / @types.plasma_speed
  proj.target_idx = -1
  proj.size = 0.3
  proj.fuel = 0.0
  proj.piercing = false
}

///|
fn @types.Game::fire_railgun(
  game : @types.Game,
  fwd : (Float, Float, Float),
  damage_mult : Float,
) -> Unit {
  let p = game.player
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let proj = game.projectiles[idx]
  proj.active = true
  proj.kind = Railgun
  proj.from_player = true
  proj.x = p.x + fwd.0 * 2.5
  proj.y = p.y + fwd.1 * 2.5
  proj.z = p.z + fwd.2 * 2.5
  proj.vx = fwd.0 * @types.railgun_speed + p.vx
  proj.vy = fwd.1 * @types.railgun_speed + p.vy
  proj.vz = fwd.2 * @types.railgun_speed + p.vz
  proj.damage = @types.railgun_damage * damage_mult
  proj.life = @types.railgun_range / @types.railgun_speed
  proj.target_idx = -1
  proj.size = 0.04
  proj.fuel = 0.0
  proj.piercing = true
  // Railgun has stronger camera shake
  game.camera_shake = @types.maxf(game.camera_shake, 0.6)
}

///|
fn @types.Game::cycle_target(game : @types.Game) -> Unit {
  let start = game.target_idx + 1
  // Search forward from current
  for i in start..<game.enemies.length() {
    if game.enemies[i].active {
      game.target_idx = i
      game.target_lock_timer = 0.0
      return
    }
  }
  // Wrap around
  for i in 0..<start {
    if i < game.enemies.length() && game.enemies[i].active {
      game.target_idx = i
      game.target_lock_timer = 0.0
      return
    }
  }
  game.target_idx = -1
}

///|
fn @types.Game::target_nearest(game : @types.Game) -> Unit {
  let p = game.player
  let idx = @types.find_nearest_enemy(game, p.x, p.y, p.z)
  if idx >= 0 {
    game.target_idx = idx
    game.target_lock_timer = 0.0
  }
}

///|
/// Applies `damage` to the player ship, absorbing with shields first, and triggers game over on death.
pub fn damage_player(game : @types.Game, damage : Float) -> Unit {
  let p = game.player
  p.shield_timer = @types.shield_regen_delay
  p.damage_flash = @types.damage_flash_duration

  // Screen flash for damage
  game.screen_flash = 0.3
  game.flash_r = 255
  game.flash_g = 50
  game.flash_b = 50

  if p.shield > 0.0 {
    let absorbed = @types.minf(p.shield, damage)
    p.shield -= absorbed
    let remaining = damage - absorbed
    if remaining > 0.0 {
      p.hull -= remaining
    }
    // Shield hit particles
    @types.spawn_shield_hit(game, p.x, p.y, p.z, 5)
  } else {
    p.hull -= damage
  }
  game.camera_shake = @types.maxf(game.camera_shake, 0.5)
  if p.hull <= 0.0 {
    p.hull = 0.0
    game.state = StateGameOver
    @types.spawn_explosion(game, p.x, p.y, p.z, 40, 255, 150, 50)
    @types.spawn_debris(game, p.x, p.y, p.z, 10, 100, 150, 220)
    game.camera_shake = 2.0
    game.screen_flash = 1.0
  }
}
