///|
/// Returns the absolute value of a float.
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
/// Clamps a float to the inclusive range `[low, high]`.
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
/// Clamps an integer to the inclusive range `[low, high]`.
pub fn clampi(v : Int, low : Int, high : Int) -> Int {
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
/// Returns the smaller of two integer values.
pub fn mini(a : Int, b : Int) -> Int {
  a.min(b)
}

///|
/// Returns the larger of two integer values.
pub fn maxi(a : Int, b : Int) -> Int {
  a.max(b)
}

///|
/// Linearly interpolates from `a` to `b` by parameter `t`.
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
/// Computes Euclidean distance in the XZ plane.
pub fn distance2d(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  let dx = x1 - x2
  let dz = z1 - z2
  (dx * dx + dz * dz).sqrt()
}

///|
/// Computes Euclidean distance in 3D space.
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
/// Normalizes an angle in radians to the `[-pi, pi]` range.
pub fn normalize_angle(a : Float) -> Float {
  let mut angle = a
  for _i in 0..<10 {
    if angle > pi {
      angle = angle - 2.0 * pi
    } else if angle < -pi {
      angle = angle + 2.0 * pi
    } else {
      break
    }
  }
  angle
}

///|
/// Returns shortest signed angular difference from `a` to `b`.
pub fn angle_diff(a : Float, b : Float) -> Float {
  normalize_angle(b - a)
}

// Calculate bearing from one point to another

///|
/// Returns bearing angle in radians from `(x1, z1)` to `(x2, z2)`.
pub fn bearing(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  @math.atan2f(x2 - x1, z2 - z1)
}

// Check if angle b is within +/- range of angle a

///|
/// Returns whether angle `b` is within `range` radians of angle `a`.
pub fn angle_within(a : Float, b : Float, range : Float) -> Bool {
  absf(angle_diff(a, b)) < range
}

// Sailing speed calculator - wind-based
// Takes ship heading, wind direction, wind speed, sail amount, sail state, mast hp ratio

///|
/// Computes effective sailing speed from heading, wind, sail trim, and mast condition.
pub fn calc_sailing_speed(
  heading : Float,
  wind_dir : Float,
  wind_speed : Float,
  sail_amount : Float,
  mast_hp_ratio : Float,
  base_speed : Float,
) -> Float {
  // Calculate relative wind angle (0 = headwind, pi = tailwind)
  let rel_wind = absf(angle_diff(heading, wind_dir))
  // Point of sail coefficient
  let point_of_sail : Float = if rel_wind < in_irons_angle {
    sail_in_irons
  } else if rel_wind < close_haul_angle {
    // Lerp between in_irons and close_haul
    let t = (rel_wind - in_irons_angle) / (close_haul_angle - in_irons_angle)
    lerpf(sail_in_irons, sail_close_haul, t)
  } else if rel_wind < beam_reach_angle {
    let t = (rel_wind - close_haul_angle) /
      (beam_reach_angle - close_haul_angle)
    lerpf(sail_close_haul, sail_beam_reach, t)
  } else if rel_wind < broad_reach_angle {
    let t = (rel_wind - beam_reach_angle) /
      (broad_reach_angle - beam_reach_angle)
    lerpf(sail_beam_reach, sail_broad_reach, t)
  } else {
    let t = (rel_wind - broad_reach_angle) / (pi - broad_reach_angle)
    lerpf(sail_broad_reach, sail_running, t)
  }
  // Sail state multiplier
  let sail_mult = sail_amount
  // Mast damage reduces sail effectiveness
  let mast_eff : Float = 0.2 + 0.8 * mast_hp_ratio
  // Final speed
  base_speed * point_of_sail * wind_speed * sail_mult * mast_eff
}

// Ship turning rate calculation

///|
/// Computes effective turn rate from rudder health and current speed.
pub fn calc_turn_rate(
  base_rate : Float,
  rudder_hp_ratio : Float,
  speed : Float,
  base_speed : Float,
) -> Float {
  // Rudder damage reduces turning
  let rudder_eff : Float = 0.15 + 0.85 * rudder_hp_ratio
  // Turning is best at moderate speed, worse when stopped or very fast
  let speed_ratio : Float = if base_speed > 0.0 {
    speed / base_speed
  } else {
    0.0
  }
  let speed_factor : Float = if speed_ratio < 0.1 {
    0.3
  } else if speed_ratio < 0.5 {
    0.7 + speed_ratio * 0.6
  } else if speed_ratio < 0.8 {
    1.0
  } else {
    1.0 - (speed_ratio - 0.8) * 0.5
  }
  base_rate * rudder_eff * speed_factor
}

// Water height at position (simple wave function)

///|
/// Returns procedural ocean surface height at world position and time.
pub fn water_height(x : Float, z : Float, time : Float) -> Float {
  let w1 = @math.sinf(x * wave_frequency + time * wave_speed) * wave_amplitude
  let w2 = @math.sinf(z * wave_frequency * 0.7 + time * wave_speed * 1.3) *
    wave_amplitude *
    0.5
  let w3 = @math.sinf((x + z) * wave_frequency * 0.5 + time * wave_speed * 0.8) *
    wave_amplitude *
    0.3
  w1 + w2 + w3
}

// Calculate wind crosswind drift

///|
/// Computes lateral wind drift vector applied to a moving ship.
pub fn calc_wind_drift(
  heading : Float,
  wind_dir : Float,
  wind_speed : Float,
  ship_speed : Float,
) -> (Float, Float) {
  // Drift perpendicular to heading based on crosswind component
  let rel_wind = angle_diff(heading, wind_dir)
  let cross_component = @math.sinf(rel_wind) * wind_speed * drift_factor
  // Drift is perpendicular to heading
  let drift_mult : Float = if ship_speed > 0.5 { 0.5 / ship_speed } else { 1.0 }
  let dx = @math.cosf(heading) * cross_component * drift_mult
  let dz = -@math.sinf(heading) * cross_component * drift_mult
  (dx, dz)
}

// Cannon ballistic trajectory - calculate launch velocity for given range

///|
/// Returns cannonball launch velocity components for a shot profile.
pub fn calc_cannon_launch(
  fire_angle : Float,
  cannon_speed : Float,
  cannon_arc : Float,
  target_dist : Float,
) -> (Float, Float, Float) {
  // Horizontal velocity
  let hvel = cannon_speed
  let vx = @math.sinf(fire_angle) * hvel
  let vz = @math.cosf(fire_angle) * hvel
  // Vertical velocity for arc (higher arc = more lob)
  let arc_mult : Float = if target_dist > 20.0 {
    cannon_arc * 1.2
  } else {
    cannon_arc * 0.8
  }
  (vx, arc_mult, vz)
}

// Get cannon damage for a specific cannon type

///|
/// Returns base damage for a cannon type.
pub fn get_cannon_damage(cannon_type : Int) -> Float {
  if cannon_type == cannon_light {
    light_cannon_damage
  } else if cannon_type == cannon_medium {
    medium_cannon_damage
  } else if cannon_type == cannon_heavy {
    heavy_cannon_damage
  } else if cannon_type == cannon_mortar {
    mortar_damage
  } else if cannon_type == cannon_chain_shot {
    chain_shot_damage
  } else {
    medium_cannon_damage
  }
}

// Get cannon reload time

///|
/// Returns reload time in seconds for a cannon type.
pub fn get_cannon_reload(cannon_type : Int) -> Float {
  if cannon_type == cannon_light {
    light_cannon_reload
  } else if cannon_type == cannon_medium {
    medium_cannon_reload
  } else if cannon_type == cannon_heavy {
    heavy_cannon_reload
  } else if cannon_type == cannon_mortar {
    mortar_reload
  } else if cannon_type == cannon_chain_shot {
    chain_shot_reload
  } else {
    medium_cannon_reload
  }
}

// Get cannon speed

///|
/// Returns muzzle speed for a cannon type.
pub fn get_cannon_speed(cannon_type : Int) -> Float {
  if cannon_type == cannon_light {
    light_cannon_speed
  } else if cannon_type == cannon_medium {
    medium_cannon_speed
  } else if cannon_type == cannon_heavy {
    heavy_cannon_speed
  } else if cannon_type == cannon_mortar {
    mortar_speed
  } else if cannon_type == cannon_chain_shot {
    chain_shot_speed
  } else {
    medium_cannon_speed
  }
}

// Get cannon arc

///|
/// Returns vertical launch arc factor for a cannon type.
pub fn get_cannon_arc(cannon_type : Int) -> Float {
  if cannon_type == cannon_light {
    light_cannon_arc
  } else if cannon_type == cannon_medium {
    medium_cannon_arc
  } else if cannon_type == cannon_heavy {
    heavy_cannon_arc
  } else if cannon_type == cannon_mortar {
    mortar_arc
  } else if cannon_type == cannon_chain_shot {
    chain_shot_arc
  } else {
    medium_cannon_arc
  }
}

// Get damage multipliers for ammo type

///|
/// Returns hull damage multiplier for an ammo type.
pub fn get_ammo_hull_mult(ammo_type : Int) -> Float {
  if ammo_type == ammo_round_shot {
    round_shot_hull_mult
  } else if ammo_type == ammo_chain_shot {
    chain_shot_hull_mult
  } else if ammo_type == ammo_grapeshot {
    grapeshot_hull_mult
  } else {
    1.0
  }
}

///|
/// Returns mast damage multiplier for an ammo type.
pub fn get_ammo_mast_mult(ammo_type : Int) -> Float {
  if ammo_type == ammo_round_shot {
    round_shot_mast_mult
  } else if ammo_type == ammo_chain_shot {
    chain_shot_mast_mult
  } else if ammo_type == ammo_grapeshot {
    grapeshot_mast_mult
  } else {
    0.3
  }
}

///|
/// Returns crew damage multiplier for an ammo type.
pub fn get_ammo_crew_mult(ammo_type : Int) -> Float {
  if ammo_type == ammo_round_shot {
    round_shot_crew_mult
  } else if ammo_type == ammo_chain_shot {
    chain_shot_crew_mult
  } else if ammo_type == ammo_grapeshot {
    grapeshot_crew_mult
  } else {
    0.1
  }
}

// Ship class stats helpers

///|
/// Returns maximum hull HP for a ship class.
pub fn get_class_max_hull(ship_class : Int) -> Float {
  if ship_class == class_sloop {
    sloop_max_hull
  } else if ship_class == class_brigantine {
    brigantine_max_hull
  } else if ship_class == class_frigate {
    frigate_max_hull
  } else if ship_class == class_galleon {
    galleon_max_hull
  } else if ship_class == class_man_of_war {
    mow_max_hull
  } else {
    frigate_max_hull
  }
}

///|
/// Returns maximum mast HP for a ship class.
pub fn get_class_max_mast(ship_class : Int) -> Float {
  if ship_class == class_sloop {
    sloop_max_mast
  } else if ship_class == class_brigantine {
    brigantine_max_mast
  } else if ship_class == class_frigate {
    frigate_max_mast
  } else if ship_class == class_galleon {
    galleon_max_mast
  } else if ship_class == class_man_of_war {
    mow_max_mast
  } else {
    frigate_max_mast
  }
}

///|
/// Returns maximum rudder HP for a ship class.
pub fn get_class_max_rudder(ship_class : Int) -> Float {
  if ship_class == class_sloop {
    sloop_max_rudder
  } else if ship_class == class_brigantine {
    brigantine_max_rudder
  } else if ship_class == class_frigate {
    frigate_max_rudder
  } else if ship_class == class_galleon {
    galleon_max_rudder
  } else if ship_class == class_man_of_war {
    mow_max_rudder
  } else {
    frigate_max_rudder
  }
}

///|
/// Returns base sailing speed for a ship class.
pub fn get_class_base_speed(ship_class : Int) -> Float {
  if ship_class == class_sloop {
    sloop_base_speed
  } else if ship_class == class_brigantine {
    brigantine_base_speed
  } else if ship_class == class_frigate {
    frigate_base_speed
  } else if ship_class == class_galleon {
    galleon_base_speed
  } else if ship_class == class_man_of_war {
    mow_base_speed
  } else {
    frigate_base_speed
  }
}

///|
/// Returns base turning rate for a ship class.
pub fn get_class_turn_rate(ship_class : Int) -> Float {
  if ship_class == class_sloop {
    sloop_turn_rate
  } else if ship_class == class_brigantine {
    brigantine_turn_rate
  } else if ship_class == class_frigate {
    frigate_turn_rate
  } else if ship_class == class_galleon {
    galleon_turn_rate
  } else if ship_class == class_man_of_war {
    mow_turn_rate
  } else {
    frigate_turn_rate
  }
}

///|
/// Returns broadside cannon count for a ship class.
pub fn get_class_cannon_count(ship_class : Int) -> Int {
  if ship_class == class_sloop {
    sloop_cannon_count
  } else if ship_class == class_brigantine {
    brigantine_cannon_count
  } else if ship_class == class_frigate {
    frigate_cannon_count
  } else if ship_class == class_galleon {
    galleon_cannon_count
  } else if ship_class == class_man_of_war {
    mow_cannon_count
  } else {
    frigate_cannon_count
  }
}

///|
/// Returns maximum crew capacity for a ship class.
pub fn get_class_max_crew(ship_class : Int) -> Int {
  if ship_class == class_sloop {
    sloop_max_crew
  } else if ship_class == class_brigantine {
    brigantine_max_crew
  } else if ship_class == class_frigate {
    frigate_max_crew
  } else if ship_class == class_galleon {
    galleon_max_crew
  } else if ship_class == class_man_of_war {
    mow_max_crew
  } else {
    frigate_max_crew
  }
}

///|
/// Returns hull length in world units for a ship class.
pub fn get_class_length(ship_class : Int) -> Float {
  if ship_class == class_sloop {
    sloop_length
  } else if ship_class == class_brigantine {
    brigantine_length
  } else if ship_class == class_frigate {
    frigate_length
  } else if ship_class == class_galleon {
    galleon_length
  } else if ship_class == class_man_of_war {
    mow_length
  } else {
    frigate_length
  }
}

///|
/// Returns hull width in world units for a ship class.
pub fn get_class_width(ship_class : Int) -> Float {
  if ship_class == class_sloop {
    sloop_width
  } else if ship_class == class_brigantine {
    brigantine_width
  } else if ship_class == class_frigate {
    frigate_width
  } else if ship_class == class_galleon {
    galleon_width
  } else if ship_class == class_man_of_war {
    mow_width
  } else {
    frigate_width
  }
}

///|
/// Returns score reward for sinking a ship class.
pub fn get_class_score(ship_class : Int) -> Int {
  if ship_class == class_sloop {
    score_sloop_kill
  } else if ship_class == class_brigantine {
    score_brigantine_kill
  } else if ship_class == class_frigate {
    score_frigate_kill
  } else if ship_class == class_galleon {
    score_galleon_kill
  } else if ship_class == class_man_of_war {
    score_mow_kill
  } else {
    score_frigate_kill
  }
}

///|
/// Returns display name for a ship class id.
pub fn get_class_name(ship_class : Int) -> String {
  if ship_class == class_sloop {
    "Sloop"
  } else if ship_class == class_brigantine {
    "Brigantine"
  } else if ship_class == class_frigate {
    "Frigate"
  } else if ship_class == class_galleon {
    "Galleon"
  } else if ship_class == class_man_of_war {
    "Man-of-War"
  } else {
    "Ship"
  }
}

///|
/// Returns reputation title string for a reputation score.
pub fn get_reputation_title(rep : Int) -> String {
  if rep >= rep_legend {
    "Legend"
  } else if rep >= rep_admiral {
    "Admiral"
  } else if rep >= rep_commodore {
    "Commodore"
  } else if rep >= rep_captain {
    "Captain"
  } else {
    "Privateer"
  }
}

// RNG

///|
/// Advances RNG state and returns the next pseudo-random integer.
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
/// Returns random integer in inclusive range `[low, high]`.
pub fn rand_range(game : Game, low : Int, high : Int) -> Int {
  if high <= low {
    low
  } else {
    low + rand_next(game) % (high - low + 1)
  }
}

///|
/// Returns random float in inclusive range `[low, high]`.
pub fn rand_rangef(game : Game, low : Float, high : Float) -> Float {
  let n = Float::from_int(rand_next(game) % 10000) / 10000.0
  low + (high - low) * n
}

// Pool allocators

///|
/// Returns the first inactive enemy slot index, or `-1` when full.
pub fn alloc_enemy(game : Game) -> Int {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      return i
    }
  }
  -1
}

