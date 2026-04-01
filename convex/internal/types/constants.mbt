///|
pub let screen_width : Int = 1280

///|
pub let screen_height : Int = 720

///|
pub let target_fps : Int = 60

///|
pub let plane_x : Float = 240.0

///|
pub let plane_y : Float = 60.0

///|
pub let plane_width : Float = 800.0

///|
pub let plane_height : Float = 600.0

///|
pub let grid_snap : Float = 20.0

///|
pub let tolerance : Float = 15.0

///|
pub let point_radius : Float = 6.0

///|
pub let hull_point_radius : Float = 8.0

///|
pub let remove_radius : Float = 15.0

///|
pub let total_levels : Int = 25

///|
pub let tier1_count : Int = 8

///|
pub let tier2_count : Int = 9

///|
pub let tier3_count : Int = 8

// Colors - dark geometric aesthetic

///|
pub let color_bg : @raylib.Color = @raylib.Color::new(15, 15, 25, 255)

///|
pub let color_plane_bg : @raylib.Color = @raylib.Color::new(20, 22, 35, 255)

///|
pub let color_grid : @raylib.Color = @raylib.Color::new(35, 38, 55, 255)

///|
pub let color_grid_major : @raylib.Color = @raylib.Color::new(45, 50, 70, 255)

///|
pub let color_point : @raylib.Color = @raylib.Color::new(0, 220, 255, 255)

///|
pub let color_point_interior : @raylib.Color = @raylib.Color::new(
  100, 100, 140, 180,
)

///|
pub let color_hull : @raylib.Color = @raylib.Color::new(50, 255, 120, 255)

///|
pub let color_hull_fill : @raylib.Color = @raylib.Color::new(50, 255, 120, 25)

///|
pub let color_target : @raylib.Color = @raylib.Color::new(255, 200, 50, 255)

///|
pub let color_target_fill : @raylib.Color = @raylib.Color::new(255, 200, 50, 15)

///|
pub let color_match : @raylib.Color = @raylib.Color::new(50, 255, 50, 255)

///|
pub let color_nomatch : @raylib.Color = @raylib.Color::new(255, 80, 80, 255)

///|
pub let color_snap : @raylib.Color = @raylib.Color::new(0, 220, 255, 80)

///|
pub let color_hover_remove : @raylib.Color = @raylib.Color::new(
  255, 60, 60, 200,
)

///|
pub let color_ui_text : @raylib.Color = @raylib.Color::new(200, 210, 230, 255)

///|
pub let color_ui_dim : @raylib.Color = @raylib.Color::new(120, 130, 150, 255)

///|
pub let color_star_gold : @raylib.Color = @raylib.Color::new(255, 215, 0, 255)

///|
pub let color_star_empty : @raylib.Color = @raylib.Color::new(80, 80, 100, 255)

///|
pub let color_tier_vertices : @raylib.Color = @raylib.Color::new(
  80, 200, 255, 255,
)

///|
pub let color_tier_edges : @raylib.Color = @raylib.Color::new(
  180, 120, 255, 255,
)

///|
pub let color_tier_sculpt : @raylib.Color = @raylib.Color::new(
  255, 140, 80, 255,
)

///|
pub let color_panel : @raylib.Color = @raylib.Color::new(25, 28, 45, 240)

///|
pub let color_button : @raylib.Color = @raylib.Color::new(40, 45, 70, 255)

///|
pub let color_button_hover : @raylib.Color = @raylib.Color::new(55, 60, 90, 255)
