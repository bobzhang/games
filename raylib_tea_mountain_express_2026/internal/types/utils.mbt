///|
/// Clamps an integer to the inclusive `[lo, hi]` range.
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
/// Returns the absolute value of a float.
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
/// Clamps a float into `[0, 1]`.
pub fn clamp01(v : Float) -> Float {
  clampf(v, 0.0, 1.0)
}

///|
/// Computes `sin(v)` and returns a `Float`.
pub fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
/// Computes `cos(v)` and returns a `Float`.
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
/// Returns a pseudo-random integer sampled from `[lo, hi]`.
pub fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
/// Returns normalized depth factor for a screen Y on the road.
pub fn road_depth(y : Float) -> Float {
  clamp01(
    (y - Float::from_int(road_top_y_i)) /
    (Float::from_int(screen_h) - Float::from_int(road_top_y_i)),
  )
}

///|
/// Returns half-width of the road at screen Y.
pub fn road_half_width(y : Float) -> Float {
  let t = road_depth(y)
  130.0 + t * 440.0
}

///|
/// Returns road center X at given world time and screen Y.
pub fn road_center_x(world_t : Float, y : Float) -> Float {
  let t = road_depth(y)
  let base = Float::from_int(screen_w) * 0.5
  let curve0 = sinf(world_t * 0.56 + t * 2.7) * 88.0
  let curve1 = cosf(world_t * 0.28 + t * 5.8) * 36.0
  base + curve0 + curve1
}

///|
/// Returns lane center X for lane index at screen Y.
pub fn lane_center_x(world_t : Float, lane : Int, y : Float) -> Float {
  let span = Float::from_int(lane_count - 1)
  let t = Float::from_int(clampi(lane, 0, lane_count - 1)) / span
  let offset = (t - 0.5) * 2.0
  let road_center = road_center_x(world_t, y)
  let lane_extent = road_half_width(y) * 0.55
  road_center + offset * lane_extent
}

///|
/// Returns route distance covered by a checkpoint segment index.
pub fn checkpoint_segment_distance(index : Int) -> Float {
  checkpoint_distance_base +
  Float::from_int(index - 1) * checkpoint_distance_step
}

///|
/// Returns allowed time budget for a checkpoint index.
pub fn checkpoint_time_limit(index : Int) -> Float {
  clampf(
    checkpoint_timer_base - Float::from_int(index - 1) * checkpoint_timer_decay,
    checkpoint_timer_min,
    checkpoint_timer_base,
  )
}

///|
/// Returns display name for a hazard kind.
pub fn hazard_name(kind : HazardKind) -> String {
  match kind {
    Rock => "Rockfall"
    Landslide => "Landslide"
    Crosswind => "Crosswind"
  }
}

///|
/// Returns steering tilt bias induced by a hazard kind.
pub fn hazard_tilt_bias(kind : HazardKind) -> Float {
  match kind {
    Rock => 0.0
    Landslide => -0.75
    Crosswind => 0.72
  }
}

///|
/// Returns durability damage from colliding with a hazard kind.
pub fn hazard_durability_hit(kind : HazardKind) -> Float {
  match kind {
    Rock => 15.0
    Landslide => 21.0
    Crosswind => 11.0
  }
}

///|
/// Returns cargo quality damage from colliding with a hazard kind.
pub fn hazard_cargo_hit(kind : HazardKind) -> Float {
  match kind {
    Rock => 13.0
    Landslide => 16.0
    Crosswind => 18.0
  }
}
