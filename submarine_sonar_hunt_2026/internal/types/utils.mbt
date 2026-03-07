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
/// Returns the larger of two float values.
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
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
/// Returns geometry information for arena left.
pub fn arena_left() -> Float {
  Float::from_int(arena_x0)
}

///|
/// Returns geometry information for arena right.
pub fn arena_right() -> Float {
  Float::from_int(arena_x1)
}

///|
/// Returns geometry information for arena top.
pub fn arena_top() -> Float {
  Float::from_int(arena_y0)
}

///|
/// Returns geometry information for arena bottom.
pub fn arena_bottom() -> Float {
  Float::from_int(arena_y1)
}

///|
/// Returns the touch or HUD hit area for title start button rect.
pub fn title_start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 180, screen_h / 2 + 112, 360, 72)
}

///|
/// Returns the touch or HUD hit area for result restart button rect.
pub fn result_restart_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 190, screen_h / 2 + 84, 180, 64)
}

///|
/// Returns the touch or HUD hit area for result next button rect.
pub fn result_next_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 + 10, screen_h / 2 + 84, 180, 64)
}

///|
/// Returns the touch or HUD hit area for result title button rect.
pub fn result_title_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 110, screen_h / 2 + 160, 220, 52)
}

///|
/// Returns the touch or HUD hit area for mobile left btn.
pub fn mobile_left_btn() -> (Int, Int, Int, Int) {
  (34, screen_h - 146, 66, 66)
}

///|
/// Returns the touch or HUD hit area for mobile right btn.
pub fn mobile_right_btn() -> (Int, Int, Int, Int) {
  (182, screen_h - 146, 66, 66)
}

///|
/// Returns the touch or HUD hit area for mobile up btn.
pub fn mobile_up_btn() -> (Int, Int, Int, Int) {
  (108, screen_h - 220, 66, 66)
}

///|
/// Returns the touch or HUD hit area for mobile down btn.
pub fn mobile_down_btn() -> (Int, Int, Int, Int) {
  (108, screen_h - 72, 66, 66)
}

///|
/// Returns the touch or HUD hit area for mobile sonar btn.
pub fn mobile_sonar_btn() -> (Int, Int, Int, Int) {
  (screen_w - 184, screen_h - 152, 148, 66)
}

///|
/// Returns the touch or HUD hit area for mobile boost btn.
pub fn mobile_boost_btn() -> (Int, Int, Int, Int) {
  (screen_w - 184, screen_h - 76, 148, 58)
}

///|
/// Returns the touch or HUD hit area for mobile restart btn.
pub fn mobile_restart_btn() -> (Int, Int, Int, Int) {
  (screen_w - 148, 20, 128, 46)
}

///|
/// Returns world-space coordinates for in hot zone xy.
pub fn in_hot_zone_xy(x : Float, y : Float) -> Bool {
  dist2(x, y, hot_zone_x, hot_zone_y) <= hot_zone_r * hot_zone_r
}

///|
/// Returns the rectangle used for point in rect.
pub fn point_in_rect(
  x : Float,
  y : Float,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  let x0 = Float::from_int(rx)
  let y0 = Float::from_int(ry)
  let x1 = Float::from_int(rx + rw)
  let y1 = Float::from_int(ry + rh)
  x >= x0 && x <= x1 && y >= y0 && y <= y1
}

///|
/// Returns the rectangle used for pointer on rect.
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

///|
/// Returns AI or spawn-planning data for nearest undetected target.
pub fn nearest_undetected_target(game : Game) -> (Float, Float, Bool) {
  let (best_x, best_y, found) = for i in 0..<game.target_goal;
      best_x = game.sub_x, best_y = game.sub_y, found = false,
      best_d = 1_000_000_000.0F {
    if !game.targets[i].active || game.targets[i].detected {
      continue
    }
    let d = dist2(game.sub_x, game.sub_y, game.targets[i].x, game.targets[i].y)
    if d < best_d {
      continue game.targets[i].x, game.targets[i].y, true, d
    }
  } nobreak {
    (best_x, best_y, found)
  }
  (best_x, best_y, found)
}

///|
/// Returns a derived gameplay metric for lose reason text.
pub fn lose_reason_text(game : Game) -> String {
  match game.lose_reason {
    Hull => "Hull failure after mine impact"
    Oxygen => "Crew oxygen depleted"
    Fuel => "Fuel reserves exhausted"
    None => "Mission failed"
  }
}
