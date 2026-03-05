// Screen

///|
/// Window width in pixels.
pub let screen_width : Int = 1024

///|
/// Window height in pixels.
pub let screen_height : Int = 768

// Game states

// Ship classes

// Ship class stats: (max_hull, max_mast_hp, max_rudder_hp, max_crew, cannon_count, base_speed, turn_rate, ship_length, ship_width)
// Sloop: fast, light, small crew

///|
/// Sloop: fast, light, small crew setting for sloop max hull.
pub let sloop_max_hull : Float = 60.0

///|
/// Sloop: fast, light, small crew setting for sloop max mast.
pub let sloop_max_mast : Float = 50.0

///|
/// Sloop: fast, light, small crew setting for sloop max rudder.
pub let sloop_max_rudder : Float = 45.0

///|
/// Crew-related value for sloop max crew.
pub let sloop_max_crew : Int = 20

///|
/// Count limit or quantity for sloop cannon count.
pub let sloop_cannon_count : Int = 4

///|
/// Speed value for sloop base speed in world units per second.
pub let sloop_base_speed : Float = 10.0

///|
/// Rate value for sloop turn rate.
pub let sloop_turn_rate : Float = 1.8

///|
/// Size or distance value for sloop length in world units.
pub let sloop_length : Float = 3.0

///|
/// Size or distance value for sloop width in world units.
pub let sloop_width : Float = 1.2

// Brigantine: balanced

///|
/// Brigantine: balanced setting for brigantine max hull.
pub let brigantine_max_hull : Float = 85.0

///|
/// Brigantine: balanced setting for brigantine max mast.
pub let brigantine_max_mast : Float = 70.0

///|
/// Brigantine: balanced setting for brigantine max rudder.
pub let brigantine_max_rudder : Float = 60.0

///|
/// Crew-related value for brigantine max crew.
pub let brigantine_max_crew : Int = 40

///|
/// Count limit or quantity for brigantine cannon count.
pub let brigantine_cannon_count : Int = 8

///|
/// Speed value for brigantine base speed in world units per second.
pub let brigantine_base_speed : Float = 8.0

///|
/// Rate value for brigantine turn rate.
pub let brigantine_turn_rate : Float = 1.4

///|
/// Size or distance value for brigantine length in world units.
pub let brigantine_length : Float = 4.0

///|
/// Size or distance value for brigantine width in world units.
pub let brigantine_width : Float = 1.6

// Frigate: strong, moderate

///|
/// Frigate: strong, moderate setting for frigate max hull.
pub let frigate_max_hull : Float = 120.0

///|
/// Frigate: strong, moderate setting for frigate max mast.
pub let frigate_max_mast : Float = 90.0

///|
/// Frigate: strong, moderate setting for frigate max rudder.
pub let frigate_max_rudder : Float = 75.0

///|
/// Crew-related value for frigate max crew.
pub let frigate_max_crew : Int = 80

///|
/// Count limit or quantity for frigate cannon count.
pub let frigate_cannon_count : Int = 16

///|
/// Speed value for frigate base speed in world units per second.
pub let frigate_base_speed : Float = 7.0

///|
/// Rate value for frigate turn rate.
pub let frigate_turn_rate : Float = 1.2

///|
/// Size or distance value for frigate length in world units.
pub let frigate_length : Float = 5.0

///|
/// Size or distance value for frigate width in world units.
pub let frigate_width : Float = 2.0

// Galleon: heavy, slow, powerful

///|
/// Galleon: heavy, slow, powerful setting for galleon max hull.
pub let galleon_max_hull : Float = 160.0

///|
/// Galleon: heavy, slow, powerful setting for galleon max mast.
pub let galleon_max_mast : Float = 110.0

///|
/// Galleon: heavy, slow, powerful setting for galleon max rudder.
pub let galleon_max_rudder : Float = 90.0

///|
/// Crew-related value for galleon max crew.
pub let galleon_max_crew : Int = 120

///|
/// Count limit or quantity for galleon cannon count.
pub let galleon_cannon_count : Int = 20

///|
/// Speed value for galleon base speed in world units per second.
pub let galleon_base_speed : Float = 5.5

///|
/// Rate value for galleon turn rate.
pub let galleon_turn_rate : Float = 0.9

///|
/// Size or distance value for galleon length in world units.
pub let galleon_length : Float = 6.5

///|
/// Size or distance value for galleon width in world units.
pub let galleon_width : Float = 2.4

// Man-of-War: massive fortress

///|
/// Man-of-War: massive fortress setting for mow max hull.
pub let mow_max_hull : Float = 220.0

