///|
/// Converts EnemyKind to integer.
pub fn EnemyKind::to_int(self : EnemyKind) -> Int {
  match self {
    Zombie => 0
    Runner => 1
    Brute => 2
    Spitter => 3
    Exploder => 4
    Necromancer => 5
    Shielded => 6
    Boss => 7
  }
}

///|
/// Converts integer to EnemyKind.
pub fn EnemyKind::from_int(v : Int) -> EnemyKind {
  match v {
    0 => Zombie
    1 => Runner
    2 => Brute
    3 => Spitter
    4 => Exploder
    5 => Necromancer
    6 => Shielded
    _ => Boss
  }
}

///|
/// Converts WeaponKind to integer.
pub fn WeaponKind::to_int(self : WeaponKind) -> Int {
  match self {
    Pistol => 0
    Shotgun => 1
    Rifle => 2
    Sniper => 3
    Rocket => 4
    Minigun => 5
  }
}

///|
/// Converts integer to WeaponKind.
pub fn WeaponKind::from_int(v : Int) -> WeaponKind {
  match v {
    0 => Pistol
    1 => Shotgun
    2 => Rifle
    3 => Sniper
    4 => Rocket
    _ => Minigun
  }
}

///|
/// Converts ParticleKind to integer.
pub fn ParticleKind::to_int(self : ParticleKind) -> Int {
  match self {
    Blood => 0
    Muzzle => 1
    Explosion => 2
    Shell => 3
    Spark => 4
    Heal => 5
  }
}

///|
/// Converts integer to ParticleKind.
pub fn ParticleKind::from_int(v : Int) -> ParticleKind {
  match v {
    0 => Blood
    1 => Muzzle
    2 => Explosion
    3 => Shell
    4 => Spark
    _ => Heal
  }
}

///|
/// Converts Trap to integer.
pub fn Trap::to_int(self : Trap) -> Int {
  match self {
    Spike => 0
    Flame => 1
    Electric => 2
  }
}

///|
/// Converts integer to Trap.
pub fn Trap::from_int(v : Int) -> Trap {
  match v {
    0 => Spike
    1 => Flame
    _ => Electric
  }
}

///|
/// Clamps a float value to inclusive range `[low, high]`.
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
/// Returns the smaller of two float values.
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
/// Returns the larger of two float values.
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// Linearly interpolates from `a` to `b` by factor `t`.
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
/// Returns the sign of a float as `-1.0`, `0.0`, or `1.0`.
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
/// Computes planar distance on the arena floor (`x/z` axes).
pub fn distance2d(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  @math.hypotf(x1 - x2, z1 - z2)
}

///|
/// Computes full 3D Euclidean distance.
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
/// Normalizes a 3D vector, returning zero vector for near-zero length input.
pub fn normalize3d(x : Float, y : Float, z : Float) -> (Float, Float, Float) {
  let len = (x * x + y * y + z * z).sqrt()
  if len < 0.0001 {
    (0.0, 0.0, 0.0)
  } else {
    (x / len, y / len, z / len)
  }
}

// Dot product of two 3d vectors

// Angle between two 2d vectors (returns radians)

// Check if angle difference is within threshold (for shield check)

///|
/// Returns whether two angles differ by less than `threshold` radians.
pub fn angle_within(angle1 : Float, angle2 : Float, threshold : Float) -> Bool {
  let mut diff = angle1 - angle2
  if diff > pi {
    diff = diff - 2.0 * pi
  }
  if diff < -pi {
    diff = diff + 2.0 * pi
  }
  diff.abs() < threshold
}

// RNG

///|
/// Advances xorshift RNG state and returns next random integer.
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
/// Returns integer random value in inclusive range `[low, high]`.
pub fn rand_range(game : Game, low : Int, high : Int) -> Int {
  if high <= low {
    low
  } else {
    low + rand_next(game) % (high - low + 1)
  }
}

///|
/// Returns float random value in range `[low, high]`.
pub fn rand_rangef(game : Game, low : Float, high : Float) -> Float {
  let n = Float::from_int(rand_next(game) % 10000) / 10000.0
  low + (high - low) * n
}

