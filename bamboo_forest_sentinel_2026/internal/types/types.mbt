///|
/// Enumerates high-level states in the game flow.
pub(all) enum GameState {
  Title
  Playing
  Paused
  GameOver
} derive(Eq)

///|
/// Stores runtime data for InputState.
pub(all) struct InputState {
  mut move_x : Int
  mut move_y : Int
  mut press_j : Bool
  mut press_k : Bool
  mut press_space : Bool
  mut press_pause : Bool
  mut press_restart : Bool
  mut press_start : Bool

  fn new() -> InputState
}

///|
/// Creates a default InputState value for a new session.
#deprecated
pub fn InputState::new() -> InputState {
  {
    move_x: 0,
    move_y: 0,
    press_j: false,
    press_k: false,
    press_space: false,
    press_pause: false,
    press_restart: false,
    press_start: false,
  }
}

///|
/// Stores runtime data for Player.
pub(all) struct Player {
  mut x : Float
  mut y : Float
  mut facing_x : Float
  mut facing_y : Float
  mut dash_vx : Float
  mut dash_vy : Float
  mut dash_t : Float
  mut dash_cd : Float
  mut attack_cd : Float
  mut attack_t : Float

  fn new() -> Player
}

///|
/// Creates a default Player value for a new session.
#deprecated
pub fn Player::new() -> Player {
  {
    x: Float::from_int(world_x + 330),
    y: lane_y(1),
    facing_x: 1.0,
    facing_y: 0.0,
    dash_vx: 0.0,
    dash_vy: 0.0,
    dash_t: 0.0,
    dash_cd: 0.0,
    attack_cd: 0.0,
    attack_t: 0.0,
  }
}

///|
/// Stores runtime data for Beacon.
pub(all) struct Beacon {
  x : Float
  y : Float
  mut integrity : Float
  mut pulse_t : Float

  fn new(index : Int) -> Beacon
}

///|
/// Creates a default Beacon value for a new session.
#deprecated
pub fn Beacon::new(index : Int) -> Beacon {
  let (x, y) = beacon_position(index)
  { x, y, integrity: beacon_integrity_max, pulse_t: 0.0 }
}

///|
/// Stores runtime data for Trap.
pub(all) struct Trap {
  mut active : Bool
  x : Float
  y : Float
  mut trigger_cd : Float
  mut flash_t : Float

  fn new(index : Int) -> Trap
}

///|
/// Creates a default Trap value for a new session.
#deprecated
pub fn Trap::new(index : Int) -> Trap {
  let (x, y) = trap_slot_position(index)
  { active: false, x, y, trigger_cd: 0.0, flash_t: 0.0 }
}

///|
/// Stores runtime data for Enemy.
pub(all) struct Enemy {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut hp : Float
  mut max_hp : Float
  mut speed : Float
  mut damage : Float
  mut target : Int
  mut slow_t : Float
  mut kind : Int
  mut anim_t : Float

  fn new() -> Enemy
}

///|
/// Creates a default Enemy value for a new session.
#deprecated
pub fn Enemy::new() -> Enemy {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    hp: 0.0,
    max_hp: 0.0,
    speed: 0.0,
    damage: 0.0,
    target: 0,
    slow_t: 0.0,
    kind: 0,
    anim_t: 0.0,
  }
}

