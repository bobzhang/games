///|
/// Clamps an integer into `[lo, hi]`.
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  v.clamp(min=lo, max=hi)
}

///|
/// Clamps a float into `[lo, hi]`.
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
/// Returns the smaller of two floats.
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
/// Returns the larger of two floats.
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// Returns a random float in `[lo, hi]`.
pub fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}
