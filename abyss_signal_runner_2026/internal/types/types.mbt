///|
/// High-level state of the abyss run flow.
pub(all) enum GameState {
  Title
  Play
  StageClear
  GameOver
} derive(Eq)

///|
/// Spawnable world object category.
pub(all) enum ObjKind {
  Rock
  Mine
  Data
  Oxygen
  Current
  Scrap
} derive(Eq)

///|
/// Dynamic obstacle or pickup instance in the scrolling world.
pub(all) struct Obj {
  mut active : Bool
  mut kind : ObjKind
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut r : Float
  mut cloak : Bool
  mut spin : Float
  mut life : Float

  fn new() -> Obj
}

///|
/// Lightweight particle used for impacts and ambient effects.
pub(all) struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut size : Float
  mut kind : Int

  fn new() -> Particle
}

///|
/// Expanding ring effect used by sonar and hits.
pub(all) struct Ripple {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut r : Float
  mut life : Float
  mut kind : Int

  fn new() -> Ripple
}

///|
/// Short-lived trail quad used for movement streak rendering.
pub(all) struct Trail {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut w : Float
  mut h : Float
  mut life : Float
  mut kind : Int

  fn new() -> Trail
}

///|
/// Player submarine state and kinematic values.
pub(all) struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut r : Float
  mut invuln : Float
  mut hurt_t : Float
  mut anim_t : Float

  fn new() -> Player
}

