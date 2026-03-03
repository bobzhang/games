///|
/// Clamps an integer to the inclusive `[lo, hi]` range.
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  v.clamp(min=lo, max=hi)
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
/// Returns the absolute value of `v`.
pub fn absf(v : Float) -> Float {
  v.abs()
}

///|
/// Linearly interpolates from `a` to `b` by `t`.
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
/// Computes the sine of `v` in radians.
pub fn sinf(v : Float) -> Float {
  @math.sinf(v)
}

///|
/// Computes the cosine of `v` in radians.
pub fn cosf(v : Float) -> Float {
  @math.cosf(v)
}

///|
/// Computes the square root of `v`.
pub fn sqrtf(v : Float) -> Float {
  v.sqrt()
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

///|
/// Returns whether an entity kind should attack the shrine.
pub fn is_hostile(kind : Int) -> Bool {
  kind == foe_wisp || kind == foe_brute || kind == foe_shaman
}

///|
/// Returns whether an entity kind is a relic pickup.
pub fn is_relic(kind : Int) -> Bool {
  kind == foe_relic
}

///|
/// Returns collision radius for a foe.
pub fn foe_hit_r(f : Foe) -> Float {
  maxf(f.w, f.h) * 0.34
}

///|
/// Returns collision radius for the hero.
pub fn hero_hit_r(h : Hero) -> Float {
  maxf(h.w, h.h) * 0.32
}

///|
/// Returns `c` with clamped alpha `a`.
pub fn a_col(c : @raylib.Color, a : Int) -> @raylib.Color {
  @raylib.Color::new(
    c.r.to_int(),
    c.g.to_int(),
    c.b.to_int(),
    clampi(a, 0, 255),
  )
}

///|
/// Returns the display color for a foe kind.
pub fn foe_col(kind : Int) -> @raylib.Color {
  if kind == foe_wisp {
    pink()
  } else if kind == foe_brute {
    @raylib.Color::new(255, 170, 118, 255)
  } else if kind == foe_shaman {
    @raylib.Color::new(126, 210, 255, 255)
  } else {
    jade()
  }
}

///|
/// Returns the display color for a spark kind.
pub fn spark_col(kind : Int) -> @raylib.Color {
  if kind == 0 {
    cyan()
  } else if kind == 1 {
    pink()
  } else if kind == 2 {
    jade()
  } else {
    @raylib.Color::new(232, 242, 255, 255)
  }
}
