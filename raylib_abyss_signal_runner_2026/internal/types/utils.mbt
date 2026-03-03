///|
/// Clamps an integer value to the inclusive `[lo, hi]` range.
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  v.clamp(min=lo, max=hi)
}

///|
/// Clamps a float value to the inclusive `[lo, hi]` range.
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
/// Returns true with probability `p` percent.
pub fn chance(p : Int) -> Bool {
  randi(0, 99) < p
}

///|
/// Returns squared Euclidean distance between two points.
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
/// Quadratic ease-out curve clamped to input range `[0, 1]`.
pub fn ease_out_quad(t : Float) -> Float {
  let x = clampf(t, 0.0, 1.0)
  1.0 - (1.0 - x) * (1.0 - x)
}

///|
/// Computes cave center X at depth `y` and time `t`.
pub fn cave_center(y : Float, t : Float) -> Float {
  let base = Float::from_int(screen_w / 2)
  let s0 = @math.sinf(y * 0.004 + t * 0.6) * 170.0
  let s1 = @math.sinf(y * 0.0022 + t * 1.1 + 1.4) * 80.0
  base + s0 + s1
}

///|
/// Computes cave half-width at depth/time with stage-based narrowing.
pub fn cave_half_width(y : Float, t : Float, stage : Int) -> Float {
  let wobble = @math.sinf(y * 0.0033 + t * 0.7 + 0.9) * 62.0
  let shrink = Float::from_int(stage - 1) * 8.0
  clampf(cave_max_half + wobble - shrink, cave_min_half, cave_max_half)
}

///|
/// Primary top background color for the abyss scene.
pub fn bg_top() -> @raylib.Color {
  @raylib.Color::new(8, 14, 28, 255)
}

///|
/// Primary bottom background color for the abyss scene.
pub fn bg_bottom() -> @raylib.Color {
  @raylib.Color::new(7, 28, 44, 255)
}

///|
/// Accent color used for cave glow rendering.
pub fn cave_glow() -> @raylib.Color {
  @raylib.Color::new(82, 222, 255, 255)
}

///|
/// Accent color used for hazards.
pub fn hazard_col() -> @raylib.Color {
  @raylib.Color::new(255, 98, 158, 255)
}

///|
/// Accent color used for collectible data nodes.
pub fn data_col() -> @raylib.Color {
  @raylib.Color::new(146, 255, 190, 255)
}

///|
/// Accent color used for oxygen pickups and bars.
pub fn oxygen_col() -> @raylib.Color {
  @raylib.Color::new(146, 218, 255, 255)
}

///|
/// Accent color used for sonar/phase visuals.
pub fn phase_col() -> @raylib.Color {
  @raylib.Color::new(186, 146, 255, 255)
}

///|
/// Accent color used for hull/health indicators.
pub fn hp_col() -> @raylib.Color {
  @raylib.Color::new(255, 116, 156, 255)
}

///|
/// Side length of on-screen touch control buttons.
pub fn btn_size() -> Float {
  Float::from_int(102)
}

///|
/// Returns the touch rectangle for moving left.
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
/// Returns the touch rectangle for moving right.
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
/// Returns the touch rectangle for moving up.
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
/// Returns the touch rectangle for moving down.
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
/// Returns the touch rectangle for activating dash.
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
/// Returns the touch rectangle for activating sonar.
pub fn btn_sonar_rect() -> (Float, Float, Float, Float) {
  let s = btn_size()
  (
    Float::from_int(screen_w) - s - Float::from_int(20),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
/// Returns whether point `(x, y)` lies inside a rectangle.
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
/// Returns whether mouse hold or touch input is inside a rectangle.
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
/// Returns the title screen start button rectangle.
pub fn title_start_rect() -> (Float, Float, Float, Float) {
  let w = Float::from_int(410)
  let h = Float::from_int(88)
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.62,
    w,
    h,
  )
}

///|
/// Returns the game-over restart button rectangle.
pub fn restart_rect() -> (Float, Float, Float, Float) {
  let w = Float::from_int(180)
  let h = Float::from_int(56)
  (
    Float::from_int(screen_w) * 0.5 - w * 0.5,
    Float::from_int(screen_h) * 0.72,
    w,
    h,
  )
}

///|
/// Converts a screen-space Y coordinate to world depth.
pub fn depth_at_screen(game : Game, y : Float) -> Float {
  game.distance + (Float::from_int(screen_h) - y)
}

///|
/// Returns the left and right cave edges at a screen-space Y.
pub fn cave_edges(game : Game, y : Float) -> (Float, Float) {
  let d = depth_at_screen(game, y)
  let c = cave_center(d, game.time_s)
  let hw = cave_half_width(d, game.time_s, game.stage)
  (c - hw, c + hw)
}

///|
/// Finds a free trail slot or reuses the shortest-lived active trail.
pub fn alloc_trail(game : Game) -> Int {
  for i in 0..<game.trails.length() {
    if not(game.trails[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.trails[0].life
  for i in 1..<game.trails.length() {
    if game.trails[i].life < best_life {
      best_life = game.trails[i].life
      best = i
    }
  }
  best
}

///|
/// Writes a trail segment into the selected trail pool slot.
pub fn emit_trail(
  game : Game,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  life : Float,
  kind : Int,
) -> Unit {
  let i = alloc_trail(game)
  game.trails[i].active = true
  game.trails[i].x = x
  game.trails[i].y = y
  game.trails[i].w = w
  game.trails[i].h = h
  game.trails[i].life = life
  game.trails[i].kind = kind
}
