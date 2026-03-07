///|
/// Mutable enemy entity stored in the combat simulation pool.
pub(all) struct Enemy {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut r : Float
  mut hp : Float
  mut kind : EnemyKind
  mut phase : Float

  fn new() -> Enemy
}

///|
/// Mutable pickup entity stored in the world object pool.
pub(all) struct Pickup {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut kind : PickupKind
  mut phase : Float

  fn new() -> Pickup
}

///|
/// Mutable projectile entity stored in the bullet pool.
pub(all) struct Bullet {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut power : Float
  mut kind : BulletKind

  fn new() -> Bullet
}

///|
/// Mutable particle used for lightweight visual effects.
pub(all) struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut size : Float
  mut kind : ParticleKind

  fn new() -> Particle
}

///|
/// High-level state of the game flow.
pub(all) enum GameState {
  Title
  Play
  Result
} derive(Eq)

///|
/// Complete runtime state for one arctic outpost survival session.
/// The player defends a core generator from waves of enemies while managing
/// suit HP, fuel, ammo, and core heat over a 200-second survival run.
pub(all) struct Game {
  // ──── Entity pools ────
  /// Pre-allocated pool of enemy entities (wolves, brutes, shards).
  /// Size is `max_enemies` (200). Only slots with `active == true` participate
  /// in update and collision logic. Spawned by `spawn_enemy`, cleared between runs.
  enemies : Array[Enemy]
  /// Pre-allocated pool of supply pickups (fuel, medkit, ammo, overdrive).
  /// Size is `max_pickups` (100). Pickups fall from above the world and are
  /// collected on player contact. Cleared between runs.
  pickups : Array[Pickup]
  /// Pre-allocated pool of projectiles fired by the player.
  /// Size is `max_bullets` (240). Each bullet travels in a straight line and
  /// is deactivated on lifetime expiry, leaving the world, or hitting an enemy.
  bullets : Array[Bullet]
  /// Pre-allocated pool of lightweight visual-effect particles.
  /// Size is `max_particles` (1600). Used for muzzle flash, damage bursts,
  /// and overdrive trail effects. Updated and rendered every frame.
  particles : Array[Particle]
  // ──── Core state ────
  /// Which screen/phase the game is currently in.
  /// Possible values: `Title`, `Play`, `Result`.
  /// The main update loop dispatches to different input and logic based on this.
  mut state : GameState
  // ──── Player kinematics ────
  /// Horizontal position of the player character in world-space pixels.
  /// Clamped to stay within the playable world boundaries (world_x0..world_x0+world_w).
  /// Updated each frame by `update_player` based on velocity.
  mut player_x : Float
  /// Vertical position of the player character in world-space pixels.
  /// Clamped to stay within the playable world boundaries (world_y0..world_y0+world_h).
  /// Updated each frame by `update_player` based on velocity.
  mut player_y : Float
  /// Horizontal velocity of the player in pixels per second.
  /// Driven by `move_x` input acceleration and damped by a drag factor (3.4/s).
  /// Recoil from firing also modifies this value.
  mut player_vx : Float
  /// Vertical velocity of the player in pixels per second.
  /// Driven by `move_y` input acceleration and damped by a drag factor (3.4/s).
  /// Recoil from firing also modifies this value.
  mut player_vy : Float
  /// X coordinate of the player's current aim target in world-space pixels.
  /// Set by mouse/pointer position when inside the world area, or by auto-aim
  /// toward the nearest enemy on touch. Used as the direction for fired bullets.
  mut aim_x : Float
  /// Y coordinate of the player's current aim target in world-space pixels.
  /// Set by mouse/pointer position when inside the world area, or by auto-aim
  /// toward the nearest enemy on touch. Used as the direction for fired bullets.
  mut aim_y : Float
  /// Normalized horizontal movement input axis, in the range [-1.0, 1.0].
  /// Set each frame from keyboard (WASD/arrows) and on-screen touch d-pad.
  /// Multiplied by acceleration to drive `player_vx`.
  mut move_x : Float
  /// Normalized vertical movement input axis, in the range [-1.0, 1.0].
  /// Set each frame from keyboard (WASD/arrows) and on-screen touch d-pad.
  /// Multiplied by acceleration to drive `player_vy`.
  mut move_y : Float
  // ──── Player resources ────
  /// Number of remaining lives. Starts at 3 per run.
  /// Decremented when suit HP reaches zero; the run ends when lives reach 0.
  mut lives : Int
  /// Current suit hit points, ranging from 0.0 to 100.0.
  /// Damaged by enemy contact (reduced 28% during overdrive) and drained when
  /// fuel is empty. Healed by medkit pickups and the repair action.
  /// When it hits 0 the player loses a life and respawns.
  mut suit_hp : Float
  /// Current core generator heat level, ranging from 0.0 to 100.0.
  /// Passively decays each frame from base drain, wave-scaled enemy pressure,
  /// and sinusoidal storm intensity. Restored by fuel pickups and repair action.
  /// When it reaches 0 the run ends in defeat.
  mut core_heat : Float
  /// Current fuel reserve, ranging from 0.0 to 100.0.
  /// Drains passively each second (base ~0.95 + wave*0.03). Consumed by the
  /// repair action (7 units). When fuel is empty, suit HP drains instead.
  /// Replenished by fuel pickups (+26).
  mut fuel : Float
  /// Current ammunition count. Starts at 180 per run; max ~460.
  /// Each shot consumes 1 ammo. Replenished by ammo crate pickups (+48)
  /// and the repair action (+10). Cannot fire when ammo is 0.
  mut ammo : Int
  // ──── Cooldowns and timers ────
  /// Remaining overdrive duration in seconds. When > 0 the player fires
  /// faster pierce bullets, moves faster, and takes 28% less damage.
  /// Activated by overdrive pickups (sets to 7.0s). Ticks down each frame.
  mut overdrive_t : Float
  /// Remaining fire cooldown in seconds. Prevents firing until it reaches 0.
  /// Set to 0.11s per normal shot, 0.055s during overdrive.
  mut fire_cd : Float
  /// Remaining repair cooldown in seconds. Prevents repairing until it reaches 0.
  /// Set to 1.10s after a successful repair, or 0.22s on a failed attempt.
  mut repair_cd : Float
  // ──── Score and progression ────
  /// Current run score. Earned by killing enemies (base + combo bonus),
  /// collecting pickups, and repairing the core. Deducted slightly by hint use (-6).
  mut score : Int
  /// Highest score achieved across all runs in this session.
  /// Updated at end of run and continuously during play when score exceeds it.
  mut best_score : Int
  /// Current difficulty wave, ranging from 1 to 12.
  /// Advances every ~22 seconds of game time (wave = 1 + game_t/22, capped at 12).
  /// Controls enemy spawn rate, enemy stats, fuel drain, and pickup fall speed.
  mut wave : Int
  /// Current combo counter. Incremented by killing enemies or collecting pickups.
  /// Capped at 18 for kills, 12 for pickups. Resets to 0 when `combo_t` expires
  /// or when the player takes damage. Multiplies kill score bonus by 2 per combo.
  mut combo : Int
  /// Remaining combo window in seconds. Set to 2.4s on kill, 2.1s on pickup.
  /// When it reaches 0, `combo` resets to 0. Ticks down each frame.
  mut combo_t : Float
  // ──── Spawn accumulators ────
  /// Accumulated time toward the next enemy spawn, in seconds.
  /// When it exceeds the wave-scaled spawn interval (0.70 - wave*0.038, min 0.18),
  /// an enemy is spawned and the accumulator is reduced by the interval.
  mut spawn_t : Float
  /// Accumulated time toward the next supply pickup spawn, in seconds.
  /// When it reaches 1.95s a pickup is spawned and the timer resets to 0.
  mut pickup_t : Float
  /// Monotonically increasing storm phase timer in seconds.
  /// Drives the sinusoidal storm intensity curve used in `passive_heat_decay`
  /// to modulate core heat drain over time.
  mut storm_t : Float
  // ──── Global timers ────
  /// Total elapsed game time in the current Play run, in seconds.
  /// Used to determine the current wave and to check the 200s survival goal.
  /// Reset to 0 at the start of each run.
  mut game_t : Float
  /// Monotonically increasing UI animation timer in seconds.
  /// Used by the renderer for pulsing, bobbing, and fade effects on HUD elements.
  mut ui_t : Float
  // ──── Tactical hint system ────
  /// Number of tactical hint charges remaining. Starts at 3 per run.
  /// Each use marks the safest lane or nearest needed supply on screen
  /// and deducts 6 score points.
  mut hint_left : Int
  /// Remaining display time for the current hint marker, in seconds.
  /// Set to 2.8s when a hint is used; the marker fades when this reaches 0.
  mut hint_t : Float
  /// World-space X coordinate of the current hint marker.
  /// Points to either the nearest needed supply pickup or the safest lane position.
  mut hint_x : Float
  /// World-space Y coordinate of the current hint marker.
  /// Points to either the nearest needed supply pickup or the safest lane position.
  mut hint_y : Float
  // ──── Transient UI messages ────
  /// Text content of the current on-screen status message (e.g. "No ammo").
  /// Set by `set_msg` and displayed by the renderer while `msg_t > 0`.
  mut msg : String
  /// Remaining display time for the status message, in seconds.
  /// Ticks down each frame; the message is hidden when this reaches 0.
  mut msg_t : Float
  // ──── Screen effects ────
  /// Remaining camera shake duration in seconds.
  /// Set on player damage (0.24s) or core hit (0.30s). The renderer applies
  /// random screen offset while this is positive. Ticks down each frame.
  mut shake_t : Float
  // ──── Input state ────
  /// Cooldown timer preventing rapid touch input re-triggers, in seconds.
  /// Set to ~0.14-0.16s after each touch action to debounce taps.
  mut touch_cd : Float
  /// Whether the current run ended in a win (survived 200s) or loss.
  /// Set by `finish_run`; read by the Result screen renderer to choose
  /// the victory or defeat message.
  mut win : Bool
  /// Current mouse/pointer X position in screen pixels.
  /// Written by the main loop from `get_mouse_x()` each frame, read by
  /// input handlers and the renderer for aim and button hover detection.
  mut mouse_x : Float
  /// Current mouse/pointer Y position in screen pixels.
  /// Written by the main loop from `get_mouse_y()` each frame, read by
  /// input handlers and the renderer for aim and button hover detection.
  mut mouse_y : Float
  /// Whether the left mouse button is currently held down.
  /// Written by the main loop each frame; used to detect pointer-on-rect
  /// interactions for on-screen buttons and firing.
  mut mouse_hold : Bool
  /// Number of active touch points this frame (0 on desktop).
  /// Written by the main loop from `get_touch_point_count()` each frame.
  /// Used by `pointer_on_rect` to iterate over touch positions.
  mut touch_count : Int

