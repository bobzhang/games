/// Window width in pixels.
pub let screen_w : Int = 1280

/// Window height in pixels.
pub let screen_h : Int = 720

/// Target frame rate for gameplay.
pub let target_fps : Int = 120

/// Title screen state id.
pub let state_title : Int = 0

/// Active heist gameplay state id.
pub let state_play : Int = 1

/// Stage-clear transition state id.
pub let state_stage_clear : Int = 2

/// Game-over state id.
pub let state_game_over : Int = 3

/// Entity kind id for patrol guards.
pub let ent_guard : Int = 0

/// Entity kind id for flying drones.
pub let ent_drone : Int = 1

/// Entity kind id for stationary turrets.
pub let ent_turret : Int = 2

/// Entity kind id for explosive crates.
pub let ent_crate : Int = 3

/// Entity kind id for armor pickups.
pub let ent_medkit : Int = 4

/// Entity kind id for heat pickups.
pub let ent_battery : Int = 5

/// Entity kind id for signal loot pickups.
pub let ent_signal : Int = 6

/// Maximum entities tracked in the pool.
pub let max_ents : Int = 380

/// Maximum projectiles tracked in the pool.
pub let max_shots : Int = 460

/// Maximum spark effects tracked in the pool.
pub let max_fx : Int = 800

/// Maximum ring effects tracked in the pool.
pub let max_rings : Int = 76

/// Maximum shadow effects tracked in the pool.
pub let max_shadows : Int = 220

/// Player collision width.
pub let player_w : Float = Float::from_int(42)

/// Player collision height.
pub let player_h : Float = Float::from_int(76)

/// Horizontal movement acceleration.
pub let player_accel_x : Float = Float::from_int(1380)

/// Horizontal velocity damping factor.
pub let player_drag_x : Float = Float::from_int(4)

/// Maximum horizontal speed.
pub let player_max_vx : Float = Float::from_int(380)

/// Downward acceleration.
pub let gravity : Float = Float::from_int(1550)

/// Maximum falling speed.
pub let fall_max : Float = Float::from_int(760)

/// Initial vertical velocity for jumps.
pub let jump_speed : Float = Float::from_int(680)

/// Dash cooldown duration.
pub let dash_cd_time : Float = 1.4

/// Dash active duration.
pub let dash_time : Float = 0.2

/// Dash horizontal speed.
pub let dash_speed : Float = Float::from_int(600)

/// Hook ability cooldown duration.
pub let hook_cd_time : Float = 2.3

/// Hook ability active duration.
pub let hook_time : Float = 0.72

/// Hook effect radius.
pub let hook_radius : Float = Float::from_int(240)

/// Instant-kill radius during hook impact.
pub let hook_kill_radius : Float = Float::from_int(100)

/// Invulnerability window after taking damage.
pub let invuln_time : Float = 0.62

/// Base cooldown between player shots.
pub let fire_cd_base : Float = 0.15

/// Projectile speed for player shots.
pub let shot_speed : Float = Float::from_int(780)

/// Projectile speed for enemy shots.
pub let enemy_shot_speed : Float = Float::from_int(320)

/// Lifetime of each shot in seconds.
pub let shot_life : Float = 1.4

/// Base world scroll speed.
pub let base_scroll : Float = Float::from_int(250)

/// Additional scroll speed per stage.
pub let stage_scroll_bonus : Float = Float::from_int(28)

/// Base distance goal for stage completion.
pub let stage_goal_base : Float = Float::from_int(2200)

/// Extra distance goal added per stage.
pub let stage_goal_bonus : Float = Float::from_int(700)

/// Initial x position used when spawning incoming entities.
pub let spawn_start_x : Float = Float::from_int(screen_w) + 100.0

/// Minimum gap between spawned entities.
pub let spawn_gap_min : Float = 120.0

/// Maximum gap between spawned entities.
pub let spawn_gap_max : Float = 220.0

/// Number of vertical lanes on the train route.
pub let lane_count : Int = 3

/// Distance between adjacent lane centers.
pub let lane_gap : Float = Float::from_int(120)

/// Y coordinate of the top lane center.
pub let lane_top : Float = Float::from_int(282)

/// Maximum armor meter value.
pub let armor_max : Float = Float::from_int(100)

/// Maximum heat meter value.
pub let heat_max : Float = Float::from_int(100)

/// Passive heat drain per second.
pub let heat_drain_base : Float = Float::from_int(3)

/// Extra heat drain per second while dashing.
pub let heat_drain_dash : Float = Float::from_int(6)

/// Heat gained from battery pickups.
pub let heat_pickup : Float = Float::from_int(24)

/// Passive armor regeneration per second.
pub let armor_passive : Float = 0.38

/// Delay before advancing after stage clear.
pub let stage_clear_wait : Float = 1.86

/// Height of the HUD area in pixels.
pub let hud_h : Int = 112

/// Returns the square size used by touch controls.
pub fn btn_size() -> Float {
  Float::from_int(104)
}

/// Returns the rectangle for the touch left button.
pub fn btn_left_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(20),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

/// Returns the rectangle for the touch right button.
pub fn btn_right_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(134),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

/// Returns the rectangle for the touch jump button.
pub fn btn_jump_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(248),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

/// Returns the rectangle for the touch fire button.
pub fn btn_fire_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s - Float::from_int(20),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

/// Returns the rectangle for the touch dash button.
pub fn btn_dash_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s * Float::from_int(2) - Float::from_int(34),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

/// Returns the rectangle for the touch hook button.
pub fn btn_hook_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s - Float::from_int(20),
    Float::from_int(screen_h) - s * Float::from_int(2) - Float::from_int(34),
    s,
    s,
  )
}

/// Returns the rectangle for the title-screen start button.
pub fn title_start_rect() -> (Float, Float, Float, Float) {
  let w = Float::from_int(420)
  let h = Float::from_int(88)
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.64,
    w,
    h,
  )
}

/// Returns the rectangle for the result-screen retry button.
pub fn retry_rect() -> (Float, Float, Float, Float) {
  let w = Float::from_int(220)
  let h = Float::from_int(64)
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.74,
    w,
    h,
  )
}

/// Returns the top color of the polar background gradient.
pub fn bg_top() -> @raylib.Color {
  @raylib.Color::new(8, 16, 30, 255)
}

/// Returns the bottom color of the polar background gradient.
pub fn bg_bottom() -> @raylib.Color {
  @raylib.Color::new(14, 34, 56, 255)
}

/// Returns the base snow highlight color.
pub fn snow_col() -> @raylib.Color {
  @raylib.Color::new(230, 244, 255, 255)
}

/// Returns the cyan accent color.
pub fn cyan() -> @raylib.Color {
  @raylib.Color::new(94, 238, 255, 255)
}

/// Returns the pink accent color.
pub fn pink() -> @raylib.Color {
  @raylib.Color::new(255, 114, 214, 255)
}

/// Returns the amber accent color.
pub fn amber() -> @raylib.Color {
  @raylib.Color::new(255, 214, 124, 255)
}

/// Returns the armor bar color.
pub fn armor_col() -> @raylib.Color {
  @raylib.Color::new(255, 122, 154, 255)
}

/// Returns the heat bar color.
pub fn heat_col() -> @raylib.Color {
  @raylib.Color::new(116, 244, 196, 255)
}
