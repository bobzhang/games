///|
/// Returns the integer index for a Theme value.
pub fn theme_to_int(t : Theme) -> Int {
  match t {
    Circuit => 0
    Beach => 1
    Mountain => 2
    Castle => 3
    Desert => 4
    ThemeIce => 5
    Night => 6
    Volcano => 7
  }
}

///|
/// Returns a PowerupKind from its integer index.
pub fn powerup_kind_from_int(i : Int) -> PowerupKind {
  match i {
    1 => Boost
    2 => Shield
    3 => Missile
    4 => OilSlick
    5 => Lightning
    6 => Star
    7 => Banana
    8 => TripleMushroom
    _ => NoPowerup
  }
}

///|
/// Returns the integer rank for a DriftLevel value (for ordering comparisons).
pub fn drift_level_to_int(level : DriftLevel) -> Int {
  match level {
    DriftNone => 0
    Mini => 1
    Super => 2
    Ultra => 3
  }
}

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
/// Returns the smaller of `a` and `b`.
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
/// Returns the linear interpolation from `a` to `b` by factor `t`.
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
/// Returns the 2D Euclidean distance between two points on the XZ plane.
pub fn distance2d(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  @math.hypotf(x1 - x2, z1 - z2)
}

// Normalize angle to [-PI, PI]

///|
/// Returns the angle normalized to the range negative pi to pi.
pub fn normalize_angle(a : Float) -> Float {
  let mut result = a
  for _i in 0..<10 {
    if result > pi {
      result = result - two_pi
    } else if result < -pi {
      result = result + two_pi
    } else {
      break
    }
  }
  result
}

// Angle difference (shortest path)

///|
/// Returns the shortest signed angular difference from `from` to `to`.
pub fn angle_diff(from : Float, to : Float) -> Float {
  normalize_angle(to - from)
}

// Get angle from point a to point b

// Dot product of 2D vectors

// Cross product magnitude of 2D vectors (useful for determining side)

// Project point onto line segment, return parameter t [0,1]

// Get distance from point to line segment

// Get the surface grip multiplier

///|
/// Returns the grip multiplier for the given `surface` type.
pub fn get_surface_grip(surface : Surface) -> Float {
  match surface {
    Road => grip_road
    Dirt => grip_dirt
    Grass => grip_grass
    BoostPad => grip_boost_pad
    Oil => grip_oil
    SurfaceIce => grip_ice
  }
}

// Get the surface speed multiplier

///|
/// Returns the top speed multiplier for the given `surface` type.
pub fn get_surface_speed_mult(surface : Surface) -> Float {
  match surface {
    Road => speed_mult_road
    Dirt => speed_mult_dirt
    Grass => speed_mult_grass
    BoostPad => speed_mult_boost_pad
    Oil => speed_mult_oil
    SurfaceIce => speed_mult_ice
  }
}

// Get the drift boost power for a level

///|
/// Returns the speed bonus for the given drift boost `level`.
pub fn get_drift_boost_power(level : DriftLevel) -> Float {
  match level {
    Mini => drift_mini_boost
    Super => drift_super_boost
    Ultra => drift_ultra_boost
    DriftNone => 0.0
  }
}

// Get the drift boost duration for a level

///|
/// Returns the duration in seconds for the given drift boost `level`.
pub fn get_drift_boost_duration(level : DriftLevel) -> Float {
  match level {
    Mini => drift_mini_duration
    Super => drift_super_duration
    Ultra => drift_ultra_duration
    DriftNone => 0.0
  }
}

// Calculate drift level based on time

///|
/// Returns the drift boost level achieved after `drift_time` seconds of sustained drift.
pub fn calc_drift_level(drift_time : Float) -> DriftLevel {
  if drift_time >= drift_ultra_threshold {
    Ultra
  } else if drift_time >= drift_super_threshold {
    Super
  } else if drift_time >= drift_mini_threshold {
    Mini
  } else {
    DriftNone
  }
}

// Get drift spark color based on level (r, g, b)

///|
/// Returns the RGB color for drift spark particles at the given drift `level`.
pub fn get_drift_spark_color(level : DriftLevel) -> (Int, Int, Int) {
  match level {
    Mini => (80, 150, 255) // Blue
    Super => (255, 180, 50) // Orange
    Ultra => (255, 80, 200) // Pink
    DriftNone => (200, 200, 200) // Default gray
  }
}

// Get kart max speed based on type and surface

