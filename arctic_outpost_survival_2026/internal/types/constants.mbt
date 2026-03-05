///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1720

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 980

///|
/// Target frame rate used by the game loop.
pub let target_fps : Int = 120

///|
/// Enemy kind id for fast melee wolves.
pub let enemy_wolf : Int = 0

///|
/// Enemy kind id for slow armored brutes.
pub let enemy_brute : Int = 1

///|
/// Enemy kind id for agile shard creatures.
pub let enemy_shard : Int = 2

///|
/// Pickup kind id for fuel canisters.
pub let pickup_fuel : Int = 0

///|
/// Pickup kind id for medkits.
pub let pickup_medkit : Int = 1

///|
/// Pickup kind id for ammunition crates.
pub let pickup_ammo : Int = 2

///|
/// Pickup kind id for temporary overdrive boosts.
pub let pickup_overdrive : Int = 3

///|
/// Bullet kind id for the default projectile.
pub let bullet_normal : Int = 0

///|
/// Bullet kind id for piercing overdrive shots.
pub let bullet_pierce : Int = 1

///|
/// Maximum number of enemies allocated in the object pool.
pub let max_enemies : Int = 200

///|
/// Maximum number of pickups allocated in the object pool.
pub let max_pickups : Int = 100

///|
/// Maximum number of bullets allocated in the object pool.
pub let max_bullets : Int = 240

///|
/// Maximum number of particles allocated in the object pool.
pub let max_particles : Int = 1600

///|
/// Left edge of the playable world in pixels.
pub let world_x0 : Int = 24

///|
/// Top edge of the playable world in pixels.
pub let world_y0 : Int = 20

///|
/// Width of the playable world in pixels.
pub let world_w : Int = 1120

///|
/// Height of the playable world in pixels.
pub let world_h : Int = 940

///|
/// Left edge of the right-side information panel.
pub let panel_x0 : Int = world_x0 + world_w + 24

///|
/// Width of the right-side information panel.
pub let panel_w : Int = screen_w - panel_x0 - 24

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
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 290, 620, 580, 122)
}

///|
/// Returns the result-screen retry button rectangle.
pub fn retry_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 250, 648, 500, 110)
}

///|
/// Returns the on-screen left movement button rectangle.
pub fn btn_left() -> (Int, Int, Int, Int) {
  (1230, 730, 104, 96)
}

///|
/// Returns the on-screen right movement button rectangle.
pub fn btn_right() -> (Int, Int, Int, Int) {
  (1460, 730, 104, 96)
}

///|
/// Returns the on-screen up movement button rectangle.
pub fn btn_up() -> (Int, Int, Int, Int) {
  (1345, 624, 104, 96)
}

///|
/// Returns the on-screen down movement button rectangle.
pub fn btn_down() -> (Int, Int, Int, Int) {
  (1345, 836, 104, 96)
}

///|
/// Returns the on-screen fire action button rectangle.
pub fn btn_fire() -> (Int, Int, Int, Int) {
  (1582, 706, 110, 124)
}

///|
/// Returns the on-screen repair action button rectangle.
pub fn btn_repair() -> (Int, Int, Int, Int) {
  (1582, 846, 110, 94)
}

///|
/// Returns the on-screen tactical hint button rectangle.
pub fn btn_hint() -> (Int, Int, Int, Int) {
  (1582, 606, 110, 92)
}

///|
/// Returns the on-screen restart button rectangle.
pub fn btn_restart() -> (Int, Int, Int, Int) {
  (1462, 606, 110, 92)
}