///|
/// Returns the first inactive cannonball slot index, or `-1` when full.
pub fn alloc_cannonball(game : Game) -> Int {
  for i in 0..<game.cannonballs.length() {
    if not(game.cannonballs[i].active) {
      return i
    }
  }
  -1
}

///|
/// Returns the first inactive particle slot index, or `-1` when full.
pub fn alloc_particle(game : Game) -> Int {
  for i in 0..<game.particles.length() {
    if not(game.particles[i].active) {
      return i
    }
  }
  -1
}

///|
/// Returns the first inactive wake slot index, or `-1` when full.
pub fn alloc_wake(game : Game) -> Int {
  for i in 0..<game.wakes.length() {
    if not(game.wakes[i].active) {
      return i
    }
  }
  -1
}

///|
/// Returns the first inactive debris slot index, or `-1` when full.
pub fn alloc_debris(game : Game) -> Int {
  for i in 0..<game.debris_pool.length() {
    if not(game.debris_pool[i].active) {
      return i
    }
  }
  -1
}

///|
/// Returns a free battle-message slot, replacing the oldest if necessary.
pub fn alloc_message(game : Game) -> Int {
  for i in 0..<game.messages.length() {
    if not(game.messages[i].active) {
      return i
    }
  }
  // Overwrite oldest
  let mut oldest_idx = 0
  let mut oldest_timer : Float = 999.0
  for i in 0..<game.messages.length() {
    if game.messages[i].timer < oldest_timer {
      oldest_timer = game.messages[i].timer
      oldest_idx = i
    }
  }
  oldest_idx
}

