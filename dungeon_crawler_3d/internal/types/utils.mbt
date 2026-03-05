// Math helpers

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
/// Returns the smaller of two float values.
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
/// Returns `-1.0`, `0.0`, or `1.0` based on the sign of `v`.
pub fn signf(v : Float) -> Float {
  if v > 0.0 {
    1.0
  } else if v < 0.0 {
    -1.0
  } else {
    0.0
  }
}

// Grid helpers

///|
/// Returns whether the grid coordinate lies inside dungeon bounds.
pub fn in_bounds(gx : Int, gy : Int) -> Bool {
  gx >= 0 && gy >= 0 && gx < grid_w && gy < grid_h
}

///|
/// Converts a grid coordinate to the flat tile array index.
pub fn tile_index(gx : Int, gy : Int) -> Int {
  gy * grid_w + gx
}

///|
/// Returns the tile id at grid coordinate, or `tile_wall` when out of bounds.
pub fn get_tile(game : Game, gx : Int, gy : Int) -> Int {
  if in_bounds(gx, gy) {
    game.tiles[tile_index(gx, gy)]
  } else {
    tile_wall
  }
}

///|
/// Sets a tile id when the grid coordinate is in bounds.
pub fn set_tile(game : Game, gx : Int, gy : Int, tile : Int) -> Unit {
  if in_bounds(gx, gy) {
    game.tiles[tile_index(gx, gy)] = tile
  }
}

///|
/// Returns whether a tile id can be traversed by actors.
pub fn is_walkable(tile : Int) -> Bool {
  tile == tile_floor ||
  tile == tile_door ||
  tile == tile_stairs ||
  tile == tile_chest ||
  tile == tile_trap ||
  tile == tile_shrine ||
  tile == tile_shop
}

// Convert world position to grid position

///|
/// Converts world X position to grid X index.
pub fn world_to_grid_x(wx : Float) -> Int {
  (wx / cell_size).to_int()
}

///|
/// Converts world Z position to grid Y index.
pub fn world_to_grid_z(wz : Float) -> Int {
  (wz / cell_size).to_int()
}

// Convert grid position to world center

///|
/// Converts grid X index to world-space cell center X.
pub fn grid_to_world_x(gx : Int) -> Float {
  Float::from_int(gx) * cell_size + cell_size / 2.0
}

///|
/// Converts grid Y index to world-space cell center Z.
pub fn grid_to_world_z(gy : Int) -> Float {
  Float::from_int(gy) * cell_size + cell_size / 2.0
}

// Check if a world position is blocked by walls

///|
/// Checks circle-vs-walls collision against nearby tiles using corner sampling.
pub fn is_blocked(game : Game, wx : Float, wz : Float, radius : Float) -> Bool {
  // Check four corners of bounding box
  let gx0 = world_to_grid_x(wx - radius)
  let gz0 = world_to_grid_z(wz - radius)
  let gx1 = world_to_grid_x(wx + radius)
  let gz1 = world_to_grid_z(wz + radius)
  if not(is_walkable(get_tile(game, gx0, gz0))) {
    return true
  }
  if not(is_walkable(get_tile(game, gx1, gz0))) {
    return true
  }
  if not(is_walkable(get_tile(game, gx0, gz1))) {
    return true
  }
  if not(is_walkable(get_tile(game, gx1, gz1))) {
    return true
  }
  false
}

// Check if blocked including locked doors

// Distance between two points in 2D (xz plane)

///|
/// Computes Euclidean distance in the XZ plane.
pub fn dist2d(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  @math.hypotf(x2 - x1, z2 - z1)
}

// Squared distance (avoids sqrt for comparisons)

///|
/// Computes squared XZ distance without taking a square root.
pub fn dist2d_sq(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  let dx = x2 - x1
  let dz = z2 - z1
  dx * dx + dz * dz
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
/// Returns a random integer in the inclusive range `[low, high]`.
pub fn rand_range(game : Game, low : Int, high : Int) -> Int {
  if high <= low {
    low
  } else {
    low + rand_next(game) % (high - low + 1)
  }
}

///|
/// Returns a random float in the inclusive range `[low, high]`.
pub fn rand_rangef(game : Game, low : Float, high : Float) -> Float {
  let n = Float::from_int(rand_next(game) % 10000) / 10000.0
  low + (high - low) * n
}

// Weighted random selection: returns index based on weights

///|
/// Selects an index using weighted random sampling.
pub fn rand_weighted(game : Game, weights : Array[Int]) -> Int {
  let mut total = 0
  for weight in weights {
    total += weight
  }
  if total <= 0 {
    return 0
  }
  let mut roll = rand_range(game, 0, total - 1)
  for i in 0..<weights.length() {
    roll -= weights[i]
    if roll < 0 {
      return i
    }
  }
  weights.length() - 1
}

// Allocators

///|
/// Returns the first inactive enemy slot index, or `-1` if none.
pub fn alloc_enemy(game : Game) -> Int {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      return i
    }
  }
  -1
}

