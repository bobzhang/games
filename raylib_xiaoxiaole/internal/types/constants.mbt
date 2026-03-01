///|
/// Window width in pixels.
pub let screen_w : Int = 680

///|
/// Window height in pixels.
pub let screen_h : Int = 800

///|
/// Target frame rate for gameplay updates.
pub let target_fps : Int = 60

///|
/// Number of columns in the gem board.
pub let grid_cols : Int = 8

///|
/// Number of rows in the gem board.
pub let grid_rows : Int = 8

///|
/// Total number of board slots.
pub let cell_count : Int = grid_cols * grid_rows

///|
/// Number of non-empty gem colors used for generation.
pub let num_colors : Int = 6

///|
/// Pixel size of one gem cell.
pub let cell_px : Int = 64

///|
/// Pixel spacing between adjacent cells.
pub let cell_gap : Int = 4

///|
/// Left edge of the board in screen coordinates.
pub let board_left : Int = 36

///|
/// Top edge of the board in screen coordinates.
pub let board_top : Int = 160

///|
/// Speed factor for swap interpolation.
pub let swap_speed : Float = 10.0

///|
/// Speed factor for gravity/fall interpolation.
pub let fall_speed : Float = 12.0

///|
/// Duration in seconds for gem removal flash.
pub let flash_duration : Float = 0.25

///|
/// Starting move budget for level 1.
pub let base_moves : Int = 30

///|
/// Starting target score for level 1.
pub let base_target : Int = 1000

///|
/// Returns base fill color for a gem kind.
pub fn gem_color(kind : GemKind) -> @raylib.Color {
  match kind {
    Red => @raylib.Color::new(231, 76, 60, 255)
    Green => @raylib.Color::new(46, 204, 113, 255)
    Blue => @raylib.Color::new(52, 152, 219, 255)
    Yellow => @raylib.Color::new(241, 196, 15, 255)
    Purple => @raylib.Color::new(155, 89, 182, 255)
    Orange => @raylib.Color::new(230, 126, 34, 255)
    Empty => @raylib.Color::new(200, 200, 200, 255)
  }
}

///|
/// Returns highlight color used for gem specular dot.
pub fn gem_highlight(kind : GemKind) -> @raylib.Color {
  match kind {
    Red => @raylib.Color::new(255, 120, 100, 255)
    Green => @raylib.Color::new(100, 230, 150, 255)
    Blue => @raylib.Color::new(100, 180, 240, 255)
    Yellow => @raylib.Color::new(255, 220, 80, 255)
    Purple => @raylib.Color::new(190, 130, 210, 255)
    Orange => @raylib.Color::new(250, 160, 80, 255)
    Empty => @raylib.Color::new(230, 230, 230, 255)
  }
}

///|
/// Scene background color.
pub let bg_color : @raylib.Color = @raylib.Color::new(44, 62, 80, 255)

///|
/// Board panel background color.
pub let board_bg_color : @raylib.Color = @raylib.Color::new(34, 49, 63, 255)

///|
/// Primary text color for scoreboard values.
pub let panel_text_color : @raylib.Color = @raylib.Color::new(
  236, 240, 241, 255,
)

///|
/// Secondary text color for scoreboard labels.
pub let panel_label_color : @raylib.Color = @raylib.Color::new(
  149, 165, 166, 255,
)

///|
/// Outline color for selected cells.
pub let select_color : @raylib.Color = @raylib.Color::new(255, 255, 255, 200)