///|
/// Adds a transient colored battle message to the HUD queue.
pub fn add_battle_message(
  game : Game,
  text : String,
  r : Int,
  g : Int,
  b : Int,
) -> Unit {
  let idx = alloc_message(game)
  let msg = game.messages[idx]
  msg.active = true
  msg.text = text
  msg.timer = message_display_time
  msg.priority = 0
  msg.color_r = r
  msg.color_g = g
  msg.color_b = b
}

///|
/// Appends a line to the battle log history.
pub fn add_battle_log(game : Game, text : String) -> Unit {
  if game.battle_log_count < game.battle_log.length() {
    game.battle_log[game.battle_log_count] = text
    game.battle_log_count += 1
  } else {
    // Shift entries
    for i in 0..<(game.battle_log.length() - 1) {
      game.battle_log[i] = game.battle_log[i + 1]
    }
    game.battle_log[game.battle_log.length() - 1] = text
  }
}

///|
/// Spawns generic colored particles at world position.
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
    p.y = wy + rand_rangef(game, 0.0, 0.5)
    p.z = wz + rand_rangef(game, -0.5, 0.5)
    p.vx = rand_rangef(game, -3.0, 3.0)
    p.vy = rand_rangef(game, 2.0, 6.0)
    p.vz = rand_rangef(game, -3.0, 3.0)
    p.life = rand_rangef(game, 0.4, 1.0)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.05, 0.15)
    p.particle_type = particle_generic
    ignore(i)
  }
}

