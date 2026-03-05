///|
/// Converts an integer to an EnemyKind enum value.
pub fn enemy_kind_from_int(n : Int) -> EnemyKind {
  if n == 0 {
    Basic
  } else if n == 1 {
    Fast
  } else if n == 2 {
    Tank
  } else if n == 3 {
    Flying
  } else if n == 4 {
    Boss
  } else if n == 5 {
    Healer
  } else if n == 6 {
    Swarm
  } else if n == 7 {
    Shield
  } else if n == 8 {
    Camo
  } else {
    Splitter
  }
}

///|
/// Converts an EnemyKind enum value to an integer.
pub fn enemy_kind_to_int(kind : EnemyKind) -> Int {
  if kind == Basic {
    0
  } else if kind == Fast {
    1
  } else if kind == Tank {
    2
  } else if kind == Flying {
    3
  } else if kind == Boss {
    4
  } else if kind == Healer {
    5
  } else if kind == Swarm {
    6
  } else if kind == Shield {
    7
  } else if kind == Camo {
    8
  } else {
    9
  }
}

///|
/// Converts an integer to a TargetPriority enum value.
pub fn target_priority_from_int(n : Int) -> TargetPriority {
  if n == 0 {
    First
  } else if n == 1 {
    Last
  } else if n == 2 {
    Strongest
  } else {
    Closest
  }
}

///|
/// Converts a TargetPriority enum value to an integer.
pub fn target_priority_to_int(mode : TargetPriority) -> Int {
  if mode == First {
    0
  } else if mode == Last {
    1
  } else if mode == Strongest {
    2
  } else {
    3
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
/// Returns the larger of `a` and `b`.
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// Returns the linear interpolation between `a` and `b` at parameter `t`.
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
/// Returns the Euclidean distance between two points on the XZ plane.
pub fn distance2d(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  @math.hypotf(x1 - x2, z1 - z2)
}

///|
/// Returns the Euclidean distance between two points in 3D space.
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
/// Returns whether grid coordinates (`gx`, `gy`) are within the map bounds.
pub fn in_bounds(gx : Int, gy : Int) -> Bool {
  gx >= 0 && gy >= 0 && gx < map_w && gy < map_h
}

///|
/// Returns the flat array index for grid coordinates (`gx`, `gy`).
pub fn tile_index(gx : Int, gy : Int) -> Int {
  gy * map_w + gx
}

///|
/// Returns the tile type at grid position (`gx`, `gy`), or rock if out of bounds.
pub fn get_tile(game : Game, gx : Int, gy : Int) -> Tile {
  if in_bounds(gx, gy) {
    game.tiles[tile_index(gx, gy)]
  } else {
    Rock
  }
}

///|
/// Sets the tile type at grid position (`gx`, `gy`) to `tile`.
pub fn set_tile(game : Game, gx : Int, gy : Int, tile : Tile) -> Unit {
  if in_bounds(gx, gy) {
    game.tiles[tile_index(gx, gy)] = tile
  }
}

///|
/// Returns the world-space X coordinate for grid column `gx`.
pub fn grid_to_world_x(gx : Int) -> Float {
  Float::from_int(gx) * cell_size + cell_size / 2.0
}

///|
/// Returns the world-space Z coordinate for grid row `gy`.
pub fn grid_to_world_z(gy : Int) -> Float {
  Float::from_int(gy) * cell_size + cell_size / 2.0
}

///|
/// Returns the grid column for world-space X coordinate `wx`.
pub fn world_to_grid_x(wx : Float) -> Int {
  (wx / cell_size).to_int()
}

///|
/// Returns the grid row for world-space Z coordinate `wz`.
pub fn world_to_grid_y(wz : Float) -> Int {
  (wz / cell_size).to_int()
}

///|
/// Returns the tower pool index at grid position (`gx`, `gy`), or -1 if none.
pub fn tower_at(game : Game, gx : Int, gy : Int) -> Int {
  for i in 0..<game.towers.length() {
    if game.towers[i].active &&
      game.towers[i].gx == gx &&
      game.towers[i].gy == gy {
      return i
    }
  }
  -1
}

///|
/// Returns the index of the first inactive tower slot, or -1 if full.
pub fn alloc_tower(game : Game) -> Int {
  for i in 0..<game.towers.length() {
    if not(game.towers[i].active) {
      return i
    }
  }
  -1
}

///|
/// Returns the index of the first inactive enemy slot, or -1 if full.
pub fn alloc_enemy(game : Game) -> Int {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      return i
    }
  }
  -1
}

