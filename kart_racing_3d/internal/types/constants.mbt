// Screen

///|
/// Window width in pixels.
pub let screen_width : Int = 1024

///|
/// Window height in pixels.
pub let screen_height : Int = 768

// Kart constants

///|
/// Maximum number of karts in a race.
pub let max_karts : Int = 8

///|
/// Index of the player-controlled kart.
pub let player_kart : Int = 0

///|
/// Kart body width in world units.
pub let kart_width : Float = 0.8

///|
/// Kart body height in world units.
pub let kart_height : Float = 0.5

///|
/// Kart body length in world units.
pub let kart_length : Float = 1.2

// Kart type indices

///|
/// Kart type index for balanced all-round stats.
pub let kart_type_balanced : Int = 0

///|
/// Total number of available kart types.
pub let kart_type_count : Int = 8

// Kart type stats: (max_speed, acceleration, handling, weight, drift_boost)

///|
/// Per-kart-type tuples of max speed, acceleration, handling, weight, and drift boost multiplier.
pub let kart_stats : Array[(Float, Float, Float, Float, Float)] = [
  (28.0, 18.0, 2.8, 1.0, 1.0), // Balanced
  (33.0, 15.0, 2.4, 0.9, 0.8), // Speed - fast top speed, slower accel
  (25.0, 24.0, 2.6, 0.8, 0.9), // Accel - quick acceleration
  (26.0, 17.0, 3.5, 0.7, 1.1), // Handling - tight turns
  (30.0, 12.0, 2.0, 1.5, 0.7), // Heavy - high top speed, poor handling
  (27.0, 16.0, 3.0, 0.9, 1.5), // Drift - massive drift boosts
  (32.0, 20.0, 2.2, 0.8, 1.2), // Turbo - good speed and accel, poor handling
  (24.0, 22.0, 3.2, 0.5, 1.0), // Feather - light, nimble, slow
]

// Kart type names

///|
/// Display names for each kart type, indexed by kart type ID.
pub let kart_type_names : Array[String] = [
  "Balanced", "Speed", "Accel", "Handling", "Heavy", "Drift", "Turbo", "Feather",
]

// Character names for racers

///|
/// Display names for each racer character, indexed by character ID.
pub let character_names : Array[String] = [
  "Dash", "Blaze", "Leaf", "Sunny", "Violet", "Frost", "Ember", "Ghost",
]

// Physics

///|
/// Default forward acceleration in units per second squared.
pub let kart_accel : Float = 18.0

///|
/// Braking deceleration in units per second squared.
pub let kart_brake : Float = 25.0

///|
/// Default maximum forward speed in units per second.
pub let kart_max_speed : Float = 28.0

///|
/// Friction deceleration applied when coasting.
pub let kart_friction : Float = 8.0

///|
/// Steering sensitivity multiplier while drifting.
pub let drift_steer_mult : Float = 1.6

///|
/// Friction reduction multiplier while drifting.
pub let drift_friction_mult : Float = 0.6

///|
/// Gravitational acceleration in units per second squared.
pub let gravity : Float = 20.0

///|
/// Upward velocity applied when launching off a jump ramp.
pub let jump_ramp_force : Float = 12.0

///|
/// Steering sensitivity multiplier while airborne.
pub let air_steer_mult : Float = 0.4

// Powerup types

///|
/// Powerup type ID for no held item.
pub let powerup_none : Int = 0

///|
/// Powerup type ID for speed boost mushroom.
pub let powerup_boost : Int = 1

///|
/// Powerup type ID for defensive shield.
pub let powerup_shield : Int = 2

///|
/// Powerup type ID for homing missile.
pub let powerup_missile : Int = 3

///|
/// Powerup type ID for droppable oil slick trap.
pub let powerup_oil_slick : Int = 4

///|
/// Powerup type ID for lightning bolt strike.
pub let powerup_lightning : Int = 5

