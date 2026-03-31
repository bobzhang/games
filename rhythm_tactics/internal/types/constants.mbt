///|
pub let screen_w : Int = 960

///|
pub let screen_h : Int = 720

///|
pub let grid_w : Int = 10

///|
pub let grid_h : Int = 10

///|
pub let tile_size : Int = 48

///|
pub let grid_offset_x : Int = 240

///|
pub let grid_offset_y : Int = 60

///|
pub let default_bpm : Float = 120.0

///|
pub let beat_window_perfect : Float = 0.08

///|
pub let beat_window_good : Float = 0.15

///|
pub let max_combo : Int = 99

///|
pub let combo_damage_bonus : Float = 0.1

///|
pub let color_perfect : @raylib.Color = @raylib.Color::new(255, 215, 0, 255)

///|
pub let color_good : @raylib.Color = @raylib.Color::new(100, 200, 255, 255)

///|
pub let color_miss : @raylib.Color = @raylib.Color::new(200, 60, 60, 255)

///|
pub let color_bg : @raylib.Color = @raylib.Color::new(18, 18, 30, 255)

///|
pub let color_grid_line : @raylib.Color = @raylib.Color::new(40, 40, 65, 255)

///|
pub let color_wall : @raylib.Color = @raylib.Color::new(80, 80, 100, 255)

///|
pub let color_floor_base : @raylib.Color = @raylib.Color::new(30, 30, 50, 255)

///|
pub let color_exit : @raylib.Color = @raylib.Color::new(0, 200, 100, 255)

///|
pub let color_spike : @raylib.Color = @raylib.Color::new(200, 50, 50, 255)

///|
pub let color_ice : @raylib.Color = @raylib.Color::new(150, 220, 255, 255)

///|
pub let color_pit : @raylib.Color = @raylib.Color::new(10, 10, 15, 255)

///|
pub let color_player : @raylib.Color = @raylib.Color::new(80, 200, 255, 255)

///|
pub let color_enemy_base : @raylib.Color = @raylib.Color::new(255, 80, 80, 255)

///|
pub let color_hud_bg : @raylib.Color = @raylib.Color::new(20, 20, 35, 200)

///|
pub let color_gold : @raylib.Color = @raylib.Color::new(255, 215, 0, 255)

///|
pub let beat_indicator_y : Int = 660

///|
pub let beat_indicator_h : Int = 40

///|
pub let miss_damage : Int = 1

///|
pub let spike_damage : Int = 1

///|
pub let message_duration : Float = 1.5

///|
pub let max_enemies_per_floor : Int = 12

///|
pub let max_floor : Int = 20

// --- BPM Scaling ---

///|
pub let bpm_floor_1_3 : Float = 100.0

///|
pub let bpm_floor_4_6 : Float = 120.0

///|
pub let bpm_floor_7_9 : Float = 140.0

///|
pub let bpm_floor_10 : Float = 160.0

// --- Beat Window Scaling ---

///|
pub let perfect_window_early : Float = 0.10

///|
pub let perfect_window_late : Float = 0.06

///|
pub let good_window_early : Float = 0.18

///|
pub let good_window_late : Float = 0.10

// --- Shop Prices ---

///|
pub let price_health_potion : Int = 20

///|
pub let price_shield : Int = 30

///|
pub let price_weapon_upgrade : Int = 50

///|
pub let price_special_charge : Int = 25

///|
pub let price_beat_window : Int = 40

// --- Boss constants ---

///|
pub let boss_arena_size : Int = 8

///|
pub let beat_dragon_hp : Int = 30

///|
pub let rhythm_lich_hp : Int = 40

///|
pub let beat_dragon_damage : Int = 3

///|
pub let rhythm_lich_damage : Int = 2

///|
pub let boss_intro_duration : Float = 2.0

///|
pub let floor_transition_duration : Float = 1.5

// --- Particle constants ---

///|
pub let particle_count_death : Int = 12

///|
pub let particle_life : Float = 0.6

// --- Score constants ---

///|
pub let score_kill_base_mult : Int = 10

///|
pub let score_perfect_mult : Float = 3.0

///|
pub let score_good_mult : Float = 1.5

///|
pub let score_miss_mult : Float = 0.5

///|
pub let score_combo_bonus : Int = 5

///|
pub let score_floor_hp_mult : Int = 100

///|
pub let score_floor_gold_mult : Int = 10

///|
pub let grade_s_threshold : Int = 5000

///|
pub let grade_a_threshold : Int = 3000

///|
pub let grade_b_threshold : Int = 1500

// --- Item pickup gold amounts ---

///|
pub let item_gold_amount : Int = 15

///|
pub let speed_boost_duration : Int = 10

///|
pub let beat_freeze_duration : Int = 3

///|
pub let bomb_radius : Int = 1

///|
pub let color_lava : @raylib.Color = @raylib.Color::new(255, 80, 20, 255)

///|
pub let color_shop_bg : @raylib.Color = @raylib.Color::new(25, 20, 40, 255)

///|
pub let color_shop_highlight : @raylib.Color = @raylib.Color::new(60, 50, 90, 255)