///|
/// Returns the index of the first inactive projectile slot, or -1 if full.
pub fn alloc_projectile(game : Game) -> Int {
  for i in 0..<game.projectiles.length() {
    if not(game.projectiles[i].active) {
      return i
    }
  }
  -1
}

///|
/// Returns the index of the first inactive particle slot, or -1 if full.
pub fn alloc_particle(game : Game) -> Int {
  for i in 0..<game.particles.length() {
    if not(game.particles[i].active) {
      return i
    }
  }
  -1
}

// Tower cost lookup (base cost)

///|
/// Returns the base gold cost for building a tower of the given `kind`.
pub fn tower_cost_for(kind : TowerKind) -> Int {
  if kind == Arrow {
    cost_arrow
  } else if kind == Cannon {
    cost_cannon
  } else if kind == Frost {
    cost_frost
  } else if kind == Lightning {
    cost_lightning
  } else if kind == Flame {
    cost_flame
  } else if kind == Sniper {
    cost_sniper
  } else if kind == Splash {
    cost_splash
  } else if kind == Buff {
    cost_buff
  } else {
    999
  }
}

// Keep old name for backward compatibility

///|
/// Returns the base gold cost for a tower type (backward-compatible alias).
pub fn tower_cost(kind : TowerKind) -> Int {
  tower_cost_for(kind)
}

// Tower upgrade cost for a given level

///|
/// Returns the gold cost to upgrade a tower of `kind` from `current_level`.
pub fn tower_upgrade_cost(kind : TowerKind, current_level : Int) -> Int {
  let base = tower_cost_for(kind)
  if current_level == 1 {
    let cost : Float = Float::from_int(base) * upgrade_cost_mult_2
    cost.to_int()
  } else if current_level == 2 {
    let cost : Float = Float::from_int(base) * upgrade_cost_mult_3
    cost.to_int()
  } else {
    0
  }
}

// Total investment in a tower (base + upgrades)

///|
/// Returns the total gold invested in a tower of `kind` at the given `level`.
pub fn tower_total_investment(kind : TowerKind, level : Int) -> Int {
  let mut total = tower_cost_for(kind)
  if level >= 2 {
    let cost2 : Float = Float::from_int(tower_cost_for(kind)) *
      upgrade_cost_mult_2
    total = total + cost2.to_int()
  }
  if level >= 3 {
    let cost3 : Float = Float::from_int(tower_cost_for(kind)) *
      upgrade_cost_mult_3
    total = total + cost3.to_int()
  }
  total
}

// Tower sell value

///|
/// Returns the gold refund for selling a tower of `kind` at the given `level`.
pub fn tower_sell_value(kind : TowerKind, level : Int) -> Int {
  let invested = tower_total_investment(kind, level)
  let value : Float = Float::from_int(invested) * sell_value_pct
  value.to_int()
}

///|
/// Returns the base attack range for a tower of the given `kind`.
pub fn tower_range(kind : TowerKind) -> Float {
  if kind == Arrow {
    range_arrow
  } else if kind == Cannon {
    range_cannon
  } else if kind == Frost {
    range_frost
  } else if kind == Lightning {
    range_lightning
  } else if kind == Flame {
    range_flame
  } else if kind == Sniper {
    range_sniper
  } else if kind == Splash {
    range_splash
  } else if kind == Buff {
    range_buff
  } else {
    0.0
  }
}

// Tower range with level scaling and buff bonus

///|
/// Returns the actual range of `tower` including level scaling and buff bonuses.
pub fn tower_effective_range(tower : Tower) -> Float {
  let base : Float = tower_range(tower.kind)
  let level_mult : Float = 1.0 +
    Float::from_int(tower.level - 1) * upgrade_range_mult
  let buff_mult : Float = 1.0 + tower.buff_range
  base * level_mult * buff_mult
}

