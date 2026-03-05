///|
/// Number of playfield columns.
pub let board_cols : Int = 10

///|
/// Number of playfield rows.
pub let board_rows : Int = 20

///|
/// Pixel size of one board block.
pub let board_cell : Int = 30

///|
/// Left edge of the playfield in screen coordinates.
pub let board_x : Int = 42

///|
/// Top edge of the playfield in screen coordinates.
pub let board_y : Int = 24

///|
/// Left edge for next/hold and score panel.
pub let side_panel_x : Int = board_x + board_cols * board_cell + 24

///|
/// Window width in pixels.
pub let screen_width : Int = 560

///|
/// Window height in pixels.
pub let screen_height : Int = 700

///|
/// Number of tetromino kinds in a bag shuffle.
pub let bag_size : Int = 7

///|
/// Base points for clearing one line.
pub let score_single : Int = 100

///|
/// Base points for clearing two lines.
pub let score_double : Int = 300

///|
/// Base points for clearing three lines.
pub let score_triple : Int = 500

///|
/// Base points for clearing four lines at once.
pub let score_tetris : Int = 800
