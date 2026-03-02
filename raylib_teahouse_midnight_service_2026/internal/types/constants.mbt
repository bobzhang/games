///|
/// Window width in pixels.
pub let screen_w : Int = 1280

///|
/// Window height in pixels.
pub let screen_h : Int = 720

///|
/// Target frame rate for simulation and rendering.
pub let target_fps : Int = 120

///|
/// Height of the top HUD region in pixels.
pub let hud_h : Int = 110

///|
/// Left play-area boundary.
pub let play_left : Float = 46.0

///|
/// Right play-area boundary.
pub let play_right : Float = Float::from_int(screen_w) - 46.0

///|
/// Top play-area boundary.
pub let play_top : Float = Float::from_int(hud_h) + 18.0

///|
/// Bottom play-area boundary.
pub let play_bottom : Float = Float::from_int(screen_h) - 26.0

///|
/// Title screen state id.
pub let state_title : Int = 0

///|
/// Active stage state id.
pub let state_play : Int = 1

///|
/// Stage-clear transition state id.
pub let state_stage_clear : Int = 2

///|
/// Game-over state id.
pub let state_game_over : Int = 3

///|
/// Tea id for jasmine orders.
pub let tea_jasmine : Int = 0

///|
/// Tea id for oolong orders.
pub let tea_oolong : Int = 1

///|
/// Tea id for pu-erh orders.
pub let tea_puer : Int = 2

///|
/// Tea id for matcha orders.
pub let tea_matcha : Int = 3

///|
/// Tea id for berry blend orders.
pub let tea_berry : Int = 4

///|
/// Number of distinct tea types.
pub let tea_count : Int = 5

///|
/// Maximum customers tracked in the pool.
pub let max_customers : Int = 24

///|
/// Maximum spark particles tracked in the pool.
pub let max_sparks : Int = 860

///|
/// Maximum ring effects tracked in the pool.
pub let max_rings : Int = 86

///|
/// Maximum shadow effects tracked in the pool.
pub let max_shadows : Int = 320

///|
/// Number of simultaneous customer counter slots.
pub let customer_slots : Int = 6

///|
/// Player collision width.
pub let player_w : Float = 46.0

///|
/// Player collision height.
pub let player_h : Float = 58.0

///|
/// Player movement acceleration.
pub let player_accel : Float = 1260.0

///|
/// Velocity damping factor for player movement.
pub let player_drag : Float = 3.4

///|
/// Maximum player move speed.
pub let player_max_speed : Float = 360.0

///|
/// Dash cooldown duration.
pub let dash_cd_time : Float = 1.5

///|
/// Dash active duration.
pub let dash_time : Float = 0.2

///|
/// Dash movement speed.
pub let dash_speed : Float = 620.0

///|
/// Distance needed to interact with stations.
pub let interact_reach : Float = 84.0

///|
/// Distance needed to serve customers.
pub let serve_reach : Float = 104.0

///|
/// Base brew time before stage scaling.
pub let brew_time_base : Float = 1.9

///|
/// Minimum brew time after stage scaling.
pub let brew_time_min : Float = 1.1

///|
/// Base score goal for stage 1.
pub let stage_goal_base : Int = 1300

///|
/// Extra score goal added per stage.
pub let stage_goal_bonus : Int = 760

///|
/// Base stage timer in seconds.
pub let stage_time_base : Float = 72.0

///|
/// Extra stage time added per stage.
pub let stage_time_bonus : Float = 10.0

///|
/// Delay before advancing after a stage clear.
pub let stage_clear_wait : Float = 1.9

///|
/// Minimum customer spawn cooldown.
pub let spawn_cd_min : Float = 0.6

///|
/// Maximum customer spawn cooldown.
pub let spawn_cd_max : Float = 2.2

///|
/// Maximum reputation value.
pub let reputation_max : Float = 100.0

///|
/// Maximum focus meter value.
pub let focus_max : Float = 100.0

///|
/// Focus drain per second while focus mode is held.
pub let focus_drain : Float = 28.0

///|
/// Focus regeneration per second outside focus mode.
pub let focus_regen : Float = 20.0

///|
/// Focus spent when performing a dash.
pub let dash_focus_cost : Float = 14.0

///|
/// Reputation loss for serving the wrong tea.
pub let wrong_serve_penalty : Float = 8.0

///|
/// Reputation loss when a customer leaves unserved.
pub let miss_penalty : Float = 12.0

///|
/// Score bonus awarded when a stage is cleared.
pub let stage_clear_bonus : Int = 340

///|
/// Kettle station x-coordinate.
pub let kettle_x : Float = 164.0

///|
/// Kettle station y-coordinate.
pub let kettle_y : Float = 248.0

///|
/// Brewing station x-coordinate.
pub let brew_x : Float = 480.0

///|
/// Brewing station y-coordinate.
pub let brew_y : Float = 258.0