///|
/// Returns the base damage per shot for a tower of the given `kind`.
pub fn tower_damage(kind : TowerKind) -> Float {
  if kind == Arrow {
    dmg_arrow
  } else if kind == Cannon {
    dmg_cannon
  } else if kind == Frost {
    dmg_frost
  } else if kind == Lightning {
    dmg_lightning
  } else if kind == Flame {
    dmg_flame
  } else if kind == Sniper {
    dmg_sniper
  } else if kind == Splash {
    dmg_splash
  } else if kind == Buff {
    dmg_buff
  } else {
    0.0
  }
}

// Tower damage with level scaling and buff bonus

///|
/// Returns the actual damage of `tower` including level scaling and buff bonuses.
pub fn tower_effective_damage(tower : Tower) -> Float {
  let base = tower_damage(tower.kind)
  let level_mult : Float = 1.0 +
    Float::from_int(tower.level - 1) * upgrade_damage_mult
  let buff_mult : Float = 1.0 + tower.buff_damage
  base * level_mult * buff_mult
}

///|
/// Returns the base fire rate in seconds between shots for a tower of `kind`.
pub fn tower_fire_rate(kind : TowerKind) -> Float {
  if kind == Arrow {
    rate_arrow
  } else if kind == Cannon {
    rate_cannon
  } else if kind == Frost {
    rate_frost
  } else if kind == Lightning {
    rate_lightning
  } else if kind == Flame {
    rate_flame
  } else if kind == Sniper {
    rate_sniper
  } else if kind == Splash {
    rate_splash
  } else if kind == Buff {
    rate_buff
  } else {
    1.0
  }
}

// Tower fire rate with level scaling and buff bonus (lower = faster)

///|
/// Returns the actual fire rate of `tower` including level scaling and buff bonuses.
pub fn tower_effective_rate(tower : Tower) -> Float {
  let base = tower_fire_rate(tower.kind)
  let level_mult : Float = 1.0 -
    Float::from_int(tower.level - 1) * upgrade_rate_mult
  let buff_mult : Float = 1.0 - tower.buff_rate
  let result : Float = base * level_mult * buff_mult
  maxf(result, 0.1)
}

///|
/// Returns the display name for a tower of the given `kind`.
pub fn tower_name(kind : TowerKind) -> String {
  if kind == Arrow {
    "Arrow"
  } else if kind == Cannon {
    "Cannon"
  } else if kind == Frost {
    "Frost"
  } else if kind == Lightning {
    "Lightning"
  } else if kind == Flame {
    "Flame"
  } else if kind == Sniper {
    "Sniper"
  } else if kind == Splash {
    "Splash"
  } else if kind == Buff {
    "Buff"
  } else {
    "Unknown"
  }
}

///|
/// Returns the display name for an enemy of the given `kind`.
pub fn enemy_name(kind : EnemyKind) -> String {
  if kind == Basic {
    "Soldier"
  } else if kind == Fast {
    "Scout"
  } else if kind == Tank {
    "Heavy"
  } else if kind == Flying {
    "Flyer"
  } else if kind == Boss {
    "Boss"
  } else if kind == Healer {
    "Medic"
  } else if kind == Swarm {
    "Swarm"
  } else if kind == Shield {
    "Shield"
  } else if kind == Camo {
    "Stealth"
  } else if kind == Splitter {
    "Splitter"
  } else {
    "Unknown"
  }
}

///|
/// Returns the display name for the given targeting `mode`.
pub fn targeting_mode_name(mode : TargetPriority) -> String {
  if mode == First {
    "First"
  } else if mode == Last {
    "Last"
  } else if mode == Strongest {
    "Strong"
  } else if mode == Closest {
    "Close"
  } else {
    "First"
  }
}

// Enemy resistance to tower damage types
// Returns a multiplier: <1.0 = resistant, 1.0 = normal, >1.0 = weak

