///|
/// Returns a computed helper value for f.
pub fn f(i : Int) -> Float {
  Float::from_int(i)
}

///|
/// Clamps an integer value to the inclusive range `[lo, hi]`.
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  v.clamp(min=lo, max=hi)
}

///|
/// Clamps a float value to the inclusive range `[lo, hi]`.
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
/// Returns the larger of two float values.
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// Returns the smaller of two float values.
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
/// Linearly interpolates between two floats using `t` in `[0, 1]`.
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
/// Returns the sine of an angle in radians.
pub fn sinf(v : Float) -> Float {
  @math.sinf(v)
}

///|
/// Returns the cosine of an angle in radians.
pub fn cosf(v : Float) -> Float {
  @math.cosf(v)
}

///|
/// Returns a pseudo-random float sampled from `[lo, hi]`.
pub fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
/// Returns a pseudo-random integer sampled from `[lo, hi]`.
pub fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
/// Wraps an angle into the canonical gameplay range.
pub fn wrap_angle(a : Float) -> Float {
  let mut v = a
  while v > pi {
    v = v - tau
  }
  while v < -pi {
    v = v + tau
  }
  v
}

///|
/// Returns the signed shortest angular difference in degrees.
pub fn shortest_angle(from : Float, to : Float) -> Float {
  wrap_angle(to - from)
}

///|
/// Returns the smallest angular difference in degrees.
pub fn angle_dist(a : Float, b : Float) -> Float {
  shortest_angle(a, b).abs()
}

///|
/// Returns a computed helper value for ring radius.
pub fn ring_radius(ring : Int) -> Float {
  base_radius + Float::from_int(ring) * ring_gap
}

///|
/// Returns world-space coordinates for world x.
pub fn world_x(radius : Float, angle : Float) -> Float {
  radius * cosf(angle)
}

///|
/// Returns world-space coordinates for world y.
pub fn world_y(radius : Float, angle : Float) -> Float {
  radius * sinf(angle)
}

///|
/// Returns squared distance between two 2D points.
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
/// Applies an ease-in-out curve to a normalized input value.
pub fn ease_in_out(t : Float) -> Float {
  let x = clampf(t, 0.0, 1.0)
  if x < 0.5 {
    f(2) * x * x
  } else {
    f(1) - (-f(2) * x + f(2)) * (-f(2) * x + f(2)) * 0.5
  }
}

///|
/// Returns world-space coordinates for center x.
pub fn center_x() -> Float {
  Float::from_int(screen_w / 2)
}

///|
/// Returns world-space coordinates for center y.
pub fn center_y() -> Float {
  Float::from_int(screen_h / 2)
}

///|
/// Returns helper data for bg top.
pub fn bg_top() -> @raylib.Color {
  @raylib.Color::new(10, 8, 24, 255)
}

///|
/// Returns helper data for bg bottom.
pub fn bg_bottom() -> @raylib.Color {
  @raylib.Color::new(20, 18, 42, 255)
}

///|
/// Returns a computed helper value for ring alpha.
pub fn ring_alpha() -> @raylib.Color {
  @raylib.Color::new(88, 226, 255, 255)
}

///|
/// Returns a computed helper value for ring beta.
pub fn ring_beta() -> @raylib.Color {
  @raylib.Color::new(255, 136, 230, 255)
}

///|
/// Returns the configured UI or gameplay color for phase bar col.
pub fn phase_bar_col() -> @raylib.Color {
  @raylib.Color::new(146, 236, 255, 255)
}

///|
/// Returns the configured UI or gameplay color for hp bar col.
pub fn hp_bar_col() -> @raylib.Color {
  @raylib.Color::new(255, 126, 154, 255)
}

///|
/// Returns helper data for button size.
pub fn button_size() -> Float {
  Float::from_int(102)
}

///|
/// Returns the touch or HUD hit area for button left rect.
pub fn button_left_rect() -> (Float, Float, Float, Float) {
  let s = button_size()
  (
    Float::from_int(24),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
/// Returns the touch or HUD hit area for button right rect.
pub fn button_right_rect() -> (Float, Float, Float, Float) {
  let s = button_size()
  (
    Float::from_int(138),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
/// Returns the touch or HUD hit area for button in rect.
pub fn button_in_rect() -> (Float, Float, Float, Float) {
  let s = button_size()
  (
    Float::from_int(screen_w) - s * Float::from_int(3) - Float::from_int(48),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
/// Returns the touch or HUD hit area for button out rect.
pub fn button_out_rect() -> (Float, Float, Float, Float) {
  let s = button_size()
  (
    Float::from_int(screen_w) - s * Float::from_int(2) - Float::from_int(34),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
/// Returns the touch or HUD hit area for button fire rect.
pub fn button_fire_rect() -> (Float, Float, Float, Float) {
  let s = button_size()
  (
    Float::from_int(screen_w) - s - Float::from_int(20),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
/// Returns world-space coordinates for enemy world xy.
pub fn enemy_world_xy(e : Enemy) -> (Float, Float) {
  let r = ring_radius(e.ring)
  (world_x(r, e.angle), world_y(r, e.angle))
}

///|
/// Returns world-space coordinates for player world xy.
pub fn player_world_xy(player : Player) -> (Float, Float) {
  let r = ring_radius(player.ring)
  (world_x(r, player.angle), world_y(r, player.angle))
}

///|
/// Returns whether phase mask active is true for the current query.
pub fn phase_mask_active(mask : Int, beta : Bool) -> Bool {
  if mask == 1 {
    not(beta)
  } else if mask == 2 {
    beta
  } else {
    true
  }
}

///|
/// Returns the rectangle used for point in rect.
pub fn point_in_rect(
  x : Float,
  y : Float,
  rx : Float,
  ry : Float,
  rw : Float,
  rh : Float,
) -> Bool {
  x >= rx && x <= rx + rw && y >= ry && y <= ry + rh
}

///|
/// Returns the rectangle used for pointer on rect.
pub fn pointer_on_rect(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
  rx : Float,
  ry : Float,
  rw : Float,
  rh : Float,
) -> Bool {
  if hold && point_in_rect(mx, my, rx, ry, rw, rh) {
    return true
  }

  for i in 0..<touch_count {
    let p = @raylib.get_touch_position(i)
    if point_in_rect(p.x, p.y, rx, ry, rw, rh) {
      return true
    }
  }

  false
}