///|
/// Returns the effective maximum speed for `kart` considering type, surface, and active effects.
pub fn get_kart_max_speed(kart : Kart) -> Float {
  let stats = kart_stats[kart.kart_type.clamp(min=0, max=kart_type_count - 1)]
  let base_speed = stats.0
  let surface_mult = get_surface_speed_mult(kart.on_surface_type)
  let mut result : Float = base_speed * surface_mult
  if kart.boost_timer > 0.0 {
    result = result + kart.boost_power
  }
  if kart.star_timer > 0.0 {
    result = result + star_speed_add
  }
  if kart.lightning_timer > 0.0 {
    result = result * lightning_slow_mult
  }
  result
}

// Get kart acceleration based on type

///|
/// Returns the acceleration stat for `kart` based on its type.
pub fn get_kart_accel(kart : Kart) -> Float {
  let stats = kart_stats[kart.kart_type.clamp(min=0, max=kart_type_count - 1)]
  stats.1
}

// Get kart handling based on type

///|
/// Returns the effective handling for `kart` adjusted by surface grip.
pub fn get_kart_handling(kart : Kart) -> Float {
  let stats = kart_stats[kart.kart_type.clamp(min=0, max=kart_type_count - 1)]
  let grip = get_surface_grip(kart.on_surface_type)
  stats.2 * grip
}

// Get kart weight

///|
/// Returns the weight stat for `kart` based on its type.
pub fn get_kart_weight(kart : Kart) -> Float {
  let stats = kart_stats[kart.kart_type.clamp(min=0, max=kart_type_count - 1)]
  stats.3
}

// Get kart drift boost multiplier

///|
/// Returns the drift boost multiplier for `kart` based on its type.
pub fn get_kart_drift_boost_mult(kart : Kart) -> Float {
  let stats = kart_stats[kart.kart_type.clamp(min=0, max=kart_type_count - 1)]
  stats.4
}

// RNG

///|
/// Advances the game RNG state and returns the next pseudorandom positive integer.
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
/// Returns a random integer in the inclusive range from `low` to `high`.
pub fn rand_range(game : Game, low : Int, high : Int) -> Int {
  if high <= low {
    low
  } else {
    low + rand_next(game) % (high - low + 1)
  }
}

///|
/// Returns a random float in the range from `low` to `high`.
pub fn rand_rangef(game : Game, low : Float, high : Float) -> Float {
  let n = Float::from_int(rand_next(game) % 10000) / 10000.0
  low + (high - low) * n
}

// Allocators

///|
/// Returns the index of the first inactive projectile slot, or -1 if full.
pub fn alloc_projectile(game : Game) -> Int {
  for i, slot in game.projectiles {
    if !slot.active {
      return i
    }
  }
  -1
}

///|
/// Returns the index of the first inactive particle slot, or -1 if full.
pub fn alloc_particle(game : Game) -> Int {
  for i, slot in game.particles {
    if !slot.active {
      return i
    }
  }
  -1
}

///|
/// Returns the index of the first inactive dropped item slot, or -1 if full.
pub fn alloc_dropped_item(game : Game) -> Int {
  for i, slot in game.dropped_items {
    if !slot.active {
      return i
    }
  }
  -1
}

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
    p.particle_type = particle_explosion
    p.x = wx + rand_rangef(game, -0.3, 0.3)
    p.y = wy + rand_rangef(game, 0.0, 0.5)
    p.z = wz + rand_rangef(game, -0.3, 0.3)
    p.vx = rand_rangef(game, -2.0, 2.0)
    p.vy = rand_rangef(game, 1.0, 5.0)
    p.vz = rand_rangef(game, -2.0, 2.0)
    p.life = rand_rangef(game, 0.3, 0.8)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.04, 0.1)
    ignore(i)
  }
}

// Spawn typed particles

///|
/// Spawns particles of the given `ptype` at the specified position with custom color, size, and lifespan.
pub fn spawn_typed_particles(
  game : Game,
  ptype : Int,
  wx : Float,
  wy : Float,
  wz : Float,
  count : Int,
  r : Int,
  g : Int,
  b : Int,
  size : Float,
  life : Float,
) -> Unit {
  for i in 0..<count {
    let idx = alloc_particle(game)
    if idx < 0 {
      return
    }
    let p = game.particles[idx]
    p.active = true
    p.particle_type = ptype
    p.x = wx + rand_rangef(game, -0.2, 0.2)
    p.y = wy + rand_rangef(game, 0.0, 0.3)
    p.z = wz + rand_rangef(game, -0.2, 0.2)
    p.vx = rand_rangef(game, -1.5, 1.5)
    p.vy = rand_rangef(game, 0.5, 3.0)
    p.vz = rand_rangef(game, -1.5, 1.5)
    p.life = life + rand_rangef(game, -0.1, 0.1)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = size + rand_rangef(game, -0.01, 0.01)
    ignore(i)
  }
}