///|
/// Returns the damage resistance multiplier for `enemy_kind` against `tower_kind`.
pub fn enemy_resistance(enemy_kind : EnemyKind, tower_kind : TowerKind) -> Float {
  // Flying enemies are weak to arrow, resistant to flame
  if enemy_kind == Flying {
    if tower_kind == Arrow {
      return 1.5
    }
    if tower_kind == Flame {
      return 0.5
    }
    return 1.0
  }
  // Tank enemies are resistant to arrow, weak to cannon
  if enemy_kind == Tank {
    if tower_kind == Arrow {
      return 0.6
    }
    if tower_kind == Cannon {
      return 1.5
    }
    return 1.0
  }
  // Shield enemies are resistant to splash, weak to sniper
  if enemy_kind == Shield {
    if tower_kind == Splash {
      return 0.6
    }
    if tower_kind == Sniper {
      return 1.5
    }
    return 1.0
  }
  // Boss enemies are resistant to frost slow
  if enemy_kind == Boss {
    if tower_kind == Frost {
      return 0.5
    }
    return 1.0
  }
  // Swarm enemies are weak to splash and flame
  if enemy_kind == Swarm {
    if tower_kind == Splash {
      return 1.5
    }
    if tower_kind == Flame {
      return 1.5
    }
    return 1.0
  }
  // Armored (healer) enemies are weak to lightning
  if enemy_kind == Healer {
    if tower_kind == Lightning {
      return 1.3
    }
    return 1.0
  }
  1.0
}

// Enemy armor value by type

///|
/// Returns the flat damage reduction armor value for an enemy of `kind`.
pub fn enemy_armor_value(kind : EnemyKind) -> Float {
  if kind == Basic {
    armor_basic
  } else if kind == Fast {
    armor_fast
  } else if kind == Tank {
    armor_tank
  } else if kind == Flying {
    armor_flying
  } else if kind == Boss {
    armor_boss
  } else if kind == Healer {
    armor_healer
  } else if kind == Swarm {
    armor_swarm
  } else if kind == Shield {
    armor_shield
  } else if kind == Camo {
    armor_camo
  } else if kind == Splitter {
    armor_splitter
  } else {
    0.0
  }
}

// Calculate actual damage after armor and resistance

///|
/// Returns the final damage after applying armor and resistance modifiers.
pub fn calc_damage(
  base_damage : Float,
  tower_kind : TowerKind,
  enemy : Enemy,
) -> Float {
  let resistance = enemy_resistance(enemy.kind, tower_kind)
  let effective_armor : Float = enemy.armor * enemy.armor_break_factor
  let after_armor : Float = maxf(base_damage - effective_armor, 1.0)
  after_armor * resistance
}

// Path interpolation: get world position at a given path progress

// Get total path progress for an enemy (for targeting comparison)

///|
/// Returns the combined path progress of `enemy` for targeting priority comparison.
pub fn enemy_total_progress(enemy : Enemy) -> Float {
  Float::from_int(enemy.path_index) + enemy.path_progress
}

// Target selection: find best enemy in range based on targeting mode

///|
/// Returns the index of the best enemy target in `range` based on targeting `mode`.
pub fn find_target(
  game : Game,
  wx : Float,
  wz : Float,
  range : Float,
  mode : TargetPriority,
  can_see_camo : Bool,
) -> Int {
  let mut best_idx = -1
  let mut best_score : Float = -999999.0
  for j in 0..<game.enemies.length() {
    let enemy = game.enemies[j]
    if not(enemy.active) {
      continue
    }
    // Skip camo enemies if tower cannot detect them
    if enemy.is_camo && not(can_see_camo) {
      continue
    }
    let dist = distance2d(wx, wz, enemy.x, enemy.z)
    if dist <= range {
      let score : Float = if mode == First {
        // Highest path progress = first (furthest along)
        enemy_total_progress(enemy)
      } else if mode == Last {
        // Lowest path progress = last
        -enemy_total_progress(enemy)
      } else if mode == Strongest {
        // Highest current HP
        enemy.hp
      } else {
        // Closest: negate distance so closer = higher score
        -dist
      }
      if score > best_score {
        best_score = score
        best_idx = j
      }
    }
  }
  best_idx
}

// Count active enemies

///|
/// Returns the number of currently active enemies on the field.
pub fn count_active_enemies(game : Game) -> Int {
  let mut count = 0
  for enemy in game.enemies {
    if enemy.active {
      count += 1
    }
  }
  count
}

// Count active towers

///|
/// Returns the number of currently active towers on the map.
pub fn count_active_towers(game : Game) -> Int {
  let mut count = 0
  for tower in game.towers {
    if tower.active {
      count += 1
    }
  }
  count
}

// Check if any tower can detect camo (sniper towers and lightning towers can detect camo)

