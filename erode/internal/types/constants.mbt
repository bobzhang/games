///|
pub let screen_width : Int = 1280

///|
pub let screen_height : Int = 720

///|
pub let target_fps : Int = 60

///|
pub let cell_size : Int = 64

///|
pub let grid_size : Int = 8

///|
pub let total_levels : Int = 20

///|
pub let tier1_count : Int = 7

///|
pub let tier2_count : Int = 7

///|
pub let tier3_count : Int = 6

///|
pub let anim_duration : Float = 0.3

// Grid drawing offsets - current grid on left, target on right

///|
pub let grid_left_x : Int = 80

///|
pub let grid_top_y : Int = 100

///|
pub let grid_right_x : Int = 700

// Colors

///|
pub let color_bg : @raylib.Color = @raylib.Color::new(30, 30, 40, 255)

///|
pub let color_solid : @raylib.Color = @raylib.Color::new(160, 120, 80, 255)

///|
pub let color_empty : @raylib.Color = @raylib.Color::new(50, 50, 60, 255)

///|
pub let color_water : @raylib.Color = @raylib.Color::new(60, 140, 255, 255)

///|
pub let color_wind : @raylib.Color = @raylib.Color::new(180, 180, 190, 255)

///|
pub let color_frost : @raylib.Color = @raylib.Color::new(100, 220, 240, 255)

///|
pub let color_heat : @raylib.Color = @raylib.Color::new(240, 80, 60, 255)

///|
pub let color_target_match : @raylib.Color = @raylib.Color::new(
  80, 200, 80, 255,
)

///|
pub let color_over_eroded : @raylib.Color = @raylib.Color::new(240, 60, 60, 200)

///|
pub let color_under_eroded : @raylib.Color = @raylib.Color::new(
  240, 200, 60, 200,
)

///|
pub let color_preview : @raylib.Color = @raylib.Color::new(255, 80, 80, 140)

///|
pub let color_grid_line : @raylib.Color = @raylib.Color::new(70, 70, 80, 255)

///|
pub let color_text : @raylib.Color = @raylib.Color::new(220, 220, 230, 255)

///|
pub let color_text_dim : @raylib.Color = @raylib.Color::new(150, 150, 160, 255)

///|
pub let color_text_highlight : @raylib.Color = @raylib.Color::new(
  255, 230, 100, 255,
)

///|
pub let color_star_gold : @raylib.Color = @raylib.Color::new(255, 215, 0, 255)

///|
pub let color_star_empty : @raylib.Color = @raylib.Color::new(80, 80, 90, 255)

///|
pub let color_button : @raylib.Color = @raylib.Color::new(70, 70, 90, 255)

///|
pub let color_button_hover : @raylib.Color = @raylib.Color::new(
  90, 90, 120, 255,
)

///|
pub let color_selected : @raylib.Color = @raylib.Color::new(255, 200, 60, 255)

///|
pub let color_tier_clay : @raylib.Color = @raylib.Color::new(180, 130, 80, 255)

///|
pub let color_tier_stone : @raylib.Color = @raylib.Color::new(
  140, 140, 160, 255,
)

///|
pub let color_tier_crystal : @raylib.Color = @raylib.Color::new(
  140, 100, 220, 255,
)
