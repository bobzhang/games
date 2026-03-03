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
/// Clamps a float value to the normalized range `[0.0, 1.0]`.
pub fn clamp01(v : Float) -> Float {
  clampf(v, 0.0, 1.0)
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
/// Returns squared distance between two 2D points.
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
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
/// Returns a computed helper value for chance.
pub fn chance(pct : Int) -> Bool {
  randi(0, 99) < pct
}

///|
/// Returns derived layout data for checkpoint span.
pub fn checkpoint_span(idx : Int) -> Float {
  checkpoint_base_span + Float::from_int(idx.max(0)) * checkpoint_span_step
}

///|
/// Returns a derived gameplay metric for caravan speed.
pub fn caravan_speed(checkpoint : Int) -> Float {
  caravan_speed_base + Float::from_int(checkpoint.max(0)) * caravan_speed_step
}

///|
/// Returns world-space coordinates for wagon slot x.
pub fn wagon_slot_x(index : Int) -> Float {
  caravan_center_x + Float::from_int(index - wagon_count / 2) * wagon_gap
}

///|
/// Returns world-space coordinates for wagon slot y.
pub fn wagon_slot_y(index : Int) -> Float {
  if index % 2 == 0 {
    caravan_center_y - 24.0
  } else {
    caravan_center_y + 20.0
  }
}

///|
/// Returns world-space coordinates for lane base y.
pub fn lane_base_y(index : Int) -> Float {
  desert_lane_top +
  Float::from_int(clampi(index, 0, lane_count - 1)) * desert_lane_gap
}

///|
/// Returns a computed helper value for ellipse norm.
pub fn ellipse_norm(dx : Float, dy : Float, rx : Float, ry : Float) -> Float {
  let nx = dx / maxf(rx, 0.001)
  let ny = dy / maxf(ry, 0.001)
  (nx * nx + ny * ny).sqrt()
}
