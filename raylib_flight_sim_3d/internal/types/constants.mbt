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
/// Game state identifier for the mission complete screen.
pub let state_mission_complete : Int = 3

///|
/// Game state identifier for the game over screen.
pub let state_game_over : Int = 4

///|
/// Game state identifier for the aircraft selection screen.
pub let state_aircraft_select : Int = 5

///|
/// Game state identifier for the mission briefing screen.
pub let state_mission_briefing : Int = 6

// PI constant

///|
/// Pi constant for trigonometric calculations.
pub let pi : Float = 3.14159265

///|
/// Two times pi for full-circle angle wrapping.
pub let two_pi : Float = 6.2831853

///|
/// Half of pi representing a 90-degree angle in radians.
pub let half_pi : Float = 1.57079632

///|
/// Conversion factor from degrees to radians.
pub let deg_to_rad : Float = 0.01745329

// Aircraft types

///|
/// Aircraft type identifier for the trainer.
pub let aircraft_trainer : Int = 0

///|
/// Aircraft type identifier for the fighter.
pub let aircraft_fighter : Int = 1

///|
/// Aircraft type identifier for the bomber.
pub let aircraft_bomber : Int = 2

///|
/// Aircraft type identifier for the interceptor.
pub let aircraft_interceptor : Int = 3

// Trainer stats

///|
/// Trainer maximum airspeed.
pub let trainer_speed_max : Float = 60.0

///|
/// Trainer minimum airspeed before stalling.
pub let trainer_speed_min : Float = 12.0

///|
/// Trainer yaw turn rate in radians per second.
pub let trainer_turn_rate : Float = 2.0

///|
/// Trainer roll rate in radians per second.
pub let trainer_roll_rate : Float = 2.8

///|
/// Trainer vertical climb rate.
pub let trainer_climb_rate : Float = 1.5

///|
/// Trainer fuel tank capacity in units.
pub let trainer_fuel_capacity : Float = 120.0

///|
/// Trainer maximum hit points.
pub let trainer_hp : Float = 80.0

///|
/// Trainer machine gun ammunition count.
pub let trainer_ammo_mg : Int = 300

///|
/// Trainer rocket ammunition count.
pub let trainer_ammo_rockets : Int = 4

///|
/// Trainer bomb ammunition count.
pub let trainer_ammo_bombs : Int = 2

// Fighter stats

///|
/// Fighter maximum airspeed.
pub let fighter_speed_max : Float = 90.0

///|
/// Fighter minimum airspeed before stalling.
pub let fighter_speed_min : Float = 18.0

///|
/// Fighter yaw turn rate in radians per second.
pub let fighter_turn_rate : Float = 2.4

///|
/// Fighter roll rate in radians per second.
pub let fighter_roll_rate : Float = 3.2

///|
/// Fighter vertical climb rate.
pub let fighter_climb_rate : Float = 2.0

///|
/// Fighter fuel tank capacity in units.
pub let fighter_fuel_capacity : Float = 100.0

///|
/// Fighter maximum hit points.
pub let fighter_hp : Float = 100.0

///|
/// Fighter machine gun ammunition count.
pub let fighter_ammo_mg : Int = 500

///|
/// Fighter rocket ammunition count.
pub let fighter_ammo_rockets : Int = 8

///|
/// Fighter bomb ammunition count.
pub let fighter_ammo_bombs : Int = 4

// Bomber stats

///|
/// Bomber maximum airspeed.
pub let bomber_speed_max : Float = 55.0

///|
/// Bomber minimum airspeed before stalling.
pub let bomber_speed_min : Float = 15.0

///|
/// Bomber yaw turn rate in radians per second.
pub let bomber_turn_rate : Float = 1.2

///|
/// Bomber roll rate in radians per second.
pub let bomber_roll_rate : Float = 1.5

///|
/// Bomber vertical climb rate.
pub let bomber_climb_rate : Float = 0.8

