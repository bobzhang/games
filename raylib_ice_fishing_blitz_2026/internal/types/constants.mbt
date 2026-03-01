///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1720

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 980

///|
/// Target frame rate used by the game loop.
pub let target_fps : Int = 120

///|
/// Fish kind id for trout.
pub let fish_trout : Int = 0

///|
/// Fish kind id for salmon.
pub let fish_salmon : Int = 1

///|
/// Fish kind id for rare gold fish.
pub let fish_gold : Int = 2

///|
/// Hazard kind id for jellyfish.
pub let hazard_jelly : Int = 0

///|
/// Hazard kind id for electric eel.
pub let hazard_eel : Int = 1

///|
/// Hazard kind id for floating ice chunk.
pub let hazard_ice : Int = 2

///|
/// Maximum fish entities allocated in the fish pool.
pub let max_fish : Int = 180

///|
/// Maximum hazard entities allocated in the hazard pool.
pub let max_hazards : Int = 120

///|
/// Maximum pickup entities allocated in the pickup pool.
pub let max_pickups : Int = 80

///|
/// Maximum particles allocated for effects.
pub let max_particles : Int = 1500

///|
/// Left edge of the world play area in pixels.
pub let world_x0 : Int = 24

///|
/// Top edge of the world play area in pixels.
pub let world_y0 : Int = 20

///|
/// Width of the world play area in pixels.
pub let world_w : Int = 1120

///|
/// Height of the world play area in pixels.
pub let world_h : Int = 940

///|
/// Left edge of the side panel in pixels.
pub let panel_x0 : Int = world_x0 + world_w + 24

///|
/// Width of the side panel in pixels.
pub let panel_w : Int = screen_w - panel_x0 - 24

///|
/// Top Y bound of the underwater region.
pub let water_top : Int = world_y0 + 170

///|
/// Bottom Y bound of the underwater region.
pub let water_bottom : Int = world_y0 + world_h - 14

///|
/// X coordinate of the fishing hole center.
pub let hole_x : Int = world_x0 + world_w / 2

///|
/// Y coordinate of the fishing hole center.
pub let hole_y : Int = water_top - 24

///|
/// Radius of the hook collision area.
pub let hook_r : Float = 13.0

///|
/// Round duration target in seconds.
pub let run_time_goal : Float = 200.0

///|
/// Score target used for victory condition.
pub let score_goal : Int = 1600

///|
/// Maximum allowed fishing line length.
pub let max_line_len : Float = 760.0

///|
/// Minimum allowed fishing line length.
pub let min_line_len : Float = 60.0

///|
/// Returns catch-zone rectangle X coordinate.
pub fn catch_zone_x() -> Int {
  hole_x - 120
}

///|
/// Returns catch-zone rectangle Y coordinate.
pub fn catch_zone_y() -> Int {
  water_top - 54
}

///|
/// Returns catch-zone rectangle width.
pub fn catch_zone_w() -> Int {
  240
}

///|
/// Returns catch-zone rectangle height.
pub fn catch_zone_h() -> Int {
  76
}

///|
/// Returns title overlay start button rectangle.
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 280, 620, 560, 122)
}

///|
/// Returns result overlay retry button rectangle.
pub fn retry_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 240, 648, 480, 110)
}

///|
/// Returns touch rectangle for moving hook left.
pub fn btn_left() -> (Int, Int, Int, Int) {
  (1230, 730, 104, 96)
}

///|
/// Returns touch rectangle for moving hook right.
pub fn btn_right() -> (Int, Int, Int, Int) {
  (1460, 730, 104, 96)
}

///|
/// Returns touch rectangle for moving hook upward.
pub fn btn_up() -> (Int, Int, Int, Int) {
  (1345, 624, 104, 96)
}

///|
/// Returns touch rectangle for moving hook downward.
pub fn btn_down() -> (Int, Int, Int, Int) {
  (1345, 836, 104, 96)
}

///|
/// Returns touch rectangle for hook/grab action.
pub fn btn_hook() -> (Int, Int, Int, Int) {
  (1582, 704, 110, 124)
}

///|
/// Returns touch rectangle for temporary speed boost.
pub fn btn_boost() -> (Int, Int, Int, Int) {
  (1582, 842, 110, 98)
}

///|
/// Returns touch rectangle for hint button.
pub fn btn_hint() -> (Int, Int, Int, Int) {
  (1582, 606, 110, 90)
}

///|
/// Returns touch rectangle for restart button.
pub fn btn_restart() -> (Int, Int, Int, Int) {
  (1462, 606, 110, 90)
}

///|
/// Returns touch rectangle for line repair action.
pub fn btn_repair() -> (Int, Int, Int, Int) {
  (1462, 704, 110, 124)
}
