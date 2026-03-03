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
/// Linearly interpolates between two floats using `t` in `[0, 1]`.
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
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
/// Returns geometry information for road center at.
pub fn road_center_at(depth : Float, time_s : Float) -> Float {
  let cx = Float::from_int(screen_w / 2)
  let sway0 = @math.sinf(depth * 0.0024 + time_s * 0.72) * 146.0
  let sway1 = @math.sinf(depth * 0.0041 + time_s * 1.2 + 1.4) * 84.0
  cx + sway0 + sway1
}

///|
/// Returns geometry information for road half width.
pub fn road_half_width(stage : Int, depth : Float, time_s : Float) -> Float {
  let pulse = @math.sinf(depth * 0.0037 + time_s * 0.95 + 0.7) * 62.0
  let shrink = Float::from_int(stage - 1) * 10.0
  clampf(
    Float::from_int(310) + pulse - shrink,
    Float::from_int(164),
    Float::from_int(332),
  )
}

///|
/// Returns derived layout data for lane to offset.
pub fn lane_to_offset(lane : Int) -> Float {
  (Float::from_int(lane) - Float::from_int(lanes_count - 1) * 0.5) * lane_gap
}

///|
/// Returns world-space coordinates for lane x.
pub fn lane_x(lane : Int, center : Float) -> Float {
  center + lane_to_offset(lane.clamp(min=0, max=lanes_count - 1))
}

///|
/// Returns geometry information for road edges.
pub fn road_edges(stage : Int, depth : Float, time_s : Float) -> (Float, Float) {
  let c = road_center_at(depth, time_s)
  let hw = road_half_width(stage, depth, time_s)
  (c - hw, c + hw)
}

///|
/// Returns world-space coordinates for road spawn x.
pub fn road_spawn_x(
  game_depth : Float,
  game_time : Float,
  stage : Int,
  y : Float,
) -> Float {
  let d = game_depth + (Float::from_int(screen_h) - y)
  let c = road_center_at(d, game_time)
  let hw = road_half_width(stage, d, game_time)
  let lo = c - hw + 58.0
  let hi = c + hw - 58.0
  randf(lo, hi)
}

///|
/// Returns helper data for bg top.
pub fn bg_top() -> @raylib.Color {
  @raylib.Color::new(8, 8, 24, 255)
}

///|
/// Returns helper data for bg bottom.
pub fn bg_bottom() -> @raylib.Color {
  @raylib.Color::new(10, 24, 46, 255)
}

///|
/// Returns geometry information for road dark.
pub fn road_dark() -> @raylib.Color {
  @raylib.Color::new(14, 20, 34, 255)
}

///|
/// Returns geometry information for road mid.
pub fn road_mid() -> @raylib.Color {
  @raylib.Color::new(20, 30, 52, 255)
}

///|
/// Returns the predefined palette color neon yellow.
pub fn neon_yellow() -> @raylib.Color {
  @raylib.Color::new(255, 222, 118, 255)
}

///|
/// Returns the configured UI or gameplay color for shield col.
pub fn shield_col() -> @raylib.Color {
  @raylib.Color::new(255, 116, 152, 255)
}

///|
/// Returns the configured UI or gameplay color for energy col.
pub fn energy_col() -> @raylib.Color {
  @raylib.Color::new(112, 244, 196, 255)
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
/// Returns the touch or HUD hit area for btn boost rect.
pub fn btn_boost_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s * Float::from_int(2) - Float::from_int(34),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
/// Returns the touch or HUD hit area for btn hack rect.
pub fn btn_hack_rect() -> (Float, Float, Float, Float) {
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
  let h = Float::from_int(90)
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.64,
    w,
    h,
  )
}

///|
/// Returns the touch or HUD hit area for result retry rect.
pub fn result_retry_rect() -> (Float, Float, Float, Float) {
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
/// Returns whether entity is hostile is true for the current query.
pub fn entity_is_hostile(kind : EntityKind) -> Bool {
  match kind {
    FoeBike | FoeDrone | FoeTruck | FoeLaser => true
    ItemCredit | ItemBattery | ItemHackcell => false
  }
}

///|
/// Returns whether is pickup is true for the current query.
pub fn is_pickup(kind : EntityKind) -> Bool {
  match kind {
    ItemCredit | ItemBattery | ItemHackcell => true
    FoeBike | FoeDrone | FoeTruck | FoeLaser => false
  }
}

///|
/// Returns collision or positioning data for entity hit radius.
pub fn entity_hit_radius(e : Entity) -> Float {
  maxf(e.w, e.h) * 0.38
}

///|
/// Returns collision or positioning data for player hit radius.
pub fn player_hit_radius(hero : Player) -> Float {
  maxf(hero.w, hero.h) * 0.34
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
