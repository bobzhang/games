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
  if !is_walkable(get_tile(game, gx0, gz0)) {
    return true
  }
  if !is_walkable(get_tile(game, gx1, gz0)) {
    return true
  }
  if !is_walkable(get_tile(game, gx0, gz1)) {
    return true
  }
  if !is_walkable(get_tile(game, gx1, gz1)) {
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
  @utils.first_index_by(game.enemies, fn(slot) { !slot.active })
}

///|
/// Returns the first inactive projectile slot index, or `-1` if none.
pub fn alloc_projectile(game : Game) -> Int {
  @utils.first_index_by(game.projectiles, fn(slot) { !slot.active })
}

///|
/// Returns the first inactive particle slot index, or `-1` if none.
pub fn alloc_particle(game : Game) -> Int {
  @utils.first_index_by(game.particles, fn(slot) { !slot.active })
}

///|
/// Returns the first inactive loot slot index, or `-1` if none.
pub fn alloc_loot(game : Game) -> Int {
  @utils.first_index_by(game.loot, fn(slot) { !slot.active })
}

///|
/// Returns the first inactive trap slot index, or `-1` if none.
pub fn alloc_trap(game : Game) -> Int {
  @utils.first_index_by(game.traps, fn(slot) { !slot.active })
}

///|
/// Returns the first inactive torch slot index, or `-1` if none.
pub fn alloc_torch(game : Game) -> Int {
  @utils.first_index_by(game.torches, fn(slot) { !slot.active })
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
  if !is_blocked(game, test_x, test_z, radius) {
    return (nx, nz)
  }
  // Try sliding along X
  if !is_blocked(game, test_x, from_z, radius) {
    let x_dir = signf(nx)
    return (x_dir, 0.0)
  }
  // Try sliding along Z
  if !is_blocked(game, from_x, test_z, radius) {
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
  @utils.any_by(game.buffs, fn(buff) { buff.active && buff.kind == kind })
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
    if !buff.active {
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
  } else if kind == loot_equip_weapon {
    "Weapon"
  } else if kind == loot_equip_armor {
    "Armor"
  } else if kind == loot_equip_ring {
    "Ring"
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

// Screen shake

///|
/// Triggers screen shake with given intensity and duration.
pub fn trigger_shake(game : Game, intensity : Float, duration : Float) -> Unit {
  if intensity > game.shake_intensity {
    game.shake_intensity = intensity
    game.shake_timer = duration
  }
}

///|
/// Updates the screen shake timer, decaying intensity over time.
pub fn update_shake(game : Game, dt : Float) -> Unit {
  if game.shake_timer > 0.0 {
    game.shake_timer -= dt
    if game.shake_timer <= 0.0 {
      game.shake_timer = 0.0
      game.shake_intensity = 0.0
    } else {
      // Decay intensity
      game.shake_intensity *= 0.92
    }
  }
}

///|
/// Returns a random shake offset for the current frame.
pub fn get_shake_offset(game : Game) -> (Float, Float) {
  if game.shake_timer > 0.0 {
    let ox = rand_rangef(game, -game.shake_intensity, game.shake_intensity)
    let oy = rand_rangef(game, -game.shake_intensity, game.shake_intensity)
    (ox, oy)
  } else {
    (0.0, 0.0)
  }
}

// Floating damage numbers

///|
/// Returns the first inactive damage number slot index, or `-1` if none.
pub fn alloc_damage_number(game : Game) -> Int {
  @utils.first_index_by(game.damage_numbers, fn(slot) { !slot.active })
}

///|
/// Spawns a floating damage number at a world position.
pub fn spawn_damage_number(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  value : Int,
  r : Int,
  g : Int,
  b : Int,
  is_crit : Bool,
) -> Unit {
  let idx = alloc_damage_number(game)
  if idx < 0 {
    return
  }
  let dn = game.damage_numbers[idx]
  dn.active = true
  dn.x = wx + rand_rangef(game, -0.3, 0.3)
  dn.y = wy
  dn.z = wz + rand_rangef(game, -0.3, 0.3)
  dn.value = value
  dn.timer = if is_crit { 1.5 } else { 1.0 }
  dn.r = r
  dn.g = g
  dn.b = b
  dn.is_crit = is_crit
}

///|
/// Updates all floating damage numbers (rise and fade).
pub fn update_damage_numbers(game : Game, dt : Float) -> Unit {
  for dn in game.damage_numbers {
    if !dn.active {
      continue
    }
    dn.timer -= dt
    dn.y += 1.5 * dt
    if dn.timer <= 0.0 {
      dn.active = false
    }
  }
}

// Knockback

///|
/// Applies knockback to an enemy away from a source point.
pub fn apply_knockback(
  game : Game,
  e : Enemy,
  source_x : Float,
  source_z : Float,
  force : Float,
) -> Unit {
  let dx = e.x - source_x
  let dz = e.z - source_z
  let d = @math.hypotf(dx, dz)
  if d < 0.01 {
    return
  }
  let nx = dx / d
  let nz = dz / d
  let new_x = e.x + nx * force
  let new_z = e.z + nz * force
  let radius : Float = 0.4
  if !is_blocked(game, new_x, e.z, radius) {
    e.x = new_x
  }
  if !is_blocked(game, e.x, new_z, radius) {
    e.z = new_z
  }
}

///|
/// Returns rarity display name.
pub fn get_rarity_name(rarity : Int) -> String {
  if rarity == 0 {
    "Common"
  } else if rarity == 1 {
    "Uncommon"
  } else if rarity == 2 {
    "Rare"
  } else if rarity == 3 {
    "Epic"
  } else if rarity == 4 {
    "Legendary"
  } else {
    "Common"
  }
}

///|
/// Returns rarity color R component.
pub fn get_rarity_color_r(rarity : Int) -> Int {
  if rarity == 0 {
    200
  } else if rarity == 1 {
    80
  } else if rarity == 2 {
    50
  } else if rarity == 3 {
    180
  } else if rarity == 4 {
    255
  } else {
    200
  }
}

///|
/// Returns rarity color G component.
pub fn get_rarity_color_g(rarity : Int) -> Int {
  if rarity == 0 {
    200
  } else if rarity == 1 {
    220
  } else if rarity == 2 {
    120
  } else if rarity == 3 {
    80
  } else if rarity == 4 {
    165
  } else {
    200
  }
}

///|
/// Returns rarity color B component.
pub fn get_rarity_color_b(rarity : Int) -> Int {
  if rarity == 0 {
    200
  } else if rarity == 1 {
    80
  } else if rarity == 2 {
    255
  } else if rarity == 3 {
    220
  } else if rarity == 4 {
    0
  } else {
    200
  }
}

///|
/// Returns ring effect display name.
pub fn get_ring_name(kind : Int) -> String {
  if kind == ring_mana_regen {
    "Ring of Wisdom"
  } else if kind == ring_life_steal {
    "Vampiric Ring"
  } else if kind == ring_thorns {
    "Thorned Ring"
  } else if kind == ring_gold_find {
    "Ring of Fortune"
  } else if kind == ring_crit_chance {
    "Ring of Precision"
  } else {
    "Ring"
  }
}

///|
/// Computes total player attack including equipment weapon bonus.
pub fn calc_player_attack_with_equip(game : Game) -> Int {
  let base = calc_player_attack(game)
  base + game.equip_weapon_bonus
}

///|
/// Computes total player defense including equipment armor bonus.
pub fn calc_player_defense_with_equip(game : Game) -> Int {
  let base = calc_player_defense(game)
  base + game.equip_armor_bonus
}

///|
/// Checks if enemy has line of sight to player (no walls in between).
pub fn has_line_of_sight(
  game : Game,
  from_x : Float,
  from_z : Float,
  to_x : Float,
  to_z : Float,
) -> Bool {
  let dx = to_x - from_x
  let dz = to_z - from_z
  let d = @math.hypotf(dx, dz)
  if d < 0.5 {
    return true
  }
  let steps = (d / 0.5).to_int() + 1
  let step_x = dx / Float::from_int(steps)
  let step_z = dz / Float::from_int(steps)
  let mut cx = from_x
  let mut cz = from_z
  for i in 0..<steps {
    cx += step_x
    cz += step_z
    let gx = world_to_grid_x(cx)
    let gz = world_to_grid_z(cz)
    if get_tile(game, gx, gz) == tile_wall {
      return false
    }
    ignore(i)
  }
  true
}

///|
/// Returns the boss phase (1, 2, or 3) based on current HP fraction.
pub fn get_boss_phase(hp : Int, max_hp : Int) -> Int {
  let frac = Float::from_int(hp) / Float::from_int(max_hp)
  if frac > boss_phase2_threshold {
    1
  } else if frac > boss_phase3_threshold {
    2
  } else {
    3
  }
}

// Hitstop

///|
/// Triggers hitstop (a brief game-freeze on impactful hits).
pub fn trigger_hitstop(game : Game, duration : Float) -> Unit {
  if duration > game.hitstop_timer {
    game.hitstop_timer = duration
  }
}

///|
/// Updates the hitstop timer. Returns true when the game should be frozen.
pub fn update_hitstop(game : Game, dt : Float) -> Bool {
  if game.hitstop_timer > 0.0 {
    game.hitstop_timer -= dt
    if game.hitstop_timer < 0.0 {
      game.hitstop_timer = 0.0
    }
    true
  } else {
    false
  }
}

///|
/// Returns a short display name for a buff kind.
pub fn get_buff_name(kind : Int) -> String {
  if kind == buff_speed {
    "SPD"
  } else if kind == buff_strength {
    "STR"
  } else if kind == buff_shield {
    "SHD"
  } else {
    "BUF"
  }
}

///|
/// Returns RGB color for a buff kind.
pub fn get_buff_color(kind : Int) -> (Int, Int, Int) {
  if kind == buff_speed {
    (100, 255, 100)
  } else if kind == buff_strength {
    (255, 100, 80)
  } else if kind == buff_shield {
    (80, 150, 255)
  } else {
    (200, 200, 200)
  }
}

// Weapon discovery helpers

///|
/// Returns the weapon kind index (0..5) for discovered_weapons array.
pub fn weapon_kind_index(w : WeaponKind) -> Int {
  match w {
    Sword => 0
    Axe => 1
    Mace => 2
    Dagger => 3
    Staff => 4
    Bow => 5
  }
}

///|
/// Returns weapon kind from index.
pub fn weapon_kind_from_index(i : Int) -> WeaponKind {
  if i == 0 {
    Sword
  } else if i == 1 {
    Axe
  } else if i == 2 {
    Mace
  } else if i == 3 {
    Dagger
  } else if i == 4 {
    Staff
  } else {
    Bow
  }
}

///|
/// Cycles to the next discovered weapon.
pub fn next_discovered_weapon(game : Game) -> WeaponKind {
  let current = weapon_kind_index(game.player_weapon)
  // Find the next discovered weapon after current
  for offset in 1..<=max_discovered_weapons {
    let idx = (current + offset) % max_discovered_weapons
    if game.discovered_weapons[idx] {
      return weapon_kind_from_index(idx)
    }
  }
  game.player_weapon
}

///|
/// Rolls a random weapon affix for rare+ items.
pub fn roll_affix(game : Game, rarity : Int) -> WeaponAffix {
  if rarity < 2 {
    return AffixNone
  }
  let roll = rand_range(game, 0, affix_count - 1)
  if roll == 0 {
    AffixVampiric
  } else if roll == 1 {
    AffixFlaming
  } else if roll == 2 {
    AffixIcy
  } else if roll == 3 {
    AffixSwift
  } else if roll == 4 {
    AffixHeavy
  } else {
    AffixKeen
  }
}

///|
/// Generates 3 random level-up card indices (no duplicates).
pub fn roll_levelup_cards(game : Game) -> Unit {
  game.levelup_cards[0] = rand_range(game, 0, levelup_card_count - 1)
  game.levelup_cards[1] = rand_range(game, 0, levelup_card_count - 1)
  // Avoid duplicate with first
  while game.levelup_cards[1] == game.levelup_cards[0] {
    game.levelup_cards[1] = rand_range(game, 0, levelup_card_count - 1)
  }
  game.levelup_cards[2] = rand_range(game, 0, levelup_card_count - 1)
  // Avoid duplicates with first two
  while game.levelup_cards[2] == game.levelup_cards[0] ||
        game.levelup_cards[2] == game.levelup_cards[1] {
    game.levelup_cards[2] = rand_range(game, 0, levelup_card_count - 1)
  }
}

///|
/// Returns name and description for a level-up card type.
pub fn get_levelup_card_text(card_id : Int) -> (String, String) {
  if card_id == 0 {
    ("+5 Max HP", "Increases maximum health by 5")
  } else if card_id == 1 {
    ("+3 ATK", "Increases attack power by 3")
  } else if card_id == 2 {
    ("+10 Max Mana", "Increases maximum mana by 10")
  } else if card_id == 3 {
    ("+2 DEF", "Increases defense by 2")
  } else if card_id == 4 {
    ("+5% Crit", "Increases crit chance via DEX +5")
  } else {
    ("+2 STR/DEX/INT", "Increases all stats by 2")
  }
}

///|
/// Generates build-weighted shrine boons based on player stats.
pub fn generate_shrine_boons(game : Game) -> Unit {
  // Warrior-leaning: high HP build
  if game.player_max_hp > 130 && game.player_str > 12 {
    game.shrine_boon_names[0] = "Berserker's Fury (+20% DMG < 30% HP)"
    game.shrine_boon_ids[0] = 10
  } else {
    game.shrine_boon_names[0] = "+15 Max HP"
    game.shrine_boon_ids[0] = 0
  }
  // Mage-leaning: high INT build
  if game.player_int_stat > 14 && game.player_max_mana > 70 {
    game.shrine_boon_names[1] = "Mana Shield (absorb DMG with mana)"
    game.shrine_boon_ids[1] = 11
  } else {
    game.shrine_boon_names[1] = "+10 Max Mana"
    game.shrine_boon_ids[1] = 1
  }
  // Rogue-leaning: high DEX build
  if game.player_dex > 14 {
    game.shrine_boon_names[2] = "Shadow Step (invis after dodge)"
    game.shrine_boon_ids[2] = 12
  } else {
    game.shrine_boon_names[2] = "+5 ATK"
    game.shrine_boon_ids[2] = 2
  }
}

///|
/// Buff kind id for berserker fury effect.
pub let buff_berserker : Int = 3

///|
/// Buff kind id for mana shield effect.
pub let buff_mana_shield : Int = 4

///|
/// Buff kind id for shadow step effect.
pub let buff_shadow_step : Int = 5

// Get theme name
