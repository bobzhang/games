// Screen

///|
/// Framebuffer width in pixels.
pub let screen_width : Int = 1280

///|
/// Framebuffer height in pixels.
pub let screen_height : Int = 720

// Arena dimensions

///|
/// Arena width along world X axis.
pub let arena_width : Float = 60.0

///|
/// Arena depth along world Z axis.
pub let arena_depth : Float = 60.0

///|
/// Height of perimeter arena walls.
pub let arena_wall_height : Float = 4.0

///|
/// Thickness of perimeter arena walls.
pub let arena_wall_thickness : Float = 1.0

// Pillar

///|
/// Number of central arena pillars spawned at match start.
pub let pillar_count : Int = 8

///|
/// Radius of each pillar collider/mesh.
pub let pillar_radius : Float = 1.2

///|
/// Height of each pillar mesh.
pub let pillar_height : Float = 5.0

// Crate

///|
/// Uniform side length of crate meshes.
pub let crate_size : Float = 1.5

// Ramp dimensions

///|
/// Ramp width used for collision/rendering.
pub let ramp_width : Float = 4.0

///|
/// Ramp run length from base to top.
pub let ramp_length : Float = 6.0

///|
/// Ramp rise height from floor to top platform.
pub let ramp_height : Float = 2.5

// Low wall (half-cover)

///|
/// Horizontal width of each low wall.
pub let low_wall_width : Float = 4.0

///|
/// Vertical height of low wall cover.
pub let low_wall_height : Float = 1.5

///|
/// Thickness/depth of low wall cover.
pub let low_wall_depth : Float = 0.6

// Weapon types

///|
/// Total number of weapon ids.
pub let weapon_count : Int = 6

// Weapon fire rates (seconds between shots)

///|
/// Seconds between pistol shots.
pub let rate_pistol : Float = 0.35

///|
/// Seconds between shotgun shots.
pub let rate_shotgun : Float = 0.85

///|
/// Seconds between rifle shots.
pub let rate_rifle : Float = 0.09

///|
/// Seconds between sniper shots.
pub let rate_sniper : Float = 1.2

///|
/// Seconds between rocket shots.
pub let rate_rocket : Float = 1.5

///|
/// Seconds between minigun rounds at full spin.
pub let rate_minigun : Float = 0.06

// Weapon damage

///|
/// Base per-shot pistol damage.
pub let dmg_pistol : Float = 15.0

///|
/// Base per-pellet shotgun damage.
pub let dmg_shotgun : Float = 8.0

///|
/// Base per-shot rifle damage.
pub let dmg_rifle : Float = 8.0

///|
/// Base per-shot sniper damage.
pub let dmg_sniper : Float = 80.0

///|
/// Base direct-hit rocket damage.
pub let dmg_rocket : Float = 80.0

///|
/// Base per-shot minigun damage.
pub let dmg_minigun : Float = 6.0

// Weapon ammo (starting)

///|
/// Starting reserve ammo for pistol (effectively infinite economy baseline).
pub let ammo_pistol : Int = 999

///|
/// Starting reserve ammo for shotgun.
pub let ammo_shotgun : Int = 20

///|
/// Starting reserve ammo for rifle.
pub let ammo_rifle : Int = 90

///|
/// Starting reserve ammo for sniper rifle.
pub let ammo_sniper : Int = 10

///|
/// Starting reserve ammo for rocket launcher.
pub let ammo_rocket : Int = 5

///|
/// Starting reserve ammo for minigun.
pub let ammo_minigun : Int = 200

// Weapon max reserve ammo

// Weapon projectile speed

///|
/// Pistol projectile speed.
pub let speed_pistol : Float = 60.0

///|
/// Shotgun pellet projectile speed.
pub let speed_shotgun : Float = 50.0

///|
/// Rifle projectile speed.
pub let speed_rifle : Float = 80.0

///|
/// Sniper projectile speed.
pub let speed_sniper : Float = 120.0

///|
/// Rocket projectile speed.
pub let speed_rocket : Float = 25.0

///|
/// Minigun projectile speed.
pub let speed_minigun : Float = 70.0

// Shotgun pellets

///|
/// Pellet count fired per shotgun shot.
pub let shotgun_pellets : Int = 8

///|
/// Random spread cone factor for shotgun pellets.
pub let shotgun_spread : Float = 0.12

// Sniper penetration count

///|
/// Number of enemies a sniper round can penetrate.
pub let sniper_penetration : Int = 3

// Rocket splash

///|
/// Splash damage radius for rockets.
pub let rocket_splash_radius : Float = 5.0

// Minigun spin-up time

///|
/// Spin-up duration before minigun reaches full fire rate.
pub let minigun_spinup_time : Float = 0.6

