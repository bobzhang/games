///|
/// Returns `v` clamped between `low` and `high`.
pub fn clampf(v : Float, low : Float, high : Float) -> Float {
  if v < low {
    low
  } else if v > high {
    high
  } else {
    v
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
/// Returns the linear interpolation between `a` and `b` at factor `t`.
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
/// Returns the sign of `v` as -1.0, 0.0, or 1.0.
pub fn sign(v : Float) -> Float {
  if v > 0.0 {
    1.0
  } else if v < 0.0 {
    -1.0
  } else {
    0.0
  }
}

///|
/// Returns the angle wrapped to the range (-pi, pi].
pub fn angle_wrap(angle : Float) -> Float {
  let mut a = angle
  if a > pi {
    a = a - two_pi
  }
  if a < -pi {
    a = a + two_pi
  }
  a
}

///|
/// Returns the shortest signed angular difference from `a` to `b`.
pub fn angle_diff(a : Float, b : Float) -> Float {
  angle_wrap(b - a)
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
/// Returns the Euclidean distance between two points on the XZ plane.
pub fn distance2d(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  @math.hypotf(x1 - x2, z1 - z2)
}

///|
/// Returns the unit vector of the given 3D vector, or zero if too short.
pub fn normalize3d(x : Float, y : Float, z : Float) -> (Float, Float, Float) {
  let len = (x * x + y * y + z * z).sqrt()
  if len < 0.0001 {
    (0.0, 0.0, 0.0)
  } else {
    (x / len, y / len, z / len)
  }
}

// Terrain height at world position using noise-like function

///|
/// Returns the procedural terrain height at world position (`wx`, `wz`).
pub fn terrain_height_at(wx : Float, wz : Float) -> Float {
  let freq1 : Float = 0.02
  let freq2 : Float = 0.05
  let freq3 : Float = 0.01
  let h1 = @math.sinf(wx * freq1 + 1.3) *
    @math.cosf(wz * freq1 + 0.7) *
    terrain_max_height *
    0.5
  let h2 = @math.sinf(wx * freq2 + 3.1) *
    @math.cosf(wz * freq2 + 2.1) *
    terrain_max_height *
    0.25
  let h3 = @math.sinf(wx * freq3) *
    @math.cosf(wz * freq3) *
    terrain_max_height *
    0.8
  let h = h1 + h2 + h3
  if h < 0.0 {
    0.0
  } else {
    h
  }
}

// Terrain height with bilinear interpolation for smoother results

// Terrain normal (approximate via finite differences)

// Altitude above terrain

///|
/// Returns the altitude above ground level at position (`x`, `y`, `z`).
pub fn altitude_above_terrain(x : Float, y : Float, z : Float) -> Float {
  let ground = terrain_height_at(x, z)
  y - ground
}

// Altitude effect on engine and control (thinner air at high altitude)

// Calculate lift based on speed and aircraft min speed

// Calculate drag based on speed

// Calculate thrust from throttle and altitude

// Check if aircraft is in stall condition

// Fuel consumption rate based on throttle

// Lead targeting: predict where target will be

// Bomb trajectory prediction: where will bomb land given current position/velocity

// Wind effect on aircraft

// Turbulence jitter

// Collision: point vs sphere

// Collision: point vs AABB (axis-aligned bounding box)

///|
/// Returns whether the point is inside the axis-aligned bounding box.
pub fn point_in_aabb(
  px : Float,
  py : Float,
  pz : Float,
  bx : Float,
  by : Float,
  bz : Float,
  hw : Float,
  hh : Float,
  hd : Float,
) -> Bool {
  (px - bx).abs() < hw && (py - by).abs() < hh && (pz - bz).abs() < hd
}

// Distance and bearing to waypoint

///|
/// Returns the bearing angle from one XZ position to another.
pub fn bearing_to(
  from_x : Float,
  from_z : Float,
  to_x : Float,
  to_z : Float,
) -> Float {
  @math.atan2f(to_x - from_x, to_z - from_z)
}

// Landing approach calculation

// Glide slope check for landing

// Calculate G-force from vertical acceleration change

// Camera chase position calculation

///|
/// Returns the chase camera world position behind and above the player.
pub fn chase_camera_pos(
  player_x : Float,
  player_y : Float,
  player_z : Float,
  fx : Float,
  fy : Float,
  fz : Float,
  dist : Float,
  height : Float,
) -> (Float, Float, Float) {
  let cx = player_x - fx * dist
  let cy = player_y - fy * dist + height
  let cz = player_z - fz * dist
  (cx, cy, cz)
}

// RNG

///|
/// Returns the next pseudo-random integer and advances the RNG state.
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

// Allocators

///|
/// Returns the index of a free enemy slot, or -1 if none available.
pub fn alloc_enemy(game : Game) -> Int {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      return i
    }
  }
  -1
}

///|
/// Returns the index of a free turret slot, or -1 if none available.
pub fn alloc_turret(game : Game) -> Int {
  for i in 0..<game.turrets.length() {
    if not(game.turrets[i].active) {
      return i
    }
  }
  -1
}

///|
/// Returns the index of a free projectile slot, or -1 if none available.
pub fn alloc_projectile(game : Game) -> Int {
  for i in 0..<game.projectiles.length() {
    if not(game.projectiles[i].active) {
      return i
    }
  }
  -1
}

///|
/// Returns the index of a free particle slot, or -1 if none available.
pub fn alloc_particle(game : Game) -> Int {
  for i in 0..<game.particles.length() {
    if not(game.particles[i].active) {
      return i
    }
  }
  -1
}

///|
/// Returns the index of a free checkpoint slot, or -1 if none available.
pub fn alloc_checkpoint(game : Game) -> Int {
  for i in 0..<game.checkpoints.length() {
    if not(game.checkpoints[i].active) {
      return i
    }
  }
  -1
}

///|
/// Returns the index of a free building slot, or -1 if none available.
pub fn alloc_building(game : Game) -> Int {
  for i in 0..<game.buildings.length() {
    if not(game.buildings[i].active) {
      return i
    }
  }
  -1
}

///|
/// Returns the index of a free cloud slot, or -1 if none available.
pub fn alloc_cloud(game : Game) -> Int {
  for i in 0..<game.clouds.length() {
    if not(game.clouds[i].active) {
      return i
    }
  }
  -1
}

// Spawn particles at position

///|
/// Spawns explosion particles at the given world position with the specified color.
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
    p.kind = particle_explosion
    p.x = wx + rand_rangef(game, -0.5, 0.5)
    p.y = wy + rand_rangef(game, -0.5, 0.5)
    p.z = wz + rand_rangef(game, -0.5, 0.5)
    p.vx = rand_rangef(game, -4.0, 4.0)
    p.vy = rand_rangef(game, -2.0, 5.0)
    p.vz = rand_rangef(game, -4.0, 4.0)
    p.life = rand_rangef(game, 0.3, 1.0)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.05, 0.2)
    ignore(i)
  }
}

