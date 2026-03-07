///|
/// High-level state machine for menu and campaign flow.
pub(all) enum GameState {
  Menu
  StageIntro
  Playing
  Paused
  StageClear
  GameOver
  CampaignClear
} derive(Eq)

///|
/// Team affiliation used for friendly-fire and scoring.
pub(all) enum Team {
  None
  Player1
  Player2
  Enemy
} derive(Eq)

///|
/// Tile categories used by map collision and rendering.
pub(all) enum TileKind {
  Empty
  Brick
  Steel
  Water
  Bush
  Ice
  Base
} derive(Eq)

///|
/// Enemy behavior archetypes.
pub(all) enum EnemyKind {
  Basic
  Fast
  Heavy
  Sniper
} derive(Eq)

///|
/// Collectible powerup categories.
pub(all) enum PowerupKind {
  Shield
  Star
  Grenade
  Clock
  Shovel
  ExtraLife
} derive(Eq)

///|
/// Shared tank record used for players and enemies.
pub(all) struct Tank {
  mut active : Bool
  enemy_kind : EnemyKind
  mut x : Float
  mut y : Float
  mut dir : Dir
  mut move_speed : Float
  mut hp : Int
  mut reload_timer : Float
  mut reload_delay : Float
  mut ai_move_timer : Float
  mut ai_fire_timer : Float
  mut ai_stuck_timer : Float
  mut shield_timer : Float
  mut invuln_timer : Float
  mut respawn_timer : Float
  mut lives : Int
  mut score : Int
  mut weapon_level : Int
  mut blink_timer : Float
  mut skid_timer : Float
}

///|
/// Creates an inactive tank slot.
pub fn Tank::inactive() -> Tank {
  {
    active: false,
    enemy_kind: Basic,
    x: 0.0,
    y: 0.0,
    dir: Up,
    move_speed: speed_enemy_basic,
    hp: 1,
    reload_timer: 0.0,
    reload_delay: enemy_reload_base,
    ai_move_timer: 0.0,
    ai_fire_timer: 0.0,
    ai_stuck_timer: 0.0,
    shield_timer: 0.0,
    invuln_timer: 0.0,
    respawn_timer: 0.0,
    lives: 0,
    score: 0,
    weapon_level: 0,
    blink_timer: 0.0,
    skid_timer: 0.0,
  }
}

///|
/// Creates a player-controlled tank at a spawn point.
pub fn Tank::new_player(_index : Int, spawn_x : Float, spawn_y : Float) -> Tank {
  {
    active: true,
    enemy_kind: Basic,
    x: spawn_x,
    y: spawn_y,
    dir: Up,
    move_speed: speed_player,
    hp: 1,
    reload_timer: 0.0,
    reload_delay: player_reload_base,
    ai_move_timer: 0.0,
    ai_fire_timer: 0.0,
    ai_stuck_timer: 0.0,
    shield_timer: 0.0,
    invuln_timer: player_invuln_spawn,
    respawn_timer: 0.0,
    lives: 3,
    score: 0,
    weapon_level: 0,
    blink_timer: 0.0,
    skid_timer: 0.0,
  }
}

///|
/// Creates an enemy tank configured by `kind`.
pub fn Tank::new_enemy(
  kind : EnemyKind,
  spawn_x : Float,
  spawn_y : Float,
) -> Tank {
  let (speed, hp, reload) = match kind {
    Fast => (speed_enemy_fast, 1, enemy_reload_base * 0.85)
    Heavy => (speed_enemy_heavy, 4, enemy_reload_base * 1.35)
    Sniper => (speed_enemy_sniper, 2, enemy_reload_base * 0.72)
    Basic => (speed_enemy_basic, 1, enemy_reload_base)
  }
  {
    active: true,
    enemy_kind: kind,
    x: spawn_x,
    y: spawn_y,
    dir: Down,
    move_speed: speed,
    hp,
    reload_timer: 0.0,
    reload_delay: reload,
    ai_move_timer: 0.12,
    ai_fire_timer: 0.35,
    ai_stuck_timer: 0.0,
    shield_timer: 0.0,
    invuln_timer: 1.0,
    respawn_timer: 0.0,
    lives: 0,
    score: 0,
    weapon_level: 0,
    blink_timer: 0.0,
    skid_timer: 0.0,
  }
}

///|
/// Projectile record for tank bullets.
pub(all) struct Bullet {
  mut active : Bool
  owner_team : Team
  mut x : Float
  mut y : Float
  vx : Float
  vy : Float
  mut ttl : Float
  damage : Int
  power : Int
  radius : Float
}