///|
/// Maximum spread while minigun is unstable.
pub let minigun_max_spread : Float = 0.08

///|
/// Minimum spread while minigun is stabilized.
pub let minigun_min_spread : Float = 0.02

// Weapon reload times

///|
/// Reload duration for pistol.
pub let reload_pistol : Float = 1.0

///|
/// Reload duration for shotgun.
pub let reload_shotgun : Float = 2.2

///|
/// Reload duration for rifle.
pub let reload_rifle : Float = 1.8

///|
/// Reload duration for sniper rifle.
pub let reload_sniper : Float = 2.5

///|
/// Reload duration for rocket launcher.
pub let reload_rocket : Float = 3.0

///|
/// Reload duration for minigun.
pub let reload_minigun : Float = 4.0

// Weapon magazine sizes

///|
/// Magazine size for pistol.
pub let mag_pistol : Int = 12

///|
/// Magazine size for shotgun.
pub let mag_shotgun : Int = 6

///|
/// Magazine size for rifle.
pub let mag_rifle : Int = 30

///|
/// Magazine size for sniper rifle.
pub let mag_sniper : Int = 5

///|
/// Magazine size for rocket launcher.
pub let mag_rocket : Int = 1

///|
/// Magazine size for minigun.
pub let mag_minigun : Int = 100

// Weapon upgrade cost multiplier per level

// Max upgrade level per stat

// Enemy types

// Player

///|
/// Standing camera/player eye height.
pub let player_height : Float = 1.8

///|
/// Base walk speed in arena units per second.
pub let player_speed : Float = 8.0

///|
/// Multiplier applied to speed while sprinting.
pub let player_sprint_mult : Float = 1.6

///|
/// Multiplier applied to speed while crouching.
pub let player_crouch_mult : Float = 0.5

///|
/// Target eye height while crouched.
pub let player_crouch_height : Float = 1.1

///|
/// Player collision radius for obstacle/enemy pushes.
pub let player_radius : Float = 0.5

///|
/// Maximum player health.
pub let player_max_hp : Float = 100.0

///|
/// Maximum player armor value.
pub let player_max_armor : Float = 100.0

///|
/// Mouse look sensitivity scalar.
pub let player_mouse_sensitivity : Float = 0.003

///|
/// Invulnerability window after taking damage (seconds).
pub let player_damage_cooldown : Float = 0.3

// Camera

///|
/// Perspective camera field-of-view angle.
pub let camera_fovy : Float = 70.0

// Pool sizes

///|
/// Maximum active enemies in pool.
pub let max_enemies : Int = 128

///|
/// Maximum active projectiles in pool.
pub let max_projectiles : Int = 256

///|
/// Maximum active particles in pool.
pub let max_particles : Int = 512

///|
/// Maximum active pickups in pool.
pub let max_pickups : Int = 32

///|
/// Maximum active arena traps in pool.
pub let max_traps : Int = 12

///|
/// Maximum active barricades in pool.
pub let max_barricades : Int = 16

///|
/// Number of kill-feed lines shown simultaneously.
pub let max_kill_feed : Int = 5

// Wave timing

///|
/// Shop/intermission duration between waves in seconds.
pub let wave_shop_time : Float = 15.0

///|
/// Baseline interval between enemy spawns during active waves.
pub let spawn_interval : Float = 0.6

///|
/// Total number of waves in the full run.
pub let max_waves : Int = 30

// Spawn distance from center range

///|
/// Minimum radial distance from center used for enemy spawns.
pub let spawn_min_dist : Float = 25.0

///|
/// Maximum radial distance from center used for enemy spawns.
pub let spawn_max_dist : Float = 28.0

// Shop costs

///|
/// Shop price for health restoration.
pub let cost_heal : Int = 50

///|
/// Shop price for armor restoration.
pub let cost_armor : Int = 40

///|
/// Shop price for shotgun ammo bundle.
pub let cost_shotgun_ammo : Int = 30

///|
/// Shop price for rifle ammo bundle.
pub let cost_rifle_ammo : Int = 25

///|
/// Shop price for sniper ammo bundle.
pub let cost_sniper_ammo : Int = 50

///|
/// Shop price for rocket ammo bundle.
pub let cost_rocket_ammo : Int = 60

///|
/// Shop price for minigun ammo bundle.
pub let cost_minigun_ammo : Int = 45

///|
/// Shop price for damage upgrade.
pub let cost_damage_up : Int = 100

///|
/// Shop price for speed upgrade.
pub let cost_speed_up : Int = 80

///|
/// Shop price to unlock sniper weapon.
pub let cost_buy_sniper : Int = 200

