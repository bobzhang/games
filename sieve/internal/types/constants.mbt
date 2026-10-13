///|
pub let screen_width : Int32 = 1280

///|
pub let screen_height : Int32 = 720

///|
pub let target_fps : Int32 = 60

///|
pub let grid_size : Int32 = 5

///|
pub let grid_total_cells : Int32 = 25

///|
pub let cell_size : Int32 = 80

///|
pub let grid_offset_x : Int32 = 80

///|
pub let grid_offset_y : Int32 = 100

///|
pub let palette_x : Int32 = 80

///|
pub let palette_y : Int32 = 550

///|
pub let palette_cell : Int32 = 55

///|
pub let constraint_panel_x : Int32 = 560

///|
pub let constraint_panel_y : Int32 = 100

///|
pub let total_levels : Int32 = 25

///|
pub let tier1_count : Int32 = 8

///|
pub let tier2_count : Int32 = 9

///|
pub let tier3_count : Int32 = 8

// Colors

///|
pub let color_bg : @raylib.Color = @raylib.Color::new(20, 22, 36, 255)

///|
pub let color_grid_bg : @raylib.Color = @raylib.Color::new(30, 34, 52, 255)

///|
pub let color_cell_empty : @raylib.Color = @raylib.Color::new(42, 46, 68, 255)

///|
pub let color_cell_locked : @raylib.Color = @raylib.Color::new(55, 60, 85, 255)

///|
pub let color_cell_selected : @raylib.Color = @raylib.Color::new(
  80, 120, 200, 255,
)

///|
pub let color_cell_error : @raylib.Color = @raylib.Color::new(200, 60, 60, 180)

///|
pub let color_cell_correct : @raylib.Color = @raylib.Color::new(
  60, 180, 80, 180,
)

///|
pub let color_number_locked : @raylib.Color = @raylib.Color::new(
  220, 225, 240, 255,
)

///|
pub let color_number_editable : @raylib.Color = @raylib.Color::new(
  120, 200, 255, 255,
)

///|
pub let color_number_prime : @raylib.Color = @raylib.Color::new(
  255, 200, 80, 255,
)

///|
pub let color_constraint_sat : @raylib.Color = @raylib.Color::new(
  80, 220, 100, 255,
)

///|
pub let color_constraint_unsat : @raylib.Color = @raylib.Color::new(
  220, 80, 80, 255,
)

///|
pub let color_constraint_text : @raylib.Color = @raylib.Color::new(
  180, 185, 200, 255,
)

///|
pub let color_title : @raylib.Color = @raylib.Color::new(100, 180, 255, 255)

///|
pub let color_subtitle : @raylib.Color = @raylib.Color::new(160, 170, 200, 255)

///|
pub let color_button : @raylib.Color = @raylib.Color::new(60, 70, 110, 255)

///|
pub let color_button_hover : @raylib.Color = @raylib.Color::new(
  80, 95, 140, 255,
)

///|
pub let color_button_text : @raylib.Color = @raylib.Color::new(
  220, 225, 240, 255,
)

///|
pub let color_star_filled : @raylib.Color = @raylib.Color::new(255, 215, 0, 255)

///|
pub let color_star_empty : @raylib.Color = @raylib.Color::new(80, 80, 100, 255)

///|
pub let color_tier_primes : @raylib.Color = @raylib.Color::new(
  100, 200, 100, 255,
)

///|
pub let color_tier_factors : @raylib.Color = @raylib.Color::new(
  200, 160, 60, 255,
)

///|
pub let color_tier_theorem : @raylib.Color = @raylib.Color::new(
  200, 80, 80, 255,
)

///|
pub let color_grid_line : @raylib.Color = @raylib.Color::new(70, 75, 100, 255)

///|
pub let color_palette_bg : @raylib.Color = @raylib.Color::new(35, 40, 58, 255)

///|
pub let color_timer : @raylib.Color = @raylib.Color::new(200, 210, 230, 255)

// Constraint visualization colors

///|
pub let color_constraint_icon_sat : @raylib.Color = @raylib.Color::new(
  60, 220, 90, 255,
)

///|
pub let color_constraint_icon_unsat : @raylib.Color = @raylib.Color::new(
  220, 70, 70, 255,
)

///|
pub let color_constraint_icon_pending : @raylib.Color = @raylib.Color::new(
  130, 140, 170, 255,
)

///|
pub let color_constraint_bar_bg : @raylib.Color = @raylib.Color::new(
  20, 24, 38, 255,
)

// Candidate highlighting colors

///|
pub let color_candidate_valid : @raylib.Color = @raylib.Color::new(
  60, 180, 100, 180,
)

///|
pub let color_candidate_invalid : @raylib.Color = @raylib.Color::new(
  180, 50, 50, 100,
)

///|
pub let color_candidate_text : @raylib.Color = @raylib.Color::new(
  140, 180, 220, 200,
)

///|
pub let color_cell_highlight : @raylib.Color = @raylib.Color::new(
  80, 120, 200, 50,
)