///|
/// Service counter x-coordinate.
pub let counter_x : Float = 958.0

///|
/// Service counter y-coordinate.
pub let counter_y : Float = 250.0

///|
/// Returns the x-coordinate of the tea leaf station.
pub fn leaf_x() -> Float {
  270.0
}

///|
/// Returns the y-coordinate of a tea leaf slot for a tea id.
pub fn leaf_y(tea : Int) -> Float {
  182.0 + Float::from_int(clampi(tea, 0, tea_count - 1)) * 86.0
}

///|
/// Returns world coordinates for a customer slot index.
pub fn customer_slot_pos(slot : Int) -> (Float, Float) {
  let s = clampi(slot, 0, customer_slots - 1)
  let row = s / 3
  let col = s % 3
  let x : Float = 822.0 + Float::from_int(col) * 140.0
  let y : Float = 424.0 + Float::from_int(row) * 134.0
  (x, y)
}

///|
/// Returns the top color of the scene gradient.
pub fn bg_top() -> @raylib.Color {
  @raylib.Color::new(14, 28, 52, 255)
}

///|
/// Returns the bottom color of the scene gradient.
pub fn bg_bottom() -> @raylib.Color {
  @raylib.Color::new(40, 74, 112, 255)
}

///|
/// Returns the amber accent color.
pub fn amber() -> @raylib.Color {
  @raylib.Color::new(255, 214, 126, 255)
}

///|
/// Returns the pink accent color.
pub fn pink() -> @raylib.Color {
  @raylib.Color::new(255, 126, 198, 255)
}

///|
/// Returns the cyan accent color.
pub fn cyan() -> @raylib.Color {
  @raylib.Color::new(108, 236, 255, 255)
}

///|
/// Returns the jade accent color.
pub fn jade() -> @raylib.Color {
  @raylib.Color::new(126, 244, 196, 255)
}

///|
/// Returns the reputation bar color.
pub fn reputation_col() -> @raylib.Color {
  @raylib.Color::new(255, 128, 166, 255)
}

///|
/// Returns the focus bar color.
pub fn focus_col() -> @raylib.Color {
  @raylib.Color::new(124, 244, 204, 255)
}

///|
/// Returns the display name for a tea id.
pub fn tea_name(t : Int) -> String {
  if t == tea_jasmine {
    "JASMINE"
  } else if t == tea_oolong {
    "OOLONG"
  } else if t == tea_puer {
    "PU-ERH"
  } else if t == tea_matcha {
    "MATCHA"
  } else {
    "BERRY"
  }
}

///|
/// Returns the cup color used for a tea id.
pub fn tea_color(t : Int) -> @raylib.Color {
  if t == tea_jasmine {
    @raylib.Color::new(246, 238, 178, 255)
  } else if t == tea_oolong {
    @raylib.Color::new(220, 154, 110, 255)
  } else if t == tea_puer {
    @raylib.Color::new(164, 94, 74, 255)
  } else if t == tea_matcha {
    @raylib.Color::new(124, 208, 126, 255)
  } else {
    @raylib.Color::new(236, 112, 152, 255)
  }
}

///|
/// Returns the square size for touch control buttons.
pub fn btn_size() -> Float {
  98.0
}

///|
/// Returns the rectangle for the touch left button.
pub fn btn_left_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (20.0, Float::from_int(screen_h) - s - 20.0, s, s)
}

///|
/// Returns the rectangle for the touch right button.
pub fn btn_right_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (130.0, Float::from_int(screen_h) - s - 20.0, s, s)
}

///|
/// Returns the rectangle for the touch up button.
pub fn btn_up_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (75.0, Float::from_int(screen_h) - s * 2.0 - 34.0, s, s)
}

///|
/// Returns the rectangle for the touch down button.
pub fn btn_down_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (75.0, Float::from_int(screen_h) - 20.0, s, s)
}

///|
/// Returns the rectangle for the touch interact button.
pub fn btn_interact_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s - 20.0,
    Float::from_int(screen_h) - s - 20.0,
    s,
    s,
  )
}

///|
/// Returns the rectangle for the touch focus button.
pub fn btn_focus_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s - 20.0,
    Float::from_int(screen_h) - s * 2.0 - 34.0,
    s,
    s,
  )
}

///|
/// Returns the rectangle for the touch dash button.
pub fn btn_dash_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s * 2.0 - 34.0,
    Float::from_int(screen_h) - s - 20.0,
    s,
    s,
  )
}

///|
/// Returns the rectangle for the title-screen start button.
pub fn title_start_rect() -> (Float, Float, Float, Float) {
  let w : Float = 420.0
  let h : Float = 88.0
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.65,
    w,
    h,
  )
}

///|
/// Returns the rectangle for the result-screen retry button.
pub fn retry_rect() -> (Float, Float, Float, Float) {
  let w : Float = 220.0
  let h : Float = 66.0
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.75,
    w,
    h,
  )
}