///|
/// Bernoulli helper that returns true with probability `chance`.
pub fn rand_bool(game : Game, chance : Float) -> Bool {
  rand_rangef(game, 0.0, 1.0) < chance
}

// Allocators

///|
/// Finds a free enemy slot in the enemy pool.
pub fn alloc_enemy(game : Game) -> Int {
  for i, slot in game.enemies {
    if !slot.active {
      return i
    }
  }
  -1
}

///|
/// Finds a free projectile slot in the projectile pool.
pub fn alloc_projectile(game : Game) -> Int {
  for i, slot in game.projectiles {
    if !slot.active {
      return i
    }
  }
  -1
}

///|
/// Finds a free particle slot in the particle pool.
pub fn alloc_particle(game : Game) -> Int {
  for i, slot in game.particles {
    if !slot.active {
      return i
    }
  }
  -1
}

///|
/// Finds a free pickup slot in the pickup pool.
pub fn alloc_pickup(game : Game) -> Int {
  for i, slot in game.pickups {
    if !slot.active {
      return i
    }
  }
  -1
}

///|
/// Finds a free barricade slot in the barricade pool.
pub fn alloc_barricade(game : Game) -> Int {
  for i, slot in game.barricades {
    if !slot.active {
      return i
    }
  }
  -1
}

///|
/// Finds a free trap slot in the trap pool.
pub fn alloc_trap(game : Game) -> Int {
  for i, slot in game.traps {
    if !slot.active {
      return i
    }
  }
  -1
}

// Spawn particles

///|
/// Spawns a burst of generic particles around a world-space position.
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
    p.x = wx + rand_rangef(game, -0.3, 0.3)
    p.y = wy + rand_rangef(game, 0.0, 0.5)
    p.z = wz + rand_rangef(game, -0.3, 0.3)
    p.vx = rand_rangef(game, -3.0, 3.0)
    p.vy = rand_rangef(game, 1.0, 6.0)
    p.vz = rand_rangef(game, -3.0, 3.0)
    p.life = rand_rangef(game, 0.3, 0.8)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.04, 0.12)
    p.kind = Blood
    ignore(i)
  }
}

// Spawn typed particles

///|
/// Spawns particles tagged with an explicit particle kind.
pub fn spawn_particles_typed(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  count : Int,
  r : Int,
  g : Int,
  b : Int,
  kind : ParticleKind,
) -> Unit {
  for i in 0..<count {
    let idx = alloc_particle(game)
    if idx < 0 {
      return
    }
    let p = game.particles[idx]
    p.active = true
    p.x = wx + rand_rangef(game, -0.3, 0.3)
    p.y = wy + rand_rangef(game, 0.0, 0.5)
    p.z = wz + rand_rangef(game, -0.3, 0.3)
    p.vx = rand_rangef(game, -3.0, 3.0)
    p.vy = rand_rangef(game, 1.0, 6.0)
    p.vz = rand_rangef(game, -3.0, 3.0)
    p.life = rand_rangef(game, 0.3, 0.8)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.04, 0.12)
    p.kind = kind
    ignore(i)
  }
}

// Spawn directional particles (for muzzle flash etc)

///|
/// Spawns directional particles (e.g. muzzle flash streaks) biased by `(dx, dy, dz)`.
pub fn spawn_particles_dir(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  dx : Float,
  dy : Float,
  dz : Float,
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
    p.vx = dx * rand_rangef(game, 2.0, 5.0) + rand_rangef(game, -1.0, 1.0)
    p.vy = dy * rand_rangef(game, 2.0, 5.0) + rand_rangef(game, -0.5, 2.0)
    p.vz = dz * rand_rangef(game, 2.0, 5.0) + rand_rangef(game, -1.0, 1.0)
    p.life = rand_rangef(game, 0.1, 0.4)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.03, 0.08)
    p.kind = Muzzle
    ignore(i)
  }
}

// Spawn shell casing particle