///|
/// Bomber fuel tank capacity in units.
pub let bomber_fuel_capacity : Float = 150.0

///|
/// Bomber maximum hit points.
pub let bomber_hp : Float = 160.0

///|
/// Bomber machine gun ammunition count.
pub let bomber_ammo_mg : Int = 200

///|
/// Bomber rocket ammunition count.
pub let bomber_ammo_rockets : Int = 6

///|
/// Bomber bomb ammunition count.
pub let bomber_ammo_bombs : Int = 12

// Interceptor stats

///|
/// Interceptor maximum airspeed.
pub let interceptor_speed_max : Float = 110.0

///|
/// Interceptor minimum airspeed before stalling.
pub let interceptor_speed_min : Float = 22.0

///|
/// Interceptor yaw turn rate in radians per second.
pub let interceptor_turn_rate : Float = 1.8

///|
/// Interceptor roll rate in radians per second.
pub let interceptor_roll_rate : Float = 2.6

///|
/// Interceptor vertical climb rate.
pub let interceptor_climb_rate : Float = 2.8

///|
/// Interceptor fuel tank capacity in units.
pub let interceptor_fuel_capacity : Float = 80.0

///|
/// Interceptor maximum hit points.
pub let interceptor_hp : Float = 70.0

///|
/// Interceptor machine gun ammunition count.
pub let interceptor_ammo_mg : Int = 400

///|
/// Interceptor rocket ammunition count.
pub let interceptor_ammo_rockets : Int = 12

///|
/// Interceptor bomb ammunition count.
pub let interceptor_ammo_bombs : Int = 0

// Player aircraft (legacy / defaults)

///|
/// Default minimum airspeed before stalling.
pub let aircraft_speed_min : Float = 15.0

///|
/// Default maximum airspeed.
pub let aircraft_speed_max : Float = 80.0

///|
/// Default starting airspeed when a mission begins.
pub let aircraft_speed_start : Float = 40.0

///|
/// Throttle acceleration rate per second.
pub let aircraft_throttle_accel : Float = 20.0

///|
/// Pitch rotation rate in radians per second.
pub let aircraft_pitch_rate : Float = 1.8

///|
/// Yaw rotation rate in radians per second.
pub let aircraft_yaw_rate : Float = 1.2

///|
/// Roll rotation rate in radians per second.
pub let aircraft_roll_rate : Float = 2.5

///|
/// Gravitational acceleration applied to the aircraft.
pub let aircraft_gravity : Float = 9.8

///|
/// Lift coefficient multiplied by speed to oppose gravity.
pub let aircraft_lift_factor : Float = 0.15

///|
/// Aerodynamic drag coefficient.
pub let aircraft_drag : Float = 0.02

///|
/// Collision radius of the player aircraft.
pub let aircraft_size : Float = 1.5

///|
/// Default maximum fuel capacity.
pub let aircraft_max_fuel : Float = 100.0

///|
/// Fuel consumption rate multiplier per second.
pub let aircraft_fuel_rate : Float = 1.5

///|
/// Minimum altitude above terrain before ground contact.
pub let aircraft_min_altitude : Float = 0.5

// Stall parameters

///|
/// Speed ratio below minimum that triggers a stall.
pub let stall_speed_threshold : Float = 0.7

///|
/// Pitch correction rate during stall recovery.
pub let stall_recovery_pitch : Float = 0.3

///|
/// Rate at which the nose drops during a stall.
pub let stall_nose_drop_rate : Float = 1.5

///|
/// Control effectiveness reduction factor during a stall.
pub let stall_control_reduction : Float = 0.3

///|
/// Speed ratio at which the stall warning activates.
pub let stall_warning_speed_ratio : Float = 0.8

// Altitude effects

///|
/// Altitude at which thin air effects begin reducing performance.
pub let altitude_thin_air_start : Float = 60.0

///|
/// Altitude at which thin air effects reach maximum severity.
pub let altitude_thin_air_max : Float = 120.0