  fn new() -> Game
}

///|
/// Creates an inactive enemy with default field values.
#deprecated
pub fn Enemy::new() -> Enemy {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    r: 0.0,
    hp: 0.0,
    kind: Wolf,
    phase: 0.0,
  }
}

///|
/// Creates an inactive pickup with default field values.
#deprecated
pub fn Pickup::new() -> Pickup {
  { active: false, x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, kind: Fuel, phase: 0.0 }
}

///|
/// Creates an inactive bullet with default field values.
#deprecated
pub fn Bullet::new() -> Bullet {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 0.0,
    power: 0.0,
    kind: Normal,
  }
}

///|
/// Creates an inactive particle with default field values.
#deprecated
pub fn Particle::new() -> Particle {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 0.0,
    size: 0.0,
    kind: Default,
  }
}

///|
/// Creates a new game state with preallocated object pools.
#deprecated
pub fn Game::new() -> Game {
  {
    enemies: Array::makei(max_enemies, fn(_i) { Enemy() }),
    pickups: Array::makei(max_pickups, fn(_i) { Pickup() }),
    bullets: Array::makei(max_bullets, fn(_i) { Bullet() }),
    particles: Array::makei(max_particles, fn(_i) { Particle() }),
    state: Title,
    player_x: Float::from_int(world_x0 + world_w / 2),
    player_y: Float::from_int(world_y0 + world_h - 180),
    player_vx: 0.0,
    player_vy: 0.0,
    aim_x: core_x(),
    aim_y: core_y(),
    move_x: 0.0,
    move_y: 0.0,
    lives: 3,
    suit_hp: 100.0,
    core_heat: 100.0,
    fuel: 100.0,
    ammo: 160,
    overdrive_t: 0.0,
    fire_cd: 0.0,
    repair_cd: 0.0,
    score: 0,
    best_score: 0,
    wave: 1,
    combo: 0,
    combo_t: 0.0,
    spawn_t: 0.0,
    pickup_t: 0.0,
    storm_t: 0.0,
    game_t: 0.0,
    ui_t: 0.0,
    hint_left: 3,
    hint_t: 0.0,
    hint_x: core_x(),
    hint_y: core_y(),
    msg: "",
    msg_t: 0.0,
    shake_t: 0.0,
    touch_cd: 0.0,
    win: false,
    mouse_x: 0.0,
    mouse_y: 0.0,
    mouse_hold: false,
    touch_count: 0,
  }
}
