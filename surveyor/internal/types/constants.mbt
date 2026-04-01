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
pub let fence_thickness : Float = 6.0

///|
pub let fence_hover_thickness : Float = 4.0

///|
pub let total_levels : Int = 25

///|
pub let tier1_count : Int = 8

///|
pub let tier2_count : Int = 9

///|
pub let tier3_count : Int = 8

// Colors

///|
pub let color_bg : @raylib.Color = @raylib.Color::new(62, 99, 52, 255)

///|
pub let color_grass : @raylib.Color = @raylib.Color::new(86, 140, 66, 255)

///|
pub let color_grass_alt : @raylib.Color = @raylib.Color::new(78, 128, 60, 255)

///|
pub let color_road : @raylib.Color = @raylib.Color::new(140, 140, 130, 255)

///|
pub let color_water : @raylib.Color = @raylib.Color::new(70, 130, 200, 255)

///|
pub let color_water_dark : @raylib.Color = @raylib.Color::new(50, 100, 170, 255)

///|
pub let color_fence : @raylib.Color = @raylib.Color::new(240, 230, 210, 255)

///|
pub let color_fence_hover : @raylib.Color = @raylib.Color::new(
  255, 255, 180, 180,
)

///|
pub let color_grid_line : @raylib.Color = @raylib.Color::new(50, 80, 42, 120)

///|
pub let color_ui_bg : @raylib.Color = @raylib.Color::new(40, 60, 35, 240)

///|
pub let color_ui_text : @raylib.Color = @raylib.Color::new(240, 235, 220, 255)

///|
pub let color_ui_dim : @raylib.Color = @raylib.Color::new(160, 155, 140, 255)

///|
pub let color_title : @raylib.Color = @raylib.Color::new(255, 240, 200, 255)

///|
pub let color_star : @raylib.Color = @raylib.Color::new(255, 215, 0, 255)

///|
pub let color_star_empty : @raylib.Color = @raylib.Color::new(100, 95, 80, 255)

///|
pub let color_satisfied : @raylib.Color = @raylib.Color::new(80, 200, 80, 255)

///|
pub let color_violated : @raylib.Color = @raylib.Color::new(220, 60, 60, 255)

///|
pub let color_unchecked : @raylib.Color = @raylib.Color::new(180, 180, 160, 255)

///|
pub let color_button : @raylib.Color = @raylib.Color::new(90, 140, 75, 255)

///|
pub let color_button_hover : @raylib.Color = @raylib.Color::new(
  110, 170, 90, 255,
)

// House colors (for different color_id values)

///|
pub fn house_color(id : Int) -> @raylib.Color {
  match id {
    0 => @raylib.Color::new(200, 60, 60, 255) // red
    1 => @raylib.Color::new(60, 100, 200, 255) // blue
    2 => @raylib.Color::new(200, 160, 40, 255) // yellow
    3 => @raylib.Color::new(160, 60, 200, 255) // purple
    4 => @raylib.Color::new(40, 180, 140, 255) // teal
    5 => @raylib.Color::new(220, 120, 40, 255) // orange
    6 => @raylib.Color::new(180, 80, 140, 255) // pink
    7 => @raylib.Color::new(100, 160, 60, 255) // lime
    _ => @raylib.Color::new(180, 180, 180, 255) // gray
  }
}

///|
pub fn region_shade(id : Int) -> @raylib.Color {
  match id {
    0 => @raylib.Color::new(200, 60, 60, 50)
    1 => @raylib.Color::new(60, 100, 200, 50)
    2 => @raylib.Color::new(200, 160, 40, 50)
    3 => @raylib.Color::new(160, 60, 200, 50)
    4 => @raylib.Color::new(40, 180, 140, 50)
    5 => @raylib.Color::new(220, 120, 40, 50)
    6 => @raylib.Color::new(180, 80, 140, 50)
    7 => @raylib.Color::new(100, 160, 60, 50)
    _ => @raylib.Color::new(180, 180, 180, 50)
  }
}