///|
/// Spawns one shell-casing particle ejected to the weapon's right side.
pub fn spawn_shell_casing(
  game : Game,
  x : Float,
  y : Float,
  z : Float,
  right_x : Float,
  right_z : Float,
) -> Unit {
  let idx = alloc_particle(game)
  if idx < 0 {
    return
  }
  let p = game.particles[idx]
  p.active = true
  p.x = x + right_x * 0.3
  p.y = y - 0.1
  p.z = z + right_z * 0.3
  p.vx = right_x * rand_rangef(game, 2.0, 4.0)
  p.vy = rand_rangef(game, 1.0, 3.0)
  p.vz = right_z * rand_rangef(game, 2.0, 4.0)
  p.life = rand_rangef(game, 0.5, 1.2)
  p.max_life = p.life
  p.r = 200
  p.g = 180
  p.b = 50
  p.size = 0.04
  p.kind = Shell
}

// Check if point is inside arena bounds

///|
/// Checks whether a position lies within playable arena bounds.
pub fn in_arena(x : Float, z : Float) -> Bool {
  let half_w = arena_width / 2.0 - arena_wall_thickness
  let half_d = arena_depth / 2.0 - arena_wall_thickness
  x > -half_w && x < half_w && z > -half_d && z < half_d
}

// Clamp position to arena bounds

///|
/// Clamps a position to valid arena bounds with wall margin.
pub fn clamp_to_arena(x : Float, z : Float) -> (Float, Float) {
  let half_w = arena_width / 2.0 - arena_wall_thickness - 0.3
  let half_d = arena_depth / 2.0 - arena_wall_thickness - 0.3
  (clampf(x, -half_w, half_w), clampf(z, -half_d, half_d))
}

// Check circle vs pillar collision, return pushed position

///|
/// Resolves circle-vs-pillar overlap and returns pushed position plus collision flag.
pub fn push_from_pillar(
  x : Float,
  z : Float,
  radius : Float,
  px : Float,
  pz : Float,
  pradius : Float,
) -> (Float, Float, Bool) {
  let dx = x - px
  let dz = z - pz
  let dist = @math.hypotf(dx, dz)
  let min_dist = radius + pradius
  if dist < min_dist && dist > 0.001 {
    let push = min_dist - dist
    let nx = dx / dist
    let nz = dz / dist
    (x + nx * push, z + nz * push, true)
  } else {
    (x, z, false)
  }
}

// Check circle vs box collision (for low walls, barricades)

///|
/// Resolves circle-vs-box overlap and returns pushed position plus collision flag.
pub fn push_from_box(
  x : Float,
  z : Float,
  radius : Float,
  bx : Float,
  bz : Float,
  bw : Float,
  bd : Float,
) -> (Float, Float, Bool) {
  let half_w = bw / 2.0
  let half_d = bd / 2.0
  // Find closest point on box to circle
  let closest_x = clampf(x, bx - half_w, bx + half_w)
  let closest_z = clampf(z, bz - half_d, bz + half_d)
  let dx = x - closest_x
  let dz = z - closest_z
  let dist = @math.hypotf(dx, dz)
  if dist < radius && dist > 0.001 {
    let push = radius - dist
    let nx = dx / dist
    let nz = dz / dist
    (x + nx * push, z + nz * push, true)
  } else if dist < 0.001 &&
    (x - bx).abs() < half_w + radius &&
    (z - bz).abs() < half_d + radius {
    // Inside the box, push out on nearest edge
    let dx_edge = half_w + radius - (x - bx).abs()
    let dz_edge = half_d + radius - (z - bz).abs()
    if dx_edge < dz_edge {
      let push_dir = sign(x - bx)
      (x + push_dir * dx_edge, z, true)
    } else {
      let push_dir = sign(z - bz)
      (x, z + push_dir * dz_edge, true)
    }
  } else {
    (x, z, false)
  }
}

// Weapon name

///|
/// Returns full display name for weapon type id.
pub fn weapon_name(kind : Int) -> String {
  match WeaponKind::from_int(kind) {
    Pistol => "Pistol"
    Shotgun => "Shotgun"
    Rifle => "Rifle"
    Sniper => "Sniper"
    Rocket => "Rocket"
    Minigun => "Minigun"
  }
}