///|
/// Creates an inactive bullet slot.
pub fn Bullet::inactive() -> Bullet {
  {
    active: false,
    owner_team: None,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    ttl: 0.0,
    damage: 1,
    power: 1,
    radius: bullet_radius,
  }
}

///|
/// Bomb record for timed and chained explosions.
pub(all) struct Bomb {
  mut active : Bool
  mut owner_team : Team
  mut x : Float
  mut y : Float
  mut tile_x : Int
  mut tile_y : Int
  mut fuse : Float
  mut blast_timer : Float
  mut exploding : Bool
  mut blast_range : Int
}

///|
/// Creates an inactive bomb slot.
pub fn Bomb::inactive() -> Bomb {
  {
    active: false,
    owner_team: None,
    x: 0.0,
    y: 0.0,
    tile_x: 0,
    tile_y: 0,
    fuse: 0.0,
    blast_timer: 0.0,
    exploding: false,
    blast_range: bomb_range_base,
  }
}

///|
/// Particle record for burst and smoke effects.
pub(all) struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut max_life : Float
  mut size : Float
  mut fade : Float
  mut color : @raylib.Color
}

///|
/// Creates an inactive particle slot.
pub fn Particle::inactive() -> Particle {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 0.0,
    max_life: 1.0,
    size: 1.0,
    fade: 0.0,
    color: @raylib.white,
  }
}

///|
/// Powerup record for map pickups.
pub(all) struct Powerup {
  mut active : Bool
  mut kind : PowerupKind
  mut x : Float
  mut y : Float
  mut ttl : Float
  mut blink : Float
  mut pulse : Float
}

///|
/// Creates an inactive powerup slot.
pub fn Powerup::inactive() -> Powerup {
  {
    active: false,
    kind: Shield,
    x: 0.0,
    y: 0.0,
    ttl: 0.0,
    blink: 0.0,
    pulse: 0.0,
  }
}

///|
/// Decorative star used by the background starfield.
pub(all) struct Star {
  mut x : Float
  mut y : Float
  mut speed : Float
  mut twinkle : Float
}

///|
/// Creates a star entry for the background layer.
pub fn Star::new(x : Float, y : Float, speed : Float, twinkle : Float) -> Star {
  { x, y, speed, twinkle }
}

