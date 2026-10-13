///|
/// Window width in pixels.
pub let screen_w : Int32 = 1720

///|
/// Window height in pixels.
pub let screen_h : Int32 = 980

///|
/// Fixed update/render target frequency.
pub let target_fps : Int32 = 120

///|
/// Capacity of obstacle pool.
pub let max_obstacles : Int32 = 120

///|
/// Capacity of pickup pool.
pub let max_pickups : Int32 = 80

///|
/// Capacity of particle effect pool.
pub let max_particles : Int32 = 1400

///|
/// Left x coordinate of world play area.
pub let world_x0 : Int32 = 24

///|
/// Top y coordinate of world play area.
pub let world_y0 : Int32 = 20

///|
/// Width of world play area.
pub let world_w : Int32 = 1120

///|
/// Height of world play area.
pub let world_h : Int32 = 940

///|
/// Left x coordinate of right-side HUD panel.
pub let panel_x0 : Int32 = world_x0 + world_w + 24

///|
/// Width of right-side HUD panel.
pub let panel_w : Int32 = screen_w - panel_x0 - 24

///|
/// Raft collision radius.
pub let raft_r : Float = 26.0

///|
/// Run duration in seconds required for victory.
pub let run_time_goal : Float = 180.0

///|
/// Title-screen start button rectangle.
pub fn start_button_rect() -> (Int32, Int32, Int32, Int32) {
  (screen_w / 2 - 260, 620, 520, 118)
}

///|
/// Result-screen retry button rectangle.
pub fn retry_button_rect() -> (Int32, Int32, Int32, Int32) {
  (screen_w / 2 - 230, 652, 460, 108)
}

///|
/// Touch button rectangle for moving left.
pub fn btn_left() -> (Int32, Int32, Int32, Int32) {
  (1230, 730, 104, 96)
}

///|
/// Touch button rectangle for moving right.
pub fn btn_right() -> (Int32, Int32, Int32, Int32) {
  (1460, 730, 104, 96)
}

///|
/// Touch button rectangle for moving up.
pub fn btn_up() -> (Int32, Int32, Int32, Int32) {
  (1345, 622, 104, 96)
}

///|
/// Touch button rectangle for moving down.
pub fn btn_down() -> (Int32, Int32, Int32, Int32) {
  (1345, 838, 104, 96)
}

///|
/// Touch button rectangle for boost toggle.
pub fn btn_boost() -> (Int32, Int32, Int32, Int32) {
  (1582, 708, 110, 124)
}

///|
/// Touch button rectangle for immediate restart.
pub fn btn_restart() -> (Int32, Int32, Int32, Int32) {
  (1582, 848, 110, 92)
}

///|
/// Touch button rectangle for hint activation.
pub fn btn_hint() -> (Int32, Int32, Int32, Int32) {
  (1582, 606, 110, 92)
}

///|
/// Kind of obstacle entity in the river lane.
pub(all) enum ObstacleKind {
  Rock
  Log
  Mine
} derive(Eq)

///|
pub extend ObstacleKind with Eq::{not_equal, equal}

///|
/// Kind of collectible pickup entity.
pub(all) enum PickupKind {
  Coin
  Fuel
  Shield
  Repair
} derive(Eq)

///|
pub extend PickupKind with Eq::{not_equal, equal}

///|
/// Kind of visual particle effect.
pub(all) enum ParticleKind {
  Water
  Hit
  Bubble
} derive(Eq)

///|
pub extend ParticleKind with Eq::{not_equal, equal}

///|
/// High-level game screen state.
pub(all) enum GameState {
  Title
  Play
  Result
} derive(Eq)

///|
pub extend GameState with Eq::{not_equal, equal}