// Spawn smoke trail particles

///|
/// Spawns smoke trail particles at the given world position.
pub fn spawn_smoke(
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
    p.kind = particle_smoke
    p.x = wx + rand_rangef(game, -0.3, 0.3)
    p.y = wy + rand_rangef(game, -0.3, 0.3)
    p.z = wz + rand_rangef(game, -0.3, 0.3)
    p.vx = rand_rangef(game, -1.0, 1.0)
    p.vy = rand_rangef(game, 0.5, 2.0)
    p.vz = rand_rangef(game, -1.0, 1.0)
    p.life = rand_rangef(game, 0.8, 2.0)
    p.max_life = p.life
    p.r = 80
    p.g = 80
    p.b = 80
    p.size = rand_rangef(game, 0.15, 0.4)
    ignore(i)
  }
}

// Spawn fire particles

///|
/// Spawns fire particles at the given world position.
pub fn spawn_fire(
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
    p.kind = particle_fire
    p.x = wx + rand_rangef(game, -0.2, 0.2)
    p.y = wy
    p.z = wz + rand_rangef(game, -0.2, 0.2)
    p.vx = rand_rangef(game, -1.5, 1.5)
    p.vy = rand_rangef(game, 1.0, 4.0)
    p.vz = rand_rangef(game, -1.5, 1.5)
    p.life = rand_rangef(game, 0.2, 0.6)
    p.max_life = p.life
    p.r = 255
    p.g = rand_range(game, 80, 200)
    p.b = 20
    p.size = rand_rangef(game, 0.1, 0.25)
    ignore(i)
  }
}

