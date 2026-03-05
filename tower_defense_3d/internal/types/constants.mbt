// Screen

///|
/// Window width in pixels.
pub let screen_width : Int = 1024

///|
/// Window height in pixels.
pub let screen_height : Int = 768

// Map grid

///|
/// Map grid width in cells.
pub let map_w : Int = 20

///|
/// Map grid height in cells.
pub let map_h : Int = 15

///|
/// World-space size of each grid cell.
pub let cell_size : Float = 2.0

///|
/// Total number of cells in the map grid.
pub let map_total : Int = 300 // map_w * map_h

// Tile types

// Tower types (8 tower types)

// Tower costs (base cost for level 1)

///|
/// Base gold cost to build an arrow tower.
pub let cost_arrow : Int = 50

///|
/// Base gold cost to build a cannon tower.
pub let cost_cannon : Int = 100

///|
/// Base gold cost to build a frost tower.
pub let cost_frost : Int = 75

///|
/// Base gold cost to build a lightning tower.
pub let cost_lightning : Int = 150

///|
/// Base gold cost to build a flame tower.
pub let cost_flame : Int = 120

///|
/// Base gold cost to build a sniper tower.
pub let cost_sniper : Int = 200

///|
/// Base gold cost to build a splash tower.
pub let cost_splash : Int = 130

///|
/// Base gold cost to build a buff tower.
pub let cost_buff : Int = 175

// Tower ranges (base range)

///|
/// Base attack range for arrow towers.
pub let range_arrow : Float = 5.0

///|
/// Base attack range for cannon towers.
pub let range_cannon : Float = 4.5

///|
/// Base attack range for frost towers.
pub let range_frost : Float = 4.0

///|
/// Base attack range for lightning towers.
pub let range_lightning : Float = 6.0

///|
/// Base attack range for flame towers.
pub let range_flame : Float = 3.5

///|
/// Base attack range for sniper towers.
pub let range_sniper : Float = 9.0

///|
/// Base attack range for splash towers.
pub let range_splash : Float = 4.0

///|
/// Base buff range for support towers.
pub let range_buff : Float = 5.0

// Tower damage (base damage)

///|
/// Base damage per shot for arrow towers.
pub let dmg_arrow : Float = 10.0

///|
/// Base damage per shot for cannon towers.
pub let dmg_cannon : Float = 30.0

///|
/// Base damage per shot for frost towers.
pub let dmg_frost : Float = 5.0

///|
/// Base damage per shot for lightning towers.
pub let dmg_lightning : Float = 20.0

///|
/// Base damage per shot for flame towers.
pub let dmg_flame : Float = 15.0

///|
/// Base damage per shot for sniper towers.
pub let dmg_sniper : Float = 60.0

///|
/// Base damage per shot for splash towers.
pub let dmg_splash : Float = 18.0

///|
/// Base damage per shot for buff towers (zero since they only support).
pub let dmg_buff : Float = 0.0

// Tower fire rates (seconds between shots)

///|
/// Seconds between shots for arrow towers.
pub let rate_arrow : Float = 0.8

///|
/// Seconds between shots for cannon towers.
pub let rate_cannon : Float = 2.0

///|
/// Seconds between shots for frost towers.
pub let rate_frost : Float = 1.0

///|
/// Seconds between shots for lightning towers.
pub let rate_lightning : Float = 1.5

///|
/// Seconds between shots for flame towers.
pub let rate_flame : Float = 0.3

///|
/// Seconds between shots for sniper towers.
pub let rate_sniper : Float = 3.0

///|
/// Seconds between shots for splash towers.
pub let rate_splash : Float = 1.8

///|
/// Seconds between buff pulses for support towers.
pub let rate_buff : Float = 4.0

// Tower upgrade costs (level 2 and level 3)

///|
/// Cost multiplier for upgrading a tower to level 2.
pub let upgrade_cost_mult_2 : Float = 0.6

///|
/// Cost multiplier for upgrading a tower to level 3.
pub let upgrade_cost_mult_3 : Float = 1.0

// Tower upgrade stat multipliers per level

///|
/// Range increase fraction per tower upgrade level.
pub let upgrade_range_mult : Float = 0.12

///|
/// Damage increase fraction per tower upgrade level.
pub let upgrade_damage_mult : Float = 0.25

///|
/// Fire rate improvement fraction per tower upgrade level.
pub let upgrade_rate_mult : Float = 0.10

// Tower sell value (percentage of total investment)

///|
/// Percentage of total gold investment returned when selling a tower.
pub let sell_value_pct : Float = 0.6

// Targeting modes

///|
/// Total number of available targeting modes.
pub let target_mode_count : Int = 4

// Projectile types

// Projectile speeds

///|
/// Travel speed for arrow tower bullets.
pub let proj_speed_bullet : Float = 14.0

