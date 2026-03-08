///|
/// Stores runtime data for Breach.
pub(all) struct Breach {
  room : Int
  mut severity : Float
  mut raider_cd : Float
  mut ember_cd : Float

  fn new(room : Int) -> Breach
}

///|
/// Stores runtime data for Raider.
pub(all) struct Raider {
  active : Bool
  mut room : Int
  mut x : Float
  mut y : Float
  mut hp : Float
  max_hp : Float
  mut panic_t : Float
  mut attack_cd : Float

  fn new() -> Raider
}

///|
/// Stores runtime data for Flame.
pub(all) struct Flame {
  active : Bool
  room : Int
  x : Float
  y : Float
  mut intensity : Float
  mut spread_cd : Float

  fn new() -> Flame
}

///|
/// Enumerates high-level states in the game flow.
pub(all) enum GameState {
  Title
  Playing
  Paused
  GameOver
} derive(Eq)

///|
/// Stores runtime data for Keeper.
pub(all) struct Keeper {
  mut room : Int
  mut x : Float
  mut y : Float
  mut facing_x : Float
  mut facing_y : Float
  mut stamina : Float
  mut extinguisher_mode : Bool
  mut action_cd : Float
  mut shield_cd : Float
  mut shield_t : Float
  mut ink_shields : Float

  fn new() -> Keeper
}

///|
/// Aggregates all mutable state needed to run one session of Dragon Scroll Keeper.
/// The player (keeper) defends a vault of dragon scrolls against raiders and
/// fires across multiple chambers, using attacks, seals, extinguishers, and ink
/// shield bursts. The game progresses in waves of increasing difficulty.
pub(all) struct Game {
  // ──── Entity pools ────
  /// Per-room breach slots, one for each of the `chamber_count` rooms.
  /// Each breach tracks severity (0..100) and cooldown timers that spawn
  /// raiders and flames. Written by the breach system; read by seal actions.
  breaches : Array[Breach]
  /// Pre-allocated raider pool (up to `max_raiders` = 160 slots).
  /// Active raiders spawn from breaches, move toward the vault, and drain
  /// scroll integrity. The keeper defeats them with attacks or ink shields.
  raiders : Array[Raider]
  /// Pre-allocated flame pool (up to `max_flames` = 220 slots).
  /// Active flames spawn from breach embers, decay over time, spread to
  /// child flames, and continuously drain scroll integrity weighted by room.
  flames : Array[Flame]
  /// The player-controlled keeper character.
  /// Holds position, room, stamina, facing direction, mode toggle, cooldowns,
  /// and ink shield stock. Updated every frame by motion and timer systems.
  keeper : Keeper
  // ──── Core state ────
  /// Which screen/phase the game is currently in.
  /// Possible values: `Title`, `Playing`, `Paused`, `GameOver`.
  /// The main update loop dispatches to different logic based on this value.
  mut state : GameState
  /// Current wave number, starting at 1 and incrementing each time the wave
  /// timer elapses. Higher waves increase breach pressure, raider HP/speed,
  /// and flame spawn rates.
  mut wave : Int
  /// Elapsed time within the current wave, in seconds.
  /// Compared against `wave_goal_t` to determine when to advance to the
  /// next wave. Reset to 0 on each wave transition.
  mut wave_t : Float
  /// Duration of the current wave in seconds (computed from `wave_duration()`).
  /// When `wave_t` reaches this value the wave advances, replenishing
  /// resources and raising new breaches.
  mut wave_goal_t : Float
  /// Cooldown timer (seconds) until the next random breach-pressure event.
  /// Decremented each frame; when it reaches 0, one or more rooms receive a
  /// severity spike and the cooldown resets to a wave-scaled value (min 1.2s).
  mut breach_event_cd : Float
  // ──── Scroll / resources ────
  /// Health of the dragon scroll archive, range 0..100.
  /// Drained by breach pressure, raider vault strikes, and active flames.
  /// When it reaches 0 the game ends. Partially restored by ink shield
  /// bursts and wave transitions.
  mut scroll_integrity : Float
  /// Number of seal charges available this wave.
  /// Starts at `seal_charges_start` (4) and gains 1 per wave (max 7).
  /// Each seal action consumes one charge to reduce a breach's severity.
  mut seal_charges : Int
  // ──── Scoring ────
  /// Cumulative score for the current run.
  /// Increased by attacking raiders, sealing breaches, extinguishing flames,
  /// ink shield hits, and wave-completion bonuses.
  mut score : Int
  /// Highest score achieved across all runs in this session.
  /// Updated at game-over if the current `score` exceeds it.
  mut best_score : Int
  // ──── Session statistics ────
  /// Total number of raiders defeated in the current run.
  /// Incremented each time a raider's HP drops to 0.
  mut raiders_defeated : Int
  /// Total number of flames fully extinguished in the current run.
  /// Incremented when a flame's intensity reaches 0 via extinguisher or
  /// ink shield burst.
  mut flames_cleared : Int
  /// Total number of breaches fully sealed in the current run.
  /// Incremented when a seal action reduces a breach's severity to 0.
  mut seals_done : Int
  /// Wall-clock game time elapsed since the run started, in seconds.
  /// Accumulated each frame with a clamped dt (max 0.05s). Used for
  /// display and message lifetime tracking.
  mut time_s : Float
  // ──── HUD message ────
  /// Text currently shown in the on-screen message bar.
  /// Set by `set_message()` along with `message_t` to control display time.
  mut message : String
  /// Remaining display time for the current message, in seconds.
  /// Decremented each frame; when it reaches 0 the message fades.
  /// Set to 99.0 for persistent messages (title, game-over).
  mut message_t : Float
  // ──── Input snapshot ────
  /// Horizontal movement axis, range -1..1.
  /// Set from WASD/arrow keys each frame. Drives keeper horizontal motion
  /// and facing direction.
  mut input_x : Float
  /// Vertical movement axis, range -1..1.
  /// Set from WASD/arrow keys each frame. Drives keeper vertical motion
  /// and facing direction.
  mut input_y : Float
  /// True for one frame when J is pressed.
  /// In Playing state triggers attack (combat mode) or seal (if near a breach)
  /// or extinguish (extinguisher mode). Also starts a new run from Title/GameOver.
  mut input_action_press : Bool
  /// True for one frame when K is pressed.
  /// In Playing state toggles between combat/seal mode and extinguisher mode.
  /// In Paused/GameOver state returns to the title screen.
  mut input_cancel_press : Bool
  /// True for one frame when Space is pressed.
  /// Triggers an ink shield burst that damages nearby raiders, quenches
  /// flames, and temporarily reduces integrity loss.
  mut input_shield_press : Bool
  /// True for one frame when P is pressed.
  /// Toggles between Playing and Paused states.
  mut input_pause_press : Bool
  /// True for one frame when R is pressed.
  /// Starts a new run from Paused or GameOver states.
  mut input_restart_press : Bool

