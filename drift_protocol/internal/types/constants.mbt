///|
pub let screen_width : Int = 1280

///|
pub let screen_height : Int = 720

///|
pub let target_fps : Int = 60

///|
pub let tile_size : Int = 40

///|
pub let grid_width : Int = 20

///|
pub let grid_height : Int = 15

///|
pub let grid_offset_x : Int = 40

///|
pub let grid_offset_y : Int = 40

///|
pub let move_lerp_speed : Float = 12.0

///|
pub let move_cooldown_time : Float = 0.12

///|
pub let walk_noise_radius : Int = 1

///|
pub let run_noise_radius : Int = 3

///|
pub let coin_noise_radius : Int = 4

///|
pub let coin_duration : Float = 2.0

///|
pub let detection_rate_light : Float = 1.5

///|
pub let detection_rate_shadow : Float = 0.5

///|
pub let detection_max : Float = 1.0

///|
pub let suspicious_duration : Float = 3.0

///|
pub let alert_duration : Float = 5.0

///|
pub let guard_move_interval : Float = 0.5

///|
pub let hack_sequence_length : Int = 4

///|
pub let hack_time_limit : Float = 3.0

///|
pub let shadow_vision_mult : Float = 0.5

///|
pub let noise_decay_time : Float = 0.5

///|
pub let camera_rotation_speed : Float = 1.0

///|
pub let camera_vision_range : Float = 5.0

///|
pub let total_levels : Int = 8

///|
pub let pi : Float = 3.14159265

// Cyberpunk neon color theme

///|
pub let color_bg : @raylib.Color = @raylib.Color::new(10, 10, 20, 255)

///|
pub let color_floor : @raylib.Color = @raylib.Color::new(25, 25, 40, 255)

///|
pub let color_wall : @raylib.Color = @raylib.Color::new(50, 50, 70, 255)

///|
pub let color_wall_edge : @raylib.Color = @raylib.Color::new(80, 80, 120, 255)

///|
pub let color_shadow : @raylib.Color = @raylib.Color::new(12, 12, 25, 200)

///|
pub let color_shadow_zone : @raylib.Color = @raylib.Color::new(15, 15, 30, 255)

///|
pub let color_player : @raylib.Color = @raylib.Color::new(0, 255, 220, 255)

///|
pub let color_player_dim : @raylib.Color = @raylib.Color::new(0, 180, 160, 180)

///|
pub let color_terminal : @raylib.Color = @raylib.Color::new(0, 255, 100, 255)

///|
pub let color_terminal_hacked : @raylib.Color = @raylib.Color::new(100, 100, 100, 255)

///|
pub let color_high_terminal : @raylib.Color = @raylib.Color::new(255, 200, 0, 255)

///|
pub let color_door_closed : @raylib.Color = @raylib.Color::new(200, 100, 50, 255)

///|
pub let color_door_open : @raylib.Color = @raylib.Color::new(80, 160, 80, 255)

///|
pub let color_laser : @raylib.Color = @raylib.Color::new(255, 30, 30, 255)

///|
pub let color_laser_off : @raylib.Color = @raylib.Color::new(80, 20, 20, 255)

///|
pub let color_power_node : @raylib.Color = @raylib.Color::new(255, 160, 0, 255)

///|
pub let color_power_off : @raylib.Color = @raylib.Color::new(100, 60, 0, 255)

///|
pub let color_exit : @raylib.Color = @raylib.Color::new(0, 200, 255, 255)

///|
pub let color_camera_tile : @raylib.Color = @raylib.Color::new(200, 200, 200, 255)

///|
pub let color_guard_patrol : @raylib.Color = @raylib.Color::new(50, 200, 50, 255)

///|
pub let color_guard_suspicious : @raylib.Color = @raylib.Color::new(255, 255, 50, 255)

///|
pub let color_guard_alert : @raylib.Color = @raylib.Color::new(255, 50, 50, 255)

///|
pub let color_vision_cone : @raylib.Color = @raylib.Color::new(255, 255, 100, 30)

///|
pub let color_vision_alert : @raylib.Color = @raylib.Color::new(255, 50, 50, 40)

///|
pub let color_hud_bg : @raylib.Color = @raylib.Color::new(0, 0, 0, 180)

///|
pub let color_hud_text : @raylib.Color = @raylib.Color::new(200, 220, 255, 255)

///|
pub let color_noise_ring : @raylib.Color = @raylib.Color::new(255, 255, 100, 60)

///|
pub let color_minimap_bg : @raylib.Color = @raylib.Color::new(0, 0, 0, 200)

///|
pub let color_cyan : @raylib.Color = @raylib.Color::new(0, 255, 255, 255)

///|
pub let color_neon_pink : @raylib.Color = @raylib.Color::new(255, 0, 128, 255)

///|
pub let color_neon_green : @raylib.Color = @raylib.Color::new(0, 255, 80, 255)

///|
pub let color_dim_text : @raylib.Color = @raylib.Color::new(120, 130, 150, 255)

///|
pub let color_white : @raylib.Color = @raylib.Color::new(255, 255, 255, 255)

///|
pub let color_grade_s : @raylib.Color = @raylib.Color::new(255, 215, 0, 255)

///|
pub let color_grade_a : @raylib.Color = @raylib.Color::new(0, 255, 100, 255)

///|
pub let color_grade_b : @raylib.Color = @raylib.Color::new(100, 180, 255, 255)

///|
pub let color_grade_c : @raylib.Color = @raylib.Color::new(180, 180, 180, 255)

///|
pub let color_coin : @raylib.Color = @raylib.Color::new(255, 220, 50, 255)

///|
pub let color_start : @raylib.Color = @raylib.Color::new(0, 200, 200, 255)