///|
/// Spawns smoke particles at world position.
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
    p.x = wx + rand_rangef(game, -0.3, 0.3)
    p.y = wy + rand_rangef(game, 0.0, 0.3)
    p.z = wz + rand_rangef(game, -0.3, 0.3)
    p.vx = rand_rangef(game, -1.0, 1.0)
    p.vy = rand_rangef(game, 1.0, 3.0)
    p.vz = rand_rangef(game, -1.0, 1.0)
    p.life = rand_rangef(game, 0.8, 2.0)
    p.max_life = p.life
    p.r = 100
    p.g = 100
    p.b = 110
    p.size = rand_rangef(game, 0.15, 0.35)
    p.particle_type = particle_smoke
    ignore(i)
  }
}

///|
/// Spawns fire particles at world position.
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
    p.x = wx + rand_rangef(game, -0.2, 0.2)
    p.y = wy + rand_rangef(game, 0.0, 0.3)
    p.z = wz + rand_rangef(game, -0.2, 0.2)
    p.vx = rand_rangef(game, -0.5, 0.5)
    p.vy = rand_rangef(game, 2.0, 5.0)
    p.vz = rand_rangef(game, -0.5, 0.5)
    p.life = rand_rangef(game, 0.3, 0.8)
    p.max_life = p.life
    p.r = 255
    p.g = rand_range(game, 100, 200)
    p.b = 30
    p.size = rand_rangef(game, 0.1, 0.25)
    p.particle_type = particle_fire
    ignore(i)
  }
}

