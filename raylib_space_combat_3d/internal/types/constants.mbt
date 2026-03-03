// Screen

///|
/// Window width in pixels.
pub let screen_width : Int = 1280

///|
/// Window height in pixels.
pub let screen_height : Int = 720

// Game states

///|
/// Game state identifier for the main menu screen.
pub let state_menu : Int = 0

///|
/// Game state identifier for active gameplay.
pub let state_playing : Int = 1

///|
/// Game state identifier for the pause screen.
pub let state_paused : Int = 2

///|
/// Game state identifier for the mission complete summary.
pub let state_mission_complete : Int = 3

///|
/// Game state identifier for the game over screen.
pub let state_game_over : Int = 4

///|
/// Game state identifier for the pre-mission briefing screen.
pub let state_mission_briefing : Int = 5

///|
/// Game state identifier for the mission selection screen.
pub let state_mission_select : Int = 6

///|
/// Game state identifier for the ship loadout selection screen.
pub let state_loadout : Int = 7

// Ship classes

///|
/// Ship class identifier for the balanced fighter.
pub let ship_fighter : Int = 0

///|
/// Ship class identifier for the fast, fragile interceptor.
pub let ship_interceptor : Int = 1

///|
/// Ship class identifier for the slow, heavy bomber.
pub let ship_bomber : Int = 2

///|
/// Ship class identifier for the armored cruiser.
pub let ship_cruiser : Int = 3

///|
/// Ship class identifier for the massive capital ship.
pub let ship_capital_ship : Int = 4

// Weapon types

///|
/// Weapon type identifier for rapid-fire laser bolts.
pub let weapon_laser : Int = 0

///|
/// Weapon type identifier for homing missiles.
pub let weapon_missile : Int = 1

///|
/// Weapon type identifier for area-of-effect plasma shots.
pub let weapon_plasma : Int = 2

///|
/// Weapon type identifier for high-velocity piercing railgun rounds.
pub let weapon_railgun : Int = 3

// Enemy types

///|
/// Enemy type identifier for standard fighter craft.
pub let enemy_fighter : Int = 0

///|
/// Enemy type identifier for heavily armored cruiser.
pub let enemy_cruiser : Int = 1

///|
/// Enemy type identifier for fast interceptor craft.
pub let enemy_interceptor : Int = 3

///|
/// Enemy type identifier for slow heavy bomber.
pub let enemy_bomber : Int = 4

///|
/// Enemy type identifier for boss-class capital ship.
pub let enemy_capital : Int = 5

// Enemy AI states

///|
/// AI state for idle enemies awaiting activation.
pub let ai_idle : Int = 0

///|
/// AI state for patrolling toward a waypoint.
pub let ai_patrol : Int = 1

///|
/// AI state for pursuing the player.
pub let ai_chase : Int = 2

///|
/// AI state for actively engaging and firing at the player.
pub let ai_attack : Int = 3

///|
/// AI state for evasive jinking maneuvers when damaged.
pub let ai_evade : Int = 4

///|
/// AI state for fleeing when health is critically low.
pub let ai_flee : Int = 5

///|
/// AI state for holding squad formation position.
pub let ai_formation : Int = 6

// Power-up types

///|
/// Power-up type that restores hull integrity.
pub let powerup_health : Int = 0

///|
/// Power-up type that recharges shield energy.
pub let powerup_shield : Int = 1

///|
/// Power-up type that temporarily increases weapon damage.
pub let powerup_weapon_boost : Int = 2

///|
/// Power-up type that temporarily increases ship speed.
pub let powerup_speed_boost : Int = 3

// Asteroid size tiers

///|
/// Size tier for large breakable asteroids.
pub let asteroid_large : Int = 0

///|
/// Size tier for medium asteroids from breaking large ones.
pub let asteroid_medium : Int = 1

///|
/// Size tier for small non-breakable asteroid fragments.
pub let asteroid_small : Int = 2

