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
}

///|
/// Mutable runtime state for the full game session.
pub(all) struct Game {
  player : Player
  mut relics : Array[Relic]
  mut traps : Array[Trap]
  mut hazards : Array[Hazard]
  mut plates : Array[Plate]
  mut doors : Array[Door]
  mut state : GameState
  mut stage_index : Int
  stage_count : Int
  mut required_relics : Int
  mut collected_relics : Int
  mut exit_x : Float
  mut exit_y : Float
  mut exit_w : Float
  mut exit_h : Float
  mut stage_time : Float
  mut fail_reason : String
  mut banner_text : String
  mut banner_t : Float
  mut input_x : Float
  mut input_y : Float
  mut input_dash_hold : Bool
  mut input_start_press : Bool
  mut input_restart_press : Bool
  mut input_next_press : Bool
  mut touch_mode : Bool
  mut touch_start_prev : Bool
  mut touch_restart_prev : Bool
  mut touch_next_prev : Bool
  mut mouse_x : Float
  mut mouse_y : Float
  mut mouse_hold : Bool
  mut touch_count : Int
}

///|
/// Create a player at default spawn with full stamina.
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
pub fn Game::new() -> Game {
  {
    player: Player::new(),
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
