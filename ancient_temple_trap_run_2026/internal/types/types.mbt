///|
/// Main state machine for title, run, and outcomes.
pub(all) enum GameState {
  Title
  Play
  StageClear
  Failed
  Victory
} derive(Eq)

///|
/// Collectible relic placed in a stage.
pub(all) struct Relic {
  mut active : Bool
  x : Float
  y : Float
  r : Float
}

///|
/// Periodic trap hazard with hot/cool timing window.
pub(all) struct Trap {
  x : Float
  y : Float
  w : Float
  h : Float
  cycle : Float
  hot_window : Float
  phase : Float
  kind : Int
  label : String
  mut timer : Float
}

///|
/// Static hazard zone that fails the run on contact.
pub(all) struct Hazard {
  x : Float
  y : Float
  w : Float
  h : Float
  kind : Int
  label : String
}

///|
/// Pressure plate that controls one or more doors.
pub(all) struct Plate {
  x : Float
  y : Float
  w : Float
  h : Float
  mut pressed : Bool
}

///|
/// Door controlled by a plate timer.
pub(all) struct Door {
  x : Float
  y : Float
  w : Float
  h : Float
  plate_index : Int
  hold_time : Float
  mut timer : Float
  mut open : Bool
}

///|
/// Immutable stage blueprint for spawn and hazard layout.
pub(all) struct StageLayout {
  start_x : Float
  start_y : Float
  exit_x : Float
  exit_y : Float
  exit_w : Float
  exit_h : Float
  relics : Array[Relic]
  traps : Array[Trap]
  hazards : Array[Hazard]
  plates : Array[Plate]
  doors : Array[Door]
}

///|
/// Player position, bounds, and stamina state.
pub(all) struct Player {
  mut x : Float
  mut y : Float
  w : Float
  h : Float
  mut stamina : Float
  mut dash_on : Bool

  fn new() -> Player
}

///|
/// Mutable runtime state for the full game session, including the player,
/// stage layout entities (relics, traps, hazards, plates, doors), progression
/// tracking, UI banners, and input abstraction for keyboard/mouse/touch.
pub(all) struct Game {
  // ──── Player ────
  /// The player character: position, bounding-box size, stamina gauge,
  /// and whether a dash is currently active.
  player : Player
  // ──── Stage entities (swapped when a new stage loads) ────
  /// Active relics in the current chamber. Collecting all of them unlocks
  /// the exit gate. Replaced wholesale by `apply_layout` on stage load.
  mut relics : Array[Relic]
  /// Periodic trap hazards (spikes, darts) in the current chamber.
  /// Each trap cycles between hot and cool phases; contact during the hot
  /// phase fails the run. Replaced on stage load.
  mut traps : Array[Trap]
  /// Static hazard zones (e.g. lava) that instantly fail the run on contact.
  /// Replaced on stage load.
  mut hazards : Array[Hazard]
  /// Pressure plates that the player can step on to open linked doors.
  /// Replaced on stage load; their `pressed` state is refreshed every frame.
  mut plates : Array[Plate]
  /// Doors controlled by pressure plates. A door stays open while its
  /// linked plate's hold timer is positive. Replaced on stage load.
  mut doors : Array[Door]
  // ──── Core state ────
  /// Which screen/phase the game is currently in.
  /// Possible values: `Title`, `Play`, `StageClear`, `Failed`, `Victory`.
  /// The main update loop dispatches to different input and logic handlers
  /// based on this value.
  mut state : GameState
  /// Zero-based index of the current stage (0..stage_count-1).
  /// Used to select the stage layout and to decide whether clearing the
  /// stage triggers `StageClear` or `Victory`.
  mut stage_index : Int
  /// Total number of stages in a full run (constant `stage_total`, currently 3).
  /// Used as the upper bound when checking whether more stages remain.
  stage_count : Int
  // ──── Relic tracking ────
  /// Number of relics that must be collected to unlock the exit in the
  /// current stage. Set to the length of the stage's relic array on load.
  mut required_relics : Int
  /// Number of relics the player has collected so far in the current stage.
  /// Incremented by `collect_relics`; compared against `required_relics`
  /// to decide if the exit gate is unlocked.
  mut collected_relics : Int
  // ──── Exit gate geometry ────
  /// Left edge X of the exit gate rectangle in world pixels.
  /// Set from the stage layout; tested against the player's bounding box
  /// by `reach_exit`.
  mut exit_x : Float
  /// Top edge Y of the exit gate rectangle in world pixels.
  mut exit_y : Float
  /// Width of the exit gate rectangle in world pixels.
  mut exit_w : Float
  /// Height of the exit gate rectangle in world pixels.
  mut exit_h : Float
  // ──── Timing & UI ────
  /// Elapsed time in seconds since the current stage began.
  /// Ticked each play-state frame; displayed on the HUD.
  mut stage_time : Float
  /// Human-readable reason string shown on the failure screen
  /// (e.g. "You slipped into a molten trench."). Set by `fail_stage`.
  mut fail_reason : String
  /// Short message shown as a temporary banner overlay
  /// (e.g. "Relic secured", "Exit sealed: collect every relic").
  /// Set by `set_banner`; fades when `banner_t` reaches 0.
  mut banner_text : String
  /// Seconds remaining before `banner_text` disappears.
  /// Decremented each frame; when it reaches 0 the banner is hidden.
  mut banner_t : Float
  // ──── Abstracted input (written by input handlers, read by game logic) ────
  /// Horizontal movement axis, clamped to -1..1.
  /// Negative = left, positive = right. Set each frame from keyboard
  /// or touch d-pad; consumed by `move_player`.
  mut input_x : Float
  /// Vertical movement axis, clamped to -1..1.
  /// Negative = up, positive = down. Set each frame from keyboard
  /// or touch d-pad; consumed by `move_player`.
  mut input_y : Float
  /// True while the player is holding the dash input (Shift key or touch
  /// dash button). While held and stamina is above `dash_min_stamina`,
  /// the player moves at `player_speed_dash` and stamina drains.
  mut input_dash_hold : Bool
  /// True for the single frame when the player presses start on the title
  /// screen. Consumed by `update_title_state` to begin a new run.
  mut input_start_press : Bool
  /// True for the single frame when the player presses the restart/retry
  /// button. Consumed on play, stage-clear, failed, and victory screens
  /// to reload or reset.
  mut input_restart_press : Bool
  /// True for the single frame when the player presses the "next" or
  /// "continue" button. Consumed on stage-clear (advance stage), failed
  /// (return to title), and victory (start new run) screens.
  mut input_next_press : Bool
  // ──── Touch input state ────
  /// Whether the game is operating in touch-control mode.
  /// Set to true when `touch_count > 0`; once true, on-screen d-pad
  /// and action buttons are rendered.
  mut touch_mode : Bool
  /// Previous-frame pressed state of the touch start button.
  /// Used for edge detection so a held touch registers as a single press.
  mut touch_start_prev : Bool
  /// Previous-frame pressed state of the touch restart button.
  /// Used for edge detection so a held touch registers as a single press.
  mut touch_restart_prev : Bool
  /// Previous-frame pressed state of the touch next/continue button.
  /// Used for edge detection so a held touch registers as a single press.
  mut touch_next_prev : Bool
  // ──── Raw pointer state (written by main loop before input handlers) ────
  /// Current mouse or primary touch X coordinate in screen pixels.
  /// Read by touch-button hit-testing in the input handlers.
  mut mouse_x : Float
  /// Current mouse or primary touch Y coordinate in screen pixels.
  /// Read by touch-button hit-testing in the input handlers.
  mut mouse_y : Float
  /// True while the left mouse button or primary touch is held down.
  /// Used together with `mouse_x`/`mouse_y` for button hit-testing.
  mut mouse_hold : Bool
  /// Number of active touch points this frame (0 on desktop).
  /// When > 0, activates `touch_mode` and enables on-screen controls.
  mut touch_count : Int

