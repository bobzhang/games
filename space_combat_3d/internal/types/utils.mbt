///|
/// Returns the smaller of `a` and `b`.
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
/// Returns the larger of `a` and `b`.
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// Returns the linear interpolation between `a` and `b` by factor `t`.
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
/// Returns the Euclidean distance between two 3D points.
pub fn distance3d(
  x1 : Float,
  y1 : Float,
  z1 : Float,
  x2 : Float,
  y2 : Float,
  z2 : Float,
) -> Float {
  let dx = x1 - x2
  let dy = y1 - y2
  let dz = z1 - z2
  (dx * dx + dy * dy + dz * dz).sqrt()
}

///|
/// Returns the unit vector of the given 3D vector, or forward if near zero.
pub fn normalize3d(x : Float, y : Float, z : Float) -> (Float, Float, Float) {
  let len = (x * x + y * y + z * z).sqrt()
  if len < 0.0001 {
    (0.0, 0.0, 1.0)
  } else {
    (x / len, y / len, z / len)
  }
}

///|
/// Returns the magnitude of a 3D vector.
pub fn length3d(x : Float, y : Float, z : Float) -> Float {
  (x * x + y * y + z * z).sqrt()
}

// Cross product

///|
/// Returns the cross product of two 3D vectors.
pub fn cross3d(
  x1 : Float,
  y1 : Float,
  z1 : Float,
  x2 : Float,
  y2 : Float,
  z2 : Float,
) -> (Float, Float, Float) {
  (y1 * z2 - z1 * y2, z1 * x2 - x1 * z2, x1 * y2 - y1 * x2)
}

// Rotate a vector around an axis by angle (Rodrigues rotation formula)

///|
/// Rotates vector (vx,vy,vz) around unit axis (ax,ay,az) by `angle` radians.
pub fn rotate_around_axis(
  vx : Float,
  vy : Float,
  vz : Float,
  ax : Float,
  ay : Float,
  az : Float,
  angle : Float,
) -> (Float, Float, Float) {
  let c = @math.cosf(angle)
  let s = @math.sinf(angle)
  let dot = vx * ax + vy * ay + vz * az
  let cx = ay * vz - az * vy
  let cy = az * vx - ax * vz
  let cz = ax * vy - ay * vx
  (
    vx * c + cx * s + ax * dot * (1.0 - c),
    vy * c + cy * s + ay * dot * (1.0 - c),
    vz * c + cz * s + az * dot * (1.0 - c),
  )
}

///|
/// Returns the dot product of two 3D vectors.
pub fn dot3d(
  x1 : Float,
  y1 : Float,
  z1 : Float,
  x2 : Float,
  y2 : Float,
  z2 : Float,
) -> Float {
  x1 * x2 + y1 * y2 + z1 * z2
}

///|
/// Clamps a float value between min and max.
pub fn clampf(v : Float, low : Float, high : Float) -> Float {
  if v < low {
    low
  } else if v > high {
    high
  } else {
    v
  }
}

// Forward direction from yaw and pitch

///|
/// Returns the forward direction vector from `yaw` and `pitch` angles.
pub fn forward_dir(yaw : Float, pitch : Float) -> (Float, Float, Float) {
  let cp = @math.cosf(pitch)
  let sp = @math.sinf(pitch)
  let cy = @math.cosf(yaw)
  let sy = @math.sinf(yaw)
  (sy * cp, sp, cy * cp)
}

// Right direction from yaw

///|
/// Returns the right-facing direction vector from `yaw` angle.
pub fn right_dir(yaw : Float) -> (Float, Float, Float) {
  let cy = @math.cosf(yaw)
  let sy = @math.sinf(yaw)
  (cy, 0.0, -sy)
}

// Up direction from yaw and pitch

///|
/// Returns the upward direction vector from `yaw` and `pitch` angles.
pub fn up_dir(yaw : Float, pitch : Float) -> (Float, Float, Float) {
  let fwd = forward_dir(yaw, pitch)
  let rgt = right_dir(yaw)
  cross3d(rgt.0, rgt.1, rgt.2, fwd.0, fwd.1, fwd.2)
}

// Lead targeting: calculate where to aim to hit a moving target
// Returns the aim direction normalized

