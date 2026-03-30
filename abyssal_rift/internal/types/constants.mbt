///|
pub let screen_w : Int = 1280

///|
pub let screen_h : Int = 800

///|
pub let tile_size : Int = 40

///|
pub let tile_sizef : Float = 40.0

///|
/// Player physics
pub let player_base_speed : Float = 280.0

///|
pub let player_accel : Float = 2400.0

///|
pub let player_decel : Float = 1800.0

///|
pub let player_max_speed : Float = 280.0

///|
/// Dash
pub let dash_speed : Float = 700.0

///|
pub let dash_duration : Float = 0.12

///|
pub let dash_cooldown : Float = 0.8

///|
/// Combat
pub let invuln_duration : Float = 0.5

///|
pub let hit_pause_duration : Float = 0.05

///|
pub let knockback_speed : Float = 400.0

///|
pub let knockback_duration : Float = 0.15

///|
pub let combo_window : Float = 0.6

///|
/// Shield
pub let shield_regen_delay : Float = 4.5

///|
pub let shield_regen_rate : Float = 6.0

///|
/// Camera
pub let camera_lerp_speed : Float = 8.0

///|
pub let camera_lead : Float = 30.0

///|
/// Pool sizes
pub let max_enemies : Int = 128

///|
pub let max_projectiles : Int = 256

///|
pub let max_items : Int = 64

///|
pub let max_particles : Int = 600

///|
pub let max_damage_nums : Int = 32

///|
/// Player hitbox
pub let player_radius : Float = 14.0

///|
/// Colors
pub let color_bg : @raylib.Color = @raylib.Color::new(20, 18, 24, 255)

///|
pub let color_wall : @raylib.Color = @raylib.Color::new(55, 50, 62, 255)

///|
pub let color_floor : @raylib.Color = @raylib.Color::new(38, 35, 45, 255)

///|
pub let color_floor_alt : @raylib.Color = @raylib.Color::new(42, 38, 48, 255)

///|
pub let color_player : @raylib.Color = @raylib.Color::new(100, 200, 255, 255)

///|
pub let color_player_shield : @raylib.Color = @raylib.Color::new(
  80, 160, 255, 120,
)

///|
pub let color_health : @raylib.Color = @raylib.Color::new(220, 50, 50, 255)

///|
pub let color_shield : @raylib.Color = @raylib.Color::new(80, 160, 255, 255)

///|
pub let color_gold_text : @raylib.Color = @raylib.Color::new(255, 215, 0, 255)

///|
pub let color_hud_bg : @raylib.Color = @raylib.Color::new(0, 0, 0, 160)

///|
pub let color_crit : @raylib.Color = @raylib.Color::new(255, 200, 50, 255)

///|
pub let color_damage : @raylib.Color = @raylib.Color::new(255, 80, 80, 255)

///|
pub let color_heal : @raylib.Color = @raylib.Color::new(80, 255, 80, 255)
