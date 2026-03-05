///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1500

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 900

///|
/// Target frame rate used by the main loop.
pub let target_fps : Int = 120

///|
/// World layout coordinate for world x.
pub let world_x : Int = 44

///|
/// World layout coordinate for world y.
pub let world_y : Int = 48

///|
/// Gameplay tuning constant for world w.
pub let world_w : Int = 1040

///|
/// Gameplay tuning constant for world h.
pub let world_h : Int = 804

///|
/// World layout coordinate for hud x.
pub let hud_x : Int = world_x + world_w + 24

///|
/// World layout coordinate for hud y.
pub let hud_y : Int = world_y

///|
/// Gameplay tuning constant for hud w.
pub let hud_w : Int = 348

///|
/// Gameplay tuning constant for hud h.
pub let hud_h : Int = world_h

///|
/// Gameplay tuning constant for corridor lanes.
pub let corridor_lanes : Int = 3

///|
/// World layout coordinate for lane top y.
pub let lane_top_y : Int = world_y + 176

///|
/// World layout coordinate for lane mid y.
pub let lane_mid_y : Int = world_y + world_h / 2

///|
/// World layout coordinate for lane bottom y.
pub let lane_bottom_y : Int = world_y + world_h - 176

///|
/// Spatial tuning constant for player radius.
pub let player_radius : Float = 16.0

///|
/// Movement or scaling coefficient for player speed.
pub let player_speed : Float = 312.0

///|
/// Movement or scaling coefficient for dash speed.
pub let dash_speed : Float = 860.0

///|
/// Timing constant that controls dash time.
pub let dash_time : Float = 0.12

///|
/// Timing constant that controls dash cooldown.
pub let dash_cooldown : Float = 0.92

///|
/// Gameplay tuning constant for dash energy cost.
pub let dash_energy_cost : Float = 18.0

///|
/// Survival or damage balancing constant for basic attack damage.
pub let basic_attack_damage : Float = 34.0

///|
/// Spatial tuning constant for basic attack range.
pub let basic_attack_range : Float = 90.0

///|
/// Gameplay tuning constant for basic attack arc dot.
pub let basic_attack_arc_dot : Float = 0.28

///|
/// Gameplay tuning constant for basic attack energy cost.
pub let basic_attack_energy_cost : Float = 6.0

///|
/// Timing constant that controls basic attack cooldown.
pub let basic_attack_cooldown : Float = 0.22

///|
/// Timing constant that controls attack flash time.
pub let attack_flash_time : Float = 0.14

///|
/// Maximum value configured for energy max.
pub let energy_max : Float = 100.0

///|
/// Survival or damage balancing constant for energy regen.
pub let energy_regen : Float = 14.0

///|
/// Maximum value configured for sweep charge max.
pub let sweep_charge_max : Float = 100.0

///|
/// Gameplay tuning constant for sweep charge passive.
pub let sweep_charge_passive : Float = 3.8

///|
/// Survival or damage balancing constant for sweep charge hit.
pub let sweep_charge_hit : Float = 8.0

///|
/// Gameplay tuning constant for sweep charge kill.
pub let sweep_charge_kill : Float = 16.0

///|
/// Spatial tuning constant for sweep radius.
pub let sweep_radius : Float = 250.0

///|
/// Survival or damage balancing constant for sweep damage.
pub let sweep_damage : Float = 88.0

///|
/// Timing constant that controls sweep fx time.
pub let sweep_fx_time : Float = 0.34

///|
/// Visual tuning constant for trap slot cols.
pub let trap_slot_cols : Int = 6

///|
/// Gameplay tuning constant for trap slot rows.
pub let trap_slot_rows : Int = 3

///|
/// Gameplay tuning constant for trap slot count.
pub let trap_slot_count : Int = trap_slot_cols * trap_slot_rows

///|
/// Spatial tuning constant for trap place range.
pub let trap_place_range : Float = 46.0

///|
/// Gameplay tuning constant for trap place energy cost.
pub let trap_place_energy_cost : Float = 18.0

///|
/// Timing constant that controls trap place cooldown.
pub let trap_place_cooldown : Float = 0.46

///|
/// Spatial tuning constant for trap trigger radius.
pub let trap_trigger_radius : Float = 54.0

///|
/// Survival or damage balancing constant for trap damage.
pub let trap_damage : Float = 44.0

///|
/// Timing constant that controls trap rearm time.
pub let trap_rearm_time : Float = 1.18

///|
/// Timing constant that controls trap flash time.
pub let trap_flash_time : Float = 0.20

///|
/// Timing constant that controls trap slow time.
pub let trap_slow_time : Float = 1.10

///|
/// Movement or scaling coefficient for trap slow factor.
pub let trap_slow_factor : Float = 0.56

///|
/// Spatial tuning constant for trap remove range.
pub let trap_remove_range : Float = 56.0

///|
/// Gameplay tuning constant for trap remove refund.
pub let trap_remove_refund : Float = 8.0

///|
/// Gameplay tuning constant for beacon count.
pub let beacon_count : Int = 3

///|
/// Spatial tuning constant for beacon radius.
pub let beacon_radius : Float = 26.0

///|
/// Maximum value configured for beacon integrity max.
pub let beacon_integrity_max : Float = 140.0

///|
/// Upper bound for max enemies in gameplay systems.
pub let max_enemies : Int = 260

///|
/// Spatial tuning constant for enemy radius.
pub let enemy_radius : Float = 14.0

///|
/// Base value before difficulty or progression scaling for enemy hp base.
pub let enemy_hp_base : Float = 58.0

///|
/// Per-step progression tuning for enemy hp step.
pub let enemy_hp_step : Float = 6.4

///|
/// Base value before difficulty or progression scaling for enemy speed base.
pub let enemy_speed_base : Float = 92.0

///|
/// Per-step progression tuning for enemy speed step.
pub let enemy_speed_step : Float = 7.2

///|
/// Base value before difficulty or progression scaling for enemy damage base.
pub let enemy_damage_base : Float = 14.0

///|
/// Per-step progression tuning for enemy damage step.
pub let enemy_damage_step : Float = 1.5

///|
/// Base value before difficulty or progression scaling for night spawn base.
pub let night_spawn_base : Int = 10

///|
/// Per-step progression tuning for night spawn step.
pub let night_spawn_step : Int = 4

///|
/// Gameplay tuning constant for spawn interval start.
pub let spawn_interval_start : Float = 1.04

///|
/// Per-step progression tuning for spawn interval decay.
pub let spawn_interval_decay : Float = 0.06

///|
/// Minimum or floor value used for spawn interval floor.
pub let spawn_interval_floor : Float = 0.28

///|
/// Timing constant that controls night banner time.
pub let night_banner_time : Float = 1.35

///|
/// Progression and scoring constant for night clear energy bonus.
pub let night_clear_energy_bonus : Float = 20.0

///|
/// Progression and scoring constant for night clear charge bonus.
pub let night_clear_charge_bonus : Float = 22.0

///|
/// Base value before difficulty or progression scaling for score kill base.
pub let score_kill_base : Int = 40

///|
/// Progression and scoring constant for score night clear bonus.
pub let score_night_clear_bonus : Int = 220

///|
/// Gameplay tuning constant for status default t.
pub let status_default_t : Float = 1.4

///|
/// Timing constant that controls shake hit time.
pub let shake_hit_time : Float = 0.18
