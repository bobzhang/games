///|
pub let screen_width : Int = 1280

///|
pub let screen_height : Int = 720

///|
pub let target_fps : Int = 60

// View cell sizes based on grid size

///|
pub let cell_size_3 : Int = 40

///|
pub let cell_size_4 : Int = 30

///|
pub let cell_size_5 : Int = 24

// Isometric projection

///|
pub let iso_scale : Float = 20.0

///|
pub let iso_x_factor : Float = 0.866

///|
pub let iso_y_factor : Float = 0.5

// Layout: 3 view panels + isometric view
// Top view: top-left area

///|
pub let view_top_x : Int = 40

///|
pub let view_top_y : Int = 60

// Front view: top-right area

///|
pub let view_front_x : Int = 660

///|
pub let view_front_y : Int = 60

// Side view: bottom-left area

///|
pub let view_side_x : Int = 40

///|
pub let view_side_y : Int = 400

// Isometric view: bottom-right area

///|
pub let view_iso_x : Int = 660

///|
pub let view_iso_y : Int = 400

///|
pub let iso_center_x : Int = 900

///|
pub let iso_center_y : Int = 550

// Colors

///|
pub let color_bg : @raylib.Color = @raylib.Color::new(18, 18, 30, 255)

///|
pub let color_panel_bg : @raylib.Color = @raylib.Color::new(25, 25, 42, 255)

///|
pub let color_filled : @raylib.Color = @raylib.Color::new(0, 200, 220, 255)

///|
pub let color_filled_light : @raylib.Color = @raylib.Color::new(
  60, 230, 245, 255,
)

///|
pub let color_empty : @raylib.Color = @raylib.Color::new(50, 50, 70, 255)

///|
pub let color_target : @raylib.Color = @raylib.Color::new(255, 200, 50, 180)

///|
pub let color_matched : @raylib.Color = @raylib.Color::new(50, 220, 100, 255)

///|
pub let color_unmatched : @raylib.Color = @raylib.Color::new(220, 50, 60, 255)

///|
pub let color_hover : @raylib.Color = @raylib.Color::new(255, 255, 255, 100)

///|
pub let color_grid_line : @raylib.Color = @raylib.Color::new(60, 60, 90, 255)

///|
pub let color_text : @raylib.Color = @raylib.Color::new(200, 210, 230, 255)

///|
pub let color_title : @raylib.Color = @raylib.Color::new(0, 220, 240, 255)

///|
pub let color_star_gold : @raylib.Color = @raylib.Color::new(255, 215, 0, 255)

///|
pub let color_star_empty : @raylib.Color = @raylib.Color::new(80, 80, 100, 255)

///|
pub let color_button : @raylib.Color = @raylib.Color::new(60, 60, 100, 255)

///|
pub let color_button_hover : @raylib.Color = @raylib.Color::new(
  80, 80, 140, 255,
)

///|
pub let color_iso_top : @raylib.Color = @raylib.Color::new(0, 200, 220, 255)

///|
pub let color_iso_left : @raylib.Color = @raylib.Color::new(0, 150, 170, 255)

///|
pub let color_iso_right : @raylib.Color = @raylib.Color::new(0, 120, 140, 255)

///|
pub let color_preview : @raylib.Color = @raylib.Color::new(255, 255, 100, 120)

///|
pub let color_tier_shapes : @raylib.Color = @raylib.Color::new(
  80, 200, 120, 255,
)

///|
pub let color_tier_structures : @raylib.Color = @raylib.Color::new(
  100, 150, 255, 255,
)

///|
pub let color_tier_sculptures : @raylib.Color = @raylib.Color::new(
  220, 100, 255, 255,
)

///|
pub let color_complete : @raylib.Color = @raylib.Color::new(50, 255, 120, 255)

///|
pub let total_levels : Int = 30

///|
pub let levels_per_tier : Int = 10
