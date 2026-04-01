///|
pub let screen_width : Int = 1280

///|
pub let screen_height : Int = 720

///|
pub let target_fps : Int = 60

///|
pub let grid_cols : Int = 8

///|
pub let grid_rows : Int = 8

///|
pub let cell_size : Int = 64

///|
pub let grid_offset_x : Int = 80

///|
pub let grid_offset_y : Int = 80

///|
pub let pi : Float = 3.14159265

///|
pub let two_pi : Float = 6.2831853

///|
pub let gear_small_radius : Float = 24.0

///|
pub let gear_medium_radius : Float = 36.0

///|
pub let gear_large_radius : Float = 48.0

///|
pub let gear_small_teeth : Int = 8

///|
pub let gear_medium_teeth : Int = 12

///|
pub let gear_large_teeth : Int = 16

///|
pub let gear_small_speed_ratio : Float = 2.0

///|
pub let gear_medium_speed_ratio : Float = 1.0

///|
pub let gear_large_speed_ratio : Float = 0.5

///|
pub let base_rotation_speed : Float = 1.0

///|
pub let cam_push_distance : Float = 32.0

///|
pub let cam_radius : Float = 20.0

///|
pub let spring_force : Float = 3.0

///|
pub let spring_release_speed : Float = 4.0

///|
pub let escapement_period : Float = 1.0

///|
pub let bell_trigger_distance : Float = 16.0

///|
pub let bell_ring_duration : Float = 0.5

///|
pub let max_components : Int = 20

///|
pub let max_bells : Int = 6

///|
pub let total_levels : Int = 20

///|
pub let tier1_levels : Int = 7

///|
pub let tier2_levels : Int = 7

///|
pub let tier3_levels : Int = 6

// Colors - Clockwork aesthetic

///|
pub let color_bg : @raylib.Color = @raylib.Color::new(20, 15, 10, 255)

///|
pub let color_grid_bg : @raylib.Color = @raylib.Color::new(35, 28, 20, 255)

///|
pub let color_grid_line : @raylib.Color = @raylib.Color::new(60, 50, 35, 255)

///|
pub let color_peg : @raylib.Color = @raylib.Color::new(120, 100, 70, 255)

///|
pub let color_gear_gold : @raylib.Color = @raylib.Color::new(210, 180, 80, 255)

///|
pub let color_gear_copper : @raylib.Color = @raylib.Color::new(200, 120, 60, 255)

///|
pub let color_gear_silver : @raylib.Color = @raylib.Color::new(180, 190, 200, 255)

///|
pub let color_cam : @raylib.Color = @raylib.Color::new(160, 140, 100, 255)

///|
pub let color_spring : @raylib.Color = @raylib.Color::new(100, 180, 120, 255)

///|
pub let color_escapement : @raylib.Color = @raylib.Color::new(150, 100, 180, 255)

///|
pub let color_bell : @raylib.Color = @raylib.Color::new(220, 200, 50, 255)

///|
pub let color_bell_ringing : @raylib.Color = @raylib.Color::new(
  255, 240, 100, 255,
)

///|
pub let color_highlight : @raylib.Color = @raylib.Color::new(
  255, 255, 200, 120,
)

///|
pub let color_invalid : @raylib.Color = @raylib.Color::new(255, 60, 60, 120)

///|
pub let color_hud_bg : @raylib.Color = @raylib.Color::new(0, 0, 0, 150)

///|
pub let color_hud_text : @raylib.Color = @raylib.Color::new(220, 210, 180, 255)

///|
pub let color_star_empty : @raylib.Color = @raylib.Color::new(80, 70, 50, 255)

///|
pub let color_star_filled : @raylib.Color = @raylib.Color::new(255, 220, 50, 255)

///|
pub let color_title : @raylib.Color = @raylib.Color::new(210, 180, 80, 255)

///|
pub let color_connection : @raylib.Color = @raylib.Color::new(180, 160, 80, 180)

///|
pub let color_selected : @raylib.Color = @raylib.Color::new(255, 220, 100, 200)

///|
pub let color_toolbar_bg : @raylib.Color = @raylib.Color::new(30, 25, 18, 220)

///|
pub let color_button : @raylib.Color = @raylib.Color::new(80, 70, 50, 255)

///|
pub let color_button_hover : @raylib.Color = @raylib.Color::new(
  120, 105, 70, 255,
)

///|
pub let color_success : @raylib.Color = @raylib.Color::new(80, 220, 120, 255)

///|
pub let color_fail : @raylib.Color = @raylib.Color::new(220, 80, 80, 255)