///|
/// Minimum control effectiveness at extreme altitude.
pub let altitude_control_min : Float = 0.4

///|
/// Minimum engine efficiency at extreme altitude.
pub let altitude_engine_min : Float = 0.5

// Fuel consumption rates

///|
/// Fuel consumption rate at idle throttle.
pub let fuel_idle_rate : Float = 0.3

///|
/// Fuel consumption rate at cruise throttle.
pub let fuel_cruise_rate : Float = 1.0

///|
/// Fuel consumption rate at full afterburner throttle.
pub let fuel_afterburner_rate : Float = 3.0

///|
/// Fuel ratio below which the low-fuel warning activates.
pub let fuel_warning_threshold : Float = 0.2

///|
/// Fuel ratio below which the critical-fuel warning activates.
pub let fuel_critical_threshold : Float = 0.1

// Camera

///|
/// Camera field of view in degrees.
pub let camera_fovy : Float = 65.0

///|
/// Chase camera distance behind the aircraft.
pub let camera_distance : Float = 12.0

///|
/// Chase camera height offset above the aircraft.
pub let camera_height : Float = 4.0

///|
/// Camera interpolation smoothing speed.
pub let camera_smooth : Float = 5.0

///|
/// Camera mode identifier for third-person chase view.
pub let camera_mode_chase : Int = 0

///|
/// Camera mode identifier for first-person cockpit view.
pub let camera_mode_cockpit : Int = 1

///|
/// Camera mode identifier for free orbiting view.
pub let camera_mode_free : Int = 2

///|
/// Field of view in degrees for cockpit camera mode.
pub let camera_cockpit_fov : Float = 80.0

// Terrain

///|
/// Number of cells per terrain grid side.
pub let terrain_grid_size : Int = 16

///|
/// World-space size of each terrain chunk.
pub let terrain_chunk_scale : Float = 8.0

///|
/// Maximum procedural terrain height.
pub let terrain_max_height : Float = 15.0

///|
/// Number of terrain chunks visible in each direction from the player.
pub let terrain_view_range : Int = 8

///|
/// Maximum number of terrain chunks in the pool.
pub let max_terrain_chunks : Int = 256

///|
/// Terrain height below which water is rendered.
pub let terrain_water_level : Float = 1.0

///|
/// Terrain height above which snow caps are rendered.
pub let terrain_snow_level : Float = 12.0

///|
/// Terrain height above which forest biome begins.
pub let terrain_forest_level : Float = 5.0

// Weapon types

///|
/// Weapon type identifier for machine guns.
pub let weapon_machine_gun : Int = 0

///|
/// Weapon type identifier for rockets.
pub let weapon_rockets : Int = 1

///|
/// Weapon type identifier for bombs.
pub let weapon_bombs : Int = 2

// Machine gun parameters

///|
/// Machine gun fire interval in seconds.
pub let mg_fire_rate : Float = 0.08

///|
/// Machine gun damage per bullet.
pub let mg_damage : Float = 12.0

///|
/// Machine gun bullet speed.
pub let mg_speed : Float = 150.0

///|
/// Machine gun effective range.
pub let mg_range : Float = 80.0

///|
/// Machine gun bullet spread in radians.
pub let mg_spread : Float = 0.02

// Rocket parameters

///|
/// Rocket fire interval in seconds.
pub let rocket_fire_rate : Float = 0.5

///|
/// Rocket damage per hit.
pub let rocket_damage : Float = 60.0

///|
/// Rocket projectile speed.
pub let rocket_speed : Float = 100.0

///|
/// Rocket maximum effective range.
pub let rocket_range : Float = 120.0

///|
/// Rocket engine thrust acceleration.
pub let rocket_thrust : Float = 40.0

///|
/// Gravity effect on rocket trajectory.
pub let rocket_gravity : Float = 2.0

// Bomb parameters

