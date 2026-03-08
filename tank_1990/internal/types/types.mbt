///|
/// Shared tank record used for players and enemies.
pub(all) struct Tank {
  mut active : Bool
  mut is_player : Bool
  mut player_index : Int
  enemy_kind : EnemyKind
  mut x : Float
  mut y : Float
  mut spawn_x : Float
  mut spawn_y : Float
  mut dir : Dir
  mut move_speed : Float
  mut hp : Int
  mut max_hp : Int
  mut reload_timer : Float
  mut reload_delay : Float
  mut ai_move_timer : Float
  mut ai_fire_timer : Float
  mut ai_stuck_timer : Float
  mut freeze_timer : Float
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
/// Creates an inactive tank slot with default values.
pub fn Tank::inactive() -> Tank {
  {
    active: false,
    is_player: false,
    player_index: 0,
    enemy_kind: Basic,
    x: 0.0,
    y: 0.0,
    spawn_x: 0.0,
    spawn_y: 0.0,
    dir: Up,
    move_speed: speed_enemy_basic,
    hp: 1,
    max_hp: 1,
    reload_timer: 0.0,
    reload_delay: enemy_reload_base,
    ai_move_timer: 0.0,
    ai_fire_timer: 0.0,
    ai_stuck_timer: 0.0,
    freeze_timer: 0.0,
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
/// Creates a new player tank at the given spawn position.
pub fn Tank::new_player(index : Int, spawn_x : Float, spawn_y : Float) -> Tank {
  {
    active: true,
    is_player: true,
    player_index: index,
    enemy_kind: Basic,
    x: spawn_x,
    y: spawn_y,
    spawn_x,
    spawn_y,
    dir: Up,
    move_speed: speed_player,
    hp: 1,
    max_hp: 1,
    reload_timer: 0.0,
    reload_delay: player_reload_base,
    ai_move_timer: 0.0,
    ai_fire_timer: 0.0,
    ai_stuck_timer: 0.0,
    freeze_timer: 0.0,
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
/// Creates a new enemy tank of the given `kind` at the spawn position.
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
    is_player: false,
    player_index: 0,
    enemy_kind: kind,
    x: spawn_x,
    y: spawn_y,
    spawn_x,
    spawn_y,
    dir: Down,
    move_speed: speed,
    hp,
    max_hp: hp,
    reload_timer: 0.0,
    reload_delay: reload,
    ai_move_timer: 0.12,
    ai_fire_timer: 0.35,
    ai_stuck_timer: 0.0,
    freeze_timer: 0.0,
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
/// Projectile fired by tanks.
pub(all) struct Bullet {
  mut active : Bool
  mut owner_team : Team
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut ttl : Float
  mut damage : Int
  mut power : Int
  mut radius : Float
}

///|
/// Creates an inactive bullet slot with default values.
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
/// Visual particle for explosions, sparks, and smoke effects.
pub(all) struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut max_life : Float
  mut size : Float
  mut spin : Float
  mut rot : Float
  mut fade : Float
  mut color : @raylib.Color
}

///|
/// Creates an inactive particle slot with default values.
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
    spin: 0.0,
    rot: 0.0,
    fade: 0.0,
    color: @raylib.white,
  }
}

///|
/// Collectible powerup item on the battlefield.
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
/// Creates an inactive powerup slot with default values.
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
/// Background star for the parallax starfield effect.
pub(all) struct Star {
  mut x : Float
  mut y : Float
  mut speed : Float
  mut twinkle : Float
}

///|
/// Creates a new background star at the given position with speed and twinkle phase.
pub fn Star::new(x : Float, y : Float, speed : Float, twinkle : Float) -> Star {
  { x, y, speed, twinkle }
}

///|
/// Visual and gameplay profile for a campaign stage.
pub(all) struct StageProfile {
  title : String
  subtitle : String
  enemy_bonus : Int
  spawn_scale : Float
  drop_bonus : Int
  sky_top : @raylib.Color
  sky_bottom : @raylib.Color
  fog_alpha : Float
  ui_accent : @raylib.Color

  fn new(
    title : String,
    subtitle : String,
    enemy_bonus : Int,
    spawn_scale : Float,
    drop_bonus : Int,
    sky_top : @raylib.Color,
    sky_bottom : @raylib.Color,
    fog_alpha : Float,
    ui_accent : @raylib.Color,
  ) -> StageProfile
}

///|
/// Creates a new stage profile with all visual and gameplay parameters.
#deprecated
pub fn StageProfile::new(
  title : String,
  subtitle : String,
  enemy_bonus : Int,
  spawn_scale : Float,
  drop_bonus : Int,
  sky_top : @raylib.Color,
  sky_bottom : @raylib.Color,
  fog_alpha : Float,
  ui_accent : @raylib.Color,
) -> StageProfile {
  {
    title,
    subtitle,
    enemy_bonus,
    spawn_scale,
    drop_bonus,
    sky_top,
    sky_bottom,
    fog_alpha,
    ui_accent,
  }
}

///|
/// Returns the default stage profile for unmatched stage indices.
pub fn default_stage_profile() -> StageProfile {
  StageProfile(
    "Border Skirmish",
    "Standard armored engagement",
    0,
    1.0,
    0,
    @raylib.Color::new(14, 20, 31, 255),
    @raylib.Color::new(8, 10, 15, 255),
    0.06,
    @raylib.gold,
  )
}

///|
/// Global mutable game state for Tank 1990.
///
/// This struct holds **everything** about a running game — the current screen
/// the player sees (menu, playing, paused …), all tanks, bullets, particles,
/// the tile map, score tracking, timers, and visual effects.  A single `Game`
/// value is created at startup and passed to every update/render function.
pub(all) struct Game {
  // ──────────────────────── Core game mode ────────────────────────

  /// Which screen/phase the game is currently in.
  /// Possible values: `Menu`, `StageIntro`, `Playing`, `Paused`,
  /// `StageClear`, `GameOver`, `CampaignClear`.
  /// The main update loop dispatches to different logic based on this value.
  mut state : GameState
  /// Whether two-player cooperative mode is turned on.
  /// When `true`, player 2 is spawned and accepts input from a second set
  /// of keys.  Toggled from the main menu with the "C" key.
  mut coop_enabled : Bool
  /// Whether the game is running in AI demo mode (attract screen).
  /// In demo mode both players are controlled by simple AI logic instead
  /// of keyboard input, and timers (intro, clear, game-over) are shortened
  /// so the demo cycles quickly.
  mut demo_mode : Bool
  /// How many demo campaigns have been started since the program launched.
  /// Incremented each time `start_demo_campaign()` is called.  Purely
  /// informational — not used for gameplay logic.
  mut demo_runs : Int
  /// Seconds elapsed since the current demo campaign began.
  /// Accumulates every frame while `demo_mode` is `true` and the state
  /// is not `Menu`.  Reset to 0 when a new demo campaign starts.
  mut demo_elapsed : Float

  // ──────────────────────── Main menu ─────────────────────────────

  /// Index of the currently highlighted menu item (0–3).
  /// 0 = Start Game, 1 = Demo, 2 = Co-op toggle, 3 = Quit.
  /// Changed with Up/Down arrow keys on the menu screen.
  mut menu_cursor : Int
  /// Timer that drives the blinking animation of the menu selection cursor.
  /// Continuously increases; a sine of this value controls the blink effect.
  mut menu_blink : Float

  // ──────────────────────── Frame / stage counters ────────────────

  /// Total number of frames rendered since the game was created.
  /// Incremented by 1 every frame regardless of game state.
  /// Useful for frame-based animation or periodic events.
  mut frame_counter : Int
  /// Zero-based index of the current campaign stage (level).
  /// Ranges from 0 to `level_count - 1` (0–95).  Advances by 1 each time
  /// the player clears a stage.
  mut stage_index : Int

  // ──────────────────────── Phase transition timers ───────────────
  // These countdown timers control how long each overlay screen is shown
  // before the game automatically moves to the next phase.

  /// Seconds remaining on the "STAGE N" intro overlay.
  /// Counts down from `stage_intro_time` (1.6 s); when it reaches 0 the
  /// state transitions from `StageIntro` → `Playing`.
  mut stage_intro_timer : Float
  /// Seconds remaining on the "STAGE CLEAR" overlay.
  /// Counts down from `stage_clear_time` (2.4 s); when it reaches 0 the
  /// game loads the next stage or enters `CampaignClear`.
  mut stage_clear_timer : Float
  /// Seconds remaining on the "GAME OVER" overlay.
  /// Counts down from `game_over_delay` (2.8 s); when it reaches 0 the
  /// game returns to the menu (or restarts the demo).
  mut game_over_timer : Float
  /// Seconds remaining on the "CAMPAIGN CLEAR" victory overlay.
  /// Counts down from `campaign_clear_delay` (3.6 s); when it reaches 0
  /// the game returns to the menu (or restarts the demo).
  mut campaign_clear_timer : Float
  /// Timer that drives the blinking "PAUSED" text when the game is paused.
  /// Increases each frame while paused; a sine of this value controls the
  /// blink effect.
  mut pause_blink : Float

  // ──────────────────────── Stage profile ─────────────────────────

  /// Visual and gameplay profile for the current stage.
  /// Contains the stage title/subtitle, sky gradient colors, fog intensity,
  /// UI accent color, and gameplay modifiers like extra enemies
  /// (`enemy_bonus`), spawn speed scaling (`spawn_scale`), and powerup
  /// drop rate bonus (`drop_bonus`).  Loaded from a table each time a new
  /// stage begins.
  mut profile : StageProfile

  // ──────────────────────── Global powerup effects ────────────────

  /// Seconds remaining on the "freeze all enemies" effect (Clock powerup).
  /// While > 0, enemy AI is completely paused — enemies cannot move or
  /// shoot.  Counts down to 0 each frame.
  mut freeze_all_timer : Float
  /// Seconds remaining on the "shovel fortress" effect (Shovel powerup).
  /// While > 0, the tiles surrounding the player base are upgraded to
  /// steel.  When the timer reaches 0, the original tiles are restored
  /// from `base_tiles_cached`.
  mut shovel_timer : Float

  // ──────────────────────── Camera shake ──────────────────────────

  /// Current intensity of the camera shake effect (in pixels).
  /// When an explosion or grenade goes off, this is bumped up (capped at
  /// `camera_shake_power` = 7.5).  It then decays toward 0 each frame.
  /// The rendering code converts this into X/Y offsets applied to all
  /// world-space drawing.
  mut camera_shake : Float
  /// Phase angle for the camera shake oscillation.
  /// Incremented each frame while shake is active; fed into sin/cos to
  /// produce the jittery offset pattern.
  mut camera_shake_phase : Float

  // ──────────────────────── Player base (eagle) ───────────────────

  /// Whether the player's base (the eagle icon at the bottom-center of the
  /// map) is still intact.  If a bullet hits the base tile, this is set to
  /// `false` and the game immediately enters `GameOver`.
  mut base_alive : Bool
  /// Flash intensity when the base is hit.
  /// Set to 1.0 on impact and decays to 0 over time; the renderer uses it
  /// to tint the base area red/white to show damage.
  mut base_flash : Float
  /// Cached tile types of the 14 tiles surrounding the base.
  /// Saved before the Shovel powerup replaces them with steel, and
  /// restored when the shovel effect expires.  This ensures the original
  /// wall layout around the base is preserved.
  base_tiles_cached : Array[Tile]

  // ──────────────────────── Score ─────────────────────────────────

  /// Cumulative score across both players for the current campaign.
  /// Increased whenever an enemy is destroyed or a powerup is collected.
  mut score_total : Int
  /// Highest `score_total` achieved across all campaigns in this session.
  /// Updated automatically whenever `score_total` exceeds it.
  /// (Not persisted to disk — resets when the program restarts.)
  mut high_score : Int

  // ──────────────────────── Enemy spawning ────────────────────────

  /// Total number of enemies that must be spawned in this stage before it
  /// can be considered "cleared".  Calculated from the stage index
  /// (higher stages → more enemies) and the profile's `enemy_bonus`.
  /// Ranges from 18 to 60.
  mut enemies_to_spawn : Int
  /// How many enemies have been spawned so far in this stage.
  /// Incremented each time a new enemy tank appears.  When this reaches
  /// `enemies_to_spawn`, no more enemies will spawn.
  mut enemies_spawned : Int
  /// How many enemy tanks are currently alive on the battlefield.
  /// Incremented on spawn, decremented on destruction.  The stage is
  /// cleared when `enemies_spawned >= enemies_to_spawn` AND
  /// `enemies_alive <= 0`.
  mut enemies_alive : Int
  /// Countdown timer (in seconds) until the next enemy spawn attempt.
  /// When it reaches 0, the game tries to place a new enemy at one of
  /// three spawn lanes at the top of the map.  Then resets to
  /// `enemy_spawn_period * profile.spawn_scale`.
  mut spawn_timer : Float

  // ──────────────────────── Kill combo ────────────────────────────

  /// Current kill combo streak (0–9).
  /// Incremented each time an enemy is destroyed.  Higher combos give a
  /// score multiplier: 1× (combo ≤ 1), 2× (≤ 3), 3× (≤ 6), 4× (≥ 7).
  /// Resets to 0 when `combo_timer` expires.
  mut kill_combo : Int
  /// Seconds remaining before the kill combo resets.
  /// Set to 2.1 s each time a kill is scored.  If no enemy is killed
  /// within this window, `kill_combo` drops back to 0.
  mut combo_timer : Float

  // ──────────────────────── Random number generator ───────────────

  /// Internal state of the xorshift pseudo-random number generator.
  /// Used by `rand_next()` / `rand_range()` / `rand_rangef()` to produce
  /// deterministic random values for enemy AI decisions, spawn rolls,
  /// powerup drops, and particle effects.  Seeded to `0x13572468` on
  /// creation.
  mut rng_state : Int

  // ──────────────────────── Tile map ──────────────────────────────

  /// Flat array storing the tile type of every cell on the 26×26 grid.
  /// Index = `ty * 26 + tx`.  Tile types: `Empty`, `Brick`, `Steel`,
  /// `Water`, `Bush`, `Ice`, `Base`.  Brick can be destroyed by bullets;
  /// Steel only by high-power bullets; Water blocks tanks but not bullets
  /// visually; Bush hides tanks; Ice makes tanks slide.
  map_tiles : Array[Tile]
  /// Hit points for each tile, parallel to `map_tiles`.
  /// Brick tiles start at 1 HP and are destroyed when reduced to 0.
  /// Steel tiles have 999 HP (effectively indestructible unless bullet
  /// power ≥ 3).  Empty/Bush/Ice/Water tiles have 0 HP.
  map_hp : Array[Int]

  // ──────────────────────── Entity pools ──────────────────────────
  // All entities use pre-allocated fixed-size arrays ("object pools").
  // Each element has an `active` flag; inactive slots are available for
  // reuse.  This avoids heap allocation during gameplay.

  /// The 1–2 player tanks.  Index 0 is player 1, index 1 is player 2.
  /// Player 2 is only active when `coop_enabled` is `true`.
  /// Each `Tank` tracks position, direction, HP, lives, weapon level,
  /// reload cooldown, and various effect timers (shield, invulnerability,
  /// respawn, etc.).
  players : Array[Tank]
  /// Pool of up to 42 enemy tank slots.
  /// Enemies are spawned from the top of the map and controlled by AI.
  /// Each has a `kind` (Basic / Fast / Heavy / Sniper) that determines
  /// its speed, HP, reload rate, and score value.
  enemies : Array[Tank]
  /// Pool of up to 320 bullet slots.
  /// Bullets travel in a straight line, damage tiles and tanks on contact,
  /// and expire after a time-to-live (`ttl`) runs out.  Each bullet knows
  /// which team fired it (`owner_team`) to prevent friendly fire.
  bullets : Array[Bullet]
  /// Pool of up to 960 visual particle slots.
  /// Particles are purely cosmetic — explosions, sparks, smoke puffs.
  /// They have velocity, rotation, color, and a lifetime that fades them
  /// out.  They do not affect gameplay.
  particles : Array[Particle]
  /// Pool of up to 32 collectible powerup slots.
  /// Powerups appear when certain enemies are destroyed.  Types: Shield
  /// (temporary invulnerability), Star (weapon upgrade), Grenade (destroy
  /// all enemies), Clock (freeze enemies), Shovel (steel base walls),
  /// Tank (extra life).  Each has a time-to-live before it disappears.
  powerups : Array[Powerup]
  /// Array of 120 background stars for the parallax scrolling starfield
  /// effect drawn behind the menu and game screens.  Each star has a
  /// position, scroll speed, and twinkle phase.  Stars wrap from bottom
  /// to top for a continuous scrolling illusion.
  stars : Array[Star]
}

///|
/// Creates a new game instance with all pools allocated and default menu state.
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
    particles: Array::make(max_particles, Particle::inactive()),
    powerups: Array::make(max_powerups, Powerup::inactive()),
    stars,
  }
}
