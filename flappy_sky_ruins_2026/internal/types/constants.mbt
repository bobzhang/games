///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1720

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 980

///|
/// Target frame rate used by the main loop.
pub let target_fps : Int = 120

///|
/// Player collision radius.
pub let player_r : Float = 24.0

///|
/// Downward acceleration applied each second.
pub let gravity : Float = 1220.0

///|
/// Instant vertical velocity applied when flapping.
pub let flap_impulse : Float = -420.0

///|
/// Maximum number of pooled obstacles.
pub let max_obs : Int = 72

///|
/// Maximum number of pooled pickups.
pub let max_pickups : Int = 64

///|
/// Maximum number of pooled particles.
pub let max_particles : Int = 1300

///|
/// Left x coordinate of the side panel.
pub let panel_x0 : Int = 1180

///|
/// Width of the side panel.
pub let panel_w : Int = screen_w - panel_x0 - 24

///|
/// Left edge of the playable world area.
pub let world_x0 : Int = 24

///|
/// Top edge of the playable world area.
pub let world_y0 : Int = 20

///|
/// Width of the playable world area.
pub let world_w : Int = panel_x0 - world_x0 - 24

///|
/// Height of the playable world area.
pub let world_h : Int = screen_h - 40

///|
/// Returns the title-screen start button rectangle.
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 260, 620, 520, 118)
}

///|
/// Returns the result-screen retry button rectangle.
pub fn retry_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 230, 652, 460, 108)
}

///|
/// Returns the touch rectangle for flap input.
pub fn btn_flap_rect() -> (Int, Int, Int, Int) {
  (1250, 730, 188, 126)
}

///|
/// Returns the touch rectangle for boost input.
pub fn btn_boost_rect() -> (Int, Int, Int, Int) {
  (1454, 730, 188, 126)
}

///|
/// Returns the touch rectangle for restarting the run.
pub fn btn_restart_rect() -> (Int, Int, Int, Int) {
  (1454, 876, 188, 74)
}

///|
/// Returns the touch rectangle for using hints.
pub fn btn_hint_rect() -> (Int, Int, Int, Int) {
  (1250, 876, 188, 74)
}

///|
/// Kind of obstacle in the scrolling world.
pub(all) enum ObstacleKind {
  Gate
  Beam
  Spinner
} derive(Eq)

///|
/// Kind of collectible pickup item.
pub(all) enum PickupKind {
  Score
  Boost
  Shield
  Heart
} derive(Eq)
