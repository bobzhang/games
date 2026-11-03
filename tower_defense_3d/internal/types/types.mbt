// Status effect on an enemy

///|
/// Active debuff or buff applied to an enemy with duration and strength.
pub(all) struct StatusEffect {
  mut kind : Int32
  mut duration : Float
  mut strength : Float
  mut tick_timer : Float
}

///|
/// Creates an empty status effect with no active debuff.
pub fn StatusEffect::none() -> StatusEffect {
  { kind: effect_none, duration: 0.0, strength: 0.0, tick_timer: 0.0, }
}

///|
/// Creates a status effect with the given `kind`, `duration`, and `strength`.
pub fn StatusEffect::StatusEffect(
  kind : Int32,
  duration : Float,
  strength : Float,
) -> StatusEffect {
  { kind, duration, strength, tick_timer: 0.0, }
}

// Tower entity

///|
/// Tower entity with targeting, upgrade level, and attack state.
pub(all) struct Tower {
  mut active : Bool
  mut kind : TowerKind
  mut gx : Int32
  mut gy : Int32
  mut level : Int32
  mut reload_timer : Float
  mut target_idx : Int32
  mut angle : Float
  mut targeting_mode : TargetPriority
  mut kills : Int32
  mut total_damage : Float
  mut special_timer : Float
  mut special_active : Bool
  mut buff_damage : Float
  mut buff_range : Float
  mut buff_rate : Float
  mut sell_value : Int32
}

///|
/// Creates an inactive tower slot for use in the entity pool.
pub fn Tower::inactive() -> Tower {
  {
    active: false,
    kind: Arrow,
    gx: 0,
    gy: 0,
    level: 1,
    reload_timer: 0.0,
    target_idx: -1,
    angle: 0.0,
    targeting_mode: First,
    kills: 0,
    total_damage: 0.0,
    special_timer: 0.0,
    special_active: false,
    buff_damage: 0.0,
    buff_range: 0.0,
    buff_rate: 0.0,
    sell_value: 0,
  }
}

///|
/// Creates a new active tower of the given `kind` at grid position (`gx`, `gy`).
pub fn Tower::Tower(kind : TowerKind, gx : Int32, gy : Int32) -> Tower {
  {
    active: true,
    kind,
    gx,
    gy,
    level: 1,
    reload_timer: 0.0,
    target_idx: -1,
    angle: 0.0,
    targeting_mode: First,
    kills: 0,
    total_damage: 0.0,
    special_timer: 0.0,
    special_active: false,
    buff_damage: 0.0,
    buff_range: 0.0,
    buff_rate: 0.0,
    sell_value: tower_sell_value(kind, 1),
  }
}

// Enemy entity

///|
/// Enemy entity with HP, movement, status effects, and special traits.
pub(all) struct Enemy {
  mut active : Bool
  mut kind : EnemyKind
  mut x : Float
  mut y : Float
  mut z : Float
  mut hp : Float
  mut max_hp : Float
  mut speed : Float
  mut base_speed : Float
  mut armor : Float
  mut path_index : Int32
  mut path_progress : Float
  mut slow_timer : Float
  mut slow_factor : Float
  mut burn_timer : Float
  mut burn_dps : Float
  mut stun_timer : Float
  mut armor_break_timer : Float
  mut armor_break_factor : Float
  mut armor_broken : Bool
  mut chilled : Bool
  mut chill_timer : Float
  mut gold_value : Int32
  mut flying : Bool
  mut is_boss : Bool
  mut is_camo : Bool
  mut shield_hp : Float
  mut shield_max : Float
  mut shield_regen_timer : Float
  mut heal_timer : Float
  mut spawn_children : Bool
  mut score_value : Int32
}

///|
/// Creates an inactive enemy slot for use in the entity pool.
pub fn Enemy::inactive() -> Enemy {
  {
    active: false,
    kind: Basic,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    hp: 0.0,
    max_hp: 1.0,
    speed: 2.0,
    base_speed: 2.0,
    armor: 0.0,
    path_index: 0,
    path_progress: 0.0,
    slow_timer: 0.0,
    slow_factor: 1.0,
    burn_timer: 0.0,
    burn_dps: 0.0,
    stun_timer: 0.0,
    armor_break_timer: 0.0,
    armor_break_factor: 1.0,
    armor_broken: false,
    chilled: false,
    chill_timer: 0.0,
    gold_value: 10,
    flying: false,
    is_boss: false,
    is_camo: false,
    shield_hp: 0.0,
    shield_max: 0.0,
    shield_regen_timer: 0.0,
    heal_timer: 0.0,
    spawn_children: false,
    score_value: 10,
  }
}