///|
/// Shop price to unlock rocket launcher.
pub let cost_buy_rocket : Int = 300

///|
/// Shop price to unlock minigun.
pub let cost_buy_minigun : Int = 400

///|
/// Shop price to place one barricade.
pub let cost_barricade : Int = 60

///|
/// Shop price to place one spike trap.
pub let cost_trap_spike : Int = 80

// Pickup types

///|
/// Pickup id for health restoration.
pub let pickup_health : Int = 0

///|
/// Pickup id for ammo refill.
pub let pickup_ammo : Int = 1

///|
/// Pickup id for temporary speed boost.
pub let pickup_speed_boost : Int = 2

///|
/// Pickup id for temporary damage boost.
pub let pickup_damage_boost : Int = 3

///|
/// Pickup id for temporary shield.
pub let pickup_shield : Int = 4

///|
/// Pickup id for nuke effect.
pub let pickup_nuke : Int = 5

// Pickup durations

///|
/// Duration of speed boost pickup effect.
pub let pickup_speed_duration : Float = 10.0

///|
/// Duration of damage boost pickup effect.
pub let pickup_damage_duration : Float = 10.0

///|
/// Duration of shield pickup effect.
pub let pickup_shield_duration : Float = 8.0

// Arena trap types

// Trap stats

///|
/// Damage dealt by spike trap activation.
pub let trap_spike_damage : Float = 30.0

///|
/// Cooldown between spike trap activations.
pub let trap_spike_cooldown : Float = 3.0

///|
/// Active flame duration once triggered.
pub let trap_flame_duration : Float = 2.0

///|
/// Cooldown between electric trap pulses.
pub let trap_electric_cooldown : Float = 4.0

///|
/// Stun duration applied by electric trap.
pub let trap_electric_stun : Float = 1.5

// Barricade

///|
/// Maximum HP for placed barricades.
pub let barricade_max_hp : Float = 150.0

///|
/// Square footprint size of barricades.
pub let barricade_size : Float = 2.0

// Combo system

///|
/// Time window to continue a combo chain after a kill.
pub let combo_timeout : Float = 3.0

///|
/// Base score multiplier at combo start.
pub let combo_base_mult : Float = 1.0

///|
/// Multiplier increase per combo step.
pub let combo_increment : Float = 0.25

///|
/// Hard cap for combo score multiplier.
pub let combo_max_mult : Float = 4.0

// Headshot

///|
/// Damage multiplier applied to headshot hits.
pub let headshot_mult : Float = 2.5

///|
/// Fraction of enemy height treated as head region.
pub let headshot_head_ratio : Float = 0.2

// Gravity for projectiles

///|
/// Gravity acceleration used for projectile arcs/ballistics.
pub let gravity : Float = 9.8

// Exploder

///|
/// Explosion radius for exploder self-detonation.
pub let exploder_radius : Float = 4.0

///|
/// Damage dealt by exploder detonation.
pub let exploder_damage : Float = 40.0

// Necromancer

///|
/// Range within which necromancer can revive allies.
pub let necro_revive_range : Float = 12.0

///|
/// Cooldown between necromancer revive attempts.
pub let necro_revive_cooldown : Float = 8.0

// Shield enemy

///|
/// Angular threshold (radians) for shield block arc checks.
pub let shield_block_angle : Float = 1.2

// Score bonuses

///|
/// Bonus score/money granted for headshot kills.
pub let bonus_headshot : Int = 25

///|
/// Bonus granted for rapid double kill streak.
pub let bonus_double_kill : Int = 50

///|
/// Bonus granted for rapid triple kill streak.
pub let bonus_triple_kill : Int = 100

///|
/// Bonus granted for larger multi-kill streaks.
pub let bonus_multi_kill : Int = 200

// Kill feed

///|
/// Visibility duration for kill-feed entries.
pub let kill_feed_duration : Float = 3.0

// Particle types (used as kind tag)

// PI constant

///|
/// Shared PI constant used by radial arena math.
pub let pi : Float = 3.14159265

///|
/// Enemy variant.
pub(all) enum EnemyKind {
  Zombie
  Runner
  Brute
  Spitter
  Exploder
  Necromancer
  Shielded
  Boss
} derive(Eq)

///|
/// Particle effect type.
pub(all) enum ParticleKind {
  Blood
  Muzzle
  Explosion
  Shell
  Spark
  Heal
} derive(Eq)

///|
/// Trap type.
pub(all) enum Trap {
  Spike
  Flame
  Electric
} derive(Eq)

///|
/// Weapon variant.
pub(all) enum WeaponKind {
  Pistol
  Shotgun
  Rifle
  Sniper
  Rocket
  Minigun
} derive(Eq)

// Minimap

// Difficulty scaling per wave