///|
/// Bomb release interval in seconds.
pub let bomb_fire_rate : Float = 0.8

///|
/// Bomb damage at the center of the blast.
pub let bomb_damage : Float = 120.0

///|
/// Bomb explosion area-of-effect radius.
pub let bomb_blast_radius : Float = 8.0

///|
/// Gravitational acceleration applied to falling bombs.
pub let bomb_gravity : Float = 9.8

// Projectiles

///|
/// Maximum number of active projectiles in the pool.
pub let max_projectiles : Int = 128

///|
/// Default projectile travel speed.
pub let projectile_speed : Float = 120.0

///|
/// Default projectile lifetime in seconds.
pub let projectile_life : Float = 2.0

///|
/// Default projectile damage per hit.
pub let projectile_damage : Float = 25.0

///|
/// Minimum interval between player weapon fires in seconds.
pub let fire_cooldown : Float = 0.15

// Projectile types

///|
/// Projectile type identifier for bullets.
pub let proj_bullet : Int = 0

///|
/// Projectile type identifier for rockets.
pub let proj_rocket : Int = 1

///|
/// Projectile type identifier for bombs.
pub let proj_bomb : Int = 2

///|
/// Projectile type identifier for anti-aircraft shells.
pub let proj_aa_shell : Int = 3

// Enemies

///|
/// Maximum number of active enemies in the pool.
pub let max_enemies : Int = 32

///|
/// Default airspeed for airborne enemies.
pub let enemy_air_speed : Float = 20.0

///|
/// Collision radius of ground enemies.
pub let enemy_ground_size : Float = 2.0

///|
/// Collision radius of airborne enemies.
pub let enemy_air_size : Float = 1.8

///|
/// Default hit points for airborne enemies.
pub let enemy_hp_air : Float = 50.0

///|
/// Default hit points for ground enemies.
pub let enemy_hp_ground : Float = 80.0

///|
/// Enemy fire interval in seconds.
pub let enemy_fire_rate : Float = 2.0

///|
/// Maximum distance at which enemies can fire at the player.
pub let enemy_fire_range : Float = 60.0

///|
/// Enemy type identifier for airborne fighters.
pub let enemy_type_air : Int = 0

///|
/// Enemy type identifier for ground emplacements.
pub let enemy_type_ground : Int = 1

// Enemy AI states

///|
/// AI state identifier for patrol behavior.
pub let ai_patrol : Int = 0

///|
/// AI state identifier for engaging the player.
pub let ai_engage : Int = 1

///|
/// AI state identifier for evasive maneuvers.
pub let ai_evade : Int = 2

///|
/// AI state identifier for fleeing when critically damaged.
pub let ai_flee : Int = 3

///|
/// AI state identifier for formation flying.
pub let ai_formation : Int = 4

// Enemy AI parameters

///|
/// Distance at which enemies switch from patrol to engage state.
pub let ai_engage_range : Float = 80.0

///|
/// Distance at which engaged enemies return to patrol state.
pub let ai_disengage_range : Float = 150.0

///|
/// HP ratio below which enemies switch to flee state.
pub let ai_flee_hp_ratio : Float = 0.2

///|
/// Duration of evasive maneuvers in seconds.
pub let ai_evade_duration : Float = 3.0

///|
/// Distance between aircraft in formation flying.
pub let ai_formation_spacing : Float = 8.0

// Turrets

///|
/// Maximum number of active turrets in the pool.
pub let max_turrets : Int = 16

///|
/// Turret fire interval in seconds.
pub let turret_fire_rate : Float = 1.5

///|
/// Turret maximum engagement range.
pub let turret_range : Float = 70.0

///|
/// Turret maximum hit points.
pub let turret_hp : Float = 100.0

///|
/// Turret barrel rotation speed in radians per second.
pub let turret_rotation_speed : Float = 1.0

///|
/// Speed of anti-aircraft shells fired by turrets.
pub let turret_shell_speed : Float = 80.0