// Formation patterns

///|
/// V-shaped formation pattern for enemy squads.
pub let formation_v : Int = 0

///|
/// Line-abreast formation pattern for enemy squads.
pub let formation_line : Int = 1

///|
/// Circular formation pattern for enemy squads.
pub let formation_circle : Int = 2

///|
/// Arrow-wedge formation pattern for enemy squads.
pub let formation_wedge : Int = 3

// Pool sizes

///|
/// Maximum number of concurrent enemy entities.
pub let max_enemies : Int = 64

///|
/// Maximum number of concurrent projectiles in flight.
pub let max_projectiles : Int = 128

///|
/// Maximum number of concurrent particle effects.
pub let max_particles : Int = 512

///|
/// Maximum number of concurrent asteroids in the field.
pub let max_asteroids : Int = 96

///|
/// Maximum number of background stars.
pub let max_stars : Int = 200

///|
/// Maximum number of concurrent power-up pickups.
pub let max_powerups : Int = 16

///|
/// Maximum number of concurrent space stations.
pub let max_stations : Int = 4

///|
/// Maximum number of concurrent debris fragments.
pub let max_debris : Int = 64

// Ship class stats: hull, shield, speed, turn_rate, boost_speed
// Fighter - balanced

///|
/// Fighter class maximum hull hit points.
pub let fighter_class_hull : Float = 100.0

///|
/// Fighter class maximum shield capacity.
pub let fighter_class_shield : Float = 80.0

///|
/// Fighter class base movement speed.
pub let fighter_class_speed : Float = 40.0

///|
/// Fighter class turn rate in radians per second.
pub let fighter_class_turn : Float = 2.5

///|
/// Fighter class afterburner boost speed.
pub let fighter_class_boost : Float = 70.0

// Interceptor - fast, fragile

///|
/// Interceptor class maximum hull hit points.
pub let interceptor_class_hull : Float = 70.0

///|
/// Interceptor class maximum shield capacity.
pub let interceptor_class_shield : Float = 50.0

///|
/// Interceptor class base movement speed.
pub let interceptor_class_speed : Float = 55.0

///|
/// Interceptor class turn rate in radians per second.
pub let interceptor_class_turn : Float = 3.5

///|
/// Interceptor class afterburner boost speed.
pub let interceptor_class_boost : Float = 90.0

// Bomber - slow, tough, high damage

///|
/// Bomber class maximum hull hit points.
pub let bomber_class_hull : Float = 150.0

///|
/// Bomber class maximum shield capacity.
pub let bomber_class_shield : Float = 100.0

///|
/// Bomber class base movement speed.
pub let bomber_class_speed : Float = 28.0

///|
/// Bomber class turn rate in radians per second.
pub let bomber_class_turn : Float = 1.5

///|
/// Bomber class afterburner boost speed.
pub let bomber_class_boost : Float = 45.0

// Cruiser class - for player

///|
/// Cruiser class maximum hull hit points.
pub let cruiser_class_hull : Float = 200.0

///|
/// Cruiser class maximum shield capacity.
pub let cruiser_class_shield : Float = 160.0

///|
/// Cruiser class base movement speed.
pub let cruiser_class_speed : Float = 22.0

///|
/// Cruiser class turn rate in radians per second.
pub let cruiser_class_turn : Float = 1.2

///|
/// Cruiser class afterburner boost speed.
pub let cruiser_class_boost : Float = 35.0

// Capital class - for player

///|
/// Capital ship class maximum hull hit points.
pub let capital_class_hull : Float = 350.0

///|
/// Capital ship class maximum shield capacity.
pub let capital_class_shield : Float = 250.0

///|
/// Capital ship class base movement speed.
pub let capital_class_speed : Float = 15.0

///|
/// Capital ship class turn rate in radians per second.
pub let capital_class_turn : Float = 0.8

