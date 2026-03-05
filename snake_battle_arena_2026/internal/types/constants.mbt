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
/// Grid width in cells.
pub let grid_w : Int = 34

///|
/// Grid height in cells.
pub let grid_h : Int = 20

///|
/// Total number of cells in the arena grid.
pub let max_cells : Int = grid_w * grid_h

///|
/// Maximum segment capacity for a snake body.
pub let max_segments : Int = max_cells

///|
/// Number of AI rival snakes.
pub let max_rivals : Int = 2

///|
/// Food type for pickups in the arena.
pub(all) enum FoodKind {
  Normal
  Gold
} derive(Eq)

///|
/// Starting life count per run.
pub let lives_default : Int = 3

///|
/// Match timer limit in seconds.
pub let match_time_limit : Float = 180.0

///|
/// Left x coordinate of right-side panel.
pub let panel_x0 : Int = 1146

///|
/// Width of right-side panel.
pub let panel_w : Int = screen_w - panel_x0 - 24

///|
/// Left x coordinate of board drawing area.
pub let board_area_x : Int = 40

///|
/// Top y coordinate of board drawing area.
pub let board_area_y : Int = 30

///|
/// Width of board drawing area.
pub let board_area_w : Int = panel_x0 - board_area_x - 24

///|
/// Height of board drawing area.
pub let board_area_h : Int = screen_h - 60

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
/// Touch button rectangle for left movement.
pub fn btn_left() -> (Int, Int, Int, Int) {
  (1180, 710, 104, 94)
}

///|
/// Touch button rectangle for right movement.
pub fn btn_right() -> (Int, Int, Int, Int) {
  (1408, 710, 104, 94)
}

///|
/// Touch button rectangle for upward movement.
pub fn btn_up() -> (Int, Int, Int, Int) {
  (1294, 604, 104, 94)
}

///|
/// Touch button rectangle for downward movement.
pub fn btn_down() -> (Int, Int, Int, Int) {
  (1294, 816, 104, 94)
}

///|
/// Touch button rectangle for boost activation.
pub fn btn_boost() -> (Int, Int, Int, Int) {
  (1530, 690, 154, 112)
}

///|
/// Touch button rectangle for restart action.
pub fn btn_restart() -> (Int, Int, Int, Int) {
  (1530, 816, 154, 92)
}

///|
/// Touch button rectangle for hint action.
pub fn btn_hint() -> (Int, Int, Int, Int) {
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
/// Cardinal movement direction for snakes.
pub(all) enum Dir {
  Left
  Right
  Up
  Down
} derive(Eq)

///|
/// Top-level game screen state.
pub(all) enum GameState {
  Title
  Play
  Result
} derive(Eq)
