///|
/// Number of playfield columns.
pub let board_cols : Int32 = 10

///|
/// Number of playfield rows.
pub let board_rows : Int32 = 20

///|
/// Pixel size of one board block.
pub let board_cell : Int32 = 30

///|
/// Left edge of the playfield in screen coordinates.
pub let board_x : Int32 = 42

///|
/// Top edge of the playfield in screen coordinates.
pub let board_y : Int32 = 24

///|
/// Left edge for next/hold and score panel.
pub let side_panel_x : Int32 = board_x + board_cols * board_cell + 24

///|
/// Window width in pixels.
pub let screen_width : Int32 = 560

///|
/// Window height in pixels.
pub let screen_height : Int32 = 700

///|
/// Number of tetromino kinds in a bag shuffle.
pub let bag_size : Int32 = 7

///|
/// Base points for clearing one line.
pub let score_single : Int32 = 100

///|
/// Base points for clearing two lines.
pub let score_double : Int32 = 300

///|
/// Base points for clearing three lines.
pub let score_triple : Int32 = 500

///|
/// Base points for clearing four lines at once.
pub let score_tetris : Int32 = 800
