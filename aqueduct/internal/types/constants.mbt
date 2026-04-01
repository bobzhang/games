///|
pub let screen_width : Int = 1280

///|
pub let screen_height : Int = 720

///|
pub let target_fps : Int = 60

///|
pub let grid_cols : Int = 10

///|
pub let grid_rows : Int = 8

///|
pub let cell_size : Int = 64

///|
pub let grid_offset_x : Int = 40

///|
pub let grid_offset_y : Int = 80

///|
pub let max_elevation : Int = 4

///|
pub let sim_tick_interval : Float = 0.15

///|
pub let color_bg : @raylib.Color = @raylib.Color::new(20, 30, 45, 255)

///|
pub let color_grid_bg : @raylib.Color = @raylib.Color::new(35, 50, 70, 255)

///|
pub let color_grid_line : @raylib.Color = @raylib.Color::new(55, 75, 100, 255)

///|
pub let color_water : @raylib.Color = @raylib.Color::new(40, 140, 255, 220)

///|
pub let color_water_flow : @raylib.Color = @raylib.Color::new(80, 180, 255, 255)

///|
pub let color_spring : @raylib.Color = @raylib.Color::new(60, 200, 255, 255)

///|
pub let color_fountain : @raylib.Color = @raylib.Color::new(255, 100, 180, 255)

///|
pub let color_fountain_filled : @raylib.Color = @raylib.Color::new(
  100, 255, 180, 255,
)

///|
pub let color_aqueduct : @raylib.Color = @raylib.Color::new(180, 160, 130, 255)

///|
pub let color_aqueduct_wet : @raylib.Color = @raylib.Color::new(
  100, 170, 230, 255,
)

///|
pub let color_reservoir : @raylib.Color = @raylib.Color::new(140, 120, 180, 255)

///|
pub let color_reservoir_full : @raylib.Color = @raylib.Color::new(
  80, 160, 255, 255,
)

///|
pub let color_dam : @raylib.Color = @raylib.Color::new(160, 140, 100, 255)

///|
pub let color_hover : @raylib.Color = @raylib.Color::new(255, 255, 255, 60)

///|
pub let color_invalid : @raylib.Color = @raylib.Color::new(255, 60, 60, 80)

///|
pub let color_hud_text : @raylib.Color = @raylib.Color::new(210, 220, 235, 255)

///|
pub let color_hud_dim : @raylib.Color = @raylib.Color::new(140, 155, 175, 200)

///|
pub let color_title_accent : @raylib.Color = @raylib.Color::new(
  80, 180, 255, 255,
)

///|
pub let color_star_on : @raylib.Color = @raylib.Color::new(255, 215, 0, 255)

///|
pub let color_star_off : @raylib.Color = @raylib.Color::new(80, 90, 110, 255)

///|
pub let color_selected : @raylib.Color = @raylib.Color::new(255, 255, 255, 255)

///|
pub let color_tier1 : @raylib.Color = @raylib.Color::new(100, 200, 255, 255)

///|
pub let color_tier2 : @raylib.Color = @raylib.Color::new(255, 180, 60, 255)

///|
pub let color_tier3 : @raylib.Color = @raylib.Color::new(255, 80, 180, 255)

///|
pub let color_elevation : Array[@raylib.Color] = [
  @raylib.Color::new(30, 60, 40, 255),
  @raylib.Color::new(50, 90, 55, 255),
  @raylib.Color::new(75, 120, 70, 255),
  @raylib.Color::new(100, 150, 85, 255),
  @raylib.Color::new(130, 180, 100, 255),
]

///|
pub fn tier_color(t : Tier) -> @raylib.Color {
  match t {
    Tier1 => color_tier1
    Tier2 => color_tier2
    Tier3 => color_tier3
  }
}

///|
pub fn tier_name(t : Tier) -> String {
  match t {
    Tier1 => "Tier 1: Downhill"
    Tier2 => "Tier 2: Reservoirs"
    Tier3 => "Tier 3: Mastery"
  }
}