// Buildings

///|
/// Maximum number of active buildings in the pool.
pub let max_buildings : Int = 32

///|
/// Building type identifier for hangars.
pub let building_hangar : Int = 0

///|
/// Building type identifier for control towers.
pub let building_tower : Int = 1

///|
/// Building type identifier for runways.
pub let building_runway : Int = 2

///|
/// Building type identifier for houses.
pub let building_house : Int = 3

///|
/// Building type identifier for factories.
pub let building_factory : Int = 4

///|
/// Building type identifier for bunkers.
pub let building_bunker : Int = 5

// Particles

///|
/// Maximum number of active particles in the pool.
pub let max_particles : Int = 512

///|
/// Particle type identifier for engine exhaust.
pub let particle_exhaust : Int = 0

///|
/// Particle type identifier for smoke trails.
pub let particle_smoke : Int = 1

///|
/// Particle type identifier for fire effects.
pub let particle_fire : Int = 2

///|
/// Particle type identifier for bullet tracers.
pub let particle_tracer : Int = 3

///|
/// Particle type identifier for explosion fragments.
pub let particle_explosion : Int = 4

///|
/// Particle type identifier for debris chunks.
pub let particle_debris : Int = 5

///|
/// Particle type identifier for rain droplets.
pub let particle_rain : Int = 6

///|
/// Particle type identifier for spark effects.
pub let particle_spark : Int = 7

// Checkpoints

///|
/// Maximum number of active checkpoints in the pool.
pub let max_checkpoints : Int = 16

///|
/// Trigger radius for collecting a checkpoint ring.
pub let checkpoint_radius : Float = 8.0

// Mission types

///|
/// Mission type identifier for checkpoint navigation.
pub let mission_checkpoint : Int = 0

///|
/// Mission type identifier for destroy-all-targets.
pub let mission_destroy : Int = 1

///|
/// Mission type identifier for landing challenges.
pub let mission_landing : Int = 2

///|
/// Mission type identifier for timed survival.
pub let mission_survive : Int = 3

///|
/// Mission type identifier for escort duties.
pub let mission_escort : Int = 4

///|
/// Mission type identifier for patrol routes.
pub let mission_patrol : Int = 5

///|
/// Mission type identifier for intercepting enemy formations.
pub let mission_intercept : Int = 6

///|
/// Mission type identifier for bombing run sorties.
pub let mission_bombing_run : Int = 7

///|
/// Mission type identifier for air-to-air dogfights.
pub let mission_dogfight : Int = 8

///|
/// Mission type identifier for reconnaissance flyovers.
pub let mission_recon : Int = 9

///|
/// Mission type identifier for base defense.
pub let mission_defense : Int = 10

///|
/// Mission type identifier for attacking an enemy base.
pub let mission_attack_base : Int = 11

///|
/// Mission type identifier for high-speed canyon runs.
pub let mission_canyon_run : Int = 12

///|
/// Mission type identifier for night operations.
pub let mission_night_mission : Int = 13

///|
/// Mission type identifier for the final boss encounter.
pub let mission_boss : Int = 14

///|
/// Total number of missions available in the campaign.
pub let total_missions : Int = 15

// Weather

///|
/// Weather type identifier for clear skies.
pub let weather_clear : Int = 0

///|
/// Weather type identifier for cloudy conditions.
pub let weather_cloudy : Int = 1

///|
/// Weather type identifier for heavy fog.
pub let weather_fog : Int = 2

///|
/// Weather type identifier for rain.
pub let weather_rain : Int = 3

///|
/// Weather type identifier for severe storms.
pub let weather_storm : Int = 4

///|
/// Weather type identifier for nighttime conditions.
pub let weather_night : Int = 5

// Weather parameters

///|
/// Fog draw distance in clear weather.
pub let fog_clear_dist : Float = 200.0

///|
/// Fog draw distance in cloudy weather.
pub let fog_cloudy_dist : Float = 150.0