///|
/// Powerup type ID for invincibility star.
pub let powerup_star : Int = 6

///|
/// Powerup type ID for droppable banana peel trap.
pub let powerup_banana : Int = 7

///|
/// Powerup type ID for triple mushroom boost.
pub let powerup_triple_mushroom : Int = 8

///|
/// Total number of distinct powerup types including none.
pub let powerup_type_count : Int = 9

// Powerup effects

///|
/// Duration of speed boost effect in seconds.
pub let boost_duration : Float = 2.0

///|
/// Speed added to max speed during a boost.
pub let boost_speed_add : Float = 12.0

///|
/// Duration of shield protection in seconds.
pub let shield_duration : Float = 5.0

///|
/// Travel speed of a fired missile projectile.
pub let missile_speed : Float = 40.0

///|
/// Time in seconds an oil slick persists on track.
pub let oil_slick_lifetime : Float = 15.0

///|
/// Duration of lightning bolt slow effect in seconds.
pub let lightning_duration : Float = 4.0

///|
/// Speed multiplier applied to karts struck by lightning.
pub let lightning_slow_mult : Float = 0.5

///|
/// Duration of star invincibility in seconds.
pub let star_duration : Float = 6.0

///|
/// Speed bonus added during star power.
pub let star_speed_add : Float = 6.0

///|
/// Time in seconds a banana peel persists on track.
pub let banana_lifetime : Float = 20.0

///|
/// Duration of each triple mushroom boost use in seconds.
pub let triple_mushroom_boost : Float = 1.2

// Object pools

///|
/// Maximum number of powerup pickups on the track.
pub let max_powerups : Int = 32

///|
/// Maximum number of active projectiles in flight.
pub let max_projectiles : Int = 16

///|
/// Maximum number of active particles for visual effects.
pub let max_particles : Int = 256

///|
/// Maximum number of dropped items on the track.
pub let max_dropped_items : Int = 24

// Track segment types

///|
/// Segment type ID for a straight section.
pub let seg_straight : Int = 0

// Track surface types

///|
/// Surface type ID for standard paved road.
pub let surface_road : Int = 0

///|
/// Surface type ID for off-road dirt.
pub let surface_dirt : Int = 1

///|
/// Surface type ID for off-road grass.
pub let surface_grass : Int = 2

///|
/// Surface type ID for a speed boost pad.
pub let surface_boost_pad : Int = 3

///|
/// Surface type ID for an oil-slicked area.
pub let surface_oil : Int = 4

///|
/// Surface type ID for icy terrain.
pub let surface_ice : Int = 5

// Surface grip multipliers

///|
/// Grip multiplier on standard road surface.
pub let grip_road : Float = 1.0

///|
/// Grip multiplier on dirt surface.
pub let grip_dirt : Float = 0.7

///|
/// Grip multiplier on grass surface.
pub let grip_grass : Float = 0.5

///|
/// Grip multiplier on boost pad surface.
pub let grip_boost_pad : Float = 1.0

///|
/// Grip multiplier on oil-slicked surface.
pub let grip_oil : Float = 0.3

///|
/// Grip multiplier on icy surface.
pub let grip_ice : Float = 0.35

// Surface speed multipliers

///|
/// Top speed multiplier on standard road.
pub let speed_mult_road : Float = 1.0

///|
/// Top speed multiplier on dirt surface.
pub let speed_mult_dirt : Float = 0.75

///|
/// Top speed multiplier on grass surface.
pub let speed_mult_grass : Float = 0.55

///|
/// Top speed multiplier on boost pad surface.
pub let speed_mult_boost_pad : Float = 1.3

///|
/// Top speed multiplier on oil-slicked surface.
pub let speed_mult_oil : Float = 0.9

///|
/// Top speed multiplier on icy surface.
pub let speed_mult_ice : Float = 0.95

// Drift boost levels