///|
/// Returns the aim direction to intercept a moving target with a projectile.
pub fn lead_target(
  shooter_x : Float,
  shooter_y : Float,
  shooter_z : Float,
  target_x : Float,
  target_y : Float,
  target_z : Float,
  target_vx : Float,
  target_vy : Float,
  target_vz : Float,
  projectile_speed : Float,
) -> (Float, Float, Float) {
  let dx = target_x - shooter_x
  let dy = target_y - shooter_y
  let dz = target_z - shooter_z
  let dist = (dx * dx + dy * dy + dz * dz).sqrt()
  if dist < 0.01 {
    return (0.0, 0.0, 1.0)
  }
  // Time to intercept (approximate)
  let time_to_target = dist / projectile_speed
  // Predict target position
  let pred_x = target_x + target_vx * time_to_target
  let pred_y = target_y + target_vy * time_to_target
  let pred_z = target_z + target_vz * time_to_target
  // Direction to predicted position
  let aim_dx = pred_x - shooter_x
  let aim_dy = pred_y - shooter_y
  let aim_dz = pred_z - shooter_z
  normalize3d(aim_dx, aim_dy, aim_dz)
}

// Sphere-sphere collision test

// Distance culling: check if object is within render distance

// Damage calculation with shield absorption

// Angle difference (handles wrapping)

// Smooth damp (spring-like interpolation)

// RNG

///|
/// Returns the next pseudo-random positive integer and advances the RNG state.
pub fn rand_next(game : Game) -> Int {
  let mut x = game.rng_state
  x = x ^ (x << 13)
  x = x ^ (x >> 17)
  x = x ^ (x << 5)
  if x < 0 {
    x = -x
  }
  game.rng_state = x
  x
}

///|
/// Returns a random integer in the inclusive range [`low`, `high`].
pub fn rand_range(game : Game, low : Int, high : Int) -> Int {
  if high <= low {
    low
  } else {
    low + rand_next(game) % (high - low + 1)
  }
}

///|
/// Returns a random float in the range [`low`, `high`].
pub fn rand_rangef(game : Game, low : Float, high : Float) -> Float {
  let n = Float::from_int(rand_next(game) % 10000) / 10000.0
  low + (high - low) * n
}

///|
/// Returns whether a random roll succeeds with the given `chance` probability.
pub fn rand_bool(game : Game, chance : Float) -> Bool {
  rand_rangef(game, 0.0, 1.0) < chance
}

///|
/// Returns the index of the first inactive enemy slot, or -1 if the pool is full.
pub fn alloc_enemy(game : Game) -> Int {
  @utils.first_index_by(game.enemies, fn(slot) { !slot.active })
}

///|
/// Returns the index of the first inactive projectile slot, or -1 if the pool is full.
pub fn alloc_projectile(game : Game) -> Int {
  @utils.first_index_by(game.projectiles, fn(slot) { !slot.active })
}

///|
/// Returns the index of the first inactive particle slot, or -1 if the pool is full.
pub fn alloc_particle(game : Game) -> Int {
  @utils.first_index_by(game.particles, fn(slot) { !slot.active })
}

///|
/// Returns the index of the first inactive asteroid slot, or -1 if the pool is full.
pub fn alloc_asteroid(game : Game) -> Int {
  @utils.first_index_by(game.asteroids, fn(slot) { !slot.active })
}

///|
/// Returns the index of the first inactive power-up slot, or -1 if the pool is full.
pub fn alloc_powerup(game : Game) -> Int {
  @utils.first_index_by(game.powerups, fn(slot) { !slot.active })
}

///|
/// Returns the index of the first inactive station slot, or -1 if the pool is full.
pub fn alloc_station(game : Game) -> Int {
  @utils.first_index_by(game.stations, fn(slot) { !slot.active })
}

///|
/// Returns the index of the first inactive debris slot, or -1 if the pool is full.
pub fn alloc_debris(game : Game) -> Int {
  @utils.first_index_by(game.debris, fn(slot) { !slot.active })
}

///|
/// Spawns colored particles scattered around a world position.
pub fn spawn_particles(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  count : Int,
  r : Int,
  g : Int,
  b : Int,
) -> Unit {
  for i in 0..<count {
    let idx = alloc_particle(game)
    if idx < 0 {
      return
    }
    let p = game.particles[idx]
    p.active = true
    p.x = wx + rand_rangef(game, -0.5, 0.5)
    p.y = wy + rand_rangef(game, -0.5, 0.5)
    p.z = wz + rand_rangef(game, -0.5, 0.5)
    p.vx = rand_rangef(game, -8.0, 8.0)
    p.vy = rand_rangef(game, -8.0, 8.0)
    p.vz = rand_rangef(game, -8.0, 8.0)
    p.life = rand_rangef(game, 0.3, 1.0)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.05, 0.2)
    p.kind = 0
    ignore(i)
  }
}

