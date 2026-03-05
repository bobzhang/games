///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1520

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 920

///|
/// Target frame rate used by the game loop.
pub let target_fps : Int = 120

///|
/// Maximum enemies allocated in the enemy pool.
pub let max_enemy_slots : Int = 84

///|
/// Arena left pixel coordinate.
pub let arena_x : Int = 120

///|
/// Arena top pixel coordinate.
pub let arena_y : Int = 90

///|
/// Arena width in pixels.
pub let arena_w : Int = 1280

///|
/// Arena height in pixels.
pub let arena_h : Int = 760

///|
/// Returns arena left boundary in world coordinates.
pub fn arena_left() -> Float {
  Float::from_int(arena_x)
}

///|
/// Returns arena right boundary in world coordinates.
pub fn arena_right() -> Float {
  Float::from_int(arena_x + arena_w)
}

///|
/// Returns arena top boundary in world coordinates.
pub fn arena_top() -> Float {
  Float::from_int(arena_y)
}

///|
/// Returns arena bottom boundary in world coordinates.
pub fn arena_bottom() -> Float {
  Float::from_int(arena_y + arena_h)
}

///|
/// Returns arena center X in world coordinates.
pub fn arena_center_x() -> Float {
  Float::from_int(arena_x + arena_w / 2)
}

///|
/// Returns arena center Y in world coordinates.
pub fn arena_center_y() -> Float {
  Float::from_int(arena_y + arena_h / 2)
}

///|
/// Collision radius of the player.
pub let player_radius : Float = 22.0

///|
/// Maximum player health value.
pub let player_max_health : Float = 100.0

///|
/// Maximum player stamina value.
pub let player_max_stamina : Float = 100.0

///|
/// Player movement acceleration.
pub let player_move_accel : Float = 1700.0

///|
/// Friction factor applied to player movement.
pub let player_friction : Float = 6.3

///|
/// Invulnerability duration after taking damage.
pub let player_hit_invuln : Float = 0.56

///|
/// Stamina cost of a light attack.
pub let light_attack_cost : Float = 14.0

///|
/// Damage dealt by a light attack.
pub let light_attack_damage : Float = 34.0

///|
/// Effective range of a light attack.
pub let light_attack_range : Float = 118.0

///|
/// Dot-product threshold defining light attack arc.
pub let light_attack_arc_dot : Float = 0.10

///|
/// Cooldown duration after a light attack.
pub let light_attack_cooldown : Float = 0.20

///|
/// Animation duration for a light attack.
pub let light_attack_anim_t : Float = 0.16

///|
/// Stamina cost of a heavy attack.
pub let heavy_attack_cost : Float = 30.0

///|
/// Damage dealt by a heavy attack.
pub let heavy_attack_damage : Float = 58.0

///|
/// Effective range of a heavy attack.
pub let heavy_attack_range : Float = 170.0

///|
/// Dot-product threshold defining heavy attack arc.
pub let heavy_attack_arc_dot : Float = -0.22

///|
/// Cooldown duration after a heavy attack.
pub let heavy_attack_cooldown : Float = 0.44

///|
/// Animation duration for a heavy attack.
pub let heavy_attack_anim_t : Float = 0.30

///|
/// Stamina cost to trigger parry dash.
pub let parry_dash_cost : Float = 22.0

///|
/// Active window duration for parry state.
pub let parry_active_t : Float = 0.24

///|
/// Duration of dash movement.
pub let dash_t : Float = 0.16

///|
/// Movement speed during dash.
pub let dash_speed : Float = 900.0

///|
/// Damage dealt by a successful parry counter.
pub let parry_counter_damage : Float = 46.0

///|
/// Effective range of parry counter.
pub let parry_range : Float = 102.0

///|
/// Fast stamina regeneration rate when idle.
pub let stamina_regen_fast : Float = 27.0

///|
/// Slow stamina regeneration rate under activity.
pub let stamina_regen_slow : Float = 14.0

///|
/// Time allowed before combo chain expires.
pub let combo_timeout : Float = 2.3

///|
/// Minimum enemy telegraph duration.
pub let enemy_telegraph_min : Float = 0.64

///|
/// Maximum enemy telegraph duration.
pub let enemy_telegraph_max : Float = 1.18

///|
/// Timing window where enemy strikes can be parried.
pub let enemy_parry_window : Float = 0.24

///|
/// Duration of enemy strike state.
pub let enemy_strike_t : Float = 0.22

///|
/// Duration of enemy recovery state.
pub let enemy_recover_t : Float = 0.48

///|
/// Duration of enemy stunned state.
pub let enemy_stunned_t : Float = 0.95

///|
/// Contact damage from enemy collision.
pub let enemy_contact_damage : Float = 16.0

///|
/// Delay between completed waves.
pub let wave_gap_duration : Float = 1.25

///|
/// Base enemy spawn interval.
pub let spawn_interval_base : Float = 0.96

///|
/// Minimum enemy spawn interval cap.
pub let spawn_interval_min : Float = 0.30

///|
/// Player attack type.
pub(all) enum Attack {
  None
  Light
  Heavy
} derive(Eq)

///|
/// Enemy AI behavior state.
pub(all) enum EnemyState {
  Seek
  Telegraph
  Strike
  Recover
  Stunned
} derive(Eq)

///|
/// Top-level game state.
pub(all) enum GameState {
  Title
  Playing
  Paused
  GameOver
} derive(Eq)