///|
/// Returns whether a tower of `kind` can detect camouflaged enemies.
pub fn tower_can_detect_camo(kind : TowerKind) -> Bool {
  kind == Sniper || kind == Lightning
}

// Get projectile speed for tower type

///|
/// Returns the projectile travel speed for a tower of the given `kind`.
pub fn projectile_speed_for(kind : TowerKind) -> Float {
  if kind == Arrow {
    proj_speed_bullet
  } else if kind == Cannon {
    proj_speed_cannonball
  } else if kind == Frost {
    proj_speed_ice_shard
  } else if kind == Lightning {
    proj_speed_lightning
  } else if kind == Flame {
    proj_speed_fireball
  } else if kind == Sniper {
    proj_speed_sniper
  } else if kind == Splash {
    proj_speed_splash
  } else {
    12.0
  }
}

// Get splash radius for tower type

///|
/// Returns the area-of-effect splash radius for a tower of the given `kind`.
pub fn splash_radius_for(kind : TowerKind) -> Float {
  if kind == Cannon {
    splash_radius_cannon
  } else if kind == Splash {
    splash_radius_splash
  } else if kind == Flame {
    splash_radius_flame
  } else {
    0.0
  }
}

// RNG

///|
/// Returns the next pseudorandom integer and advances the RNG state.
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
/// Returns a random integer between `low` and `high` inclusive.
pub fn rand_range(game : Game, low : Int, high : Int) -> Int {
  if high <= low {
    low
  } else {
    low + rand_next(game) % (high - low + 1)
  }
}

///|
/// Returns a random float between `low` and `high`.
pub fn rand_rangef(game : Game, low : Float, high : Float) -> Float {
  let n = Float::from_int(rand_next(game) % 10000) / 10000.0
  low + (high - low) * n
}

///|
/// Returns whether a random roll succeeds given the probability `chance`.
pub fn rand_bool(game : Game, chance : Float) -> Bool {
  rand_rangef(game, 0.0, 1.0) < chance
}

///|
/// Creates `count` particles at the given world position with the specified color.
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
    p.vx = rand_rangef(game, -2.0, 2.0)
    p.vy = rand_rangef(game, 1.0, 5.0)
    p.vz = rand_rangef(game, -2.0, 2.0)
    p.life = rand_rangef(game, 0.3, 0.8)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.04, 0.1)
    p.kind = particle_normal
    ignore(i)
  }
}

