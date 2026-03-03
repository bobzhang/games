///|
/// Returns the smaller of two integers.
pub fn mini(a : Int, b : Int) -> Int {
  a.min(b)
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
/// Computes `sin(v)` and returns a `Float`.
pub fn sinf(v : Float) -> Float {
  @math.sinf(v)
}

///|
/// Returns a pseudo-random float sampled from `[lo, hi]`.
pub fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
/// Returns squared distance between two points.
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx : Float = x1 - x0
  let dy : Float = y1 - y0
  dx * dx + dy * dy
}

///|
/// Returns a normalized direction using Manhattan-length normalization.
pub fn normalize(dx : Float, dy : Float) -> (Float, Float) {
  let d1 : Float = dx.abs() + dy.abs()
  if d1 <= 0.0001 {
    (1.0, 0.0)
  } else {
    (dx / d1, dy / d1)
  }
}

///|
/// Sets the transient in-game message and its remaining lifetime.
pub fn set_message(game : Game, msg : String, ttl : Float) -> Unit {
  game.message = msg
  game.message_t = ttl
}
