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
/// Number of columns in the minefield.
pub let board_w : Int = 24

///|
/// Number of rows in the minefield.
pub let board_h : Int = 14

///|
/// Total number of cells in the minefield.
pub let max_cells : Int = board_w * board_h

///|
/// Default mine count for a fresh game.
pub let mine_count_default : Int = 58

///|
/// Default number of player lives.
pub let lives_default : Int = 3

///|
/// Default number of hint actions available.
pub let hints_default : Int = 3

///|
/// Returns the left x coordinate of the side panel.
pub fn panel_x() -> Int {
  1168
}

///|
/// Returns the x coordinate of the board drawing area.
pub fn board_area_x() -> Int {
  44
}

///|
/// Returns the y coordinate of the board drawing area.
pub fn board_area_y() -> Int {
  32
}

///|
/// Returns the width of the board drawing area.
pub fn board_area_w() -> Int {
  panel_x() - board_area_x() - 24
}

///|
/// Returns the height of the board drawing area.
pub fn board_area_h() -> Int {
  screen_h - 64
}

///|
/// Returns the title-screen start button rectangle.
pub fn title_start_button() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 250, 600, 500, 120)
}

///|
/// Returns the result-screen retry button rectangle.
pub fn result_retry_button() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 230, 650, 460, 108)
}

///|
/// Returns the touch rectangle for mode switching.
pub fn touch_mode_button() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 252, 190, 90)
}

///|
/// Returns the touch rectangle for consuming a hint.
pub fn touch_hint_button() -> (Int, Int, Int, Int) {
  (panel_x() + 228, screen_h - 252, 170, 90)
}

///|
/// Returns the touch rectangle for restarting the current run.
pub fn touch_reset_button() -> (Int, Int, Int, Int) {
  (panel_x() + 410, screen_h - 252, 190, 90)
}

///|
/// Returns the touch rectangle for revealing the selected cell.
pub fn touch_reveal_button() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 148, 576, 96)
}