///|
/// Global mutable game state for Bomberman-lite, a tank-and-bomb arcade
/// game inspired by the classic Bomberman / Battle City formula. Holds
/// the full campaign progression, tile map, entity pools, scoring, and
/// all UI/timer state for menu, play, pause, and game-over screens.
pub(all) struct Game {
  // ──── Core state machine ────
  /// Which screen/phase the game is currently in.
  /// Possible values: `Menu`, `StageIntro`, `Playing`, `Paused`,
  /// `StageClear`, `GameOver`, `CampaignClear`.
  /// The main update loop dispatches to different logic based on this value.
  mut state : GameState
  /// Whether player 2 (co-op) is enabled. Toggled from the menu with C.
  /// When false, only player 1 spawns and receives input.
  mut coop_enabled : Bool
  /// Whether an AI demonstration is running instead of human input.
  /// When true, both players are controlled by `demo_player_command` and
  /// stage timers are shortened. Toggled from the menu or via D key.
  mut demo_mode : Bool
  /// Number of demo campaigns started this session. Incremented each time
  /// `start_demo_campaign` is called. Used for display/diagnostic purposes.
  mut demo_runs : Int
  /// Wall-clock time elapsed during the current demo run, in seconds.
  /// Accumulates each frame while `demo_mode` is true and state is not Menu.
  mut demo_elapsed : Float
  // ──── Menu UI ────
  /// Currently highlighted menu item index (0 = Start, 1 = Demo,
  /// 2 = Co-op toggle, 3 = Quit). Navigated with Up/Down keys.
  mut menu_cursor : Int
  /// Accumulating timer that drives the blinking highlight animation on
  /// the selected menu item, in radians. Advances at `menu_select_blink_speed`.
  mut menu_blink : Float
  // ──── Frame & stage progression ────
  /// Global frame counter, incremented by 1 every `update_game` call.
  /// Used for timing-independent logic and animation phase offsets.
  mut frame_counter : Int
  /// Zero-based index of the current stage within the campaign
  /// (0 to `level_count - 1`, i.e. 0..95). Advanced by 1 after each stage clear.
  mut stage_index : Int
  /// Countdown timer for the "STAGE N" intro overlay, in seconds.
  /// Set to `stage_intro_time` (1.6 s, or 0.45 s in demo) when a stage loads;
  /// play begins when it reaches 0.
  mut stage_intro_timer : Float
  /// Countdown timer for the stage-clear celebration, in seconds.
  /// Set to `stage_clear_time` (2.4 s) when the last enemy is destroyed;
  /// the next stage loads when it reaches 0.
  mut stage_clear_timer : Float
  /// Countdown timer for the game-over screen, in seconds.
  /// Set to `game_over_delay` (2.8 s) on game over; returns to Menu when 0.
  mut game_over_timer : Float
  /// Countdown timer for the campaign-clear victory screen, in seconds.
  /// Set to `campaign_clear_delay` (3.6 s) after clearing all 96 stages.
  mut campaign_clear_timer : Float
  /// Accumulating timer for the "PAUSED" text blink animation, in radians.
  /// Advanced while the game is paused; used by the renderer to flash text.
  mut pause_blink : Float
  // ──── Stage profile & global effects ────
  /// Per-stage configuration loaded from the levels package. Contains
  /// difficulty tuning (enemy bonus, spawn scale, drop bonus) and
  /// visual theming (sky colors, fog alpha, UI accent).
  mut profile : StageProfile
  /// Remaining duration of the Clock powerup freeze effect, in seconds.
  /// While positive, all enemy movement and AI are suspended.
  /// Set to `freeze_duration` (6 s) when a Clock powerup is collected.
  mut freeze_all_timer : Float
  /// Remaining duration of the Shovel powerup base-shield effect, in seconds.
  /// While positive, the base ring tiles are upgraded to Steel.
  /// Set to `shovel_duration` (11 s); original tiles are restored when it
  /// reaches 0.
  mut shovel_timer : Float
  // ──── Camera ────
  /// Current camera-shake intensity, in pixels. Decays toward 0 each frame
  /// at a rate of `camera_shake_decay * camera_shake_power`. Pushed upward
  /// by explosions and bomb detonations via `push_camera_shake`.
  mut camera_shake : Float
  /// Phase angle (radians) for the camera-shake oscillation pattern.
  /// Advances by 0.12 per render call while `camera_shake > 0` to produce
  /// a jittery offset via sin/cos.
  mut camera_shake_phase : Float
  // ──── Base (HQ) state ────
  /// Whether the player's base (HQ eagle tile) is still intact.
  /// Set to false when a bullet or bomb blast hits a Base tile.
  /// If false the game transitions to GameOver immediately.
  mut base_alive : Bool
  /// Flash animation timer for the base, in the range [0, 1].
  /// Set to 1.0 when the base is destroyed; decays toward 0 for a
  /// brief white-flash effect on the base tile.
  mut base_flash : Float
  /// Cached original tile kinds for the `base_ring_count` (14) tiles
  /// surrounding the base. Saved before a Shovel powerup upgrades
  /// them to Steel, and restored when the shovel timer expires.
  base_tiles_cached : Array[TileKind]
  // ──── Scoring ────
  /// Cumulative score for the current campaign run, in points.
  /// Increased by destroying enemies, collecting powerups, and combo bonuses.
  /// Displayed on the side panel and game-over screen.
  mut score_total : Int
  /// Highest score achieved across all campaigns this session.
  /// Updated whenever `score_total` exceeds it. Shown on the game-over screen.
  mut high_score : Int
  // ──── Enemy spawning ────
  /// Total number of enemies to spawn during the current stage.
  /// Computed from the stage index and profile on stage load (18..60 range).
  mut enemies_to_spawn : Int
  /// Number of enemies already spawned this stage. Incremented each time
  /// `spawn_enemy` succeeds. Spawning stops when this equals `enemies_to_spawn`.
  mut enemies_spawned : Int
  /// Number of enemies currently alive on the field. Incremented on spawn,
  /// decremented on destroy. Capped at `enemy_on_field_limit` (8) to
  /// prevent overcrowding.
  mut enemies_alive : Int
  /// Countdown timer until the next enemy spawn attempt, in seconds.
  /// Reset to `enemy_spawn_period * profile.spawn_scale` after each spawn.
  mut spawn_timer : Float
  // ──── Combo system ────
  /// Current kill combo streak count (0..9). Incremented by `bump_combo`
  /// when an enemy is destroyed; reset to 0 when `combo_timer` expires.
  /// Higher combo values yield a score multiplier (1x / 2x / 3x / 5x).
  mut kill_combo : Int
  /// Remaining time before the combo streak resets, in seconds.
  /// Set to 2.1 s on each kill; when it reaches 0, `kill_combo` resets to 0.
  mut combo_timer : Float
  // ──── Deterministic RNG ────
  /// Internal state for the xorshift pseudo-random number generator.
  /// Used by `rand_range` and `rand_rangef` for all gameplay randomness
  /// (enemy spawn lanes, AI decisions, powerup drops). Seeded to 0x13572468.
  mut rng_state : Int
  // ──── Map data ────
  /// Flat array of tile kinds for the 26x26 tile map, indexed by
  /// `y * map_tiles_w + x`. Possible values: Empty, Brick, Steel, Water,
  /// Bush, Ice, Base. Mutated by bullet hits and bomb blasts.
  map_tiles : Array[TileKind]
  /// Hit-point values for each map tile, parallel to `map_tiles`.
  /// Brick tiles start at 1 HP; Steel tiles at 999 (indestructible by
  /// normal bullets). Decremented by bullet `power`; tile is cleared at 0.
  map_hp : Array[Int]
  // ──── Entity pools ────
  /// Fixed array of 2 player tanks (index 0 = P1, index 1 = P2).
  /// P2 is only active when `coop_enabled` is true. Each tank holds
  /// position, direction, HP, lives, weapon level, and various timers.
  players : Array[Tank]
  /// Object pool of enemy tanks, pre-allocated to `max_enemies` (42) slots.
  /// Active enemies are AI-driven; inactive slots are recycled by the spawner.
  enemies : Array[Tank]
  /// Object pool of bullets, pre-allocated to `max_bullets` (320) slots.
  /// Fired by players and enemies; travel in a straight line and test
  /// collision against tiles, tanks, and other bullets each frame.
  bullets : Array[Bullet]
  /// Object pool of bombs, pre-allocated to `max_bombs` (96) slots.
  /// Placed by players on their current tile. Each bomb has a fuse timer
  /// and detonates in a cross-shaped blast that destroys tiles and entities.
  bombs : Array[Bomb]
  /// Object pool of visual particles, pre-allocated to `max_particles` (960).
  /// Used for explosions, spark bursts, and respawn effects. Purely cosmetic.
  particles : Array[Particle]
  /// Object pool of collectible powerups, pre-allocated to `max_powerups` (32).
  /// Dropped by destroyed enemies. Types: Shield, Star, Grenade, Clock,
  /// Shovel, ExtraLife. Despawn after `powerup_life` (11 s).
  powerups : Array[Powerup]
  /// Array of background stars for the decorative scrolling starfield.
  /// Initialized with 120 stars at random positions and speeds. Purely visual.
  stars : Array[Star]
}

