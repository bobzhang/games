///|
/// High-level flow state for a train heist run.
pub(all) enum GameState {
  Title
  Play
  Result
} derive(Eq)

///|
/// Board tile classification used for movement and collision.
pub(all) enum TileKind {
  Wall
  Floor
  Door
  Exit
} derive(Eq)

///|
/// AI behavior mode for guard updates.
pub(all) enum GuardMode {
  Patrol
  Hunt
  Stunned
} derive(Eq)

///|
/// Loot category used for scoring and progression.
pub(all) enum LootKind {
  Blueprint
  Keycard
  Gold
} derive(Eq)

///|
/// Particle effect category for rendering.
pub(all) enum ParticleKind {
  Spark
  Glitter
  Smoke
} derive(Eq)

///|
/// Grid actor state with interpolation data for smooth movement.
pub(all) struct Actor {
  mut x : Int
  mut y : Int
  mut from_x : Int
  mut from_y : Int
  mut to_x : Int
  mut to_y : Int
  mut fx : Float
  mut fy : Float
  mut t : Float
  mut moving : Bool

  fn new() -> Actor
}

///|
/// Guard entity state, including patrol and alert metadata.
pub(all) struct Guard {
  mut active : Bool
  body : Actor
  mut mode : GuardMode
  mut move_cd : Float
  mut stun_t : Float
  mut dir_x : Int
  mut dir_y : Int
  mut patrol_min : Int
  mut patrol_max : Int
  mut seed : Int
  mut alert_t : Float
  mut color_id : Int

  fn new() -> Guard
}

///|
/// Collectible loot entity placed on the map.
pub(all) struct Loot {
  mut active : Bool
  mut x : Int
  mut y : Int
  mut kind : LootKind
  mut value : Int

  fn new() -> Loot
}

///|
/// Smoke cloud entity used for stealth and stun interactions.
pub(all) struct Smoke {
  mut active : Bool
  mut x : Int
  mut y : Int
  mut t : Float

  fn new() -> Smoke
}

///|
/// Visual particle state for transient effects.
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
/// Complete runtime game state for one heist session.
/// Holds the tile map, entity pools, player state, input buffers,
/// timers, scoring, and visual-effect trackers needed to run one
/// clockwork-train stealth mission from start to result screen.
pub(all) struct Game {
  // ──── Map & entity pools ────

  /// Flat row-major grid of tile kinds (size `grid_w * grid_h`).
  /// Indexed via `y * grid_w + x`. Written once per run by `clear_map`,
  /// read every frame for movement, collision, and rendering.
  map : Array[TileKind]

  /// Pre-allocated pool of guard entities (capacity `max_guards`).
  /// Active guards patrol or hunt the player; inactive slots are skipped.
  guards : Array[Guard]

  /// Pre-allocated pool of collectible loot items (capacity `max_loot`).
  /// Each active loot sits on a tile; collecting it increments `loot_taken`.
  loots : Array[Loot]

  /// Pre-allocated pool of smoke clouds (capacity `max_smokes`).
  /// Active smokes block guard line-of-sight and stun nearby guards.
  smokes : Array[Smoke]

  /// Pre-allocated pool of visual particles (capacity `max_particles`).
  /// Used for spark, glitter, and smoke burst effects; purely cosmetic.
  particles : Array[Particle]

  // ──── Core state ────

  /// Which screen/phase the game is currently in.
  /// Possible values: `Title`, `Play`, `Result`.
  /// The main update loop dispatches to different logic based on this value.
  mut state : GameState

  /// The player-controlled actor with grid position and smooth
  /// interpolation data. Placed at `(start_x, start_y)` each run.
  player : Actor

  /// Remaining lives for the current run. Starts at 3.
  /// Decremented when a non-stunned guard catches the player.
  /// Reaching 0 ends the run as a loss.
  mut lives : Int

  /// Accumulated score for the current run, in points.
  /// Increased by collecting loot, stunning guards, and escaping.
  mut score : Int

  /// Highest score achieved across all runs in this session.
  /// Updated at the end of each run if `score` exceeds it.
  mut best_score : Int

  /// Number of loot items the player has collected this run.
  /// When it reaches `loot_need` (6), the exit is unlocked.
  mut loot_taken : Int

  /// Whether the escape exit tile is passable.
  /// Set to `true` once `loot_taken >= loot_need`; otherwise the
  /// Exit tile blocks movement like a wall.
  mut vault_open : Bool

  /// Seconds remaining before the run times out.
  /// Starts at `run_time_limit` (210 s) and counts down each frame.
  /// Reaching 0 ends the run as a loss.
  mut time_left : Float

  // ──── Input buffering ────

  /// Requested horizontal move direction from input: -1, 0, or 1.
  /// Written by the input system each frame; read by `try_move_player`.
  mut req_dx : Int

  /// Requested vertical move direction from input: -1, 0, or 1.
  /// Written by the input system each frame; read by `try_move_player`.
  mut req_dy : Int

  /// Whether the action key/button is currently held down this frame.
  /// Used together with `action_pressed` to detect rising edges.
  mut action_down : Bool

  /// True only on the frame the action key was first pressed (rising edge).
  /// Triggers smoke deployment; cleared at the end of each `update_game`.
  mut action_pressed : Bool

  // ──── Cooldowns & resources ────

  /// Movement cooldown in seconds. While positive the player cannot
  /// start a new tile move. Set to a small value after each move.
  mut move_cd : Float

