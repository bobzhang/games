///|
pub let screen_width : Int = 1280

///|
pub let screen_height : Int = 720

///|
pub let target_fps : Int = 60

///|
pub let grid_cols : Int = 12

///|
pub let grid_rows : Int = 10

///|
pub let cell_size : Int = 52

///|
pub let grid_offset_x : Int = 40

///|
pub let grid_offset_y : Int = 60

///|
pub let total_levels : Int = 20

// Water colors by depth (deeper = darker blue)
///|
pub let color_water_shallow : @raylib.Color = @raylib.Color::new(
  100, 180, 255, 255,
)

///|
pub let color_water_mid : @raylib.Color = @raylib.Color::new(50, 120, 220, 255)

///|
pub let color_water_deep : @raylib.Color = @raylib.Color::new(20, 60, 160, 255)

// Land colors by height (lower = darker green/brown)
///|
pub let color_land_low : @raylib.Color = @raylib.Color::new(80, 140, 60, 255)

///|
pub let color_land_mid : @raylib.Color = @raylib.Color::new(110, 170, 70, 255)

///|
pub let color_land_high : @raylib.Color = @raylib.Color::new(160, 200, 100, 255)

///|
pub let color_land_peak : @raylib.Color = @raylib.Color::new(200, 220, 150, 255)

///|
pub let color_settlement : @raylib.Color = @raylib.Color::new(255, 200, 50, 255)

///|
pub let color_sand : @raylib.Color = @raylib.Color::new(220, 190, 130, 255)

///|
pub let color_sand_highlight : @raylib.Color = @raylib.Color::new(
  240, 220, 170, 255,
)

///|
pub let color_flood_preview : @raylib.Color = @raylib.Color::new(
  255, 80, 80, 120,
)

///|
pub let color_connected : @raylib.Color = @raylib.Color::new(50, 255, 100, 200)

///|
pub let color_disconnected : @raylib.Color = @raylib.Color::new(
  255, 50, 50, 200,
)

///|
pub let color_bg : @raylib.Color = @raylib.Color::new(15, 20, 35, 255)

///|
pub let color_ui_bg : @raylib.Color = @raylib.Color::new(0, 0, 0, 150)

///|
pub let color_ui_text : @raylib.Color = @raylib.Color::new(220, 230, 245, 255)

///|
pub let color_title_water : @raylib.Color = @raylib.Color::new(
  40, 100, 200, 255,
)

///|
pub let color_star_gold : @raylib.Color = @raylib.Color::new(255, 215, 0, 255)

///|
pub let color_star_empty : @raylib.Color = @raylib.Color::new(80, 80, 80, 255)

///|
pub let color_hover_valid : @raylib.Color = @raylib.Color::new(
  255, 255, 255, 80,
)

///|
pub let color_hover_invalid : @raylib.Color = @raylib.Color::new(
  255, 0, 0, 80,
)

///|
pub let color_tier_shores : @raylib.Color = @raylib.Color::new(
  80, 200, 120, 255,
)

///|
pub let color_tier_straits : @raylib.Color = @raylib.Color::new(
  200, 160, 60, 255,
)

///|
pub let color_tier_archipelago : @raylib.Color = @raylib.Color::new(
  200, 80, 80, 255,
)