///|
/// Fog draw distance in foggy weather.
pub let fog_fog_dist : Float = 80.0

///|
/// Fog draw distance in rainy weather.
pub let fog_rain_dist : Float = 100.0

///|
/// Fog draw distance in storm weather.
pub let fog_storm_dist : Float = 50.0

///|
/// Fog draw distance at night.
pub let fog_night_dist : Float = 120.0

// Turbulence strength by weather

///|
/// Turbulence strength in clear weather.
pub let turb_clear : Float = 0.0

///|
/// Turbulence strength in cloudy weather.
pub let turb_cloudy : Float = 0.1

///|
/// Turbulence strength in foggy weather.
pub let turb_fog : Float = 0.05

///|
/// Turbulence strength in rainy weather.
pub let turb_rain : Float = 0.3

///|
/// Turbulence strength in storm weather.
pub let turb_storm : Float = 0.6

///|
/// Turbulence strength at night.
pub let turb_night : Float = 0.05

// Wind parameters

///|
/// Wind speed in clear weather.
pub let wind_clear : Float = 0.0

///|
/// Wind speed in cloudy weather.
pub let wind_cloudy : Float = 2.0

///|
/// Wind speed in foggy weather.
pub let wind_fog : Float = 1.0

///|
/// Wind speed in rainy weather.
pub let wind_rain : Float = 5.0

///|
/// Wind speed in storm weather.
pub let wind_storm : Float = 10.0

///|
/// Wind speed at night.
pub let wind_night : Float = 1.5

// Cloud parameters

///|
/// Default cloud layer base altitude.
pub let cloud_base_height : Float = 50.0

///|
/// Vertical thickness of the cloud layer.
pub let cloud_layer_thickness : Float = 10.0

///|
/// Maximum number of active clouds in the pool.
pub let max_clouds : Int = 40

// Landing parameters

///|
/// Ideal glide slope angle for landing approach.
pub let landing_glide_slope : Float = 0.05

///|
/// Maximum airspeed allowed for a safe landing.
pub let landing_max_speed : Float = 25.0

///|
/// Maximum pitch angle allowed during landing.
pub let landing_max_pitch : Float = 0.2

///|
/// Maximum roll angle allowed during landing.
pub let landing_max_roll : Float = 0.3

///|
/// Horizontal radius of the landing zone.
pub let landing_zone_radius : Float = 15.0

///|
/// Time the aircraft must hold landing conditions to succeed in seconds.
pub let landing_hold_time : Float = 1.5

// G-force parameters

///|
/// Normal gravitational force at 1G level flight.
pub let gforce_normal : Float = 1.0

///|
/// Maximum tolerable G-force before effects worsen.
pub let gforce_max : Float = 6.0

///|
/// G-force threshold that triggers pilot blackout.
pub let gforce_blackout : Float = 7.0

///|
/// G-force threshold above which the aircraft takes structural damage.
pub let gforce_damage_threshold : Float = 8.0

// Scoring

///|
/// Score awarded for collecting a checkpoint.
pub let score_checkpoint : Int = 100

///|
/// Score awarded for destroying an airborne enemy.
pub let score_air_kill : Int = 150

///|
/// Score awarded for destroying a ground enemy.
pub let score_ground_kill : Int = 75

///|
/// Score awarded for destroying a turret.
pub let score_turret_kill : Int = 50

///|
/// Score awarded for destroying a building.
pub let score_building_destroy : Int = 100

///|
/// Score awarded for completing a mission.
pub let score_mission_complete : Int = 500

///|
/// Bonus score awarded for a successful landing.
pub let score_landing_bonus : Int = 200

// Mission rating thresholds

///|
/// Minimum score required for an S rating.
pub let rating_s_threshold : Int = 2000

///|
/// Minimum score required for an A rating.
pub let rating_a_threshold : Int = 1500

///|
/// Minimum score required for a B rating.
pub let rating_b_threshold : Int = 1000