///|
/// Aggregates all mutable state needed to run one game session of
/// Bamboo Forest Sentinel. The player defends shrine beacons across
/// increasingly difficult nights by slashing enemies, placing bamboo
/// snare traps, and charging a moon-sweep area attack.
pub(all) struct Game {
  // ──── Input & entities ────
  /// Per-frame snapshot of keyboard input (movement axes and action presses).
  /// Populated at the start of each `update_game` call and read by every
  /// gameplay system that needs player intent.
  input : InputState
  /// The player-controlled sentinel. Holds position, facing direction,
  /// dash state, and attack cooldowns. Updated by movement and action systems.
  player : Player
  /// Fixed-size array of shrine beacons the player must protect.
  /// Length equals `beacon_count` (3). Each beacon has an integrity value
  /// that enemies drain on contact; when all reach zero the run ends.
  beacons : Array[Beacon]
  /// Pre-allocated grid of trap slots (trap_slot_count = rows * cols = 18).
  /// Each slot has a fixed world position; `active` marks whether a bamboo
  /// snare is currently placed there. Traps damage and slow nearby enemies.
  traps : Array[Trap]
  /// Object pool of enemies, pre-allocated to `max_enemies` (260) slots.
  /// Active enemies march toward their target beacon; inactive slots are
  /// recycled by the spawning system each night.
  enemies : Array[Enemy]
  // ──── Core state ────
  /// Which screen/phase the game is currently in.
  /// Possible values: `Title`, `Playing`, `Paused`, `GameOver`.
  /// The main update loop dispatches to different logic based on this value.
  mut state : GameState
  /// Current night (wave) number, starting at 1.
  /// Increases by 1 each time the player clears all spawned enemies.
  /// Controls enemy stat scaling, spawn pool size, and score bonuses.
  mut night : Int
  /// Cumulative score for the current run, in points.
  /// Increased by killing enemies and clearing nights. Displayed on the HUD.
  mut score : Int
  /// Highest score achieved across all runs in this session.
  /// Updated whenever `score` exceeds it. Displayed on the HUD for reference.
  mut best_score : Int
  /// Total number of enemies killed in the current run.
  /// Incremented by `register_kill` and displayed on the HUD.
  mut kills : Int
  /// Wall-clock time elapsed during the current run, in seconds.
  /// Incremented every play-state frame by `dt`. Used for HUD display only.
  mut elapsed : Float
  // ──── Player resources ────
  /// Current energy, in the range [0, energy_max] (0..100).
  /// Consumed by attacks (6), dashes (18), and trap placement (18).
  /// Regenerates passively at `energy_regen` per second and gains small
  /// bursts on kills. Displayed as a bar on the HUD.
  mut energy : Float
  /// Charge toward the moon-sweep ultimate ability, range [0, sweep_charge_max] (0..100).
  /// Builds passively, on melee hits, on trap hits, and on kills.
  /// When full, the player can fire a large AoE sweep that damages and slows
  /// all enemies within `sweep_radius`.
  mut sweep_charge : Float
  /// Cooldown timer for placing traps, in seconds. Counts down to 0.
  /// Set to `trap_place_cooldown` (0.46 s) when a trap is placed; the player
  /// cannot place another trap until it reaches 0.
  mut trap_place_cd : Float
  // ──── Spawning ────
  /// Number of enemies still waiting to be spawned this night.
  /// Set to `night_spawn_base + (night-1) * night_spawn_step` at the start
  /// of each night. Decremented by 1 each time an enemy is spawned.
  /// When 0 and no active enemies remain, the night is cleared.
  mut spawn_pool : Int
  /// Countdown timer until the next enemy spawn, in seconds.
  /// Reset to the night's spawn interval after each successful spawn.
  /// Decremented by `dt` every play frame.
  mut spawn_cd : Float
  // ──── Visual / UI timers ────
  /// Remaining duration of the moon-sweep visual effect, in seconds.
  /// Set to `sweep_fx_time` (0.34 s) when a sweep fires; the renderer
  /// draws a radial flash while this is positive. Counts down to 0.
  mut sweep_t : Float
  /// Remaining display time for the "Night N" banner overlay, in seconds.
  /// Set to `night_banner_time` (1.35 s) at the start of each night.
  /// The renderer draws the banner while this is positive.
  mut night_banner_t : Float
  /// Short text shown in the HUD status area (e.g. "Slash connected.",
  /// "Night 1 begins."). Set by `set_status` along with `status_t`.
  mut status_text : String
  /// Remaining display time for `status_text`, in seconds.
  /// Counts down to 0; when it reaches 0 the status text is hidden.
  mut status_t : Float
  /// Remaining duration of camera-shake feedback, in seconds.
  /// Set to `shake_hit_time` (0.18 s) when an enemy reaches a beacon
  /// or during a sweep. The renderer offsets the camera while positive.
  mut shake_t : Float
  /// Human-readable reason the run ended (e.g. "All shrine beacons collapsed.").
  /// Set when transitioning to `GameOver`; empty string during active play.
  /// Displayed on the game-over screen.
  mut game_over_reason : String

  fn new() -> Game
}

///|
/// Creates a default Game value for a new session.
#deprecated
pub fn Game::new() -> Game {
  let beacons = Array::makei(beacon_count, fn(i) { Beacon(i) })
  let traps = Array::makei(trap_slot_count, fn(i) { Trap(i) })
  let enemies = Array::makei(max_enemies, fn(_i) { Enemy() })

  {
    input: InputState(),
    player: Player(),
    beacons,
    traps,
    enemies,
    state: Title,
    night: 1,
    score: 0,
    best_score: 0,
    kills: 0,
    elapsed: 0.0,
    energy: energy_max,
    sweep_charge: 0.0,
    trap_place_cd: 0.0,
    spawn_pool: 0,
    spawn_cd: 0.0,
    sweep_t: 0.0,
    night_banner_t: 0.0,
    status_text: "Press J / Enter / Space to begin the first night",
    status_t: 2.4,
    shake_t: 0.0,
    game_over_reason: "",
  }
}