///|
/// Spawns water splash particles at sea level around a point.
pub fn spawn_water_splash(
  game : Game,
  wx : Float,
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
    p.x = wx + rand_rangef(game, -0.3, 0.3)
    p.y = rand_rangef(game, 0.0, 0.3)
    p.z = wz + rand_rangef(game, -0.3, 0.3)
    p.vx = rand_rangef(game, -2.0, 2.0)
    p.vy = rand_rangef(game, 3.0, 8.0)
    p.vz = rand_rangef(game, -2.0, 2.0)
    p.life = rand_rangef(game, 0.3, 0.7)
    p.max_life = p.life
    p.r = 150
    p.g = 200
    p.b = 255
    p.size = rand_rangef(game, 0.06, 0.12)
    p.particle_type = particle_splash
    ignore(i)
  }
}

///|
/// Spawns floating debris pieces around a wreck point.
pub fn spawn_debris_cluster(
  game : Game,
  wx : Float,
  wz : Float,
  count : Int,
) -> Unit {
  for i in 0..<count {
    let idx = alloc_debris(game)
    if idx < 0 {
      return
    }
    let d = game.debris_pool[idx]
    d.active = true
    d.x = wx + rand_rangef(game, -2.0, 2.0)
    d.y = 0.1
    d.z = wz + rand_rangef(game, -2.0, 2.0)
    d.vx = rand_rangef(game, -3.0, 3.0)
    d.vz = rand_rangef(game, -3.0, 3.0)
    d.rotation = rand_rangef(game, 0.0, two_pi)
    d.rot_speed = rand_rangef(game, -2.0, 2.0)
    d.life = debris_lifetime + rand_rangef(game, -2.0, 2.0)
    let dtype = rand_range(game, 0, 3)
    d.debris_type = dtype
    if dtype == debris_plank {
      d.size = rand_rangef(game, 0.2, 0.5)
      d.r = 120
      d.g = 80
      d.b = 40
    } else if dtype == debris_barrel {
      d.size = rand_rangef(game, 0.3, 0.5)
      d.r = 100
      d.g = 70
      d.b = 35
    } else if dtype == debris_sail_scrap {
      d.size = rand_rangef(game, 0.4, 0.8)
      d.r = 220
      d.g = 210
      d.b = 180
    } else {
      d.size = rand_rangef(game, 0.3, 0.7)
      d.r = 90
      d.g = 65
      d.b = 30
    }
    ignore(i)
  }
}