  /// Action (smoke deploy) cooldown in seconds. Prevents spamming
  /// the smoke ability; set to 0.35 s after each deployment.
  mut action_cd : Float

  /// Current smoke energy, range 0..100. Deploying smoke costs
  /// `smoke_cost` (34) energy; regenerates at 17 units/s during play.
  mut smoke_energy : Float

  /// Touch-input cooldown in seconds. Prevents accidental double-taps
  /// on touch buttons; set to 0.16 s after each touch action.
  mut touch_cd : Float

  // ──── HUD & visual effects ────

  /// Current HUD status message text displayed to the player.
  /// Set by `set_msg` alongside `msg_t`; cleared when `msg_t` expires.
  mut msg : String

  /// Remaining display time for the HUD message, in seconds.
  /// Counts down each frame; message is hidden once it reaches 0.
  mut msg_t : Float

  /// Remaining flash overlay time in seconds. Used for invincibility
  /// flash after being caught (set to ~1.2 s) and loot pickup flash
  /// (set to ~0.22 s). While positive, the player is visually flashing.
  mut flash_t : Float

  /// Remaining camera-shake duration in seconds.
  /// Triggered by vault unlock (~0.30 s) and guard capture (~0.36 s).
  /// The renderer applies random screen offset while positive.
  mut shake_t : Float

  // ──── Timing & hints ────

  /// Total elapsed time in seconds since entering the current state.
  /// Incremented every frame; used for animations on title and result
  /// screens and as a general time reference during play.
  mut time_s : Float

  /// Index of the last hint shown, cycling 0..3.
  /// Pressing H or the hint touch button advances this and shows
  /// the corresponding hint text via `hint_text(hint_i)`.
  mut hint_i : Int

  // ──── Run outcome ────

  /// Whether the player escaped successfully in the current/last run.
  /// Set by `finish_run`; read on the result screen to choose the
  /// win or loss message and scoring.
  mut win : Bool

  /// Human-readable reason the run ended (e.g. "Caught by railway
  /// guards" or "Clockwork engine reached lockdown").
  /// Empty string when the run was a win.
  mut loss_reason : String

  // ──── Pointer / touch state ────

  /// Current mouse cursor X position in screen pixels.
  /// Updated each frame; used by `pointer_on_rect` for UI hit-testing.
  mut mouse_x : Float

  /// Current mouse cursor Y position in screen pixels.
  /// Updated each frame; used by `pointer_on_rect` for UI hit-testing.
  mut mouse_y : Float

  /// Whether the left mouse button is currently held down.
  /// Used together with `mouse_x`/`mouse_y` for virtual d-pad and
  /// on-screen button detection via `pointer_on_rect`.
  mut mouse_hold : Bool

  /// Number of active touch points this frame (0 on desktop).
  /// `pointer_on_rect` iterates `0..<touch_count` to check each touch
  /// against UI button rectangles.
  mut touch_count : Int

  fn new() -> Game
}

///|
/// Creates an actor initialized at the starting tile.
#deprecated
pub fn Actor::new() -> Actor {
  {
    x: start_x,
    y: start_y,
    from_x: start_x,
    from_y: start_y,
    to_x: start_x,
    to_y: start_y,
    fx: Float::from_int(start_x),
    fy: Float::from_int(start_y),
    t: 1.0,
    moving: false,
  }
}

///|
/// Creates an inactive guard with default patrol parameters.
#deprecated
pub fn Guard::new() -> Guard {
  {
    active: false,
    body: Actor(),
    mode: Patrol,
    move_cd: 0.0,
    stun_t: 0.0,
    dir_x: 1,
    dir_y: 0,
    patrol_min: 1,
    patrol_max: 1,
    seed: 1,
    alert_t: 0.0,
    color_id: 0,
  }
}

///|
/// Creates an inactive loot slot.
#deprecated
pub fn Loot::new() -> Loot {
  { active: false, x: 0, y: 0, kind: Gold, value: 0 }
}

///|
/// Creates an inactive smoke slot.
#deprecated
pub fn Smoke::new() -> Smoke {
  { active: false, x: 0, y: 0, t: 0.0 }
}

///|
/// Creates an inactive particle slot.
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
    kind: Spark,
  }
}

///|
/// Creates a new game state with all pools preallocated.
#deprecated
pub fn Game::new() -> Game {
  {
    map: Array::make(grid_w * grid_h, Wall),
    guards: Array::makei(max_guards, fn(_i) { Guard() }),
    loots: Array::makei(max_loot, fn(_i) { Loot() }),
    smokes: Array::makei(max_smokes, fn(_i) { Smoke() }),
    particles: Array::makei(max_particles, fn(_i) { Particle() }),
    state: Title,
    player: Actor(),
    lives: 3,
    score: 0,
    best_score: 0,
    loot_taken: 0,
    vault_open: false,
    time_left: run_time_limit,
    req_dx: 0,
    req_dy: 0,
    action_down: false,
    action_pressed: false,
    move_cd: 0.0,
    action_cd: 0.0,
    smoke_energy: 100.0,
    touch_cd: 0.0,
    msg: "",
    msg_t: 0.0,
    flash_t: 0.0,
    shake_t: 0.0,
    time_s: 0.0,
    hint_i: 0,
    win: false,
    loss_reason: "",
    mouse_x: 0.0,
    mouse_y: 0.0,
    mouse_hold: false,
    touch_count: 0,
  }
}
