///|
/// Window width in pixels.
pub let screen_w : Int = 1720

///|
/// Window height in pixels.
pub let screen_h : Int = 980

///|
/// Fixed update/render target frequency.
pub let target_fps : Int = 120

///|
/// Title-screen state id.
pub let state_title : Int = 0

///|
/// Active gameplay state id.
pub let state_play : Int = 1

///|
/// Result-screen state id.
pub let state_result : Int = 2

///|
/// Obstacle kind id for rocks.
pub let obstacle_rock : Int = 0

///|
/// Obstacle kind id for floating logs.
pub let obstacle_log : Int = 1

///|
/// Obstacle kind id for mines.
pub let obstacle_mine : Int = 2

///|
/// Pickup kind id for score coins.
pub let pickup_coin : Int = 0

///|
/// Pickup kind id for fuel canisters.
pub let pickup_fuel : Int = 1

///|
/// Pickup kind id for temporary shields.
pub let pickup_shield : Int = 2

///|
/// Pickup kind id for life repair kits.
pub let pickup_repair : Int = 3

///|
/// Capacity of obstacle pool.
pub let max_obstacles : Int = 120

///|
/// Capacity of pickup pool.
pub let max_pickups : Int = 80

///|
/// Capacity of particle effect pool.
pub let max_particles : Int = 1400

///|
/// Left x coordinate of world play area.
pub let world_x0 : Int = 24

///|
/// Top y coordinate of world play area.
pub let world_y0 : Int = 20

///|
/// Width of world play area.
pub let world_w : Int = 1120

///|
/// Height of world play area.
pub let world_h : Int = 940

///|
/// Left x coordinate of right-side HUD panel.
pub let panel_x0 : Int = world_x0 + world_w + 24

///|
/// Width of right-side HUD panel.
pub let panel_w : Int = screen_w - panel_x0 - 24

///|
/// Raft collision radius.
pub let raft_r : Float = 26.0

///|
/// Run duration in seconds required for victory.
pub let run_time_goal : Float = 180.0

///|
/// Title-screen start button rectangle.
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 260, 620, 520, 118)
}

///|
/// Result-screen retry button rectangle.
pub fn retry_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 230, 652, 460, 108)
}

///|
/// Touch button rectangle for moving left.
pub fn btn_left() -> (Int, Int, Int, Int) {
  (1230, 730, 104, 96)
}

///|
/// Touch button rectangle for moving right.
pub fn btn_right() -> (Int, Int, Int, Int) {
  (1460, 730, 104, 96)
}

///|
/// Touch button rectangle for moving up.
pub fn btn_up() -> (Int, Int, Int, Int) {
  (1345, 622, 104, 96)
}

///|
/// Touch button rectangle for moving down.
pub fn btn_down() -> (Int, Int, Int, Int) {
  (1345, 838, 104, 96)
}

///|
/// Touch button rectangle for boost toggle.
pub fn btn_boost() -> (Int, Int, Int, Int) {
  (1582, 708, 110, 124)
}

///|
/// Touch button rectangle for immediate restart.
pub fn btn_restart() -> (Int, Int, Int, Int) {
  (1582, 848, 110, 92)
}

///|
/// Touch button rectangle for hint activation.
pub fn btn_hint() -> (Int, Int, Int, Int) {
  (1582, 606, 110, 92)
}
