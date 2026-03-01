///|
/// Window width in pixels for the 2048 scene.
pub let screen_w : Int = 560

///|
/// Window height in pixels for the 2048 scene.
pub let screen_h : Int = 740

///|
/// Target refresh rate used by the main loop.
pub let target_fps : Int = 60

///|
/// Number of tiles per row and column on the board.
pub let grid_size : Int = 4

///|
/// Total number of cells in the board grid.
pub let cell_count : Int = grid_size * grid_size

///|
/// Inner padding between board frame and first cell.
pub let board_padding : Int = 16

///|
/// Pixel gap between adjacent cells.
pub let cell_gap : Int = 12

///|
/// Top edge of the board area in screen coordinates.
pub let board_top : Int = 200

///|
/// Left edge of the board area in screen coordinates.
pub let board_left : Int = 16

///|
/// Board side length in pixels.
pub let board_size : Int = screen_w - board_left * 2

///|
/// Side length of a single cell in pixels after spacing is applied.
pub let cell_size : Int = (
    board_size - board_padding * 2 - cell_gap * (grid_size - 1)
  ) /
  grid_size

///|
/// Interpolation speed for tile slide animation.
pub let anim_slide_speed : Float = 12.0

///|
/// Interpolation speed for tile pop-back scaling.
pub let anim_pop_speed : Float = 6.0

///|
/// Peak scale multiplier used when a tile is created or merged.
pub let anim_pop_scale : Float = 1.15

///|
/// Background color behind all UI elements.
pub let bg_color : @raylib.Color = @raylib.Color::new(250, 248, 239, 255)

///|
/// Fill color of the board container.
pub let board_bg_color : @raylib.Color = @raylib.Color::new(187, 173, 160, 255)

///|
/// Fill color for empty board cells.
pub let cell_empty_color : @raylib.Color = @raylib.Color::new(
  205, 193, 180, 255,
)

///|
/// Main header text color used for labels and hints.
pub let header_text_color : @raylib.Color = @raylib.Color::new(
  119, 110, 101, 255,
)

///|
/// Background color of score and best-score cards.
pub let score_bg_color : @raylib.Color = @raylib.Color::new(187, 173, 160, 255)

///|
/// Label color for score card captions.
pub let score_label_color : @raylib.Color = @raylib.Color::new(
  238, 228, 218, 255,
)

///|
/// Value color for score card numbers.
pub let score_value_color : @raylib.Color = @raylib.Color::new(
  255, 255, 255, 255,
)

///|
/// Default button background color.
pub let btn_color : @raylib.Color = @raylib.Color::new(143, 122, 102, 255)

///|
/// Default button text color.
pub let btn_text_color : @raylib.Color = @raylib.Color::new(249, 246, 242, 255)
