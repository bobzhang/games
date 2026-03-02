///|
/// Clamps `v` to the inclusive range `[lo, hi]`.
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
/// Returns absolute value of a float.
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
/// Performs linear interpolation from `a` to `b`.
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
/// Converts a column index to screen-space X.
pub fn cell_x(col : Int) -> Float {
  Float::from_int(board_left + col * (cell_px + cell_gap))
}

///|
/// Converts a row index to screen-space Y.
pub fn cell_y(row : Int) -> Float {
  Float::from_int(board_top + row * (cell_px + cell_gap))
}

///|
/// Converts row and column to linear board index.
pub fn idx(r : Int, c : Int) -> Int {
  r * grid_cols + c
}
