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
/// Convert a Room enum to its integer index.
pub fn Room::to_int(self : Room) -> Int {
  match self {
    Rest => 0
    Train => 1
    Sparring => 2
    Defense => 3
  }
}

///|
/// Convert an integer index to a Room enum value.
pub fn Room::from_int(v : Int) -> Room {
  match v {
    1 => Train
    2 => Sparring
    3 => Defense
    _ => Rest
  }
}

///|
/// Convert room to UI label text.
pub fn room_name(room : Room) -> String {
  match room {
    Rest => "Rest"
    Train => "Train"
    Sparring => "Spar"
    Defense => "Defense"
  }
}