///|
/// Travel speed for cannon tower shells.
pub let proj_speed_cannonball : Float = 10.0

///|
/// Travel speed for frost tower ice shards.
pub let proj_speed_ice_shard : Float = 12.0

///|
/// Travel speed for lightning tower bolts.
pub let proj_speed_lightning : Float = 20.0

///|
/// Travel speed for flame tower fireballs.
pub let proj_speed_fireball : Float = 8.0

///|
/// Travel speed for sniper tower rounds.
pub let proj_speed_sniper : Float = 25.0

///|
/// Travel speed for splash tower bombs.
pub let proj_speed_splash : Float = 9.0

// Splash radii

///|
/// Area-of-effect blast radius for cannon projectiles.
pub let splash_radius_cannon : Float = 2.0

///|
/// Area-of-effect blast radius for splash tower bombs.
pub let splash_radius_splash : Float = 3.0

///|
/// Area-of-effect blast radius for flame tower fireballs.
pub let splash_radius_flame : Float = 1.5

// Status effect types

///|
/// Status effect type for no active effect.
pub let effect_none : Int = 0

// Status effect durations

///|
/// Duration in seconds of the slow debuff on enemies.
pub let slow_duration : Float = 2.5

///|
/// Duration in seconds of the burn damage-over-time effect.
pub let burn_duration : Float = 3.0

///|
/// Duration in seconds of the stun immobilization effect.
pub let stun_duration : Float = 1.0

// Status effect strengths

///|
/// Movement speed multiplier applied during slow (0.4 = 60% speed reduction).
pub let slow_strength : Float = 0.4

///|
/// Damage per second dealt by the burn status effect.
pub let burn_dps : Float = 5.0

// Lightning chain parameters

///|
/// Number of additional enemies hit by lightning chain bounces.
pub let chain_count : Int = 3

///|
/// Maximum distance a lightning chain can jump between enemies.
pub let chain_range : Float = 4.0

///|
/// Damage multiplier applied to each successive lightning chain bounce.
pub let chain_damage_decay : Float = 0.7

// Sniper crit parameters

///|
/// Probability that a sniper shot deals critical damage.
pub let sniper_crit_chance : Float = 0.25

///|
/// Damage multiplier applied on a sniper critical hit.
pub let sniper_crit_mult : Float = 2.5

// Buff tower parameters

///|
/// Damage bonus fraction applied to towers in buff range.
pub let buff_damage_bonus : Float = 0.25

///|
/// Range bonus fraction applied to towers in buff range.
pub let buff_range_bonus : Float = 0.15

///|
/// Fire rate bonus fraction applied to towers in buff range.
pub let buff_rate_bonus : Float = 0.10

// Enemy types (10+ enemy types)

// Enemy armor values (damage reduction flat amount)

///|
/// Flat damage reduction for basic enemies.
pub let armor_basic : Float = 0.0

///|
/// Flat damage reduction for fast enemies.
pub let armor_fast : Float = 0.0

///|
/// Flat damage reduction for tank enemies.
pub let armor_tank : Float = 5.0

///|
/// Flat damage reduction for flying enemies.
pub let armor_flying : Float = 0.0

///|
/// Flat damage reduction for boss enemies.
pub let armor_boss : Float = 8.0

///|
/// Flat damage reduction for healer enemies.
pub let armor_healer : Float = 1.0

///|
/// Flat damage reduction for swarm enemies.
pub let armor_swarm : Float = 0.0

///|
/// Flat damage reduction for shield enemies.
pub let armor_shield : Float = 10.0

///|
/// Flat damage reduction for camouflaged enemies.
pub let armor_camo : Float = 0.0

///|
/// Flat damage reduction for splitter enemies.
pub let armor_splitter : Float = 2.0

// Enemy resistance system: 0.0 = immune, 0.5 = resistant, 1.0 = normal, 1.5 = weak, 2.0 = very weak
// Indexed by [enemy_type][damage_source] where damage_source maps to tower types
// We'll use functions to look up resistance

// Healer parameters

///|
/// Radius within which healer enemies restore HP to allies.
pub let healer_range : Float = 4.0

///|
/// HP restored per heal tick by healer enemies.
pub let healer_heal_rate : Float = 8.0

///|
/// Seconds between healer enemy heal ticks.
pub let healer_heal_interval : Float = 1.5

// Splitter parameters

///|
/// Number of child enemies spawned when a splitter dies.
pub let splitter_children : Int = 3

///|
/// HP fraction of parent that each splitter child inherits.
pub let splitter_child_hp_pct : Float = 0.3

// Shield enemy parameters

///|
/// Seconds after taking damage before shield regeneration begins.
pub let shield_regen_delay : Float = 3.0

///|
/// Shield HP restored per second during regeneration.
pub let shield_regen_rate : Float = 5.0