// Projectile

///|
/// Projectile entity with position, damage, and on-hit effect properties.
pub(all) struct Projectile {
  mut active : Bool
  mut kind : TowerKind
  mut x : Float
  mut y : Float
  mut z : Float
  mut target_idx : Int32
  mut damage : Float
  mut speed : Float
  mut splash_radius : Float
  mut slow_amount : Float
  mut slow_duration : Float
  mut burn_damage : Float
  mut burn_duration : Float
  mut stun_chance : Float
  mut stun_duration : Float
  mut chain_count : Int32
  mut chain_range : Float
  mut is_crit : Bool
  mut tower_idx : Int32
}

///|
/// Creates an inactive projectile slot for use in the entity pool.
pub fn Projectile::inactive() -> Projectile {
  {
    active: false,
    kind: Arrow,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    target_idx: -1,
    damage: 0.0,
    speed: 12.0,
    splash_radius: 0.0,
    slow_amount: 0.0,
    slow_duration: 0.0,
    burn_damage: 0.0,
    burn_duration: 0.0,
    stun_chance: 0.0,
    stun_duration: 0.0,
    chain_count: 0,
    chain_range: 0.0,
    is_crit: false,
    tower_idx: -1,
  }
}

// Particle

///|
/// Visual particle with position, velocity, color, and lifetime.
pub(all) struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut z : Float
  mut vx : Float
  mut vy : Float
  mut vz : Float
  mut life : Float
  mut max_life : Float
  mut r : Int32
  mut g : Int32
  mut b : Int32
  mut size : Float
  mut kind : Int32
}

///|
/// Creates an inactive particle slot for use in the particle pool.
pub fn Particle::inactive() -> Particle {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    vx: 0.0,
    vy: 0.0,
    vz: 0.0,
    life: 0.0,
    max_life: 1.0,
    r: 255,
    g: 255,
    b: 255,
    size: 0.05,
    kind: 0,
  }
}

// Particle kinds

///|
/// Particle kind for generic visual effects.
pub let particle_normal : Int32 = 0

///|
/// Particle kind for flame and burn effects.
pub let particle_fire : Int32 = 1

///|
/// Particle kind for frost and ice effects.
pub let particle_ice : Int32 = 2

///|
/// Particle kind for electrical discharge effects.
pub let particle_lightning : Int32 = 3

///|
/// Particle kind for gold collection visual feedback.
pub let particle_gold : Int32 = 4

///|
/// Particle kind for tower construction effects.
pub let particle_build : Int32 = 5

///|
/// Particle kind for explosion and impact effects.
pub let particle_explosion : Int32 = 6

// Path node

///|
/// Waypoint on the enemy movement path with world-space coordinates.
pub(all) struct PathNode {
  x : Float
  z : Float
}

// Wave spawn entry: one type of enemy within a wave

///|
/// Single enemy group within a wave with type, count, and spawn timing.
pub(all) struct WaveSpawnEntry {
  enemy_kind : EnemyKind
  count : Int32
  hp_mult : Float
  speed_mult : Float
  spawn_delay : Float
}

// Wave definition

///|
/// Simple wave definition with enemy type, count, and scaling multipliers.
pub(all) struct WaveDef {
  enemy_kind : EnemyKind
  count : Int32
  hp_mult : Float
  speed_mult : Float
}

// Extended wave definition with multiple spawn groups

///|
/// Extended wave definition with multiple spawn groups and bonus rewards.
pub(all) struct WaveInfo {
  entries : Array[WaveSpawnEntry]
  is_boss_wave : Bool
  bonus_gold : Int32
  wave_message : String
}

// Map data definition

///|
/// Map metadata including name, difficulty rating, and layout data.
pub(all) struct MapInfo {
  name : String
  difficulty : Int32
  layout : Array[String]
  description : String
  starting_gold_bonus : Int32
}

// Tower upgrade info

///|
/// Tower upgrade details including cost, stat multipliers, and description.
pub(all) struct UpgradeInfo {
  cost : Int32
  damage_mult : Float
  range_mult : Float
  rate_mult : Float
  special_desc : String
}

// Main Game struct

///|
/// Main game state holding all entity pools, economy, wave, camera, and UI data.
pub(all) struct Game {
  mut state : GameState
  mut prev_state : GameState

  // Economy
  mut gold : Int32
  mut lives : Int32
  mut score : Int32
  mut interest_timer : Float
  mut total_gold_earned : Int32
  mut total_gold_spent : Int32

