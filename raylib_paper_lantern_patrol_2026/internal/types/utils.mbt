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
/// Returns the smaller of two float values.
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
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
/// Returns the square of a float value.
pub fn squaref(v : Float) -> Float {
  v * v
}

///|
/// Returns squared distance between two 2D points.
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
/// Returns a pseudo-random float sampled from `[lo, hi]`.
pub fn randf(lo : Float, hi : Float) -> Float {
  let roll = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * roll
}

///|
/// Returns a pseudo-random integer sampled from `[lo, hi]`.
pub fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
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
/// Returns the configured UI or gameplay color for a col.
pub fn a_col(c : @raylib.Color, a : Int) -> @raylib.Color {
  @raylib.Color::new(
    c.r.to_int(),
    c.g.to_int(),
    c.b.to_int(),
    clampi(a, 0, 255),
  )
}

///|
/// Returns geometry information for night top.
pub fn night_top() -> @raylib.Color {
  @raylib.Color::new(12, 20, 42, 255)
}

///|
/// Returns geometry information for night bottom.
pub fn night_bottom() -> @raylib.Color {
  @raylib.Color::new(36, 52, 96, 255)
}

///|
/// Returns helper data for street dark.
pub fn street_dark() -> @raylib.Color {
  @raylib.Color::new(30, 28, 40, 255)
}

///|
/// Returns helper data for street mid.
pub fn street_mid() -> @raylib.Color {
  @raylib.Color::new(52, 46, 64, 255)
}

///|
/// Returns the configured UI or gameplay color for lantern frame col.
pub fn lantern_frame_col() -> @raylib.Color {
  @raylib.Color::new(212, 178, 124, 255)
}

///|
/// Returns the configured UI or gameplay color for lantern flame col.
pub fn lantern_flame_col(flame : Float) -> @raylib.Color {
  let t = clampf(flame / 100.0, 0.0, 1.0)
  @raylib.Color::new(
    246,
    118 + (t * 122.0).to_int(),
    62 + (t * 130.0).to_int(),
    250,
  )
}

///|
/// Returns the configured UI or gameplay color for shrine col.
pub fn shrine_col() -> @raylib.Color {
  @raylib.Color::new(114, 208, 188, 255)
}

///|
/// Returns the configured UI or gameplay color for danger col.
pub fn danger_col() -> @raylib.Color {
  @raylib.Color::new(244, 110, 94, 255)
}

///|
/// Returns the configured UI or gameplay color for calm col.
pub fn calm_col() -> @raylib.Color {
  @raylib.Color::new(118, 212, 252, 255)
}