///|
/// Returns the first inactive projectile slot index, or `-1` if none.
pub fn alloc_projectile(game : Game) -> Int {
  for i in 0..<game.projectiles.length() {
    if not(game.projectiles[i].active) {
      return i
    }
  }
  -1
}

///|
/// Returns the first inactive particle slot index, or `-1` if none.
pub fn alloc_particle(game : Game) -> Int {
  for i in 0..<game.particles.length() {
    if not(game.particles[i].active) {
      return i
    }
  }
  -1
}

///|
/// Returns the first inactive loot slot index, or `-1` if none.
pub fn alloc_loot(game : Game) -> Int {
  for i in 0..<game.loot.length() {
    if not(game.loot[i].active) {
      return i
    }
  }
  -1
}

///|
/// Returns the first inactive trap slot index, or `-1` if none.
pub fn alloc_trap(game : Game) -> Int {
  for i in 0..<game.traps.length() {
    if not(game.traps[i].active) {
      return i
    }
  }
  -1
}

///|
/// Returns the first inactive torch slot index, or `-1` if none.
pub fn alloc_torch(game : Game) -> Int {
  for i in 0..<game.torches.length() {
    if not(game.torches[i].active) {
      return i
    }
  }
  -1
}

// Spawn particles

///|
/// Spawns a randomized particle burst at world position.
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
    p.vy = rand_rangef(game, 1.0, 5.0)
    p.vz = rand_rangef(game, -2.0, 2.0)
    p.life = rand_rangef(game, 0.3, 0.8)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.03, 0.1)
    ignore(i)
  }
}

// Spawn directional particles (for spell effects)

///|
/// Spawns particles with directional bias for spell/projectile effects.
pub fn spawn_directional_particles(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  dir_x : Float,
  dir_z : Float,
  count : Int,
  r : Int,
  g : Int,
  b : Int,
  speed : Float,
) -> Unit {
  for i in 0..<count {
    let idx = alloc_particle(game)
    if idx < 0 {
      return
    }
    let p = game.particles[idx]
    p.active = true
    p.x = wx + rand_rangef(game, -0.2, 0.2)
    p.y = wy + rand_rangef(game, -0.1, 0.3)
    p.z = wz + rand_rangef(game, -0.2, 0.2)
    p.vx = dir_x * speed + rand_rangef(game, -1.0, 1.0)
    p.vy = rand_rangef(game, 0.5, 2.0)
    p.vz = dir_z * speed + rand_rangef(game, -1.0, 1.0)
    p.life = rand_rangef(game, 0.2, 0.5)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.04, 0.12)
    ignore(i)
  }
}

// Mark explored tiles around player position

///|
/// Marks tiles around the player as explored for minimap/fog systems.
pub fn update_explored(game : Game) -> Unit {
  let gx = world_to_grid_x(game.player_x)
  let gz = world_to_grid_z(game.player_z)
  let radius = 4
  for dy in -radius..<=radius {
    for dx in -radius..<=radius {
      let nx = gx + dx
      let nz = gz + dy
      if in_bounds(nx, nz) {
        game.explored[tile_index(nx, nz)] = true
      }
    }
  }
}

// Count active enemies

///|
/// Counts currently active enemies.
pub fn count_active_enemies(game : Game) -> Int {
  let mut count = 0
  for enemy in game.enemies {
    if enemy.active {
      count += 1
    }
  }
  count
}

// Normalize angle to -pi..pi range

// Add message to log

///|
/// Pushes a new colored message into the scrolling message log.
pub fn add_message(
  game : Game,
  text : String,
  r : Int,
  g : Int,
  b : Int,
) -> Unit {
  // Shift messages down
  for i = game.messages.length() - 1; i > 0; i = i - 1 {
    game.messages[i].text = game.messages[i - 1].text
    game.messages[i].timer = game.messages[i - 1].timer
    game.messages[i].r = game.messages[i - 1].r
    game.messages[i].g = game.messages[i - 1].g
    game.messages[i].b = game.messages[i - 1].b
  }
  // Add new at top
  if game.messages.length() > 0 {
    game.messages[0].text = text
    game.messages[0].timer = 4.0
    game.messages[0].r = r
    game.messages[0].g = g
    game.messages[0].b = b
  }
}

