///|
/// Width of the game window in pixels.
pub let screen_w : Int32 = 1720

///|
/// Height of the game window in pixels.
pub let screen_h : Int32 = 980

///|
/// Target frame rate used by the game loop.
pub let target_fps : Int32 = 120

///|
/// Maximum number of enemies allocated in the object pool.
pub let max_enemies : Int32 = 200

///|
/// Maximum number of pickups allocated in the object pool.
pub let max_pickups : Int32 = 100

///|
/// Maximum number of bullets allocated in the object pool.
pub let max_bullets : Int32 = 240

///|
/// Maximum number of particles allocated in the object pool.
pub let max_particles : Int32 = 1600

///|
/// Left edge of the playable world in pixels.
pub let world_x0 : Int32 = 24

///|
/// Top edge of the playable world in pixels.
pub let world_y0 : Int32 = 20

///|
/// Width of the playable world in pixels.
pub let world_w : Int32 = 1120

///|
/// Height of the playable world in pixels.
pub let world_h : Int32 = 940

///|
/// Left edge of the right-side information panel.
pub let panel_x0 : Int32 = world_x0 + world_w + 24

///|
/// Width of the right-side information panel.
pub let panel_w : Int32 = screen_w - panel_x0 - 24

///|
/// Collision radius of the player character.
pub let player_r : Float = 22.0

///|
/// Collision radius of the core generator.
pub let core_r : Float = 72.0

///|
/// Survival duration required to win the run, in seconds.
pub let survival_time_goal : Float = 200.0

///|
/// Returns the horizontal center of the core generator.
pub fn core_x() -> Float {
  Float::from_int(world_x0 + world_w / 2)
}

///|
/// Returns the vertical center of the core generator.
pub fn core_y() -> Float {
  Float::from_int(world_y0 + world_h / 2 - 90)
}

///|
/// Returns the title-screen start button rectangle.
pub fn start_button_rect() -> (Int32, Int32, Int32, Int32) {
  (screen_w / 2 - 290, 620, 580, 122)
}

///|
/// Returns the result-screen retry button rectangle.
pub fn retry_button_rect() -> (Int32, Int32, Int32, Int32) {
  (screen_w / 2 - 250, 648, 500, 110)
}

///|
/// Returns the on-screen left movement button rectangle.
pub fn btn_left() -> (Int32, Int32, Int32, Int32) {
  (1230, 730, 104, 96)
}

///|
/// Returns the on-screen right movement button rectangle.
pub fn btn_right() -> (Int32, Int32, Int32, Int32) {
  (1460, 730, 104, 96)
}

///|
/// Returns the on-screen up movement button rectangle.
pub fn btn_up() -> (Int32, Int32, Int32, Int32) {
  (1345, 624, 104, 96)
}

///|
/// Returns the on-screen down movement button rectangle.
pub fn btn_down() -> (Int32, Int32, Int32, Int32) {
  (1345, 836, 104, 96)
}

///|
/// Returns the on-screen fire action button rectangle.
pub fn btn_fire() -> (Int32, Int32, Int32, Int32) {
  (1582, 706, 110, 124)
}

///|
/// Returns the on-screen repair action button rectangle.
pub fn btn_repair() -> (Int32, Int32, Int32, Int32) {
  (1582, 846, 110, 94)
}

///|
/// Returns the on-screen tactical hint button rectangle.
pub fn btn_hint() -> (Int32, Int32, Int32, Int32) {
  (1582, 606, 110, 92)
}

///|
/// Returns the on-screen restart button rectangle.
pub fn btn_restart() -> (Int32, Int32, Int32, Int32) {
  (1462, 606, 110, 92)
}

///|
/// Classifies the three enemy archetypes in the arctic outpost.
pub(all) enum EnemyKind {
  Wolf
  Brute
  Shard
} derive(Eq)

///|
pub extend EnemyKind with Eq::{not_equal, equal}

///|
/// Classifies the four supply pickup types that can spawn.
pub(all) enum PickupKind {
  Fuel
  Medkit
  Ammo
  Overdrive
} derive(Eq)

///|
pub extend PickupKind with Eq::{not_equal, equal}

///|
/// Classifies the two projectile types the player can fire.
pub(all) enum BulletKind {
  Normal
  Pierce
} derive(Eq)

///|
pub extend BulletKind with Eq::{not_equal, equal}

///|
/// Classifies the three visual particle effect categories.
pub(all) enum ParticleKind {
  Default
  Damage
  OverdriveEffect
} derive(Eq)

///|
pub extend ParticleKind with Eq::{not_equal, equal}
