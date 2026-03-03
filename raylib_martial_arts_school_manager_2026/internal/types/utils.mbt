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
/// Compute week duration after progression scaling.
pub fn week_duration_for(week : Int) -> Float {
  let raw = week_duration_base - Float::from_int(week - 1) * week_duration_drop
  maxf(week_duration_min, raw)
}

///|
/// Compute weekly upkeep cost for the given week.
pub fn upkeep_for(week : Int) -> Float {
  week_upkeep_base + Float::from_int(week - 1) * week_upkeep_growth
}

///|
/// Compute average delay between incidents for a week.
pub fn incident_gap_for(week : Int) -> Float {
  let raw = incident_gap_base - Float::from_int(week - 1) * incident_gap_drop
  maxf(incident_gap_min, raw)
}

///|
/// Compute incident severity multiplier for a week.
pub fn incident_severity_for(week : Int) -> Float {
  incident_severity_base + Float::from_int(week - 1) * incident_severity_growth
}

///|
/// Convert room id to UI label text.
pub fn room_name(room : Int) -> String {
  if room == room_rest {
    "Rest"
  } else if room == room_train {
    "Train"
  } else if room == room_sparring {
    "Spar"
  } else {
    "Defense"
  }
}
