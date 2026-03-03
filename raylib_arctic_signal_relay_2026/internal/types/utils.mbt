///|
/// Clamps `v` to the inclusive `[lo, hi]` float range and returns the result.
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
/// Returns the larger of two float values.
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// Returns a pseudo-random float sampled uniformly from `[lo, hi]`.
pub fn randf(lo : Float, hi : Float) -> Float {
  let n = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * n
}

///|
/// Returns the world X coordinate of the left boundary of the viewport.
pub fn world_left() -> Float {
  Float::from_int(world_x0)
}

///|
/// Returns the world X coordinate of the right boundary of the viewport.
pub fn world_right() -> Float {
  Float::from_int(world_x0 + world_w)
}

///|
/// Returns the world Y coordinate of the top boundary of the viewport.
pub fn world_top() -> Float {
  Float::from_int(world_y0)
}

///|
/// Returns the world Y coordinate of the bottom boundary of the viewport.
pub fn world_bottom() -> Float {
  Float::from_int(world_y0 + world_h)
}

///|
/// Returns the squared Euclidean distance between two 2D points.
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
/// Returns the world X coordinate of the central power cell depot.
pub fn depot_x() -> Float {
  Float::from_int(world_x0 + 132)
}

///|
/// Returns the world Y coordinate of the central power cell depot.
pub fn depot_y() -> Float {
  Float::from_int(world_y0 + world_h - 126)
}

///|
/// Returns the interaction radius of the depot in pixels.
pub fn depot_r() -> Float {
  70.0
}

///|
/// Returns the collision radius used for hit detection on relay towers in pixels.
pub fn tower_hit_r() -> Float {
  30.0
}

///|
/// Returns the interaction radius within which the rover can deliver cells to a relay tower in pixels.
pub fn tower_interact_r() -> Float {
  66.0
}

///|
/// Returns the screen rectangle `(x, y, w, h)` for the title screen start button.
pub fn title_start_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 220, screen_h / 2 + 128, 440, 92)
}

///|
/// Returns the screen rectangle `(x, y, w, h)` for the primary action button on the result screen.
pub fn result_primary_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 236, screen_h / 2 + 116, 472, 88)
}

///|
/// Returns the screen rectangle `(x, y, w, h)` for the secondary action button on the result screen.
pub fn result_secondary_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 236, screen_h / 2 + 224, 472, 74)
}

///|
/// Returns the screen rectangle `(x, y, w, h)` for the touch left-movement button in the panel.
pub fn touch_left_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 24, screen_h - 190, 76, 76)
}

///|
/// Returns the screen rectangle `(x, y, w, h)` for the touch right-movement button in the panel.
pub fn touch_right_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 184, screen_h - 190, 76, 76)
}

///|
/// Returns the screen rectangle `(x, y, w, h)` for the touch up-movement button in the panel.
pub fn touch_up_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 104, screen_h - 270, 76, 76)
}

///|
/// Returns the screen rectangle `(x, y, w, h)` for the touch down-movement button in the panel.
pub fn touch_down_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 104, screen_h - 110, 76, 76)
}

///|
/// Returns the screen rectangle `(x, y, w, h)` for the touch action button in the panel.
pub fn touch_action_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + panel_w - 128, screen_h - 228, 104, 104)
}

///|
/// Returns true if the point `(x, y)` lies inside the axis-aligned screen rectangle defined by `(rx, ry, rw, rh)`.
pub fn point_in_rect(
  x : Float,
  y : Float,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  let fx0 = Float::from_int(rx)
  let fy0 = Float::from_int(ry)
  let fx1 = Float::from_int(rx + rw)
  let fy1 = Float::from_int(ry + rh)
  x >= fx0 && x <= fx1 && y >= fy0 && y <= fy1
}

///|
/// Returns true if the mouse pointer (when held) or any active touch point lies inside the given screen rectangle.
pub fn pointer_on_rect(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
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
