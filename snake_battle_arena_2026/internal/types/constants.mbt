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
/// Grid width in cells.
pub let grid_w : Int32 = 34

///|
/// Grid height in cells.
pub let grid_h : Int32 = 20

///|
/// Total number of cells in the arena grid.
pub let max_cells : Int32 = grid_w * grid_h

///|
/// Maximum segment capacity for a snake body.
pub let max_segments : Int32 = max_cells

///|
/// Number of AI rival snakes.
pub let max_rivals : Int32 = 2

///|
/// Food type for pickups in the arena.
pub(all) enum FoodKind {
  Normal
  Gold
} derive(Eq)

///|
pub extend FoodKind with Eq::{not_equal, equal}

///|
/// Starting life count per run.
pub let lives_default : Int32 = 3

///|
/// Match timer limit in seconds.
pub let match_time_limit : Float = 180.0

///|
/// Left x coordinate of right-side panel.
pub let panel_x0 : Int32 = 1146

///|
/// Width of right-side panel.
pub let panel_w : Int32 = screen_w - panel_x0 - 24

///|
/// Left x coordinate of board drawing area.
pub let board_area_x : Int32 = 40

///|
/// Top y coordinate of board drawing area.
pub let board_area_y : Int32 = 30

///|
/// Width of board drawing area.
pub let board_area_w : Int32 = panel_x0 - board_area_x - 24

///|
/// Height of board drawing area.
pub let board_area_h : Int32 = screen_h - 60

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
/// Touch button rectangle for left movement.
pub fn btn_left() -> (Int32, Int32, Int32, Int32) {
  (1180, 710, 104, 94)
}

///|
/// Touch button rectangle for right movement.
pub fn btn_right() -> (Int32, Int32, Int32, Int32) {
  (1408, 710, 104, 94)
}

///|
/// Touch button rectangle for upward movement.
pub fn btn_up() -> (Int32, Int32, Int32, Int32) {
  (1294, 604, 104, 94)
}

///|
/// Touch button rectangle for downward movement.
pub fn btn_down() -> (Int32, Int32, Int32, Int32) {
  (1294, 816, 104, 94)
}

///|
/// Touch button rectangle for boost activation.
pub fn btn_boost() -> (Int32, Int32, Int32, Int32) {
  (1530, 690, 154, 112)
}

///|
/// Touch button rectangle for restart action.
pub fn btn_restart() -> (Int32, Int32, Int32, Int32) {
  (1530, 816, 154, 92)
}

///|
/// Touch button rectangle for hint action.
pub fn btn_hint() -> (Int32, Int32, Int32, Int32) {
  (1530, 590, 154, 82)
}

///|
/// Visual spark particle category.
pub(all) enum SparkKind {
  Splash
  Eat
  Death
} derive(Eq)

///|
pub extend SparkKind with Eq::{not_equal, equal}

///|
/// Cardinal movement direction for snakes.
pub(all) enum Dir {
  Left
  Right
  Up
  Down
} derive(Eq)

///|
pub extend Dir with Eq::{not_equal, equal}

///|
/// Top-level game screen state.
pub(all) enum GameState {
  Title
  Play
  Result
} derive(Eq)

///|
pub extend GameState with Eq::{not_equal, equal}
