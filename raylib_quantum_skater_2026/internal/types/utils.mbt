///|
/// Clamp an integer to the inclusive range `[lo, hi]`.
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  v.clamp(min=lo, max=hi)
}

///|
/// Clamp a float to the inclusive range `[lo, hi]`.
pub fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
/// Return the larger of two float values.
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// Return the smaller of two float values.
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
/// Linear interpolation from `a` to `b` by `t`.
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
/// Move `v` toward `target` by at most `step`.
pub fn approachf(v : Float, target : Float, step : Float) -> Float {
  if v < target {
    minf(v + step, target)
  } else {
    maxf(v - step, target)
  }
}

///|
/// Sine helper wrapping the math double API.
pub fn sinf(v : Float) -> Float {
  @math.sinf(v)
}

///|
/// Cosine helper wrapping the math double API.
pub fn cosf(v : Float) -> Float {
  @math.cosf(v)
}

///|
/// Random float sampled uniformly from `[lo, hi]`.
pub fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
/// Random integer sampled uniformly from `[lo, hi]`.
pub fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
/// Return true with approximately `p` percent probability.
pub fn chance(p : Int) -> Bool {
  randi(0, 99) < p
}

///|
/// Squared Euclidean distance between two points.
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
/// Perspective scale factor for depth `z`.
pub fn proj_scale(z : Float) -> Float {
  1.0 / (1.0 + z * 0.0042)
}

///|
/// Convert lane index to centered world x coordinate.
pub fn lane_world_x(lane : Int) -> Float {
  let half = Float::from_int(lane_count - 1) * 0.5
  (Float::from_int(lane) - half) * 220.0
}

///|
/// Project world lane position to screen x at depth `z`.
pub fn lane_screen_x(lane : Float, z : Float) -> Float {
  let cx = Float::from_int(screen_w / 2)
  cx + lane * proj_scale(z)
}

///|
/// Compute projected track y position for depth `z`.
pub fn track_y(z : Float) -> Float {
  let near : Float = Float::from_int(screen_h) - Float::from_int(118)
  let far : Float = Float::from_int(162)
  lerpf(near, far, clampf(z / 2400.0, 0.0, 1.0))
}

///|
/// Background gradient top color.
pub fn color_bg_top() -> @raylib.Color {
  @raylib.Color::new(8, 12, 32, 255)
}

///|
/// Background gradient bottom color.
pub fn color_bg_bottom() -> @raylib.Color {
  @raylib.Color::new(10, 18, 44, 255)
}

///|
/// Lane tint used in alpha phase.
pub fn color_lane_alpha() -> @raylib.Color {
  @raylib.Color::new(86, 236, 255, 255)
}

///|
/// Lane tint used in beta phase.
pub fn color_lane_beta() -> @raylib.Color {
  @raylib.Color::new(255, 124, 228, 255)
}

///|
/// HUD bar color for phase energy.
pub fn color_phase_bar() -> @raylib.Color {
  @raylib.Color::new(136, 230, 255, 255)
}

///|
/// HUD bar color for player health.
pub fn color_hp_bar() -> @raylib.Color {
  @raylib.Color::new(255, 118, 152, 255)
}

///|
/// Touch control rectangle for moving left.
pub fn button_left_rect() -> (Float, Float, Float, Float) {
  let s : Float = Float::from_int(104)
  (
    Float::from_int(22),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
/// Touch control rectangle for moving right.
pub fn button_right_rect() -> (Float, Float, Float, Float) {
  let s : Float = Float::from_int(104)
  (
    Float::from_int(140),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
/// Touch control rectangle for jump input.
pub fn button_jump_rect() -> (Float, Float, Float, Float) {
  let s : Float = Float::from_int(104)
  (
    Float::from_int(screen_w) - s - Float::from_int(20),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
/// Touch control rectangle for phase toggle input.
pub fn button_phase_rect() -> (Float, Float, Float, Float) {
  let s : Float = Float::from_int(104)
  (
    Float::from_int(screen_w) - s * Float::from_int(2) - Float::from_int(34),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}
