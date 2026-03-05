///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1720

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 980

///|
/// Target frame rate for simulation and rendering.
pub let target_fps : Int = 120

///|
/// Maximum number of survivor entities in the pool.
pub let max_survivors : Int = 90

///|
/// Maximum number of hazard entities in the pool.
pub let max_hazards : Int = 160

///|
/// Maximum number of pickup entities in the pool.
pub let max_pickups : Int = 80

///|
/// Maximum number of particle entities in the pool.
pub let max_particles : Int = 1400

///|
/// Left edge of the playable world in pixels.
pub let world_x0 : Int = 24

///|
/// Top edge of the playable world in pixels.
pub let world_y0 : Int = 20

///|
/// Width of the playable world in pixels.
pub let world_w : Int = 1120

///|
/// Height of the playable world in pixels.
pub let world_h : Int = 940

///|
/// Left edge of the information panel.
pub let panel_x0 : Int = world_x0 + world_w + 24

///|
/// Width of the information panel.
pub let panel_w : Int = screen_w - panel_x0 - 24

///|
/// Collision radius of the rescue helicopter.
pub let heli_r : Float = 24.0

///|
/// Collision radius used for survivor pickup checks.
pub let survivor_r : Float = 15.0

///|
/// Number of rescues required to win the mission.
pub let rescue_target : Int = 18

///|
/// Time limit for a run, in seconds.
pub let run_time_goal : Float = 210.0

///|
/// Returns the x-position of the safe zone rectangle.
pub fn safe_zone_x() -> Int {
  world_x0 + world_w - 224
}

///|
/// Returns the y-position of the safe zone rectangle.
pub fn safe_zone_y() -> Int {
  world_y0 + 42
}

///|
/// Returns the width of the safe zone rectangle.
pub fn safe_zone_w() -> Int {
  184
}

///|
/// Returns the height of the safe zone rectangle.
pub fn safe_zone_h() -> Int {
  142
}

///|
/// Returns the title-screen start button rectangle.
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 280, 620, 560, 122)
}

///|
/// Returns the result-screen retry button rectangle.
pub fn retry_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 240, 648, 480, 110)
}

///|
/// Returns the on-screen left movement button rectangle.
pub fn btn_left() -> (Int, Int, Int, Int) {
  (1230, 730, 104, 96)
}

///|
/// Returns the on-screen right movement button rectangle.
pub fn btn_right() -> (Int, Int, Int, Int) {
  (1460, 730, 104, 96)
}

///|
/// Returns the on-screen up movement button rectangle.
pub fn btn_up() -> (Int, Int, Int, Int) {
  (1345, 624, 104, 96)
}

///|
/// Returns the on-screen down movement button rectangle.
pub fn btn_down() -> (Int, Int, Int, Int) {
  (1345, 836, 104, 96)
}

///|
/// Returns the on-screen hook action button rectangle.
pub fn btn_hook() -> (Int, Int, Int, Int) {
  (1582, 704, 110, 124)
}

///|
/// Returns the on-screen boost action button rectangle.
pub fn btn_boost() -> (Int, Int, Int, Int) {
  (1582, 842, 110, 98)
}

///|
/// Returns the on-screen hint button rectangle.
pub fn btn_hint() -> (Int, Int, Int, Int) {
  (1582, 606, 110, 90)
}

///|
/// Returns the on-screen restart button rectangle.
pub fn btn_restart() -> (Int, Int, Int, Int) {
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
/// Distinguishes the kind of pickup entity.
pub(all) enum PickupKind {
  Fuel
  Medkit
  Turbo
} derive(Eq)

///|
/// Identifies the current phase of the game loop.
pub(all) enum GameState {
  Title
  Play
  Result
} derive(Eq)

///|
/// Returns the on-screen repair button rectangle.
pub fn btn_repair() -> (Int, Int, Int, Int) {
  (1462, 704, 110, 124)
}
