///|
pub fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
}

///|
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
pub fn sqrtf(a : Float) -> Float {
  Float::from_double(a.to_double().sqrt())
}

///|
pub fn vec2(x : Float, y : Float) -> Vec2 {
  { x, y, }
}

///|
pub fn vec2_zero() -> Vec2 {
  { x: 0.0, y: 0.0, }
}

///|
pub fn vec2_add(a : Vec2, b : Vec2) -> Vec2 {
  { x: a.x + b.x, y: a.y + b.y, }
}

///|
pub fn vec2_sub(a : Vec2, b : Vec2) -> Vec2 {
  { x: a.x - b.x, y: a.y - b.y, }
}

///|
pub fn vec2_scale(v : Vec2, s : Float) -> Vec2 {
  { x: v.x * s, y: v.y * s, }
}

///|
pub fn vec2_len(v : Vec2) -> Float {
  sqrtf(v.x * v.x + v.y * v.y)
}

///|
pub fn vec2_dist(a : Vec2, b : Vec2) -> Float {
  let dx = a.x - b.x
  let dy = a.y - b.y
  sqrtf(dx * dx + dy * dy)
}

///|
pub fn vec2_dist_sq(a : Vec2, b : Vec2) -> Float {
  let dx = a.x - b.x
  let dy = a.y - b.y
  dx * dx + dy * dy
}

///|
pub fn vec2_normalize(v : Vec2) -> Vec2 {
  let len = vec2_len(v)
  if len < 0.001 {
    vec2_zero()
  } else {
    { x: v.x / len, y: v.y / len, }
  }
}

///|
pub fn vec2_dot(a : Vec2, b : Vec2) -> Float {
  a.x * b.x + a.y * b.y
}

///|
pub fn vec2_rotate(v : Vec2, angle : Float) -> Vec2 {
  let c = cosf(angle)
  let s = sinf(angle)
  { x: v.x * c - v.y * s, y: v.x * s + v.y * c, }
}

///|
pub fn vec2_lerp(a : Vec2, b : Vec2, t : Float) -> Vec2 {
  { x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t, }
}

///|
pub fn angle_to(from : Vec2, to : Vec2) -> Float {
  let dx = to.x - from.x
  let dy = to.y - from.y
  Float::from_double(@math.atan2(dy.to_double(), dx.to_double()))
}

///|
pub fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
let rng_state : Ref[Int] = { val: 12345, }

///|
pub fn seed_rng(s : Int) -> Unit {
  rng_state.val = s
}

///|
pub fn rng_next() -> Int {
  rng_state.val = rng_state.val * 1103515245 + 12345
  let v = rng_state.val / 65536
  if v < 0 {
    -v
  } else {
    v
  }
}

///|
pub fn rng_int(max : Int) -> Int {
  if max <= 0 {
    0
  } else {
    rng_next() % max
  }
}

///|
pub fn rng_float() -> Float {
  Float::from_int(rng_next() % 10000) / 10000.0
}

///|
pub fn rng_range(lo : Float, hi : Float) -> Float {
  lo + rng_float() * (hi - lo)
}

///|
pub fn rng_sign() -> Float {
  if rng_next() % 2 == 0 {
    1.0
  } else {
    -1.0
  }
}

// Pool allocation helpers

///|
pub fn alloc_projectile(pool : Array[Projectile]) -> Int {
  for i in 0..<pool.length() {
    if !pool[i].active {
      return i
    }
  }
  -1
}

///|
pub fn alloc_enemy(pool : Array[Enemy]) -> Int {
  for i in 0..<pool.length() {
    if !pool[i].active {
      return i
    }
  }
  -1
}

///|
pub fn alloc_particle(pool : Array[Particle]) -> Int {
  for i in 0..<pool.length() {
    if !pool[i].active {
      return i
    }
  }
  // Evict oldest
  let mut oldest = 0
  let mut oldest_life : Float = 1.0
  for i in 0..<pool.length() {
    let ratio : Float = pool[i].life / pool[i].max_life
    if ratio < oldest_life {
      oldest_life = ratio
      oldest = i
    }
  }
  oldest
}

///|
pub fn alloc_damage_number(pool : Array[DamageNumber]) -> Int {
  for i in 0..<pool.length() {
    if !pool[i].active {
      return i
    }
  }
  0
}

///|
pub fn count_active_enemies(pool : Array[Enemy]) -> Int {
  let mut count = 0
  for i in 0..<pool.length() {
    if pool[i].active {
      count += 1
    }
  }
  count
}

// Constructors