///|
/// Maximum shield HP as a fraction of the enemy base HP.
pub let shield_max_pct : Float = 0.4

// Game states

// Pools

///|
/// Maximum number of towers that can exist simultaneously.
pub let max_towers : Int = 64

///|
/// Maximum number of enemies that can exist simultaneously.
pub let max_enemies : Int = 200

///|
/// Maximum number of projectiles that can exist simultaneously.
pub let max_projectiles : Int = 300

///|
/// Maximum number of visual particles that can exist simultaneously.
pub let max_particles : Int = 600

///|
/// Maximum number of waypoints in an enemy path.
pub let max_path_nodes : Int = 64

///|
/// Total number of enemy waves per game session.
pub let max_waves : Int = 30

// Camera

///|
/// Camera vertical field of view in degrees.
pub let camera_fovy : Float = 45.0

///|
/// Minimum camera distance when zoomed in.
pub let camera_min_dist : Float = 10.0

///|
/// Maximum camera distance when zoomed out.
pub let camera_max_dist : Float = 40.0

// Economy

///|
/// Gold amount the player starts with.
pub let starting_gold : Int = 250

///|
/// Number of lives the player starts with.
pub let starting_lives : Int = 25

///|
/// Fraction of current gold awarded as interest each interval.
pub let interest_rate : Float = 0.05

///|
/// Seconds between gold interest payouts.
pub let interest_interval : Float = 10.0

///|
/// Maximum gold gained from a single interest payout.
pub let interest_cap : Int = 50

///|
/// Bonus gold awarded for completing a wave.
pub let wave_completion_bonus : Int = 25

// Wave timing

///|
/// Seconds of preparation time before each wave begins.
pub let wave_prep_time : Float = 8.0

///|
/// Default seconds between spawning consecutive enemies.
pub let spawn_interval : Float = 0.8

///|
/// Reduced spawn interval for fast-arriving enemy waves.
pub let fast_spawn_interval : Float = 0.3

// Speed multiplier options

///|
/// Normal game speed multiplier.
pub let speed_1x : Float = 1.0

///|
/// Double game speed multiplier.
pub let speed_2x : Float = 2.0

///|
/// Triple game speed multiplier.
pub let speed_3x : Float = 3.0

// Difficulty multipliers

///|
/// Enemy HP multiplier on easy difficulty.
pub let difficulty_easy_hp : Float = 0.7

///|
/// Enemy speed multiplier on easy difficulty.
pub let difficulty_easy_speed : Float = 0.9

///|
/// Enemy HP multiplier on normal difficulty.
pub let difficulty_normal_hp : Float = 1.0

///|
/// Enemy speed multiplier on normal difficulty.
pub let difficulty_normal_speed : Float = 1.0

///|
/// Enemy HP multiplier on hard difficulty.
pub let difficulty_hard_hp : Float = 1.4

///|
/// Enemy speed multiplier on hard difficulty.
pub let difficulty_hard_speed : Float = 1.15

// Map count

///|
/// Total number of available maps.
pub let map_count : Int = 5

// Special ability cooldowns

///|
/// Cooldown in seconds for the flame aura special ability.
pub let ability_flame_aura_cd : Float = 3.0

///|
/// Cooldown in seconds for the buff pulse special ability.
pub let ability_buff_pulse_cd : Float = 12.0

// Visual constants

///|
/// Mathematical constant pi for angle calculations.
pub let pi : Float = 3.14159

///|
/// Width of the enemy health bar relative to enemy size.
pub let health_bar_width : Float = 1.2

///|
/// Height of the enemy health bar in world units.
pub let health_bar_height : Float = 0.08

///|
/// Side length of the minimap overlay in pixels.
pub let minimap_size : Int = 150

///|
/// Horizontal screen position of the minimap in pixels.
pub let minimap_x : Int = 10

///|
/// Vertical screen position of the minimap in pixels.
pub let minimap_y : Int = 60


///|
/// Enemy variant.
pub(all) enum EnemyKind {
  Basic
  Fast
  Tank
  Flying
  Boss
  Healer
  Swarm
  Shield
  Camo
  Splitter
} derive(Eq)

///|
/// Current game state.
pub(all) enum GameState {
  Menu
  Playing
  Paused
  WavePrep
  GameOver
  Victory
  Building
  MapSelect
  TowerInfo
} derive(Eq)

///|
/// Tower targeting priority.
pub(all) enum TargetPriority {
  First
  Last
  Strongest
  Closest
} derive(Eq)

///|
/// Map tile type.
pub(all) enum Tile {
  Grass
  Path
  Start
  End
  Water
  Rock
} derive(Eq)

///|
/// Tower variant.
pub(all) enum TowerKind {
  Arrow
  Cannon
  Frost
  Lightning
  Flame
  Sniper
  Splash
  Buff
} derive(Eq)
