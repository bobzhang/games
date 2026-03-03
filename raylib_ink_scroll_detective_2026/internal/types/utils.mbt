///|
/// Returns total city grid width in pixels.
pub fn city_w_i() -> Int {
  city_cols * cell_w_i
}

///|
/// Returns total city grid height in pixels.
pub fn city_h_i() -> Int {
  city_rows * cell_h_i
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
/// Returns the larger of two floating-point values.
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// Returns the smaller of two floating-point values.
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
/// Clamps a float into the `[0.0, 1.0]` range.
pub fn clamp01(v : Float) -> Float {
  clampf(v, 0.0, 1.0)
}

///|
/// Returns a random float sampled uniformly from `[lo, hi]`.
pub fn randf(lo : Float, hi : Float) -> Float {
  let n = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * n
}

///|
/// Returns a random integer sampled uniformly from `[lo, hi]`.
pub fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
/// Converts a cell coordinate to a linear district index.
pub fn cell_index(cell_x : Int, cell_y : Int) -> Int {
  cell_y * city_cols + cell_x
}

///|
/// Returns left pixel position of a district cell.
pub fn cell_left_i(cell_x : Int) -> Int {
  city_origin_x_i + cell_x * cell_w_i
}

///|
/// Returns top pixel position of a district cell.
pub fn cell_top_i(cell_y : Int) -> Int {
  city_origin_y_i + cell_y * cell_h_i
}

///|
/// Returns center x-position of a district cell.
pub fn cell_center_x(cell_x : Int) -> Float {
  Float::from_int(cell_left_i(cell_x) + cell_w_i / 2)
}

///|
/// Returns center y-position of a district cell.
pub fn cell_center_y(cell_y : Int) -> Float {
  Float::from_int(cell_top_i(cell_y) + cell_h_i / 2)
}

///|
/// Converts `(suspect, chain)` to a flattened chain-progress index.
pub fn chain_slot(suspect : Int, chain : Int) -> Int {
  suspect * chains_per_suspect + chain
}

///|
/// Returns required evidence score for an incident severity.
pub fn incident_need_score(severity : Int) -> Int {
  10 + severity * 8
}

///|
/// Returns countdown duration for an incident severity.
pub fn incident_timer_for_severity(severity : Int) -> Float {
  incident_timer_base - Float::from_int(severity - 1) * incident_timer_drop
}