// Inventory helpers

// Get weapon stats

///|
/// Returns melee/ranged reach for the given weapon type.
pub fn get_weapon_range(weapon_type : WeaponKind) -> Float {
  match weapon_type {
    Sword => sword_range
    Axe => axe_range
    Mace => mace_range
    Dagger => dagger_range
    Staff => staff_range
    Bow => bow_range
  }
}

///|
/// Returns attack cooldown duration in seconds for the given weapon type.
pub fn get_weapon_cooldown(weapon_type : WeaponKind) -> Float {
  match weapon_type {
    Sword => sword_cooldown
    Axe => axe_cooldown
    Mace => mace_cooldown
    Dagger => dagger_cooldown
    Staff => staff_cooldown
    Bow => bow_cooldown
  }
}

///|
/// Returns attack damage multiplier for the given weapon type.
pub fn get_weapon_damage_mult(weapon_type : WeaponKind) -> Float {
  match weapon_type {
    Sword => sword_damage_mult
    Axe => axe_damage_mult
    Mace => mace_damage_mult
    Dagger => dagger_damage_mult
    Staff => staff_damage_mult
    Bow => bow_damage_mult
  }
}

///|
/// Returns display name for a weapon type id.
pub fn get_weapon_name(weapon_type : WeaponKind) -> String {
  match weapon_type {
    Sword => "Sword"
    Axe => "Axe"
    Mace => "Mace"
    Dagger => "Dagger"
    Staff => "Staff"
    Bow => "Bow"
  }
}

///|
/// Returns defense value granted by an armor type.
pub fn get_armor_defense(armor_type : Int) -> Int {
  if armor_type == armor_robes {
    robes_defense
  } else if armor_type == armor_leather {
    leather_defense
  } else if armor_type == armor_chain {
    chain_defense
  } else if armor_type == armor_plate {
    plate_defense
  } else {
    0
  }
}

///|
/// Returns display name for a spell type id.
pub fn get_spell_name(spell_type : Spell) -> String {
  match spell_type {
    Fireball => "Fireball"
    IceBolt => "Ice Bolt"
    Heal => "Heal"
    Shield => "Shield"
    Lightning => "Lightning"
    Teleport => "Teleport"
    _ => "None"
  }
}

///|
/// Returns mana cost for a spell type.
pub fn get_spell_mana_cost(spell_type : Spell) -> Int {
  match spell_type {
    Fireball => fireball_mana_cost
    IceBolt => ice_bolt_mana_cost
    Heal => heal_mana_cost
    Shield => shield_mana_cost
    Lightning => lightning_mana_cost
    Teleport => teleport_mana_cost
    _ => 0
  }
}

// Calculate total player defense (base + armor + buffs)

///|
/// Computes total player defense including armor and active shield buffs.
pub fn calc_player_defense(game : Game) -> Int {
  let mut total = game.player_def + get_armor_defense(game.player_armor)
  for buff in game.buffs {
    if buff.active && buff.kind == buff_shield {
      total += buff.value
    }
  }
  total
}

// Calculate total player attack (base + str + weapon + buffs)

///|
/// Computes total player attack including stats, weapon multiplier, and buffs.
pub fn calc_player_attack(game : Game) -> Int {
  let base = game.player_atk + game.player_str / 3
  let mult = get_weapon_damage_mult(game.player_weapon)
  let base_f = Float::from_int(base) * mult
  let mut total = base_f.to_int()
  for buff in game.buffs {
    if buff.active && buff.kind == buff_strength {
      total += buff.value
    }
  }
  total
}

// Get enemy type name

///|
/// Returns display name for an enemy kind id.
pub fn get_enemy_name(kind : EnemyKind) -> String {
  match kind {
    Skeleton => "Skeleton"
    Archer => "Archer"
    Golem => "Golem"
    Wraith => "Wraith"
    DragonBoss => "Dragon"
    Slime => "Slime"
    Bat => "Bat"
    Spider => "Spider"
    Minotaur => "Minotaur"
    Lich => "Lich"
    Mimic => "Mimic"
    _ => "Unknown"
  }
}

// Get XP value for enemy type

// Get rarity name

// Get class name

// Check line of sight between two grid cells

// Simple pathfinding step: returns direction to move toward target
// Returns (dx, dz) normalized direction