///|
/// Capital ship class afterburner boost speed.
pub let capital_class_boost : Float = 22.0

// Player constants (default fighter)

///|
/// Default player hull hit points for the fighter class.
pub let player_max_hull : Float = 100.0

///|
/// Default player shield capacity for the fighter class.
pub let player_max_shield : Float = 80.0

///|
/// Shield regeneration rate in points per second.
pub let shield_regen_rate : Float = 3.0

///|
/// Delay in seconds before shield begins regenerating after taking damage.
pub let shield_regen_delay : Float = 2.5

///|
/// Default player forward movement speed.
pub let player_speed : Float = 40.0

///|
/// Default player yaw and pitch turn speed in radians per second.
pub let player_turn_speed : Float = 2.5

///|
/// Player barrel roll rotation speed in radians per second.
pub let player_roll_speed : Float = 3.0

// Weapon stats
// Laser: rapid fire, low damage, no ammo cost

///|
/// Laser bolt damage per hit.
pub let laser_damage : Float = 8.0

///|
/// Laser bolt travel speed in units per second.
pub let laser_speed : Float = 120.0

///|
/// Minimum seconds between laser shots.
pub let laser_cooldown : Float = 0.12

///|
/// Maximum effective range of laser bolts.
pub let laser_range : Float = 200.0

///|
/// Weapon energy consumed per laser shot.
pub let laser_energy_cost : Float = 2.0

// Plasma: medium fire, medium damage, energy cost

///|
/// Plasma shot damage on direct hit.
pub let plasma_damage : Float = 50.0

///|
/// Plasma projectile travel speed in units per second.
pub let plasma_speed : Float = 60.0

///|
/// Minimum seconds between plasma shots.
pub let plasma_cooldown : Float = 1.2

///|
/// Maximum effective range of plasma shots.
pub let plasma_range : Float = 150.0

///|
/// Weapon energy consumed per plasma shot.
pub let plasma_energy_cost : Float = 15.0

// Missile: slow fire, high damage, limited ammo, homing

///|
/// Missile damage on impact or proximity detonation.
pub let missile_damage : Float = 35.0

///|
/// Missile travel speed in units per second.
pub let missile_speed : Float = 50.0

///|
/// Minimum seconds between missile launches.
pub let missile_cooldown : Float = 0.8

///|
/// Maximum homing range of missiles before expiring.
pub let missile_range : Float = 300.0

///|
/// Missile tracking turn rate for homing guidance.
pub let missile_turn_rate : Float = 4.0

///|
/// Missile fuel duration in seconds for homing capability.
pub let missile_fuel : Float = 5.0

///|
/// Proximity detonation trigger radius around missile.
pub let missile_prox_radius : Float = 3.0

///|
/// Maximum missile ammunition the player can carry.
pub let missile_max_ammo : Int = 24

// Railgun: very slow, very high damage, piercing, energy cost

///|
/// Railgun damage per piercing round.
pub let railgun_damage : Float = 80.0

///|
/// Railgun projectile travel speed in units per second.
pub let railgun_speed : Float = 250.0

///|
/// Minimum seconds between railgun shots.
pub let railgun_cooldown : Float = 2.5

///|
/// Maximum effective range of railgun rounds.
pub let railgun_range : Float = 400.0

///|
/// Weapon energy consumed per railgun shot.
pub let railgun_energy_cost : Float = 30.0

// Weapon energy

///|
/// Maximum weapon energy pool capacity.
pub let max_weapon_energy : Float = 100.0

///|
/// Weapon energy regeneration rate in points per second.
pub let weapon_energy_regen : Float = 8.0

// Boost fuel

///|
/// Maximum afterburner fuel capacity.
pub let max_boost_fuel : Float = 100.0

///|
/// Afterburner fuel consumption rate per second while boosting.
pub let boost_fuel_drain : Float = 25.0

///|
/// Afterburner fuel regeneration rate per second when not boosting.
pub let boost_fuel_regen : Float = 10.0