///|
/// Minimum score required for a C rating.
pub let rating_c_threshold : Int = 500

// Building types (extended)

///|
/// Building type identifier for barracks.
pub let building_barracks : Int = 6

///|
/// Building type identifier for fuel depots.
pub let building_fuel_depot : Int = 7

///|
/// Building type identifier for radar installations.
pub let building_radar : Int = 8

///|
/// Building type identifier for command centers.
pub let building_command : Int = 9

// Building HP values

///|
/// Hit points for hangar buildings.
pub let hp_hangar : Float = 200.0

///|
/// Hit points for control tower buildings.
pub let hp_tower : Float = 80.0

///|
/// Hit points for house buildings.
pub let hp_house : Float = 60.0

///|
/// Hit points for factory buildings.
pub let hp_factory : Float = 250.0

///|
/// Hit points for bunker buildings.
pub let hp_bunker : Float = 300.0

///|
/// Hit points for barracks buildings.
pub let hp_barracks : Float = 120.0

///|
/// Hit points for fuel depot buildings.
pub let hp_fuel_depot : Float = 90.0

///|
/// Hit points for radar installation buildings.
pub let hp_radar : Float = 70.0

///|
/// Hit points for command center buildings.
pub let hp_command : Float = 180.0

// Weapon damage multipliers by aircraft type

///|
/// Trainer weapon damage multiplier.
pub let trainer_damage_mult : Float = 0.8

///|
/// Fighter weapon damage multiplier.
pub let fighter_damage_mult : Float = 1.0

///|
/// Bomber weapon damage multiplier.
pub let bomber_damage_mult : Float = 1.3

///|
/// Interceptor weapon damage multiplier.
pub let interceptor_damage_mult : Float = 1.1

// Weapon fire rate multipliers by aircraft type

///|
/// Trainer fire rate multiplier.
pub let trainer_firerate_mult : Float = 1.2

///|
/// Fighter fire rate multiplier.
pub let fighter_firerate_mult : Float = 1.0

///|
/// Bomber fire rate multiplier.
pub let bomber_firerate_mult : Float = 0.7

///|
/// Interceptor fire rate multiplier.
pub let interceptor_firerate_mult : Float = 0.9

// Scoring constants (extended)

///|
/// Bonus score for 90% or higher accuracy.
pub let score_accuracy_bonus_90 : Int = 500

///|
/// Bonus score for 70% or higher accuracy.
pub let score_accuracy_bonus_70 : Int = 300

///|
/// Bonus score for 50% or higher accuracy.
pub let score_accuracy_bonus_50 : Int = 150

///|
/// Bonus score for completing a mission without taking damage.
pub let score_no_damage_bonus : Int = 400

///|
/// Bonus score for completing a mission well under par time.
pub let score_time_bonus_fast : Int = 500

///|
/// Bonus score for completing a mission under par time.
pub let score_time_bonus_good : Int = 300

///|
/// Bonus score for completing a mission near par time.
pub let score_time_bonus_ok : Int = 150

///|
/// Bonus score for a 3-kill streak.
pub let score_kill_streak_3 : Int = 100

///|
/// Bonus score for a 5-kill streak.
pub let score_kill_streak_5 : Int = 250

///|
/// Bonus score for a 10-kill streak.
pub let score_kill_streak_10 : Int = 500

// Kill values per enemy type

///|
/// Point value for destroying an enemy fighter.
pub let kill_value_fighter : Int = 150

///|
/// Point value for destroying a ground enemy.
pub let kill_value_ground : Int = 75

///|
/// Point value for destroying a turret.
pub let kill_value_turret : Int = 50

///|
/// Point value for destroying a building.
pub let kill_value_building : Int = 100

///|
/// Point value for destroying a boss enemy.
pub let kill_value_boss : Int = 500

// Weather effect parameters (extended)

///|
/// Number of rain particles spawned per frame.
pub let rain_particle_count : Int = 30

