// Screen

///|
/// Window width in pixels.
pub let screen_width : Int = 1280

///|
/// Window height in pixels.
pub let screen_height : Int = 720

// Game states

///|
pub(all) enum GameState {
  StateMenu
  StatePlaying
  StatePaused
  StateMissionComplete
  StateGameOver
  StateMissionBriefing
  StateMissionSelect
  StateLoadout
} derive(Eq)

///|
/// Converts a GameState to its integer value.
pub fn GameState::to_int(self : GameState) -> Int {
  match self {
    StateMenu => 0
    StatePlaying => 1
    StatePaused => 2
    StateMissionComplete => 3
    StateGameOver => 4
    StateMissionBriefing => 5
    StateMissionSelect => 6
    StateLoadout => 7
  }
}

///|
/// Converts an integer to a GameState.
pub fn GameState::from_int(v : Int) -> GameState {
  match v {
    0 => StateMenu
    1 => StatePlaying
    2 => StatePaused
    3 => StateMissionComplete
    4 => StateGameOver
    5 => StateMissionBriefing
    6 => StateMissionSelect
    _ => StateLoadout
  }
}

// Ship classes

///|
/// Player and enemy ship class identifiers.
pub(all) enum ShipKind {
  Fighter
  Interceptor
  Bomber
  Cruiser
  CapitalShip
} derive(Eq)

// Weapon types

///|
/// Weapon type identifiers for projectiles.
pub(all) enum WeaponKind {
  Laser
  Missile
  Plasma
  Railgun
} derive(Eq)

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
/// Enemy AI behavior state identifiers.
pub(all) enum AiState {
  Idle
  Patrol
  Chase
  Attack
  Evade
  Flee
  Formation
} derive(Eq)

// Power-up types

///|
/// Power-up pickup type identifiers.
pub(all) enum PowerupKind {
  Health
  Shield
  WeaponBoost
  SpeedBoost
} derive(Eq)

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
/// Enemy squad formation pattern identifiers.
pub(all) enum Formation {
  V
  Line
  Circle
  Wedge
} derive(Eq)

// Mission objective types

///|
/// Mission objective type identifiers.
pub(all) enum Objective {
  DestroyAll
  Escort
  DefendStation
  BossFight
  Ambush
  PatrolMission
  Survive
  DestroyCount
} derive(Eq)

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
pub fn ship_class_hull(ship_class : ShipKind) -> Float {
  match ship_class {
    Fighter => (fighter_class_hull)
    Interceptor => (interceptor_class_hull)
    Bomber => (bomber_class_hull)
    Cruiser => (cruiser_class_hull)
    _ => (capital_class_hull)
  }
}

///|
/// Returns the maximum shield capacity for the given `ship_class`.
pub fn ship_class_shield(ship_class : ShipKind) -> Float {
  match ship_class {
    Fighter => (fighter_class_shield)
    Interceptor => (interceptor_class_shield)
    Bomber => (bomber_class_shield)
    Cruiser => (cruiser_class_shield)
    _ => (capital_class_shield)
  }
}

///|
/// Returns the base movement speed for the given `ship_class`.
pub fn ship_class_speed(ship_class : ShipKind) -> Float {
  match ship_class {
    Fighter => (fighter_class_speed)
    Interceptor => (interceptor_class_speed)
    Bomber => (bomber_class_speed)
    Cruiser => (cruiser_class_speed)
    _ => (capital_class_speed)
  }
}

///|
/// Returns the turn rate for the given `ship_class`.
pub fn ship_class_turn(ship_class : ShipKind) -> Float {
  match ship_class {
    Fighter => (fighter_class_turn)
    Interceptor => (interceptor_class_turn)
    Bomber => (bomber_class_turn)
    Cruiser => (cruiser_class_turn)
    _ => (capital_class_turn)
  }
}

///|
/// Returns the afterburner boost speed for the given `ship_class`.
pub fn ship_class_boost(ship_class : ShipKind) -> Float {
  match ship_class {
    Fighter => (fighter_class_boost)
    Interceptor => (interceptor_class_boost)
    Bomber => (bomber_class_boost)
    Cruiser => (cruiser_class_boost)
    _ => (capital_class_boost)
  }
}

///|
/// Returns the display name for the given `ship_class`.
pub fn ship_class_name(ship_class : ShipKind) -> String {
  match ship_class {
    Fighter => { "Fighter" }
    Interceptor => { "Interceptor" }
    Bomber => { "Bomber" }
    Cruiser => { "Cruiser" }
    _ => { "Capital Ship" }
  }
}

// Enemy type score

///|
/// Returns the human-readable description for the given `obj_type`.
pub fn objective_type_name(obj_type : Objective) -> String {
  match obj_type {
    DestroyAll => { "Destroy all enemies" }
    Escort => { "Escort ally ship" }
    DefendStation => { "Defend the station" }
    BossFight => { "Destroy the capital ship" }
    Ambush => { "Survive the ambush" }
    PatrolMission => { "Clear patrol waypoints" }
    Survive => { "Survive for the duration" }
    DestroyCount => { "Destroy target count" }
    _ => { "Unknown objective" }
  }
}

///|
/// Converts an integer to a ShipKind enum value.
pub fn ship_kind_from_int(v : Int) -> ShipKind {
  if v == 0 {
    Fighter
  } else if v == 1 {
    Interceptor
  } else if v == 2 {
    Bomber
  } else if v == 3 {
    Cruiser
  } else {
    CapitalShip
  }
}

///|
/// Converts an integer to a PowerupKind enum value.
pub fn powerup_kind_from_int(v : Int) -> PowerupKind {
  if v == 0 {
    Health
  } else if v == 1 {
    Shield
  } else if v == 2 {
    WeaponBoost
  } else {
    SpeedBoost
  }
}

///|
/// Converts an integer to a Formation enum value.
pub fn formation_from_int(v : Int) -> Formation {
  if v == 0 {
    V
  } else if v == 1 {
    Line
  } else if v == 2 {
    Circle
  } else {
    Wedge
  }
}

///|
/// Converts an integer to an Objective enum value.
pub fn objective_from_int(v : Int) -> Objective {
  if v == 0 {
    DestroyAll
  } else if v == 1 {
    Escort
  } else if v == 2 {
    DefendStation
  } else if v == 3 {
    BossFight
  } else if v == 4 {
    Ambush
  } else if v == 5 {
    PatrolMission
  } else if v == 6 {
    Survive
  } else {
    DestroyCount
  }
}
