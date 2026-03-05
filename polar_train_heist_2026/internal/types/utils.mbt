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
/// Returns the larger of two floats.
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
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
/// Linearly interpolates from `a` to `b` by `t`.
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
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
/// Applies an ease-out cubic curve to a normalized value.
pub fn ease_out_cubic(t : Float) -> Float {
  let x = clampf(t, 0.0, 1.0)
  Float::from_int(1) -
  (Float::from_int(1) - x) * (Float::from_int(1) - x) * (Float::from_int(1) - x)
}

///|
/// Returns the world y-coordinate of a lane center.
pub fn lane_y(lane : Int) -> Float {
  lane_top + Float::from_int(lane.clamp(min=0, max=lane_count - 1)) * lane_gap
}

///|
/// Returns whether an entity kind is hostile.
pub fn is_hostile(kind : Int) -> Bool {
  kind == ent_guard ||
  kind == ent_drone ||
  kind == ent_turret ||
  kind == ent_crate
}

///|
/// Returns whether an entity kind is a pickup.
pub fn is_pickup(kind : Int) -> Bool {
  kind == ent_medkit || kind == ent_battery || kind == ent_signal
}

///|
/// Returns collision radius used for an entity.
pub fn ent_hit_r(e : Ent) -> Float {
  maxf(e.w, e.h) * 0.36
}

///|
/// Returns collision radius used for the player.
pub fn player_hit_r(p : Player) -> Float {
  maxf(p.w, p.h) * 0.34
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
/// Returns whether active mouse or touch input is inside a rectangle.
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
