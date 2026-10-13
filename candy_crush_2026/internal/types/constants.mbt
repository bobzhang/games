///|
/// Width of the game window in pixels.
pub let screen_w : Int32 = 1420

///|
/// Height of the game window in pixels.
pub let screen_h : Int32 = 900

///|
/// Target frame rate used by the main loop.
pub let target_fps : Int32 = 120

///|
/// Number of columns in the candy board.
pub let board_cols : Int32 = 8

///|
/// Number of rows in the candy board.
pub let board_rows : Int32 = 8

///|
/// Total number of cells in the board.
pub let board_cells : Int32 = board_cols * board_rows

///|
/// Number of regular candy kinds used for random spawning.
pub let candy_kinds : Int32 = 6

///|
/// Pixel size of one board cell.
pub let cell_px : Int32 = 84

///|
/// Padding used around board visuals.
pub let board_pad : Int32 = 18

///|
/// Width of the right-side UI panel.
pub let ui_panel_w : Int32 = 360

///|
/// Base move budget for level 1.
pub let moves_base : Int32 = 28

///|
/// Extra moves granted per level.
pub let moves_level_bonus : Int32 = 2

///|
/// Base jelly target for level 1.
pub let base_jelly : Int32 = 16

///|
/// Extra jelly target added per level.
pub let jelly_level_bonus : Int32 = 3

///|
/// Maximum duration of a shown hint in seconds.
pub let hint_ttl_max : Float = 2.2

///|
/// Maximum duration of HUD messages in seconds.
pub let message_ttl_max : Float = 2.4

///|
/// Minimum delay between touch actions in seconds.
pub let touch_action_cooldown : Float = 0.1

///|
/// Kind of special candy effect applied to a board cell.
pub(all) enum Special {
  None
  Row
  Col
  Bomb
} derive(Eq)

///|
pub extend Special with Eq::{not_equal, equal}
