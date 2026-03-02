/// Window width in pixels.
pub let screen_w : Int = 1280

/// Window height in pixels.
pub let screen_h : Int = 720

/// Target frame rate for the main loop.
pub let target_fps : Int = 120

/// HUD strip height in pixels.
pub let hud_h : Int = 112

/// Left boundary of the playable area.
pub let play_left : Float = 42.0

/// Right boundary of the playable area.
pub let play_right : Float = Float::from_int(screen_w) - 42.0

/// Top boundary of the playable area.
pub let play_top : Float = Float::from_int(hud_h) + 18.0

/// Bottom boundary of the playable area.
pub let play_bottom : Float = Float::from_int(screen_h) - 24.0

/// Returns the shrine center x-coordinate.
pub fn shrine_x() -> Float {
  Float::from_int(screen_w) * 0.5
}

/// Returns the shrine center y-coordinate.
pub fn shrine_y() -> Float {
  Float::from_int(screen_h) * 0.55
}

/// Returns the bell orbit radius around the shrine.
pub fn bell_orbit_r() -> Float {
  220.0
}

/// Returns world coordinates for bell index `i`.
pub fn bell_pos(i : Int) -> (Float, Float) {
  let cx = shrine_x()
  let cy = shrine_y()
  let r = bell_orbit_r()
  let k = i % bell_count

  if k == 0 {
    (cx, cy - r)
  } else if k == 1 {
    (cx + r, cy)
  } else if k == 2 {
    (cx, cy + r)
  } else {
    (cx - r, cy)
  }
}

/// Enemy kind id for wisps.
pub let foe_wisp : Int = 0

/// Enemy kind id for brutes.
pub let foe_brute : Int = 1

/// Enemy kind id for shamans.
pub let foe_shaman : Int = 2

/// Entity kind id for relic pickups.
pub let foe_relic : Int = 3

/// Maximum foe records in the pool.
pub let max_foes : Int = 380

/// Maximum bolt records in the pool.
pub let max_bolts : Int = 420

/// Maximum spark records in the pool.
pub let max_sparks : Int = 900

/// Maximum ring records in the pool.
pub let max_rings : Int = 96

/// Maximum echo records in the pool.
pub let max_echoes : Int = 320

/// Hero collision width.
pub let hero_w : Float = 46.0

/// Hero collision height.
pub let hero_h : Float = 52.0

/// Hero movement acceleration.
pub let hero_accel : Float = 1400.0

/// Hero velocity damping factor.
pub let hero_drag : Float = 3.6

/// Hero maximum movement speed.
pub let hero_max_speed : Float = 390.0

/// Invulnerability duration after taking damage.
pub let hero_invuln_time : Float = 0.62

/// Duration of the hurt animation feedback.
pub let hero_hurt_time : Float = 0.56

/// Dash cooldown duration.
pub let dash_cd_time : Float = 1.2

/// Dash active duration.
pub let dash_time : Float = 0.2

/// Dash movement speed.
pub let dash_speed : Float = 700.0

/// Number of bells guarding the shrine.
pub let bell_count : Int = 4

/// Activation reach distance for bell ringing.
pub let bell_ring_reach : Float = 138.0

/// Cooldown time before a bell can ring again.
pub let bell_cd_time : Float = 1.38

/// Spirit cost to activate a bell ring.
pub let bell_cost : Float = 18.0

/// Radius of the bell shockwave effect.
pub let bell_shock_radius : Float = 180.0

/// Damage dealt by a bell shockwave.
pub let bell_shock_damage : Float = 26.0

/// Speed of projectile bolts.
pub let bolt_speed : Float = 360.0

/// Lifetime of projectile bolts.
pub let bolt_life : Float = 3.0

/// Radius used for shrine collision and effects.
pub let shrine_radius : Float = 64.0

/// Maximum shrine health.
pub let shrine_max_hp : Float = 100.0

/// Maximum spirit meter value.
pub let spirit_max : Float = 100.0

/// Spirit regeneration per second.
pub let spirit_regen : Float = 16.0

/// Spirit spent when performing a dash.
pub let spirit_dash_cost : Float = 12.0

/// Base score goal for stage 1.
pub let stage_goal_base : Int = 1200

/// Additional score goal added per stage.
pub let stage_goal_bonus : Int = 760

/// Base stage timer in seconds.
pub let stage_time_base : Float = 60.0

/// Extra stage time added per stage.
pub let stage_time_bonus : Float = 10.0

/// Delay before leaving stage-clear state.
pub let stage_clear_wait : Float = 1.9

/// Minimum foe spawn cooldown.
pub let spawn_cd_min : Float = 0.26

/// Maximum foe spawn cooldown.
pub let spawn_cd_max : Float = 1.08

/// Shrine damage caused by a wisp contact.
pub let shrine_drain_wisp : Float = 9.0

/// Shrine damage caused by a brute contact.
pub let shrine_drain_brute : Float = 16.0

/// Shrine damage caused by a shaman contact.
pub let shrine_drain_shaman : Float = 11.0

/// Returns the top color of the temple background gradient.
pub fn bg_top() -> @raylib.Color {
  @raylib.Color::new(8, 18, 38, 255)
}

/// Returns the bottom color of the temple background gradient.
pub fn bg_bottom() -> @raylib.Color {
  @raylib.Color::new(18, 42, 76, 255)
}

/// Returns the cyan accent color.
pub fn cyan() -> @raylib.Color {
  @raylib.Color::new(96, 238, 255, 255)
}

/// Returns the pink accent color.
pub fn pink() -> @raylib.Color {
  @raylib.Color::new(255, 124, 188, 255)
}

/// Returns the amber accent color.
pub fn amber() -> @raylib.Color {
  @raylib.Color::new(255, 212, 122, 255)
}

/// Returns the jade accent color.
pub fn jade() -> @raylib.Color {
  @raylib.Color::new(126, 244, 198, 255)
}

/// Returns the shrine health bar color.
pub fn shrine_col() -> @raylib.Color {
  @raylib.Color::new(255, 136, 168, 255)
}

/// Returns the spirit meter color.
pub fn spirit_col() -> @raylib.Color {
  @raylib.Color::new(120, 244, 204, 255)
}

/// Returns the square size for touch control buttons.
pub fn btn_size() -> Float {
  102.0
}

/// Returns the rectangle for the touch left button.
pub fn btn_left_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (20.0, Float::from_int(screen_h) - s - 20.0, s, s)
}

/// Returns the rectangle for the touch right button.
pub fn btn_right_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (132.0, Float::from_int(screen_h) - s - 20.0, s, s)
}

/// Returns the rectangle for the touch up button.
pub fn btn_up_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (76.0, Float::from_int(screen_h) - s * 2.0 - 34.0, s, s)
}

/// Returns the rectangle for the touch down button.
pub fn btn_down_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (76.0, Float::from_int(screen_h) - 20.0, s, s)
}

/// Returns the rectangle for the touch bell-ring button.
pub fn btn_ring_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s - 20.0,
    Float::from_int(screen_h) - s - 20.0,
    s,
    s,
  )
}

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

/// Returns the rectangle for the title-screen start button.
pub fn title_start_rect() -> (Float, Float, Float, Float) {
  let w : Float = 420.0
  let h : Float = 86.0
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.66,
    w,
    h,
  )
}

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