// Get waypoint with wrap-around

///|
/// Returns the waypoint at `idx` with wrap-around for looping tracks.
pub fn get_waypoint(game : Game, idx : Int) -> Waypoint {
  let wc = game.waypoint_count
  if wc == 0 {
    return { x: 0.0, y: 0.0, z: 0.0 }
  }
  let mut i = idx % wc
  if i < 0 {
    i = i + wc
  }
  game.waypoints[i]
}

// Get track segment with wrap-around

///|
/// Returns the track segment at `idx` with wrap-around for looping tracks.
pub fn get_segment(game : Game, idx : Int) -> TrackSegment {
  let wc = game.waypoint_count
  if wc == 0 {
    return TrackSegment::default()
  }
  let mut i = idx % wc
  if i < 0 {
    i = i + wc
  }
  game.segments[i]
}

// Calculate kart's total progress for ranking

///|
/// Returns the total race progress for `kart` used for position ranking.
pub fn calc_total_progress(kart : Kart, waypoint_count : Int) -> Float {
  Float::from_int(kart.lap * waypoint_count + kart.waypoint_idx) +
  kart.waypoint_progress
}

// Points for finishing position

///|
/// Returns the cup points awarded for the given finishing `place`.
pub fn position_points(place : Int) -> Int {
  if place >= 1 && place <= cup_points_table.length() {
    cup_points_table[place - 1]
  } else {
    1
  }
}

// Check if kart is near a jump ramp segment

///|
/// Returns whether `kart` is on a jump ramp segment.
pub fn is_on_ramp(game : Game, kart : Kart) -> Bool {
  let wc = game.waypoint_count
  if wc < 2 {
    return false
  }
  let seg = get_segment(game, kart.waypoint_idx)
  seg.is_ramp
}

// Get surface type at kart position based on distance from track center

///|
/// Returns the surface type at position (`x`, `z`) based on distance from the nearest track segment.
pub fn detect_surface_type(game : Game, x : Float, z : Float) -> Surface {
  let wc = game.waypoint_count
  if wc < 2 {
    return Road
  }
  // Find nearest segment
  let mut best_dist : Float = 99999.0
  let mut best_seg = 0
  for i in 0..<wc {
    let wp = game.waypoints[i]
    let d = distance2d(x, z, wp.x, wp.z)
    if d < best_dist {
      best_dist = d
      best_seg = i
    }
  }
  // Check segment surface type
  let seg = game.segments[best_seg]
  // If within road width, use segment surface
  if best_dist < road_half * seg.width_mult {
    // Check for boost pad or special surface
    if seg.surface_type != Road {
      return seg.surface_type
    }
    return Road
  }
  // Slightly off road - dirt
  if best_dist < road_half * seg.width_mult + 2.0 {
    return Dirt
  }
  // Far off road - grass
  Grass
}

// Detect wrong way: check if kart heading is opposite to track direction

///|
/// Returns whether `kart` is facing the wrong way relative to the track direction.
pub fn is_wrong_way(game : Game, kart : Kart) -> Bool {
  let wc = game.waypoint_count
  if wc < 2 {
    return false
  }
  let cur = get_waypoint(game, kart.waypoint_idx)
  let nxt = get_waypoint(game, (kart.waypoint_idx + 1) % wc)
  let track_angle = @math.atan2f(nxt.x - cur.x, nxt.z - cur.z)
  let diff = angle_diff(kart.angle, track_angle).abs()
  diff > wrong_way_angle_threshold
}

// Find nearest opponent ahead of the given kart (for homing missiles)

///|
/// Returns the index of the nearest opponent ahead of `kart_idx`, or the nearest behind if none ahead.
pub fn find_target_ahead(game : Game, kart_idx : Int) -> Int {
  let kart = game.karts[kart_idx]
  let mut best_idx = -1
  let mut best_dist : Float = 99999.0
  for i in 0..<max_karts {
    if i == kart_idx {
      continue
    }
    let other = game.karts[i]
    if !other.active || other.finished {
      continue
    }
    if other.total_progress <= kart.total_progress {
      continue
    }
    let d = distance2d(kart.x, kart.z, other.x, other.z)
    if d < best_dist {
      best_dist = d
      best_idx = i
    }
  }
  // If nobody is ahead, target nearest behind
  if best_idx < 0 {
    for i in 0..<max_karts {
      if i == kart_idx {
        continue
      }
      let other = game.karts[i]
      if !other.active || other.finished {
        continue
      }
      let d = distance2d(kart.x, kart.z, other.x, other.z)
      if d < best_dist {
        best_dist = d
        best_idx = i
      }
    }
  }
  best_idx
}