///|
/// Returns a normalized step direction that attempts to move toward a target while avoiding walls.
pub fn pathfind_step(
  game : Game,
  from_x : Float,
  from_z : Float,
  to_x : Float,
  to_z : Float,
) -> (Float, Float) {
  let dx = to_x - from_x
  let dz = to_z - from_z
  let d = @math.hypotf(dx, dz)
  if d < 0.1 {
    return (0.0, 0.0)
  }
  let nx = dx / d
  let nz = dz / d
  // Try direct path first
  let radius : Float = 0.4
  let step : Float = 0.5
  let test_x = from_x + nx * step
  let test_z = from_z + nz * step
  if not(is_blocked(game, test_x, test_z, radius)) {
    return (nx, nz)
  }
  // Try sliding along X
  if not(is_blocked(game, test_x, from_z, radius)) {
    let x_dir = signf(nx)
    return (x_dir, 0.0)
  }
  // Try sliding along Z
  if not(is_blocked(game, from_x, test_z, radius)) {
    let z_dir = signf(nz)
    return (0.0, z_dir)
  }
  (0.0, 0.0)
}

// Find a random walkable position in a room

// Check if player has an active buff of given kind

///|
/// Returns whether the player currently has an active buff kind.
pub fn has_buff(game : Game, kind : Int) -> Bool {
  for buff in game.buffs {
    if buff.active && buff.kind == kind {
      return true
    }
  }
  false
}

// Add a buff to player

///|
/// Adds or refreshes a player buff with duration and value.
pub fn add_buff(game : Game, kind : Int, duration : Float, value : Int) -> Unit {
  // Check if already have this buff, refresh it
  for buff in game.buffs {
    if buff.active && buff.kind == kind {
      buff.timer = duration
      buff.value = value
      return
    }
  }
  // Find empty slot
  for buff in game.buffs {
    if not(buff.active) {
      buff.active = true
      buff.kind = kind
      buff.timer = duration
      buff.value = value
      return
    }
  }
}

// Update buff timers

///|
/// Decrements buff timers and clears buffs that expire this frame.
pub fn update_buffs(game : Game, dt : Float) -> Unit {
  for buff in game.buffs {
    if buff.active {
      buff.timer -= dt
      if buff.timer <= 0.0 {
        buff.active = false
      }
    }
  }
}

// Update message timers

///|
/// Decrements message timers and clears expired message visibility.
pub fn update_messages(game : Game, dt : Float) -> Unit {
  for message in game.messages {
    if message.timer > 0.0 {
      message.timer -= dt
      if message.timer < 0.0 {
        message.timer = 0.0
      }
    }
  }
}

// Get trap name

// Get loot name

///|
/// Returns display name for a loot kind id.
pub fn get_loot_name(kind : Int) -> String {
  if kind == loot_health_potion {
    "Health Potion"
  } else if kind == loot_mana_potion {
    "Mana Potion"
  } else if kind == loot_damage_boost {
    "Damage Scroll"
  } else if kind == loot_armor {
    "Armor Shard"
  } else if kind == loot_speed_potion {
    "Speed Potion"
  } else if kind == loot_strength_potion {
    "Strength Potion"
  } else if kind == loot_gold_pile {
    "Gold"
  } else if kind == loot_key {
    "Key"
  } else if kind == loot_boss_key {
    "Boss Key"
  } else {
    "Unknown"
  }
}

///|
/// Converts an integer to a TrapKind enum value.
pub fn trap_kind_from_int(n : Int) -> TrapKind {
  if n == 0 {
    Spike
  } else if n == 1 {
    Arrow
  } else if n == 2 {
    Flame
  } else if n == 3 {
    Poison
  } else if n == 4 {
    Pitfall
  } else {
    Spike
  }
}

///|
/// Cycles to the next weapon in order.
pub fn next_weapon(w : WeaponKind) -> WeaponKind {
  match w {
    Sword => Axe
    Axe => Mace
    Mace => Dagger
    Dagger => Staff
    Staff => Bow
    _ => Sword
  }
}

///|
/// Converts an integer to a Spell enum value.
pub fn spell_from_int(n : Int) -> Spell {
  if n == 1 {
    Fireball
  } else if n == 2 {
    IceBolt
  } else if n == 3 {
    Heal
  } else if n == 4 {
    Shield
  } else if n == 5 {
    Lightning
  } else if n == 6 {
    Teleport
  } else {
    None
  }
}

///|
/// Converts an integer to a ShipClass enum value.
pub fn ship_class_from_int(n : Int) -> ShipClass {
  if n == 0 {
    Warrior
  } else if n == 1 {
    Rogue
  } else if n == 2 {
    Mage
  } else {
    Warrior
  }
}

// Get theme name
