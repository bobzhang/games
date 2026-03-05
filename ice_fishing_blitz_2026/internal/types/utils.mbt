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
/// Returns a pseudo-random float sampled from `[lo, hi]`.
pub fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
/// Returns world left boundary as float.
pub fn world_left() -> Float {
  Float::from_int(world_x0)
}

///|
/// Returns world right boundary as float.
pub fn world_right() -> Float {
  Float::from_int(world_x0 + world_w)
}

///|
/// Returns top water boundary as float.
pub fn topf() -> Float {
  Float::from_int(water_top)
}

///|
/// Returns bottom water boundary as float.
pub fn bottomf() -> Float {
  Float::from_int(water_bottom)
}

///|
/// Returns hole center X as float.
pub fn hole_xf() -> Float {
  Float::from_int(hole_x)
}

///|
/// Returns hole center Y as float.
pub fn hole_yf() -> Float {
  Float::from_int(hole_y)
}

///|
/// Returns squared distance between two points.
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx : Float = x1 - x0
  let dy : Float = y1 - y0
  dx * dx + dy * dy
}

///|
/// Returns whether a point lies inside the catch zone.
pub fn in_catch_zone(x : Float, y : Float) -> Bool {
  x >= Float::from_int(catch_zone_x()) &&
  x <= Float::from_int(catch_zone_x() + catch_zone_w()) &&
  y >= Float::from_int(catch_zone_y()) &&
  y <= Float::from_int(catch_zone_y() + catch_zone_h())
}

///|
/// Sets HUD message text and remaining display time.
pub fn set_msg(game : Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
}

///|
/// Returns whether point `(x, y)` lies inside a rectangle.
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
/// Returns whether mouse/touch pointer is inside a rectangle.
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