// Enemy stats

///|
/// Enemy fighter base hull hit points.
pub let fighter_hp : Float = 30.0

///|
/// Enemy fighter movement speed.
pub let fighter_speed : Float = 25.0

///|
/// Enemy fighter seconds between shots.
pub let fighter_fire_rate : Float = 1.5

///|
/// Enemy fighter damage per shot.
pub let fighter_damage : Float = 5.0

///|
/// Score awarded for destroying an enemy fighter.
pub let fighter_score : Int = 100

///|
/// Distance at which enemy fighters detect the player.
pub let fighter_detect_range : Float = 120.0

///|
/// Distance at which enemy fighters begin attack runs.
pub let fighter_attack_range : Float = 80.0

///|
/// Health percentage below which fighters start evasive maneuvers.
pub let fighter_evade_hp_pct : Float = 0.3

///|
/// Health percentage below which fighters flee from combat.
pub let fighter_flee_hp_pct : Float = 0.15

///|
/// Enemy interceptor base hull hit points.
pub let interceptor_hp : Float = 20.0

///|
/// Enemy interceptor movement speed.
pub let interceptor_speed : Float = 40.0

///|
/// Enemy interceptor seconds between shots.
pub let interceptor_fire_rate : Float = 0.8

///|
/// Enemy interceptor damage per shot.
pub let interceptor_damage : Float = 4.0

///|
/// Score awarded for destroying an enemy interceptor.
pub let interceptor_score : Int = 150

///|
/// Distance at which enemy interceptors detect the player.
pub let interceptor_detect_range : Float = 150.0

///|
/// Enemy bomber base hull hit points.
pub let bomber_hp : Float = 60.0

///|
/// Enemy bomber movement speed.
pub let bomber_speed : Float = 15.0

///|
/// Enemy bomber seconds between plasma shots.
pub let bomber_fire_rate : Float = 3.0

///|
/// Enemy bomber damage per plasma shot.
pub let bomber_damage : Float = 20.0

///|
/// Score awarded for destroying an enemy bomber.
pub let bomber_score : Int = 250

///|
/// Enemy cruiser base hull hit points.
pub let cruiser_hp : Float = 120.0

///|
/// Enemy cruiser movement speed.
pub let cruiser_speed : Float = 10.0

///|
/// Enemy cruiser seconds between shots.
pub let cruiser_fire_rate : Float = 2.0

///|
/// Enemy cruiser damage per shot.
pub let cruiser_damage : Float = 12.0

///|
/// Score awarded for destroying an enemy cruiser.
pub let cruiser_score : Int = 500

///|
/// Enemy capital ship base hull hit points.
pub let capital_hp : Float = 500.0

///|
/// Enemy capital ship movement speed.
pub let capital_speed : Float = 5.0

///|
/// Enemy capital ship main gun seconds between shots.
pub let capital_fire_rate : Float = 1.0

///|
/// Enemy capital ship damage per main gun shot.
pub let capital_damage : Float = 25.0

///|
/// Score awarded for destroying an enemy capital ship.
pub let capital_score : Int = 2000

///|
/// Hit points of each capital ship weak point.
pub let capital_weak_point_hp : Float = 80.0

///|
/// Score awarded for destroying an asteroid.
pub let asteroid_score : Int = 25

///|
/// Hit points for a large asteroid.
pub let asteroid_large_hp : Float = 80.0

///|
/// Hit points for a medium asteroid.
pub let asteroid_medium_hp : Float = 40.0

///|
/// Hit points for a small asteroid fragment.
pub let asteroid_small_hp : Float = 15.0

///|
/// Collision radius for large asteroids.
pub let asteroid_large_size : Float = 4.5

///|
/// Collision radius for medium asteroids.
pub let asteroid_medium_size : Float = 2.5

///|
/// Collision radius for small asteroid fragments.
pub let asteroid_small_size : Float = 1.2