  fn new() -> Game
}

///|
/// Creates a default Breach value for a new session.
#deprecated
pub fn Breach::new(room : Int) -> Breach {
  { room, severity: 0.0, raider_cd: randf(0.8, 1.6), ember_cd: randf(0.7, 1.4) }
}

///|
/// Creates a default Raider value for a new session.
#deprecated
pub fn Raider::new() -> Raider {
  {
    active: false,
    room: 0,
    x: 0.0,
    y: 0.0,
    hp: 0.0,
    max_hp: 1.0,
    panic_t: 0.0,
    attack_cd: 0.0,
  }
}

///|
/// Creates a default Flame value for a new session.
#deprecated
pub fn Flame::new() -> Flame {
  { active: false, room: 0, x: 0.0, y: 0.0, intensity: 0.0, spread_cd: 0.0 }
}

///|
/// Creates a default Keeper value for a new session.
#deprecated
pub fn Keeper::new() -> Keeper {
  {
    room: vault_room,
    x: chamber_center_x(),
    y: chamber_center_y(),
    facing_x: 1.0,
    facing_y: 0.0,
    stamina: keeper_stamina_max,
    extinguisher_mode: false,
    action_cd: 0.0,
    shield_cd: 0.0,
    shield_t: 0.0,
    ink_shields: ink_shield_stock_start,
  }
}

///|
/// Creates a default Game value for a new session.
#deprecated
pub fn Game::new() -> Game {
  {
    breaches: Array::makei(chamber_count, fn(room) { Breach(room) }),
    raiders: Array::makei(max_raiders, fn(_i) { Raider() }),
    flames: Array::makei(max_flames, fn(_i) { Flame() }),
    keeper: Keeper(),
    state: Title,
    wave: 1,
    wave_t: 0.0,
    wave_goal_t: wave_duration(1),
    breach_event_cd: 1.4,
    scroll_integrity: scroll_integrity_max,
    seal_charges: seal_charges_start,
    score: 0,
    best_score: 0,
    raiders_defeated: 0,
    flames_cleared: 0,
    seals_done: 0,
    time_s: 0.0,
    message: "Press J to begin guarding the dragon scroll vault.",
    message_t: 99.0,
    input_x: 0.0,
    input_y: 0.0,
    input_action_press: false,
    input_cancel_press: false,
    input_shield_press: false,
    input_pause_press: false,
    input_restart_press: false,
  }
}
