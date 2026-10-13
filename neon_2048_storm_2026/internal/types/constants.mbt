///|
/// Width of the game window in pixels.
pub let screen_w : Int32 = 1720

///|
/// Height of the game window in pixels.
pub let screen_h : Int32 = 980

///|
/// Target frame rate used by the main loop.
pub let target_fps : Int32 = 120

///|
/// Number of rows and columns in the square board.
pub let board_n : Int32 = 5

///|
/// Total number of cells in the board.
pub let max_cells : Int32 = board_n * board_n

///|
/// Winning tile value for a completed run.
pub let target_tile : Int32 = 2048

///|
/// Sentinel value stored in a cell that contains debris.
pub let blocker_value : Int32 = -1

///|
/// Left edge of the right-side control panel.
pub let panel_x0 : Int32 = 1060

///|
/// Width of the right-side control panel.
pub let panel_w : Int32 = screen_w - panel_x0 - 24

///|
/// Returns the x coordinate of the board drawing area.
pub fn board_area_x() -> Int32 {
  60
}

///|
/// Returns the y coordinate of the board drawing area.
pub fn board_area_y() -> Int32 {
  44
}

///|
/// Returns the width of the board drawing area.
pub fn board_area_w() -> Int32 {
  panel_x0 - board_area_x() - 24
}

///|
/// Returns the height of the board drawing area.
pub fn board_area_h() -> Int32 {
  screen_h - 88
}

///|
/// Returns the start button rectangle on the title screen.
pub fn title_start_button() -> (Int32, Int32, Int32, Int32) {
  (screen_w / 2 - 260, 620, 520, 118)
}

///|
/// Returns the retry button rectangle on the result screen.
pub fn retry_button() -> (Int32, Int32, Int32, Int32) {
  (screen_w / 2 - 230, 658, 460, 108)
}

///|
/// Returns the on-screen touch rectangle for moving the cursor left.
pub fn btn_left() -> (Int32, Int32, Int32, Int32) {
  (1100, 704, 110, 96)
}

///|
/// Returns the on-screen touch rectangle for moving the cursor right.
pub fn btn_right() -> (Int32, Int32, Int32, Int32) {
  (1348, 704, 110, 96)
}

///|
/// Returns the on-screen touch rectangle for moving the cursor up.
pub fn btn_up() -> (Int32, Int32, Int32, Int32) {
  (1224, 590, 110, 96)
}

///|
/// Returns the on-screen touch rectangle for moving the cursor down.
pub fn btn_down() -> (Int32, Int32, Int32, Int32) {
  (1224, 818, 110, 96)
}

///|
/// Returns the on-screen touch rectangle for the zap action.
pub fn btn_zap() -> (Int32, Int32, Int32, Int32) {
  (1476, 684, 188, 110)
}

///|
/// Returns the on-screen touch rectangle for undo.
pub fn btn_undo() -> (Int32, Int32, Int32, Int32) {
  (1476, 808, 188, 92)
}

///|
/// Returns the on-screen touch rectangle for restarting the run.
pub fn btn_restart() -> (Int32, Int32, Int32, Int32) {
  (1476, 590, 188, 82)
}