///|
/// Full mutable game state for one abyss signal run, including entity pools,
/// player state, resource gauges, ability cooldowns, scoring, spawn scheduling,
/// and input abstraction for keyboard/mouse/touch.
pub(all) struct Game {
  // ──── Entity pools ────
  /// Fixed-size pool of world objects (rocks, mines, data shards, oxygen
  /// pickups, currents, scrap). Capacity is `max_objs` (420).
  /// Inactive slots have `active == false` and are recycled by `alloc_obj`.
  objs : Array[Obj]
  /// Fixed-size pool of lightweight visual particles for impacts, pickups,
  /// and ambient effects. Capacity is `max_particles` (560).
  particles : Array[Particle]
  /// Fixed-size pool of expanding ring effects used by sonar pulses and
  /// hit feedback. Capacity is `max_ripples` (64).
  ripples : Array[Ripple]
  /// Fixed-size pool of short-lived trail quads rendered behind the
  /// submarine during dash movement. Capacity is `max_trails` (180).
  trails : Array[Trail]
  // ──── Player ────
  /// The player's submarine: position, velocity, collision radius,
  /// invulnerability timer, hurt flash timer, and animation clock.
  hero : Player
  // ──── Core state ────
  /// Which screen/phase the game is currently in.
  /// Possible values: `Title`, `Play`, `StageClear`, `GameOver`.
  /// The main update loop dispatches to different logic based on this value.
  mut state : GameState
  /// Current stage number, starting at 1. Increases by 1 each time the
  /// player clears a stage. Affects scroll speed, spawn difficulty, and
  /// the stage distance goal.
  mut stage : Int
  /// How far (in world units) the player has scrolled in the current stage.
  /// Compared against `stage_goal` to trigger `StageClear`.
  mut distance : Float
  /// Distance threshold the player must reach to clear the current stage.
  /// Computed as `stage_base_goal + (stage - 1) * stage_goal_gain`.
  mut stage_goal : Float
  // ──── Scoring ────
  /// Cumulative score for the current run. Earned from collecting data,
  /// destroying mines, picking up scrap/oxygen, and clearing stages.
  /// All rewards are scaled by the current combo multiplier.
  mut score : Int
  /// Highest score ever reached across all runs in this session.
  /// Updated after every `add_score` call if `score` exceeds it.
  mut best_score : Int
  /// Total number of data shards collected in the current run.
  /// Incremented on Data pickup; displayed on the HUD.
  mut data_collected : Int
  /// Current combo multiplier chain (0..18). Each pickup or mine kill
  /// increments this by 1 (capped at 18). Resets to 0 on hull damage
  /// or when `combo_t` expires.
  mut combo : Int
  /// Seconds remaining before the combo counter resets to 0.
  /// Set to 3.4 s on each `push_combo` call; ticked down every frame.
  mut combo_t : Float
  // ──── Resources ────
  /// Submarine hull integrity as a percentage (0..100).
  /// Reduced by collisions with rocks, mines, and cave walls.
  /// When it reaches 0 the game transitions to `GameOver`.
  /// Partially restored between stages.
  mut hull : Float
  /// Oxygen supply as a percentage (0..100). Drains continuously during
  /// play at `oxygen_drain` per second, with extra drain during dashes
  /// and fast movement. Replenished by Oxygen and Data pickups.
  /// Reaching 0 triggers `GameOver`.
  mut oxygen : Float
  // ──── Ability cooldowns & active timers ────
  /// Seconds remaining on the sonar ability cooldown (0 = ready).
  /// Set to `sonar_cd_time` (2.1 s) when sonar is activated.
  mut sonar_cd : Float
  /// Seconds remaining of the active sonar pulse effect.
  /// While > 0, cloaked objects are revealed and nearby mines can be
  /// destroyed on contact. Set to `sonar_time` (0.76 s) on activation.
  mut sonar_t : Float
  /// Seconds remaining on the dash ability cooldown (0 = ready).
  /// Set to `dash_cd_time` (1.3 s) when dash is activated.
  mut dash_cd : Float
  /// Seconds remaining of the active dash state.
  /// While > 0, the submarine moves at `dash_speed` with brief
  /// invulnerability and can destroy rocks on contact.
  /// Set to `dash_time` (0.19 s) on activation.
  mut dash_t : Float
  // ──── Timing & effects ────
  /// Elapsed wall-clock time in seconds since the run started.
  /// Used by cave geometry functions for sinusoidal wall animation.
  mut time_s : Float
  /// Seconds remaining of the screen-wide white flash overlay.
  /// Set on hull damage; decays to 0 each frame. The renderer draws a
  /// semi-transparent white rectangle while this is positive.
  mut flash_t : Float
  /// Seconds remaining of the camera shake effect.
  /// Set on hull damage; decays to 0 each frame. The renderer offsets
  /// the camera by a random jitter while this is positive.
  mut shake_t : Float
  /// Elapsed time on the result screen (StageClear or GameOver).
  /// Used to pace celebration particles and the auto-advance delay
  /// (`stage_clear_delay`).
  mut result_t : Float
  /// Elapsed time used for the controls hint overlay on the title screen.
  /// Ticked up every frame; the hint fades in based on this value.
  mut hint_t : Float
  // ──── Scrolling & spawning ────
  /// Current forward scroll speed in world units per second.
  /// Starts at `base_scroll` and increases with stage number and distance.
  /// Drives object movement and the spawn scheduler.
  mut scroll_speed : Float
  /// Y coordinate at which the next obstacle wave will spawn.
  /// Starts at `spawn_start_y` (-120) and advances with scroll speed.
  /// When it crosses 0 a new wave is emitted and the value is pushed back
  /// by a random spacing interval.
  mut next_spawn_y : Float
  // ──── Abstracted input (written by input handlers, read by game logic) ────
  /// Horizontal movement axis, normalized to -1..1.
  /// Negative = left, positive = right. Set each frame from keyboard
  /// or touch d-pad; consumed by `apply_player_input`.
  mut input_x : Float
  /// Vertical movement axis, normalized to -1..1.
  /// Negative = up, positive = down. Set each frame from keyboard
  /// or touch d-pad; consumed by `apply_player_input`.
  mut input_y : Float
  /// True for the single frame when the player activates the dash ability.
  /// Set from Shift/K key press or touch dash button edge.
  mut input_dash_press : Bool
  /// True for the single frame when the player activates the sonar ability.
  /// Set from Space/J/L key press or touch sonar button edge.
  mut input_sonar_press : Bool
  /// True for the single frame when the player presses restart/continue.
  /// Used on title, stage-clear, and game-over screens to advance flow.
  mut input_restart_press : Bool
  // ──── Touch input state ────
  /// Whether the game is operating in touch-control mode.
  /// Set to true when `touch_count > 0`; once true, on-screen d-pad
  /// and action buttons are rendered.
  mut touch_mode : Bool
  /// Previous-frame pressed state of the touch dash button.
  /// Used for edge detection so a held touch registers as a single press.
  mut touch_dash_prev : Bool
  /// Previous-frame pressed state of the touch sonar button.
  /// Used for edge detection so a held touch registers as a single press.
  mut touch_sonar_prev : Bool
  /// Previous-frame pressed state of the touch restart/start button.
  /// Used for edge detection so a held touch registers as a single press.
  mut touch_restart_prev : Bool
  // ──── Raw pointer state (written by main loop before input handlers) ────
  /// Current mouse or primary touch X coordinate in screen pixels.
  /// Read by touch-button hit-testing in the input handlers.
  mut mx : Float
  /// Current mouse or primary touch Y coordinate in screen pixels.
  /// Read by touch-button hit-testing in the input handlers.
  mut my : Float
  /// True while the left mouse button or primary touch is held down.
  /// Used together with `mx`/`my` for touch-button hit-testing.
  mut hold : Bool
  /// Number of active touch points this frame (0 on desktop).
  /// When > 0, activates `touch_mode` and enables on-screen controls.
  mut touch_count : Int

