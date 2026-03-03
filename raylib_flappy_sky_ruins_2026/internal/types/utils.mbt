///|
/// Returns the smaller of two integers.
pub fn mini(a : Int, b : Int) -> Int {
  a.min(b)
}

///|
/// Clamps an integer into the inclusive range [`lo`, `hi`].
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  v.clamp(min=lo, max=hi)
}

///|
/// Clamps a float into the inclusive range [`lo`, `hi`].
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
/// Returns the larger of two floating-point values.
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// Returns a pseudo-random float in the inclusive range [`lo`, `hi`].
pub fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
/// Returns the world left boundary as float.
pub fn world_left() -> Float {
  Float::from_int(world_x0)
}

///|
/// Returns the world right boundary as float.
pub fn world_right() -> Float {
  Float::from_int(world_x0 + world_w)
}

///|
/// Returns the world top boundary as float.
pub fn world_top() -> Float {
  Float::from_int(world_y0)
}

///|
/// Returns the world bottom boundary as float.
pub fn world_bottom() -> Float {
  Float::from_int(world_y0 + world_h)
}

///|
/// Sets the transient HUD message and its remaining lifetime.
pub fn set_msg(game : Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
}

///|
/// Checks whether an active pointer is currently inside a rectangle.
pub fn pointer_on_rect(
  x : Float,
  y : Float,
  hold : Bool,
  touch_count : Int,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  if not(hold) && touch_count <= 0 {
    return false
  }

  let x0 : Float = Float::from_int(rx)
  let y0 : Float = Float::from_int(ry)
  let x1 : Float = Float::from_int(rx + rw)
  let y1 : Float = Float::from_int(ry + rh)

  x >= x0 && x <= x1 && y >= y0 && y <= y1
}

///|
/// Returns the effective gap center for an obstacle, including spinner motion.
pub fn obstacle_gap_mid(ob : Obstacle) -> Float {
  if ob.kind == obstacle_kind_spinner {
    ob.gap_y + @math.sinf(ob.phase) * 120.0
  } else {
    ob.gap_y
  }
}