// Spawn debris particles

///|
/// Spawns debris particles at the given world position.
pub fn spawn_debris(
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
    p.kind = particle_debris
    p.x = wx + rand_rangef(game, -1.0, 1.0)
    p.y = wy + rand_rangef(game, -0.5, 1.0)
    p.z = wz + rand_rangef(game, -1.0, 1.0)
    p.vx = rand_rangef(game, -8.0, 8.0)
    p.vy = rand_rangef(game, 2.0, 10.0)
    p.vz = rand_rangef(game, -8.0, 8.0)
    p.life = rand_rangef(game, 0.5, 1.5)
    p.max_life = p.life
    p.r = rand_range(game, 60, 120)
    p.g = rand_range(game, 50, 100)
    p.b = rand_range(game, 30, 60)
    p.size = rand_rangef(game, 0.1, 0.3)
    ignore(i)
  }
}

// Spawn rocket trail

///|
/// Spawns a single smoke particle for a rocket exhaust trail.
pub fn spawn_rocket_trail(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
) -> Unit {
  let idx = alloc_particle(game)
  if idx < 0 {
    return
  }
  let p = game.particles[idx]
  p.active = true
  p.kind = particle_smoke
  p.x = wx + rand_rangef(game, -0.1, 0.1)
  p.y = wy + rand_rangef(game, -0.1, 0.1)
  p.z = wz + rand_rangef(game, -0.1, 0.1)
  p.vx = rand_rangef(game, -0.5, 0.5)
  p.vy = rand_rangef(game, -0.3, 0.3)
  p.vz = rand_rangef(game, -0.5, 0.5)
  p.life = 0.4
  p.max_life = 0.4
  p.r = 200
  p.g = 200
  p.b = 200
  p.size = 0.15
}

// Spawn explosion

///|
/// Spawns a full explosion effect with fire, debris, and smoke at the given position.
pub fn spawn_explosion(game : Game, wx : Float, wy : Float, wz : Float) -> Unit {
  spawn_particles(game, wx, wy, wz, 20, 255, 180, 50)
  spawn_particles(game, wx, wy, wz, 10, 255, 80, 20)
  spawn_fire(game, wx, wy, wz, 8)
  spawn_debris(game, wx, wy, wz, 6)
  spawn_smoke(game, wx, wy, wz, 5)
}

// Spawn large explosion (for buildings/bases)

///|
/// Spawns an oversized explosion effect for buildings and bases.
pub fn spawn_large_explosion(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
) -> Unit {
  spawn_particles(game, wx, wy, wz, 30, 255, 200, 50)
  spawn_particles(game, wx, wy, wz, 15, 255, 100, 30)
  spawn_fire(game, wx, wy, wz, 15)
  spawn_debris(game, wx, wy, wz, 12)
  spawn_smoke(game, wx, wy, wz, 10)
}

// Show message

///|
/// Sets the primary on-screen message with the given `text` and `duration`.
pub fn show_message(game : Game, text : String, duration : Float) -> Unit {
  game.message_text = text
  game.message_timer = duration
}

// Add message to message queue