  fn new() -> Game
}

///|
/// Create a player at default spawn with full stamina.
#deprecated
pub fn Player::new() -> Player {
  {
    x: world_x + 90.0,
    y: world_y + world_h - 100.0,
    w: player_w,
    h: player_h,
    stamina: stamina_max,
    dash_on: false,
  }
}

///|
/// Build a fresh game initialized to title state.
#deprecated
pub fn Game::new() -> Game {
  {
    player: Player(),
    relics: [],
    traps: [],
    hazards: [],
    plates: [],
    doors: [],
    state: Title,
    stage_index: 0,
    stage_count: stage_total,
    required_relics: 0,
    collected_relics: 0,
    exit_x: world_x + world_w - 110.0,
    exit_y: world_y + 80.0,
    exit_w: 80.0,
    exit_h: 120.0,
    stage_time: 0.0,
    fail_reason: "",
    banner_text: "",
    banner_t: 0.0,
    input_x: 0.0,
    input_y: 0.0,
    input_dash_hold: false,
    input_start_press: false,
    input_restart_press: false,
    input_next_press: false,
    touch_mode: false,
    touch_start_prev: false,
    touch_restart_prev: false,
    touch_next_prev: false,
    mouse_x: 0.0,
    mouse_y: 0.0,
    mouse_hold: false,
    touch_count: 0,
  }
}

///|
/// Create an active relic at world position `(x, y)`.
pub fn make_relic(x : Float, y : Float) -> Relic {
  { active: true, x, y, r: 13.0 }
}

///|
/// Create a timed trap hazard definition.
pub fn make_trap(
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  cycle : Float,
  hot_window : Float,
  phase : Float,
  kind : Int,
  label : String,
) -> Trap {
  { x, y, w, h, cycle, hot_window, phase, kind, label, timer: 0.0 }
}

///|
/// Create a static hazard rectangle.
pub fn make_hazard(
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  kind : Int,
  label : String,
) -> Hazard {
  { x, y, w, h, kind, label }
}

///|
/// Create a pressure plate with default unpressed state.
pub fn make_plate(x : Float, y : Float, w : Float, h : Float) -> Plate {
  { x, y, w, h, pressed: false }
}

///|
/// Create a door controlled by `plate_index` and hold timer.
pub fn make_door(
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  plate_index : Int,
  hold_time : Float,
) -> Door {
  { x, y, w, h, plate_index, hold_time, timer: 0.0, open: false }
}
