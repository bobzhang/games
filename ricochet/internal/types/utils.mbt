///|
pub fn cosf(a : Float) -> Float {
  Float::from_double(@math.cos(a.to_double()))
}

///|
pub fn sinf(a : Float) -> Float {
  Float::from_double(@math.sin(a.to_double()))
}

///|
pub fn sqrtf(a : Float) -> Float {
  Float::from_double(a.to_double().sqrt())
}

///|
pub fn atan2f(y : Float, x : Float) -> Float {
  Float::from_double(@math.atan2(y.to_double(), x.to_double()))
}

///|
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
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
pub fn vec2(x : Float, y : Float) -> Vec2 {
  { x, y, }
}

///|
pub fn vec2_zero() -> Vec2 {
  { x: 0.0, y: 0.0, }
}

///|
pub fn vec2_add(a : Vec2, b : Vec2) -> Vec2 {
  { x: a.x + b.x, y: a.y + b.y, }
}

///|
pub fn vec2_sub(a : Vec2, b : Vec2) -> Vec2 {
  { x: a.x - b.x, y: a.y - b.y, }
}

///|
pub fn vec2_scale(v : Vec2, s : Float) -> Vec2 {
  { x: v.x * s, y: v.y * s, }
}

///|
pub fn vec2_len(v : Vec2) -> Float {
  sqrtf(v.x * v.x + v.y * v.y)
}

///|
pub fn vec2_dist(a : Vec2, b : Vec2) -> Float {
  let dx = a.x - b.x
  let dy = a.y - b.y
  sqrtf(dx * dx + dy * dy)
}

///|
pub fn vec2_normalize(v : Vec2) -> Vec2 {
  let len = vec2_len(v)
  if len < 0.0001 {
    vec2_zero()
  } else {
    { x: v.x / len, y: v.y / len, }
  }
}

///|
pub fn vec2_dot(a : Vec2, b : Vec2) -> Float {
  a.x * b.x + a.y * b.y
}

///|
pub fn vec2_reflect(v : Vec2, normal : Vec2) -> Vec2 {
  let d : Float = 2.0 * vec2_dot(v, normal)
  { x: v.x - d * normal.x, y: v.y - d * normal.y, }
}

///|
pub fn vec2_rotate(v : Vec2, angle : Float) -> Vec2 {
  let c = cosf(angle)
  let s = sinf(angle)
  { x: v.x * c - v.y * s, y: v.x * s + v.y * c, }
}

///|
pub fn vec2_neg(v : Vec2) -> Vec2 {
  { x: -v.x, y: -v.y, }
}

///|
/// Distance from point p to line segment (a, b).
/// Returns (distance, closest_point_t_parameter).
pub fn point_to_segment_dist(p : Vec2, a : Vec2, b : Vec2) -> (Float, Float) {
  let ab = vec2_sub(b, a)
  let ap = vec2_sub(p, a)
  let ab_len_sq = vec2_dot(ab, ab)
  if ab_len_sq < 0.0001 {
    return (vec2_dist(p, a), 0.0)
  }
  let t = clampf(vec2_dot(ap, ab) / ab_len_sq, 0.0, 1.0)
  let closest = vec2_add(a, vec2_scale(ab, t))
  (vec2_dist(p, closest), t)
}

///|
/// Line segment normal (perpendicular, normalized).
pub fn segment_normal(a : Vec2, b : Vec2) -> Vec2 {
  let dx = b.x - a.x
  let dy = b.y - a.y
  vec2_normalize({ x: -dy, y: dx, })
}

///|
/// Check if two line segments intersect.
/// Returns Some(t) where t is parameter along first segment, or None.
pub fn segment_intersect(p1 : Vec2, p2 : Vec2, p3 : Vec2, p4 : Vec2) -> Float? {
  let d1 = vec2_sub(p2, p1)
  let d2 = vec2_sub(p4, p3)
  let cross = d1.x * d2.y - d1.y * d2.x
  if absf(cross) < 0.0001 {
    return None
  }
  let d3 = vec2_sub(p3, p1)
  let t = (d3.x * d2.y - d3.y * d2.x) / cross
  let u = (d3.x * d1.y - d3.y * d1.x) / cross
  if t >= 0.0 && t <= 1.0 && u >= 0.0 && u <= 1.0 {
    Some(t)
  } else {
    None
  }
}

