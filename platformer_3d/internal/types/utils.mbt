///|
/// Clamps a float into the inclusive range `[low, high]`.
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
/// Linearly interpolates from `a` to `b` using parameter `t`.
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
/// Computes Euclidean distance in the XZ plane.
pub fn dist2d(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  @math.hypotf(x1 - x2, z1 - z2)
}

///|
/// Computes Euclidean distance in 3D space.
pub fn dist3d(
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

// Smoothstep interpolation (cubic ease in/out)

///|
/// Applies smoothstep interpolation between two edges.
pub fn smoothstep(edge0 : Float, edge1 : Float, x : Float) -> Float {
  let t = clampf((x - edge0) / (edge1 - edge0), 0.0, 1.0)
  t * t * (3.0 - 2.0 * t)
}

// Ease-in quadratic

// Ease-out quadratic

// Ease-in-out quadratic

// Ease-out bounce

// Ease-out elastic (simplified)

// Move toward value

// Wrap angle to 0..360

// Normalize a 2D vector, returning (nx, nz, length)

// Dot product 2d

// Dot product 3d

// Reflect 2d vector off normal

// AABB overlap check

// Sphere-AABB overlap

///|
/// Tests overlap between a sphere and an axis-aligned 3D box.
pub fn sphere_aabb(
  sx : Float,
  sy : Float,
  sz : Float,
  sr : Float,
  bx : Float,
  by : Float,
  bz : Float,
  bw : Float,
  bh : Float,
  bd : Float,
) -> Bool {
  let closest_x = clampf(sx, bx - bw / 2.0, bx + bw / 2.0)
  let closest_y = clampf(sy, by - bh / 2.0, by + bh / 2.0)
  let closest_z = clampf(sz, bz - bd / 2.0, bz + bd / 2.0)
  let dx = sx - closest_x
  let dy = sy - closest_y
  let dz = sz - closest_z
  dx * dx + dy * dy + dz * dz < sr * sr
}

// Check if point is above a platform (for shadow casting)

///|
/// Returns whether an XZ point falls within a platform footprint.
pub fn point_above_platform(
  px : Float,
  pz : Float,
  bx : Float,
  bz : Float,
  bw : Float,
  bd : Float,
) -> Bool {
  px > bx - bw / 2.0 &&
  px < bx + bw / 2.0 &&
  pz > bz - bd / 2.0 &&
  pz < bz + bd / 2.0
}

// Find highest platform below a point (for shadow y)

///|
/// Finds the highest platform top below a point for projected shadow placement.
pub fn find_shadow_y(game : Game, px : Float, py : Float, pz : Float) -> Float {
  let mut best_y : Float = -25.0
  for plat in game.platforms {
    if !plat.active {
      continue
    }
    if point_above_platform(px, pz, plat.x, plat.z, plat.w, plat.d) {
      let top = plat.y + plat.h / 2.0
      if top < py && top > best_y {
        best_y = top
      }
    }
  }
  best_y
}

// Calculate shadow alpha based on height above surface

///|
/// Computes shadow alpha (0-255) from vertical distance to the support surface.
pub fn shadow_alpha(py : Float, shadow_y : Float) -> Int {
  let height = py - shadow_y
  if height < 0.0 {
    return 0
  }
  if height > shadow_max_height {
    return shadow_min_alpha
  }
  let ratio : Float = height / shadow_max_height
  let t : Float = 1.0 - ratio
  let min_f : Float = Float::from_int(shadow_min_alpha)
  let range_f : Float = Float::from_int(shadow_max_alpha - shadow_min_alpha)
  let alpha_f : Float = min_f + t * range_f
  alpha_f.to_int().clamp(min=shadow_min_alpha, max=shadow_max_alpha)
}

// Calculate shadow size based on height

///|
/// Computes a shadow scale factor from vertical distance to the support surface.
pub fn shadow_scale(py : Float, shadow_y : Float) -> Float {
  let height = py - shadow_y
  if height < 0.0 {
    return shadow_size_base
  }
  let t = clampf(height / shadow_max_height, 0.0, 1.0)
  shadow_size_base * (1.0 - t * 0.5)
}

///|
/// Returns the first inactive particle slot index, or `-1` if full.
pub fn alloc_particle(game : Game) -> Int {
  for i, slot in game.particles {
    if !slot.active {
      return i
    }
  }
  -1
}

///|
/// Spawns a burst of particles at world position with random spread and velocity.
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
    p.y = wy + rand_rangef(game, 0.0, 0.4)
    p.z = wz + rand_rangef(game, -0.3, 0.3)
    p.vx = rand_rangef(game, -2.0, 2.0)
    p.vy = rand_rangef(game, 1.5, 5.0)
    p.vz = rand_rangef(game, -2.0, 2.0)
    p.life = rand_rangef(game, 0.3, 0.8)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.04, 0.1)
    p.kind = 0
    ignore(i)
  }
}