///|
/// Drift level ID for no active drift boost.
pub let drift_level_none : Int = 0

///|
/// Drift level ID for mini turbo boost.
pub let drift_level_mini : Int = 1

///|
/// Drift level ID for super turbo boost.
pub let drift_level_super : Int = 2

///|
/// Drift level ID for ultra turbo boost.
pub let drift_level_ultra : Int = 3

// Drift level timing thresholds (seconds of sustained drift)

///|
/// Seconds of sustained drift required for mini turbo.
pub let drift_mini_threshold : Float = 0.6

///|
/// Seconds of sustained drift required for super turbo.
pub let drift_super_threshold : Float = 1.5

///|
/// Seconds of sustained drift required for ultra turbo.
pub let drift_ultra_threshold : Float = 2.8

// Drift boost power per level

///|
/// Speed bonus for a mini drift boost release.
pub let drift_mini_boost : Float = 4.0

///|
/// Speed bonus for a super drift boost release.
pub let drift_super_boost : Float = 8.0

///|
/// Speed bonus for an ultra drift boost release.
pub let drift_ultra_boost : Float = 14.0

// Drift boost duration per level

///|
/// Duration of mini drift boost in seconds.
pub let drift_mini_duration : Float = 0.4

///|
/// Duration of super drift boost in seconds.
pub let drift_super_duration : Float = 0.8

///|
/// Duration of ultra drift boost in seconds.
pub let drift_ultra_duration : Float = 1.3

// Track

///|
/// Maximum number of waypoints per track layout.
pub let max_waypoints : Int = 64

///|
/// Full width of the road surface in world units.
pub let road_width : Float = 8.0

///|
/// Half width of the road surface in world units.
pub let road_half : Float = 4.0

///|
/// Default number of laps per race.
pub let total_laps : Int = 3

// Cup / race

///|
/// Total number of cups in the championship.
pub let cups_count : Int = 4

///|
/// Number of races in each cup.
pub let races_per_cup : Int = 4

// Cup point system (position 1-8)

///|
/// Points awarded per finishing position from 1st through 8th place.
pub let cup_points_table : Array[Int] = [15, 12, 10, 8, 6, 5, 4, 3]

// Camera

///|
/// Vertical field of view in degrees.
pub let camera_fovy : Float = 55.0

///|
/// Distance of the chase camera behind the kart.
pub let camera_dist : Float = 8.0

///|
/// Height of the chase camera above the kart.
pub let camera_height : Float = 4.0

///|
/// Smoothing factor for chase camera interpolation.
pub let camera_smooth : Float = 5.0

///|
/// Lateral camera offset applied while drifting.
pub let camera_drift_offset : Float = 1.5

///|
/// Additional field of view degrees added during boost.
pub let camera_boost_fov_add : Float = 8.0

// AI rubber-banding

///|
/// Speed boost added to AI karts trailing the player.
pub let ai_rubberband_behind : Float = 0.12

///|
/// Speed reduction applied to AI karts ahead of the player.
pub let ai_rubberband_ahead : Float = 0.08

///|
/// AI difficulty level ID for medium mode.
pub let ai_difficulty_medium : Int = 1

// AI difficulty modifiers: (speed_mult, item_luck, line_accuracy, reaction_time)

///|
/// Per-difficulty tuples of speed multiplier, item luck, line accuracy, and reaction time.
pub let ai_difficulty_stats : Array[(Float, Float, Float, Float)] = [
  (0.85, 0.7, 0.6, 1.5), // Easy
  (0.92, 0.85, 0.8, 1.0), // Medium
  (0.97, 1.0, 0.92, 0.6), // Hard
  (1.02, 1.1, 0.98, 0.3), // Expert
]

// Countdown

///|
/// Duration of the pre-race countdown in seconds.
pub let countdown_total : Float = 3.0

// Colors for karts (r,g,b)

