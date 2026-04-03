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
    Red => @raylib.Color::new(220, 82, 112, 255)
    Green => @raylib.Color::new(70, 206, 146, 255)
    Blue => @raylib.Color::new(86, 152, 246, 255)
    Yellow => @raylib.Color::new(241, 197, 70, 255)
    Purple => @raylib.Color::new(166, 118, 242, 255)
    Orange => @raylib.Color::new(244, 146, 77, 255)
    Empty => @raylib.Color::new(200, 200, 200, 255)
  }
}

///|
/// Returns highlight color used for gem specular dot.
pub fn gem_highlight(kind : GemKind) -> @raylib.Color {
  match kind {
    Red => @raylib.Color::new(255, 180, 196, 255)
    Green => @raylib.Color::new(184, 244, 210, 255)
    Blue => @raylib.Color::new(196, 225, 255, 255)
    Yellow => @raylib.Color::new(255, 240, 186, 255)
    Purple => @raylib.Color::new(226, 210, 255, 255)
    Orange => @raylib.Color::new(255, 216, 170, 255)
    Empty => @raylib.Color::new(230, 230, 230, 255)
  }
}

///|
/// Scene background color.
pub let bg_color : @raylib.Color = @raylib.Color::new(10, 18, 34, 255)

///|
/// Lower scene background color used for gradients.
pub let bg_color_bottom : @raylib.Color = @raylib.Color::new(26, 47, 72, 255)

///|
/// Main top HUD card background color.
pub let panel_card_color : @raylib.Color = @raylib.Color::new(18, 29, 47, 255)

///|
/// Border/accent color for HUD cards and frames.
pub let panel_card_border : @raylib.Color = @raylib.Color::new(
  105, 141, 175, 255,
)

///|
/// Warm accent color used for headings and ribbons.
pub let panel_accent_color : @raylib.Color = @raylib.Color::new(
  244, 194, 89, 255,
)

///|
/// Board panel background color.
pub let board_bg_color : @raylib.Color = @raylib.Color::new(18, 33, 51, 255)

///|
/// Empty board-slot recess color.
pub let board_slot_color : @raylib.Color = @raylib.Color::new(8, 18, 31, 255)

///|
/// Primary text color for scoreboard values.
pub let panel_text_color : @raylib.Color = @raylib.Color::new(
  241, 246, 250, 255,
)

///|
/// Secondary text color for scoreboard labels.
pub let panel_label_color : @raylib.Color = @raylib.Color::new(
  150, 184, 208, 255,
)

///|
/// Outline color for selected cells.
pub let select_color : @raylib.Color = @raylib.Color::new(255, 246, 196, 224)

///|
/// Positive accent for completed states and filled progress.
pub let success_color : @raylib.Color = @raylib.Color::new(74, 206, 145, 255)

///|
/// Negative accent for low moves and fail states.
pub let danger_color : @raylib.Color = @raylib.Color::new(243, 93, 107, 255)

///|
/// Hint accent color.
pub let hint_color : @raylib.Color = @raylib.Color::new(255, 213, 112, 255)