///|
/// Number of smaller fragments spawned when an asteroid breaks apart.
pub let asteroid_break_count : Int = 3

// Station parameters

///|
/// Default space station hull hit points.
pub let station_hp : Float = 300.0

///|
/// Station allegiance identifier for friendly stations.
pub let station_friendly : Int = 0

///|
/// Station allegiance identifier for hostile stations.
pub let station_enemy : Int = 1

// Power-up parameters

///|
/// Hull points restored by the health power-up.
pub let powerup_health_amount : Float = 40.0

///|
/// Shield points restored by the shield power-up.
pub let powerup_shield_amount : Float = 30.0

///|
/// Duration in seconds of the weapon damage boost.
pub let powerup_weapon_duration : Float = 10.0

///|
/// Duration in seconds of the speed boost.
pub let powerup_speed_duration : Float = 8.0

///|
/// Vertical bobbing animation speed for floating power-ups.
pub let powerup_float_speed : Float = 1.5

///|
/// Vertical bobbing amplitude for floating power-ups.
pub let powerup_bob_amplitude : Float = 0.5

///|
/// Rotation speed of the power-up spin animation.
pub let powerup_spin_speed : Float = 2.0

///|
/// Collection trigger radius around power-up pickups.
pub let powerup_collect_radius : Float = 3.0

// Particle effect parameters

// Camera

///|
/// Camera vertical field of view in degrees.
pub let camera_fovy : Float = 60.0

///|
/// Chase camera distance behind the player ship.
pub let camera_distance : Float = 12.0

///|
/// Chase camera height offset above the player ship.
pub let camera_height : Float = 4.0

// World bounds

///|
/// Half-extent of the cubic world boundary for coordinate wrapping.
pub let world_size : Float = 500.0

// Pi

///|
/// Mathematical constant pi.
pub let pi : Float = 3.14159265

///|
/// Mathematical constant two times pi.
pub let two_pi : Float = 6.2831853

// Mission count

///|
/// Total number of playable missions in the campaign.
pub let total_missions : Int = 12

// Combo system

///|
/// Seconds before the kill combo counter resets.
pub let combo_timeout : Float = 3.0

///|
/// Score multiplier for a 2-kill combo.
pub let combo_mult_2 : Float = 1.5

///|
/// Score multiplier for a 3-kill combo.
pub let combo_mult_3 : Float = 2.0

///|
/// Score multiplier for a 5-kill combo.
pub let combo_mult_5 : Float = 3.0

///|
/// Score multiplier for an 8-kill combo.
pub let combo_mult_8 : Float = 5.0

// Kill feed

///|
/// Maximum number of visible kill feed entries on screen.
pub let max_kill_feed : Int = 5

///|
/// Duration in seconds a kill feed entry remains visible.
pub let kill_feed_duration : Float = 3.0

// Damage flash

///|
/// Duration in seconds of the damage flash visual effect.
pub let damage_flash_duration : Float = 0.3

// Radar/minimap

// Difficulty scaling per mission

///|
/// Returns the enemy HP scaling multiplier for the given `mission` number.
pub fn mission_difficulty_hp_mult(mission : Int) -> Float {
  1.0 + Float::from_int(mission) * 0.15
}

///|
/// Returns the enemy speed scaling multiplier for the given `mission` number.
pub fn mission_difficulty_speed_mult(mission : Int) -> Float {
  1.0 + Float::from_int(mission) * 0.05
}

// Ship class hull by type

///|
/// Returns the maximum hull hit points for the given `ship_class`.
pub fn ship_class_hull(ship_class : Int) -> Float {
  if ship_class == ship_fighter {
    fighter_class_hull
  } else if ship_class == ship_interceptor {
    interceptor_class_hull
  } else if ship_class == ship_bomber {
    bomber_class_hull
  } else if ship_class == ship_cruiser {
    cruiser_class_hull
  } else {
    capital_class_hull
  }
}