// Weapon short name for UI slots

// Weapon fire rate (base)

///|
/// Returns base fire interval (seconds between shots) for a weapon type.
pub fn weapon_fire_rate(kind : Int) -> Float {
  match WeaponKind::from_int(kind) {
    Pistol => rate_pistol
    Shotgun => rate_shotgun
    Rifle => rate_rifle
    Sniper => rate_sniper
    Rocket => rate_rocket
    Minigun => rate_minigun
  }
}

// Weapon damage (base)

///|
/// Returns base damage for a weapon type.
pub fn weapon_damage(kind : Int) -> Float {
  match WeaponKind::from_int(kind) {
    Pistol => dmg_pistol
    Shotgun => dmg_shotgun
    Rifle => dmg_rifle
    Sniper => dmg_sniper
    Rocket => dmg_rocket
    Minigun => dmg_minigun
  }
}

// Weapon projectile speed

///|
/// Returns base projectile speed for a weapon type.
pub fn weapon_proj_speed(kind : Int) -> Float {
  match WeaponKind::from_int(kind) {
    Pistol => speed_pistol
    Shotgun => speed_shotgun
    Rifle => speed_rifle
    Sniper => speed_sniper
    Rocket => speed_rocket
    Minigun => speed_minigun
  }
}

// Weapon reload time (base)

///|
/// Returns base reload time for a weapon type.
pub fn weapon_reload_time(kind : Int) -> Float {
  match WeaponKind::from_int(kind) {
    Pistol => reload_pistol
    Shotgun => reload_shotgun
    Rifle => reload_rifle
    Sniper => reload_sniper
    Rocket => reload_rocket
    Minigun => reload_minigun
  }
}

// Weapon magazine size (base)

///|
/// Returns base magazine size for a weapon type.
pub fn weapon_mag_size(kind : Int) -> Int {
  match WeaponKind::from_int(kind) {
    Pistol => mag_pistol
    Shotgun => mag_shotgun
    Rifle => mag_rifle
    Sniper => mag_sniper
    Rocket => mag_rocket
    Minigun => mag_minigun
  }
}

// Get effective fire rate with upgrades

///|
/// Returns player-adjusted fire interval after weapon upgrades.
pub fn effective_fire_rate(player : Player, kind : Int) -> Float {
  let base = weapon_fire_rate(kind)
  let lvl = Float::from_int(player.weapon_rate_level[kind])
  let mult : Float = 1.0 - lvl * 0.12
  base * mult
}

// Get effective damage with upgrades and boosts

///|
/// Returns effective damage after upgrades and temporary buffs.
pub fn effective_damage(player : Player, kind : Int) -> Float {
  let base = weapon_damage(kind)
  let lvl = Float::from_int(player.weapon_damage_level[kind])
  let upgrade_mult : Float = 1.0 + lvl * 0.2
  let boost_mult : Float = if player.damage_boost_timer > 0.0 {
    1.5
  } else {
    1.0
  }
  base * upgrade_mult * player.damage_mult * boost_mult
}

// Get effective magazine size with upgrades

///|
/// Returns effective magazine size after magazine upgrades.
pub fn effective_mag_size(player : Player, kind : Int) -> Int {
  let base = weapon_mag_size(kind)
  let lvl = player.weapon_mag_level[kind]
  let bonus_f : Float = Float::from_int(base) * Float::from_int(lvl) * 0.3
  base + bonus_f.to_int()
}

// Enemy name

// Pickup name

// Count active enemies

///|
/// Counts currently active enemies in the arena.
pub fn count_active_enemies(game : Game) -> Int {
  let mut count = 0
  for enemy in game.enemies {
    if enemy.active {
      count += 1
    }
  }
  count
}

// Show temporary message

///|
/// Displays a temporary center-screen message for `duration` seconds.
pub fn show_message(game : Game, text : String, duration : Float) -> Unit {
  game.message_text = text
  game.message_timer = duration
}

// Add kill feed entry