///|
/// Primary RGB colors for each kart, indexed by kart slot.
pub let kart_colors : Array[(Int, Int, Int)] = [
  (220, 40, 40), // Player - Red
  (40, 100, 220), // Blue
  (40, 200, 40), // Green
  (220, 200, 40), // Yellow
  (200, 60, 200), // Purple
  (40, 200, 200), // Cyan
  (220, 130, 40), // Orange
  (200, 200, 200), // White
]

// Track theme indices

///|
/// Theme index for standard circuit tracks.
pub let theme_circuit : Int = 0

///|
/// Theme index for beach tracks.
pub let theme_beach : Int = 1

///|
/// Theme index for mountain tracks.
pub let theme_mountain : Int = 2

///|
/// Theme index for castle tracks.
pub let theme_castle : Int = 3

///|
/// Theme index for desert tracks.
pub let theme_desert : Int = 4

///|
/// Theme index for ice tracks.
pub let theme_ice : Int = 5

///|
/// Theme index for night city tracks.
pub let theme_night : Int = 6

///|
/// Theme index for volcano tracks.
pub let theme_volcano : Int = 7

// Theme sky colors (r, g, b)

///|
/// Sky background RGB colors for each track theme.
pub let theme_sky_colors : Array[(Int, Int, Int)] = [
  (100, 180, 255), // Circuit - blue sky
  (130, 200, 255), // Beach - bright sky
  (140, 160, 200), // Mountain - hazy
  (80, 90, 140), // Castle - overcast
  (220, 180, 100), // Desert - warm
  (180, 210, 240), // Ice - pale
  (20, 25, 50), // Night - dark
  (120, 60, 40), // Volcano - smoky
]

// Theme ground colors (r, g, b)

///|
/// Ground plane RGB colors for each track theme.
pub let theme_ground_colors : Array[(Int, Int, Int)] = [
  (80, 160, 60), // Circuit - green grass
  (220, 200, 140), // Beach - sand
  (100, 120, 80), // Mountain - alpine
  (60, 80, 50), // Castle - dark grass
  (200, 170, 100), // Desert - sand
  (220, 230, 240), // Ice - snow
  (40, 50, 40), // Night - dark
  (80, 50, 35), // Volcano - dark rock
]

// Wrong way detection

///|
/// Angle threshold in radians beyond which a kart is considered going the wrong way.
pub let wrong_way_angle_threshold : Float = 2.0

///|
/// Flash animation speed for wrong way warning overlay.
pub let wrong_way_flash_speed : Float = 4.0

// Stun/spin durations

///|
/// Duration of kart spin-out from a standard hit in seconds.
pub let spin_duration : Float = 1.5

///|
/// Duration of kart spin-out from a lightning strike in seconds.
pub let lightning_spin_duration : Float = 1.0

///|
/// Minimum spin duration from a weight-based bump collision in seconds.
pub let bump_spin_threshold : Float = 0.8

// Weight-based collision

///|
/// Minimum weight difference required to trigger a bump spin.
pub let weight_spin_diff : Float = 0.5

// Decoration density

///|
/// Height of trackside barrier objects in world units.
pub let barrier_height : Float = 0.6

///|
/// Width of trackside barrier objects in world units.
pub let barrier_width : Float = 0.3

// PI

///|
/// Approximation of pi.
pub let pi : Float = 3.14159265

///|
/// Approximation of two pi (full circle in radians).
pub let two_pi : Float = 6.28318530

// Track decoration types

///|
/// Decoration type ID for green deciduous tree.
pub let deco_tree_green : Int = 1

///|
/// Decoration type ID for pine tree.
pub let deco_tree_pine : Int = 2

///|
/// Decoration type ID for palm tree.
pub let deco_tree_palm : Int = 3

///|
/// Decoration type ID for small rock.
pub let deco_rock_small : Int = 4

///|
/// Decoration type ID for large rock.
pub let deco_rock_large : Int = 5

