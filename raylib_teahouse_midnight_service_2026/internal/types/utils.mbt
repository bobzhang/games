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
/// Linearly interpolates from `a` to `b` by `t`.
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
/// Applies an ease-out cubic curve to a normalized value.
pub fn ease_out_cubic(t : Float) -> Float {
  let x = clampf(t, 0.0, 1.0)
  Float::from_int(1) -
  (Float::from_int(1) - x) * (Float::from_int(1) - x) * (Float::from_int(1) - x)
}

///|
/// Returns a random float in `[lo, hi]`.
pub fn randf(lo : Float, hi : Float) -> Float {
  let n = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * n
}

///|
/// Returns a random integer in `[lo, hi]`.
pub fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
/// Returns true with probability `pct / 100`.
pub fn chance(pct : Int) -> Bool {
  randi(0, 99) < pct
}

///|
/// Returns squared distance between two points.
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
/// Returns whether a point lies inside a rectangle.
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
/// Returns whether mouse or touch input is currently inside a rectangle.
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

///|
/// Returns whether the player is within `reach` of a station point.
pub fn near_station(
  px : Float,
  py : Float,
  sx : Float,
  sy : Float,
  reach : Float,
) -> Bool {
  dist2(px, py, sx, sy) <= reach * reach
}

///|
/// Returns `c` with alpha overridden by clamped `a`.
pub fn a_col(c : @raylib.Color, a : Int) -> @raylib.Color {
  @raylib.Color::new(
    c.r.to_int(),
    c.g.to_int(),
    c.b.to_int(),
    a.clamp(min=0, max=255),
  )
}