  fn new() -> Game
}

///|
/// Creates an inactive object slot for the object pool.
#deprecated
pub fn Obj::new() -> Obj {
  {
    active: false,
    kind: Rock,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    r: 0.0,
    cloak: false,
    spin: 0.0,
    life: 0.0,
  }
}

///|
/// Creates an inactive particle slot for the particle pool.
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
    kind: 0,
  }
}

///|
/// Creates an inactive ripple slot for the ripple pool.
#deprecated
pub fn Ripple::new() -> Ripple {
  { active: false, x: 0.0, y: 0.0, r: 0.0, life: 0.0, kind: 0 }
}

///|
/// Creates an inactive trail slot for the trail pool.
#deprecated
pub fn Trail::new() -> Trail {
  { active: false, x: 0.0, y: 0.0, w: 0.0, h: 0.0, life: 0.0, kind: 0 }
}

///|
/// Creates a player initialized at the default on-screen start position.
#deprecated
pub fn Player::new() -> Player {
  {
    x: Float::from_int(screen_w / 2),
    y: Float::from_int(screen_h) * 0.72,
    vx: 0.0,
    vy: 0.0,
    r: player_r,
    invuln: 0.0,
    hurt_t: 0.0,
    anim_t: 0.0,
  }
}

///|
/// Creates a new game state with initialized pools and stage counters.
#deprecated
pub fn Game::new() -> Game {
  {
    objs: Array::makei(max_objs, fn(_i) { Obj() }),
    particles: Array::makei(max_particles, fn(_i) { Particle() }),
    ripples: Array::makei(max_ripples, fn(_i) { Ripple() }),
    trails: Array::makei(max_trails, fn(_i) { Trail() }),
    hero: Player(),
    state: Title,
    stage: 1,
    distance: 0.0,
    stage_goal: stage_base_goal,
    score: 0,
    best_score: 0,
    data_collected: 0,
    combo: 0,
    combo_t: 0.0,
    hull: 100.0,
    oxygen: 100.0,
    sonar_cd: 0.0,
    sonar_t: 0.0,
    dash_cd: 0.0,
    dash_t: 0.0,
    time_s: 0.0,
    flash_t: 0.0,
    shake_t: 0.0,
    result_t: 0.0,
    hint_t: 0.0,
    scroll_speed: base_scroll,
    next_spawn_y: spawn_start_y,
    input_x: 0.0,
    input_y: 0.0,
    input_dash_press: false,
    input_sonar_press: false,
    input_restart_press: false,
    touch_mode: false,
    touch_dash_prev: false,
    touch_sonar_prev: false,
    touch_restart_prev: false,
    mx: 0.0,
    my: 0.0,
    hold: false,
    touch_count: 0,
  }
}