// Spawn directional particles (e.g., for wall slide)

///|
/// Spawns particles biased toward a direction with configurable spread.
pub fn spawn_particles_dir(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  count : Int,
  dvx : Float,
  dvy : Float,
  dvz : Float,
  spread : Float,
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
    p.x = wx + rand_rangef(game, -0.15, 0.15)
    p.y = wy + rand_rangef(game, -0.15, 0.15)
    p.z = wz + rand_rangef(game, -0.15, 0.15)
    p.vx = dvx + rand_rangef(game, -spread, spread)
    p.vy = dvy + rand_rangef(game, -spread, spread)
    p.vz = dvz + rand_rangef(game, -spread, spread)
    p.life = rand_rangef(game, 0.2, 0.6)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.03, 0.08)
    p.kind = 0
    ignore(i)
  }
}

// Spawn ring of particles (for power-up aura, checkpoint activation)

///|
/// Spawns particles distributed around a ring centered at world position.
pub fn spawn_particle_ring(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  count : Int,
  radius : Float,
  speed : Float,
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
    let angle = Float::from_int(i) / Float::from_int(count) * two_pi
    p.active = true
    p.x = wx + @math.cosf(angle) * radius
    p.y = wy
    p.z = wz + @math.sinf(angle) * radius
    p.vx = @math.cosf(angle) * speed
    p.vy = rand_rangef(game, 1.0, 3.0)
    p.vz = @math.sinf(angle) * speed
    p.life = rand_rangef(game, 0.4, 0.8)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.05, 0.12)
    p.kind = 0
    ignore(i)
  }
}

// Allocate enemy slot

// Allocate projectile slot

///|
/// Returns the first inactive projectile slot index, or `-1` if full.
pub fn alloc_projectile(game : Game) -> Int {
  for i, slot in game.projectiles {
    if !slot.active {
      return i
    }
  }
  -1
}

// Allocate score fly slot

// Spawn a score fly text

// Add score with combo

///|
/// Adds score using the current combo multiplier and refreshes combo timing.
pub fn add_score(game : Game, base : Int) -> Unit {
  let mult_score = Float::from_int(base) * game.combo_mult
  game.score = game.score + mult_score.to_int()
  game.combo_count += 1
  game.combo_timer = combo_decay_time
  game.combo_mult = minf(
    combo_base_mult + Float::from_int(game.combo_count) * combo_increment,
    combo_max,
  )
}

// Camera shake trigger

///|
/// Starts or refreshes camera shake with intensity and duration.
pub fn trigger_cam_shake(
  game : Game,
  intensity : Float,
  duration : Float,
) -> Unit {
  game.cam_shake = intensity
  game.cam_shake_timer = duration
}

// RNG

///|
/// Advances the game RNG state and returns the next pseudo-random integer.
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
/// Returns a random integer in the inclusive range `[low, high]`.
pub fn rand_range(game : Game, low : Int, high : Int) -> Int {
  if high <= low {
    low
  } else {
    low + rand_next(game) % (high - low + 1)
  }
}

///|
/// Returns a random float in the range `[low, high]`.
pub fn rand_rangef(game : Game, low : Float, high : Float) -> Float {
  let n = Float::from_int(rand_next(game) % 10000) / 10000.0
  low + (high - low) * n
}

// Map a value from one range to another

// Approach float value at a given speed

// Color lerp helper (returns int 0-255)

// Pulse helper: returns 0..1 with sine wave

///|
/// Returns a normalized sine pulse in the range `0..1`.
pub fn pulse(timer : Float, speed : Float) -> Float {
  (@math.sinf(timer * speed) + 1.0) * 0.5
}

// Flash helper: returns true for on_time, false for off_time

// Calculate star rating for level completion

///|
/// Calculates a 1-3 star completion rating from time, gem completion, and deaths.
pub fn calc_stars(
  time : Float,
  gems : Int,
  total_gems : Int,
  deaths : Int,
) -> Int {
  let mut stars = 1
  if deaths == 0 {
    stars = stars + 1
  }
  if gems == total_gems && time < star_time_threshold_1 {
    stars = stars + 1
  }
  if stars > 3 {
    stars = 3
  }
  stars
}

///|
/// Converts an integer decoration kind to the corresponding Deco enum value.
pub fn deco_from_int(v : Int) -> Deco {
  match v {
    0 => Tree
    1 => Rock
    2 => Crystal
    3 => Mushroom
    4 => Pillar
    5 => Stalagmite
    6 => LavaRock
    7 => Cloud
    8 => Bush
    9 => Lamp
    _ => Tree
  }
}
