///|
pub let screen_width : Int = 1280

///|
pub let screen_height : Int = 720

///|
pub let target_fps : Int = 60

///|
pub let tile_size : Int = 52

///|
pub let grid_width : Int = 12

///|
pub let grid_height : Int = 10

///|
pub let grid_offset_x : Int = 86

///|
pub let grid_offset_y : Int = 40

///|
pub let max_ticks : Int = 20

///|
pub let decay_rate : Float = 0.15

///|
pub let sim_tick_interval : Float = 0.35

///|
pub let total_levels : Int = 30

///|
pub let levels_per_tier : Int = 10

// Colors
///|
pub let color_bg : @raylib.Color = @raylib.Color::new(8, 12, 32, 255)

///|
pub let color_grid_line : @raylib.Color = @raylib.Color::new(25, 35, 60, 255)

///|
pub let color_grid_bg : @raylib.Color = @raylib.Color::new(12, 18, 40, 255)

///|
pub let color_wall : @raylib.Color = @raylib.Color::new(80, 85, 95, 255)

///|
pub let color_target_ok : @raylib.Color = @raylib.Color::new(50, 255, 100, 255)

///|
pub let color_target_fail : @raylib.Color = @raylib.Color::new(255, 60, 60, 255)

///|
pub let color_emitter_p0 : @raylib.Color = @raylib.Color::new(0, 220, 255, 255)

///|
pub let color_emitter_p1 : @raylib.Color = @raylib.Color::new(80, 255, 80, 255)

///|
pub let color_emitter_p2 : @raylib.Color = @raylib.Color::new(255, 220, 50, 255)

///|
pub let color_emitter_p3 : @raylib.Color = @raylib.Color::new(220, 80, 255, 255)

///|
pub let color_reflector : @raylib.Color = @raylib.Color::new(60, 200, 160, 255)

///|
pub let color_phase_shifter : @raylib.Color = @raylib.Color::new(180, 80, 255, 255)

///|
pub let color_absorber : @raylib.Color = @raylib.Color::new(60, 60, 70, 255)

///|
pub let color_ui_text : @raylib.Color = @raylib.Color::new(200, 220, 255, 255)

///|
pub let color_ui_dim : @raylib.Color = @raylib.Color::new(100, 120, 150, 255)

///|
pub let color_ui_highlight : @raylib.Color = @raylib.Color::new(0, 200, 255, 255)

///|
pub let color_ui_panel : @raylib.Color = @raylib.Color::new(15, 20, 45, 220)

///|
pub let color_star_gold : @raylib.Color = @raylib.Color::new(255, 215, 0, 255)

///|
pub let color_star_empty : @raylib.Color = @raylib.Color::new(60, 65, 80, 255)

///|
pub let color_title_accent : @raylib.Color = @raylib.Color::new(0, 180, 255, 255)

// Palette panel
///|
pub let palette_x : Int = 730

///|
pub let palette_y : Int = 50

///|
pub let palette_w : Int = 530

///|
pub let palette_h : Int = 660

// Wave visualization colors
///|
pub let color_wave_ripple_0 : @raylib.Color = @raylib.Color::new(
  0, 200, 255, 120,
)

///|
pub let color_wave_ripple_1 : @raylib.Color = @raylib.Color::new(
  80, 255, 80, 120,
)

///|
pub let color_wave_ripple_2 : @raylib.Color = @raylib.Color::new(
  255, 220, 50, 120,
)

///|
pub let color_wave_ripple_3 : @raylib.Color = @raylib.Color::new(
  220, 80, 255, 120,
)

// Target indicator colors
///|
pub let color_target_ring_sat : @raylib.Color = @raylib.Color::new(
  50, 255, 100, 255,
)

///|
pub let color_target_ring_unsat : @raylib.Color = @raylib.Color::new(
  255, 60, 60, 200,
)

///|
pub let color_target_amp_bar_bg : @raylib.Color = @raylib.Color::new(
  20, 25, 40, 200,
)

///|
pub let color_target_amp_bar_fill : @raylib.Color = @raylib.Color::new(
  100, 200, 255, 220,
)

///|
pub let color_target_amp_bar_range : @raylib.Color = @raylib.Color::new(
  60, 180, 100, 120,
)