///|
pub fn new_weapon(kind : WeaponKind) -> Weapon {
  match kind {
    Laser =>
      {
        kind: Laser,
        damage: 2,
        fire_rate: 0.15,
        fire_timer: 0.0,
        projectile_speed: 600.0,
        spread: 0.02,
        projectile_count: 1,
        range: 500.0,
        heat_cost: 5.0,
      }
    Shotgun =>
      {
        kind: Shotgun,
        damage: 1,
        fire_rate: 0.4,
        fire_timer: 0.0,
        projectile_speed: 500.0,
        spread: 0.3,
        projectile_count: 5,
        range: 300.0,
        heat_cost: 12.0,
      }
    Missile =>
      {
        kind: Missile,
        damage: 4,
        fire_rate: 0.6,
        fire_timer: 0.0,
        projectile_speed: 350.0,
        spread: 0.05,
        projectile_count: 1,
        range: 600.0,
        heat_cost: 18.0,
      }
    Railgun =>
      {
        kind: Railgun,
        damage: 8,
        fire_rate: 1.2,
        fire_timer: 0.0,
        projectile_speed: 1200.0,
        spread: 0.0,
        projectile_count: 1,
        range: 800.0,
        heat_cost: 30.0,
      }
    Flak =>
      {
        kind: Flak,
        damage: 1,
        fire_rate: 0.25,
        fire_timer: 0.0,
        projectile_speed: 400.0,
        spread: 0.5,
        projectile_count: 8,
        range: 250.0,
        heat_cost: 10.0,
      }
    Beam =>
      {
        kind: Beam,
        damage: 1,
        fire_rate: 0.05,
        fire_timer: 0.0,
        projectile_speed: 900.0,
        spread: 0.01,
        projectile_count: 1,
        range: 400.0,
        heat_cost: 3.0,
      }
  }
}

///|
pub fn new_projectile() -> Projectile {
  {
    active: false,
    pos: vec2_zero(),
    vel: vec2_zero(),
    damage: 0,
    lifetime: 0.0,
    radius: default_projectile_radius,
    friendly: true,
    piercing: false,
    homing_strength: 0.0,
    chain_count: 0,
    explosive_radius: 0.0,
    freezing: false,
    bounces: 0,
    weapon_kind: Laser,
  }
}

///|
pub fn new_enemy() -> Enemy {
  {
    active: false,
    kind: Drone,
    pos: vec2_zero(),
    vel: vec2_zero(),
    angle: 0.0,
    hp: 1,
    max_hp: 1,
    damage: 1,
    speed: 100.0,
    fire_timer: 0.0,
    fire_rate: 1.0,
    radius: 16.0,
    frozen_timer: 0.0,
    shield: 0,
    behavior_timer: 0.0,
    target_pos: vec2_zero(),
    score_value: 10,
  }
}

///|
pub fn new_particle() -> Particle {
  {
    active: false,
    pos: vec2_zero(),
    vel: vec2_zero(),
    life: 0.0,
    max_life: 1.0,
    size: 3.0,
    color: @raylib.white,
    shrink: true,
  }
}

///|
pub fn new_asteroid() -> Asteroid {
  {
    active: false,
    pos: vec2_zero(),
    vel: vec2_zero(),
    radius: 20.0,
    angle: 0.0,
    spin: 0.0,
    hp: asteroid_base_hp,
  }
}

///|
pub fn new_damage_number() -> DamageNumber {
  {
    active: false,
    pos: vec2_zero(),
    vel: vec2_zero(),
    life: 0.0,
    value: 0,
    color: @raylib.white,
  }
}

///|
pub fn new_pickup() -> Pickup {
  {
    active: false,
    kind: HealthPack,
    pos: vec2_zero(),
    radius: pickup_radius,
    lifetime: pickup_lifetime,
    pulse_timer: 0.0,
  }
}

///|
pub fn new_ship(weapon_kind : WeaponKind) -> Ship {
  {
    pos: vec2(arena_default_width / 2.0, arena_default_height / 2.0),
    vel: vec2_zero(),
    angle: 0.0,
    hp: ship_base_hp,
    max_hp: ship_base_hp,
    shield: ship_base_shield,
    max_shield: ship_base_shield,
    shield_regen_timer: 0.0,
    heat: 0.0,
    max_heat,
    heat_decay: heat_decay_rate,
    dash_cooldown: 0.0,
    dash_timer: 0.0,
    invincible_timer: 0.0,
    speed: ship_base_speed,
    drag: ship_drag,
    boost_mult: ship_boost_mult,
    weapon: new_weapon(weapon_kind),
    secondary: None,
    primary_mod: None,
    utility_mod: None,
    credits: 0,
    kills: 0,
    sectors_cleared: 0,
  }
}