///|
/// Spawns a wake segment behind a sufficiently fast ship.
pub fn spawn_wake(
  game : Game,
  wx : Float,
  wz : Float,
  heading : Float,
  speed : Float,
) -> Unit {
  if speed < wake_min_speed {
    return
  }
  let idx = alloc_wake(game)
  if idx < 0 {
    return
  }
  let w = game.wakes[idx]
  w.active = true
  w.x = wx
  w.z = wz
  w.age = 0.0
  w.max_age = wake_lifetime
  w.heading = heading
  w.speed_at_spawn = speed
  w.width = 0.3 + speed * 0.15
}

// Check collision with islands

///|
/// Checks whether a circular ship footprint intersects any active island.
pub fn check_island_collision(
  game : Game,
  x : Float,
  z : Float,
  ship_radius : Float,
) -> Bool {
  for i in 0..<game.island_count {
    let island = game.islands[i]
    if not(island.active) {
      continue
    }
    let dist = distance2d(x, z, island.x, island.z)
    if dist < island.radius + ship_radius {
      return true
    }
  }
  false
}

// Check ship-to-ship collision

///|
/// Checks overlap between two circular ship footprints.
pub fn check_ship_collision(
  x1 : Float,
  z1 : Float,
  r1 : Float,
  x2 : Float,
  z2 : Float,
  r2 : Float,
) -> Bool {
  let dist = distance2d(x1, z1, x2, z2)
  dist < r1 + r2
}