///|
/// Creates `count` typed particles at the given world position with color and `kind`.
pub fn spawn_particles_typed(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  count : Int,
  r : Int,
  g : Int,
  b : Int,
  kind : Int,
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
    p.vx = rand_rangef(game, -1.5, 1.5)
    p.vy = rand_rangef(game, 0.5, 3.0)
    p.vz = rand_rangef(game, -1.5, 1.5)
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

// Spawn gold collection particles

///|
/// Creates gold-colored floating particles at the given world position.
pub fn spawn_gold_particles(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
) -> Unit {
  spawn_particles_typed(game, wx, wy, wz, 5, 255, 215, 0, particle_gold)
}

// Spawn explosion particles

///|
/// Creates explosion particles at the given world position with variable `size`.
pub fn spawn_explosion_particles(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  size : Int,
) -> Unit {
  spawn_particles_typed(
    game, wx, wy, wz, size, 255, 150, 50, particle_explosion,
  )
}

// Spawn ice particles

///|
/// Creates blue ice particles at the given world position.
pub fn spawn_ice_particles(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
) -> Unit {
  spawn_particles_typed(game, wx, wy, wz, 4, 150, 200, 255, particle_ice)
}

// Spawn fire particles

///|
/// Creates orange fire particles at the given world position.
pub fn spawn_fire_particles(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
) -> Unit {
  spawn_particles_typed(game, wx, wy, wz, 3, 255, 100, 30, particle_fire)
}

// Spawn lightning particles

///|
/// Creates yellow lightning particles at the given world position.
pub fn spawn_lightning_particles(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
) -> Unit {
  spawn_particles_typed(game, wx, wy, wz, 4, 200, 200, 50, particle_lightning)
}

// Spawn build effect particles

///|
/// Creates blue construction particles at the given world position.
pub fn spawn_build_particles(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
) -> Unit {
  spawn_particles_typed(game, wx, wy, wz, 10, 100, 200, 255, particle_build)
}

///|
/// Returns whether a tower can be placed at grid position (`gx`, `gy`).
pub fn can_place_tower(game : Game, gx : Int, gy : Int) -> Bool {
  if not(in_bounds(gx, gy)) {
    return false
  }
  let tile = get_tile(game, gx, gy)
  if tile != Grass {
    return false
  }
  if tower_at(game, gx, gy) >= 0 {
    return false
  }
  true
}

// Set notification message

///|
/// Sets the on-screen notification `text` to display for `duration` seconds.
pub fn set_notification(game : Game, text : String, duration : Float) -> Unit {
  game.notification_text = text
  game.notification_timer = duration
}

// Difficulty HP multiplier

///|
/// Returns the enemy HP multiplier for the given `difficulty` level.
pub fn difficulty_hp_mult(difficulty : Int) -> Float {
  if difficulty == 0 {
    difficulty_easy_hp
  } else if difficulty == 2 {
    difficulty_hard_hp
  } else {
    difficulty_normal_hp
  }
}

// Difficulty speed multiplier

///|
/// Returns the enemy speed multiplier for the given `difficulty` level.
pub fn difficulty_speed_mult(difficulty : Int) -> Float {
  if difficulty == 0 {
    difficulty_easy_speed
  } else if difficulty == 2 {
    difficulty_hard_speed
  } else {
    difficulty_normal_speed
  }
}

///|
/// Returns the display name for the given `difficulty` level.
pub fn difficulty_name(difficulty : Int) -> String {
  if difficulty == 0 {
    "Easy"
  } else if difficulty == 2 {
    "Hard"
  } else {
    "Normal"
  }
}

// Get upgrade info for tower at given level

///|
/// Returns the upgrade cost and stat preview for a tower of `kind` at `level`.
pub fn get_upgrade_info(kind : TowerKind, level : Int) -> UpgradeInfo {
  let cost = tower_upgrade_cost(kind, level)
  let dmg_mult : Float = 1.0 + Float::from_int(level) * upgrade_damage_mult
  let rng_mult : Float = 1.0 + Float::from_int(level) * upgrade_range_mult
  let rate_mult : Float = 1.0 - Float::from_int(level) * upgrade_rate_mult
  let desc : String = if level == 1 {
    "Improved stats"
  } else if level == 2 {
    get_level3_special_desc(kind)
  } else {
    "Max level"
  }
  {
    cost,
    damage_mult: dmg_mult,
    range_mult: rng_mult,
    rate_mult,
    special_desc: desc,
  }
}

// Level 3 special ability descriptions

///|
/// Returns the special ability description for level 3 of a tower of `kind`.
fn get_level3_special_desc(kind : TowerKind) -> String {
  if kind == Arrow {
    "Double shot"
  } else if kind == Cannon {
    "Bigger explosion"
  } else if kind == Frost {
    "Freeze chance"
  } else if kind == Lightning {
    "More chains"
  } else if kind == Flame {
    "Fire aura"
  } else if kind == Sniper {
    "Armor break"
  } else if kind == Splash {
    "Stun chance"
  } else if kind == Buff {
    "Buff pulse"
  } else {
    "Special"
  }
}

// Add chain line visual effect

///|
/// Adds a chain lightning visual arc between two 3D points.
pub fn add_chain_line(
  game : Game,
  x1 : Float,
  y1 : Float,
  z1 : Float,
  x2 : Float,
  y2 : Float,
  z2 : Float,
) -> Unit {
  for cl in game.chain_lines {
    if not(cl.active) {
      cl.active = true
      cl.x1 = x1
      cl.y1 = y1
      cl.z1 = z1
      cl.x2 = x2
      cl.y2 = y2
      cl.z2 = z2
      cl.life = 0.3
      return
    }
  }
}

// Speed setting name

///|
/// Returns the display label for the given speed `setting`.
pub fn speed_name(setting : Int) -> String {
  if setting == 0 {
    "1x"
  } else if setting == 1 {
    "2x"
  } else {
    "3x"
  }
}

// Speed multiplier from setting

///|
/// Returns the time multiplier for the given speed `setting`.
pub fn speed_from_setting(setting : Int) -> Float {
  if setting == 0 {
    speed_1x
  } else if setting == 1 {
    speed_2x
  } else {
    speed_3x
  }
}