// Find nearest opponent behind the given kart

// Get item probability weights based on race position (better items when further behind)

// Pick a random powerup based on position weights

// Calculate rubber-band speed multiplier for AI

///|
/// Returns the AI speed multiplier adjusted by rubber-banding based on progress relative to the player.
pub fn calc_rubber_band_mult(
  ai_progress : Float,
  player_progress : Float,
  difficulty : Int,
) -> Float {
  let stats = ai_difficulty_stats[difficulty.clamp(min=0, max=3)]
  let base_mult = stats.0
  let progress_diff = ai_progress - player_progress
  let mut mult = base_mult
  if progress_diff < -8.0 {
    mult = mult + ai_rubberband_behind * 3.0
  } else if progress_diff < -3.0 {
    mult = mult + ai_rubberband_behind * 2.0
  } else if progress_diff < 0.0 {
    mult = mult + ai_rubberband_behind
  } else if progress_diff > 8.0 {
    mult = mult - ai_rubberband_ahead * 3.0
  } else if progress_diff > 3.0 {
    mult = mult - ai_rubberband_ahead * 2.0
  } else if progress_diff > 0.0 {
    mult = mult - ai_rubberband_ahead
  }
  clampf(mult, 0.7, 1.15)
}

// Format time as string "MM:SS.ms"

///|
/// Returns a formatted time string from seconds as "MM:SS.ms" or "SS.ms".
pub fn format_time(t : Float) -> String {
  let total_secs = t.to_int()
  let mins = total_secs / 60
  let secs = total_secs % 60
  let frac = t - Float::from_int(total_secs)
  let ms = (frac * 100.0).to_int()
  if mins > 0 {
    "\{mins}:\{secs}.\{ms}"
  } else {
    "\{secs}.\{ms}"
  }
}

// Get ordinal suffix for position (1st, 2nd, 3rd, etc.)

///|
/// Returns the ordinal string for position `n` such as "1st" or "3rd".
pub fn ordinal_suffix(n : Int) -> String {
  if n == 1 {
    "1st"
  } else if n == 2 {
    "2nd"
  } else if n == 3 {
    "3rd"
  } else {
    "\{n}th"
  }
}

// Track spline interpolation: get position at progress along segment

// Get track direction vector at a segment

///|
/// Returns the normalized track direction vector on the XZ plane at `seg_idx`.
pub fn get_track_direction(game : Game, seg_idx : Int) -> (Float, Float) {
  let wc = game.waypoint_count
  if wc < 2 {
    return (0.0, 1.0)
  }
  let wp0 = get_waypoint(game, seg_idx)
  let wp1 = get_waypoint(game, (seg_idx + 1) % wc)
  let dx = wp1.x - wp0.x
  let dz = wp1.z - wp0.z
  let d = distance2d(wp0.x, wp0.z, wp1.x, wp1.z)
  if d < 0.01 {
    return (0.0, 1.0)
  }
  (dx / d, dz / d)
}

// Get perpendicular direction to track at a segment

///|
/// Returns the perpendicular direction to the track on the XZ plane at `seg_idx`.
pub fn get_track_perpendicular(game : Game, seg_idx : Int) -> (Float, Float) {
  let dir = get_track_direction(game, seg_idx)
  (-dir.1, dir.0)
}

// Calculate weight-based bump force between two karts

///|
/// Returns the normalized bump force pair for two karts based on their weights.
pub fn calc_bump_force(weight_a : Float, weight_b : Float) -> (Float, Float) {
  let total = weight_a + weight_b
  if total < 0.01 {
    return (0.5, 0.5)
  }
  // Lighter kart gets pushed more
  let force_a = weight_b / total
  let force_b = weight_a / total
  (force_a, force_b)
}

// Check if two karts should trigger a spin based on weight difference

///|
/// Returns whether each kart should spin from a bump based on their weight difference.
pub fn should_spin_from_bump(
  weight_a : Float,
  weight_b : Float,
) -> (Bool, Bool) {
  let diff = (weight_a - weight_b).abs()
  if diff >= weight_spin_diff {
    if weight_a < weight_b {
      (true, false) // a spins, b doesn't
    } else {
      (false, true) // b spins, a doesn't
    }
  } else {
    (false, false) // neither spins
  }
}