///|
/// Decoration type ID for metal barrier.
pub let deco_barrier_metal : Int = 6

///|
/// Decoration type ID for tire barrier stack.
pub let deco_barrier_tire : Int = 7

///|
/// Decoration type ID for spectator grandstand.
pub let deco_grandstand : Int = 8

///|
/// Decoration type ID for small building.
pub let deco_building_small : Int = 9

///|
/// Decoration type ID for tall building.
pub let deco_building_tall : Int = 10

///|
/// Decoration type ID for cactus.
pub let deco_cactus : Int = 11

///|
/// Decoration type ID for snow mound.
pub let deco_snow_mound : Int = 12

///|
/// Decoration type ID for volcanic lava rock.
pub let deco_lava_rock : Int = 13

///|
/// Decoration type ID for lamp post.
pub let deco_lamp_post : Int = 14

///|
/// Decoration type ID for sign board.
pub let deco_sign_board : Int = 15

// Particle configuration constants

///|
/// Number of confetti particles spawned at race start.
pub let confetti_count : Int = 20

// Kart accent colors (for trim/details)

///|
/// Dark accent RGB colors for kart trim and detail rendering.
pub let kart_accent_colors : Array[(Int, Int, Int)] = [
  (150, 20, 20), // Dark Red
  (20, 60, 150), // Dark Blue
  (20, 130, 20), // Dark Green
  (180, 160, 20), // Dark Yellow
  (130, 30, 130), // Dark Purple
  (20, 140, 140), // Dark Cyan
  (180, 90, 20), // Dark Orange
  (140, 140, 140), // Gray
]

// Character stats modifiers (speed_bonus, accel_bonus, weight_bonus, drift_bonus)

///|
/// Per-character stat modifier tuples for speed, acceleration, weight, and drift bonuses.
pub let character_stats : Array[(Float, Float, Float, Float)] = [
  (1.0, 1.0, 1.0, 1.0), // Dash - balanced
  (1.1, 0.9, 0.9, 1.0), // Blaze - fast
  (0.9, 1.1, 0.8, 1.1), // Leaf - nimble
  (1.0, 1.0, 0.9, 1.0), // Sunny - balanced-light
  (0.95, 1.05, 1.0, 1.1), // Violet - drift focus
  (1.05, 0.95, 1.1, 0.9), // Frost - heavy-fast
  (1.1, 1.1, 0.8, 0.9), // Ember - glass cannon
  (0.9, 0.9, 0.7, 1.2), // Ghost - light drifter
]

// Track record times (in seconds) for each track

///|
/// Best record times in seconds for each track, indexed by track ID.
pub let track_record_times : Array[Float] = [
  65.0, // Green Meadow Oval
   72.0, // Crosswind Circuit
   68.0, // Sunny Circuit
   75.0, // Beach Loop
   80.0, // Mountain Pass
   78.0, // Castle Circuit
   85.0, // S-Curve Challenge
   76.0, // Bridge Run
   88.0, // Technical Circuit
   82.0, // Desert Storm
   90.0, // Ice Track
   84.0, // Night City
   95.0, // Rainbow Road
   92.0, // Volcano Run
   87.0, // Deep Trench
   100.0, // Grand Prix
]

// Track difficulty ratings (1-5 stars)

///|
/// Difficulty star ratings from 1 to 5 for each track, indexed by track ID.
pub let track_difficulty_ratings : Array[Int] = [
  1, // Green Meadow Oval
   1, // Crosswind Circuit
   2, // Sunny Circuit
   2, // Beach Loop
   3, // Mountain Pass
   3, // Castle Circuit
   3, // S-Curve Challenge
   3, // Bridge Run
   4, // Technical Circuit
   4, // Desert Storm
   4, // Ice Track
   4, // Night City
   5, // Rainbow Road
   5, // Volcano Run
   4, // Deep Trench
   5, // Grand Prix
]
