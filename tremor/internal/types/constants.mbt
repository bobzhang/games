///|
pub let screen_width : Int = 1280

///|
pub let screen_height : Int = 720

///|
pub let target_fps : Int = 60

///|
pub let cell_size : Int = 52

///|
pub let grid_cols : Int = 12

///|
pub let grid_rows : Int = 10

///|
pub let grid_offset_x : Int = 40

///|
pub let grid_offset_y : Int = 80

///|
pub let ui_panel_x : Int = 680

///|
pub let total_levels : Int = 25

///|
pub let tier1_count : Int = 8

///|
pub let tier2_count : Int = 9

///|
pub let tier3_count : Int = 8

///|
pub let guess_tolerance : Float = 2.0

///|
pub let broad_range : Float = 8.0

///|
pub let broad_uncertainty : Float = 2.0

///|
pub let broad_cost : Int = 1

///|
pub let precise_range : Float = 5.0

///|
pub let precise_uncertainty : Float = 1.0

///|
pub let precise_cost : Int = 2

///|
pub let directional_range : Float = 6.0

///|
pub let directional_uncertainty : Float = 1.0

///|
pub let directional_cost : Int = 3

///|
pub let directional_angle : Float = 90.0

///|
pub let noisy_extra_uncertainty : Float = 1.0

// Colors - dark seismic theme

///|
pub let color_bg : @raylib.Color = @raylib.Color::new(12, 15, 30, 255)

///|
pub let color_grid_bg : @raylib.Color = @raylib.Color::new(20, 25, 45, 255)

///|
pub let color_grid_line : @raylib.Color = @raylib.Color::new(35, 42, 65, 255)

///|
pub let color_blocked : @raylib.Color = @raylib.Color::new(60, 65, 75, 255)

///|
pub let color_town : @raylib.Color = @raylib.Color::new(255, 210, 60, 255)

///|
pub let color_noisy : @raylib.Color = @raylib.Color::new(80, 50, 70, 255)

///|
pub let color_sensor_broad : @raylib.Color = @raylib.Color::new(
  40, 200, 120, 255,
)

///|
pub let color_sensor_precise : @raylib.Color = @raylib.Color::new(
  60, 150, 255, 255,
)

///|
pub let color_sensor_dir : @raylib.Color = @raylib.Color::new(
  200, 100, 255, 255,
)

///|
pub let color_ring_broad : @raylib.Color = @raylib.Color::new(40, 200, 120, 80)

///|
pub let color_ring_precise : @raylib.Color = @raylib.Color::new(
  60, 150, 255, 80,
)

///|
pub let color_ring_dir : @raylib.Color = @raylib.Color::new(200, 100, 255, 80)

///|
pub let color_epicenter : @raylib.Color = @raylib.Color::new(255, 50, 50, 255)

///|
pub let color_guess : @raylib.Color = @raylib.Color::new(255, 255, 100, 255)

///|
pub let color_overlap : @raylib.Color = @raylib.Color::new(255, 100, 50, 50)

///|
pub let color_hud_bg : @raylib.Color = @raylib.Color::new(15, 18, 35, 230)

///|
pub let color_hud_text : @raylib.Color = @raylib.Color::new(200, 210, 230, 255)

///|
pub let color_title_accent : @raylib.Color = @raylib.Color::new(
  255, 80, 60, 255,
)

///|
pub let color_star_filled : @raylib.Color = @raylib.Color::new(
  255, 210, 60, 255,
)

///|
pub let color_star_empty : @raylib.Color = @raylib.Color::new(60, 65, 80, 255)

///|
pub let color_selected : @raylib.Color = @raylib.Color::new(255, 255, 255, 255)

///|
pub let color_button : @raylib.Color = @raylib.Color::new(40, 60, 100, 255)

///|
pub let color_button_hover : @raylib.Color = @raylib.Color::new(
  60, 90, 140, 255,
)

///|
pub let pi : Float = 3.14159265

///|
pub let two_pi : Float = 6.28318530
