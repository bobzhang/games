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
/// Maximum supported board width in cells.
pub let max_cols : Int32 = 18

///|
/// Maximum supported board height in cells.
pub let max_rows : Int32 = 12

///|
/// Maximum number of board cells for fixed-size buffers.
pub let max_cells : Int32 = max_cols * max_rows

///|
/// Maximum number of undo records kept in memory.
pub let max_undos : Int32 = 256
