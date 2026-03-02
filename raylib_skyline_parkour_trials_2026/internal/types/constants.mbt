///|
/// Width of the game window in pixels.
pub let screen_w : Int = 1366

///|
/// Height of the game window in pixels.
pub let screen_h : Int = 768

///|
/// Target frame rate used by the game loop.
pub let target_fps : Int = 120

///|
/// Number of stages in the full parkour trial.
pub let stage_count : Int = 3

///|
/// Maximum solid/hazard tiles allocated.
pub let max_tiles : Int = 128

///|
/// Maximum checkpoints allocated.
pub let max_checkpoints : Int = 12

///|
/// Player collider width in world units.
pub let player_w : Float = 34.0

///|
/// Player collider height in world units.
pub let player_h : Float = 54.0

///|
/// Gravity acceleration applied to the player.
pub let gravity : Float = 2140.0

///|
/// Terminal fall-speed cap for the player.
pub let max_fall_speed : Float = 980.0

///|
/// Ground acceleration while running.
pub let run_accel_ground : Float = 2700.0

///|
/// Air acceleration while moving.
pub let run_accel_air : Float = 1650.0

///|
/// Maximum horizontal run speed.
pub let run_max_speed : Float = 420.0

///|
/// Ground drag used to decelerate horizontal motion.
pub let run_drag_ground : Float = 2300.0

///|
/// Air drag used to decelerate horizontal motion.
pub let run_drag_air : Float = 820.0

///|
/// Initial vertical jump speed.
pub let jump_speed : Float = 780.0

///|
/// Extra gravity applied when jump is cut short.
pub let jump_cut_gravity : Float = 2400.0

///|
/// Lifetime of buffered jump input in seconds.
pub let jump_buffer_time : Float = 0.13

///|
/// Grace period after leaving ground in seconds.
pub let coyote_time : Float = 0.11

///|
/// Time window for wall-jump eligibility.
pub let wall_jump_window : Float = 0.17

///|
/// Horizontal impulse applied by wall jump.
pub let wall_jump_push : Float = 470.0

///|
/// Vertical speed applied by wall jump.
pub let wall_jump_speed : Float = 820.0

///|
/// Clamped slide speed while on a wall.
pub let wall_slide_speed : Float = 210.0

///|
/// Maximum continuous wall-climb time.
pub let wall_climb_time_max : Float = 0.62

///|
/// Upward acceleration while wall climbing.
pub let wall_climb_up_accel : Float = 1650.0

///|
/// Maximum upward speed while wall climbing.
pub let wall_climb_up_speed : Float = 220.0

///|
/// Maximum value rendered for stage timer.
pub let timer_cap : Float = 99.9

///|
/// Extra Y padding below stage for fail-out detection.
pub let stage_fail_y_pad : Float = 210.0

///|
/// Returns initial timer budget for a stage index.
pub fn stage_initial_time(stage : Int) -> Float {
  if stage <= 1 {
    42.0
  } else if stage == 2 {
    36.0
  } else {
    32.0
  }
}

///|
/// Returns checkpoint bonus seconds granted on stage clear.
pub fn stage_clear_bonus(stage : Int) -> Int {
  if stage == 1 {
    9
  } else if stage == 2 {
    8
  } else {
    0
  }
}

///|
/// Returns touch rectangle for moving left.
pub fn touch_left_rect() -> (Float, Float, Float, Float) {
  let s : Float = 94.0
  let y = Float::from_int(screen_h) - s - 22.0
  (20.0, y, s, s)
}

///|
/// Returns touch rectangle for moving right.
pub fn touch_right_rect() -> (Float, Float, Float, Float) {
  let s : Float = 94.0
  let y = Float::from_int(screen_h) - s - 22.0
  (126.0, y, s, s)
}

///|
/// Returns touch rectangle for jump action.
pub fn touch_jump_rect() -> (Float, Float, Float, Float) {
  let s : Float = 94.0
  let y = Float::from_int(screen_h) - s - 22.0
  (Float::from_int(screen_w) - s - 22.0, y, s, s)
}

///|
/// Returns touch rectangle for climb/hold action.
pub fn touch_climb_rect() -> (Float, Float, Float, Float) {
  let s : Float = 94.0
  let y = Float::from_int(screen_h) - s - 22.0
  (Float::from_int(screen_w) - s * 2.0 - 36.0, y, s, s)
}

///|
/// Returns top-right touch rectangle for in-run restart.
pub fn touch_play_restart_rect() -> (Float, Float, Float, Float) {
  (Float::from_int(screen_w) - 146.0, 16.0, 130.0, 44.0)
}

///|
/// Returns title screen start button rectangle.
pub fn title_start_rect() -> (Float, Float, Float, Float) {
  let w : Float = 320.0
  let h : Float = 82.0
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.62,
    w,
    h,
  )
}

///|
/// Returns stage-end "next stage" panel button rectangle.
pub fn panel_next_rect() -> (Float, Float, Float, Float) {
  let w : Float = 230.0
  let h : Float = 72.0
  (
    Float::from_int(screen_w) * 0.5 - w - 14.0,
    Float::from_int(screen_h) * 0.66,
    w,
    h,
  )
}

///|
/// Returns stage-end restart panel button rectangle.
pub fn panel_restart_rect() -> (Float, Float, Float, Float) {
  let w : Float = 230.0
  let h : Float = 72.0
  (
    Float::from_int(screen_w) * 0.5 + 14.0,
    Float::from_int(screen_h) * 0.66,
    w,
    h,
  )
}

///|
/// Top background gradient color.
pub fn col_bg_top() -> @raylib.Color {
  @raylib.Color::new(18, 24, 44, 255)
}

///|
/// Bottom background gradient color.
pub fn col_bg_bottom() -> @raylib.Color {
  @raylib.Color::new(8, 10, 20, 255)
}

///|
/// Sky glow accent color.
pub fn col_sky_glow() -> @raylib.Color {
  @raylib.Color::new(80, 132, 220, 90)
}

///|
/// Base rooftop tile color.
pub fn col_roof() -> @raylib.Color {
  @raylib.Color::new(54, 66, 96, 255)
}

///|
/// Rooftop edge highlight color.
pub fn col_roof_edge() -> @raylib.Color {
  @raylib.Color::new(98, 130, 196, 230)
}

///|
/// Checkpoint marker color.
pub fn col_checkpoint() -> @raylib.Color {
  @raylib.Color::new(84, 220, 255, 255)
}

///|
/// Goal marker color.
pub fn col_goal() -> @raylib.Color {
  @raylib.Color::new(146, 255, 150, 255)
}

///|
/// Primary HUD/text color.
pub fn col_text_main() -> @raylib.Color {
  @raylib.Color::new(234, 244, 255, 255)
}

///|
/// Secondary dimmed HUD/text color.
pub fn col_text_dim() -> @raylib.Color {
  @raylib.Color::new(178, 198, 228, 255)
}

///|
/// Player color while normal running.
pub fn col_player_run() -> @raylib.Color {
  @raylib.Color::new(255, 214, 106, 255)
}

///|
/// Player color while interacting with walls.
pub fn col_player_wall() -> @raylib.Color {
  @raylib.Color::new(255, 148, 104, 255)
}
