///|
pub let screen_w : Int = 960

///|
pub let screen_h : Int = 720

///|
pub let target_fps : Int = 60

///|
pub let tile_size : Int = 48

///|
pub let tile_sizef : Float = 48.0

///|
pub let grid_max_w : Int = 12

///|
pub let grid_max_h : Int = 12

///|
pub let grid_offset_x : Int = 96

///|
pub let grid_offset_y : Int = 72

///|
pub let anim_speed : Float = 8.0

///|
pub let settle_delay : Float = 0.06

///|
pub let gravity_anim_duration : Float = 0.25

///|
pub let message_duration : Float = 2.0

///|
pub let num_worlds : Int = 5

///|
pub let levels_per_world : Int = 10

///|
pub let total_levels : Int = 50

///|
pub fn world_bg_color(theme : WorldTheme) -> @raylib.Color {
  match theme {
    Stone => @raylib.Color::new(60, 56, 54, 255)
    Crystal => @raylib.Color::new(20, 12, 60, 255)
    Void => @raylib.Color::new(8, 8, 16, 255)
    Magma => @raylib.Color::new(48, 16, 8, 255)
    Sky => @raylib.Color::new(60, 100, 160, 255)
  }
}

///|
pub fn world_wall_color(theme : WorldTheme) -> @raylib.Color {
  match theme {
    Stone => @raylib.Color::new(140, 130, 120, 255)
    Crystal => @raylib.Color::new(100, 60, 160, 255)
    Void => @raylib.Color::new(40, 40, 60, 255)
    Magma => @raylib.Color::new(120, 50, 30, 255)
    Sky => @raylib.Color::new(180, 200, 220, 255)
  }
}

///|
pub fn world_floor_color(theme : WorldTheme) -> @raylib.Color {
  match theme {
    Stone => @raylib.Color::new(100, 94, 88, 255)
    Crystal => @raylib.Color::new(60, 40, 120, 255)
    Void => @raylib.Color::new(24, 24, 40, 255)
    Magma => @raylib.Color::new(80, 32, 16, 255)
    Sky => @raylib.Color::new(140, 170, 200, 255)
  }
}

///|
pub fn world_theme_of(index : Int) -> WorldTheme {
  match index {
    0 => Stone
    1 => Crystal
    2 => Void
    3 => Magma
    _ => Sky
  }
}

///|
pub fn world_name(index : Int) -> String {
  match index {
    0 => "Stone Ruins"
    1 => "Crystal Caverns"
    2 => "Void Expanse"
    3 => "Magma Depths"
    _ => "Sky Citadel"
  }
}

///|
pub let color_player : @raylib.Color = @raylib.Color::new(80, 200, 255, 255)

///|
pub let color_box : @raylib.Color = @raylib.Color::new(180, 140, 80, 255)

///|
pub let color_boulder : @raylib.Color = @raylib.Color::new(140, 140, 140, 255)

///|
pub let color_key : @raylib.Color = @raylib.Color::new(255, 220, 40, 255)

///|
pub let color_gem : @raylib.Color = @raylib.Color::new(100, 255, 100, 255)

///|
pub let color_exit : @raylib.Color = @raylib.Color::new(50, 255, 120, 255)

///|
pub let color_spike : @raylib.Color = @raylib.Color::new(255, 60, 60, 255)

///|
pub let color_ice : @raylib.Color = @raylib.Color::new(180, 220, 255, 255)

///|
pub let color_portal : @raylib.Color = @raylib.Color::new(200, 100, 255, 255)

///|
pub let color_switch : @raylib.Color = @raylib.Color::new(255, 180, 40, 255)

///|
pub let color_gate : @raylib.Color = @raylib.Color::new(255, 160, 30, 200)

///|
pub let color_crumble : @raylib.Color = @raylib.Color::new(160, 140, 100, 255)

///|
pub let color_conveyor : @raylib.Color = @raylib.Color::new(100, 180, 200, 255)

///|
pub let color_star_gold : @raylib.Color = @raylib.Color::new(255, 215, 0, 255)

///|
pub let color_star_silver : @raylib.Color = @raylib.Color::new(
  192, 192, 192, 255,
)

///|
pub let color_star_bronze : @raylib.Color = @raylib.Color::new(
  205, 127, 50, 255,
)

///|
pub let color_star_empty : @raylib.Color = @raylib.Color::new(80, 80, 80, 255)

///|
pub let color_pressure_plate : @raylib.Color = @raylib.Color::new(
  200, 180, 120, 255,
)

///|
pub let color_mirror : @raylib.Color = @raylib.Color::new(220, 240, 255, 255)

///|
pub let color_gravity_well : @raylib.Color = @raylib.Color::new(
  100, 0, 200, 255,
)

///|
pub let color_timed_lava : @raylib.Color = @raylib.Color::new(255, 100, 20, 255)

///|
pub let color_wind_gust : @raylib.Color = @raylib.Color::new(200, 230, 255, 255)

///|
pub let ghost_replay_speed : Float = 0.4

///|
pub let hint_display_duration : Float = 2.5

///|
pub let lava_cycle_period : Float = 4.0

///|
pub let wind_beat_period : Float = 2.0

///|
pub let ambient_spawn_rate : Float = 0.15

///|
pub let max_particles : Int = 256

///|
pub let gravity_rot_speed : Float = 6.0

///|
pub let bounce_duration : Float = 0.3

///|
pub let editor_tile_count : Int = 15

///|
pub let editor_entity_count : Int = 6

///|
pub let color_enemy : @raylib.Color = @raylib.Color::new(220, 50, 50, 255)

///|
pub let toast_display_duration : Float = 2.5

///|
pub let toast_slide_speed : Float = 4.0
