///|
/// Returns geometry information for chamber right.
pub fn chamber_right() -> Float {
  chamber_left + chamber_w
}

///|
/// Returns geometry information for chamber bottom.
pub fn chamber_bottom() -> Float {
  chamber_top + chamber_h
}

///|
/// Returns world-space coordinates for chamber center x.
pub fn chamber_center_x() -> Float {
  chamber_left + chamber_w * 0.5
}

///|
/// Returns world-space coordinates for chamber center y.
pub fn chamber_center_y() -> Float {
  chamber_top + chamber_h * 0.5
}

///|
/// Returns a derived gameplay metric for room name.
pub fn room_name(room : Int) -> String {
  if room == 0 {
    "Ember Archive"
  } else if room == 1 {
    "Vault Core"
  } else {
    "Seal Scriptorium"
  }
}

///|
/// Returns world-space coordinates for breach anchor x.
pub fn breach_anchor_x(room : Int) -> Float {
  if room == 0 {
    chamber_left + chamber_w * 0.82
  } else if room == 1 {
    chamber_left + chamber_w * 0.18
  } else {
    chamber_left + chamber_w * 0.58
  }
}

///|
/// Returns world-space coordinates for breach anchor y.
pub fn breach_anchor_y(room : Int) -> Float {
  if room == 0 {
    chamber_top + chamber_h * 0.24
  } else if room == 1 {
    chamber_top + chamber_h * 0.78
  } else {
    chamber_top + chamber_h * 0.32
  }
}

///|
/// Returns world-space coordinates for vault core x.
pub fn vault_core_x() -> Float {
  chamber_left + chamber_w * 0.50
}

///|
/// Returns world-space coordinates for vault core y.
pub fn vault_core_y() -> Float {
  chamber_top + chamber_h * 0.52
}

///|
/// Returns world-space coordinates for raider goal x.
pub fn raider_goal_x(room : Int) -> Float {
  if room < vault_room {
    chamber_right() - 18.0
  } else if room > vault_room {
    chamber_left + 18.0
  } else {
    vault_core_x()
  }
}

///|
/// Returns world-space coordinates for raider goal y.
pub fn raider_goal_y(room : Int) -> Float {
  if room == vault_room {
    vault_core_y()
  } else {
    door_center_y
  }
}

///|
/// Returns a derived gameplay metric for wave duration.
pub fn wave_duration(wave : Int) -> Float {
  wave_duration_base + Float::from_int(wave - 1) * wave_duration_step
}

///|
/// Clamps an integer value to the inclusive range `[lo, hi]`.
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  v.clamp(min=lo, max=hi)
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
  v.abs()
}

///|
/// Clamps a float value to the normalized range `[0.0, 1.0]`.
pub fn clamp01(v : Float) -> Float {
  clampf(v, 0.0, 1.0)
}

///|
/// Returns squared distance between two 2D points.
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
/// Returns a pseudo-random float sampled from `[lo, hi]`.
pub fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
/// Returns a pseudo-random integer sampled from `[lo, hi]`.
pub fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}