///|
/// Man-of-War: massive fortress setting for mow max mast.
pub let mow_max_mast : Float = 140.0

///|
/// Man-of-War: massive fortress setting for mow max rudder.
pub let mow_max_rudder : Float = 110.0

///|
/// Crew-related value for mow max crew.
pub let mow_max_crew : Int = 200

///|
/// Count limit or quantity for mow cannon count.
pub let mow_cannon_count : Int = 30

///|
/// Speed value for mow base speed in world units per second.
pub let mow_base_speed : Float = 4.5

///|
/// Rate value for mow turn rate.
pub let mow_turn_rate : Float = 0.7

///|
/// Size or distance value for mow length in world units.
pub let mow_length : Float = 8.0

///|
/// Size or distance value for mow width in world units.
pub let mow_width : Float = 3.0

// Cannon types

// Cannon stats: damage, range, reload_time, speed, arc

///|
/// Damage value for light cannon damage.
pub let light_cannon_damage : Float = 8.0

///|
/// Speed value for light cannon speed in world units per second.
pub let light_cannon_speed : Float = 32.0

///|
/// Cannon stats: damage, range, reload_time, speed, arc setting for light cannon arc.
pub let light_cannon_arc : Float = 4.0

///|
/// Damage value for medium cannon damage.
pub let medium_cannon_damage : Float = 14.0

///|
/// Speed value for medium cannon speed in world units per second.
pub let medium_cannon_speed : Float = 30.0

///|
/// Cannon stats: damage, range, reload_time, speed, arc setting for medium cannon arc.
pub let medium_cannon_arc : Float = 5.0

///|
/// Damage value for heavy cannon damage.
pub let heavy_cannon_damage : Float = 22.0

///|
/// Speed value for heavy cannon speed in world units per second.
pub let heavy_cannon_speed : Float = 28.0

///|
/// Cannon stats: damage, range, reload_time, speed, arc setting for heavy cannon arc.
pub let heavy_cannon_arc : Float = 6.0

///|
/// Damage value for mortar damage.
pub let mortar_damage : Float = 30.0

///|
/// Speed value for mortar speed in world units per second.
pub let mortar_speed : Float = 20.0

///|
/// Cannon stats: damage, range, reload_time, speed, arc setting for mortar arc.
pub let mortar_arc : Float = 12.0

///|
/// Damage value for chain shot damage.
pub let chain_shot_damage : Float = 5.0

///|
/// Speed value for chain shot speed in world units per second.
pub let chain_shot_speed : Float = 25.0

///|
/// Cannon stats: damage, range, reload_time, speed, arc setting for chain shot arc.
pub let chain_shot_arc : Float = 3.0

// Ammo types

///|
/// Numeric id for round shot.
pub let ammo_round_shot : Int = 0

///|
/// Numeric id for chain shot.
pub let ammo_chain_shot : Int = 1

///|
/// Numeric id for grapeshot.
pub let ammo_grapeshot : Int = 2

// Ammo multipliers

///|
/// Multiplier used for round shot hull mult.
pub let round_shot_hull_mult : Float = 1.0

///|
/// Multiplier used for round shot mast mult.
pub let round_shot_mast_mult : Float = 0.3

///|
/// Crew-related value for round shot crew mult.
pub let round_shot_crew_mult : Float = 0.1

///|
/// Multiplier used for chain shot hull mult.
pub let chain_shot_hull_mult : Float = 0.2

///|
/// Multiplier used for chain shot mast mult.
pub let chain_shot_mast_mult : Float = 1.5

///|
/// Crew-related value for chain shot crew mult.
pub let chain_shot_crew_mult : Float = 0.1

///|
/// Multiplier used for grapeshot hull mult.
pub let grapeshot_hull_mult : Float = 0.1

///|
/// Multiplier used for grapeshot mast mult.
pub let grapeshot_mast_mult : Float = 0.1

///|
/// Crew-related value for grapeshot crew mult.
pub let grapeshot_crew_mult : Float = 2.0

// Wind system

///|
/// Speed value for wind speed calm in world units per second.
pub let wind_speed_calm : Float = 0.2

///|
/// Speed value for wind speed light in world units per second.
pub let wind_speed_light : Float = 0.5

///|
/// Speed value for wind speed moderate in world units per second.
pub let wind_speed_moderate : Float = 1.0

///|
/// Speed value for wind speed strong in world units per second.
pub let wind_speed_strong : Float = 1.5

///|
/// Speed value for wind speed gale in world units per second.
pub let wind_speed_gale : Float = 2.0