///|
/// Returns the maximum shield capacity for the given `ship_class`.
pub fn ship_class_shield(ship_class : Int) -> Float {
  if ship_class == ship_fighter {
    fighter_class_shield
  } else if ship_class == ship_interceptor {
    interceptor_class_shield
  } else if ship_class == ship_bomber {
    bomber_class_shield
  } else if ship_class == ship_cruiser {
    cruiser_class_shield
  } else {
    capital_class_shield
  }
}

///|
/// Returns the base movement speed for the given `ship_class`.
pub fn ship_class_speed(ship_class : Int) -> Float {
  if ship_class == ship_fighter {
    fighter_class_speed
  } else if ship_class == ship_interceptor {
    interceptor_class_speed
  } else if ship_class == ship_bomber {
    bomber_class_speed
  } else if ship_class == ship_cruiser {
    cruiser_class_speed
  } else {
    capital_class_speed
  }
}

///|
/// Returns the turn rate for the given `ship_class`.
pub fn ship_class_turn(ship_class : Int) -> Float {
  if ship_class == ship_fighter {
    fighter_class_turn
  } else if ship_class == ship_interceptor {
    interceptor_class_turn
  } else if ship_class == ship_bomber {
    bomber_class_turn
  } else if ship_class == ship_cruiser {
    cruiser_class_turn
  } else {
    capital_class_turn
  }
}

///|
/// Returns the afterburner boost speed for the given `ship_class`.
pub fn ship_class_boost(ship_class : Int) -> Float {
  if ship_class == ship_fighter {
    fighter_class_boost
  } else if ship_class == ship_interceptor {
    interceptor_class_boost
  } else if ship_class == ship_bomber {
    bomber_class_boost
  } else if ship_class == ship_cruiser {
    cruiser_class_boost
  } else {
    capital_class_boost
  }
}

///|
/// Returns the display name for the given `ship_class`.
pub fn ship_class_name(ship_class : Int) -> String {
  if ship_class == ship_fighter {
    "Fighter"
  } else if ship_class == ship_interceptor {
    "Interceptor"
  } else if ship_class == ship_bomber {
    "Bomber"
  } else if ship_class == ship_cruiser {
    "Cruiser"
  } else {
    "Capital Ship"
  }
}

// Enemy type score

// Mission objective types

///|
/// Mission objective requiring destruction of all enemies.
pub let objective_destroy_all : Int = 0

///|
/// Mission objective requiring escort of an allied ship.
pub let objective_escort : Int = 1

///|
/// Mission objective requiring defense of a friendly station.
pub let objective_defend_station : Int = 2

///|
/// Mission objective requiring destruction of a capital ship boss.
pub let objective_boss_fight : Int = 3

///|
/// Mission objective requiring survival of an ambush encounter.
pub let objective_ambush : Int = 4

///|
/// Mission objective requiring clearance of patrol waypoints.
pub let objective_patrol : Int = 5

///|
/// Mission objective requiring survival for a set duration.
pub let objective_survive : Int = 6

///|
/// Mission objective requiring destruction of a specific number of enemies.
pub let objective_destroy_count : Int = 7

///|
/// Returns the human-readable description for the given `obj_type`.
pub fn objective_type_name(obj_type : Int) -> String {
  if obj_type == objective_destroy_all {
    "Destroy all enemies"
  } else if obj_type == objective_escort {
    "Escort ally ship"
  } else if obj_type == objective_defend_station {
    "Defend the station"
  } else if obj_type == objective_boss_fight {
    "Destroy the capital ship"
  } else if obj_type == objective_ambush {
    "Survive the ambush"
  } else if obj_type == objective_patrol {
    "Clear patrol waypoints"
  } else if obj_type == objective_survive {
    "Survive for the duration"
  } else if obj_type == objective_destroy_count {
    "Destroy target count"
  } else {
    "Unknown objective"
  }
}
