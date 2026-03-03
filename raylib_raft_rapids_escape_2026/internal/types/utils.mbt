///|
/// Return the smaller of two integers.
pub fn mini(a : Int, b : Int) -> Int {
  a.min(b)
}

///|
/// Return the larger of two integers.
pub fn maxi(a : Int, b : Int) -> Int {
  a.max(b)
}

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
/// Return the smaller of two float values.
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
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
/// Return the absolute value of a float.
pub fn absf(v : Float) -> Float {
  v.abs()
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
/// Uniform random float in `[lo, hi]`.
pub fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
/// World left boundary as float.
pub fn world_left() -> Float {
  Float::from_int(world_x0)
}

///|
/// World right boundary as float.
pub fn world_right() -> Float {
  Float::from_int(world_x0 + world_w)
}

///|
/// World top boundary as float.
pub fn world_top() -> Float {
  Float::from_int(world_y0)
}

///|
/// World bottom boundary as float.
pub fn world_bottom() -> Float {
  Float::from_int(world_y0 + world_h)
}

///|
/// Squared Euclidean distance between two points.
pub fn point_dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx : Float = x1 - x0
  let dy : Float = y1 - y0
  dx * dx + dy * dy
}

///|
/// Horizontal water current applied at a given y.
pub fn water_current_x(game : Game, y : Float) -> Float {
  let n0 : Float = sinf(game.ui_t * 0.80 + y * 0.011)
  let n1 : Float = cosf(game.ui_t * 1.53 + y * 0.006)
  (n0 * 92.0 + n1 * 68.0) * (0.6 + Float::from_int(game.level) * 0.08)
}

///|
/// Vertical water current applied at a given x.
pub fn water_current_y(game : Game, x : Float) -> Float {
  let n0 : Float = sinf(game.ui_t * 0.66 + x * 0.008)
  let n1 : Float = cosf(game.ui_t * 1.18 + x * 0.014)
  180.0 + Float::from_int(game.level) * 18.0 + n0 * 26.0 + n1 * 14.0
}

///|
/// Set transient message text and display duration.
pub fn set_msg(game : Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
}

///|
/// Test whether a point lies inside an integer rectangle.
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
/// Check pointer/touch hold intersection with a rectangle.
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
