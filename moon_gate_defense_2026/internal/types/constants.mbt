///|
/// Window width in pixels.
pub let screen_w : Int = 1420

///|
/// Window height in pixels.
pub let screen_h : Int = 900

///|
/// Target frame rate for the main loop.
pub let target_fps : Int = 120

///|
/// Number of horizontal cells on the defense board.
pub let grid_cols : Int = 11

///|
/// Number of vertical cells on the defense board.
pub let grid_rows : Int = 7

///|
/// Size of a single board cell in pixels.
pub let cell_size : Int = 82

///|
/// Total board width in pixels.
pub let board_w : Int = grid_cols * cell_size

///|
/// Total board height in pixels.
pub let board_h : Int = grid_rows * cell_size

///|
/// Left edge of the board in screen coordinates.
pub let board_x : Int = (screen_w - board_w) / 2

///|
/// Top edge of the board in screen coordinates.
pub let board_y : Int = 168

///|
/// Gate column index on the board grid.
pub let gate_gx : Int = grid_cols / 2

///|
/// Gate row index on the board grid.
pub let gate_gy : Int = grid_rows / 2

///|
/// Visual radius of the gate core.
pub let gate_radius : Float = 44.0

///|
/// Hit radius used for gate collision checks.
pub let gate_hit_radius : Float = 30.0

///|
/// Maximum gate health at run start.
pub let gate_hp_max : Float = 260.0

///|
/// Maximum number of node slots allocated in the pool.
pub let max_nodes : Int = grid_cols * grid_rows

///|
/// Maximum number of enemies tracked at once.
pub let max_enemies : Int = 200

///|
/// Maximum number of projectile bolts tracked at once.
pub let max_bolts : Int = 300

///|
/// Maximum number of pulse effects tracked at once.
pub let max_pulses : Int = 320

///|
/// Highest upgrade level available to a node.
pub let node_max_level : Int = 3

///|
/// Energy cost to build a level 1 node.
pub let node_build_cost : Float = 36.0

///|
/// Energy cost to upgrade a node from level 1 to level 2.
pub let node_upgrade_cost_l2 : Float = 52.0

///|
/// Energy cost to upgrade a node from level 2 to level 3.
pub let node_upgrade_cost_l3 : Float = 76.0

///|
/// Refund ratio applied when selling a node.
pub let node_sell_ratio : Float = 0.65

///|
/// Attack range for a level 1 node.
pub let node_range_l1 : Float = 168.0

///|
/// Attack range for a level 2 node.
pub let node_range_l2 : Float = 218.0

///|
/// Attack range for a level 3 node.
pub let node_range_l3 : Float = 270.0

///|
/// Damage dealt by a level 1 node shot.
pub let node_damage_l1 : Float = 17.0

///|
/// Damage dealt by a level 2 node shot.
pub let node_damage_l2 : Float = 28.0

///|
/// Damage dealt by a level 3 node shot.
pub let node_damage_l3 : Float = 42.0

///|
/// Fire cooldown for a level 1 node.
pub let node_fire_cd_l1 : Float = 0.58

///|
/// Fire cooldown for a level 2 node.
pub let node_fire_cd_l2 : Float = 0.40

///|
/// Fire cooldown for a level 3 node.
pub let node_fire_cd_l3 : Float = 0.27

///|
/// Travel speed of node projectiles.
pub let node_projectile_speed : Float = 620.0

///|
/// Squared cone threshold used for node firing arc checks.
pub let node_cone_dot_sq : Float = 0.22

///|
/// Lifetime of a projectile bolt before despawn.
pub let bolt_life : Float = 1.2

///|
/// Hit radius of a projectile bolt.
pub let bolt_hit_radius : Float = 8.0

///|
/// Starting energy when a run begins.
pub let energy_start : Float = 120.0

///|
/// Maximum storable energy.
pub let energy_max : Float = 320.0

///|
/// Passive energy regeneration per second.
pub let energy_regen : Float = 13.5

///|
/// Flat energy reward granted when a wave starts.
pub let wave_energy_bonus : Float = 12.0

///|
/// Delay before a newly announced wave starts spawning.
pub let wave_intro_delay : Float = 0.8

///|
/// Base enemy count for the first wave.
pub let wave_spawn_count_base : Int = 7

///|
/// Additional enemies added per wave step.
pub let wave_spawn_count_step : Int = 3

///|
/// Initial enemy spawn interval.
pub let spawn_cd_base : Float = 0.95

///|
/// Minimum allowed enemy spawn interval.
pub let spawn_cd_min : Float = 0.20

///|
/// Base health for newly spawned enemies.
pub let enemy_base_hp : Float = 28.0

///|
/// Additional enemy health added per wave.
pub let enemy_hp_per_wave : Float = 5.2

///|
/// Base movement speed for enemies.
pub let enemy_base_speed : Float = 62.0

///|
/// Additional enemy speed added per wave.
pub let enemy_speed_per_wave : Float = 5.0

///|
/// Base gate damage dealt by enemy contact.
pub let enemy_contact_damage_base : Float = 12.0

///|
/// Additional gate contact damage added per wave.
pub let enemy_contact_damage_wave : Float = 1.5

///|
/// Time window in seconds for maintaining combo chains.
pub let combo_window : Float = 2.5

///|
/// Bonus score gained for each combo step.
pub let combo_score_step : Int = 4

///|
/// Charge required to activate the barrier burst.
pub let barrier_charge_goal : Float = 100.0

///|
/// Barrier charge gained per kill.
pub let barrier_charge_kill : Float = 11.0

///|
/// Extra barrier charge gained from combo count.
pub let barrier_charge_combo : Float = 1.8

///|
/// Maximum combo count that contributes to barrier charge.
pub let barrier_charge_combo_cap : Int = 12

///|
/// Effective radius of the barrier burst.
pub let barrier_radius : Float = 235.0

///|
/// Damage dealt by barrier activation.
pub let barrier_damage : Float = 95.0

///|
/// Knockback impulse applied by barrier activation.
pub let barrier_push : Float = 72.0

///|
/// Lifetime of the barrier flash effect.
pub let barrier_flash_time : Float = 0.56

///|
/// Camera shake duration after a gate hit.
pub let shake_time_hit : Float = 0.22

///|
/// Cardinal direction used for node facing and cursor movement.
pub(all) enum Dir {
  Up
  Right
  Down
  Left
} derive(Eq)

///|
/// Rotates a direction clockwise by one step.
pub fn Dir::rotate_cw(self : Dir) -> Dir {
  match self {
    Up => Right
    Right => Down
    Down => Left
    Left => Up
  }
}

///|
/// Enemy type that determines stats and visual appearance.
pub(all) enum EnemyKind {
  Skitter
  Carapace
  Wraith
} derive(Eq)

///|
/// Returns the integer ordinal of an enemy kind.
pub fn EnemyKind::to_int(self : EnemyKind) -> Int {
  match self {
    Skitter => 0
    Carapace => 1
    Wraith => 2
  }
}

///|
/// Top-level game state controlling which screen is active.
pub(all) enum GameState {
  Title
  Playing
  Paused
  GameOver
} derive(Eq)