///|
/// Creates a fresh game state with pooled entities and defaults.
pub fn Game::new() -> Game {
  let stars : Array[Star] = []
  for _ in 0..<120 {
    let x = Float::from_int(@raylib.get_random_value(0, screen_width))
    let y = Float::from_int(@raylib.get_random_value(0, screen_height))
    let speed = Float::from_int(@raylib.get_random_value(12, 85))
    let twinkle = Float::from_int(@raylib.get_random_value(0, 1000)) / 1000.0
    stars.push(Star::new(x, y, speed, twinkle))
  }

  {
    state: Menu,
    coop_enabled: false,
    demo_mode: false,
    demo_runs: 0,
    demo_elapsed: 0.0,
    menu_cursor: 0,
    menu_blink: 0.0,
    frame_counter: 0,
    stage_index: 0,
    stage_intro_timer: 0.0,
    stage_clear_timer: 0.0,
    game_over_timer: 0.0,
    campaign_clear_timer: 0.0,
    pause_blink: 0.0,
    profile: default_stage_profile(),
    freeze_all_timer: 0.0,
    shovel_timer: 0.0,
    camera_shake: 0.0,
    camera_shake_phase: 0.0,
    base_alive: true,
    base_flash: 0.0,
    base_tiles_cached: Array::make(base_ring_count, Brick),
    score_total: 0,
    high_score: 0,
    enemies_to_spawn: 20,
    enemies_spawned: 0,
    enemies_alive: 0,
    spawn_timer: 0.0,
    kill_combo: 0,
    combo_timer: 0.0,
    rng_state: 0x13572468,
    map_tiles: Array::make(max_tiles, Empty),
    map_hp: Array::make(max_tiles, 0),
    players: [
      Tank::new_player(0, player1_spawn_x, player1_spawn_y),
      Tank::new_player(1, player2_spawn_x, player2_spawn_y),
    ],
    enemies: Array::make(max_enemies, Tank::inactive()),
    bullets: Array::make(max_bullets, Bullet::inactive()),
    bombs: Array::make(max_bombs, Bomb::inactive()),
    particles: Array::make(max_particles, Particle::inactive()),
    powerups: Array::make(max_powerups, Powerup::inactive()),
    stars,
  }
}

///|
/// Returns the team enum for a player index.
pub fn team_of_player(index : Int) -> Team {
  if index == 0 {
    Player1
  } else {
    Player2
  }
}