///|
/// Pushes a new line into the kill feed and shifts older entries down.
pub fn add_kill_feed(
  game : Game,
  text : String,
  r : Int,
  g : Int,
  b : Int,
) -> Unit {
  // Shift existing entries down
  for i = max_kill_feed - 1; i > 0; i = i - 1 {
    let prev = i - 1
    game.kill_feed[i].active = game.kill_feed[prev].active
    game.kill_feed[i].text = game.kill_feed[prev].text
    game.kill_feed[i].timer = game.kill_feed[prev].timer
    game.kill_feed[i].color_r = game.kill_feed[prev].color_r
    game.kill_feed[i].color_g = game.kill_feed[prev].color_g
    game.kill_feed[i].color_b = game.kill_feed[prev].color_b
  }
  game.kill_feed[0].active = true
  game.kill_feed[0].text = text
  game.kill_feed[0].timer = kill_feed_duration
  game.kill_feed[0].color_r = r
  game.kill_feed[0].color_g = g
  game.kill_feed[0].color_b = b
}

// Update kill feed timers

///|
/// Advances and expires kill-feed entry timers.
pub fn update_kill_feed(game : Game, dt : Float) -> Unit {
  for i in 0..<max_kill_feed {
    if game.kill_feed[i].active {
      game.kill_feed[i].timer -= dt
      if game.kill_feed[i].timer <= 0.0 {
        game.kill_feed[i].active = false
      }
    }
  }
}

// Update damage indicators

///|
/// Advances and expires directional damage indicator timers.
pub fn update_damage_indicators(game : Game, dt : Float) -> Unit {
  for damage_indicator in game.damage_indicators {
    if damage_indicator.active {
      damage_indicator.timer -= dt
      if damage_indicator.timer <= 0.0 {
        damage_indicator.active = false
      }
    }
  }
}

// Add damage indicator from a direction

///|
/// Adds a directional damage indicator pointing from attacker to player.
pub fn add_damage_indicator(
  game : Game,
  from_x : Float,
  from_z : Float,
) -> Unit {
  let angle = @math.atan2f(from_z - game.player.z, from_x - game.player.x)
  // Find inactive slot
  for damage_indicator in game.damage_indicators {
    if not(damage_indicator.active) {
      damage_indicator.active = true
      damage_indicator.angle = angle - game.player.yaw
      damage_indicator.timer = 1.0
      return
    }
  }
  // Overwrite oldest
  game.damage_indicators[0].active = true
  game.damage_indicators[0].angle = angle - game.player.yaw
  game.damage_indicators[0].timer = 1.0
}

// Check if a hit is a headshot based on projectile Y vs enemy center

///|
/// Returns whether projectile Y intercept falls in the enemy head region.
pub fn is_headshot_hit(
  proj_y : Float,
  enemy_y : Float,
  enemy_size : Float,
) -> Bool {
  let head_threshold = enemy_y + enemy_size * (1.0 - headshot_head_ratio)
  proj_y > head_threshold
}

// Get combo multiplier text

// Collision push against barricades

///|
/// Applies collision pushes against all active barricades and returns resolved position.
pub fn push_from_barricades(
  game : Game,
  x : Float,
  z : Float,
  radius : Float,
) -> (Float, Float) {
  let mut rx = x
  let mut rz = z
  for b in game.barricades {
    if not(b.active) {
      continue
    }
    let result = push_from_box(
      rx,
      rz,
      radius,
      b.x,
      b.z,
      barricade_size,
      barricade_size,
    )
    rx = result.0
    rz = result.1
  }
  (rx, rz)
}

// Collision push against low walls

///|
/// Applies collision pushes against all low-wall obstacles and returns resolved position.
pub fn push_from_low_walls(
  game : Game,
  x : Float,
  z : Float,
  radius : Float,
) -> (Float, Float) {
  let mut rx = x
  let mut rz = z
  for w in game.low_walls {
    let result = push_from_box(rx, rz, radius, w.x, w.z, w.width, w.depth)
    rx = result.0
    rz = result.1
  }
  (rx, rz)
}