///|
/// Wind system setting for wind gust frequency.
pub let wind_gust_frequency : Float = 8.0

///|
/// Time value for wind gust duration in seconds.
pub let wind_gust_duration : Float = 2.0

///|
/// Wind system setting for wind gust strength.
pub let wind_gust_strength : Float = 0.5

///|
/// Speed value for wind shift speed in world units per second.
pub let wind_shift_speed : Float = 0.03

// Sailing physics - point of sail coefficients
// Relative wind angle -> speed multiplier

///|
/// Relative wind angle -> speed multiplier setting for sail in irons.
pub let sail_in_irons : Float = 0.05

///|
/// Relative wind angle -> speed multiplier setting for sail close haul.
pub let sail_close_haul : Float = 0.45

///|
/// Relative wind angle -> speed multiplier setting for sail beam reach.
pub let sail_beam_reach : Float = 0.85

///|
/// Relative wind angle -> speed multiplier setting for sail broad reach.
pub let sail_broad_reach : Float = 1.0

///|
/// Relative wind angle -> speed multiplier setting for sail running.
pub let sail_running : Float = 0.75

// In-irons zone: within this angle of dead upwind

///|
/// In-irons zone: within this angle of dead upwind setting for in irons angle.
pub let in_irons_angle : Float = 0.35
// Close haul zone

///|
/// Close haul zone setting for close haul angle.
pub let close_haul_angle : Float = 1.0
// Beam reach zone

///|
/// Beam reach zone setting for beam reach angle.
pub let beam_reach_angle : Float = 1.8
// Broad reach zone

///|
/// Broad reach zone setting for broad reach angle.
pub let broad_reach_angle : Float = 2.5

// Sail states

// Sail state speed multipliers

///|
/// Multiplier used for sail furled mult.
pub let sail_furled_mult : Float = 0.05

///|
/// Multiplier used for sail half mult.
pub let sail_half_mult : Float = 0.5

///|
/// Multiplier used for sail full mult.
pub let sail_full_mult : Float = 1.0

// Ship damage zones

// Repair speeds per damage type (HP per second per crew member assigned)

///|
/// Speed value for repair hull speed in world units per second.
pub let repair_hull_speed : Float = 0.8

///|
/// Speed value for repair mast speed in world units per second.
pub let repair_mast_speed : Float = 0.5

///|
/// Speed value for repair rudder speed in world units per second.
pub let repair_rudder_speed : Float = 0.6

// Crew action modes

///|
/// Numeric id for cannons.
pub let crew_action_cannons : Int = 1

///|
/// Numeric id for repair hull.
pub let crew_action_repair_hull : Int = 2

///|
/// Numeric id for repair mast.
pub let crew_action_repair_mast : Int = 3

///|
/// Numeric id for repair rudder.
pub let crew_action_repair_rudder : Int = 4

// AI captain personality types

// Enemy AI states

// Battle objective types

///|
/// Numeric id for destroy all.
pub let objective_destroy_all : Int = 0

///|
/// Numeric id for escort convoy.
pub let objective_escort_convoy : Int = 3

///|
/// Numeric id for blockade run.
pub let objective_blockade_run : Int = 4

// Island types

// Pool sizes

///|
/// Count limit or quantity for max enemies.
pub let max_enemies : Int = 16

///|
/// Count limit or quantity for max cannonballs.
pub let max_cannonballs : Int = 192

///|
/// Count limit or quantity for max particles.
pub let max_particles : Int = 640

///|
/// Count limit or quantity for max islands.
pub let max_islands : Int = 32

///|
/// Count limit or quantity for max wakes.
pub let max_wakes : Int = 256

///|
/// Count limit or quantity for max debris.
pub let max_debris : Int = 128

///|
/// Count limit or quantity for max messages.
pub let max_messages : Int = 8

// Camera

///|
/// Field-of-view value for camera fovy in degrees.
pub let camera_fovy : Float = 50.0

///|
/// Size or distance value for camera dist in world units.
pub let camera_dist : Float = 18.0

///|
/// Size or distance value for camera height in world units.
pub let camera_height : Float = 10.0

///|
/// Size or distance value for camera dist min in world units.
pub let camera_dist_min : Float = 10.0

///|
/// Size or distance value for camera dist max in world units.
pub let camera_dist_max : Float = 30.0

// Physics

///|
/// Gravity acceleration for gravity in world units per second squared.
pub let gravity : Float = 9.8

///|
/// Speed value for cannonball speed in world units per second.
pub let cannonball_speed : Float = 30.0

///|
/// Physics setting for cannonball life.
pub let cannonball_life : Float = 4.0

