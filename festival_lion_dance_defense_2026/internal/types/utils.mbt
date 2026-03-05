///|
/// Returns street width in pixels.
pub fn street_w() -> Int {
  street_right - street_left
}

///|
/// Returns total lane field height in pixels.
pub fn street_h() -> Int {
  (lane_count - 1) * lane_gap + lane_height
}

///|
/// Converts a lane index into its center Y coordinate.
pub fn lane_y(lane : Int) -> Float {
  Float::from_int(lane_top + lane * lane_gap + lane_height / 2)
}

///|
/// Converts world Y position into nearest lane index.
pub fn lane_from_y(y : Float) -> Int {
  let raw = ((y - Float::from_int(lane_top)) / Float::from_int(lane_gap)).to_int()
  raw.clamp(min=0, max=lane_count - 1)
}

///|
/// Clamps a float to the inclusive `[lo, hi]` range.
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
/// Returns square of a float value.
pub fn squaref(v : Float) -> Float {
  v * v
}

///|
/// Returns squared distance between two points.
pub fn dist2(ax : Float, ay : Float, bx : Float, by : Float) -> Float {
  let dx = ax - bx
  let dy = ay - by
  dx * dx + dy * dy
}

///|
/// Returns a pseudo-random float sampled from `[lo, hi]`.
pub fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
/// Sets the HUD message and its remaining lifetime.
pub fn set_msg(game : Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
}

///|
/// Returns a time-based pulse value in `[0, 1]`.
pub fn pulse(game : Game, f : Float) -> Float {
  0.5 + 0.5 * @math.sinf(game.time_s * f)
}
