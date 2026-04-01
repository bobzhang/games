///|
pub let screen_width : Int = 1280

///|
pub let screen_height : Int = 720

///|
pub let target_fps : Int = 60

///|
pub let grid_cols : Int = 8

///|
pub let grid_rows : Int = 7

///|
pub let cell_width : Int = 80

///|
pub let cell_height : Int = 60

///|
pub let grid_offset_x : Int = 200

///|
pub let grid_offset_y : Int = 120

///|
pub let playback_speed : Float = 0.4

///|
pub let total_levels : Int = 20

// Interval scores

///|
pub let score_unison : Int = 0

///|
pub let score_second : Int = -1

///|
pub let score_third : Int = 2

///|
pub let score_tritone : Int = -2

///|
pub let score_fifth : Int = 3

///|
pub let score_sixth : Int = 2

///|
pub let score_seventh : Int = -1

// Note colors (rainbow per pitch)

///|
pub let color_note_c : @raylib.Color = @raylib.Color::new(255, 80, 80, 255)

///|
pub let color_note_d : @raylib.Color = @raylib.Color::new(255, 160, 50, 255)

///|
pub let color_note_e : @raylib.Color = @raylib.Color::new(255, 230, 50, 255)

///|
pub let color_note_f : @raylib.Color = @raylib.Color::new(80, 220, 80, 255)

///|
pub let color_note_g : @raylib.Color = @raylib.Color::new(80, 160, 255, 255)

///|
pub let color_note_a : @raylib.Color = @raylib.Color::new(140, 80, 255, 255)

///|
pub let color_note_b : @raylib.Color = @raylib.Color::new(220, 80, 220, 255)

// UI colors

///|
pub let color_bg : @raylib.Color = @raylib.Color::new(18, 18, 32, 255)

///|
pub let color_grid_bg : @raylib.Color = @raylib.Color::new(30, 30, 50, 255)

///|
pub let color_grid_line : @raylib.Color = @raylib.Color::new(50, 50, 80, 255)

///|
pub let color_target : @raylib.Color = @raylib.Color::new(255, 255, 100, 180)

///|
pub let color_locked : @raylib.Color = @raylib.Color::new(120, 120, 120, 255)

///|
pub let color_playback : @raylib.Color = @raylib.Color::new(255, 255, 255, 60)

///|
pub let color_text : @raylib.Color = @raylib.Color::new(220, 220, 240, 255)

///|
pub let color_text_dim : @raylib.Color = @raylib.Color::new(140, 140, 170, 255)

///|
pub let color_title : @raylib.Color = @raylib.Color::new(200, 160, 255, 255)

///|
pub let color_star_on : @raylib.Color = @raylib.Color::new(255, 215, 0, 255)

///|
pub let color_star_off : @raylib.Color = @raylib.Color::new(80, 80, 100, 255)

///|
pub let color_consonant : @raylib.Color = @raylib.Color::new(80, 255, 120, 255)

///|
pub let color_dissonant : @raylib.Color = @raylib.Color::new(255, 80, 80, 255)

///|
pub let color_button : @raylib.Color = @raylib.Color::new(60, 50, 100, 255)

///|
pub let color_button_hover : @raylib.Color = @raylib.Color::new(
  90, 70, 140, 255,
)

///|
pub let color_melody_tier : @raylib.Color = @raylib.Color::new(
  100, 200, 255, 255,
)

///|
pub let color_harmony_tier : @raylib.Color = @raylib.Color::new(
  100, 255, 150, 255,
)

///|
pub let color_counterpoint_tier : @raylib.Color = @raylib.Color::new(
  255, 180, 100, 255,
)
