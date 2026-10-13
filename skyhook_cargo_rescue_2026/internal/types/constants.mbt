///|
/// Width of the game window in pixels.
pub let screen_w : Int32 = 1720

///|
/// Height of the game window in pixels.
pub let screen_h : Int32 = 980

///|
/// Target frame rate for simulation and rendering.
pub let target_fps : Int32 = 120

///|
/// Maximum number of survivor entities in the pool.
pub let max_survivors : Int32 = 90

///|
/// Maximum number of hazard entities in the pool.
pub let max_hazards : Int32 = 160

///|
/// Maximum number of pickup entities in the pool.
pub let max_pickups : Int32 = 80

///|
/// Maximum number of particle entities in the pool.
pub let max_particles : Int32 = 1400

///|
/// Left edge of the playable world in pixels.
pub let world_x0 : Int32 = 24

///|
/// Top edge of the playable world in pixels.
pub let world_y0 : Int32 = 20

///|
/// Width of the playable world in pixels.
pub let world_w : Int32 = 1120

///|
/// Height of the playable world in pixels.
pub let world_h : Int32 = 940

///|
/// Left edge of the information panel.
pub let panel_x0 : Int32 = world_x0 + world_w + 24

///|
/// Width of the information panel.
pub let panel_w : Int32 = screen_w - panel_x0 - 24

///|
/// Collision radius of the rescue helicopter.
pub let heli_r : Float = 24.0

///|
/// Collision radius used for survivor pickup checks.
pub let survivor_r : Float = 15.0

///|
/// Number of rescues required to win the mission.
pub let rescue_target : Int32 = 18

///|
/// Time limit for a run, in seconds.
pub let run_time_goal : Float = 210.0

///|
/// Returns the x-position of the safe zone rectangle.
pub fn safe_zone_x() -> Int32 {
  world_x0 + world_w - 224
}

///|
/// Returns the y-position of the safe zone rectangle.
pub fn safe_zone_y() -> Int32 {
  world_y0 + 42
}

///|
/// Returns the width of the safe zone rectangle.
pub fn safe_zone_w() -> Int32 {
  184
}

///|
/// Returns the height of the safe zone rectangle.
pub fn safe_zone_h() -> Int32 {
  142
}

///|
/// Returns the title-screen start button rectangle.
pub fn start_button_rect() -> (Int32, Int32, Int32, Int32) {
  (screen_w / 2 - 280, 620, 560, 122)
}

///|
/// Returns the result-screen retry button rectangle.
pub fn retry_button_rect() -> (Int32, Int32, Int32, Int32) {
  (screen_w / 2 - 240, 648, 480, 110)
}

///|
/// Returns the on-screen left movement button rectangle.
pub fn btn_left() -> (Int32, Int32, Int32, Int32) {
  (1230, 730, 104, 96)
}

///|
/// Returns the on-screen right movement button rectangle.
pub fn btn_right() -> (Int32, Int32, Int32, Int32) {
  (1460, 730, 104, 96)
}

///|
/// Returns the on-screen up movement button rectangle.
pub fn btn_up() -> (Int32, Int32, Int32, Int32) {
  (1345, 624, 104, 96)
}

///|
/// Returns the on-screen down movement button rectangle.
pub fn btn_down() -> (Int32, Int32, Int32, Int32) {
  (1345, 836, 104, 96)
}

///|
/// Returns the on-screen hook action button rectangle.
pub fn btn_hook() -> (Int32, Int32, Int32, Int32) {
  (1582, 704, 110, 124)
}

///|
/// Returns the on-screen boost action button rectangle.
pub fn btn_boost() -> (Int32, Int32, Int32, Int32) {
  (1582, 842, 110, 98)
}

///|
/// Returns the on-screen hint button rectangle.
pub fn btn_hint() -> (Int32, Int32, Int32, Int32) {
  (1582, 606, 110, 90)
}

///|
/// Returns the on-screen restart button rectangle.
pub fn btn_restart() -> (Int32, Int32, Int32, Int32) {
  (1462, 606, 110, 90)
}

///|
/// Distinguishes the kind of hazard entity.
pub(all) enum HazardKind {
  Cloud
  Drone
  Ice
} derive(Eq)

///|
pub extend HazardKind with Eq::{not_equal, equal}

///|
/// Distinguishes the kind of pickup entity.
pub(all) enum PickupKind {
  Fuel
  Medkit
  Turbo
} derive(Eq)

///|
pub extend PickupKind with Eq::{not_equal, equal}

///|
/// Identifies the current phase of the game loop.
pub(all) enum GameState {
  Title
  Play
  Result
} derive(Eq)

///|
pub extend GameState with Eq::{not_equal, equal}

///|
/// Returns the on-screen repair button rectangle.
pub fn btn_repair() -> (Int32, Int32, Int32, Int32) {
  (1462, 704, 110, 124)
}