///|
/// Spawns an expanding explosion particle burst at a world position.
pub fn spawn_explosion(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  count : Int,
  r : Int,
  g : Int,
  b : Int,
) -> Unit {
  for i in 0..<count {
    let idx = alloc_particle(game)
    if idx < 0 {
      return
    }
    let p = game.particles[idx]
    p.active = true
    p.x = wx
    p.y = wy
    p.z = wz
    p.vx = rand_rangef(game, -15.0, 15.0)
    p.vy = rand_rangef(game, -15.0, 15.0)
    p.vz = rand_rangef(game, -15.0, 15.0)
    p.life = rand_rangef(game, 0.5, 1.5)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.1, 0.4)
    p.kind = 1
    ignore(i)
  }
}

// Spawn shield hit particles at a specific point

///|
/// Spawns blue shield impact particles at a world position.
pub fn spawn_shield_hit(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  count : Int,
) -> Unit {
  for i in 0..<count {
    let idx = alloc_particle(game)
    if idx < 0 {
      return
    }
    let p = game.particles[idx]
    p.active = true
    p.x = wx
    p.y = wy
    p.z = wz
    p.vx = rand_rangef(game, -5.0, 5.0)
    p.vy = rand_rangef(game, -5.0, 5.0)
    p.vz = rand_rangef(game, -5.0, 5.0)
    p.life = rand_rangef(game, 0.2, 0.5)
    p.max_life = p.life
    p.r = 80
    p.g = 160
    p.b = 255
    p.size = rand_rangef(game, 0.08, 0.15)
    p.kind = 2
    ignore(i)
  }
}

// Spawn debris from destroyed ship

///|
/// Spawns tumbling debris fragments from a destroyed ship at a world position.
pub fn spawn_debris(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  count : Int,
  r : Int,
  g : Int,
  b : Int,
) -> Unit {
  for i in 0..<count {
    let idx = alloc_debris(game)
    if idx < 0 {
      return
    }
    let d = game.debris[idx]
    d.active = true
    d.x = wx + rand_rangef(game, -1.0, 1.0)
    d.y = wy + rand_rangef(game, -1.0, 1.0)
    d.z = wz + rand_rangef(game, -1.0, 1.0)
    d.vx = rand_rangef(game, -10.0, 10.0)
    d.vy = rand_rangef(game, -10.0, 10.0)
    d.vz = rand_rangef(game, -10.0, 10.0)
    d.rot_x = rand_rangef(game, 0.0, 6.28)
    d.rot_y = rand_rangef(game, 0.0, 6.28)
    d.rot_speed = rand_rangef(game, 1.0, 4.0)
    d.life = rand_rangef(game, 3.0, 6.0)
    d.size = rand_rangef(game, 0.2, 0.6)
    d.r = r
    d.g = g
    d.b = b
    ignore(i)
  }
}

// Count active enemies

///|
/// Returns the number of currently active enemies in the pool.
pub fn count_active_enemies(game : Game) -> Int {
  let mut count = 0
  for enemy in game.enemies {
    if enemy.active {
      count += 1
    }
  }
  count
}

// Count active enemies of a type

///|
/// Returns the number of active enemies matching the given `kind`.
pub fn count_enemies_of_type(game : Game, kind : Int) -> Int {
  let mut count = 0
  for enemy in game.enemies {
    if enemy.active && enemy.kind == kind {
      count += 1
    }
  }
  count
}

// Find nearest enemy to a position

///|
/// Returns the index of the nearest active enemy to the given position, or -1 if none.
pub fn find_nearest_enemy(game : Game, x : Float, y : Float, z : Float) -> Int {
  for i, e in game.enemies; best_idx = -1, best_dist = 999999.0F {
    if !e.active {
      continue
    }
    let dist = distance3d(x, y, z, e.x, e.y, e.z)
    if dist < best_dist {
      continue i, dist
    }
  } nobreak {
    best_idx
  }
}

// Weapon name

///|
/// Returns the display name for the given `weapon` type.
pub fn weapon_name(weapon : WeaponKind) -> String {
  match weapon {
    Laser => "LASER"
    Missile => "MISSILE"
    Plasma => "PLASMA"
    Railgun => "RAILGUN"
  }
}

// Weapon cooldown

///|
/// Returns the fire cooldown interval in seconds for the given `weapon` type.
pub fn weapon_cooldown(weapon : WeaponKind) -> Float {
  match weapon {
    Laser => laser_cooldown
    Missile => missile_cooldown
    Plasma => plasma_cooldown
    Railgun => railgun_cooldown
  }
}

// Weapon energy cost

///|
/// Returns the energy cost per shot for the given `weapon` type.
pub fn weapon_energy_cost(weapon : WeaponKind) -> Float {
  match weapon {
    Laser => laser_energy_cost
    Missile => 0.0
    Plasma => plasma_energy_cost
    Railgun => railgun_energy_cost
  }
}

