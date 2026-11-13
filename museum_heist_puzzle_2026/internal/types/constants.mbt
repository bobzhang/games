///|
/// Width of the game window in pixels.
pub let screen_w : Int32 = 1280

///|
/// Height of the game window in pixels.
pub let screen_h : Int32 = 800

///|
/// Target frame rate for simulation and rendering.
pub let target_fps : Int32 = 60

///|
/// Number of columns in the museum board.
pub let board_cols : Int32 = 20

///|
/// Number of rows in the museum board.
pub let board_rows : Int32 = 14

///|
/// Total number of board cells.
pub let board_cells : Int32 = board_cols * board_rows

///|
/// Pixel size of one map tile.
pub let tile_size : Int32 = 44

///|
/// Left edge of the board in screen pixels.
pub let board_origin_x : Int32 = 36

///|
/// Top edge of the board in screen pixels.
pub let board_origin_y : Int32 = 96

///|
/// Left edge of the side panel.
pub let panel_x : Int32 = board_origin_x + board_cols * tile_size + 22

///|
/// Top edge of the side panel.
pub let panel_y : Int32 = 22

///|
/// Width of the side panel.
pub let panel_w : Int32 = screen_w - panel_x - 22

///|
/// Height of the side panel.
pub let panel_h : Int32 = screen_h - 44

///|
/// Minimum interval between player grid steps.
pub let player_step_interval : Float = 0.14

///|
/// Minimum interval between guard path steps.
pub let guard_step_interval : Float = 0.33

///|
/// Delay before menu actions become clickable after state changes.
pub let menu_action_delay : Float = 0.16

///|
/// Duration of the alarm flash effect after detection.
pub let alarm_flash_time : Float = 0.45