///|
pub fn new_run_stats() -> RunStats {
  {
    score: 0,
    kills: 0,
    max_combo: 0,
    combo: 0,
    sectors_cleared: 0,
    credits_earned: 0,
    damage_dealt: 0,
    damage_taken: 0,
    shots_fired: 0,
    shots_hit: 0,
    time_played: 0.0,
    bosses_defeated: 0,
    mods_collected: 0,
  }
}

///|
pub fn new_meta() -> MetaProgress {
  {
    best_score: 0,
    highest_kills: 0,
    total_runs: 0,
    total_kills: 0,
    bosses_defeated: 0,
    sectors_explored: 0,
    unlocked_weapons: [Laser],
    unlocked_mods: [],
    run_history: [],
  }
}

///|
pub fn new_shake() -> ScreenShake {
  { intensity: 0.0, decay: shake_decay, offset_x: 0.0, offset_y: 0.0, }
}

///|
pub fn new_game() -> Game {
  let projectiles : Array[Projectile] = Array::new(capacity=projectile_pool_size)
  for _i in 0..<projectile_pool_size {
    projectiles.push(new_projectile())
  }
  let enemies : Array[Enemy] = Array::new(capacity=enemy_pool_size)
  for _i in 0..<enemy_pool_size {
    enemies.push(new_enemy())
  }
  let particles : Array[Particle] = Array::new(capacity=particle_pool_size)
  for _i in 0..<particle_pool_size {
    particles.push(new_particle())
  }
  let asteroids : Array[Asteroid] = Array::new(capacity=asteroid_pool_size)
  for _i in 0..<asteroid_pool_size {
    asteroids.push(new_asteroid())
  }
  let damage_numbers : Array[DamageNumber] = Array::new(
    capacity=damage_number_pool_size,
  )
  for _i in 0..<damage_number_pool_size {
    damage_numbers.push(new_damage_number())
  }
  let pickups : Array[Pickup] = Array::new(capacity=pickup_pool_size)
  for _i in 0..<pickup_pool_size {
    pickups.push(new_pickup())
  }
  {
    screen: Title,
    ship: new_ship(Laser),
    projectiles,
    enemies,
    boss: None,
    particles,
    asteroids,
    hazards: [],
    pickups,
    damage_numbers,
    sector_map: None,
    shop_items: [],
    stats: new_run_stats(),
    meta: new_meta(),
    shake: new_shake(),
    sound_queue: [],
    message: "",
    message_timer: 0.0,
    rng: 42,
    camera_x: 0.0,
    camera_y: 0.0,
    arena_width: arena_default_width,
    arena_height: arena_default_height,
    current_sector_kind: EmptySpace,
    wave_timer: wave_interval,
    wave_count: 0,
    sector_enemies_total: 0,
    sector_enemies_killed: 0,
    sector_cleared: false,
    boss_intro_timer: 0.0,
    paused: false,
    frame_count: 0,
  }
}

///|
pub fn weapon_color(kind : WeaponKind) -> @raylib.Color {
  match kind {
    Laser => color_laser
    Shotgun => color_shotgun
    Missile => color_missile
    Railgun => color_railgun
    Flak => color_flak
    Beam => color_beam
  }
}

///|
pub fn enemy_color(kind : EnemyKind) -> @raylib.Color {
  match kind {
    Drone => color_enemy_drone
    Fighter => color_enemy_fighter
    Kiter => color_enemy_kiter
    Swarm => color_enemy_swarm
    Turret => color_enemy_turret
    Carrier => color_enemy_carrier
    Bomber => color_enemy_bomber
    ShieldBearer => color_enemy_shield
  }
}

///|
pub fn spawn_damage_number(
  game : Game,
  x : Float,
  y : Float,
  value : Int,
  color : @raylib.Color,
) -> Unit {
  let idx = alloc_damage_number(game.damage_numbers)
  let dn = game.damage_numbers[idx]
  dn.active = true
  dn.pos = vec2(x, y)
  dn.vel = vec2(rng_range(-20.0, 20.0), -damage_number_speed)
  dn.life = damage_number_life
  dn.value = value
  dn.color = color
}

///|
pub fn add_shake(shake : ScreenShake, amount : Float) -> Unit {
  shake.intensity = maxf(shake.intensity, amount)
}

///|
pub fn push_sound(game : Game, event : SoundEvent) -> Unit {
  game.sound_queue.push(event)
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}
