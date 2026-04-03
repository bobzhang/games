///|
pub let screen_width : Int = 1280

///|
pub let screen_height : Int = 720

///|
pub let target_fps : Int = 60

///|
pub let grid_cols : Int = 8

///|
pub let grid_rows : Int = 12

///|
pub let cell_size : Int = 36

///|
pub let grid_offset_x : Int = 80

///|
pub let grid_offset_y : Int = 100

///|
pub let target_offset_x : Int = 720

///|
pub let target_offset_y : Int = 100

///|
pub let target_cell_size : Int = 24

///|
pub let heddle_panel_x : Int = 80

///|
pub let heddle_panel_y : Int = 560

///|
pub let total_levels : Int = 20

///|
pub let tier1_count : Int = 7

///|
pub let tier2_count : Int = 7

///|
pub let tier3_count : Int = 6

// Color palette - warm textile tones

///|
pub let color_bg : @raylib.Color = @raylib.Color::new(248, 244, 236, 255)

///|
pub let color_loom_frame : @raylib.Color = @raylib.Color::new(120, 80, 50, 255)

///|
pub let color_grid_bg : @raylib.Color = @raylib.Color::new(255, 252, 245, 255)

///|
pub let color_grid_line : @raylib.Color = @raylib.Color::new(200, 190, 175, 255)

///|
pub let color_text : @raylib.Color = @raylib.Color::new(60, 50, 40, 255)

///|
pub let color_text_light : @raylib.Color = @raylib.Color::new(
  140, 130, 115, 255,
)

///|
pub let color_title : @raylib.Color = @raylib.Color::new(120, 60, 30, 255)

///|
pub let color_button : @raylib.Color = @raylib.Color::new(160, 100, 60, 255)

///|
pub let color_button_hover : @raylib.Color = @raylib.Color::new(
  190, 120, 70, 255,
)

///|
pub let color_selected_row : @raylib.Color = @raylib.Color::new(
  100, 180, 255, 80,
)

///|
pub let color_correct : @raylib.Color = @raylib.Color::new(80, 200, 120, 255)

///|
pub let color_incorrect : @raylib.Color = @raylib.Color::new(220, 80, 80, 255)

///|
pub let color_star_gold : @raylib.Color = @raylib.Color::new(255, 200, 50, 255)

///|
pub let color_star_empty : @raylib.Color = @raylib.Color::new(
  200, 190, 175, 255,
)

///|
pub let color_heddle_up : @raylib.Color = @raylib.Color::new(255, 220, 120, 255)

///|
pub let color_heddle_down : @raylib.Color = @raylib.Color::new(
  180, 170, 155, 255,
)

///|
pub let color_panel_bg : @raylib.Color = @raylib.Color::new(230, 220, 205, 255)

// Thread colors

///|
pub let thread_colors : Array[@raylib.Color] = [
  @raylib.Color::new(180, 50, 50, 255),
  @raylib.Color::new(50, 80, 160, 255),
  @raylib.Color::new(50, 140, 70, 255),
  @raylib.Color::new(180, 140, 50, 255),
]

///|
pub let thread_color_names : Array[String] = [
  "Crimson", "Indigo", "Forest", "Amber",
]