// Weapon speed

///|
/// Returns the projectile speed for the given `weapon` type.
pub fn weapon_proj_speed(weapon : WeaponKind) -> Float {
  match weapon {
    Laser => laser_speed
    Missile => missile_speed
    Plasma => plasma_speed
    Railgun => railgun_speed
  }
}

// Enemy type name

///|
/// Returns the display name for the given enemy `kind`.
pub fn enemy_type_name(kind : Int) -> String {
  if kind == enemy_fighter {
    "Fighter"
  } else if kind == enemy_cruiser {
    "Cruiser"
  } else if kind == enemy_interceptor {
    "Interceptor"
  } else if kind == enemy_bomber {
    "Bomber"
  } else if kind == enemy_capital {
    "Capital Ship"
  } else {
    "Asteroid"
  }
}

// Wrap coordinate within world bounds

///|
/// Returns `v` wrapped within the world boundary limits.
pub fn wrap_coord(v : Float) -> Float {
  let half = world_size
  if v > half {
    v - half * 2.0
  } else if v < -half {
    v + half * 2.0
  } else {
    v
  }
}

// Add kill feed entry

///|
/// Adds a new colored text entry to the top of the kill feed display.
pub fn add_kill_feed(
  game : Game,
  text : String,
  r : Int,
  g : Int,
  b : Int,
) -> Unit {
  // Shift existing entries up
  for i = max_kill_feed - 1; i > 0; i = i - 1 {
    game.kill_feed[i].active = game.kill_feed[i - 1].active
    game.kill_feed[i].text = game.kill_feed[i - 1].text
    game.kill_feed[i].timer = game.kill_feed[i - 1].timer
    game.kill_feed[i].r = game.kill_feed[i - 1].r
    game.kill_feed[i].g = game.kill_feed[i - 1].g
    game.kill_feed[i].b = game.kill_feed[i - 1].b
  }
  game.kill_feed[0].active = true
  game.kill_feed[0].text = text
  game.kill_feed[0].timer = kill_feed_duration
  game.kill_feed[0].r = r
  game.kill_feed[0].g = g
  game.kill_feed[0].b = b
}

// Spawn floating damage number

///|
/// Creates a floating damage number at the given 3D position.
pub fn spawn_damage_number(
  game : Game,
  x : Float,
  y : Float,
  z : Float,
  value : Int,
  r : Int,
  g : Int,
  b : Int,
) -> Unit {
  for i in 0..<max_damage_numbers {
    if !game.damage_numbers[i].active {
      let dn = game.damage_numbers[i]
      dn.active = true
      dn.x = x
      dn.y = y
      dn.z = z
      dn.value = value
      dn.timer = damage_number_duration
      dn.r = r
      dn.g = g
      dn.b = b
      return
    }
  }
}

// Update combo system

///|
/// Updates the combo timer and resets the multiplier when the combo expires.
pub fn update_combo(game : Game, dt : Float) -> Unit {
  if game.combo_timer > 0.0 {
    game.combo_timer -= dt
    if game.combo_timer <= 0.0 {
      game.combo_count = 0
      game.combo_multiplier = 1.0
    }
  }
}

// Register a kill for combo

///|
/// Registers a kill in the combo system and updates the score multiplier.
pub fn register_kill_combo(game : Game) -> Unit {
  game.combo_count += 1
  game.combo_timer = combo_timeout
  if game.combo_count >= 8 {
    game.combo_multiplier = combo_mult_8
  } else if game.combo_count >= 5 {
    game.combo_multiplier = combo_mult_5
  } else if game.combo_count >= 3 {
    game.combo_multiplier = combo_mult_3
  } else if game.combo_count >= 2 {
    game.combo_multiplier = combo_mult_2
  } else {
    game.combo_multiplier = 1.0
  }
}

// Formation position calculation

///|
/// Returns the 3D position offset for a unit at the given `index` in a formation `pattern`.
pub fn formation_offset(
  pattern : Formation,
  index : Int,
  spacing : Float,
) -> (Float, Float, Float) {
  let fi = Float::from_int(index)
  match pattern {
    V => {
      // V formation: alternating left/right, pushed back
      let side : Float = if index % 2 == 0 { 1.0 } else { -1.0 }
      let rank = Float::from_int((index + 1) / 2)
      (side * rank * spacing, 0.0, -rank * spacing * 0.8)
    }
    Line => {
      // Line abreast
      let half = fi - 3.0
      (half * spacing, 0.0, 0.0)
    }
    Circle => {
      // Circle formation
      let angle = fi * (two_pi / 8.0)
      let r = spacing * 2.0
      (@math.cosf(angle) * r, 0.0, @math.sinf(angle) * r)
    }
    _ => {
      // Wedge (arrow)
      let side : Float = if index % 2 == 0 { 1.0 } else { -1.0 }
      let rank = Float::from_int((index + 1) / 2)
      (side * rank * spacing * 0.7, rank * spacing * 0.3, -rank * spacing)
    }
  }
}

