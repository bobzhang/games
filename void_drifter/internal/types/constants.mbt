///|
pub let screen_width : Int = 1280

///|
pub let screen_height : Int = 720

///|
pub let target_fps : Int = 60

///|
pub let arena_default_width : Float = 2400.0

///|
pub let arena_default_height : Float = 1800.0

// Ship physics

///|
pub let ship_base_speed : Float = 280.0

///|
pub let ship_drag : Float = 0.92

///|
pub let ship_boost_mult : Float = 1.8

///|
pub let ship_boost_heat : Float = 15.0

///|
pub let ship_base_hp : Int = 5

///|
pub let ship_base_shield : Int = 3

///|
pub let shield_regen_delay : Float = 3.0

///|
pub let shield_regen_rate : Float = 1.0

///|
pub let dash_duration : Float = 0.15

///|
pub let dash_cooldown : Float = 0.8

///|
pub let dash_speed : Float = 800.0

///|
pub let invincible_duration : Float = 0.5

// Heat system

///|
pub let max_heat : Float = 100.0

///|
pub let heat_decay_rate : Float = 25.0

///|
pub let overheat_penalty : Float = 2.0

///|
pub let heat_sink_bonus : Float = 1.5

// Projectile defaults

///|
pub let projectile_pool_size : Int = 256

///|
pub let default_projectile_radius : Float = 4.0

///|
pub let default_projectile_lifetime : Float = 2.0

// Enemy pool

///|
pub let enemy_pool_size : Int = 64

///|
pub let enemy_spawn_margin : Float = 100.0

// Particle pool

///|
pub let particle_pool_size : Int = 512

///|
pub let particle_default_life : Float = 0.8

// Asteroid pool

///|
pub let asteroid_pool_size : Int = 32

///|
pub let asteroid_base_hp : Int = 2

// Pickup

///|
pub let pickup_pool_size : Int = 16

///|
pub let pickup_lifetime : Float = 15.0

///|
pub let pickup_radius : Float = 12.0

// Damage numbers

///|
pub let damage_number_pool_size : Int = 32

///|
pub let damage_number_life : Float = 0.8

///|
pub let damage_number_speed : Float = 60.0

// Screen shake

///|
pub let shake_decay : Float = 0.88

///|
pub let shake_hit : Float = 4.0

///|
pub let shake_explosion : Float = 8.0

///|
pub let shake_boss_hit : Float = 6.0

// Scoring

///|
pub let combo_decay_time : Float = 2.0

///|
pub let combo_multiplier_per : Float = 0.1

// Wave spawning

///|
pub let wave_interval : Float = 4.0

///|
pub let base_wave_enemies : Int = 3

// Sector map

///|
pub let sector_map_layers : Int = 4

///|
pub let nodes_per_layer : Int = 3

// Shop

///|
pub let shop_heal_cost : Int = 30

///|
pub let shop_shield_cost : Int = 40

///|
pub let shop_mod_cost : Int = 80

///|
pub let shop_weapon_cost : Int = 100

// Boss intro

///|
pub let boss_intro_duration : Float = 2.0

// Colors - Neon aesthetic

///|
pub let color_bg : @raylib.Color = @raylib.Color::new(8, 8, 24, 255)

///|
pub let color_player : @raylib.Color = @raylib.Color::new(0, 255, 200, 255)

///|
pub let color_player_shield : @raylib.Color = @raylib.Color::new(
  80, 180, 255, 120,
)

///|
pub let color_laser : @raylib.Color = @raylib.Color::new(0, 255, 100, 255)

///|
pub let color_missile : @raylib.Color = @raylib.Color::new(255, 120, 0, 255)

///|
pub let color_railgun : @raylib.Color = @raylib.Color::new(200, 100, 255, 255)

///|
pub let color_flak : @raylib.Color = @raylib.Color::new(255, 255, 100, 255)

///|
pub let color_beam : @raylib.Color = @raylib.Color::new(255, 50, 50, 255)

///|
pub let color_shotgun : @raylib.Color = @raylib.Color::new(255, 200, 50, 255)

///|
pub let color_enemy_drone : @raylib.Color = @raylib.Color::new(255, 60, 60, 255)

///|
pub let color_enemy_fighter : @raylib.Color = @raylib.Color::new(
  255, 100, 40, 255,
)

///|
pub let color_enemy_kiter : @raylib.Color = @raylib.Color::new(
  200, 60, 200, 255,
)

///|
pub let color_enemy_swarm : @raylib.Color = @raylib.Color::new(255, 180, 0, 255)

///|
pub let color_enemy_turret : @raylib.Color = @raylib.Color::new(
  150, 150, 255, 255,
)

///|
pub let color_enemy_carrier : @raylib.Color = @raylib.Color::new(
  100, 255, 100, 255,
)

///|
pub let color_enemy_bomber : @raylib.Color = @raylib.Color::new(
  255, 50, 150, 255,
)

///|
pub let color_enemy_shield : @raylib.Color = @raylib.Color::new(
  80, 200, 255, 255,
)

///|
pub let color_boss : @raylib.Color = @raylib.Color::new(255, 0, 80, 255)

///|
pub let color_asteroid : @raylib.Color = @raylib.Color::new(120, 100, 80, 255)

///|
pub let color_pickup : @raylib.Color = @raylib.Color::new(50, 255, 150, 255)

///|
pub let color_credits : @raylib.Color = @raylib.Color::new(255, 215, 0, 255)

///|
pub let color_heat_bar : @raylib.Color = @raylib.Color::new(255, 100, 30, 255)

///|
pub let color_hud_bg : @raylib.Color = @raylib.Color::new(0, 0, 0, 150)

///|
pub let color_hud_text : @raylib.Color = @raylib.Color::new(200, 220, 255, 255)

///|
pub let color_grid : @raylib.Color = @raylib.Color::new(20, 25, 50, 255)