  // Wave system
  mut current_wave : Int32
  mut wave_timer : Float
  mut spawn_timer : Float
  mut enemies_to_spawn : Int32
  mut enemies_spawned : Int32
  mut wave_enemy_kind : EnemyKind
  mut wave_hp_mult : Float
  mut wave_speed_mult : Float
  mut wave_spawn_group : Int32
  mut enemies_killed_this_wave : Int32
  mut wave_active : Bool

  // Multi-group wave system
  mut spawn_groups : Array[WaveSpawnEntry]
  mut current_group : Int32
  mut group_spawned : Int32
  mut group_delay_timer : Float

  // Map
  tiles : Array[Tile]
  path_nodes : Array[PathNode]
  mut path_count : Int32

  // Entity pools
  towers : Array[Tower]
  enemies : Array[Enemy]
  projectiles : Array[Projectile]
  particles : Array[Particle]

  // Building mode
  mut selected_tower_type : TowerKind
  mut hover_gx : Int32
  mut hover_gy : Int32
  mut hover_valid : Bool

  // Camera
  mut camera_angle : Float
  mut camera_pitch : Float
  mut camera_dist : Float
  mut camera_target_x : Float
  mut camera_target_z : Float

  // UI
  mut menu_cursor : Int32
  mut menu_blink : Float
  mut show_ranges : Bool
  mut selected_tower_idx : Int32
  mut upgrade_preview : Bool
  mut tower_info_scroll : Int32
  mut notification_timer : Float
  mut notification_text : String
  mut show_minimap : Bool

  // Speed control
  mut speed_multiplier : Float
  mut speed_setting : Int32

  // Difficulty
  mut difficulty : Int32

  // RNG
  mut rng_state : Int32
  mut frame_counter : Int32

  // Current map
  mut current_map : Int32

  // Stats tracking
  mut towers_built : Int32
  mut towers_sold : Int32
  mut total_kills : Int32
  mut damage_dealt : Float
  mut longest_wave : Int32

  // Wave message display
  mut wave_message : String
  mut wave_message_timer : Float

  // Lightning chain visualization
  mut chain_lines : Array[ChainLine]
  mut chain_line_count : Int32

  // Synergy combo visualization
  synergy_lines : Array[SynergyLine]

  // Combat readability pools
  floating_texts : Array[FloatingText]
  break_flashes : Array[BreakFlash]
  attack_beams : Array[AttackBeam]

  // Combat readability state
  mut wave_complete_timer : Float
  mut leak_warning_timer : Float
  mut gold_flash_timer : Float
  mut prev_gold : Int32
}

// Chain lightning visual line

///|
/// Visual line segment for rendering chain lightning arcs between enemies.
pub(all) struct ChainLine {
  mut active : Bool
  mut x1 : Float
  mut y1 : Float
  mut z1 : Float
  mut x2 : Float
  mut y2 : Float
  mut z2 : Float
  mut life : Float
}

///|
/// Creates an inactive chain line slot for use in the visual effect pool.
pub fn ChainLine::inactive() -> ChainLine {
  {
    active: false,
    x1: 0.0,
    y1: 0.0,
    z1: 0.0,
    x2: 0.0,
    y2: 0.0,
    z2: 0.0,
    life: 0.0,
  }
}

// Synergy combo visual line

///|
/// Visual line segment for rendering tower synergy combo effects between towers.
pub(all) struct SynergyLine {
  mut active : Bool
  mut x1 : Float
  mut y1 : Float
  mut z1 : Float
  mut x2 : Float
  mut y2 : Float
  mut z2 : Float
  mut life : Float
  mut r : Int32
  mut g : Int32
  mut b : Int32
  mut label : String
}

///|
/// Creates an inactive synergy line slot for use in the visual effect pool.
pub fn SynergyLine::inactive() -> SynergyLine {
  {
    active: false,
    x1: 0.0,
    y1: 0.0,
    z1: 0.0,
    x2: 0.0,
    y2: 0.0,
    z2: 0.0,
    life: 0.0,
    r: 255,
    g: 255,
    b: 255,
    label: "",
  }
}

// Floating damage/text number

///|
/// Floating text number displayed above enemies when damage is dealt or gold is earned.
pub(all) struct FloatingText {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut z : Float
  mut vy : Float
  mut life : Float
  mut max_life : Float
  mut value : Int32
  mut r : Int32
  mut g : Int32
  mut b : Int32
  mut is_gold : Bool
}

