///|
/// Screen width in pixels.
pub let screen_w : Int = 960

///|
/// Screen height in pixels.
pub let screen_h : Int = 720

///|
/// Target frame rate.
pub let target_fps : Int = 60

///|
/// Tile size in pixels.
pub let tile_size : Int = 48

///|
/// Tile size as Float.
pub let tile_sizef : Float = 48.0

// ── Physics ─────────────────────────────────────────────

///|
/// Gravity applied while holding jump and still ascending.
pub let gravity_low : Float = 1200.0

///|
/// Gravity when not holding jump or when descending.
pub let gravity_high : Float = 3200.0

///|
/// Initial upward velocity when jumping.
pub let jump_velocity : Float = -700.0

///|
/// Upward velocity when bouncing off an enemy stomp.
pub let bounce_velocity : Float = -480.0

///|
/// Maximum horizontal walk speed.
pub let walk_speed : Float = 220.0

///|
/// Maximum horizontal run speed (holding run button).
pub let run_speed : Float = 380.0

///|
/// Horizontal acceleration on ground.
pub let ground_accel : Float = 900.0

///|
/// Horizontal deceleration (friction) on ground.
pub let ground_decel : Float = 700.0

///|
/// Horizontal acceleration in air.
pub let air_accel : Float = 600.0

///|
/// Terminal fall velocity.
pub let max_fall_speed : Float = 850.0

///|
/// Grace period after leaving a platform edge where jump is still allowed.
pub let coyote_time : Float = 0.083

///|
/// Input buffer: jump press registers this long before landing.
pub let jump_buffer_time : Float = 0.1

// ── Enemy ───────────────────────────────────────────────

///|
/// Goomba walk speed.
pub let goomba_speed : Float = 65.0

///|
/// Koopa Troopa walk speed.
pub let koopa_speed : Float = 55.0

///|
/// Koopa shell slide speed.
pub let shell_speed : Float = 500.0

///|
/// Maximum simultaneous active enemies.
pub let max_enemies : Int = 32

// ── New enemies ────────────────────────────────────────

///|
/// BuzzyBeetle walk speed (similar to Goomba, slightly faster).
pub let buzzy_beetle_speed : Float = 70.0

///|
/// BuzzyBeetle hop interval in seconds.
pub let buzzy_beetle_hop_interval : Float = 1.5

///|
/// BuzzyBeetle hop vertical velocity.
pub let buzzy_beetle_hop_velocity : Float = -320.0

///|
/// PiranhaPlant cycle: seconds extended.
pub let piranha_extend_time : Float = 2.0

///|
/// PiranhaPlant cycle: seconds retracted.
pub let piranha_retract_time : Float = 2.0

///|
/// PiranhaPlant full cycle time (extend + retract).
pub let piranha_cycle_time : Float = 4.0

///|
/// Firebar rotation speed in radians per second.
pub let firebar_rotation_speed : Float = 1.8

///|
/// Number of fire segments in a firebar.
pub let firebar_num_segments : Int = 5

///|
/// Radius of each firebar segment.
pub let firebar_segment_radius : Float = 8.0

///|
/// Spacing between firebar segments (center to center).
pub let firebar_segment_spacing : Float = 20.0

///|
/// BowserLite walk speed.
pub let bowser_speed : Float = 45.0

///|
/// BowserLite hit points.
pub let bowser_hp : Int = 5

///|
/// BowserLite fire breath rate (seconds between shots).
pub let bowser_fire_rate : Float = 2.5

///|
/// BowserLite fire breath projectile speed.
pub let bowser_fire_speed : Float = 250.0

///|
/// BowserLite patrol range from spawn point.
pub let bowser_patrol_range : Float = 120.0

///|
/// Maximum active Bowser fire breath projectiles.
pub let max_bowser_fireballs : Int = 8

// ── Items ───────────────────────────────────────────────

///|
/// Mushroom horizontal speed after emerging.
pub let mushroom_speed : Float = 130.0

///|
/// Star horizontal speed.
pub let star_speed : Float = 150.0

///|
/// Star bounce velocity.
pub let star_bounce_vel : Float = -500.0

///|
/// Fireball horizontal speed.
pub let fireball_speed_x : Float = 420.0

///|
/// Fireball bounce velocity on ground hit.
pub let fireball_bounce_vel : Float = -380.0

///|
/// Fireball gravity.
pub let fireball_gravity : Float = 1500.0

///|
/// Maximum active items on screen.
pub let max_items : Int = 16

///|
/// Maximum active fireballs.
pub let max_fireballs : Int = 8

// ── Player ──────────────────────────────────────────────

///|
/// Invulnerability duration after taking damage.
pub let invuln_duration : Float = 2.5

///|
/// Star power duration.
pub let star_duration : Float = 12.0

///|
/// Half-width of player collision box.
pub let player_half_w : Float = 16.0

///|
/// Height of small Mario.
pub let player_height_small : Float = 44.0

///|
/// Height of big/fire Mario.
pub let player_height_big : Float = 76.0

///|
/// Duration of grow-up animation.
pub let grow_duration : Float = 0.6

///|
/// Duration of shrink-down animation.
pub let shrink_duration : Float = 0.4

// ── Effects ─────────────────────────────────────────────

///|
/// Maximum active particles.
pub let max_particles : Int = 200

///|
/// Maximum active score popups.
pub let max_score_popups : Int = 16

///|
/// Maximum simultaneously bumping blocks.
pub let max_bumped_blocks : Int = 8

// ── Camera ──────────────────────────────────────────────

///|
/// Horizontal offset of player from left screen edge.
pub let camera_offset_x : Float = 300.0

// ── Scoring ─────────────────────────────────────────────

///|
/// Points for collecting a coin.
pub let score_coin : Int = 200

///|
/// Points for breaking a brick.
pub let score_brick : Int = 50

///|
/// Points for collecting a mushroom.
pub let score_mushroom : Int = 1000

///|
/// Points for collecting a fire flower.
pub let score_fire_flower : Int = 1000

///|
/// Points for collecting a star.
pub let score_star : Int = 1000

///|
/// Starting countdown timer per level.
pub let level_time : Float = 400.0

///|
/// Number of levels in the game.
pub let total_levels : Int = 4

///|
/// Returns points awarded for the nth consecutive stomp without touching ground.
pub fn stomp_score(combo : Int) -> Int {
  match combo {
    0 => 100
    1 => 200
    2 => 400
    3 => 500
    4 => 800
    5 => 1000
    6 => 2000
    7 => 4000
    _ => 8000
  }
}

///|
/// Returns a cycling rainbow color for star-power visual effect.
pub fn star_color(index : Int) -> @raylib.Color {
  match index % 5 {
    0 => @raylib.Color::new(252, 252, 0, 255)
    1 => @raylib.Color::new(0, 252, 0, 255)
    2 => @raylib.Color::new(252, 252, 252, 255)
    3 => @raylib.Color::new(252, 0, 0, 255)
    _ => @raylib.Color::new(0, 148, 252, 255)
  }
}
