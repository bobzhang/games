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
pub fn vec2f(x : Float, y : Float) -> Vec2f {
  { x, y }
}

///|
pub fn vec2f_zero() -> Vec2f {
  { x: 0.0, y: 0.0 }
}

///|
pub fn vec2f_add(a : Vec2f, b : Vec2f) -> Vec2f {
  { x: a.x + b.x, y: a.y + b.y }
}

///|
pub fn vec2f_sub(a : Vec2f, b : Vec2f) -> Vec2f {
  { x: a.x - b.x, y: a.y - b.y }
}

///|
pub fn vec2f_scale(v : Vec2f, s : Float) -> Vec2f {
  { x: v.x * s, y: v.y * s }
}

///|
pub fn vec2f_len(v : Vec2f) -> Float {
  sqrtf(v.x * v.x + v.y * v.y)
}

///|
pub fn vec2f_dist(a : Vec2f, b : Vec2f) -> Float {
  let dx = a.x - b.x
  let dy = a.y - b.y
  sqrtf(dx * dx + dy * dy)
}

///|
pub fn vec2f_dist_sq(a : Vec2f, b : Vec2f) -> Float {
  let dx = a.x - b.x
  let dy = a.y - b.y
  dx * dx + dy * dy
}

///|
pub fn vec2f_normalize(v : Vec2f) -> Vec2f {
  let len = vec2f_len(v)
  if len < 0.001 {
    vec2f_zero()
  } else {
    { x: v.x / len, y: v.y / len }
  }
}

///|
pub fn gravity_accel(
  probe_pos : Vec2f,
  planet_pos : Vec2f,
  planet_mass : Float
) -> Vec2f {
  let diff = vec2f_sub(planet_pos, probe_pos)
  let dist_sq = vec2f_dist_sq(probe_pos, planet_pos)
  let dist = sqrtf(dist_sq)
  if dist < 1.0 {
    return vec2f_zero()
  }
  let force_mag = gravity_g * planet_mass / dist_sq
  let dir = vec2f_normalize(diff)
  vec2f_scale(dir, force_mag)
}

///|
pub fn make_planet(x : Float, y : Float, mass : Float, radius : Float) -> Planet {
  { pos: vec2f(x, y), mass, radius }
}

///|
pub fn make_station(x : Float, y : Float, radius : Float) -> Station {
  { pos: vec2f(x, y), radius }
}

///|
pub fn make_waypoint(x : Float, y : Float, radius : Float) -> Waypoint {
  { pos: vec2f(x, y), radius, collected: false }
}

///|
pub fn make_level(
  planets : Array[Planet],
  station : Station,
  waypoints : Array[Waypoint],
  launch_x : Float,
  launch_y : Float,
  par_ticks : Int,
  name : String,
  tier : Tier
) -> Level {
  {
    planets,
    station,
    waypoints,
    launch_pos: vec2f(launch_x, launch_y),
    par_ticks,
    name,
    tier,
  }
}

///|
pub fn make_star(x : Float, y : Float, brightness : Int, size : Float) -> Star {
  { x, y, brightness, size }
}

///|
pub fn new_probe() -> Probe {
  { pos: vec2f_zero(), vel: vec2f_zero(), active: false }
}

///|
pub fn new_score() -> LevelScore {
  { completed: false, best_ticks: 9999, stars: 0 }
}

///|
let rng_state : Ref[Int] = { val: 12345 }

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
pub fn rng_int(max : Int) -> Int {
  if max <= 0 {
    0
  } else {
    rng_next() % max
  }
}

///|
pub fn rng_float() -> Float {
  Float::from_int(rng_next() % 10000) / 10000.0
}

///|
pub fn generate_stars() -> Array[Star] {
  seed_rng(777)
  let stars : Array[Star] = []
  for _i in 0..<120 {
    let x = rng_float() * Float::from_int(screen_width)
    let y = rng_float() * Float::from_int(screen_height)
    let brightness = 40 + rng_int(160)
    let size : Float = 0.5 + rng_float() * 1.5
    stars.push(make_star(x, y, brightness, size))
  }
  stars
}

///|
pub fn new_game() -> Game {
  let scores : Array[LevelScore] = []
  for _i in 0..<total_levels {
    scores.push(new_score())
  }
  {
    screen: Title,
    play_state: Aiming,
    current_tier: Launch,
    current_level: 0,
    launch_angle: 0.0,
    probe: new_probe(),
    tick_count: 0,
    trail: [],
    preview: [],
    scores,
    frame_count: 0,
    stars: generate_stars(),
    message: "",
    message_timer: 0.0,
  }
}

///|
pub fn tier_start_index(tier : Tier) -> Int {
  match tier {
    Launch => 0
    Slingshot => tier1_count
    Navigation => tier1_count + tier2_count
  }
}

///|
pub fn tier_level_count(tier : Tier) -> Int {
  match tier {
    Launch => tier1_count
    Slingshot => tier2_count
    Navigation => tier3_count
  }
}

///|
pub fn tier_name(tier : Tier) -> String {
  match tier {
    Launch => "LAUNCH"
    Slingshot => "SLINGSHOT"
    Navigation => "NAVIGATION"
  }
}

///|
pub fn tier_color(tier : Tier) -> @raylib.Color {
  match tier {
    Launch => color_tier_launch
    Slingshot => color_tier_sling
    Navigation => color_tier_nav
  }
}

///|
pub fn tier_unlocked(tier : Tier, scores : Array[LevelScore]) -> Bool {
  match tier {
    Launch => true
    Slingshot => {
      let mut count = 0
      for i in 0..<tier1_count {
        if scores[i].completed {
          count += 1
        }
      }
      count >= 4
    }
    Navigation => {
      let mut count = 0
      for i = tier1_count; i < tier1_count + tier2_count; i = i + 1 {
        if scores[i].completed {
          count += 1
        }
      }
      count >= 5
    }
  }
}

///|
pub fn level_index_for(tier : Tier, idx : Int) -> Int {
  tier_start_index(tier) + idx
}

///|
pub fn set_message(game : Game, msg : String, duration : Float) -> Unit {
  game.message = msg
  game.message_timer = duration
}