// Check and update mission objectives

///|
/// Updates mission objectives of the given type by the specified increment.
pub fn check_objective_progress(
  game : Game,
  obj_type : Objective,
  increment : Int,
) -> Unit {
  for i in 0..<game.objectives_count {
    let obj = game.objectives[i]
    if obj.obj_type == obj_type && !obj.complete {
      obj.current_count = obj.current_count + increment
      if obj.current_count >= obj.target_count {
        obj.current_count = obj.target_count
        obj.complete = true
      }
    }
  }
}

// Check if all objectives are complete

// Accuracy percentage

// Mission rank based on score, time, accuracy

// === Spectacle System ===

///|
/// Spawns a directional explosion where particles expand outward from impact direction.
pub fn spawn_directional_explosion(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  hit_dx : Float,
  hit_dy : Float,
  hit_dz : Float,
  count : Int,
  r : Int,
  g : Int,
  b : Int,
) -> Unit {
  let norm = normalize3d(hit_dx, hit_dy, hit_dz)
  for i in 0..<count {
    let idx = alloc_particle(game)
    if idx < 0 {
      return
    }
    let p = game.particles[idx]
    p.active = true
    p.x = wx
    p.y = wy
    p.z = wz
    // Bias velocity along impact direction with spread
    let base_speed = rand_rangef(game, 8.0, 20.0)
    let spread_x = rand_rangef(game, -0.6, 0.6)
    let spread_y = rand_rangef(game, -0.6, 0.6)
    let spread_z = rand_rangef(game, -0.6, 0.6)
    p.vx = norm.0 * base_speed + spread_x * base_speed
    p.vy = norm.1 * base_speed + spread_y * base_speed
    p.vz = norm.2 * base_speed + spread_z * base_speed
    p.life = rand_rangef(game, 0.5, 1.5)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.1, 0.4)
    p.kind = 1
    ignore(i)
  }
}

///|
/// Spawns burning debris chunks that drift and fade with fire trail particles.
pub fn spawn_burning_debris(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  count : Int,
  r : Int,
  g : Int,
  b : Int,
) -> Unit {
  let actual = minf(Float::from_int(count), 5.0).to_int()
  for i in 0..<actual {
    let idx = alloc_debris(game)
    if idx < 0 {
      return
    }
    let d = game.debris[idx]
    d.active = true
    d.x = wx + rand_rangef(game, -1.5, 1.5)
    d.y = wy + rand_rangef(game, -1.5, 1.5)
    d.z = wz + rand_rangef(game, -1.5, 1.5)
    d.vx = rand_rangef(game, -6.0, 6.0)
    d.vy = rand_rangef(game, -6.0, 6.0)
    d.vz = rand_rangef(game, -6.0, 6.0)
    d.rot_x = rand_rangef(game, 0.0, 6.28)
    d.rot_y = rand_rangef(game, 0.0, 6.28)
    d.rot_speed = rand_rangef(game, 2.0, 5.0)
    d.life = rand_rangef(game, 3.0, 4.0)
    d.size = rand_rangef(game, 0.3, 0.7)
    d.r = r
    d.g = g
    d.b = b
    ignore(i)
  }
}

///|
/// Spawns a shock ring expanding from the given position.
pub fn spawn_shock_ring(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  max_radius : Float,
  life : Float,
  r : Int,
  g : Int,
  b : Int,
) -> Unit {
  for ring in game.shock_rings {
    if !ring.active {
      ring.active = true
      ring.x = wx
      ring.y = wy
      ring.z = wz
      ring.radius = 1.0
      ring.max_radius = max_radius
      ring.life = life
      ring.max_life = life
      ring.r = r
      ring.g = g
      ring.b = b
      return
    }
  }
}

///|
/// Returns the 3D offset for a capital ship weak point at the given index.
pub fn capital_weak_point_offset(index : Int) -> (Float, Float, Float) {
  if index == 0 {
    // Underside center
    (0.0, -1.8, 0.0)
  } else if index == 1 {
    // Port engine
    (-2.0, -0.5, -4.0)
  } else {
    // Starboard engine
    (2.0, -0.5, -4.0)
  }
}
