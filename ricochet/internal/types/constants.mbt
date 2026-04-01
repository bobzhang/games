///|
pub let screen_width : Int = 1280

///|
pub let screen_height : Int = 720

///|
pub let target_fps : Int = 60

///|
pub let arena_width : Float = 1000.0

///|
pub let arena_height : Float = 700.0

///|
pub let arena_offset_x : Float = 140.0

///|
pub let arena_offset_y : Float = 10.0

///|
pub let ball_speed : Float = 400.0

///|
pub let ball_radius : Float = 6.0

///|
pub let target_radius : Float = 15.0

///|
pub let splitter_radius : Float = 12.0

///|
pub let bumper_radius : Float = 14.0

///|
pub let pickup_radius : Float = 10.0

///|
pub let max_bounces : Int = 50

///|
pub let max_balls : Int = 8

///|
pub let preview_bounces : Int = 10

///|
pub let trail_length : Int = 12

///|
pub let aim_speed : Float = 1.5

///|
pub let pi : Float = 3.14159265

///|
pub let two_pi : Float = 6.28318530

///|
pub let splitter_angle : Float = 0.5236

// Colors - Neon aesthetic

///|
pub let color_bg : @raylib.Color = @raylib.Color::new(10, 10, 26, 255)

///|
pub let color_ball : @raylib.Color = @raylib.Color::new(0, 255, 255, 255)

///|
pub let color_ball_glow : @raylib.Color = @raylib.Color::new(0, 255, 255, 60)

///|
pub let color_target : @raylib.Color = @raylib.Color::new(255, 0, 180, 255)

///|
pub let color_target_hit : @raylib.Color = @raylib.Color::new(255, 0, 180, 80)

///|
pub let color_splitter : @raylib.Color = @raylib.Color::new(255, 255, 0, 255)

///|
pub let color_gate : @raylib.Color = @raylib.Color::new(0, 255, 100, 255)

///|
pub let color_gate_blocked : @raylib.Color = @raylib.Color::new(
  255, 60, 60, 255,
)

///|
pub let color_bumper : @raylib.Color = @raylib.Color::new(255, 160, 0, 255)

///|
pub let color_pickup_item : @raylib.Color = @raylib.Color::new(
  180, 100, 255, 255,
)

///|
pub let color_wall : @raylib.Color = @raylib.Color::new(220, 220, 255, 255)

///|
pub let color_wall_glow : @raylib.Color = @raylib.Color::new(220, 220, 255, 30)

///|
pub let color_grid : @raylib.Color = @raylib.Color::new(20, 20, 40, 255)

///|
pub let color_preview : @raylib.Color = @raylib.Color::new(0, 255, 255, 100)

///|
pub let color_hud_text : @raylib.Color = @raylib.Color::new(200, 220, 255, 255)

///|
pub let color_star_filled : @raylib.Color = @raylib.Color::new(255, 215, 0, 255)

///|
pub let color_star_empty : @raylib.Color = @raylib.Color::new(80, 80, 100, 255)

///|
pub let color_title : @raylib.Color = @raylib.Color::new(0, 255, 255, 255)

///|
pub let color_menu_item : @raylib.Color = @raylib.Color::new(180, 200, 255, 255)

///|
pub let color_menu_highlight : @raylib.Color = @raylib.Color::new(
  255, 255, 0, 255,
)

///|
pub let total_levels : Int = 30

///|
pub let levels_per_world : Int = 10
