///|
/// Clamps an integer value to the inclusive range `[lo, hi]`.
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
/// Clamps a float value to the inclusive range `[lo, hi]`.
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
/// Returns the absolute value of a float.
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
/// Returns the square root of a non-negative float.
pub fn sqrtf(v : Float) -> Float {
  v.sqrt()
}

///|
/// Returns the sine of an angle in radians.
pub fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
/// Returns the cosine of an angle in radians.
pub fn cosf(v : Float) -> Float {
  Float::from_double(@math.cos(v.to_double()))
}

///|
/// Returns a pseudo-random float sampled from `[lo, hi]`.
pub fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
/// Returns squared distance between two 2D points.
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
/// Normalizes an angle to the `[-180, 180]` degree range.
pub fn normalize_deg(a : Float) -> Float {
  let mut v = a
  while v > 180.0 {
    v = v - 360.0
  }
  while v < -180.0 {
    v = v + 360.0
  }
  v
}

///|
/// Returns the smallest angular difference in degrees.
pub fn angle_delta_deg(a : Float, b : Float) -> Float {
  absf(normalize_deg(a - b))
}

///|
/// Converts a direction vector into a heading angle in degrees.
pub fn heading_deg(dx : Float, dy : Float) -> Float {
  @math.atan2f(dy, dx) * rad_to_deg
}

///|
/// Returns geometry information for world w.
pub fn world_w() -> Float {
  world_right - world_left
}

///|
/// Returns geometry information for world h.
pub fn world_h() -> Float {
  world_bottom - world_top
}

///|
/// Returns world-space coordinates for world center x.
pub fn world_center_x() -> Float {
  (world_left + world_right) * 0.5
}

///|
/// Returns world-space coordinates for player spawn x.
pub fn player_spawn_x() -> Float {
  world_center_x()
}

///|
/// Returns world-space coordinates for player spawn y.
pub fn player_spawn_y() -> Float {
  world_bottom - 86.0
}

///|
/// Returns helper data for default exit pos.
pub fn default_exit_pos(i : Int) -> (Float, Float) {
  if i % max_exits == 0 {
    (world_left + 104.0, world_top + 84.0)
  } else if i % max_exits == 1 {
    (world_center_x(), world_top + 76.0)
  } else {
    (world_right - 104.0, world_bottom - 94.0)
  }
}

///|
/// Returns the color used for bg top visuals.
pub fn col_bg_top() -> @raylib.Color {
  @raylib.Color::new(8, 14, 23, 255)
}

///|
/// Returns the color used for bg bottom visuals.
pub fn col_bg_bottom() -> @raylib.Color {
  @raylib.Color::new(12, 21, 32, 255)
}

///|
/// Returns the color used for floor visuals.
pub fn col_floor() -> @raylib.Color {
  @raylib.Color::new(24, 34, 46, 255)
}

///|
/// Returns the color used for floor grid visuals.
pub fn col_floor_grid() -> @raylib.Color {
  @raylib.Color::new(44, 58, 74, 150)
}

///|
/// Returns the color used for wall visuals.
pub fn col_wall() -> @raylib.Color {
  @raylib.Color::new(56, 66, 84, 255)
}

///|
/// Returns the color used for player visuals.
pub fn col_player() -> @raylib.Color {
  @raylib.Color::new(114, 232, 190, 255)
}

///|
/// Returns the color used for guard visuals.
pub fn col_guard() -> @raylib.Color {
  @raylib.Color::new(255, 122, 122, 255)
}

///|
/// Returns the color used for parcel visuals.
pub fn col_parcel() -> @raylib.Color {
  @raylib.Color::new(250, 222, 120, 255)
}

///|
/// Returns the color used for exit visuals.
pub fn col_exit() -> @raylib.Color {
  @raylib.Color::new(126, 172, 255, 255)
}

///|
/// Returns the color used for trap visuals.
pub fn col_trap() -> @raylib.Color {
  @raylib.Color::new(242, 88, 142, 255)
}

///|
/// Returns the color used for health visuals.
pub fn col_health() -> @raylib.Color {
  @raylib.Color::new(238, 98, 114, 255)
}

///|
/// Returns the color used for stealth visuals.
pub fn col_stealth() -> @raylib.Color {
  @raylib.Color::new(118, 216, 196, 255)
}
