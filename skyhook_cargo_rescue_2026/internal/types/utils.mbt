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
/// Returns the smaller of two floating-point values.
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
/// Returns the larger of two floating-point values.
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// Returns a random float sampled uniformly from `[lo, hi]`.
pub fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
/// Returns the world-space left boundary.
pub fn world_left() -> Float {
  Float::from_int(world_x0)
}

///|
/// Returns the world-space right boundary.
pub fn world_right() -> Float {
  Float::from_int(world_x0 + world_w)
}

///|
/// Returns the world-space top boundary.
pub fn world_top() -> Float {
  Float::from_int(world_y0)
}

///|
/// Returns the world-space bottom boundary.
pub fn world_bottom() -> Float {
  Float::from_int(world_y0 + world_h)
}

///|
/// Returns the center x-coordinate of the safe zone.
pub fn safe_cx() -> Float {
  Float::from_int(safe_zone_x() + safe_zone_w() / 2)
}

///|
/// Returns the center y-coordinate of the safe zone.
pub fn safe_cy() -> Float {
  Float::from_int(safe_zone_y() + safe_zone_h() / 2)
}

///|
/// Returns squared distance between two points.
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx : Float = x1 - x0
  let dy : Float = y1 - y0
  dx * dx + dy * dy
}

///|
/// Tests whether a point is inside a float rectangle.
pub fn point_in_rectf(
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
/// Tests whether a world point lies inside the safe zone.
pub fn inside_safe_zone(x : Float, y : Float) -> Bool {
  point_in_rectf(
    x,
    y,
    Float::from_int(safe_zone_x()),
    Float::from_int(safe_zone_y()),
    Float::from_int(safe_zone_w()),
    Float::from_int(safe_zone_h()),
  )
}

///|
/// Returns the hook tip x-position for the current helicopter state.
pub fn hook_tip_x(game : Game) -> Float {
  game.heli_x
}

///|
/// Returns the hook tip y-position for the current helicopter state.
pub fn hook_tip_y(game : Game) -> Float {
  game.heli_y + game.hook_len
}

///|
/// Tests whether a point is inside an integer rectangle.
pub fn point_in_rect(
  x : Float,
  y : Float,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  let x0 : Float = Float::from_int(rx)
  let y0 : Float = Float::from_int(ry)
  let x1 : Float = Float::from_int(rx + rw)
  let y1 : Float = Float::from_int(ry + rh)

  x >= x0 && x <= x1 && y >= y0 && y <= y1
}

///|
/// Tests whether mouse hold or any touch point is inside a rectangle.
pub fn pointer_on_rect(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
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
