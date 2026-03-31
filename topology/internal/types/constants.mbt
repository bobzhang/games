///|
pub let screen_width : Int = 1280

///|
pub let screen_height : Int = 720

///|
pub let target_fps : Int = 60

///|
pub let cell_size : Int = 56

///|
pub let grid_cols : Int = 8

///|
pub let grid_rows : Int = 8

///|
pub let grid_offset_x : Int = 80

///|
pub let grid_offset_y : Int = 80

///|
pub let cost_shift : Int = 1

///|
pub let cost_rotate : Int = 2

///|
pub let cost_flip : Int = 2

///|
pub let cost_grow : Int = 3

///|
pub let cost_shrink : Int = 3

///|
pub let total_levels : Int = 25

///|
pub let morph_levels : Int = 8

///|
pub let sculpt_levels : Int = 9

///|
pub let transform_levels : Int = 8

///|
pub let anim_duration : Float = 0.2

///|
pub let color_bg : @raylib.Color = @raylib.Color::new(24, 24, 36, 255)

///|
pub let color_grid_line : @raylib.Color = @raylib.Color::new(50, 50, 70, 255)

///|
pub let color_grid_bg : @raylib.Color = @raylib.Color::new(30, 30, 45, 255)

///|
pub let color_shape : @raylib.Color = @raylib.Color::new(60, 140, 255, 220)

///|
pub let color_target : @raylib.Color = @raylib.Color::new(60, 220, 120, 180)

///|
pub let color_overlap : @raylib.Color = @raylib.Color::new(255, 200, 60, 240)

///|
pub let color_hover : @raylib.Color = @raylib.Color::new(255, 255, 255, 80)

///|
pub let color_grow_valid : @raylib.Color = @raylib.Color::new(
  100, 255, 100, 120,
)

///|
pub let color_shrink_valid : @raylib.Color = @raylib.Color::new(
  255, 100, 100, 120,
)

///|
pub let color_text : @raylib.Color = @raylib.Color::new(220, 225, 240, 255)

///|
pub let color_text_dim : @raylib.Color = @raylib.Color::new(140, 145, 160, 200)

///|
pub let color_accent : @raylib.Color = @raylib.Color::new(60, 200, 255, 255)

///|
pub let color_gold : @raylib.Color = @raylib.Color::new(255, 215, 0, 255)

///|
pub let color_star_empty : @raylib.Color = @raylib.Color::new(80, 80, 100, 200)

///|
pub let color_op_bg : @raylib.Color = @raylib.Color::new(40, 42, 60, 230)

///|
pub let color_op_selected : @raylib.Color = @raylib.Color::new(
  80, 140, 255, 230,
)

///|
pub let color_op_disabled : @raylib.Color = @raylib.Color::new(60, 60, 70, 150)

///|
pub let color_button : @raylib.Color = @raylib.Color::new(60, 100, 180, 230)

///|
pub let color_button_hover : @raylib.Color = @raylib.Color::new(
  80, 130, 220, 255,
)

///|
pub let color_tier_morph : @raylib.Color = @raylib.Color::new(
  100, 180, 255, 255,
)

///|
pub let color_tier_sculpt : @raylib.Color = @raylib.Color::new(
  180, 120, 255, 255,
)

///|
pub let color_tier_transform : @raylib.Color = @raylib.Color::new(
  255, 140, 80, 255,
)
