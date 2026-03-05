///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1366

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 768

///|
/// Target frame rate used by the main loop.
pub let target_fps : Int = 120

///|
/// Gameplay tuning constant for chamber count.
pub let chamber_count : Int = 3

///|
/// Gameplay tuning constant for vault room.
pub let vault_room : Int = 1

///|
/// World layout coordinate for chamber left.
pub let chamber_left : Float = 184.0

///|
/// World layout coordinate for chamber top.
pub let chamber_top : Float = 132.0

///|
/// Gameplay tuning constant for chamber w.
pub let chamber_w : Float = 998.0

///|
/// Gameplay tuning constant for chamber h.
pub let chamber_h : Float = 554.0

///|
/// World layout coordinate for door center y.
pub let door_center_y : Float = chamber_top + chamber_h * 0.56

///|
/// Gameplay tuning constant for door half h.
pub let door_half_h : Float = 78.0

///|
/// Spatial tuning constant for keeper radius.
pub let keeper_radius : Float = 18.0

///|
/// Movement or scaling coefficient for keeper speed.
pub let keeper_speed : Float = 270.0

///|
/// Gameplay tuning constant for keeper mode speed scale.
pub let keeper_mode_speed_scale : Float = 0.76

///|
/// Gameplay tuning constant for keeper action cd.
pub let keeper_action_cd : Float = 0.20

///|
/// Maximum value configured for keeper stamina max.
pub let keeper_stamina_max : Float = 100.0

///|
/// Survival or damage balancing constant for keeper stamina regen.
pub let keeper_stamina_regen : Float = 24.0

///|
/// Survival or damage balancing constant for keeper stamina regen mode.
pub let keeper_stamina_regen_mode : Float = 12.0

///|
/// Gameplay tuning constant for stamina attack cost.
pub let stamina_attack_cost : Float = 13.0

///|
/// Gameplay tuning constant for stamina seal cost.
pub let stamina_seal_cost : Float = 20.0

///|
/// Gameplay tuning constant for stamina extinguish cost.
pub let stamina_extinguish_cost : Float = 16.0

///|
/// Spatial tuning constant for attack range.
pub let attack_range : Float = 82.0

///|
/// Survival or damage balancing constant for attack damage.
pub let attack_damage : Float = 50.0

///|
/// Survival or damage balancing constant for attack damage wave bonus.
pub let attack_damage_wave_bonus : Float = 1.6

///|
/// Spatial tuning constant for extinguisher range.
pub let extinguisher_range : Float = 118.0

///|
/// Gameplay tuning constant for extinguisher power.
pub let extinguisher_power : Float = 62.0

///|
/// Survival or damage balancing constant for ink shield stock start.
pub let ink_shield_stock_start : Float = 2.0

///|
/// Maximum value configured for ink shield stock max.
pub let ink_shield_stock_max : Float = 3.0

///|
/// Timing constant that controls ink shield cooldown.
pub let ink_shield_cooldown : Float = 7.5

///|
/// Timing constant that controls ink shield duration.
pub let ink_shield_duration : Float = 2.2

///|
/// Spatial tuning constant for ink shield radius.
pub let ink_shield_radius : Float = 176.0

///|
/// Survival or damage balancing constant for ink shield damage.
pub let ink_shield_damage : Float = 82.0

///|
/// Survival or damage balancing constant for ink shield fire quench.
pub let ink_shield_fire_quench : Float = 72.0

///|
/// Survival or damage balancing constant for ink shield integrity block.
pub let ink_shield_integrity_block : Float = 0.55

///|
/// Maximum value configured for scroll integrity max.
pub let scroll_integrity_max : Float = 100.0

///|
/// Gameplay tuning constant for seal charges start.
pub let seal_charges_start : Int = 4

///|
/// Per-step progression tuning for seal charges wave gain.
pub let seal_charges_wave_gain : Int = 1

///|
/// Maximum value configured for seal charges max.
pub let seal_charges_max : Int = 7

///|
/// Maximum value configured for breach severity max.
pub let breach_severity_max : Float = 100.0

///|
/// Base value before difficulty or progression scaling for breach event cd base.
pub let breach_event_cd_base : Float = 4.1

///|
/// Minimum or floor value used for breach event cd floor.
pub let breach_event_cd_floor : Float = 1.2

///|
/// Progression and scoring constant for breach wave growth.
pub let breach_wave_growth : Float = 0.24

///|
/// Survival or damage balancing constant for breach integrity drain.
pub let breach_integrity_drain : Float = 5.4

///|
/// Gameplay tuning constant for breach seal power.
pub let breach_seal_power : Float = 42.0

///|
/// Progression and scoring constant for breach seal wave bonus.
pub let breach_seal_wave_bonus : Float = 2.2

///|
/// Spatial tuning constant for raider radius.
pub let raider_radius : Float = 14.0

///|
/// Base value before difficulty or progression scaling for raider hp base.
pub let raider_hp_base : Float = 82.0

///|
/// Survival or damage balancing constant for raider hp wave bonus.
pub let raider_hp_wave_bonus : Float = 8.4

///|
/// Base value before difficulty or progression scaling for raider speed base.
pub let raider_speed_base : Float = 78.0

///|
/// Progression and scoring constant for raider speed wave bonus.
pub let raider_speed_wave_bonus : Float = 5.6

///|
/// Base value before difficulty or progression scaling for raider spawn cd base.
pub let raider_spawn_cd_base : Float = 2.2

///|
/// Minimum or floor value used for raider spawn cd floor.
pub let raider_spawn_cd_floor : Float = 0.68

///|
/// Gameplay tuning constant for raider vault strike.
pub let raider_vault_strike : Float = 6.5

///|
/// Survival or damage balancing constant for raider keeper stamina hit.
pub let raider_keeper_stamina_hit : Float = 10.5

///|
/// Base value before difficulty or progression scaling for flame spawn cd base.
pub let flame_spawn_cd_base : Float = 2.8

///|
/// Minimum or floor value used for flame spawn cd floor.
pub let flame_spawn_cd_floor : Float = 0.9

///|
/// Base value before difficulty or progression scaling for flame spread cd base.
pub let flame_spread_cd_base : Float = 3.2

///|
/// Minimum or floor value used for flame spread cd floor.
pub let flame_spread_cd_floor : Float = 1.0

///|
/// Per-step progression tuning for flame decay.
pub let flame_decay : Float = 1.2

///|
/// Gameplay tuning constant for flame breach feed.
pub let flame_breach_feed : Float = 0.11

///|
/// Survival or damage balancing constant for flame integrity side mul.
pub let flame_integrity_side_mul : Float = 0.030

///|
/// Survival or damage balancing constant for flame integrity vault mul.
pub let flame_integrity_vault_mul : Float = 0.064

///|
/// Base value before difficulty or progression scaling for wave duration base.
pub let wave_duration_base : Float = 28.0

///|
/// Per-step progression tuning for wave duration step.
pub let wave_duration_step : Float = 3.8

///|
/// Upper bound for max raiders in gameplay systems.
pub let max_raiders : Int = 160

///|
/// Upper bound for max flames in gameplay systems.
pub let max_flames : Int = 220