///|
/// Physics setting for drift factor.
pub let drift_factor : Float = 0.3

// Player ship defaults (frigate class)

///|
/// Hit-point value for player max hp.
pub let player_max_hp : Float = 120.0

///|
/// Player ship defaults (frigate class) setting for player max sail.
pub let player_max_sail : Float = 8.0

///|
/// Player ship defaults (frigate class) setting for player cannon reload.
pub let player_cannon_reload : Float = 1.0

///|
/// Damage value for player cannon damage.
pub let player_cannon_damage : Float = 15.0

///|
/// Crew-related value for player start crew.
pub let player_start_crew : Int = 80

///|
/// Player ship defaults (frigate class) setting for player start ammo.
pub let player_start_ammo : Int = 60

// Boarding combat

///|
/// Size or distance value for boarding range in world units.
pub let boarding_range : Float = 3.5

///|
/// Crew-related value for boarding crew power.
pub let boarding_crew_power : Float = 1.0

///|
/// Time value for boarding duration in seconds.
pub let boarding_duration : Float = 5.0

// Fortress constants

///|
/// Hit-point value for fortress base hp.
pub let fortress_base_hp : Float = 200.0

///|
/// Count limit or quantity for fortress cannon count.
pub let fortress_cannon_count : Int = 6

///|
/// Rate value for fortress fire rate.
pub let fortress_fire_rate : Float = 3.0

///|
/// Damage value for fortress cannon damage.
pub let fortress_cannon_damage : Float = 18.0

///|
/// Size or distance value for fortress range in world units.
pub let fortress_range : Float = 50.0

// Wind

///|
/// Wind setting for wind strength.
pub let wind_strength : Float = 1.0

// Ocean

///|
/// Size or distance value for ocean size in world units.
pub let ocean_size : Float = 200.0

// Wave parameters

///|
/// Wave parameters setting for wave amplitude.
pub let wave_amplitude : Float = 0.3

///|
/// Wave parameters setting for wave frequency.
pub let wave_frequency : Float = 0.15

///|
/// Speed value for wave speed in world units per second.
pub let wave_speed : Float = 1.5

// Pi

///|
/// Mathematical constant pi in radians.
pub let pi : Float = 3.14159

///|
/// Full-turn angle constant in radians.
pub let two_pi : Float = 6.28318

// Minimap

// Score multipliers

///|
/// Scoring or progression value for score fortress kill.
pub let score_fortress_kill : Int = 500

// Reputation thresholds

// Water wake parameters

///|
/// Time value for wake lifetime in seconds.
pub let wake_lifetime : Float = 2.5

///|
/// Speed value for wake min speed in world units per second.
pub let wake_min_speed : Float = 1.0

// Debris parameters

///|
/// Time value for debris lifetime in seconds.
pub let debris_lifetime : Float = 8.0

///|
/// Speed value for debris sink speed in world units per second.
pub let debris_sink_speed : Float = 0.3

// Message display

///|
/// Time value for message display time in seconds.
pub let message_display_time : Float = 3.0

// Battle timer (for survive objectives)

///|
/// Time value for survive time default in seconds.
pub let survive_time_default : Float = 120.0

// Convoy speed

///|
/// Speed value for convoy speed in world units per second.
pub let convoy_speed : Float = 2.0

///|
/// Size or distance value for convoy spacing in world units.
pub let convoy_spacing : Float = 8.0

// Fleet command distance

///|
/// Size or distance value for fleet follow dist in world units.
pub let fleet_follow_dist : Float = 15.0

///|
/// AI behavior state.
pub(all) enum AiState {
  Patrol
  Chase
  Attack
  Retreat
  Flank
  BroadsideRun
} derive(Eq)

///|
/// AI personality type.
pub(all) enum AiPersonality {
  Aggressive
  Defensive
  Flanker
  Retreater
  Berserker
} derive(Eq)

///|
/// Cannon type.
pub(all) enum Cannon {
  Light
  Medium
  Heavy
  Mortar
  ChainShot
} derive(Eq)

///|
/// Ship class.
pub(all) enum ShipClass {
  Sloop
  Brigantine
  Frigate
  Galleon
  ManOfWar
} derive(Eq)

///|
/// Island variant.
pub(all) enum IslandKind {
  Small
  Medium
  Large
  Fortress
} derive(Eq)

///|
/// Sail configuration.
pub(all) enum Sail {
  Furled
  Half
  Full
} derive(Eq)

///|
/// Current game state.
pub(all) enum GameState {
  Menu
  Playing
  Paused
  BattleComplete
  GameOver
  BattleSelect
} derive(Eq)
