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
/// Returns the absolute value of a float.
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
/// Linearly interpolates between two floats using `t` in `[0, 1]`.
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
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
/// Returns the square root of a non-negative float.
pub fn sqrtf(v : Float) -> Float {
  v.sqrt()
}

///|
/// Returns a pseudo-random float sampled from `[lo, hi]`.
pub fn randf(lo : Float, hi : Float) -> Float {
  let n = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * n
}

///|
/// Returns a pseudo-random integer sampled from `[lo, hi]`.
pub fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
/// Returns a computed helper value for chance.
pub fn chance(pct : Int) -> Bool {
  randi(0, 99) < pct
}

///|
/// Returns squared distance between two 2D points.
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
/// Applies a cubic ease-out curve to a normalized input value.
pub fn ease_out_cubic(t : Float) -> Float {
  let x = clampf(t, 0.0, 1.0)
  Float::from_int(1) -
  (Float::from_int(1) - x) * (Float::from_int(1) - x) * (Float::from_int(1) - x)
}

///|
/// Returns world-space coordinates for track center.
pub fn track_center(depth : Float, time_s : Float) -> Float {
  let c = Float::from_int(screen_w / 2)
  let sway0 = sinf(depth * 0.0025 + time_s * 0.68) * 150.0
  let sway1 = sinf(depth * 0.004 + time_s * 1.18 + 1.2) * 86.0
  c + sway0 + sway1
}

///|
/// Returns geometry information for track half width.
pub fn track_half_width(stage : Int, depth : Float, time_s : Float) -> Float {
  let wobble = sinf(depth * 0.0035 + time_s * 0.92 + 0.8) * 58.0
  let shrink = Float::from_int(stage - 1) * 10.0
  clampf(
    Float::from_int(305) + wobble - shrink,
    Float::from_int(160),
    Float::from_int(334),
  )
}

///|
/// Returns derived layout data for lane offset.
pub fn lane_offset(lane : Int) -> Float {
  (Float::from_int(lane) - Float::from_int(lane_count - 1) * 0.5) * lane_gap
}

///|
/// Returns derived layout data for lane pos.
pub fn lane_pos(lane : Int, center : Float) -> Float {
  center + lane_offset(clampi(lane, 0, lane_count - 1))
}

///|
/// Returns geometry information for track edges.
pub fn track_edges(
  stage : Int,
  depth : Float,
  time_s : Float,
) -> (Float, Float) {
  let c = track_center(depth, time_s)
  let hw = track_half_width(stage, depth, time_s)
  (c - hw, c + hw)
}

///|
/// Returns world-space coordinates for spawn x.
pub fn spawn_x(
  distance : Float,
  time_s : Float,
  stage : Int,
  y : Float,
) -> Float {
  let depth = distance + (Float::from_int(screen_h) - y)
  let c = track_center(depth, time_s)
  let hw = track_half_width(stage, depth, time_s)
  randf(c - hw + 56.0, c + hw - 56.0)
}

///|
/// Returns helper data for bg top.
pub fn bg_top() -> @raylib.Color {
  @raylib.Color::new(10, 10, 24, 255)
}

///|
/// Returns helper data for bg bottom.
pub fn bg_bottom() -> @raylib.Color {
  @raylib.Color::new(12, 26, 44, 255)
}

///|
/// Returns geometry information for track dark.
pub fn track_dark() -> @raylib.Color {
  @raylib.Color::new(16, 20, 34, 255)
}

///|
/// Returns geometry information for track mid.
pub fn track_mid() -> @raylib.Color {
  @raylib.Color::new(22, 30, 50, 255)
}

///|
/// Returns the predefined palette color amber.
pub fn amber() -> @raylib.Color {
  @raylib.Color::new(255, 214, 124, 255)
}

///|
/// Returns the configured UI or gameplay color for armor col.
pub fn armor_col() -> @raylib.Color {
  @raylib.Color::new(255, 122, 154, 255)
}

///|
/// Returns the configured UI or gameplay color for heat col.
pub fn heat_col() -> @raylib.Color {
  @raylib.Color::new(116, 244, 196, 255)
}

///|
/// Returns helper data for btn size.
pub fn btn_size() -> Float {
  Float::from_int(104)
}

///|
/// Returns the touch or HUD hit area for btn left rect.
pub fn btn_left_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(20),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
/// Returns the touch or HUD hit area for btn right rect.
pub fn btn_right_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(134),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
/// Returns the touch or HUD hit area for btn up rect.
pub fn btn_up_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(248),
    Float::from_int(screen_h) - s * Float::from_int(2) - Float::from_int(34),
    s,
    s,
  )
}

///|
/// Returns the touch or HUD hit area for btn down rect.
pub fn btn_down_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(248),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
/// Returns the touch or HUD hit area for btn fire rect.
pub fn btn_fire_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s - Float::from_int(20),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
/// Returns the touch or HUD hit area for btn dash rect.
pub fn btn_dash_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s * Float::from_int(2) - Float::from_int(34),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
/// Returns the touch or HUD hit area for btn emp rect.
pub fn btn_emp_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s - Float::from_int(20),
    Float::from_int(screen_h) - s * Float::from_int(2) - Float::from_int(34),
    s,
    s,
  )
}

///|
/// Returns the touch or HUD hit area for title start rect.
pub fn title_start_rect() -> (Float, Float, Float, Float) {
  let w = Float::from_int(420)
  let h = Float::from_int(88)
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.64,
    w,
    h,
  )
}

///|
/// Returns the touch or HUD hit area for retry rect.
pub fn retry_rect() -> (Float, Float, Float, Float) {
  let w = Float::from_int(220)
  let h = Float::from_int(64)
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.74,
    w,
    h,
  )
}

///|
/// Returns the rectangle used for point in rect.
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
/// Returns the rectangle used for pointer on rect.
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
/// Returns whether is hostile is true for the current query.
pub fn is_hostile(kind : ObjKind) -> Bool {
  match kind {
    Scout | Spinner | Tank | GearWall => true
    Coin | Coolant | EmpCell => false
  }
}

///|
/// Returns whether is pickup is true for the current query.
pub fn is_pickup(kind : ObjKind) -> Bool {
  match kind {
    Coin | Coolant | EmpCell => true
    Scout | Spinner | Tank | GearWall => false
  }
}

///|
/// Returns collision or positioning data for obj hit r.
pub fn obj_hit_r(o : Obj) -> Float {
  maxf(o.w, o.h) * 0.38
}

///|
/// Returns collision or positioning data for player hit r.
pub fn player_hit_r(p : Player) -> Float {
  maxf(p.w, p.h) * 0.34
}

///|
/// Returns a computed helper value for alpha color.
pub fn alpha_color(c : @raylib.Color, a : Int) -> @raylib.Color {
  @raylib.Color::new(
    c.r.to_int(),
    c.g.to_int(),
    c.b.to_int(),
    clampi(a, 0, 255),
  )
}