///|
let rng_state : Ref[Int] = { val: 42, }

///|
pub fn seed_rng(s : Int) -> Unit {
  rng_state.val = s
}

///|
pub fn rng_next() -> Int {
  rng_state.val = rng_state.val * 1103515245 + 12345
  let v = rng_state.val / 65536
  if v < 0 {
    -v
  } else {
    v
  }
}

///|
pub fn rng_float() -> Float {
  Float::from_int(rng_next() % 10000) / 10000.0
}

// Constructors

///|
pub fn new_ball(pos : Vec2, vel : Vec2) -> Ball {
  {
    pos: { x: pos.x, y: pos.y, },
    vel: { x: vel.x, y: vel.y, },
    active: true,
    bounce_count: 0,
    trail: [],
  }
}

///|
pub fn new_wall(x1 : Float, y1 : Float, x2 : Float, y2 : Float) -> Wall {
  { p1: vec2(x1, y1), p2: vec2(x2, y2), }
}

///|
pub fn new_target(x : Float, y : Float, radius : Float) -> Target {
  { pos: vec2(x, y), radius, hit: false, hit_timer: 0.0, }
}

///|
pub fn new_splitter(x : Float, y : Float, radius : Float) -> Splitter {
  { pos: vec2(x, y), radius, pulse_timer: 0.0, }
}

///|
pub fn new_gate(
  x1 : Float,
  y1 : Float,
  x2 : Float,
  y2 : Float,
  dx : Float,
  dy : Float,
) -> Gate {
  {
    p1: vec2(x1, y1),
    p2: vec2(x2, y2),
    direction: vec2_normalize(vec2(dx, dy)),
  }
}

///|
pub fn new_bumper(x : Float, y : Float, radius : Float) -> Bumper {
  { pos: vec2(x, y), radius, hit_timer: 0.0, }
}

///|
pub fn new_pickup(x : Float, y : Float, radius : Float) -> LevelPickup {
  { pos: vec2(x, y), radius, collected: false, }
}

///|
pub fn new_level_score() -> LevelScore {
  { stars: 0, completed: false, best_bounces: 999, }
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = []
  for _i in 0..<total_levels {
    scores.push(new_level_score())
  }
  {
    screen: Title,
    world: 0,
    level_index: 0,
    aim_angle: -pi / 4.0,
    ball_state: Aiming,
    balls: [],
    current_level: None,
    scores,
    total_bounces: 0,
    message: "",
    message_timer: 0.0,
    frame_count: 0,
    rng: 42,
    preview_points: [],
    anim_timer: 0.0,
    result_timer: 0.0,
    title_pulse: 0.0,
  }
}

///|
pub fn reset_level(game : Game) -> Unit {
  game.ball_state = Aiming
  game.balls.clear()
  game.total_bounces = 0
  game.aim_angle = -pi / 4.0
  game.result_timer = 0.0
  game.message = ""
  game.message_timer = 0.0
  match game.current_level {
    Some(lvl) => {
      for i in 0..<lvl.targets.length() {
        lvl.targets[i].hit = false
        lvl.targets[i].hit_timer = 0.0
      }
      for i in 0..<lvl.splitters.length() {
        lvl.splitters[i].pulse_timer = 0.0
      }
      for i in 0..<lvl.bumpers.length() {
        lvl.bumpers[i].hit_timer = 0.0
      }
      for i in 0..<lvl.pickups.length() {
        lvl.pickups[i].collected = false
      }
    }
    None => ()
  }
}

///|
pub fn all_targets_hit(level : Level) -> Bool {
  for i in 0..<level.targets.length() {
    if !level.targets[i].hit {
      return false
    }
  }
  true
}

///|
pub fn any_ball_active(balls : Array[Ball]) -> Bool {
  for i in 0..<balls.length() {
    if balls[i].active {
      return true
    }
  }
  false
}

///|
pub fn count_targets_hit(level : Level) -> Int {
  let mut count = 0
  for i in 0..<level.targets.length() {
    if level.targets[i].hit {
      count += 1
    }
  }
  count
}

///|
pub fn pickup_collected(level : Level) -> Bool {
  for i in 0..<level.pickups.length() {
    if level.pickups[i].collected {
      return true
    }
  }
  level.pickups.length() == 0
}

///|
pub fn global_level_index(world : Int, level : Int) -> Int {
  world * levels_per_world + level
}