///|
/// Visual length of each rain streak.
pub let rain_line_length : Float = 1.5

///|
/// Alpha transparency of ground-level fog overlays.
pub let fog_ground_alpha : Int = 60

///|
/// Interval between lightning flashes during storms in seconds.
pub let storm_flash_interval : Float = 5.0

///|
/// Duration of a lightning flash in seconds.
pub let storm_flash_duration : Float = 0.15

// Cloud count by weather

///|
/// Target cloud count in clear weather.
pub let cloud_count_clear : Int = 8

///|
/// Target cloud count in cloudy weather.
pub let cloud_count_cloudy : Int = 25

///|
/// Target cloud count in storm weather.
pub let cloud_count_storm : Int = 30

///|
/// Default target cloud count for other weather types.
pub let cloud_count_default : Int = 12

// Terrain detail constants

///|
/// Probability of spawning a tree on a forest terrain chunk.
pub let tree_spawn_chance : Float = 0.3

///|
/// Probability of spawning a rock on a high terrain chunk.
pub let rock_spawn_chance : Float = 0.2

///|
/// Minimum height of procedurally placed trees.
pub let tree_min_height : Float = 3.0

///|
/// Maximum height of procedurally placed trees.
pub let tree_max_height : Float = 8.0

///|
/// Minimum size of procedurally placed rocks.
pub let rock_min_size : Float = 0.5

///|
/// Maximum size of procedurally placed rocks.
pub let rock_max_size : Float = 2.0

// Radar constants

///|
/// Maximum detection range of the HUD radar.
pub let radar_range : Float = 120.0

///|
/// Radar display size in pixels.
pub let radar_size : Int = 100

///|
/// Size of enemy blips on the radar in pixels.
pub let radar_blip_size : Int = 3

///|
/// Radar sweep line rotation speed.
pub let radar_sweep_speed : Float = 2.0

// Warning flash rates

///|
/// Default warning indicator flash rate in Hz.
pub let warning_flash_rate : Float = 4.0

///|
/// Low-fuel warning flash rate in Hz.
pub let warning_fuel_rate : Float = 3.0

///|
/// Stall warning flash rate in Hz.
pub let warning_stall_rate : Float = 6.0

///|
/// Low-altitude warning flash rate in Hz.
pub let warning_altitude_rate : Float = 5.0

// Mission par times (for time bonus calculation)

///|
/// Par time in seconds for the training mission.
pub let par_time_training : Float = 60.0

///|
/// Par time in seconds for the ground strike mission.
pub let par_time_ground_strike : Float = 90.0

///|
/// Par time in seconds for the dogfight mission.
pub let par_time_dogfight : Float = 120.0

///|
/// Par time in seconds for the fog navigation mission.
pub let par_time_fog_nav : Float = 90.0

///|
/// Par time in seconds for the landing mission.
pub let par_time_landing : Float = 60.0

///|
/// Par time in seconds for the valley assault mission.
pub let par_time_valley : Float = 150.0

///|
/// Par time in seconds for the storm runner mission.
pub let par_time_storm : Float = 120.0

///|
/// Par time in seconds for the air superiority mission.
pub let par_time_air_sup : Float = 120.0

///|
/// Par time in seconds for the base raid mission.
pub let par_time_base_raid : Float = 180.0

///|
/// Par time in seconds for the survival mission.
pub let par_time_survival : Float = 60.0

///|
/// Par time in seconds for the night recon mission.
pub let par_time_night : Float = 120.0

///|
/// Par time in seconds for the canyon run mission.
pub let par_time_canyon : Float = 90.0

///|
/// Par time in seconds for the base defense mission.
pub let par_time_defense : Float = 90.0

///|
/// Par time in seconds for the storm survival mission.
pub let par_time_storm_surv : Float = 90.0

///|
/// Par time in seconds for the final sortie mission.
pub let par_time_final : Float = 240.0