// Get total HP ratio for player ship

///|
/// Returns normalized player survivability ratio from major HP pools.
pub fn player_hp_ratio(game : Game) -> Float {
  let total = game.player.hull_hp + game.player.sail_hp + game.player.rudder_hp
  let max_total = game.player.max_hp * 3.0
  if max_total > 0.0 {
    total / max_total
  } else {
    0.0
  }
}

// Check if player can board an enemy

///|
/// Returns whether the player is close enough to initiate boarding against an enemy.
pub fn check_boarding_range(game : Game, enemy_idx : Int) -> Bool {
  if enemy_idx < 0 || enemy_idx >= game.enemies.length() {
    return false
  }
  let enemy = game.enemies[enemy_idx]
  if not(enemy.active) {
    return false
  }
  let dist = distance2d(game.player.x, game.player.z, enemy.x, enemy.z)
  dist < boarding_range
}

// Resolve boarding combat

///|
/// Resolves boarding success using crew strength and randomness.
pub fn resolve_boarding(
  player_crew : Int,
  enemy_crew : Int,
  game : Game,
) -> Bool {
  // Random factor for some variance
  let player_power = Float::from_int(player_crew) * boarding_crew_power
  let enemy_power = Float::from_int(enemy_crew) * boarding_crew_power * 0.8
  let roll = rand_rangef(game, 0.7, 1.3)
  player_power * roll > enemy_power
}

// Count active fleet ships

///|
/// Counts active allied fleet ships.
pub fn count_fleet_alive(game : Game) -> Int {
  let mut count = 0
  for fleet_ship in game.fleet_ships {
    if fleet_ship.active {
      count += 1
    }
  }
  count
}

// Count active convoy ships

///|
/// Counts active convoy ships.
pub fn count_convoy_alive(game : Game) -> Int {
  let mut count = 0
  for convoy_ship in game.convoy_ships {
    if convoy_ship.active {
      count += 1
    }
  }
  count
}

// Sync wind helpers

///|
/// Mirrors wind state into legacy helper fields.
pub fn sync_wind(game : Game) -> Unit {
  game.wind_angle = game.wind.direction
  game.wind_speed = game.wind.speed
}