///|
/// Creates an inactive floating text slot for use in the text pool.
pub fn FloatingText::inactive() -> FloatingText {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    vy: 2.0,
    life: 0.0,
    max_life: 1.0,
    value: 0,
    r: 255,
    g: 255,
    b: 255,
    is_gold: false,
  }
}

// Shield break / armor break flash

///|
/// Visual flash effect shown when an enemy shield or armor breaks.
pub(all) struct BreakFlash {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut z : Float
  mut life : Float
  mut r : Int32
  mut g : Int32
  mut b : Int32
  mut radius : Float
}

///|
/// Creates an inactive break flash slot for use in the effect pool.
pub fn BreakFlash::inactive() -> BreakFlash {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    life: 0.0,
    r: 100,
    g: 150,
    b: 255,
    radius: 0.8,
  }
}

// Tower attack beam visual

///|
/// Visual beam line drawn from a tower to its current target for laser/frost type attacks.
pub(all) struct AttackBeam {
  mut active : Bool
  mut x1 : Float
  mut y1 : Float
  mut z1 : Float
  mut x2 : Float
  mut y2 : Float
  mut z2 : Float
  mut life : Float
  mut r : Int32
  mut g : Int32
  mut b : Int32
  mut kind : TowerKind
}

///|
/// Creates an inactive attack beam slot for use in the visual effect pool.
pub fn AttackBeam::inactive() -> AttackBeam {
  {
    active: false,
    x1: 0.0,
    y1: 0.0,
    z1: 0.0,
    x2: 0.0,
    y2: 0.0,
    z2: 0.0,
    life: 0.0,
    r: 255,
    g: 255,
    b: 255,
    kind: Arrow,
  }
}

///|
/// Creates a new game instance with default settings and empty entity pools.
pub fn Game::Game() -> Game {
  {
    state: Menu,
    prev_state: Menu,
    gold: starting_gold,
    lives: starting_lives,
    score: 0,
    interest_timer: 0.0,
    total_gold_earned: starting_gold,
    total_gold_spent: 0,
    current_wave: 0,
    wave_timer: 0.0,
    spawn_timer: 0.0,
    enemies_to_spawn: 0,
    enemies_spawned: 0,
    wave_enemy_kind: Basic,
    wave_hp_mult: 1.0,
    wave_speed_mult: 1.0,
    wave_spawn_group: 0,
    enemies_killed_this_wave: 0,
    wave_active: false,
    spawn_groups: [],
    current_group: 0,
    group_spawned: 0,
    group_delay_timer: 0.0,
    tiles: Array::make(map_total, Grass),
    path_nodes: {
      let arr : Array[PathNode] = []
      for i in 0..<max_path_nodes {
        arr.push({ x: 0.0, z: 0.0, })
        ignore(i)
      }
      arr
    },
    path_count: 0,
    towers: Array::make(max_towers, Tower::inactive()),
    enemies: Array::make(max_enemies, Enemy::inactive()),
    projectiles: Array::make(max_projectiles, Projectile::inactive()),
    particles: Array::make(max_particles, Particle::inactive()),
    selected_tower_type: Arrow,
    hover_gx: 0,
    hover_gy: 0,
    hover_valid: false,
    camera_angle: 45.0,
    camera_pitch: 55.0,
    camera_dist: 25.0,
    camera_target_x: Float::from_int(map_w) * cell_size / 2.0,
    camera_target_z: Float::from_int(map_h) * cell_size / 2.0,
    menu_cursor: 0,
    menu_blink: 0.0,
    show_ranges: false,
    selected_tower_idx: -1,
    upgrade_preview: false,
    tower_info_scroll: 0,
    notification_timer: 0.0,
    notification_text: "",
    show_minimap: true,
    speed_multiplier: 1.0,
    speed_setting: 0,
    difficulty: 1,
    rng_state: 12345,
    frame_counter: 0,
    current_map: 0,
    towers_built: 0,
    towers_sold: 0,
    total_kills: 0,
    damage_dealt: 0.0,
    longest_wave: 0,
    wave_message: "",
    wave_message_timer: 0.0,
    chain_lines: Array::make(16, ChainLine::inactive()),
    chain_line_count: 0,
    synergy_lines: Array::make(16, SynergyLine::inactive()),
    floating_texts: Array::make(max_floating_texts, FloatingText::inactive()),
    break_flashes: Array::make(max_break_flashes, BreakFlash::inactive()),
    attack_beams: Array::make(max_attack_beams, AttackBeam::inactive()),
    wave_complete_timer: 0.0,
    leak_warning_timer: 0.0,
    gold_flash_timer: 0.0,
    prev_gold: starting_gold,
  }
}