///|
/// Adds a prioritized message to the message queue.
pub fn push_message(
  game : Game,
  text : String,
  duration : Float,
  priority : Int,
) -> Unit {
  // Find empty slot or lowest priority
  let mut lowest_pri = 999
  let mut lowest_idx = 0
  for i in 0..<game.messages.length() {
    if game.messages[i].timer <= 0.0 {
      game.messages[i].text = text
      game.messages[i].timer = duration
      game.messages[i].priority = priority
      return
    }
    if game.messages[i].priority < lowest_pri {
      lowest_pri = game.messages[i].priority
      lowest_idx = i
    }
  }
  // Overwrite lowest priority if our priority is higher
  if priority > lowest_pri {
    game.messages[lowest_idx].text = text
    game.messages[lowest_idx].timer = duration
    game.messages[lowest_idx].priority = priority
  }
}

// Count active enemies

// Count active turrets

// Count active buildings

///|
/// Returns the number of currently active buildings.
pub fn count_active_buildings(game : Game) -> Int {
  let mut count = 0
  for building in game.buildings {
    if building.active {
      count += 1
    }
  }
  count
}

// Count active checkpoints not collected

// Get forward direction from pitch and yaw

///|
/// Returns the forward direction unit vector from `pitch` and `yaw` angles.
pub fn get_forward(pitch : Float, yaw : Float) -> (Float, Float, Float) {
  let cp = @math.cosf(pitch)
  let sp = @math.sinf(pitch)
  let cy = @math.cosf(yaw)
  let sy = @math.sinf(yaw)
  (sy * cp, -sp, cy * cp)
}

// Get right direction from yaw and roll

///|
/// Returns the right direction unit vector from `yaw` and `roll` angles.
pub fn get_right(yaw : Float, roll : Float) -> (Float, Float, Float) {
  let cy = @math.cosf(yaw)
  let sy = @math.sinf(yaw)
  let cr = @math.cosf(roll)
  let sr = @math.sinf(roll)
  (cy * cr, sr, -sy * cr)
}

// Find nearest enemy to position

// Calculate mission accuracy percentage

///|
/// Returns the hit accuracy as a percentage from `shots_fired` and `shots_hit`.
pub fn calculate_accuracy(shots_fired : Int, shots_hit : Int) -> Float {
  if shots_fired <= 0 {
    0.0
  } else {
    Float::from_int(shots_hit) / Float::from_int(shots_fired) * 100.0
  }
}

// Calculate mission rating based on score

///|
/// Returns the letter rating grade for a mission based on `score`.
pub fn calculate_rating(score : Int) -> String {
  if score >= rating_s_threshold {
    "S"
  } else if score >= rating_a_threshold {
    "A"
  } else if score >= rating_b_threshold {
    "B"
  } else if score >= rating_c_threshold {
    "C"
  } else {
    "D"
  }
}

// Weapon name for display

///|
/// Returns the short display name for the weapon type `kind`.
pub fn weapon_name(kind : Int) -> String {
  if kind == weapon_machine_gun {
    "MG"
  } else if kind == weapon_rockets {
    "RKT"
  } else if kind == weapon_bombs {
    "BMB"
  } else {
    "???"
  }
}

// Get ammo count for current weapon

///|
/// Returns the remaining ammo count for the player's currently equipped weapon.
pub fn get_ammo(player : Player) -> Int {
  if player.current_weapon == weapon_machine_gun {
    player.ammo_mg
  } else if player.current_weapon == weapon_rockets {
    player.ammo_rockets
  } else {
    player.ammo_bombs
  }
}

// Weather name

///|
/// Returns the display name string for the weather type `kind`.
pub fn weather_name(kind : Int) -> String {
  if kind == weather_clear {
    "CLEAR"
  } else if kind == weather_cloudy {
    "CLOUDY"
  } else if kind == weather_fog {
    "FOG"
  } else if kind == weather_rain {
    "RAIN"
  } else if kind == weather_storm {
    "STORM"
  } else if kind == weather_night {
    "NIGHT"
  } else {
    ""
  }
}

// Difficulty stars string

///|
/// Returns a star-rating string representing the difficulty `level`.
pub fn difficulty_str(level : Int) -> String {
  if level <= 1 {
    "*"
  } else if level <= 2 {
    "**"
  } else if level <= 3 {
    "***"
  } else if level <= 5 {
    "****"
  } else if level <= 7 {
    "*****"
  } else {
    "******"
  }
}
