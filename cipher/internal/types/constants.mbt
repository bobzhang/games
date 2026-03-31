///|
pub let screen_width : Int = 1280

///|
pub let screen_height : Int = 720

///|
pub let target_fps : Int = 60

///|
pub let alphabet_size : Int = 26

///|
pub let unmapped : Int = -1

// English letter frequencies (percent, A-Z)
///|
pub let english_freq : Array[Float] = [
  8.2, 1.5, 2.8, 4.3, 12.7, 2.2, 2.0, 6.1, 7.0, 0.2, 0.8, 4.0, 2.4, 6.7, 7.5,
  1.9, 0.1, 6.0, 6.3, 9.1, 2.8, 1.0, 2.4, 0.2, 2.0, 0.1,
]

// Spy theme colors - dark terminal aesthetic
///|
pub let color_bg : @raylib.Color = @raylib.Color::new(10, 12, 18, 255)

///|
pub let color_panel : @raylib.Color = @raylib.Color::new(18, 22, 32, 255)

///|
pub let color_panel_border : @raylib.Color = @raylib.Color::new(40, 50, 70, 255)

///|
pub let color_green : @raylib.Color = @raylib.Color::new(0, 220, 100, 255)

///|
pub let color_red : @raylib.Color = @raylib.Color::new(220, 50, 50, 255)

///|
pub let color_amber : @raylib.Color = @raylib.Color::new(255, 180, 0, 255)

///|
pub let color_cyan : @raylib.Color = @raylib.Color::new(0, 200, 220, 255)

///|
pub let color_text : @raylib.Color = @raylib.Color::new(180, 200, 220, 255)

///|
pub let color_dim : @raylib.Color = @raylib.Color::new(80, 100, 120, 255)

///|
pub let color_highlight : @raylib.Color = @raylib.Color::new(60, 80, 120, 255)

///|
pub let color_dark_green : @raylib.Color = @raylib.Color::new(0, 100, 50, 255)

///|
pub let color_star_gold : @raylib.Color = @raylib.Color::new(255, 215, 0, 255)

///|
pub let color_star_empty : @raylib.Color = @raylib.Color::new(60, 60, 60, 255)

///|
pub let color_bar_english : @raylib.Color = @raylib.Color::new(60, 60, 100, 180)

///|
pub let color_bar_cipher : @raylib.Color = @raylib.Color::new(0, 180, 80, 200)

///|
pub let color_button : @raylib.Color = @raylib.Color::new(30, 45, 65, 255)

///|
pub let color_button_hover : @raylib.Color = @raylib.Color::new(50, 70, 100, 255)

///|
pub let color_white : @raylib.Color = @raylib.Color::new(240, 245, 255, 255)

// Layout constants
///|
pub let msg_area_x : Int = 40

///|
pub let msg_area_y : Int = 60

///|
pub let msg_area_w : Int = 840

///|
pub let tool_panel_x : Int = 900

///|
pub let tool_panel_w : Int = 360

///|
pub let char_cell_w : Int = 28

///|
pub let char_cell_h : Int = 36

///|
pub let max_undo : Int = 100
