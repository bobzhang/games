///|
pub let screen_width : Int = 1280

///|
pub let screen_height : Int = 720

///|
pub let target_fps : Int = 60

///|
pub let grid_cols : Int = 8

///|
pub let grid_rows : Int = 6

///|
pub let cell_size : Int = 72

///|
pub let grid_offset_x : Int = 80

///|
pub let grid_offset_y : Int = 80

///|
pub let battery_voltage : Float = 1.5

///|
pub let voltage_tolerance : Float = 0.1

///|
pub let fuse_blow_multiplier : Float = 2.0

///|
pub let total_levels : Int = 25

///|
pub let tier1_count : Int = 8

///|
pub let tier2_count : Int = 9

///|
pub let tier3_count : Int = 8

///|
pub let animation_speed : Float = 2.0

///|
pub let spark_lifetime : Float = 0.5

///|
pub let fuse_blow_duration : Float = 0.8

///|
pub let wire_thickness : Float = 3.0

///|
pub let component_radius : Float = 28.0

// Colors

///|
pub let color_bg : @raylib.Color = @raylib.Color::new(20, 22, 36, 255)

///|
pub let color_grid_line : @raylib.Color = @raylib.Color::new(40, 44, 70, 255)

///|
pub let color_grid_cell : @raylib.Color = @raylib.Color::new(28, 30, 48, 255)

///|
pub let color_battery : @raylib.Color = @raylib.Color::new(80, 200, 80, 255)

///|
pub let color_device : @raylib.Color = @raylib.Color::new(255, 180, 50, 255)

///|
pub let color_wire : @raylib.Color = @raylib.Color::new(100, 160, 255, 255)

///|
pub let color_wire_powered : @raylib.Color = @raylib.Color::new(
  130, 220, 255, 255,
)

///|
pub let color_fuse : @raylib.Color = @raylib.Color::new(255, 100, 80, 255)

///|
pub let color_fuse_blown : @raylib.Color = @raylib.Color::new(80, 40, 40, 255)

///|
pub let color_switch_on : @raylib.Color = @raylib.Color::new(50, 255, 150, 255)

///|
pub let color_switch_off : @raylib.Color = @raylib.Color::new(150, 80, 80, 255)

///|
pub let color_satisfied : @raylib.Color = @raylib.Color::new(50, 255, 100, 255)

///|
pub let color_unsatisfied : @raylib.Color = @raylib.Color::new(255, 80, 60, 255)

///|
pub let color_hud_bg : @raylib.Color = @raylib.Color::new(0, 0, 0, 180)

///|
pub let color_hud_text : @raylib.Color = @raylib.Color::new(200, 220, 255, 255)

///|
pub let color_title : @raylib.Color = @raylib.Color::new(255, 220, 80, 255)

///|
pub let color_star_filled : @raylib.Color = @raylib.Color::new(255, 215, 0, 255)

///|
pub let color_star_empty : @raylib.Color = @raylib.Color::new(60, 60, 80, 255)

///|
pub let color_highlight : @raylib.Color = @raylib.Color::new(255, 255, 255, 60)

///|
pub let color_cursor : @raylib.Color = @raylib.Color::new(255, 255, 100, 180)

///|
pub let color_button : @raylib.Color = @raylib.Color::new(60, 80, 140, 255)

///|
pub let color_button_hover : @raylib.Color = @raylib.Color::new(
  80, 110, 180, 255,
)

///|
pub let color_panel : @raylib.Color = @raylib.Color::new(30, 34, 56, 240)
